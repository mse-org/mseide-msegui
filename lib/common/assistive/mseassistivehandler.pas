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

 tassistivewidgetitem = class(tmsecomponent)
  private
   fserver: tassistiveserver;
   fwidget: twidget;
   fonwindowactivated: assistiveeventty;
   procedure setserver(const avalue: tassistiveserver);
   procedure setwidget(const avalue: twidget);
  protected
   procedure link();
   procedure unlink();
   procedure objectevent(const sender: tobject;
                                 const event: objecteventty) override;
   procedure dowindowactivated(const sender: tassistiveserver;
                         const aintf: iassistiveclient; var handled: boolean);
  public
   destructor destroy(); override;
  published
   property server: tassistiveserver read fserver write setserver;
   property widget: twidget read fwidget write setwidget;
   property onwindowactivated: assistiveeventty read fonwindowactivated 
                                                    write fonwindowactivated;
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
 
 tassistiveserver = class(tmsecomponent,iassistiveserver)
  private
   factive: boolean;
   fspeaker: tassistivespeak;
   fvoicecaption: int32;
   fvoicetext: int32;
   fonwindowactivated: assistiveservereventty;
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
 unlink();
 setlinkedvar(avalue,tmsecomponent(fserver));
 link();
end;

procedure tassistivewidgetitem.setwidget(const avalue: twidget);
begin
 unlink();
 setlinkedvar(avalue,tmsecomponent(fwidget));
 link();
end;

procedure tassistivewidgetitem.link();
begin
 if (fwidget <> nil) and (fserver <> nil) and 
            not (csdesigning in componentstate) then begin
  fserver.registeritem(twidget1(fwidget).getiassistiveclient,self);
 end;
end;

procedure tassistivewidgetitem.unlink();
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
  unlink();
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
 aitem:= nil;
 p1:= pointer(fitems.find(aintf));
 if p1 <> nil then begin
  aitem:= p1^ .data.item;
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
begin
end;

procedure tassistiveserver.dowindowclosed(const sender: iassistiveclient);
begin
end;

procedure tassistiveserver.doenter(const sender: iassistiveclient);
begin
end;

procedure tassistiveserver.doactivate(const sender: iassistiveclient);
var
 w1: twidget;
begin
 pointer(w1):= sender.getinstance();
 if w1 = w1.window.focusedwidget then begin
  speakall(sender,ass_windowactivated in fstate);
  removestate([ass_windowactivated]);
 end;
end;

procedure tassistiveserver.doitementer(const sender: iassistiveclient;
               const items: shapeinfoarty; const aindex: integer);
begin
end;

procedure tassistiveserver.doitementer(const sender: iassistiveclient;
               const items: menucellinfoarty; const aindex: integer);
begin
end;

procedure tassistiveserver.doclientmouseevent(const sender: iassistiveclient;
               const info: mouseeventinfoty);
begin
end;

procedure tassistiveserver.dofocuschanged(const oldwidget: iassistiveclient;
               const newwidget: iassistiveclient);
begin
end;

procedure tassistiveserver.dokeydown(const sender: iassistiveclient;
               const info: keyeventinfoty);
var
 fla1: assistiveflagsty;
begin
 if not (es_child in info.eventstate) then begin
  if (info.key = key_return) and 
                (info.shiftstate*keyshiftstatesmask = []) then begin
   fla1:= sender.getassistiveflags();
   if info.serial <> fdataenteredkeyserial then begin
    speakall(sender,false);
   end;
  end;
  fdataenteredkeyserial:= 0;
 end;
end;

procedure tassistiveserver.doactionexecute(const sender: tobject;
               const info: actioninfoty);
begin
end;

procedure tassistiveserver.dochange(const sender: iassistiveclient);
begin
end;

procedure tassistiveserver.dodataentered(const sender: iassistiveclientdata);
begin
 fdataenteredkeyserial:= 0;
 if application.keyeventinfo <> nil then begin
  fdataenteredkeyserial:= application.keyeventinfo^.serial;
 end;
 speakinput(sender);
end;

procedure tassistiveserver.docellevent(const sender: iassistiveclientgrid;
               const info: celleventinfoty);
begin
end;

procedure tassistiveserver.doeditcharenter(const sender: iassistiveclientedit;
               const achar: msestring);
begin
 startspeak();
 if length(achar) = 1 then begin
  speakcharacter(getucs4char(achar,1),fvoicetext);
 end
 else begin
  speaktext(achar,fvoicetext);
 end;
end;

procedure tassistiveserver.doeditchardelete(const sender: iassistiveclientedit;
               const achar: msestring);
begin
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
 s1: msestring;
begin
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

procedure tassistiveserver.doeditwithdrawn(const sender: iassistiveclientedit);
begin
 startspeak();
 speaktext(sc_withdrawn,fvoicecaption);
 speaktext(sender.getassistivetext(),fvoicetext);
end;

procedure tassistiveserver.doedittextblock(const sender: iassistiveclientedit;
               const amode: edittextblockmodety; const atext: msestring);
var
 sc1: stockcaptionty;
begin
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

procedure tassistiveserver.doeditinputmodeset(
              const sender: iassistiveclientedit; const amode: editinputmodety);
begin
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

procedure tassistiveserver.donavigbordertouched(const sender: iassistiveclient;
               const adirection: graphicdirectionty);
var
 ca1: stockcaptionty;
begin
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

end.
