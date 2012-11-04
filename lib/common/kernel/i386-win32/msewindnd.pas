{ MSEgui Copyright (c) 2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msewindnd;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 windows,msetypes,msegui,mseguiintf,mseguiglob,msegraphutils,msestrings,
 mseclasses,activex,mseglob;

type
 ienumformatetc = interface(iunknown)['{00000103-0000-0000-c000-000000000046}']
  function next(celt: ulong; out rgelt: formatetc;
                      pceltfetched:pulong = nil): hresult; stdcall;
  function skip(celt: ulong): hresult; stdcall;
  function reset: hresult; stdcall;
  function clone(out penum: ienumformatetc): hresult; stdcall;
 end;
 
 idataobject = interface (iunknown) ['{0000010e-0000-0000-c000-000000000046}']
  function getdata(const formatetcin: formatetc;
                       out medium: stgmedium): hresult; stdcall;
  function getdatahere(const pformatetc: formatetc;
                                 var medium: stgmedium): hresult; stdcall;
  function querygetdata(const pformatetc: formatetc): hresult; stdcall;
  function getcanonicalformatetc(const pformatetcin: formatetc;
                            out pformatetcout: formatetc): hresult; stdcall;
  function setdata (const pformatetc: formatetc;
              const medium:stgmedium; frelease: bool): hresult; stdcall;
  function enumformatetc(dwdirection : dword;
               out enumformatetcpara: ienumformatetc): hresult; stdcall;
  function dadvise(const formatetc : formatetc; advf: dword;
          const advsink: iadvisesink;
                            out dwconnection: dword): hresult; stdcall;
  function dunadvise(dwconnection: dword): hresult; stdcall;
  function enumdadvise(out enumadvise: ienumstatdata): hresult; stdcall;
 end;

 idroptarget = interface(iunknown) ['{00000122-0000-0000-c000-000000000046}']
  function dragenter(const dataobj: idataobject; grfkeystate: dword;
                       pt: tpoint; var dweffect: dword): hresult; stdcall;
  function dragover(grfkeystate: dword; pt: tpoint;
                                   var dweffect: dword): hresult; stdcall;
  function dragleave: hresult;stdcall;
  function drop(const dataobj: idataobject; grfkeystate: dword; pt: tpoint;
                                       var dweffect: dword):hresult; stdcall;
 end;

function RegisterDragDrop(hwnd:HWND; pDropTarget: IDropTarget): WINOLEAPI;
               stdcall; external 'ole32.dll' name 'RegisterDragDrop';
function RevokeDragDrop(hwnd:HWND):WINOLEAPI;
               stdcall; external 'ole32.dll' name 'RevokeDragDrop';
function DoDragDrop(pDataObj: IDataObject; pDropSource: IDropSource;
       dwOKEffects: DWORD; pdwEffect: LPDWORD): WINOLEAPI;
               stdcall; external 'ole32.dll' name 'DoDragDrop';
 
procedure regsysdndwindow(const awindow: winidty);
procedure windnddeinit;
function sysdnd(const action: sysdndactionty;
               const aintf: isysdnd;  const arect: rectty;
                            out aresult: boolean): guierrorty;  
function sysdndreaddata(var adata: string;
                              const typeindex: integer): guierrorty;
function sysdndreadtext(var atext: msestring;
                              const typeindex: integer): guierrorty;
//todo: scrolling

implementation
uses
 msethread,msesysutils,sysutils,mseevent,msesysdnd;
 
type

 sdndeventkindty = (sdndk_regwindow,sdndk_unregwindow,sdndk_reject,sdndk_accept,
                    sdndk_finished,sdndk_readdataortext,
                    sdndk_writebegin,sdndk_writecheck,sdndk_writeend);
 
 tsdndevent = class(tmseevent)
  private
   fsdndkind: sdndeventkindty;
   fwinid: winidty;
   factions: dndactionsty;
   fintf: isysdnd;
   frect: rectty;
   findex: integer;
   fdatapo: pstring;
   ftextpo: pmsestring;
  public
   property sdndkind: sdndeventkindty read fsdndkind;
   constructor create(const akind: sdndeventkindty;
                      const awinid: winidty = 0;
                      const aactions: dndactionsty = [];
                      const aintf: isysdnd = nil;
                      const arect: prectty = nil;
                      const aindex: integer = -1;
                      const adatapo: pstring = nil;
                      const atextpo: pmsestring = nil);
 end;

 tdataobject = class(tlinkedobject,idataobject,idropsource)
  private
   fcheckpending: integer;
  protected
   fdata: string;
   ftext: msestring;
   findex: integer;
   fintf: isysdnd;
   factions: dndactionsty;
   ftargetactions: dndactionsty;
   fformats: msestringarty;
   fformatistext: booleanarty;
   fcformats: integerarty;
   fdrop: boolean;
   fcancel: boolean;
   ffinished: boolean;
   function checkformat(const aformat: formatetc): hresult;
   function getdatasize(out apo: pointer): integer;
   function dogetdata(var medium: stgmedium): hresult;
   procedure begindrag(const aevent: tsdndevent);

    //idataobject
   function getdata(const formatetcin: formatetc;
                                   out medium: stgmedium): hresult; stdcall;
   function getdatahere(const pformatetc: formatetc;
                                   var medium: stgmedium): hresult; stdcall;
   function querygetdata(const pformatetc: formatetc): hresult; stdcall;
   function getcanonicalformatetc(const pformatetcin : formatetc;
                              out pformatetcout: formatetc): hresult; stdcall;
   function setdata (const pformatetc: formatetc;
                 const medium: stgmedium; frelease: bool): hresult; stdcall;
   function enumformatetc(dwdirection: dword;
                out enumformatetcpara: ienumformatetc): hresult; stdcall;
   function dadvise(const formatetc: formatetc; advf: dword;
        const advsink: iadvisesink; out dwconnection: dword): hresult; stdcall;
   function dunadvise(dwconnection: dword): hresult; stdcall;
   function enumdadvise(out enumadvise: ienumstatdata): hresult; stdcall;
    //idropsource
   function querycontinuedrag(fescapepressed: bool;
               grfkeystate: longint):hresult; stdcall;
   function givefeedback(dweffect: longint): hresult; stdcall;
 end;

 writestatety = (ws_active,{ws_cancel,ws_drop,}ws_checking);
 writestatesty = set of writestatety;
 
 oleformatarty = array of tformatetc;
 tsysdndhandler = class(teventthread,idroptarget)
  protected
   fdragwinid: winidty;
   fdataobject: idataobject;
   foleformats: oleformatarty;
   fformats: msestringarty;
   fformatistext: booleanarty;
   fdata: tdataobject;
//   fdestaction: dndactionsty;
   fwritestate: writestatesty;
   function execute(thread: tmsethread): integer; override;
   function getwinid(const apos: pointty): winidty;
   procedure clearformats;
   procedure writecheck(const aactions: dndactionsty; var aresult: boolean);
   
    //iunknown
   function queryinterface({$ifdef fpc_has_constref}constref{$else}const{$endif}
                     iid: tguid; out obj): hresult; virtual; stdcall;
   function _addref: integer; stdcall;
   function _release: integer; stdcall;
    //idroptarget
   function dragenter(const dataobj: idataobject; grfkeystate: dword;
               pt: tpoint; var dweffect: dword): hresult; stdcall;
   function dragover(grfkeystate: dword; pt: tpoint;
               var dweffect: dword): hresult; stdcall;
   function dragleave: hresult; stdcall;
   function drop(const dataobj: idataobject; grfkeystate: dword; pt: tpoint;
               var dweffect: dword):hresult; stdcall;
  public
   constructor create;
   destructor destroy; override;
   procedure terminate; override;
   procedure postevent(event: tsdndevent; const aquit: boolean);
   function waitevent(const timeoutus: integer = -1): tsdndevent;
   procedure regsysdndwindow(const awindow: winidty);
 end;

 tenumformatetc = class(tinterfacedobject,ienumformatetc)
  private
   fdataobj: tdataobject;
   findex: integer;
  protected
   function next(celt: ulong; out rgelt: formatetc;
                       pceltfetched:pulong = nil): hresult; stdcall;
   function skip(celt: ulong): hresult; stdcall;
   function reset: hresult; stdcall;
   function clone(out penum: ienumformatetc): hresult; stdcall;
  public
   constructor create(const adataobj: tdataobject);
 end;
 
const
 timeout = 500000; //us  
 predefclipboardnames: array[1..16] of msestring = (
     'CF_TEXT',        //1
     'CF_BITMAP',      //2
     'CF_METAFILEPICT',//3
     'CF_SYLK',        //4
     'CF_DIF',         //5
     'CF_TIFF',        //6
     'CF_OEMTEXT',     //7
     'CF_DIB',         //8
     'CF_PALETTE',     //9
     'CF_PENDATA',     //10
     'CF_RIFF',        //11
     'CF_WAVE',        //12
     'CF_UNICODETEXT', //13
     'CF_ENHMETAFILE', //14
     'CF_HDROP',       //15
     'CF_LOCALE'       //16
     );

var
 cannotole: boolean;
 sysdndhandler: tsysdndhandler;

function winactiontoaction(const aaction: dword): dndactionsty;
begin
 result:= [];
 if aaction and dropeffect_copy <> 0 then begin
  include(result,dnda_copy);
 end;
 if aaction and dropeffect_move <> 0 then begin
  include(result,dnda_move);
 end;
 if aaction and dropeffect_link <> 0 then begin
  include(result,dnda_link);
 end;
end;

function actiontowinaction(const aaction: dndactionsty): dword;
begin
 result:= 0;
 if dnda_copy in aaction then begin
  result:= result or dropeffect_copy;
 end;
 if dnda_move in aaction then begin
  result:= result or dropeffect_move;
 end;
 if dnda_link in aaction then begin
  result:= result or dropeffect_link;
 end;
end;

function wintoshiftstate(const aflags: longword): shiftstatesty;
const
 mk_alt = $20; //who knows...
begin
 result:= [];
 if aflags and mk_control <> 0 then begin
  include(result,ss_ctrl);
 end;
 if aflags and mk_shift <> 0 then begin
  include(result,ss_shift);
 end;
 if aflags and mk_alt <> 0 then begin
  include(result,ss_alt);
 end;
 if aflags and mk_lbutton <> 0 then begin
  include(result,ss_left);
 end;
 if aflags and mk_mbutton <> 0 then begin
  include(result,ss_middle);
 end;
 if aflags and mk_rbutton <> 0 then begin
  include(result,ss_right);
 end;
end;

function sysdnd(const action: sysdndactionty;
               const aintf: isysdnd;  const arect: rectty;
                            out aresult: boolean): guierrorty;
var
 act1: dndactionsty;
begin
 aresult:= false;
 if (sysdndhandler = nil) then begin
  result:= gue_nodragpending;
 end
 else begin
  result:= gue_ok;
  if aintf <> nil then begin
   act1:= aintf.getactions;
  end;
  with sysdndhandler do begin
   case action of
    sdnda_reject: begin
     postevent(tsdndevent.create(sdndk_reject),false);
    end;
    sdnda_accept: begin
     postevent(tsdndevent.create(sdndk_accept,0,act1),false);     
    end;
    sdnda_finished: begin
     postevent(tsdndevent.create(sdndk_finished),true);     
    end;
    sdnda_begin: begin
     postevent(tsdndevent.create(sdndk_writebegin,0,act1,aintf),true);
     semwait;
    end;
    sdnda_check: begin
     writecheck(act1,aresult);
    end;
    sdnda_drop,sdnda_destroyed: begin
     if action = sdnda_drop then begin
      fdata.fdrop:= true; //dndthread in blocking dodragdrop
     end
     else begin
      fdata.fcancel:= true; //dndthread in blocking dodragdrop
     end;
     postevent(tsdndevent.create(sdndk_writeend,0,act1,aintf),
                                            action = sdnda_destroyed);
    end;
    else begin
     result:= gue_notimplemented;
    end;
   end;
  end;
 end;
end;

function sysdndreaddata(var adata: string;
                              const typeindex: integer): guierrorty;
begin
 if (sysdndhandler = nil) then begin
  result:= gue_nodragpending;
 end
 else begin
  result:= gue_ok;
  with sysdndhandler do begin
   postevent(tsdndevent.create(sdndk_readdataortext,0,[],nil,nil,
                                             typeindex,@adata,nil),false);
   semwait;
  end;
 end;
end;

function sysdndreadtext(var atext: msestring;
                              const typeindex: integer): guierrorty;
begin
 if (sysdndhandler = nil) then begin
  result:= gue_nodragpending;
 end
 else begin
  result:= gue_ok;
  with sysdndhandler do begin
   postevent(tsdndevent.create(sdndk_readdataortext,0,[],nil,nil,
                                             typeindex,nil,@atext),false);
   semwait;
  end;
 end;
end;
 
procedure regsysdndwindow(const awindow: winidty);
begin
 if (sysdndhandler = nil) and not cannotole then begin
  sysdndhandler:= tsysdndhandler.create;
  sysdndhandler.semwait;
  if cannotole then begin
   freeandnil(sysdndhandler);
   exit;
  end;
 end;
 sysdndhandler.regsysdndwindow(awindow);
end;

procedure windnddeinit;
begin
 freeandnil(sysdndhandler);
end;


{ tenumformatetc }

constructor tenumformatetc.create(const adataobj: tdataobject);
begin
 fdataobj:= adataobj;
end;

function tenumformatetc.next(celt: ulong; out rgelt: formatetc;
               pceltfetched: pulong = nil): hresult; stdcall;
var
 int1: integer;
 po1: pformatetc;
begin
 int1:= celt;
 if int1 + findex > high(fdataobj.fcformats) then begin
  int1:= length(fdataobj.fcformats) - findex;
 end;
 if int1 < 0 then begin
  int1:= 0;
 end;
 po1:= @rgelt;
 if int1 < celt then begin
  result:= s_false;
 end
 else begin
  result:= s_ok;
 end;
 for int1:= 0 to int1-1 do begin
  fillchar(po1^,sizeof(po1^),0);
  with po1^ do begin
   cfformat:= fdataobj.fcformats[findex];
   tymed:= tymed_hglobal;
  end;
  inc(findex);
  inc(po1);
 end;
end;

function tenumformatetc.skip(celt: ulong): hresult;  stdcall;
begin
 result:= s_ok;
 findex:= findex + celt;
 if findex > high(fdataobj.fcformats) then begin
  findex:= length(fdataobj.fcformats);
  result:= s_false;
 end;
end;

function tenumformatetc.reset: hresult;  stdcall;
begin
 findex:= 0;
 result:= s_ok;
end;

function tenumformatetc.clone(out penum: ienumformatetc): hresult;  stdcall;
var
 inst: tenumformatetc;
begin
 inst:= tenumformatetc.create(fdataobj);
 inst.findex:= findex;
 penum:= ienumformatetc(inst);
 result:= s_ok;
end;

{ tsdndevent }

constructor tsdndevent.create(const akind: sdndeventkindty;
                      const awinid: winidty = 0;
                      const aactions: dndactionsty = [];
                      const aintf: isysdnd = nil;
                      const arect: prectty = nil;
                      const aindex: integer = -1;
                      const adatapo: pstring = nil;
                      const atextpo: pmsestring = nil);

begin
 fsdndkind:= akind;
 fwinid:= awinid;
 factions:= aactions;
 fintf:= aintf;
 if arect = nil then begin
  frect:= nullrect;
 end
 else begin
  frect:= arect^;
 end;
 findex:= aindex;
 fdatapo:= adatapo;
 ftextpo:= atextpo;
 inherited create(ek_mse);
end;

{ tdataobject }

function tdataobject.checkformat(const aformat: formatetc): hresult;
var
 int1: integer;
begin
 result:= dv_e_formatetc;
 findex:= -1;
 for int1:= 0 to high(fcformats) do begin
  if fcformats[int1] = aformat.cfformat then begin
   findex:= int1;
   result:= s_ok;
   break;
  end;
 end;
end;

function tdataobject.getdatasize(out apo: pointer): integer;
begin
 application.lock;
 if fformatistext[findex] then begin
  if ftext = '' then begin
   if fintf <> nil then begin
    ftext:= fintf.convertmimetext(findex);
   end;
  end;
  result:= length(ftext) * sizeof(msechar);
  apo:= pointer(ftext);
 end
 else begin
  if fdata = '' then begin
   if fintf <> nil then begin
    fdata:= fintf.convertmimedata(findex);
   end;
  end;
  result:= length(fdata);
  apo:= pointer(fdata);
 end;
 application.unlock;
end;

function tdataobject.dogetdata(var medium: stgmedium): hresult;
var
 po1,po2: pointer;
 int1: integer;
begin
 if medium.tymed <> tymed_hglobal then begin
  result:= dv_e_tymed;
 end
 else begin
  po1:= globallock(medium.hglobal);
  if po1 = nil then begin
   result:= e_unexpected;
  end
  else begin
   int1:= getdatasize(po2);
   if globalsize(medium.hglobal) < int1 then begin
    result:= stg_e_mediumfull;
   end
   else begin
    move(po2^,po1^,int1);
    medium.punkforrelease:= nil;
    result:= s_ok;
   end;
   globalunlock(medium.hglobal);
  end;
 end;
end;

function tdataobject.getdata(const formatetcin: formatetc;
               out medium: stgmedium): hresult;  stdcall;
var
 po1: pointer;
begin
 result:= checkformat(formatetcin);
 if result = s_ok then begin
  medium.tymed:= tymed_hglobal;
  medium.hglobal:= globalalloc(gmem_moveable,getdatasize(po1));
  if medium.hglobal = 0 then begin
   result:= e_outofmemory;
  end
  else begin
   result:= dogetdata(medium);
  end;
 end; 
end;

function tdataobject.getdatahere(const pformatetc: formatetc;
               var medium: stgmedium): hresult;  stdcall;
begin
 result:= checkformat(pformatetc);
 if result = s_ok then begin
  result:= dogetdata(medium);
 end;
end;

function tdataobject.querygetdata(
                     const pformatetc: formatetc): hresult; stdcall;
begin
 result:= checkformat(pformatetc);
end;

function tdataobject.getcanonicalformatetc(const pformatetcin: formatetc;
               out pformatetcout: formatetc): hresult; stdcall;
begin
 pformatetcout:= pformatetcin;
 pformatetcout.ptd:= nil;
 result:= data_s_sameformatetc;
end;

function tdataobject.setdata(const pformatetc: formatetc;
               const medium: stgmedium; frelease: bool): hresult; stdcall;
begin
 result:= e_notimpl;
end;

function tdataobject.enumformatetc(dwdirection: dword;
               out enumformatetcpara: ienumformatetc): hresult;  stdcall;
begin
 if dwdirection = datadir_set then begin
  result:= e_notimpl;
 end
 else begin
  result:= s_ok;
  enumformatetcpara:= tenumformatetc.create(self);
 end;
end;

function tdataobject.dadvise(const formatetc: formatetc; advf: dword;
                const advsink: iadvisesink;
                out dwconnection: dword): hresult; stdcall;
begin
 result:= e_notimpl;
end;

function tdataobject.dunadvise(dwconnection: dword): hresult; stdcall;
begin
 result:= ole_e_advisenotsupported;
end;

function tdataobject.enumdadvise(
           out enumadvise: ienumstatdata): hresult; stdcall;
begin
 enumadvise:= nil;
 result:= ole_e_advisenotsupported;
end;

function getclipformatid(const aname: msestring): integer;
var
 int1: integer;
begin
 result:= 0;
 for int1:= low(predefclipboardnames) to high(predefclipboardnames) do begin
  if predefclipboardnames[int1] = aname then begin
   result:= int1;
   break;
  end;
 end;
 if result = 0 then begin
  result:= registerclipboardformatw(pwidechar(pmsechar(aname)));
 end;
end;

procedure tdataobject.begindrag(const aevent: tsdndevent);
var
 int1: integer;
begin
 getobjectlinker.setlinkedvar(iobjectlink(self),aevent.fintf,
                                                 iobjectlink(fintf));
 ftext:= '';
 fdata:= '';
 fcheckpending:= 0;
 fdrop:= false;
 fcancel:= false;
 ffinished:= false;
 factions:= fintf.getactions;
 fformats:= fintf.getformats;
 fformatistext:= fintf.getformatistext;
 setlength(fformatistext,length(fformats));
 fcformats:= nil;
 setlength(fcformats,length(fformats));
 for int1:= 0 to high(fformats) do begin
  fcformats[int1]:= getclipformatid(fformats[int1]);
 end;
end;

function tdataobject.querycontinuedrag(fescapepressed: bool;
               grfkeystate: longint): hresult; stdcall;
begin
 application.lock;
 result:= s_ok;
 if (fintf = nil) or fcancel then begin
  result:= dragdrop_s_cancel;
  ffinished:= true;
 end
 else begin
  if fdrop then begin
   result:= dragdrop_s_drop;
   ffinished:= true;
  end;
 end;
 application.unlock;
end;
var testvar: dndactionsty; testvar1: dword;
function tdataobject.givefeedback(dweffect: longint): hresult; stdcall;
begin
 if interlockeddecrement(fcheckpending) >= 0 then begin
  application.lock;
  if fintf <> nil then begin
   ftargetactions:= winactiontoaction(dweffect);
   application.postevent(tsysdndstatusevent.create(
         fintf.geteventintf,ftargetactions <> []));
  end;
  application.unlock;
 end
 else begin
  interlockedincrement(fcheckpending);
 end;
 testvar:= ftargetactions;
 testvar1:= dweffect;
 result:= s_ok;
end;

{ tsysdndhandler }

constructor tsysdndhandler.create;
begin
 fdata:= tdataobject.create;
 inherited;
end;

destructor tsysdndhandler.destroy;
begin
 fdata.free;
 inherited;
end;

procedure tsysdndhandler.clearformats;
var
 int1: integer;
begin
 for int1:= 0 to high(foleformats) do begin
  if foleformats[int1].ptd <> nil then begin
   cotaskmemfree(foleformats[int1].ptd);
  end;
 end;
 foleformats:= nil;
 fformats:= nil;
end;

procedure tsysdndhandler.postevent(event: tsdndevent; const aquit: boolean);
begin
 inherited postevent(event);
 if aquit then begin
  postthreadmessage(id,wm_quit,0,0); //wakeup thread, cancel dodragdrop
 end
 else begin
  postthreadmessage(id,wm_user,0,0); //wakeup thread
 end;
end;

procedure tsysdndhandler.terminate;
begin
 inherited;
 postthreadmessage(id,wm_quit,0,0); //wakeup thread
// postthreadmessage(id,wm_user,0,0); //wakeup thread
end;

function tsysdndhandler.execute(thread: tmsethread): integer;
var
 hres1: hresult;
 ev1: tsdndevent;
 int1: integer;
 msg: tmessage;
 medium: tstgmedium;
 po1: pointer;
 lwo1: longword;
begin
 hres1:= oleinitialize(nil);
 cannotole:= not((hres1 = s_ok) or (hres1 = s_false));
 sempost;
 if not cannotole then begin
  repeat
   try
    int1:= integer(getmessage(@msg,0,0,0));
    if int1 <> -1 then begin
     translatemessage(@msg);
     dispatchmessage(@msg);
    end;
    repeat
     ev1:= tsdndevent(waitevent(0));
     if ev1 <> nil then begin
      case ev1.sdndkind of
       sdndk_regwindow: begin
        registerdragdrop(ev1.fwinid,idroptarget(self));
       end;
       sdndk_unregwindow: begin
        revokedragdrop(ev1.fwinid);
       end;
       sdndk_finished: begin
        fdataobject:= nil;
        clearformats;
       end;
       sdndk_readdataortext: begin
        if (ev1.findex >= 0) and (ev1.findex <= high(foleformats)) and 
                                          (fdataobject <> nil) then begin
         fillchar(medium,sizeof(medium),0);
         with medium do begin
          tymed:= tymed_hglobal;
          if fdataobject.getdata(foleformats[ev1.findex],
                                          medium) = s_ok then begin
           int1:= globalsize(hglobal);
           po1:= globallock(hglobal);
           if ev1.ftextpo <> nil then begin
            setlength(ev1.ftextpo^,(int1+1) div 2);
            move(po1^,ev1.ftextpo^[1],int1);
           end
           else begin
            setlength(ev1.fdatapo^,int1);
            move(po1^,ev1.fdatapo^[1],int1);
           end;
           globalunlock(hglobal);
           releasestgmedium(medium);
          end;
         end;
        end;
        sempost;
       end;
       sdndk_writebegin: begin
        clearformats;
//        fcheckpending:= 0;
        fwritestate:= [ws_active];
        fdata.begindrag(ev1);
        sempost;
//        dodragdrop(idataobject(fdata),idropsource(self),
//                          actiontowinaction(ev1.factions),@lwo1);
       end;
       sdndk_writecheck: begin
        if ws_active in fwritestate then begin
         if fdata.fintf = nil then begin
          sempost;
         end
         else begin
          include(fwritestate,ws_checking);
          sempost;
          beginsdndwrite(id);
          hres1:= dodragdrop(idataobject(fdata),idropsource(fdata),
                            actiontowinaction(fdata.factions),@lwo1); //blocking
          exclude(fwritestate,ws_checking);
          endsdndwrite;
//          application.lock;
//          try
//           if (fdata.fintf <> nil) and fdata.ffinished then begin
//            fdata.fintf.cancelsysdnd;
//           end;
//          finally
//           application.unlock;
//          end;         
         end;
        end;
       end;
      end;     
      ev1.free;
     end;
    until (ev1 = nil) or terminated;
   except
    application.handleexception;
   end;
  until terminated;
  clearformats;
  oleuninitialize;
 end;
 result:= 0;
end;

procedure tsysdndhandler.regsysdndwindow(const awindow: winidty);
begin
 postevent(tsdndevent.create(sdndk_regwindow,awindow),false);
end;

function tsysdndhandler._addref: integer; stdcall;
begin
 result:= -1;
end;

function tsysdndhandler._release: integer; stdcall;
begin
 result:= -1;
end;

function tsysdndhandler.queryinterface(
        {$ifdef fpc_has_constref}constref{$else}const{$endif} iid: tguid;
                          out obj): hresult; stdcall;
begin
 if getinterface(iid, obj) then begin
   result:=0
 end
 else begin
  result:= integer(e_nointerface);
 end;
end;

function tsysdndhandler.dragenter(const dataobj: idataobject;
     grfkeystate: dword; pt: tpoint; var dweffect: dword): hresult; stdcall;
const
 chunkcount = 16;
var
 ev1: tsdndevent;
 effect1: dword;
 enumformat: ienumformatetc;
 count1: integer;
 lwo1: longword;
 int1,int2: integer;
 buffer: array[0..max_path] of msechar;
begin
 fdragwinid:= getwinid(pointty(pt));
 effect1:= dropeffect_none;
 clearevents;
 if fdragwinid <> 0 then begin
  fdataobject:= dataobj;
  clearformats;
  if fdataobject.enumformatetc(datadir_get,enumformat) = s_ok then begin
   setlength(foleformats,chunkcount);
   count1:= 0;
   lwo1:= 0;
   while enumformat.next(chunkcount,foleformats[count1],@lwo1) = s_ok do begin
    setlength(foleformats,length(foleformats)+chunkcount);
    count1:= count1 + lwo1;
   end;
   count1:= count1 + lwo1;
   setlength(foleformats,count1);
   setlength(fformats,length(foleformats));
   for int1:= 0 to high(fformats) do begin
    with foleformats[int1] do begin
     int2:= getclipboardformatnamew(cfformat,@buffer,max_path);
     if int2 > 0 then begin
      fformats[int1]:= buffer;
     end
     else begin
      if (cfformat >= low(predefclipboardnames)) and 
                    (cfformat <= high(predefclipboardnames)) then begin
       fformats[int1]:= predefclipboardnames[cfformat];
      end;
     end;
    end;
   end;
   application.postevent(tsysdndevent.create(dek_check,fdragwinid,pointty(pt),
      wintoshiftstate(grfkeystate),false,fformats,fformatistext,
      winactiontoaction(dweffect)));
   ev1:= waitevent(timeout);
   if (ev1 <> nil) and (ev1.sdndkind = sdndk_accept) then begin
    effect1:= actiontowinaction(ev1.factions)
   end;
   ev1.free;
  end;
 end;
 dweffect:= effect1;
 result:= s_ok;
end;

function tsysdndhandler.dragover(grfkeystate: dword; pt: tpoint;
               var dweffect: dword): hresult; stdcall;
var
 ev1: tsdndevent;
 effect1: dword;
begin
 effect1:= dropeffect_none;
 if fdragwinid <> 0 then begin
  application.postevent(tsysdndevent.create(dek_check,fdragwinid,pointty(pt),
     wintoshiftstate(grfkeystate),false,fformats,fformatistext,
     winactiontoaction(dweffect)));
  ev1:= waitevent(timeout);
  if (ev1 <> nil) and (ev1.sdndkind = sdndk_accept) then begin
   effect1:= actiontowinaction(ev1.factions)
  end;
  ev1.free;
 end;
 dweffect:= effect1;
 result:= s_ok;
end;

function tsysdndhandler.dragleave: hresult; stdcall;
begin
 if fdragwinid <> 0 then begin
  application.postevent(tsysdndevent.create(dek_leave,fdragwinid,nullpoint,
                                                      [],false,nil,nil,[]));
  fdataobject:= nil;
  fdragwinid:= 0;
  clearformats;
 end;
 result:= s_ok;
end;

function tsysdndhandler.drop(const dataobj: idataobject; grfkeystate: dword;
               pt: tpoint; var dweffect: dword): hresult; stdcall;
begin
 if fdragwinid <> 0 then begin
  application.postevent(tsysdndevent.create(dek_drop,fdragwinid,pointty(pt),
     wintoshiftstate(grfkeystate),false,fformats,fformatistext,
                                            winactiontoaction(dweffect)));
 end;
 result:= s_ok;
end;

function tsysdndhandler.getwinid(const apos: pointty): winidty;
var
 window1: twindow;
begin
 result:= 0;
 application.lock;
 window1:= application.windowatpos(apos);
 if (window1 <> nil) and window1.haswinid then begin //do not create winid
  result:= window1.winid;
 end;
 application.unlock;
end;

function tsysdndhandler.waitevent(const timeoutus: integer = -1): tsdndevent;
begin
 result:= tsdndevent(inherited waitevent(timeoutus));
end;

procedure tsysdndhandler.writecheck(const aactions: dndactionsty;
                                                  var aresult: boolean);
begin
 if not (ws_checking in fwritestate) then begin
  postevent(tsdndevent.create(sdndk_writecheck,0,aactions),false);
  semwait;
 end;
 aresult:= fdata.ftargetactions * aactions <> [];
 interlockedincrement(fdata.fcheckpending);
end;

end.
