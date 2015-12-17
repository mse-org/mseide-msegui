unit msefbservice;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{under construction}
interface
uses
 classes,mclasses,mseclasses,ibase60dyn,msetypes,mdb,msestrings,mibconnection;

const
 defaultinfotimeout = 60; //seconds
 
type
 fbserverinfoty = record
  version: card32;
  server_version: string;
  _implementation: string;
  capabilities: card32;
  user_dbpath: string;
  get_env: string;
  get_env_lock: string;
  get_env_msg: string;
 end;

 fbuserinfoty = record
  username: msestring;
  firstname: msestring;
  middlename: msestring;
  lastname: msestring;
  userid: card32;
  groupid: card32;
  admin: card32;
 end;
 pfbuserinfoty = ^fbuserinfoty;
 fbuserinfoarty = array of fbuserinfoty;
 
 tfbservice = class;
 
 efbserviceerror = class(edatabaseerror)
  private
   ferror: integer;
   ferrormessage: msestring;
   fsender: tfbservice;
   fstatus: statusvectorty;
  public
   constructor create(const asender: tfbservice; const amessage: msestring;
                       const aerror: statusvectorty);
   property sender: tfbservice read fsender;
   property error: integer read ferror;
   property errormessage: msestring read ferrormessage;
   property status: statusvectorty read fstatus;
 end;

 fbservicestatety = (fbss_connected,fbss_busy);
 fbservicestatesty = set of fbservicestatety;
 fbserviceoptionty = (fbso_utf8,fbso_utf8message);
 fbserviceoptionsty = set of fbserviceoptionty;
 
 tfbservice = class(tmsecomponent)
  private
   fhostname: ansistring;
   fusername: ansistring;
   fpassword: ansistring;
   fstate: fbservicestatesty;
   fhandle: isc_svc_handle;
   fstatus: statusvectorty; //array [0..19] of isc_status;
   flasterror: statusvectorty;
   flasterrormessage: msestring;
   foptions: fbserviceoptionsty;
   finfotimeout: int32;
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
  protected
   function connectionmessage(atext: pchar): msestring;
   procedure loaded(); override;
   procedure connect();
   procedure disconnect();
   procedure readstate(reader: treader); override;
   procedure checkerror(const procname : string;
                            const status : statusvectorty);
   procedure checkerror(const procname : string;
                            const status: integer);
   procedure checkbusy();
   procedure start(const procname: string; const params: string);
//   function getvalueitem(var buffer: pointer; const id: int32): card32;
//   function getstringitem(var buffer: pointer; const id: int32): string;
   function getinfo(const procname: string; const items: array of byte): string;
   function getmsestringitem(var buffer: pointer; const id: int32;
                                                var value: msestring): boolean;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   function busy(): boolean;
   function serverinfo(): fbserverinfoty;
   function users(): fbuserinfoarty;
   
   property lasterror: statusvectorty read flasterror;
   property lasterrormessage: msestring read flasterrormessage;
  published
   property hostname : ansistring read fhostname write fhostname;
   property username : ansistring read fusername write fusername;
   property password : ansistring read fpassword write fpassword;
   property connected: boolean read getconnected 
                                    write setconnected default false;   
   property options: fbserviceoptionsty read foptions write foptions default [];
   property infotimeout: int32 read finfotimeout write finfotimeout 
                                          default defaultinfotimeout; //seconds
 end;
 
implementation
uses
 msebits,msearrayutils;

function readvalue16(var buffer: pbyte): card16;
begin
 result:= buffer^;
 inc(buffer);
 result:= result + buffer^ shl 8;
 inc(buffer);
end;

function readvalue32(var buffer: pbyte): card16;
begin
 result:= buffer^;
 inc(buffer);
 result:= result + buffer^ shl 8;
 inc(buffer);
 result:= result + buffer^ shl 16;
 inc(buffer);
 result:= result + buffer^ shl 24;
 inc(buffer);
end;

procedure storevalue(var buffer: pbyte; const value: card16);
begin
 buffer^:= value;
 inc(buffer);
 buffer^:= value shr 8;
 inc(buffer); 
end;

procedure storevalue(var buffer: pbyte; const value: card32);
begin
 buffer^:= value;
 inc(buffer);
 buffer^:= value shr 8;
 inc(buffer); 
 buffer^:= value shr 16;
 inc(buffer); 
 buffer^:= value shr 24;
 inc(buffer); 
end;

procedure addshortparam(var params: string; const id: int32;
                                              const value: string); 
                                                //value limited to 255 chars
var
 i1,i2: int32;
 po1: pbyte;
begin
 i1:= length(value);
 if i1 > 255 then begin
  i1:= 255;
 end;
 i2:= length(params);
 setlength(params,i2+2+i1);
 po1:= pointer(params)+i2;
 po1^:= id;
 inc(po1);
 po1^:= i1;
 inc(po1);
 move(pointer(value)^,po1^,i1);
end;

procedure addparam(var params: string; const id: int32;
                                              const value: string); 
                                                //value limited to 65535 chars
var
 i1,i2: int32;
 po1: pbyte;
begin
 i1:= length(value);
 if i1 > 65535 then begin
  i1:= 65553;
 end;
 i2:= length(params);
 setlength(params,i2+3+i1);
 po1:= pointer(params)+i2;
 po1^:= id;
 inc(po1);
 storevalue(po1,card16(i1));
 move(pointer(value)^,po1^,i1);
end;

procedure addparam(var params: string; const id: int32;
                                              const value: card32); 
var
 i2: int32;
 po1: pbyte;
begin
 i2:= length(params);
 setlength(params,i2+1+4);
 po1:= pointer(params)+i2;
 po1^:= id;
 inc(po1);
 storevalue(po1,value);
end;

procedure addparam(var params: string; const id: int32); 
var
 i2: int32;
 po1: pbyte;
begin
 i2:= length(params);
 setlength(params,i2+1+0);
 po1:= pointer(params)+i2;
 po1^:= id;
end;

function getvalueitem(var buffer: pointer; const id: int32;
                                                var value: card32): boolean;
begin
 result:= false;
 if pbyte(buffer)^ = id then begin
  inc(buffer);
  value:= readvalue32(buffer);
  result:= true;
 end;
end;

function getstringitem(var buffer: pointer; const id: int32;
                                                var value: string): boolean;
var
 i1: int32;
begin
 result:= false;
 if pbyte(buffer)^ = id then begin
  inc(buffer);
  i1:= readvalue16(buffer);
  setlength(value,i1);
  move((buffer)^,pointer(value)^,i1);
  inc(buffer,i1);
  result:= true;
 end;
end;

{ efbserviceerror }

constructor efbserviceerror.create(const asender: tfbservice;
               const amessage: msestring; const aerror: statusvectorty);
begin
 fstatus:= aerror;
 fsender:= sender;
 ferror:= aerror[1];
 ferrormessage:= amessage;
 inherited create(asender.name+': '+ansistring(amessage));
end;

{ tfbservice }

constructor tfbservice.create(aowner: tcomponent);
begin
 fhandle:= FB_API_NULLHANDLE;
 finfotimeout:= defaultinfotimeout;
 inherited;
end;

destructor tfbservice.destroy();
begin
 inherited;
 disconnect();
end;

function tfbservice.busy(): boolean;
begin
 result:= fbss_busy in fstate;
end;

function tfbservice.getconnected: boolean;
begin
 result:= fhandle <> FB_API_NULLHANDLE;
end;

procedure tfbservice.setconnected(const avalue: boolean);
begin
 if csreading in componentstate then begin
  updatebit1(card32(fstate),ord(fbss_connected),avalue);
 end
 else begin
  if avalue then begin
   connect();
  end
  else begin
   disconnect();
  end;
 end;
end;

function tfbservice.connectionmessage(atext: pchar): msestring;
begin
 if fbso_utf8message in foptions then begin
  result:= utf8tostring(atext);
 end
 else begin
  result:= atext;
 end;
end;

procedure tfbservice.loaded();
begin
 if fbss_connected in fstate then begin
  connect();
 end;
end;

procedure tfbservice.connect();
const
 servicename = 'service_mgr';
var
 params1: string;
 str1: string;
begin
 if fhandle = FB_API_NULLHANDLE then begin
  try
   initializeibase60([]);
   if fhostname = '' then begin
    str1:= servicename;
   end
   else begin
    str1:= fhostname + ':' + servicename; //tcp/ip
   end;
   params1:=  char(isc_spb_version)+char(isc_spb_current_version);
   addshortparam(params1,isc_spb_user_name,fusername);
   addshortparam(params1,isc_spb_password,fpassword);
   checkerror('Connect',isc_service_attach(@fstatus,length(str1),pointer(str1),
                                    @fhandle,length(params1),pointer(params1)));
  except
   exclude(fstate,fbss_connected);
   fhandle:= FB_API_NULLHANDLE;
   releaseibase60();
   raise;
  end;
 end;
 include(fstate,fbss_connected);
end;

procedure tfbservice.disconnect();
begin
 fstate:= fstate - [fbss_connected,fbss_busy];
 if fhandle <> FB_API_NULLHANDLE then begin
  isc_service_detach(@fstatus,@fhandle);
  fhandle:= FB_API_NULLHANDLE;
  releaseibase60();
 end;
end;

procedure tfbservice.readstate(reader: treader);
begin
 disconnect();
 inherited;
end;

procedure tfbservice.checkerror(const procname: string;
               const status: statusvectorty);
var
 buf: array [0..1024] of char;
 p: pointer;
 Msg: msestring;  
begin
 if ((Status[0] = 1) and (Status[1] <> 0)) then begin
  p:= @Status;
  msg:= msestring(procname);
{$warnings off}
  while isc_interprete(Buf, @p) > 0 do begin
   Msg := Msg + lineend +' -' + connectionmessage(Buf);
  end;
  flasterror:= status;
  flasterrormessage:= msg;
//  flastsqlcode:= isc_sqlcode(@status);
  raise efbserviceerror.create(self,msg,status{,flastsqlcode});
 end;
end;
{$warnings on}

procedure tfbservice.checkerror(const procname: string; const status: integer);
begin
 if status <> 0 then begin
  checkerror(procname,fstatus);
 end;
end;

procedure tfbservice.checkbusy();
begin
 if not connected then begin
  databaseerror('Not connected',self);
 end;
 if busy then begin
  databaseerror('Busy',self);
 end;
end;

procedure tfbservice.start(const procname: string; const params: string);
begin
 checkbusy();
 checkerror(procname,isc_service_start(@fstatus,@fhandle,FB_API_NULLHANDLE,
                                   length(params),pointer(params)));
 include(fstate,fbss_busy);
end;

function tfbservice.getinfo(const procname: string; 
                                         const items: array of byte): string;
var
 params1: string;
begin
 params1:= '';
// params1:=  char(isc_spb_version)+char(isc_spb_current_version);
 addparam(params1,isc_info_svc_timeout,finfotimeout);
 setlength(result,1024);
 while true do begin
  checkerror(procname,isc_service_query(@fstatus,@fhandle,nil,length(params1),
      pointer(params1),length(items),@items[0],length(result),pointer(result)));
  if pbyte(pointer(result))^ <> isc_info_truncated then begin
   break;
  end;
  setlength(result,2*length(result));
 end;
end;

function tfbservice.getmsestringitem(var buffer: pointer; const id: int32;
               var value: msestring): boolean;
var
 str1: string;
begin
 str1:= '';
 result:= getstringitem(buffer,id,str1);
 if result then begin
  if fbso_utf8 in foptions then begin
   value:= utf8tostringansi(str1);
  end
  else begin
   value:= msestring(str1);
  end;
 end;
end;

function tfbservice.serverinfo(): fbserverinfoty;
var
 buffer: string;
 po1: pbyte;
begin
 checkbusy();
 finalize(result);
 fillchar(result,sizeof(result),0);
 buffer:= getinfo('serverinfo',[isc_info_svc_version,
            isc_info_svc_server_version,isc_info_svc_implementation,
            isc_info_svc_capabilities,isc_info_svc_user_dbpath,
            isc_info_svc_get_env,isc_info_svc_get_env_lock,
            isc_info_svc_get_env_msg]);
 po1:= pointer(buffer);
 with result do begin
  while (po1^ <> isc_info_end) and (po1^ <> 0) do begin
   if not (getvalueitem(po1,isc_info_svc_version,version) or
           getstringitem(po1,isc_info_svc_server_version,server_version) or
           getstringitem(po1,isc_info_svc_implementation,_implementation) or
           getvalueitem(po1,isc_info_svc_capabilities,capabilities) or
           getstringitem(po1,isc_info_svc_user_dbpath,user_dbpath) or
           getstringitem(po1,isc_info_svc_get_env,get_env) or
           getstringitem(po1,isc_info_svc_get_env_lock,get_env_lock) or
           getstringitem(po1,isc_info_svc_get_env_msg,get_env_msg)) then begin
    databaseerror('Unknown serverinfo item',self);
   end;
  end;
 end;
end;

function tfbservice.users(): fbuserinfoarty;
var
 buffer: string;
 po1: pbyte;
 count: int32;
 po2: pfbuserinfoty;
begin
 checkbusy();
 buffer:= char(isc_action_svc_display_user_adm);
 start('users',buffer);
 result:= nil;
 count:= 0;
 buffer:= getinfo('users',[isc_info_svc_get_users]);
 po1:= pointer(buffer);
 if po1^ <> isc_info_svc_get_users then begin
  databaseerror('Invalid users response',self);
 end;
 inc(po1,3); //additional bytes 50 0 ???
 while (po1^ <> isc_info_flag_end) and (po1^ <> isc_info_end) and 
                                                        (po1^ <> 0) do begin
  if po1^ = isc_spb_sec_username then begin //must be first field
   additem(result,typeinfo(result),count);
   po2:= @result[count-1];
   getmsestringitem(po1,isc_spb_sec_username,po2^.username)   
  end
  else begin
   if result = nil then begin
    databaseerror('Invalid users response',self);
   end;
  end;
  with po2^ do begin
   while (po1^ <> isc_spb_sec_username) and (po1^ <> isc_info_flag_end) and 
                                 (po1^ <> isc_info_end) and (po1^ <> 0) do begin
    if not (getmsestringitem(po1,isc_spb_sec_firstname,firstname) or
            getmsestringitem(po1,isc_spb_sec_middlename,middlename) or
            getmsestringitem(po1,isc_spb_sec_lastname,lastname) or
            getvalueitem(po1,isc_spb_sec_userid,userid) or
            getvalueitem(po1,isc_spb_sec_groupid,groupid) or
            getvalueitem(po1,isc_spb_sec_admin,admin)) then begin
     databaseerror('Unknown users item',self);
    end;
   end;
  end;
 end;
 setlength(result,count);
end;

end.
