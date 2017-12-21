{ MSEgui Copyright (c) 2017 by Martin Schreiber

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
 msestockobjects,msegraphutils,msegui,msehash;

type
 
 assistiveserverstatety = (ass_active,ass_windowactivated);
 assistiveserverstatesty = set of assistiveserverstatety;
const
 internalstates = [ass_active];
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

 tassistiveserver = class;
 tassistivewidgetitem = class;

 assistiveeventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
                 const intf: iassistiveclient; var handled: boolean) of object;
 assistivemouseeventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
                 const intf: iassistiveclient; const info: mouseeventinfoty;
                                               var handled: boolean) of object;
 assistivefocuschangedeventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
                 const intf: iassistiveclient; 
                 const oldwidget,newwidget: iassistiveclient;
                 var handled: boolean) of object;
 assistivekeyeventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
                 const intf: iassistiveclient; const info: keyeventinfoty;
                                               var handled: boolean) of object;
 assistivedataeventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
             const intf: iassistiveclientdata; var handled: boolean) of object;
 assistivecelleventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
                 const intf: iassistiveclientgrid; const info: celleventinfoty;
                                               var handled: boolean) of object;
 assistiveediteventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
              const intf: iassistiveclientedit; var handled: boolean) of object;
 assistiveeditstringeventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
                const intf: iassistiveclientedit; const atext: msestring;
                                            var handled: boolean) of object;
 assistiveeditindexeventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
                        const intf: iassistiveclientedit; const index: int32; 
                                               var handled: boolean) of object;
 assistiveeditinputmodeeventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
                 const intf: iassistiveclientedit; const amode: editinputmodety;
                                               var handled: boolean) of object;
 assistiveedittextblockeventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
              const intf: iassistiveclientedit;
                 const amode: edittextblockmodety; const atext: msestring;
                                               var handled: boolean) of object;
 assistivedirectioneventty = 
  procedure(const sender: tassistivewidgetitem; const server: tassistiveserver;
                            const intf: iassistiveclient;
                                     const adirection: graphicdirectionty;
                                                var handled: boolean) of object;

 tassistivewidgetitem = class(tmsecomponent)
  private
   fserver: tassistiveserver;
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
   procedure setserver(const avalue: tassistiveserver);
   procedure setwidget(const avalue: twidget);
  protected
   procedure linkserver();
   procedure unlinkserver();
   procedure objectevent(const sender: tobject;
                                 const event: objecteventty) override;
   procedure dowindowactivated(const sender: tassistiveserver;
                         const aintf: iassistiveclient; var handled: boolean);
   procedure dowindowdeactivated(const sender: tassistiveserver;
                         const aintf: iassistiveclient; var handled: boolean);
   procedure dowindowclosed(const sender: tassistiveserver;
                          const aintf: iassistiveclient; var handled: boolean);
   procedure doenter(const sender: tassistiveserver;
                          const aintf: iassistiveclient; var handled: boolean);
   procedure doactivate(const sender: tassistiveserver;
                          const aintf: iassistiveclient; var handled: boolean);
   procedure doclientmouseevent(const sender: tassistiveserver;
              const aintf: iassistiveclient; const info: mouseeventinfoty;
                                                        var handled: boolean);
   procedure dokeydown(const sender: tassistiveserver;
           const aintf: iassistiveclient; const info: keyeventinfoty;
                                                        var handled: boolean);
   procedure dochange(const sender: tassistiveserver; 
                         const aintf: iassistiveclient; var handled: boolean);
   procedure dodataentered(const sender: tassistiveserver;
                     const aintf: iassistiveclientdata; var handled: boolean);
   procedure docellevent(const sender: tassistiveserver;
               const aintf: iassistiveclientgrid; const info: celleventinfoty;
                                                        var handled: boolean);
   procedure doeditcharenter(const sender: tassistiveserver;
                const aintf: iassistiveclientedit; const achar: msestring;
                                                        var handled: boolean);
   procedure doeditchardelete(const sender: tassistiveserver;
                const aintf: iassistiveclientedit; const achar: msestring;
                                                        var handled: boolean);
   procedure doeditindexmoved(const sender: tassistiveserver;
                   const aintf: iassistiveclientedit; const aindex: int32;
                                                        var handled: boolean);
   procedure doeditwithdrawn(const sender: tassistiveserver;
                     const aintf: iassistiveclientedit; var handled: boolean);
   procedure doedittextblock(const sender: tassistiveserver;
                     const aintf: iassistiveclientedit;
                     const amode: edittextblockmodety; const atext: msestring;
                                                         var handled: boolean);
   procedure doeditinputmodeset(const sender: tassistiveserver;
              const aintf: iassistiveclientedit; const amode: editinputmodety;
                                                         var handled: boolean);
   procedure donavigbordertouched(const sender: tassistiveserver;
                                         const aintf: iassistiveclient;
                                         const adirection: graphicdirectionty;
                                                         var handled: boolean);
  public
   destructor destroy(); override;
  published
   property server: tassistiveserver read fserver write setserver;
   property widget: twidget read fwidget write setwidget;
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
   property oncellevent: assistivecelleventty read foncellevent
                                                        write foncellevent;
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
  procedure(const sender: tassistiveserver;
                 const intf: iassistiveclient; var handled: boolean) of object;
 assistiveserverkeyeventty = 
  procedure(const sender: tassistiveserver;
                 const intf: iassistiveclient; const info: keyeventinfoty;
                                               var handled: boolean) of object;
 assistiveservermouseeventty = 
  procedure(const sender: tassistiveserver;
                 const intf: iassistiveclient; const info: mouseeventinfoty;
                                               var handled: boolean) of object;
 assistiveserverdataeventty = 
  procedure(const sender: tassistiveserver;
             const intf: iassistiveclientdata; var handled: boolean) of object;
 assistiveservercelleventty = 
  procedure(const sender: tassistiveserver;
                 const intf: iassistiveclientgrid; const info: celleventinfoty;
                                               var handled: boolean) of object;
 assistiveservereditstringeventty = 
  procedure(const sender: tassistiveserver;
            const intf: iassistiveclientedit; const achar: msestring;
                                               var handled: boolean) of object;
 assistiveserverediteventty = 
  procedure(const sender: tassistiveserver;
              const intf: iassistiveclientedit; var handled: boolean) of object;
 assistiveservereditindexeventty = 
  procedure(const sender: tassistiveserver;
                        const intf: iassistiveclientedit; const index: int32; 
                                               var handled: boolean) of object;
 assistiveservereditinputmodeeventty = 
  procedure(const sender: tassistiveserver;
                 const intf: iassistiveclientedit; const amode: editinputmodety;
                                               var handled: boolean) of object;
 assistiveserveredittextblockeventty = 
  procedure(const sender: tassistiveserver;
              const intf: iassistiveclientedit;
                 const amode: edittextblockmodety; const atext: msestring;
                                               var handled: boolean) of object;
 assistiveserverdirectioneventty = 
  procedure(const sender: tassistiveserver;
                            const intf: iassistiveclient;
                                     const adirection: graphicdirectionty;
                                                var handled: boolean) of object;

 assistiveserverfocuschangedeventty = 
  procedure(const sender: tassistiveserver;
                 const oldwidget,newwidget: iassistiveclient;
                 var handled: boolean) of object;
 assistiveserveractioneventty = 
   procedure (const sender: tassistiveserver;
                 const actionobj: tobject; const info: actioninfoty;
                                                var handled: boolean) of object;
 assistiveserveritemeventty = 
   procedure (const sender: tassistiveserver;
                 const intf: iassistiveclient; //intf can be nil
                   const items: shapeinfoarty; const aindex: integer;
                                                var handled: boolean) of object;
 assistiveservermenuitemeventty = 
   procedure (const sender: tassistiveserver;
               const intf: iassistiveclient; //intf can be nil
                const items: menucellinfoarty; const aindex: integer;
                                                var handled: boolean) of object;
 
 tassistiveserver = class(tmsecomponent,iassistiveserver)
  private
   factive: boolean;
   fspeaker: tassistivespeak;
   fvoicecaption: int32;
   fvoicetext: int32;
   fonwindowactivated: assistiveservereventty;
   fonwindowdeactivated: assistiveservereventty;
   fonwindowclosed: assistiveservereventty;
   fonenter: assistiveservereventty;
   fonactivate: assistiveservereventty;
   fonclientmouseevent: assistiveservermouseeventty;
   fonfocuschanged: assistiveserverfocuschangedeventty;
   fonkeydown: assistiveserverkeyeventty;
   fonchange: assistiveservereventty;
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
   procedure setactive(const avalue: boolean);
   procedure setspeaker(const avalue: tassistivespeak);
  protected
   fstate: assistiveserverstatesty;
   fdataenteredkeyserial: card32;
   fitems: tassistivewidgetitemlist;
   procedure activate();
   procedure deactivate();

   procedure loaded() override;

   procedure startspeak();
   
   procedure registeritem(const aintf: iassistiveclient;
                             const aitem: tassistivewidgetitem);
   procedure unregisteritem(const aintf: iassistiveclient);
   function finditem(aintf: iassistiveclient;
                        out aitem: tassistivewidgetitem): boolean;
      
    //iassistiveserver
   procedure dowindowactivated(const sender: iassistiveclient);
   procedure dowindowdeactivated(const sender: iassistiveclient);
   procedure dowindowclosed(const sender: iassistiveclient);
   procedure doenter(const sender: iassistiveclient);
   procedure doactivate(const sender: iassistiveclient);
   procedure doclientmouseevent(const sender: iassistiveclient;
                                           const info: mouseeventinfoty);
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
   procedure doeditindexmoved(const sender: iassistiveclientedit;
                                                const aindex: int32);
   procedure doeditwithdrawn(const sender: iassistiveclientedit);
   procedure doedittextblock(const sender: iassistiveclientedit;
                     const amode: edittextblockmodety; const atext: msestring);
   procedure doeditinputmodeset(const sender: iassistiveclientedit;
                                                const amode: editinputmodety);
   procedure donavigbordertouched(const sender: iassistiveclient;
                                       const adirection: graphicdirectionty);
   procedure dofocuschanged(const oldwidget,newwidget: iassistiveclient);
   procedure doitementer(const sender: iassistiveclient; //sender can be nil
                             const items: shapeinfoarty; const aindex: integer);
   procedure doitementer(const sender: iassistiveclient; //sender can be nil
                          const items: menucellinfoarty; const aindex: integer);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   procedure wait();
   procedure cancel();
   procedure speaktext(const atext: msestring; const avoice: int32 = 0);
   procedure speaktext(const atext: stockcaptionty; const avoice: int32 = 0);
   procedure speakcharacter(const achar: char32; const avoice: int32 = 0);
   procedure speakall(const sender: iassistiveclient; const addtext: boolean);
   procedure speakinput(const sender: iassistiveclientdata);
   procedure setstate(const astate: assistiveserverstatesty);
   procedure removestate(const astate: assistiveserverstatesty);
   property state: assistiveserverstatesty read fstate;
  published
   property active: boolean read factive write setactive default false;
   property speaker: tassistivespeak read fspeaker write setspeaker;
   property voicecaption: int32 read fvoicecaption 
                                          write fvoicecaption default 0;
   property voicetext: int32 read fvoicetext 
                                          write fvoicetext default 0;
   property onwindowactivated: assistiveservereventty read
                         fonwindowactivated write fonwindowactivated;
   property onwindowdeactivated: assistiveservereventty
                         read fonwindowdeactivated write fonwindowdeactivated;
   property onwindowclosed: assistiveservereventty read fonwindowclosed
                                                      write fonwindowclosed;
   property onenter: assistiveservereventty read fonenter write fonenter;
   property onactivate: assistiveservereventty read fonactivate 
                                                        write fonactivate;
   property onclientmouseevent: assistiveservermouseeventty 
                      read fonclientmouseevent write fonclientmouseevent;
   property onfocuschanged: assistiveserverfocuschangedeventty 
                           read fonfocuschanged write fonfocuschanged;
   property onkeydown: assistiveserverkeyeventty read fonkeydown 
                                                      write fonkeydown;
   property onchange: assistiveservereventty read fonchange write fonchange;
   property ondataentered: assistiveserverdataeventty read fondataentered 
                                                        write fondataentered;
   property oncellevent: assistiveservercelleventty read foncellevent
                                                        write foncellevent;
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
   property onmenuitementer: assistiveservermenuitemeventty
                        read fonmenuitementer write fonmenuitementer;
 end;
 
implementation
uses
 msekeyboard;
type
 twidget1 = class(twidget);
 
{ tassistivespeak }

constructor tassistivespeak.create(aowner: tcomponent);
begin
 inherited;
 setsubcomponent(true);
end;

{ tassistivewidgetitem }

destructor tassistivewidgetitem.destroy();
begin
 server:= nil;
 inherited;
end;

procedure tassistivewidgetitem.setserver(const avalue: tassistiveserver);
begin
 unlinkserver();
 setlinkedvar(avalue,tmsecomponent(fserver));
 linkserver();
end;

procedure tassistivewidgetitem.setwidget(const avalue: twidget);
begin
 unlinkserver();
 setlinkedvar(avalue,tmsecomponent(fwidget));
 linkserver();
end;

procedure tassistivewidgetitem.linkserver();
begin
 if (fwidget <> nil) and (fserver <> nil) and 
            not (csdesigning in componentstate) then begin
  fserver.registeritem(twidget1(fwidget).getiassistiveclient,self);
 end;
end;

procedure tassistivewidgetitem.unlinkserver();
begin
 if (fserver <> nil) and (fwidget <> nil) and 
                               not (csdesigning in componentstate) then begin
  fserver.unregisteritem(twidget1(fwidget).getiassistiveclient());
 end;
end;

procedure tassistivewidgetitem.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 if (event = oe_destroyed) and (sender = fwidget) then begin
  unlinkserver();
 end;
 inherited;
end;

procedure tassistivewidgetitem.dowindowactivated(const sender: tassistiveserver;
               const aintf: iassistiveclient; var handled: boolean);
begin
 if canevent(tmethod(fonwindowactivated)) then begin
  fonwindowactivated(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.dowindowdeactivated(
              const sender: tassistiveserver; const aintf: iassistiveclient;
               var handled: boolean);
begin
 if canevent(tmethod(fonwindowdeactivated)) then begin
  fonwindowdeactivated(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.dowindowclosed(const sender: tassistiveserver;
               const aintf: iassistiveclient; var handled: boolean);
begin
 if canevent(tmethod(fonwindowclosed)) then begin
  fonwindowclosed(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.doenter(const sender: tassistiveserver;
               const aintf: iassistiveclient; var handled: boolean);
begin
 if canevent(tmethod(fonenter)) then begin
  fonenter(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.doactivate(const sender: tassistiveserver;
               const aintf: iassistiveclient; var handled: boolean);
begin
 if canevent(tmethod(fonactivate)) then begin
  fonactivate(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.doclientmouseevent(
              const sender: tassistiveserver; const aintf: iassistiveclient;
               const info: mouseeventinfoty; var handled: boolean);
begin
 if canevent(tmethod(fonclientmouseevent)) then begin
  fonclientmouseevent(self,sender,aintf,info,handled);
 end;
end;

procedure tassistivewidgetitem.dokeydown(const sender: tassistiveserver;
               const aintf: iassistiveclient; const info: keyeventinfoty;
               var handled: boolean);
begin
 if canevent(tmethod(fonkeydown)) then begin
  fonkeydown(self,sender,aintf,info,handled);
 end;
end;

procedure tassistivewidgetitem.dochange(const sender: tassistiveserver;
               const aintf: iassistiveclient; var handled: boolean);
begin
 if canevent(tmethod(fonchange)) then begin
  fonchange(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.dodataentered(const sender: tassistiveserver;
               const aintf: iassistiveclientdata; var handled: boolean);
begin
 if canevent(tmethod(fondataentered)) then begin
  fondataentered(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.docellevent(const sender: tassistiveserver;
               const aintf: iassistiveclientgrid; const info: celleventinfoty;
               var handled: boolean);
begin
 if canevent(tmethod(foncellevent)) then begin
  foncellevent(self,sender,aintf,info,handled);
 end;
end;

procedure tassistivewidgetitem.doeditcharenter(const sender: tassistiveserver;
               const aintf: iassistiveclientedit; const achar: msestring;
               var handled: boolean);
begin
 if canevent(tmethod(foneditcharenter)) then begin
  foneditcharenter(self,sender,aintf,achar,handled);
 end;
end;

procedure tassistivewidgetitem.doeditchardelete(const sender: tassistiveserver;
               const aintf: iassistiveclientedit; const achar: msestring;
               var handled: boolean);
begin
 if canevent(tmethod(foneditchardelete)) then begin
  foneditchardelete(self,sender,aintf,achar,handled);
 end;
end;

procedure tassistivewidgetitem.doeditindexmoved(const sender: tassistiveserver;
               const aintf: iassistiveclientedit; const aindex: int32;
               var handled: boolean);
begin
 if canevent(tmethod(foneditindexmoved)) then begin
  foneditindexmoved(self,sender,aintf,aindex,handled);
 end;
end;

procedure tassistivewidgetitem.doeditwithdrawn(const sender: tassistiveserver;
               const aintf: iassistiveclientedit; var handled: boolean);
begin
 if canevent(tmethod(foneditwithdrawn)) then begin
  foneditwithdrawn(self,sender,aintf,handled);
 end;
end;

procedure tassistivewidgetitem.doedittextblock(const sender: tassistiveserver;
               const aintf: iassistiveclientedit;
               const amode: edittextblockmodety; const atext: msestring;
               var handled: boolean);
begin
 if canevent(tmethod(fonedittextblock)) then begin
  fonedittextblock(self,sender,aintf,amode,atext,handled);
 end;
end;

procedure tassistivewidgetitem.doeditinputmodeset(
              const sender: tassistiveserver; const aintf: iassistiveclientedit;
               const amode: editinputmodety; var handled: boolean);
begin
 if canevent(tmethod(foneditinputmodeset)) then begin
  foneditinputmodeset(self,sender,aintf,amode,handled);
 end;
end;

procedure tassistivewidgetitem.donavigbordertouched(
              const sender: tassistiveserver; const aintf: iassistiveclient;
               const adirection: graphicdirectionty; var handled: boolean);
begin
 if canevent(tmethod(fonnavigbordertouched)) then begin
  fonnavigbordertouched(self,sender,aintf,adirection,handled);
 end;
end;

{ tassistivewidgetitemlist }

function tassistivewidgetitemlist.getrecordsize(): int32;
begin
 result:= sizeof(assistivewidgethashdataty);
end;

{ tassistiveserver }

constructor tassistiveserver.create(aowner: tcomponent);
begin
 fspeaker:= tassistivespeak.create(nil);
 fitems:= tassistivewidgetitemlist.create();
 inherited;
end;

destructor tassistiveserver.destroy();
begin
 inherited;
 fspeaker.free();
 fitems.free();
end;

procedure tassistiveserver.setactive(const avalue: boolean);
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

procedure tassistiveserver.activate();
begin
 if not (csdesigning in componentstate) then begin
  fspeaker.active:= true;
  assistiveserver:= iassistiveserver(self);
  noassistivedefaultbutton:= true;
  assistivewidgetnavig:= true;
  include(fstate,ass_active);
  application.invalidate();
 end;
end;

procedure tassistiveserver.deactivate();
begin
 if not (csdesigning in componentstate) then begin
  assistiveserver:= nil;
  noassistivedefaultbutton:= false;
  assistivewidgetnavig:= false;
  fspeaker.active:= false;
  exclude(fstate,ass_active);
  application.invalidate();
 end;
end;

procedure tassistiveserver.setspeaker(const avalue: tassistivespeak);
begin
 fspeaker.assign(avalue);
end;

procedure tassistiveserver.loaded();
begin
 inherited;
 if factive then begin
  factive:= false;
  active:= true;
 end;
end;

procedure tassistiveserver.wait();
begin
 fspeaker.wait();
end;

procedure tassistiveserver.cancel();
begin
 fspeaker.cancel();
end;

procedure tassistiveserver.speaktext(const atext: msestring;
               const avoice: int32 = 0);
begin
 fspeaker.speak(atext,[so_endpause],avoice);
end;

procedure tassistiveserver.speaktext(const atext: stockcaptionty;
               const avoice: int32 = 0);
begin
 speaktext(stockobjects.captions[atext],avoice);
end;

procedure tassistiveserver.speakcharacter(const achar: char32;
               const avoice: int32 = 0);
begin
 fspeaker.speakcharacter(achar,[so_endpause],avoice);
end;

procedure tassistiveserver.speakall(const sender: iassistiveclient;
                                                        const addtext: boolean);
var
 fla1: assistiveflagsty;
 s1: msestring;
begin
 fla1:= sender.getassistiveflags();
 if not addtext then begin
  startspeak();
 end;
 s1:= '';
 if asf_button in fla1 then begin
  s1:= stockobjects.captions[sc_button] + ' ';
 end;
 s1:= s1 + sender.getassistivecaption();
 speaktext(s1,fvoicecaption);
 speaktext(sender.getassistivetext(),fvoicetext);
end;

procedure tassistiveserver.speakinput(const sender: iassistiveclientdata);
begin
 startspeak();
 speaktext(sc_input,fvoicecaption);
 speaktext(sender.getassistivecaption(),fvoicecaption);
 speaktext(sender.getassistivetext(),fvoicetext);
end;

procedure tassistiveserver.setstate(const astate: assistiveserverstatesty);
begin
 fstate:= fstate + (astate-internalstates);
end;

procedure tassistiveserver.removestate(const astate: assistiveserverstatesty);
begin
 fstate:= fstate - (astate-internalstates);
end;

procedure tassistiveserver.startspeak();
begin
 cancel();
end;

procedure tassistiveserver.registeritem(const aintf: iassistiveclient;
                     const aitem: tassistivewidgetitem);
begin
 with passistivewidgethashdataty(fitems.add(aintf))^ do begin
  data.item:= aitem;
 end;
end;

procedure tassistiveserver.unregisteritem(const aintf: iassistiveclient);
begin
 fitems.delete(aintf,true);
end;

function tassistiveserver.finditem(aintf: iassistiveclient;
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

procedure tassistiveserver.dowindowactivated(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
 setstate([ass_windowactivated]);
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dowindowactivated(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonwindowactivated)) then begin
   fonwindowactivated(self,sender,b1);
  end;
  if not b1 then begin
   startspeak();
   speaktext(sc_windowactivated,fvoicecaption);
   speaktext(sender.getassistivecaption(),fvoicecaption);
   speaktext(sender.getassistivetext(),fvoicetext);
  end;
 end;
end;

procedure tassistiveserver.dowindowdeactivated(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dowindowdeactivated(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonwindowdeactivated)) then begin
   fonwindowdeactivated(self,sender,b1);
  end;
  if not b1 then begin
   cancel();
  end;
 end;
end;

procedure tassistiveserver.dowindowclosed(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
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

procedure tassistiveserver.doenter(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doenter(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonenter)) then begin
   fonenter(self,sender,b1);
  end;
 end;
end;

procedure tassistiveserver.doactivate(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dowindowclosed(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonwindowclosed)) then begin
   fonwindowclosed(self,sender,b1);
  end;
  if twidget(sender.getinstance).focused then begin
   if not b1 then begin
    speakall(sender,ass_windowactivated in fstate);
    removestate([ass_windowactivated]);
   end;
  end;
 end;
end;

procedure tassistiveserver.doclientmouseevent(const sender: iassistiveclient;
               const info: mouseeventinfoty);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
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

procedure tassistiveserver.dofocuschanged(const oldwidget: iassistiveclient;
               const newwidget: iassistiveclient);
var
 b1: boolean;
begin
 b1:= false;
 if canevent(tmethod(fonfocuschanged)) then begin
  fonfocuschanged(self,oldwidget,newwidget,b1);
 end;
end;

procedure tassistiveserver.dokeydown(const sender: iassistiveclient;
               const info: keyeventinfoty);
//var
// fla1: assistiveflagsty;
begin
 if not (es_child in info.eventstate) then begin
  if (info.key = key_return) and 
                (info.shiftstate*keyshiftstatesmask = []) then begin
//   fla1:= sender.getassistiveflags();
   if info.serial <> fdataenteredkeyserial then begin
    speakall(sender,false);
   end;
  end;
  fdataenteredkeyserial:= 0;
 end;
end;

procedure tassistiveserver.doactionexecute(const sender: tobject;
               const info: actioninfoty);
var
 b1: boolean;
begin
 b1:= false;
 if canevent(tmethod(fonactionexecute)) then begin
  fonactionexecute(self,sender,info,b1);
 end;
end;

procedure tassistiveserver.dochange(const sender: iassistiveclient);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
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

procedure tassistiveserver.dodataentered(const sender: iassistiveclientdata);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
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

procedure tassistiveserver.docellevent(const sender: iassistiveclientgrid;
               const info: celleventinfoty);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
 b1:= false;
 if finditem(sender,item1) then begin
  item1.docellevent(self,sender,info,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(foncellevent)) then begin
   foncellevent(self,sender,info,b1);
  end;
 end;
end;

procedure tassistiveserver.doeditcharenter(const sender: iassistiveclientedit;
               const achar: msestring);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doeditcharenter(self,sender,achar,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(foneditcharenter)) then begin
   foneditcharenter(self,sender,achar,b1);
  end;
  if not b1 then begin
   startspeak();
   if length(achar) = 1 then begin
    speakcharacter(getucs4char(achar,1),fvoicetext);
   end
   else begin
    speaktext(achar,fvoicetext);
   end;
  end;
 end;
end;

procedure tassistiveserver.doeditchardelete(const sender: iassistiveclientedit;
               const achar: msestring);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
 b1:= false;
 if finditem(sender,item1) then begin
  item1.dochange(self,sender,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(fonchange)) then begin
   fonchange(self,sender,b1);
  end;
 end;
 startspeak();
 speaktext(sc_deleted,fvoicecaption);
 if length(achar) = 1 then begin
  speakcharacter(getucs4char(achar,1),fvoicetext);
 end
 else begin
  speaktext(achar,fvoicetext);
 end;
end;

procedure tassistiveserver.doeditindexmoved(const sender: iassistiveclientedit;
               const aindex: int32);
var
 b1: boolean;
 item1: tassistivewidgetitem;
 s1: msestring;
begin
 b1:= false;
 if finditem(sender,item1) then begin
  item1.doeditindexmoved(self,sender,aindex,b1);
 end;
 if not b1 then begin
  if canevent(tmethod(foneditindexmoved)) then begin
   foneditindexmoved(self,sender,aindex,b1);
  end;
  if not b1 then begin
   startspeak();
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
end;

procedure tassistiveserver.doeditwithdrawn(const sender: iassistiveclientedit);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
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

procedure tassistiveserver.doedittextblock(const sender: iassistiveclientedit;
               const amode: edittextblockmodety; const atext: msestring);
var
 b1: boolean;
 item1: tassistivewidgetitem;
 sc1: stockcaptionty;
begin
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

procedure tassistiveserver.doeditinputmodeset(
              const sender: iassistiveclientedit; const amode: editinputmodety);
var
 b1: boolean;
 item1: tassistivewidgetitem;
begin
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

procedure tassistiveserver.donavigbordertouched(const sender: iassistiveclient;
               const adirection: graphicdirectionty);
var
 b1: boolean;
 item1: tassistivewidgetitem;
 ca1: stockcaptionty;
begin
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

procedure tassistiveserver.doitementer(const sender: iassistiveclient;
               const items: shapeinfoarty; const aindex: integer);
var
 b1: boolean;
begin
 b1:= false;
 if canevent(tmethod(fonitementer)) then begin
  fonitementer(self,sender,items,aindex,b1);
 end;
end;

procedure tassistiveserver.doitementer(const sender: iassistiveclient;
               const items: menucellinfoarty; const aindex: integer);
var
 b1: boolean;
begin
 b1:= false;
 if canevent(tmethod(fonmenuitementer)) then begin
  fonmenuitementer(self,sender,items,aindex,b1);
 end;
end;

end.
