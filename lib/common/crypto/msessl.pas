{ MSEgui Copyright (c) 2007-2013 by Martin Schreiber

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
 classes,mclasses,msecryptio,mseopenssl,mseopensslevp,mseopensslrand,
 msestrings,msesystypes,msecryptohandler,msetypes,msesys,
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
 {$ifend}
 
 sslprotocolty = (ssp_sslv2,ssp_sslv3,ssp_tlsv1);
 sslprotocolsty = set of sslprotocolty;
const
 defaultsslprotocols = [ssp_sslv2,ssp_sslv3,ssp_tlsv1];
 defaultcipherlist = 'DEFAULT';
 defaultkeygeniterationcount = 1{5}; //same as openssl enc
 
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
   class procedure connect(var ainfo: cryptoioinfoty;
                                       const atimeoutms: integer);  override;
   class procedure accept(var ainfo: cryptoioinfoty; const atimeoutms: integer);  override;
   class function write(var ainfo: cryptoioinfoty; const buffer: pointer;
           const count: integer; const atimeoutms: integer): integer; override;
   class function read(var ainfo: cryptoioinfoty; const buffer: pointer;
           const count: integer; const atimeoutms: integer): integer; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure link(const arxfd,atxfd: integer;
                                out ainfo: cryptoioinfoty); override;
  published
   property protocols: sslprotocolsty read fprotocols write fprotocols
                                                default defaultsslprotocols;
   property cipherlist: tstringlist read fcipherlist write setcipherlist;
   property certfile: filenamety read fcertfile write fcertfile;
   property privkeyfile: filenamety read fprivkeyfile write fprivkeyfile;
 end;

 digeststatety = (ds_inited{,ds_final});
 digeststatesty = set of digeststatety;
 
 digesthandlerdatadty = record
  ctx: pevp_md_ctx;
  md: pevp_md;
  state: digeststatesty;
//  digest: pointer; //string
 end;
 pdigesthandlerdatadty = ^digesthandlerdatadty;
 {$if sizeof(digesthandlerdatadty) > sizeof(cryptohandlerdataty)} 
  {$error 'buffer overflow'}
 {$ifend}
 digesthandlerdataty = record
  case integer of
   0: (d: digesthandlerdatadty;);
   1: (_bufferspace: cryptohandlerdataty;);
 end;
 
 tdigesthandler = class;
 
// digesteventty = procedure(const sender: tdigesthandler;
//           const astream: tmsefilestream; const adigest: string) of object;

 tdigesthandler = class(tbasecryptohandler)
  private
   fdigestname: string;
//   fondigest: digesteventty;
  protected
//   procedure finalizeclient(var aclient: cryptoclientinfoty); override;
//   procedure dofinal(var aclient: cryptoclientinfoty);
   procedure checkerror(const err: cryptoerrorty = cerr_error); override;
   procedure open(var aclient: cryptoclientinfoty); override;
   procedure close(var aclient: cryptoclientinfoty); override;
   function read(var aclient: cryptoclientinfoty;
                   var buffer; count: longint): longint; override;
   function write(var aclient: cryptoclientinfoty;
                   const buffer; count: longint): longint; override;
   function seek(var aclient: cryptoclientinfoty;
                   const offset: int64; origin: tseekorigin): int64; override;
   procedure restartdigest(var aclient: cryptoclientinfoty);
  public
   function digest(const astream: tmsefilestream): string;
  published
   property digestname: string read fdigestname write fdigestname;
//   property ondigest: digesteventty read fondigest write fondigest;
 end;
 
 cipherkindty = (ckt_stream, 
                 ckt_ecb, //electronic codebook
                 ctk_cbc, //cipher-block chaining
                 ctk_cfb, //cipher feedback
                 ctk_ofb);//output feedback

// padbufty = array[0..3*evp_max_block_length-1] of byte;
 keybufty = array[0..evp_max_key_length-1] of byte;
 ivbufty = array[0..evp_max_iv_length-1] of byte;
// blockbufty = array[0..evp_max_block_length-1] of byte;

 sslhandlerdatadty = record
  p: paddedhandlerdatadty;
  ctx: pevp_cipher_ctx;
  cipher: pevp_cipher;
  digest: pevp_md;
  keybuf: ^keybufty;
  ivbuf: ^ivbufty;
 end;
 psslhandlerdatadty = ^sslhandlerdatadty;
 {$if sizeof(sslhandlerdatadty) > sizeof(cryptohandlerdataty)} 
  {$error 'buffer overflow'}
 {$ifend}
 sslhandlerdataty = record
  case integer of
   0: (d: sslhandlerdatadty;);
   1: (_bufferspace: cryptohandlerdataty;);
 end;

 getkeyeventty = procedure(const sender: tobject;
                                var akey,asalt: string) of object;

 opensslcryptooptionty = (sslco_salt,sslco_canrestart); 
                                     //stores key and iv for seek(0)
 opensslcryptooptionsty = set of opensslcryptooptionty;
const
 defaultopensslcryptooptions = [sslco_salt];
 
type 
 tcustomopensslcryptohandler = class(tpaddedcryptohandler)
  private
   fciphername: string;
   fkey: string;
   fsalt: string;
   fkeyphrase: msestring;
   fongetkey: getkeyeventty;
   fkeylength: integer;
   foptions: opensslcryptooptionsty;
   procedure setkeyphrase(const avalue: msestring);
  protected
   procedure clearerror; {$ifdef FPC}inline;{$endif}
   procedure checkerror(const err: cryptoerrorty = cerr_error); override;
   procedure cipherupdate(var aclient: cryptoclientinfoty;
          const source: pbyte; const sourcelen: integer;
          const dest: pbyte; out destlen: integer); override;
   procedure cipherfinal(var aclient: cryptoclientinfoty;
             const dest: pbyte; out destlen: integer); override;
   procedure initcipher(var aclient: cryptoclientinfoty); virtual; abstract;
   procedure restartcipher(var aclient: cryptoclientinfoty); override;
   procedure getkey(out akey: string; out asalt: string); virtual;
   procedure initializedata(var aclient: cryptoclientinfoty); override;
   procedure finalizedata(var aclient: cryptoclientinfoty); override;
   function padbufsize: integer; override;
  public
   constructor create(aowner: tcomponent); override;
   property key: string read fkey write fkey;
   property options: opensslcryptooptionsty read foptions 
                             write foptions default defaultopensslcryptooptions;
   property ciphername: string read fciphername write fciphername;
   property keyphrase: msestring read fkeyphrase write setkeyphrase;
   property keylength: integer read fkeylength write fkeylength default 0;
                                          //bits, 0 -> use cipher default
   property ongetkey: getkeyeventty read fongetkey write fongetkey;
 end;
{
 asymkeyfileheader = record
  symkeylen: integer;
  symkey: array[0..0] of byte; //encrypted, variable length
  iv: array[0..0] of byte; //variable length, cipher dependent
 end;
}
 tsymciphercryptohandler = class(tcustomopensslcryptohandler)
  private
   fkeydigestname: string;
   fkeygeniterationcount: integer;
  protected
   procedure initcipher(var aclient: cryptoclientinfoty); override;
  published
   constructor create(aowner: tcomponent); override;
   property salt: string read fsalt write fsalt;
   property keydigestname: string read fkeydigestname write fkeydigestname;
                         //default md5
   property keygeniterationcount: integer read fkeygeniterationcount 
                 write fkeygeniterationcount default defaultkeygeniterationcount;
   property options;
   property ciphername;
//   property keydigestname;
//   property keygeniterationcount;
   property keyphrase;
   property keylength;
   property ongetkey;
 end;

 tasymciphercryptohandler = class(tcustomopensslcryptohandler)
  private
   fprivkeyfile: filenamety;
   fpubkeyfile: filenamety;
  protected
   procedure initcipher(var aclient: cryptoclientinfoty); override;
  published
   property privkeyfile: filenamety read fprivkeyfile write fprivkeyfile;
   property pubkeyfile: filenamety read fpubkeyfile write fpubkeyfile;
                      //use '"first" "second" "third"' for multiple
   property options;
   property ciphername;
//   property keydigestname;
//   property keygeniterationcount;
   property keyphrase;
   property keylength;
   property ongetkey;
 end;

getkeydataeventty = procedure(out akey: string; out asalt: string) of object;
 
function waitforio(const aerror: integer; var ainfo: cryptoioinfoty; 
              const atimeoutms: integer;
                                const resultpo: pinteger = nil): boolean;
function filebio(const aname: filenamety;
                                const aopenmode: fileopenmodety): pbio;
procedure closebio(const abio: pbio);
function readpubkey(const aname: filenamety): pevp_pkey;
function readprivkey(const aname: filenamety;
                          const getkey: getkeydataeventty): pevp_pkey;
procedure freekey(const akey: pevp_pkey);
function messagedigest(const adata: string; const digestname: string): string;
 
implementation
uses
 sysutils,msesysintf1,msefileutils,msesocketintf,mseopensslbio,mseopensslpem,
 mseopensslrsa,msebits,
 msesysintf,msectypes;

procedure raisesslerror(const err: cryptoerrorty);
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
  if str1 <> '' then begin
   str1:= str1 + lineend;
  end;
  str1:= str1 + pchar(str2);
 end;
 if str1 <> '' then begin
  raise essl.create(ansistring(cryptoerrormessages[err])+lineend+str1);
 end;
end;

procedure raiseerror(errco : integer; const amessage: string = '');
var
 buf: array [0..255] of char;
 str1: string;
begin
 if amessage = '' then begin
  str1:= 'SSL error.';
 end
 else begin
  str1:= amessage;
 end;
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

procedure cryptoerror(const aerror: cryptoerrorty);
var
 int1: integer;
begin
 int1:= err_get_error();
 if int1 <> 0 then begin
  raiseerror(int1,ansistring(cryptoerrormessages[aerror]));
 end;
end;

function filebio(const aname: filenamety;
                                    const aopenmode: fileopenmodety): pbio;
var
 str1,str2: string;
begin
 str1:= stringtoutf8ansi(tosysfilepath(filepath(aname)));
 case aopenmode of
  fm_write: begin
   str2:= 'a+';      //-> append, not supported
  end;
  fm_readwrite: begin
   str2:= 'r+';
  end;
  fm_create: begin
   str2:= 'w+';
  end;
  fm_append: begin
   str2:= 'a+';       //sets write filepointer to end!
  end
  else begin
   str2:= 'r'; //fm_read, fm none
  end;
 end;
 result:= bio_new_file(pchar(str1),pchar(str2));
 if result = nil then begin
  cryptoerror(cerr_nobio);
 end;
end;
{
function filebio(const aname: filenamety;
                                    const aopenmode: fileopenmodety): pbio;
var
 fd: integer;
begin
 syserror(sys_openfile(aname,aopenmode,[],[],fd));
 result:= bio_new_fd(fd,1);
 if result = nil then begin
  cryptoerror(cerr_nobio);
 end;
end;
}
{
function streambio(const aname: filenamety;
                                   const aopenmode: fileopenmodety): pbio;
var
 fd: integer;
 file1: pfile;
 str1: string;
begin
 syserror(sys_openfile(aname,aopenmode,[],[],fd));
 file1:= fdopen(fd,pchar(str1);
 if file1 = nil then begin
  syserror(syelasterror);
 end;
 bio_new(bio_s_file);
 if bio_set
end;
}
procedure closebio(const abio: pbio);
begin
 bio_free_all(abio);
end;

function readpubkey(const aname: filenamety): pevp_pkey;
var
 bio: pbio;
begin
 bio:= filebio(aname,fm_read);
 result:= pem_read_bio_pubkey(bio,nil,nil,nil);
 closebio(bio);
 if result = nil then begin
  cryptoerror(cerr_nopubkey);
 end;
end;

function cb(buf: pcuchar; size: cint; rwflag: cint; u: pointer): cint; cdecl;
var
 key,iv: string;
begin
 getkeydataeventty(u^)(key,iv);
 if length(key) > size then begin
  setlength(key,size);
 end;
 result:= length(key);
 move(key[1],buf^,result);
end;

function readprivkey(const aname: filenamety;
                          const getkey: getkeydataeventty): pevp_pkey;
var
 bio: pbio;
begin
 bio:= filebio(aname,fm_read);
 result:= pem_read_bio_privatekey(bio,nil,@cb,@getkey);
 closebio(bio);
 if result = nil then begin
  cryptoerror(cerr_noprivkey);
 end;
end;

procedure freekey(const akey: pevp_pkey);
begin
 if akey <> nil then begin
  evp_pkey_free(akey);
 end;
end;

function checknilerror(const avalue: pointer;
                  const err: cryptoerrorty = cerr_error): pointer;
                        {$ifdef FPC} inline;{$endif}
begin
 result:= avalue;
 if avalue = nil then begin
  raisesslerror(err);
 end;
end;

function checknullerror(const avalue: integer;
                  const err: cryptoerrorty = cerr_error): integer;
                        {$ifdef FPC} inline;{$endif}
begin
 result:= avalue;
 if avalue = 0 then begin
  raisesslerror(err);
 end;
end;

function messagedigest(const adata: string; const digestname: string): string;
var
 ctx: pevp_md_ctx;
 md: pevp_md;
 int1: integer;
 str1: string;
begin
 initsslinterface;
 ctx:= checknilerror(evp_md_ctx_create());
 try
  md:= checknilerror(evp_get_digestbyname(pointer(pchar(digestname))));
  checknullerror(evp_digestinit_ex(ctx,md,nil));
  checknullerror(evp_digestupdate(ctx,pointer(adata),length(adata)));
  setlength(str1,evp_max_md_size);
  checknullerror(evp_digestfinal_ex(ctx,pointer(str1),cardinal(int1)));
  setlength(str1,int1);
  result:= str1;
 finally
  evp_md_ctx_destroy(ctx);
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
   str1:= ansistring(tosysfilepath(filepath(fcertfile)));
   sslerror(ssl_use_certificate_file(ssl,pchar(str1),ssl_filetype_pem));
  end;
  if fprivkeyfile <> '' then begin
   str1:= ansistring(tosysfilepath(filepath(fprivkeyfile)));
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

{ tcustomopensslcryptohandler }

constructor tcustomopensslcryptohandler.create(aowner: tcomponent);
begin
 foptions:= defaultopensslcryptooptions;
 inherited;
end;

procedure tcustomopensslcryptohandler.clearerror;
begin
 err_clear_error();
end;

procedure tcustomopensslcryptohandler.checkerror(const err: cryptoerrorty);
begin
 raisesslerror(err);
end;

procedure tcustomopensslcryptohandler.initializedata(
                                    var aclient: cryptoclientinfoty);
var
 int1: integer;
begin
 inherited;
 initsslinterface;
 with sslhandlerdataty(aclient.handlerdata).d do begin
  getmem(ctx,sizeof(ctx^));
  evp_cipher_ctx_init(ctx);
  getmem(keybuf,sizeof(keybuf^));
  getmem(ivbuf,sizeof(ivbuf^));

  cipher:= checknilerror(evp_get_cipherbyname(pcchar(pchar(fciphername))),
                                                     cerr_ciphernotfound);
  checknullerror(evp_cipherinit_ex(ctx,cipher,nil,nil,nil,p.mode),
                                          cerr_cipherinit);
  if fkeylength <> 0 then begin
   int1:= fkeylength div 8;
   if int1 > evp_max_key_length then begin
    error(cerr_invalidkeylength);
   end;
   checknullerror(evp_cipher_ctx_set_key_length(ctx,int1));
   if (ctx^.key_len * 8 <> fkeylength) then begin
    error(cerr_invalidkeylength);
   end;
  end;
{  if (mode = 0) and (cipher^.block_size > 1) then begin
   finalizedata(sslhandlerdataty(aclient.handlerdata).d);
   error(cerr_invalidblocksize); //todo: implement block ciphers
  end;
}
  initcipher(aclient);
  p.blocksize:= ctx^.cipher^.block_size;
  if not (sslco_canrestart in foptions) then begin
   fillchar(keybuf^,sizeof(keybuf^),0);
   fillchar(ivbuf^,sizeof(ivbuf^),0);
  end;
 end;
end;

procedure tcustomopensslcryptohandler.finalizedata(
                                            var aclient: cryptoclientinfoty);
var
 data1: psslhandlerdatadty;
begin
 inherited;
 data1:= @sslhandlerdataty(aclient.handlerdata).d;
 with data1^ do begin
  if ctx <> nil then begin
   evp_cipher_ctx_cleanup(ctx);
   freemem(ctx);
  end;
  if keybuf <> nil then begin
   fillchar(keybuf^,sizeof(keybuf^),0);  
   freemem(keybuf);
  end;
  if ivbuf <> nil then begin
   fillchar(ivbuf^,sizeof(ivbuf^),0);  
   freemem(ivbuf);
  end;
 end;
 fillchar(data1^,sizeof(data1^),0);
end;

procedure tcustomopensslcryptohandler.restartcipher(
                                      var aclient: cryptoclientinfoty);
begin
 if not (sslco_canrestart in foptions) then begin
  error(cerr_cannotrestart);
 end;
 inherited;
 with sslhandlerdataty(aclient.handlerdata).d do begin
  checknullerror(evp_cipherinit_ex(ctx,nil,nil,pointer(keybuf),
                               pointer(ivbuf),p.mode),cerr_cipherinit);
  ctx^.iv:= ctx^.iov;
 end;
end;

procedure tcustomopensslcryptohandler.setkeyphrase(const avalue: msestring);
begin
 fkey:= stringtoutf8ansi(avalue);
 fkeyphrase:= avalue;
end;

procedure tcustomopensslcryptohandler.getkey(out akey: string; out asalt: string);
begin
 akey:= fkey;
 asalt:= fsalt;
 if canevent(tmethod(fongetkey)) then begin
  fongetkey(self,akey,asalt);
 end;
end;

procedure tcustomopensslcryptohandler.cipherupdate(
               var aclient: cryptoclientinfoty;const source: pbyte;
               const sourcelen: integer; const dest: pbyte;
               out destlen: integer);
begin
 with sslhandlerdataty(aclient.handlerdata).d do begin
  checknullerror(evp_cipherupdate(ctx,pointer(dest),destlen,
                                               pointer(source),sourcelen));
 end;
end;

procedure tcustomopensslcryptohandler.cipherfinal(
               var aclient: cryptoclientinfoty;
               const dest: pbyte; out destlen: integer);
begin
 with sslhandlerdataty(aclient.handlerdata).d do begin
  checknullerror(evp_cipherfinal(ctx,pcuchar(dest),destlen));
 end;
end;

function tcustomopensslcryptohandler.padbufsize: integer;
begin
 result:= 3*evp_max_block_length;
end;

{ tsymciphercryptohandler}

constructor tsymciphercryptohandler.create(aowner: tcomponent);
begin
 fkeydigestname:= 'md5';
 fkeygeniterationcount:= defaultkeygeniterationcount;
 inherited;
end;

procedure tsymciphercryptohandler.initcipher(var aclient: cryptoclientinfoty);
const
 salttag = 'Salted__';
 taglength = length(salttag);
 saltlength = 8;
 headerlength = taglength + saltlength;
var
// keydata: keybufty;
// ivdata: ivbufty;
 key1,salt1: string;
begin
 with sslhandlerdataty(aclient.handlerdata).d do begin
  digest:= checknilerror(evp_get_digestbyname(pcchar(pchar(fkeydigestname))),
                                                     cerr_digestnotfound);
  getkey(key1,salt1);
  if key1 = '' then begin
   error(cerr_nokey);
  end;
  if salt1 <> '' then begin
   salt1:= salt1 + nullstring(8-length(salt1));
  end;
  if sslco_salt in foptions then begin
   if p.mode = 0 then begin
    setlength(salt1,headerlength);
    if (internalread(aclient,pointer(salt1)^,headerlength) <> headerlength) or 
                    (pos(salttag,salt1) <> 1) then begin
     error(cerr_readheader);
    end;
   end
   else begin
    if salt1 = '' then begin
     setlength(salt1,saltlength);
     checknullerror(rand_bytes(pbyte(pointer(salt1)),saltlength));
    end;
    salt1:= salttag+salt1;
    if internalwrite(aclient,pointer(salt1)^,length(salt1)) <> 
                                                 length(salt1) then begin
     error(cerr_writeheader);
    end;
   end;
  end;
  if sslco_salt in foptions then begin
   p.headersize:= headerlength;
  end;
  checknullerror(evp_bytestokey(cipher,digest,
        pointer(pchar(pointer(salt1))+taglength),pointer(key1),
                         length(key1),fkeygeniterationcount,
                                               pointer(keybuf),pointer(ivbuf)));
  checknullerror(evp_cipherinit_ex(ctx,nil,nil,pointer(keybuf),pointer(ivbuf),
                                                  p.mode),cerr_cipherinit);
 end;
end;

{ tasymciphercryptohandler }

procedure tasymciphercryptohandler.initcipher(var aclient: cryptoclientinfoty);
var
 asymkey: pevp_pkey;
 keybuf1: string;
 keydata: string;
// ivdata: ivbufty;
 int1,int2: integer;
begin
 with sslhandlerdataty(aclient.handlerdata).d do begin
  asymkey:= nil;
  try
   if p.mode = 1 then begin //encrypt
    if fpubkeyfile = '' then begin
     error(cerr_nopubkey);
    end;
    asymkey:= readpubkey(fpubkeyfile);
//    setlength(keydata,evp_max_key_length);
    checknullerror(evp_cipher_ctx_rand_key(ctx,pointer(keybuf)));
    if cipher^.iv_len > 0 then begin
     checknullerror(rand_bytes(pointer(ivbuf),cipher^.iv_len));
    end;
    setlength(keybuf1,evp_pkey_size(asymkey));
    int1:= encryptsymkeyrsa(pointer(keybuf1),pointer(keybuf),ctx^.key_len,
                                                                      asymkey);
    if int1 < -1 then begin
     error(cerr_norsakey);
    end;
    if int1 < 0 then begin
     error(cerr_encrypt);
    end;
    if internalwrite(aclient,pointer(keybuf1)^,int1) <> int1 then begin
     error(cerr_writeheader);
    end;
    if cipher^.iv_len > 0 then begin
     if internalwrite(aclient,ivbuf^,cipher^.iv_len) <> 
                                               cipher^.iv_len then begin
      error(cerr_writeheader);
     end;
    end;
   end
   else begin
    if fprivkeyfile = '' then begin
     error(cerr_nopubkey);
    end;
    asymkey:= readprivkey(fprivkeyfile,{$ifdef FPC}@{$endif}getkey);
    if asymkey^._type <> EVP_PKEY_RSA then begin
     error(cerr_norsakey);
    end;
    int1:= evp_pkey_size(asymkey);
    setlength(keybuf1,int1);
    if internalread(aclient,pointer(keybuf1)^,int1) <> int1 then begin
     error(cerr_readheader);
    end;
    setlength(keydata,rsa_size(EVP_PKEY_get1_RSA(asymkey))+2);
    int2:= decryptsymkeyrsa(pointer(keydata),pointer(keybuf1),length(keybuf1),
                                                                     asymkey);
    if (int2 < 0) or (int2 > sizeof(keybuf^)) then begin
     error(cerr_decrypt);
    end;
    checknullerror(evp_cipher_ctx_set_key_length(ctx,int2));
    move(pointer(keydata)^,keybuf^,int2);
    if cipher^.iv_len > 0 then begin
     if internalread(aclient,ivbuf^,cipher^.iv_len) <> 
                                               cipher^.iv_len then begin
      error(cerr_readheader);
     end;
    end;
   end;
   p.headersize:= int1 + cipher^.iv_len;
  finally
   freekey(asymkey);
  end;
  checknullerror(evp_cipherinit_ex(ctx,nil,nil,pointer(keybuf),
                                       pointer(ivbuf),p.mode),cerr_cipherinit);
 end;
end;

{ tdigesthandler }

procedure tdigesthandler.open(var aclient: cryptoclientinfoty);
begin
 inherited;
 initsslinterface;
 with digesthandlerdataty(aclient.handlerdata).d do begin
  ctx:= checknilerror(evp_md_ctx_create());
  md:= checknilerror(evp_get_digestbyname(pointer(pchar(fdigestname))));
  checknullerror(evp_digestinit_ex(ctx,md,nil));
  include(state,ds_inited);
 end;
end;

procedure tdigesthandler.close(var aclient: cryptoclientinfoty);
begin
 inherited;
 with digesthandlerdataty(aclient.handlerdata).d do begin
  if ctx <> nil then begin
   evp_md_ctx_destroy(ctx);
   ctx:= nil;
   state:= [];
  end;
 end; 
end;

function tdigesthandler.read(var aclient: cryptoclientinfoty; var buffer;
               count: longint): longint;
begin
 result:= inherited read(aclient,buffer,count);
 with digesthandlerdataty(aclient.handlerdata).d do begin
  checknullerror(evp_digestupdate(ctx,@buffer,result));
 end;
end;

function tdigesthandler.write(var aclient: cryptoclientinfoty; const buffer;
               count: longint): longint;
begin
 with digesthandlerdataty(aclient.handlerdata).d do begin
  checknullerror(evp_digestupdate(ctx,@buffer,count));
 end;
 result:= inherited write(aclient,buffer,count);
end;

function tdigesthandler.seek(var aclient: cryptoclientinfoty;
               const offset: int64; origin: tseekorigin): int64;
begin
 if (offset <> 0) then begin
  error(cerr_notseekable);
 end;
 result:= inherited seek(aclient,offset,origin);
 if origin = sobeginning then begin
  restartdigest(aclient);
 end;
end;

procedure tdigesthandler.restartdigest(var aclient: cryptoclientinfoty);
begin
 with digesthandlerdataty(aclient.handlerdata).d do begin
  checknullerror(evp_digestinit_ex(ctx,md,nil));
//  exclude(state,ds_final);
 end;
end;

procedure tdigesthandler.checkerror(const err: cryptoerrorty = cerr_error);
begin
 raisesslerror(err);
end;

function tdigesthandler.digest(const astream: tmsefilestream): string;
var
 str1: string;
 int1: integer;
begin
 with digesthandlerdataty(getclient(astream)^.handlerdata).d do begin
  if not (ds_inited in state) then begin
   error(cerr_notactive);
  end;
  setlength(str1,evp_max_md_size);
  checknullerror(evp_digestfinal_ex(ctx,pcuchar(pointer(str1)),cardinal(int1)));
  setlength(str1,int1);
  result:= str1;
  checknullerror(evp_digestinit_ex(ctx,md,nil));
 end;
end;

{
procedure tdigesthandler.finalizeclient(var aclient: cryptoclientinfoty);
begin
 inherited;
 with digesthandlerdataty(aclient.handlerdata).d do begin
  string(digest):= '';
 end;
end;
}
end.
