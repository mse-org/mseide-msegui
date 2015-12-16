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
(*   
  { Retrieves the number of attachments and databases  }
     isc_info_svc_svr_db_info = 50;
  { Retrieves all license keys and IDs from the license file  }
     isc_info_svc_get_license = 51;
  { Retrieves a bitmask representing licensed options on the server  }
     isc_info_svc_get_license_mask = 52;
  { Retrieves the parameters and values for IB_CONFIG  }
     isc_info_svc_get_config = 53;
  { Retrieves the version of the services manager  }
     isc_info_svc_version = 54;
  { Retrieves the version of the InterBase server  }
     isc_info_svc_server_version = 55;
  { Retrieves the implementation of the InterBase server  }
     isc_info_svc_implementation = 56;
  { Retrieves a bitmask representing the server's capabilities  }
     isc_info_svc_capabilities = 57;
  { Retrieves the path to the security database in use by the server  }
     isc_info_svc_user_dbpath = 58;
  { Retrieves the setting of $INTERBASE  }
     isc_info_svc_get_env = 59;
  { Retrieves the setting of $INTERBASE_LCK  }
     isc_info_svc_get_env_lock = 60;
  { Retrieves the setting of $INTERBASE_MSG  }
     isc_info_svc_get_env_msg = 61;
  { Retrieves 1 line of service output per call  }
     isc_info_svc_line = 62;
  { Retrieves as much of the server output as will fit in the supplied buffer  }
     isc_info_svc_to_eof = 63;
  { Sets / signifies a timeout value for reading service information  }
     isc_info_svc_timeout = 64;
  { Retrieves the number of users licensed for accessing the server  }
     isc_info_svc_get_licensed_users = 65;
  { Retrieve the limbo transactions  }
     isc_info_svc_limbo_trans = 66;
  { Checks to see if a service is running on an attachment  }
     isc_info_svc_running = 67;
  { Returns the user information from isc_action_svc_display_users  }
     isc_info_svc_get_users = 68;
     isc_info_svc_stdin = 78;
 *)
 tfbservice = class;
 
 efbserviceerror = class(edatabaseerror)
  private
   ferror: integer;
   ferrormessage: msestring;
   fsender: tfbservice;
   fstatus: statusvectorty;
//   fsqlcode: integer;
  public
   constructor create(const asender: tfbservice; const amessage: msestring;
                       const aerror: statusvectorty{; const asqlcode: integer});
   property sender: tfbservice read fsender;
   property error: integer read ferror;
   property errormessage: msestring read ferrormessage;
   property status: statusvectorty read fstatus;
//   property sqlcode: integer read fsqlcode;
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
   function getvalueitem(var buffer: pointer; const id: int32): card32;
   function getstringitem(var buffer: pointer; const id: int32): string;
   function getinfo(const procname: string; const items: array of byte): string;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
   function busy(): boolean;
   function serverinfo(): fbserverinfoty;   
   
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
 msebits;

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
 pcard16(po1)^:= ntobe(card16(i1));
 inc(po1,2);
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
 pcard32(po1)^:= ntobe(card32(value));
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

function tfbservice.getvalueitem(var buffer: pointer; const id: int32): card32;
begin
 if pbyte(buffer)^ <> id then begin
  databaseerror('Invalid result',self);
 end;
 result:= leton(pcard32(buffer+1)^);
 inc(buffer,5);
end;

function tfbservice.getstringitem(var buffer: pointer; const id: int32): string;
var
 i1: int32;
begin
 if pbyte(buffer)^ <> id then begin
  databaseerror('Invalid result',self);
 end;
 i1:= leton(pcard16(buffer+1)^);
 setlength(result,i1);
 move((buffer+3)^,pointer(result)^,i1);
 inc(buffer,3+i1);
end;

function tfbservice.getinfo(const procname: string; 
                                         const items: array of byte): string;
var
 params1: string;
begin
 params1:= '';
 addparam(params1,finfotimeout);
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

function tfbservice.serverinfo(): fbserverinfoty;
var
 buffer: string;
 po1: pbyte;
begin
 finalize(result);
 fillchar(result,sizeof(result),0);
 buffer:= getinfo('serverinfo',[isc_info_svc_version,
            isc_info_svc_server_version,isc_info_svc_implementation,
            isc_info_svc_capabilities,isc_info_svc_user_dbpath,
            isc_info_svc_get_env,isc_info_svc_get_env_lock,
            isc_info_svc_get_env_msg]);
 po1:= pointer(buffer);
 with result do begin
  version:= getvalueitem(po1,isc_info_svc_version);
  server_version:= getstringitem(po1,isc_info_svc_server_version);
  _implementation:= getstringitem(po1,isc_info_svc_implementation);
  capabilities:= getvalueitem(po1,isc_info_svc_capabilities);
  user_dbpath:= getstringitem(po1,isc_info_svc_user_dbpath);
  get_env:= getstringitem(po1,isc_info_svc_get_env);
  get_env_lock:= getstringitem(po1,isc_info_svc_get_env_lock);
  get_env_msg:= getstringitem(po1,isc_info_svc_get_env_msg);
 end;
end;

end.
