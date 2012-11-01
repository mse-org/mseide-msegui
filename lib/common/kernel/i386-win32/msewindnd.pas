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
 windows,msetypes,msegui,mseguiintf,mseguiglob,msegraphutils,msestrings;
 
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
 msethread,activex,msesysutils,sysutils,mseevent,msesysdnd;
 
type
 sdndeventkindty = (sdndk_regwindow,sdndk_unregwindow,sdndk_reject,sdndk_accept,
                    sdndk_finished,sdndk_readdataortext);
 
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

 oleformatarty = array of tformatetc;
 tsysdndhandler = class(teventthread,idroptarget)
  protected
   fdragwinid: winidty;
   fdataobject: idataobject;
   foleformats: oleformatarty;
   fformats: msestringarty;
   function execute(thread: tmsethread): integer; override;
   function getwinid(const apos: pointty): winidty;
   procedure clearformats;
   
    //iunknown
   function queryinterface({$ifdef fpc_has_constref}constref{$else}const{$endif}
                     iid: tguid; out obj): hresult; virtual; stdcall;
   function _addref: integer; stdcall;
   function _release: integer; stdcall;
    //idroptarget
   function dragenter(const dataobj: idataobject; grfkeystate: dword;
               pt: tpoint; var dweffect: dword): hresult;stdcall;
   function dragover(grfkeystate: dword; pt: tpoint;
               var dweffect: dword): hresult;stdcall;
   function dragleave: hresult;stdcall;
   function drop(const dataobj: idataobject; grfkeystate: dword; pt: tpoint;
               var dweffect: dword):hresult;stdcall;
  public
   procedure terminate; override;
   procedure postevent(event: tsdndevent);
   function waitevent(const timeoutus: integer = -1): tsdndevent;
   procedure regsysdndwindow(const awindow: winidty);
 end;

const
 timeout = 500000; //us  
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
     postevent(tsdndevent.create(sdndk_reject));
    end;
    sdnda_accept: begin
     postevent(tsdndevent.create(sdndk_accept,0,act1));     
    end;
    sdnda_finished: begin
     postevent(tsdndevent.create(sdndk_finished));     
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
                                             typeindex,@adata,nil));
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
                                                           typeindex,nil,@atext));
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

{ tsysdndhandler }

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

procedure tsysdndhandler.postevent(event: tsdndevent);
begin
 inherited postevent(event);
 postthreadmessage(id,wm_user,0,0); //wakeup thread
end;

procedure tsysdndhandler.terminate;
begin
 inherited;
 postthreadmessage(id,wm_user,0,0); //wakeup thread
end;

function tsysdndhandler.execute(thread: tmsethread): integer;
var
 hres1: hresult;
 ev1: tsdndevent;
 int1: integer;
 msg: tmessage;
 medium: tstgmedium;
 po1: pointer;
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
//            if ev1.ftextpo^ <> '' then begin
//             ev1.ftextpo^[length(ev1.ftextpo^)]:= #0; //pad for wrong lenght
//            end;
            move(po1^,ev1.ftextpo^[1],int1);
//            int1:= length(ev1.ftextpo^);
//            if ev1.ftextpo^[int1] = #0 then begin
//             setlength(ev1.ftextpo^,int1-1); //remove terminating #0
//            end;
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
 postevent(tsdndevent.create(sdndk_regwindow,awindow));
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

const
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
      wintoshiftstate(grfkeystate),false,fformats,winactiontoaction(dweffect)));
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
     wintoshiftstate(grfkeystate),false,fformats,winactiontoaction(dweffect)));
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
                                                      [],false,nil,[]));
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
     wintoshiftstate(grfkeystate),false,fformats,winactiontoaction(dweffect)));
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

end.
