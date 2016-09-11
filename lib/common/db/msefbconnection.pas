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

 tfbconnection = class;
 
 tfbtrans = class(tsqlhandle)
  protected
   fconnection: tfbconnection;
   ftransaction: itransaction;
  public
   constructor create(const aconnection: tfbconnection);
   destructor destroy(); override;
 end;

 cursorstatety = (cs_hasstatement);
 cursorstatesty = set of cursorstatety;

 pfbfieldinfoty = ^fbfieldinfoty;
 fetchfuncty = procedure(const info: pfbfieldinfoty; const dest: pointer);

 tfbcursor = class;
 
 fbfieldinfoty = record
  buffer: pointer;
  name: string;
  _type: card32;
  offset: card32;
  nulloffset: int32; //-1 = none
  fetchfunc: fetchfuncty;
  _cursor: tfbcursor;
  datatype: tfieldtype;
  size: int32;
  precision: int32;
  buffersizead: pint32; //temp
 end;
 
 fbfieldinfoarty = array of fbfieldinfoty;
  
 tfbcursor = class(tsqlcursor)
  protected
   fconnection: tfbconnection;
   fparambinding: tparambinding;
   fstatement: istatement;
   fresultset: iresultset;
   fcursorstate: cursorstatesty;
   ffieldinfos: fbfieldinfoarty;
   frowbuffer: string;
  public
   constructor create(const aowner: icursorclient;
                                       const aconnection: tfbconnection);
   destructor destroy(); override;
   procedure close() override;
 end;
  
 fbapity = record
  master: imaster;
  status: istatus;
  provider: iprovider;
  util: iutil;
 end;
 
 tfbconnection = class(tcustomsqlconnection,iblobconnection)
  private
   fdialect: integer;
   function getblobstream(const acursor: tsqlcursor; const blobid: isc_quad;
                      const forstring: boolean = false): tmemorystream;
   function getblobstring(const acursor: tsqlcursor;
                                      const blobid: isc_quad): string;
  protected
   fapi: fbapity;
   fattachment: iattachment;
   procedure iniapi();
   procedure finiapi();
   function getpb(): ixpbbuilder;
   procedure clearstatus(); inline;
   function statusok(): boolean; inline;
   procedure checkstatus(const aerrormessage: msestring);
   procedure dointernalconnect override;
   procedure dointernaldisconnect override;

   function allocatetransactionhandle : tsqlhandle override;
   function gettransactionhandle(trans : tsqlhandle): pointer override;

   function startdbtransaction(const trans : tsqlhandle;
                      const aparams : tstringlist) : boolean override;
   function commit(trans : tsqlhandle) : boolean override;
   function rollback(trans : tsqlhandle) : boolean override;
   procedure internalcommitretaining(trans : tsqlhandle) override;
   procedure internalrollbackretaining(trans : tsqlhandle) override;

   procedure cursorclose(const cursor: tfbcursor);
   procedure internalexecute(const cursor: tsqlcursor;
             const atransaction: tsqltransaction; const aparams : tmseparams;
                                                const autf8: boolean) override;
   procedure updateindexdefs(var indexdefs : tindexdefs;
                                          const atablename : string) override;
   function getschemainfosql(schematype : tschematype;
              schemaobjectname, schemapattern : msestring) : msestring override;

   function createblobstream(const field: tfield; const mode: tblobstreammode;
                          const acursor: tsqlcursor): tstream; override;
   function getblobdatasize: integer; override;

    //iblobconnection
   procedure writeblobdata(const atransaction: tsqltransaction;
              const tablename: string; const acursor: tsqlcursor;
              const adata: pointer; const alength: integer;
              const afield: tfield; const aparam: tparam; out newid: string);
                                                 overload;
   procedure setupblobdata(const afield: tfield; const acursor: tsqlcursor;
                              const aparam: tparam);
   function blobscached: boolean;
  public
   constructor create(aowner: tcomponent); override;
   function allocatecursorhandle(const aowner: icursorclient;
                      const aname: ansistring): tsqlcursor override;
   procedure deallocatecursorhandle(var cursor : tsqlcursor) override;
   procedure freefldbuffers(cursor : tsqlcursor); override;
   procedure preparestatement(const cursor: tsqlcursor; 
                 const atransaction : tsqltransaction;
                 const asql: msestring; const aparams : tmseparams) override;
   procedure unpreparestatement(cursor : tsqlcursor) override;
   procedure addfielddefs(const cursor: tsqlcursor;
                                      const fielddefs : tfielddefs) override;
   function fetch(cursor : tsqlcursor) : boolean; override;
   function loadfield(const cursor: tsqlcursor;
               const datatype: tfieldtype; const fieldnum: integer; //zero based
     const buffer: pointer; var bufsize: integer;
                                const aisutf8: boolean): boolean; override;
          //if bufsize < 0 -> buffer was to small, should be -bufsize
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
   constructor create(const asender: tfbconnection;
                 const astatus: istatus; const aerrormessage: msestring);
 end;

implementation
uses
 dbconst,msefbinterface,msefbutils,msesqldb,msebufdataset,msedate;

const
 textblobtypes = [ftmemo,ftwidememo]; 
 
{ efberror }

constructor efberror.create(const asender: tfbconnection;
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

{ tfbconnection }

constructor tfbconnection.create(aowner: tcomponent);
begin
 fdialect:= sql_dialect_v6;
 inherited;
end;

procedure tfbconnection.iniapi();
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

procedure tfbconnection.finiapi();
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

procedure tfbconnection.clearstatus(); inline;
begin
 fapi.status.init();
end;

function tfbconnection.statusok(): boolean; inline;
begin
 result:= fapi.status.getstate() and istatus.state_errors = 0
end;

procedure tfbconnection.checkstatus(const aerrormessage: msestring);
begin
 if fapi.status.getstate() and istatus.state_errors <> 0 then begin
  raise efberror.create(self,fapi.status,aerrormessage);
 end;
end;

function tfbconnection.getpb(): ixpbbuilder;
begin
 result:= fapi.util.getxpbbuilder(fapi.status,ixpbbuilder.DPB,nil,0);
end;

procedure tfbconnection.dointernalconnect();
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
  clearstatus();
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

procedure tfbconnection.dointernaldisconnect;
begin
 inherited;
 if fattachment <> nil then begin
  fattachment.detach(fapi.status);
  fattachment.release();
  fattachment:= nil;
 end;
end;

function tfbconnection.allocatetransactionhandle: tsqlhandle;
begin
 result:= tfbtrans.create(self);
end;

function tfbconnection.gettransactionhandle(trans: tsqlhandle): pointer;
begin
 result:= tfbtrans(trans).ftransaction;
end;

function tfbconnection.startdbtransaction(const trans: tsqlhandle;
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
 pb: ixpbbuilder;
 pbbuffer: pointer;
 pblen: int32;
 i1,i2,i3: int32;
 s1,s2: string;
label
 next;
begin
 result := false;
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
 with tfbtrans(trans) do begin
  clearstatus();
  ftransaction:= fattachment.starttransaction(fapi.status,pblen,pbbuffer);
  if pb <> nil then begin
   pb.dispose();
  end;
  checkstatus('startdbtransaction');
 end;
 result:= true;
end;

function tfbconnection.commit(trans: tsqlhandle): boolean;
begin
 with tfbtrans(trans) do begin
  clearstatus();
  ftransaction.commit(fconnection.fapi.status);
  checkstatus('commit');
  ftransaction:= nil;
  result:= true;
 end;
end;

function tfbconnection.rollback(trans: tsqlhandle): boolean;
begin
 with tfbtrans(trans) do begin
  clearstatus();
  ftransaction.rollback(fconnection.fapi.status);
  checkstatus('rollback');
  ftransaction:= nil;
  result:= true;
 end;
end;

procedure tfbconnection.internalcommitretaining(trans: tsqlhandle);
begin
 with tfbtrans(trans) do begin
  clearstatus();
  ftransaction.commitretaining(fapi.status);
  checkstatus('commitretaining');
 end;
end;

procedure tfbconnection.internalrollbackretaining(trans: tsqlhandle);
begin
 with tfbtrans(trans) do begin
  clearstatus();
  ftransaction.rollbackretaining(fapi.status);
  checkstatus('rollbackretaining');
 end;
end;

function tfbconnection.allocatecursorhandle(const aowner: icursorclient;
               const aname: ansistring): tsqlcursor;
begin
 result:= tfbcursor.create(aowner,self);
end;

procedure tfbconnection.deallocatecursorhandle(var cursor: tsqlcursor);
begin
 freeandnil(cursor);
end;

procedure tfbconnection.freefldbuffers(cursor: tsqlcursor);
begin
 with tfbcursor(cursor) do begin
  frowbuffer:= '';
 end;
end;

procedure tfbconnection.preparestatement(const cursor: tsqlcursor;
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
   fparambinding:= nil;
   str1:= todbstring(asql);
  end;
  with tfbtrans(atransaction.trans) do begin
   clearstatus();
   fstatement:= fattachment.prepare(fapi.status,ftransaction,length(str1),
            pointer(str1),dialect,istatement.prepare_prefetch_metadata);
   checkstatus('preparestatement');
   include(fcursorstate,cs_hasstatement);
  end;
 end;
end;

procedure tfbconnection.unpreparestatement(cursor: tsqlcursor);
begin
 with tfbcursor(cursor) do begin
  if cs_hasstatement in fcursorstate then begin
   fparambinding:= nil;
   cursorclose(tfbcursor(cursor));
   clearstatus();
   fstatement.free(fapi.status);
   if not statusok then begin
    fstatement.release();
   end;
   fstatement:= nil;
   exclude(fcursorstate,cs_hasstatement);
  end;
 end;
end;

procedure tfbconnection.cursorclose(const cursor: tfbcursor);
begin
 with cursor do begin
  frowbuffer:= '';
  ffieldinfos:= nil;
  if fresultset <> nil then begin
   clearstatus();
   fresultset.close(fapi.status);
   if not statusok() then begin
    fresultset.release();
   end;
   fresultset:= nil;
  end;
 end;
end;

procedure fetchboolean(const ainfo: pfbfieldinfoty; const dest: pointer);
begin
 pwordbool(dest)^:= pcard8(ainfo^.buffer + ainfo^.offset)^ <> 0;
end;

procedure fetchint16(const ainfo: pfbfieldinfoty; const dest: pointer);
begin
 pint32(dest)^:= pint16(ainfo^.buffer + ainfo^.offset)^;
end;

procedure fetchint32(const ainfo: pfbfieldinfoty; const dest: pointer);
begin
 pint32(dest)^:= pint32(ainfo^.buffer + ainfo^.offset)^;
end;

procedure fetchint64(const ainfo: pfbfieldinfoty; const dest: pointer);
begin
 pint64(dest)^:= pint64(ainfo^.buffer + ainfo^.offset)^;
end;

procedure fetchfloat(const ainfo: pfbfieldinfoty; const dest: pointer);
begin
 pdouble(dest)^:= psingle(ainfo^.buffer + ainfo^.offset)^;
end;

procedure fetchdouble(const ainfo: pfbfieldinfoty; const dest: pointer);
begin
 pdouble(dest)^:= pdouble(ainfo^.buffer + ainfo^.offset)^;
end;

procedure fetchtime(const ainfo: pfbfieldinfoty; const dest: pointer);
begin
 pdatetime(dest)^:= pisc_time(ainfo^.buffer + ainfo^.offset)^ /
                                  (3600*24*ISC_TIME_SECONDS_PRECISION);
end;

procedure fetchdate(const ainfo: pfbfieldinfoty; const dest: pointer);
begin
 pdatetime(dest)^:= pisc_date(ainfo^.buffer + ainfo^.offset)^ + fbdatetimeoffset;
end;

procedure fetchtimestamp(const ainfo: pfbfieldinfoty; const dest: pointer);
var
 ti,da: double;
 po1: pisc_timestamp;
begin
 po1:= ainfo^.buffer + ainfo^.offset;
 da:= po1^.timestamp_date + fbdatetimeoffset;
 ti:= po1^.timestamp_time / (3600*24*ISC_TIME_SECONDS_PRECISION);
 if da < 0 then begin 
  pdatetime(dest)^:= da - ti;
 end
 else begin
  pdatetime(dest)^:= da + ti;
 end;
end;

procedure fetchtext(const ainfo: pfbfieldinfoty; const dest: pointer);
var
 i1: int32;
 po1: pchar;
begin
 po1:= ainfo^.buffer + ainfo^.offset;
 i1:= ainfo^.size;
 if i1 > ainfo^.buffersizead^ then begin
  ainfo^.buffersizead^:= -i1;
 end
 else begin
  ainfo^.buffersizead^:= i1;
  move(po1^,dest^,i1);
 end;
end;

procedure fetchvarchar(const ainfo: pfbfieldinfoty; const dest: pointer);
var
 i1: int32;
 po1: pvary;
begin
 po1:= ainfo^.buffer + ainfo^.offset;
 i1:= po1^.vary_length;
 if i1 > ainfo^.buffersizead^ then begin
  ainfo^.buffersizead^:= -i1;
 end
 else begin
  ainfo^.buffersizead^:= i1;
  move(po1^.vary_string,dest^,i1);
 end;
end;

procedure fetchblobid(const ainfo: pfbfieldinfoty; const dest: pointer);
begin
 pisc_quad(dest)^:= pisc_quad(ainfo^.buffer + ainfo^.offset)^;
             //todo: wantblobfetch
end;

procedure fetchblobidanddata(const ainfo: pfbfieldinfoty; const dest: pointer);
begin
 pisc_quad(dest)^:= pisc_quad(ainfo^.buffer + ainfo^.offset)^;
 ainfo^._cursor.addblobcache(pint64(dest)^,
           ainfo^._cursor.fconnection.getblobstring(
                                    ainfo^._cursor,pisc_quad(dest)^));
end;

procedure tfbconnection.internalexecute(const cursor: tsqlcursor;
               const atransaction: tsqltransaction; const aparams: tmseparams;
               const autf8: boolean);
var
 metadata: imessagemetadata;
 paramdata: tparamdata; //inherits from imessagemetadata
 parambuffer: pointer;
 i1,i2,i3: int32;
begin
 with tfbcursor(cursor) do begin
  if assigned(aparams) and (aparams.count > 0) and 
                                           (fparambinding <> nil) then begin
   paramdata:= tparamdata.create(tfbcursor(cursor),aparams);
   parambuffer:= paramdata.parambuffer;
  end
  else begin
   paramdata:= nil;
   parambuffer:= nil;
  end;
  with tfbtrans(atransaction.trans) do begin
   clearstatus();
 //  fstatement.execute(fapi.status,ftransaction,nil,nil,nil,nil);
   fresultset:= fstatement.opencursor(fapi.status,ftransaction,
                                     paramdata,parambuffer,nil,0);
   if paramdata <> nil then begin
    paramdata.release();
   end;
   if fresultset <> nil then begin
    metadata:= fresultset.getmetadata(fapi.status);
    if metadata <> nil then begin
     setlength(frowbuffer,metadata.getmessagelength(fapi.status));
     i1:= metadata.getcount(fapi.status);
     if statusok() then begin
      setlength(ffieldinfos,i1);
      for i1:= 0 to i1-1 do begin
       with ffieldinfos[i1] do begin
        buffer:= pointer(frowbuffer);
        name:= metadata.getalias(fapi.status,i1);
        offset:= metadata.getoffset(fapi.status,i1);
        _type:= metadata.gettype(fapi.status,i1);
        if metadata.isnullable(fapi.status,i1) then begin
         nulloffset:= metadata.getnulloffset(fapi.status,i1);
        end
        else begin
         nulloffset:= -1;
        end;
        size:= 0;
        precision:= 0;
        case _type of
 {
  SQL_TEXT =          452;
  SQL_VARYING =       448;
  SQL_SHORT =         500;
  SQL_LONG =          496;
  SQL_FLOAT =         482;
  SQL_DOUBLE =        480;
  SQL_D_FLOAT =       530;
  SQL_TIMESTAMP =     510;
  SQL_BLOB =          520;
  SQL_ARRAY =         540;
  SQL_QUAD =          550;
  SQL_TYPE_TIME =     560;
  SQL_TYPE_DATE =     570;
  SQL_INT64 =         580;
  SQL_BOOLEAN =     32764;
  SQL_NULL =        32766;
  }
         SQL_BOOLEAN: begin
          datatype:= ftboolean;
          fetchfunc:= @fetchboolean;
         end;
         SQL_SHORT: begin
          datatype:= ftsmallint;
          fetchfunc:= @fetchint16;
         end;
         SQL_LONG: begin
          datatype:= ftinteger;
          fetchfunc:= @fetchint32;
         end;
         SQL_INT64,SQL_QUAD: begin
          datatype:= ftlargeint;
          fetchfunc:= @fetchint64;
         end;
         SQL_FLOAT: begin
          datatype:= ftfloat;
          fetchfunc:= @fetchfloat;
         end;
         SQL_DOUBLE,SQL_D_FLOAT: begin
          datatype:= ftfloat;
          fetchfunc:= @fetchdouble;
         end;
         SQL_TIMESTAMP: begin
          datatype:= ftdatetime;
          fetchfunc:= @fetchtimestamp;
         end;
         SQL_TYPE_DATE: begin
          datatype:= ftdate;
          fetchfunc:= @fetchdate;
         end;
         SQL_TYPE_TIME: begin
          datatype:= fttime;
          fetchfunc:= @fetchtime;
         end;
         SQL_TEXT,SQL_VARYING: begin
          size:= metadata.getlength(fapi.status,i1);
          datatype:= ftstring;
          if _type = SQL_TEXT then begin
           fetchfunc:= @fetchtext;
          end
          else begin
           fetchfunc:= @fetchvarchar;
          end;
          i2:= metadata.getcharset(fapi.status,i1);
          case i2 of
         //  0,1,2,10,11,12,13,14,19,21,22,39,
         //  45,46,47,50,51,52,53,54,55,58: begin
         //   int1:= 1;
           5,6,8,44,56,57,64: begin
            i3:= 2;
           end;
           3: begin
            i3:= 3;
           end;
           4,59: begin
            i3:= 4;
           end;
           else begin
            i3:= 1;
           end;
          end;
          size:= size div i3;
         end;
         SQL_BLOB: begin
          size:= 8;
          if wantblobfetch then begin
           fetchfunc:= @fetchblobidanddata;
           _cursor:= tfbcursor(cursor);
          end
          else begin
           fetchfunc:= @fetchblobid;
          end;
          if metadata.getsubtype(fapi.status,i1) = isc_blob_text then begin
           datatype:= ftmemo;
          end
          else begin
           datatype:= ftblob;
          end;
         end;
         else begin
          datatype:= ftunknown;
          fetchfunc:= nil;
         end;
        end;
       end;
      end;
     end;
     metadata.release();
    end;
   end;
   checkstatus('execute');
  end;
 end;
end;

procedure tfbconnection.addfielddefs(const cursor: tsqlcursor;
               const fielddefs: tfielddefs);
var
 i1: int32;
begin
 with tfbcursor(cursor) do begin
  fielddefs.clear();
  for i1:= 0 to high(ffieldinfos) do begin
   with ffieldinfos[i1] do begin
    if datatype <> ftunknown then begin
     with tfielddef.create(fielddefs,name,datatype,size,false,i1+1) do begin
     end;
    end;
   end;
  end;
 end;
end;

procedure tfbconnection.updateindexdefs(var indexdefs: tindexdefs;
               const atablename: string);
begin
 fbupdateindexdefs(self,indexdefs,atablename);
end;

function tfbconnection.getschemainfosql(schematype : tschematype;
                schemaobjectname, schemapattern : msestring) : msestring;
begin
 result:= fbgetschemainfosql(self,schematype,schemaobjectname,schemapattern);
end;

function tfbconnection.fetch(cursor: tsqlcursor): boolean;
begin
 with tfbcursor(cursor) do begin
  clearstatus();
  result:= fresultset.fetchnext(fapi.status,pointer(frowbuffer)) = 
                                                         istatus.RESULT_OK;
  checkstatus('fetch');
 end;
end;

function tfbconnection.loadfield(const cursor: tsqlcursor;
               const datatype: tfieldtype; const fieldnum: integer;
               const buffer: pointer; var bufsize: integer;
               const aisutf8: boolean): boolean;
var
 po1: pfbfieldinfoty;
begin
 with tfbcursor(cursor) do begin
  po1:= @ffieldinfos[fieldnum];
  if (po1^.nulloffset >= 0) and 
              (pisc_short(po1^.buffer + po1^.nulloffset)^ <> 0) or 
                                            (po1^.fetchfunc = nil) then begin
   result:= false;
  end
  else begin
   if buffer <> nil then begin //else null check;
    po1^.buffersizead:= @bufsize;
    po1^.fetchfunc(po1,buffer);
   end;
   result:= true;
  end;
 end;
end;

const
 infotags: array[0..1] of byte = 
                     (isc_info_blob_max_segment,isc_info_blob_total_length);

function tfbconnection.getblobstream(const acursor: tsqlcursor;
               const blobid: isc_quad;
               const forstring: boolean = false): tmemorystream;
var
 blob: iblob;
 buffer: array[0..63] of byte;
 maxsegment,totallength: int32;
 i1,i2,i3: int32;
 po1,pe: pcard8;
 by1: byte;
begin
 clearstatus();
 blob:= fattachment.openblob(fapi.status,itransaction(acursor.ftrans),
                                                                 @blobid,0,nil);
 checkstatus('open blob');
 try
  blob.getinfo(fapi.status,length(infotags),@infotags,sizeof(buffer),@buffer);
  checkstatus('get blob info');
  po1:= @buffer;
  pe:= po1 + sizeof(buffer);
  maxsegment:= -1;
  totallength:= -1;
  while (po1 < pe) and (po1^ <> isc_info_end) do begin
   by1:= po1^;
   inc(po1);
   i2:= gds__vax_integer(po1,2);
   inc(po1,2);
   i3:= gds__vax_integer(po1,i2);
   inc(po1,i2);
   case by1 of
    isc_info_blob_max_segment: begin
     maxsegment:= i3;
    end;
    isc_info_blob_total_length: begin
     totallength:= i3;
    end;
    else begin
     break;
    end;
   end;
  end;
  if (maxsegment < 0) or (totallength < 0) or 
                     (maxsegment = 0) and (totallength <> 0)then begin
   databaseerror('Invalid blob info result',self);
  end;
  if forstring then begin
   result:= tmemorystringstream.create;
  end
  else begin
   result:= tmemorystream.create;
  end;
  result.size:= totallength;
  po1:= result.memory;
  repeat
   i3:= totallength;
   if i3 > maxsegment then begin
    i3:= maxsegment;
   end;
   i2:= blob.getsegment(fapi.status,i3,po1,@i1);
   checkstatus('read blob');
   po1:= po1 + i1;
   totallength:= totallength - i1;
  until (totallength <= 0) or
          not ((i2 = istatus.RESULT_OK) or (i2 = istatus.RESULT_SEGMENT));
 finally
  blob.release();
 end;
end;

function tfbconnection.getblobstring(const acursor: tsqlcursor;
               const blobid: isc_quad): string;
begin
 tmemorystringstream(getblobstream(acursor,blobid,true)).destroyasstring(result);
end;

function tfbconnection.createblobstream(const field: tfield;
               const mode: tblobstreammode; const acursor: tsqlcursor): tstream;
var
  blobId : ISC_QUAD;
begin
 result := nil;
 if mode = bmRead then begin
  if not field.getData(@blobId) then begin
   exit;
  end;
  result:= getblobstream(acursor,blobid);
 end
 else begin
  if (mode = bmwrite) and (field.dataset is tmsesqlquery) then begin
   result:= tmsebufdataset(field.dataset).createblobbuffer(field);
  end;
 end;
end;

function tfbconnection.getblobdatasize: integer;
begin
 result:= 8;
end;

procedure tfbconnection.writeblobdata(const atransaction: tsqltransaction;
               const tablename: string; const acursor: tsqlcursor;
               const adata: pointer; const alength: integer;
               const afield: tfield; const aparam: tparam; out newid: string);
const
 maxsegment = $ffff;
var
 blob: iblob;
 id: isc_quad;
 po1: pcard8;
 i1: int32;
begin
 clearstatus();
 blob:= fattachment.createblob(fapi.status,
                  tfbtrans(atransaction.trans).ftransaction,@id,0,nil);
 checkstatus('createblob');
 i1:= alength;
 po1:= adata;
 try
  while i1 > 0 do begin
   if i1 > maxsegment then begin
    blob.putsegment(fapi.status,maxsegment,po1);
   end
   else begin
    blob.putsegment(fapi.status,i1,po1);
   end;
   inc(po1,maxsegment);
   dec(i1,maxsegment);
   checkstatus('put segment');
  end;
  blob.close(fapi.status);
 finally
  blob.release();
 end;
 checkstatus('writeblobdata');

 if aparam <> nil then begin
  aparam.aslargeint:= int64(id);
  if afield.datatype in textblobtypes then begin
   aparam.blobkind:= bk_text;
  end
  else begin
   aparam.blobkind:= bk_binary;
  end;
 end
 else begin
  setlength(newid,sizeof(isc_quad));
  pisc_quad(pointer(newid))^:= id;
 end;
end;

procedure tfbconnection.setupblobdata(const afield: tfield;
               const acursor: tsqlcursor; const aparam: tparam);
var
 blobid: isc_quad;
begin
 afield.getdata(@blobid);
 aparam.aslargeint:= int64(blobid);
 if afield.datatype in textblobtypes then begin
  aparam.blobkind:= bk_text;
 end
 else begin
  aparam.blobkind:= bk_binary;
 end;
end;

function tfbconnection.blobscached: boolean;
begin
 result:= false;
end;

{ tfbtrans }

constructor tfbtrans.create(const aconnection: tfbconnection);
begin
 fconnection:= aconnection;
end;

destructor tfbtrans.destroy();
begin
 inherited;
 if ftransaction <> nil then begin
  ftransaction.release();
 end;
end;

{ tfbcursor }

constructor tfbcursor.create(const aowner: icursorclient;
               const aconnection: tfbconnection);
begin
 fconnection:= aconnection;
 inherited create(aowner,fconnection.name);
end;

destructor tfbcursor.destroy();
begin
 inherited;
 if fresultset <> nil then begin
  close(); //first, close needs valid statment
 end;
 if fstatement <> nil then begin
  fstatement.release();
 end;
end;

procedure tfbcursor.close();
begin
 inherited;
 fconnection.cursorclose(self);
end;

end.
