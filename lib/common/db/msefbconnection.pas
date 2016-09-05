{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefbconnection;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}
interface
uses
 classes,mclasses,firebird,msqldb,msestrings,msetypes,mdb,msedb,msedatabase,
 sysutils,msefirebird;
 
const
 SQL_DIALECT_V6 = 3;

type

 tfirebirdconnection = class;
 
 tfbtrans = class(tsqlhandle)
  protected
   fowner: tfirebirdconnection;
   ftrans: itransaction;
  public
   constructor create(const aowner: tfirebirdconnection);
   destructor destroy(); override;
 end;

 tfbcursor = class(tsqlcursor)
  protected
   fconnection: tfirebirdconnection;
   fparambinding: tparambinding;
   fstatement: istatement;
  public
   constructor create(const aowner: icursorclient;
                                       const aconnection: tfirebirdconnection);
   destructor destroy(); override;
 end;
  
 fbapity = record
  master: imaster;
  status: istatus;
  provider: iprovider;
  util: iutil;
 end;
 
 tfirebirdconnection = class(tcustomsqlconnection)
  private
   fdialect: integer;
  protected
   fapi: fbapity;
   fattachment: iattachment;
   procedure iniapi();
   procedure finiapi();
   function getpb(): ixpbbuilder;
   procedure checkstatus(const aerrormessage: msestring);
   procedure dointernalconnect; override;
   procedure dointernaldisconnect; override;

   function allocatetransactionhandle : tsqlhandle; override;
   function gettransactionhandle(trans : tsqlhandle): pointer; override;
   function startdbtransaction(const trans : tsqlhandle;
                      const aparams : tstringlist) : boolean; override;
   function allocatecursorhandle(const aowner: icursorclient;
                      const aname: ansistring): tsqlcursor; override;
   procedure preparestatement(const cursor: tsqlcursor; 
                 const atransaction : tsqltransaction;
                 const asql: msestring; const aparams : tmseparams); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property dialect: integer read fdialect write fdialect 
                                        default sql_dialect_v6;
//   property options: ibconnectionoptionsty read foptions 
//                                           write foptions default [];
   property DatabaseName;
//   property KeepConnection;
//   property Params;
 end;
 
 efberror = class(econnectionerror)
  public
   constructor create(const asender: tfirebirdconnection;
                 const astatus: istatus; const aerrormessage: msestring);
 end;

implementation
 
{ efberror }

constructor efberror.create(const asender: tfirebirdconnection;
               const astatus: istatus; const aerrormessage: msestring);
var
 str1: string;
 msg1: msestring;
begin
 str1:= formatstatus(astatus); 
 msg1:= aerrormessage;
 if str1 <> '' then begin
  msg1:= msg1 + lineend + msestring(str1);
 end;
 inherited create(asender,ansistring(msg1),msg1,0);
end;

{ tfirebirdconnection }

constructor tfirebirdconnection.create(aowner: tcomponent);
begin
 fdialect:= sql_dialect_v6;
 inherited;
end;

procedure tfirebirdconnection.iniapi();
begin
 initializefirebird([],true);
 with fapi do begin
  if master = nil then begin
   master:= fb_get_master_interface();
  end;
  if status = nil then begin
   status:= master.getstatus();
  end;
  if provider = nil then begin
   provider:= master.getdispatcher();
  end;
  if util = nil then begin
   util:= master.getutilinterface();
  end;
 end;
end;

procedure tfirebirdconnection.finiapi();
begin
 with fapi do begin
  util:= nil;
  provider:= nil;
  if status <> nil then begin
   status.dispose();
   status:= nil;
  end;
  master:= nil;
 end;
end;

procedure tfirebirdconnection.checkstatus(const aerrormessage: msestring);
begin
 if fapi.status.getstate() and istatus.state_errors <> 0 then begin
  raise efberror.create(self,fapi.status,aerrormessage);
 end;
end;

function tfirebirdconnection.getpb(): ixpbbuilder;
begin
 result:= fapi.util.getxpbbuilder(fapi.status,ixpbbuilder.DPB,nil,0);
end;

procedure tfirebirdconnection.dointernalconnect();
const
 utf8name = 'UTF8';
var
 pb: ixpbbuilder;
 databasename1 : string;
begin
 iniapi();
 try 
  inherited dointernalconnect;
  pb:= getpb();
  if username <> '' then begin
   pb.insertstring(fapi.status,isc_dpb_user_name,pointer(username));
  end;
  if password <> '' then begin
   pb.insertstring(fapi.status,isc_dpb_password,pointer(password));
  end;
//  if role <> '' then begin
//   dpb.insertstring(fapi.status,isc_dpb_role_name,pointer(role));
//  end;
  if charset <> '' then begin
   pb.insertstring(fapi.status,isc_dpb_lc_ctype,pointer(charset));
  end
  else begin
   if dbo_utf8 in fcontroller.options then begin
    pb.insertstring(fapi.status,isc_dpb_lc_ctype,utf8name);
   end;
  end;
  if hostname <> '' then begin
   databasename1:= hostname+':'+databasename;
  end
  else begin
   databasename1:= databasename;
  end;
  fattachment:= nil;
  fattachment:= fapi.provider.attachdatabase(fapi.status,
                      pchar(databasename1),pb.getbufferlength(fapi.status),
                                              pb.getbuffer(fapi.status));
  pb.dispose();
  checkstatus('dointernalconnect');
  fattachment.addref();
 except
  finiapi();
//  releasefirebird;
  raise;
 end;
// feventcontroller.connect;
end;

procedure tfirebirdconnection.dointernaldisconnect;
begin
 inherited;
 if fattachment <> nil then begin
  fattachment.detach(fapi.status);
  fattachment.release();
  fattachment:= nil;
 end;
end;

function tfirebirdconnection.allocatetransactionhandle: tsqlhandle;
begin
 result:= tfbtrans.create(self);
end;

function tfirebirdconnection.gettransactionhandle(trans: tsqlhandle): pointer;
begin
 result:= tfbtrans(trans).ftrans;
end;

function tfirebirdconnection.startdbtransaction(const trans: tsqlhandle;
               const aparams: tstringlist): boolean;
               
 procedure paramerror(const s: string);
 begin
  raise econnectionerror.create(self,
                           'Invalid transaction parameter "'+s+'"','',0);
 end; //paramerror
type
 paraminfoty = record
  id: int32;
  name: string;
 end;
 
const
 paramconsts: array[0..19] of paraminfoty =
  ((id: isc_tpb_write; name: 'isc_tpb_write'),
   (id: isc_tpb_read; name: 'isc_tpb_read'),
   (id: isc_tpb_consistency; name: 'isc_tpb_consistency'),
   (id: isc_tpb_concurrency; name: 'isc_tpb_concurrency'),
   (id: isc_tpb_read_committed; name: 'isc_tpb_read_committed'),
   (id: isc_tpb_rec_version; name: 'isc_tpb_rec_version'),
   (id: isc_tpb_no_rec_version; name: 'isc_tpb_no_rec_version'),
   (id: isc_tpb_wait; name: 'isc_tpb_wait'),
   (id: isc_tpb_nowait; name: 'isc_tpb_nowait'),
   (id: isc_tpb_shared; name: 'isc_tpb_shared'),
   (id: isc_tpb_protected; name: 'isc_tpb_protected'),
   (id: isc_tpb_exclusive; name: 'isc_tpb_exclusive'),
   (id: isc_tpb_lock_read; name: 'isc_tpb_lock_read'),
   (id: isc_tpb_lock_write; name: 'isc_tpb_lock_write'),
   (id: isc_tpb_verb_time; name: 'isc_tpb_verb_time'),
   (id: isc_tpb_commit_time; name: 'isc_tpb_commit_time'),
   (id: isc_tpb_ignore_limbo; name: 'isc_tpb_ignore_limbo'),
   (id: isc_tpb_autocommit; name: 'isc_tpb_autocommit'),
   (id: isc_tpb_restart_requests; name: 'isc_tpb_restart_requests'),
   (id: isc_tpb_no_auto_undo; name: 'isc_tpb_no_auto_undo')
  );
var
 tr: tfbtrans;
 pb: ixpbbuilder;
 pbbuffer: pointer;
 pblen: int32;
 i1,i2,i3: int32;
 s1,s2: string;
label
 next;
begin
 result := false;
 tr:= trans as tfbtrans;
 if aparams.count > 0 then begin
  pb:= getpb();
  for i1:= 0 to aparams.count - 1 do begin
   s1:= trim(aparams[i1]);
   for i2:= 0 to high(paramconsts) do begin
    with paramconsts[i2] do begin
     if s1 = name then begin
      pb.inserttag(fapi.status,id);
      goto next;
     end;
    end;
   end;
  if pos('isc_tpb_lock_timeout',s1) = 1 then begin
   i3:= length('isc_tpb_lock_timeout');
     if length(s1) > i3 then begin
      s2:= trim(copy(s1,i3+1,bigint));
      if trystrtoint(s2,i3) then begin
       pb.insertint(fapi.status,isc_tpb_lock_timeout,i3);
      end
      else begin
       paramerror(s1);
      end;
     end
     else begin
      paramerror(s1);
     end;
    end;
next:
  end;
  pblen:= pb.getbufferlength(fapi.status);
  pbbuffer:= pb.getbuffer(fapi.status);
 end
 else begin
  pb:= nil;
  pblen:= 0;
  pbbuffer:= nil;
 end;
 tr.ftrans:= fattachment.starttransaction(fapi.status,pblen,pbbuffer);
 if pb <> nil then begin
  pb.dispose();
 end;
 checkstatus('startdbtransaction');
 tr.ftrans.addref();
end;

function tfirebirdconnection.allocatecursorhandle(const aowner: icursorclient;
               const aname: ansistring): tsqlcursor;
begin
 result:= tfbcursor.create(aowner,self);
end;

procedure tfirebirdconnection.preparestatement(const cursor: tsqlcursor;
               const atransaction: tsqltransaction; const asql: msestring;
               const aparams: tmseparams);
var
 str1: string;
begin
 with tfbcursor(cursor) do begin
  if assigned(aparams) and (aparams.count > 0) then begin
   str1:= todbstring(aparams.parsesql(asql,false,false,false,psinterbase,
                            fparambinding));
  end
  else begin
   str1:= todbstring(asql);
  end;
  with tfbtrans(atransaction.trans) do begin
   fstatement:= fowner.fattachment.prepare(fowner.fapi.status,ftrans,length(str1),
            pointer(str1),fowner.dialect,istatement.prepare_prefetch_metadata);
   fowner.checkstatus('preparestatement');
   fstatement.addref();
  end;
 end;
end;

{ tfbtrans }

constructor tfbtrans.create(const aowner: tfirebirdconnection);
begin
 fowner:= aowner;
end;

destructor tfbtrans.destroy();
begin
 inherited;
 if ftrans <> nil then begin
  ftrans.release();
 end;
end;

{ tfbcursor }

constructor tfbcursor.create(const aowner: icursorclient;
               const aconnection: tfirebirdconnection);
begin
 fconnection:= aconnection;
 inherited create(aowner,fconnection.name);
end;

destructor tfbcursor.destroy();
begin
 inherited;
 if fstatement <> nil then begin
  fstatement.release();
 end;
end;

end.
