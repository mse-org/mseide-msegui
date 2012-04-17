{ MSEgui Copyright (c) 2007-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msessl;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,msecryptio,mseopenssl,mseopensslevp,
 msestrings,msesystypes,msecryptohandler,msetypes,
 msestream;
type
 
 essl = class(ecryptoio)
 end;
  
 ssldataty = record
  ssl: pssl;
  mutex: mutexty;  
 end;

 sslinfoty = record
  case integer of
   0: (d: ssldataty);
   1: (_bufferspace: cryptodataty);
 end;
 {$if sizeof(ssldataty) > sizeof(cryptodataty)}
  {$error 'buffer overflow'}
 {$endif}
 
 sslprotocolty = (ssp_sslv2,ssp_sslv3,ssp_tlsv1);
 sslprotocolsty = set of sslprotocolty;
const
 defaultsslprotocols = [ssp_sslv2,ssp_sslv3,ssp_tlsv1];
 defaultcipherlist = 'DEFAULT';
 defaultkeygeniterationcount = 5;
 
type

 tssl = class(tcryptoio)
  private
   fctx: pssl_ctx;
   fprotocols: sslprotocolsty;
   fcipherlist: tstringlist;
   fcertfile: filenamety;
   fprivkeyfile: filenamety;
   procedure ctxchanged;
   procedure setcipherlist(const avalue: tstringlist);
  protected
   class procedure internalunlink(var ainfo: cryptoioinfoty); override;
   class procedure internalthreadterminate; override;
   class procedure connect(var ainfo: cryptoioinfoty; const atimeoutms: integer);  override;
   class procedure accept(var ainfo: cryptoioinfoty; const atimeoutms: integer);  override;
   class function write(var ainfo: cryptoioinfoty; const buffer: pointer;
           const count: integer; const atimeoutms: integer): integer; override;
   class function read(var ainfo: cryptoioinfoty; const buffer: pointer; const count: integer; 
                  const atimeoutms: integer): integer; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure link(const arxfd,atxfd: integer; out ainfo: cryptoioinfoty); override;
  published
   property protocols: sslprotocolsty read fprotocols write fprotocols default
                                   defaultsslprotocols;
   property cipherlist: tstringlist read fcipherlist write setcipherlist;
   property certfile: filenamety read fcertfile write fcertfile;
   property privkeyfile: filenamety read fprivkeyfile write fprivkeyfile;
 end;

 cipherkindty = (ckt_stream, 
                 ckt_ecb, //electronic codebook
                 ctk_cbc, //cipher-block chaining
                 ctk_cfb, //cipher feedback
                 ctk_ofb);//output feedback

 sslhandlerdatadty = record
  ctx: pevp_cipher_ctx;
  cipher: pevp_cipher;
  digest: pevp_md;
//  kind: cipherkindty;
 end;
 psslhandlerdataty = ^sslhandlerdataty;
 {$if sizeof(sslhandlerdatadty) > sizeof(cryptohandlerdataty)} 
  {$error 'buffer overflow'}
 {$endif}
 sslhandlerdataty = record
  case integer of
   0: (d: sslhandlerdatadty;);
   1: (_bufferspace: cryptohandlerdataty;);
 end;

//
// under construction!
// 
 cryptoerrorty = (cerr_error,cerr_ciphernotfound,cerr_notseekable,
                  cerr_cipherinit,cerr_invalidopenmode,cerr_digestnotfound,
                  cerr_cannotwrite,cerr_invalidblocksize);

 getkeyeventty = procedure(const sender: tobject;
                                var akey,asalt: string) of object;

 tsslcryptohandler = class(tbasecryptohandler)
  private
   fciphername: string;
   fkeydigestname: string;
   fkeyiterationcount: integer;
   fkey: string;
   fsalt: string;
   fkeyphrase: msestring;
   fongetkey: getkeyeventty;
   procedure setkeyphrase(const avalue: msestring);
  protected
   procedure error(const err: cryptoerrorty);
   procedure checkerror(const err: cryptoerrorty = cerr_error);
   procedure clearerror; inline;
   function checknullerror(const avalue: integer;
                   const err: cryptoerrorty = cerr_error): integer; inline;
   function checknilerror(const avalue: pointer;
                   const err: cryptoerrorty = cerr_error): pointer; inline;
   procedure open(var aclient: cryptoclientinfoty); override;
   procedure close(var aclient: cryptoclientinfoty);  override;
   function read(var aclient: cryptoclientinfoty;
                   var buffer; count: longint): longint; override;
   function write(var aclient: cryptoclientinfoty;
                   const buffer; count: longint): longint; override;
   function seek(var aclient: cryptoclientinfoty;
                   const offset: int64; origin: tseekorigin): int64; override;
   procedure getkey(out akey: string; out asalt: string); virtual;
   procedure finalizedata(var adata: sslhandlerdatadty);
  public
   constructor create(aowner: tcomponent); override;
   property key: string read fkey write fkey;
   property salt: string read fsalt write fsalt;
  published
   property ciphername: string read fciphername write fciphername;
   property keydigestname: string read fkeydigestname write fkeydigestname;
                         //default md5
   property keyiterationcount: integer read fkeyiterationcount 
                 write fkeyiterationcount default defaultkeygeniterationcount;
   property keyphrase: msestring read fkeyphrase write setkeyphrase;
   property ongetkey: getkeyeventty read fongetkey write fongetkey;
 end;
 
function waitforio(const aerror: integer; var ainfo: cryptoioinfoty; 
              const atimeoutms: integer; const resultpo: pinteger = nil): boolean;
 
implementation
uses
 sysutils,msesysintf1,msefileutils,msesocketintf,msesys,mseopensslbio;
const
 cryptoerrormessages: array[cryptoerrorty] of msestring =(
  'OpenSSL error.',
  'Cipher not found.',
  'Stream not seekable.',
  'Can not cipher init.',
  'Invalid open mode.',
  'Digest not found.',
  'Can not write.',
  'Invalid block size.'
  );
 
procedure raiseerror(errco : integer);
var
 buf: array [0..255] of char;
 str1: string;
begin
 str1:= 'SSL error.';
 repeat
  err_error_string_n(errco,@buf,sizeof(buf));
  str1:= str1 + lineend + buf;
  errco:= err_get_error();
 until errco = 0;
 raise essl.create(str1);
end;

procedure sslerror(const aerror: integer);
begin
 if aerror <> 1 then begin
  raiseerror(err_get_error());
 end;
end;

{ tssl }

constructor tssl.create(aowner: tcomponent);
begin
 fprotocols:= defaultsslprotocols;
 fcipherlist:= tstringlist.create;
 fcipherlist.text:= defaultcipherlist;
 inherited;
end;

destructor tssl.destroy;
begin
 inherited;
 if fctx <> nil then begin
  ssl_ctx_free(fctx);
  fctx:= nil;
 end;
 fcipherlist.free;
end;

procedure tssl.ctxchanged;
begin
 if fctx <> nil then begin
  
 end;
end;

procedure tssl.link(const arxfd,atxfd: integer; out ainfo: cryptoioinfoty);
var
 int1: integer;
 str1: string;
begin
 inherited;
 if fctx = nil then begin
  initsslinterface;
  fctx:= ssl_ctx_new(sslv23_method());
  if fctx = nil then begin
   sslerror(0);
  end;
  ctxchanged;
 end;
 with ainfo,sslinfoty(cryptodata).d do begin
  ssl:= ssl_new(fctx);
  if ssl = nil then begin
   sslerror(0);
  end;
  sys_mutexcreate(mutex);
  int1:= 0;
  if not (ssp_sslv2 in fprotocols) then begin
   int1:= int1 or ssl_op_no_sslv2;
  end;
  if not (ssp_sslv3 in fprotocols) then begin
   int1:= int1 or ssl_op_no_sslv3;
  end;
  if not (ssp_tlsv1 in fprotocols) then begin
   int1:= int1 or ssl_op_no_tlsv1;
  end;
  if int1 <> 0 then begin
   ssl_set_options(ssl,int1);
  end;
  str1:= '';
  for int1:= 0 to fcipherlist.count - 1 do begin
   str1:= str1 + fcipherlist[int1] + ':';
  end;
  setlength(str1,length(str1)-1);
  sslerror(ssl_set_cipher_list(ssl,pchar(str1)));
  if fcertfile <> '' then begin
   str1:= tosysfilepath(filepath(fcertfile));
   sslerror(ssl_use_certificate_file(ssl,pchar(str1),ssl_filetype_pem));
  end;
  if fprivkeyfile <> '' then begin
   str1:= tosysfilepath(filepath(fprivkeyfile));
   sslerror(ssl_use_privatekey_file(ssl,pchar(str1),ssl_filetype_pem));
  end;
  sslerror(ssl_set_rfd(ssl,rxfd));
  sslerror(ssl_set_wfd(ssl,txfd));
 end; 
end;

class procedure tssl.internalunlink(var ainfo: cryptoioinfoty);
begin //todo: shutdown
 with ainfo,sslinfoty(cryptodata).d do begin
  if ssl <> nil then begin
   ssl_free(ssl);
  end;
  sys_mutexdestroy(mutex);
 end;
 inherited;
end;

class procedure tssl.internalthreadterminate;
begin
 err_remove_state(0);
 inherited;
end;

function {tssl.}waitforio(const aerror: integer; var ainfo: cryptoioinfoty; 
       const atimeoutms: integer; const resultpo: pinteger = nil): boolean;
var
 int1: integer;
 err1: syserrorty;
 pollres: pollkindsty;
begin
 with ainfo,sslinfoty(cryptodata).d do begin
  sys_mutexunlock(mutex);
  result:= (aerror > 0);
  if not result then begin
   if aerror < 0 then begin
    err1:= sye_ok;
    int1:= ssl_get_error(ssl,aerror);
    if (int1 = ssl_error_want_read) then begin
     if atimeoutms >= 0 then begin
      err1:= soc_poll(rxfd,[poka_read],atimeoutms,pollres);
     end;
    end
    else begin
     if (int1 = ssl_error_want_write) then begin
      if atimeoutms >= 0 then begin
       err1:= soc_poll(txfd,[poka_write],atimeoutms,pollres);
      end;
     end
     else begin
      raiseerror(int1);
     end;
    end;
    if err1 <> sye_ok then begin
     syserror(err1);
    end;
   end
   else begin
    sslerror(aerror);
   end;
  end;
 end;
 if resultpo <> nil then begin
  if (atimeoutms < 0) and (aerror < 0) then begin
   resultpo^:= 0;
  end
  else begin
   resultpo^:= aerror;
  end;
 end;
end;

class procedure tssl.connect(var ainfo: cryptoioinfoty;
                                              const atimeoutms: integer);
//var
// int1,int2: integer;
// err1: syserrorty;
begin
 with ainfo,sslinfoty(cryptodata).d do begin
  repeat
   sys_mutexlock(mutex);
  until waitforio(ssl_connect(ssl),ainfo,atimeoutms);
 end;
end;

class procedure tssl.accept(var ainfo: cryptoioinfoty;
                                                 const atimeoutms: integer);
//var
// int1{,int2}: integer;
// err1: syserrorty;
begin
 with ainfo,sslinfoty(cryptodata).d do begin
  repeat
   sys_mutexlock(mutex);
  until waitforio(ssl_accept(ssl),ainfo,atimeoutms);
 end;
end;

procedure tssl.setcipherlist(const avalue: tstringlist);
begin
 fcipherlist.assign(avalue);
end;

class function tssl.write(var ainfo: cryptoioinfoty; const buffer: pointer;
               const count: integer; const atimeoutms: integer): integer;
begin
 with ainfo,sslinfoty(cryptodata).d do begin
  try
   repeat
    sys_mutexlock(mutex);
   until waitforio(ssl_write(ssl,buffer,count),ainfo,atimeoutms,@result);
  except
   result:= -1;
  end;
 end;
end;

class function tssl.read(var ainfo: cryptoioinfoty; const buffer: pointer;
               const count: integer; const atimeoutms: integer): integer;
var
 pollres: pollkindsty;
begin
 result:= 0;
 with ainfo,sslinfoty(cryptodata).d do begin
  try
   if (atimeoutms < 0) or 
    (soc_poll(ainfo.rxfd,[poka_read],atimeoutms,pollres) = sye_ok) then begin
    repeat
     sys_mutexlock(mutex);
    until waitforio(ssl_read(ssl,buffer,count),ainfo,atimeoutms,@result) or 
            (atimeoutms < 0);
   end;
  except
   result:= -1;
  end;
 end;
end;

{ tsslcryptohandler }

constructor tsslcryptohandler.create(aowner: tcomponent);
begin
 fkeydigestname:= 'md5';
 fkeyiterationcount:= defaultkeygeniterationcount;
 inherited;
end;

procedure tsslcryptohandler.finalizedata(var adata: sslhandlerdatadty);
begin
 with adata do begin
  if ctx <> nil then begin
   evp_cipher_ctx_cleanup(ctx);
   freemem(ctx);
   ctx:= nil;
  end;
 end;
end;

var testvar: psslhandlerdataty;
procedure tsslcryptohandler.open(var aclient: cryptoclientinfoty);
var
 mode: integer;
 keydata,ivdata,key1,salt1: string;
begin
testvar:= @sslhandlerdataty(aclient.handlerdata).d;
 initsslinterface;
 case aclient.stream.openmode of
  fm_read: begin
   mode:= 0; //decrypt
  end;
  fm_create,fm_write: begin
   mode:= 1; //encrypt
  end;
  else begin
   error(cerr_invalidopenmode); //todo: allow append
  end;
 end;
 with sslhandlerdataty(aclient.handlerdata).d do begin
  getmem(ctx,sizeof(ctx^));
  evp_cipher_ctx_init(ctx);
  cipher:= checknilerror(evp_get_cipherbyname(pchar(fciphername)),
                                                     cerr_ciphernotfound);
  if (mode = 0) and (cipher^.block_size > 1) then begin
   finalizedata(sslhandlerdataty(aclient.handlerdata).d);
   error(cerr_invalidblocksize); //todo: implement block ciphers
  end;
  digest:= checknilerror(evp_get_digestbyname(pchar(fkeydigestname)),
                                                     cerr_digestnotfound);
  checknullerror(evp_cipherinit_ex(ctx,cipher,nil,nil,nil,mode),
                                          cerr_cipherinit);
  setlength(keydata,ctx^.key_len);
  setlength(ivdata,cipher^.iv_len);
  getkey(key1,salt1);
  if salt1 <> '' then begin
   salt1:= salt1 + nullstring(8-length(salt1));
  end;
  checknullerror(evp_bytestokey(cipher,digest,pointer(salt1),pchar(key1),
            length(key1),fkeyiterationcount,pointer(keydata),pointer(ivdata)));
  checknullerror(evp_cipherinit_ex(ctx,nil,nil,pointer(keydata),
                     pointer(ivdata),mode),cerr_cipherinit);
 end;
 inherited;
end;

procedure tsslcryptohandler.close(var aclient: cryptoclientinfoty);
var
 buffer: array[0..evp_max_block_length-1] of byte;
 int1: integer;
begin
 try
  with sslhandlerdataty(aclient.handlerdata).d do begin
   if ctx <> nil then begin
    if aclient.stream.openmode in [fm_write] then begin
     checknullerror(evp_cipherfinal(ctx,@buffer,int1));
     if int1 > 0 then begin
      if inherited write(aclient,buffer,int1) <> int1 then begin
       error(cerr_cannotwrite);
      end;
     end;
    end
    else begin
     checknullerror(evp_cipherfinal(ctx,@buffer,int1));
    end;
   end;
  end;
 finally
  finalizedata(sslhandlerdataty(aclient.handlerdata).d);
  inherited;
 end;
end;

function tsslcryptohandler.read(var aclient: cryptoclientinfoty; var buffer;
               count: longint): longint;
var
 po1: pointer;
 int1: integer;
begin
 if count > 0 then begin
  with sslhandlerdataty(aclient.handlerdata).d do begin
   getmem(po1,count+ctx^.cipher^.block_size);
   result:= inherited read(aclient,po1^,count);
   try       //todo: implement block cipher
    checknullerror(evp_cipherupdate(ctx,@buffer,int1,po1,result));
   finally
    freemem(po1);
   end;
  end;
 end
 else begin
  result:= inherited read(aclient,buffer,count);
 end;
end;

function tsslcryptohandler.write(var aclient: cryptoclientinfoty; const buffer;
               count: longint): longint;
var
 po1: pointer;
 int1: integer;
begin
 if count > 0 then begin
  with sslhandlerdataty(aclient.handlerdata).d do begin
   getmem(po1,count+ctx^.cipher^.block_size);
   try
    checknullerror(evp_cipherupdate(ctx,po1,int1,@buffer,count));
    result:= inherited write(aclient,po1^,int1);
    if result = int1 then begin
     result:= count;
    end;
   finally
    freemem(po1);
   end;
  end;
 end
 else begin
  result:= inherited write(aclient,buffer,count);
 end;
end;

function tsslcryptohandler.seek(var aclient: cryptoclientinfoty;
               const offset: int64; origin: tseekorigin): int64;
begin
 if offset <> 0 then begin //todo
  error(cerr_notseekable);
 end
 else begin
  result:= inherited seek(aclient,offset,origin);
 end;
end;

procedure tsslcryptohandler.checkerror(const err: cryptoerrorty);
const
 buffersize = 200;
var
 int1: integer;
 str1,str2: string;
begin
 str1:= '';
 setlength(str2,buffersize);
 while true do begin
  int1:= err_get_error();
  if int1 = 0 then begin
   break;
  end;
  err_error_string_n(int1,pointer(str2),buffersize);
  if str1 = '' then begin
   str1:= str1 + lineend;
  end;
  str1:= str1 + pchar(str2);
 end;
 if str1 <> '' then begin
  essl.create(cryptoerrormessages[err]+lineend+str1);
 end;
end;

procedure tsslcryptohandler.clearerror;
begin
 err_clear_error();
end;

function tsslcryptohandler.checknullerror(const avalue: integer;
                                          const err: cryptoerrorty): integer;
begin
 result:= avalue;
 if avalue = 0 then begin
  checkerror(err);
  error(err);
 end;
end;

function tsslcryptohandler.checknilerror(const avalue: pointer;
                                         const err: cryptoerrorty): pointer;
begin
 result:= avalue;
 if avalue = nil then begin
  checkerror(err);
  error(err);
 end;
end;

procedure tsslcryptohandler.error(const err: cryptoerrorty);
begin
 raise essl.create(cryptoerrormessages[err]); 
           //there was no queued error
end;

procedure tsslcryptohandler.setkeyphrase(const avalue: msestring);
begin
 fkey:= stringtoutf8(avalue);
 fkeyphrase:= avalue;
end;

procedure tsslcryptohandler.getkey(out akey: string; out asalt: string);
begin
 akey:= fkey;
 asalt:= fsalt;
 if canevent(tmethod(fongetkey)) then begin
  fongetkey(self,akey,asalt);
 end;
end;

end.
