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
 classes,msecryptio,mseopenssl,mseopensslevp,mseopensslrand,
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
 {$endif}
 
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

 cipherkindty = (ckt_stream, 
                 ckt_ecb, //electronic codebook
                 ctk_cbc, //cipher-block chaining
                 ctk_cfb, //cipher feedback
                 ctk_ofb);//output feedback

 sslhandlerstatety = (sslhs_hasfirstblock,sslhs_eofflag,sslhs_finalized);
 sslhandlerstatesty = set of sslhandlerstatety;
 
 padbufty = array[0..3*evp_max_block_length-1] of byte;
 keybufty = array[0..evp_max_key_length-1] of byte;
 ivbufty = array[0..evp_max_iv_length-1] of byte;
 blockbufty = array[0..evp_max_block_length-1] of byte;
 
 sslhandlerdatadty = record
  mode: integer;
  ctx: pevp_cipher_ctx;
  cipher: pevp_cipher;
  digest: pevp_md;
  headersize: integer;
  padindex: integer;
  padcount: integer;
  seekoffset: integer;
  padbuf: ^padbufty;
  keybuf: ^keybufty;
  ivbuf: ^ivbufty;
  state: sslhandlerstatesty;
 end;
 psslhandlerdatadty = ^sslhandlerdatadty;
 {$if sizeof(sslhandlerdatadty) > sizeof(cryptohandlerdataty)} 
  {$error 'buffer overflow'}
 {$endif}
 sslhandlerdataty = record
  case integer of
   0: (d: sslhandlerdatadty;);
   1: (_bufferspace: cryptohandlerdataty;);
 end;

 cryptoerrorty = (cerr_error,cerr_ciphernotfound,cerr_notseekable,
                  cerr_cipherinit,cerr_invalidopenmode,cerr_digestnotfound,
                  cerr_cannotwrite,cerr_invalidblocksize,
                  cerr_invalidkeylength,cerr_invaliddatalength,
                  cerr_readheader,cerr_writeheader,cerr_nobio,
                  cerr_nopubkey,cerr_encrypt,cerr_norsakey,
                  cerr_noprivkey,cerr_decrypt,cerr_nokey,
                  cerr_cannotrestart);

 getkeyeventty = procedure(const sender: tobject;
                                var akey,asalt: string) of object;

 opensslcryptooptionty = (sslco_salt,sslco_canrestart); 
                                     //stores key and iv for seek(0)
 opensslcryptooptionsty = set of opensslcryptooptionty;
const
 defaultopensslcryptooptions = [sslco_salt];
 
type 
 tpaddedcryptohandler = class(tbasecryptohandler)
  private
   foptions: opensslcryptooptionsty;
  protected
   procedure cipherupdate(var aclient: cryptoclientinfoty; 
             const source: pbyte; const sourcelen: integer;
                const dest: pbyte; out destlen: integer); virtual; abstract;
   procedure cipherfinal(var aclient: cryptoclientinfoty;
             const dest: pbyte; out destlen: integer); virtual; abstract;

   function read(var aclient: cryptoclientinfoty;
                   var buffer; count: longint): longint; override;
   function write(var aclient: cryptoclientinfoty;
                   const buffer; count: longint): longint; override;
   function seek(var aclient: cryptoclientinfoty;
                   const offset: int64; origin: tseekorigin): int64; override;
   function internalread(var aclient: cryptoclientinfoty;
                   var buffer; count: longint): longint;
   function internalwrite(var aclient: cryptoclientinfoty;
                   const buffer; count: longint): longint;
   function internalseek(var aclient: cryptoclientinfoty;
                   const offset: int64; origin: tseekorigin): int64;
   function  getsize(var aclient: cryptoclientinfoty): int64; override;
   procedure error(const err: cryptoerrorty);
   procedure checkerror(const err: cryptoerrorty = cerr_error); virtual;
   function checknullerror(const avalue: integer;
                   const err: cryptoerrorty = cerr_error): integer; inline;
   function checknilerror(const avalue: pointer;
                   const err: cryptoerrorty = cerr_error): pointer; inline;
   procedure restartcipher(var aclient: cryptoclientinfoty); virtual;
   procedure open(var aclient: cryptoclientinfoty); override;
   procedure close(var aclient: cryptoclientinfoty);  override;
   procedure initializedata(var adata: cryptoclientinfoty); virtual;
   procedure finalizedata(var adata: cryptoclientinfoty); virtual;
 end;
 
 tcustomopensslcryptohandler = class(tpaddedcryptohandler)
  private
   fciphername: string;
   fkey: string;
   fsalt: string;
   fkeyphrase: msestring;
   fongetkey: getkeyeventty;
   fkeylength: integer;
   procedure setkeyphrase(const avalue: msestring);
  protected
   procedure clearerror; inline;
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

//
// under construction!
//
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
              const atimeoutms: integer; const resultpo: pinteger = nil): boolean;
function filebio(const aname: filenamety; const aopenmode: fileopenmodety): pbio;
procedure closebio(const abio: pbio);
function readpubkey(const aname: filenamety): pevp_pkey;
function readprivkey(const aname: filenamety;
                          const getkey: getkeydataeventty): pevp_pkey;
procedure freekey(const akey: pevp_pkey);
 
implementation
uses
 sysutils,msesysintf1,msefileutils,msesocketintf,mseopensslbio,mseopensslpem,
 mseopensslrsa,msebits,
 msesysintf,msectypes;
const
 cryptoerrormessages: array[cryptoerrorty] of msestring =(
  'OpenSSL error.',
  'Cipher not found.',
  'Stream not seekable.',
  'Can not cipher init.',
  'Invalid open mode.',
  'Digest not found.',
  'Can not write.',
  'Invalid block size.',
  'Invalid key length.',
  'Invalid data length.',
  'Can not read header.',
  'Can not write header.',
  'Can not create BIO.',
  'No public key.',
  'Can not encrypt.',
  'No RSA key.',
  'No private key.',
  'Can not decrypt.',
  'No key.',
  'Can not restart.'
  );
 
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
  raiseerror(int1,cryptoerrormessages[aerror]);
 end;
end;

function filebio(const aname: filenamety;
                                    const aopenmode: fileopenmodety): pbio;
var
 str1,str2: string;
begin
 str1:= stringtoutf8(tosysfilepath(filepath(aname)));
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

{ tpaddedcryptohandler }
var testvar: psslhandlerdatadty;
function tpaddedcryptohandler.read(var aclient: cryptoclientinfoty;
                                         var buffer; count: longint): longint;
var
 ps,pd: pbyte;
 blocksize: integer;

 procedure checkpadding;
 var
  int1,int2: integer;
 begin
  with sslhandlerdataty(aclient.handlerdata).d do begin
   int2:= padcount - padindex;
   if int2 > 0 then begin
    int1:= count;
    if int1 > int2 then begin
     int1:= int2;
    end;
    move(padbuf^[padindex],pd^,int1);
    padindex:= padindex + int1;
    result:= result + int1;
    count:= count - int1;
    seekoffset:= seekoffset + int1;
    inc(pd,int1);
   end;
  end;
 end; //checkpadding

var
 int1,int2,int3,int4: integer;
 pb,po1: pbyte;
 
begin
testvar:= @sslhandlerdataty(aclient.handlerdata).d;
 if count > 0 then begin
  with sslhandlerdataty(aclient.handlerdata).d do begin
   blocksize:= ctx^.cipher^.block_size;
   pd:= @buffer;
   result:= 0;
   if blocksize > 1 then begin
    checkpadding;
   end;
   if count > 0 then begin
    int1:= count;
    if blocksize > 1 then begin
     if sslhs_eofflag in state then begin
      exit;
     end;
     int1:= ((count+blocksize-1) div blocksize) * blocksize; //whole blocks
     if not (sslhs_hasfirstblock in state) then begin
      int1:= int1+blocksize;
      include(state,sslhs_hasfirstblock);
     end;
     getmem(po1,int1); 
     ps:= po1;
     try       
      int2:= inherited read(aclient,(ps)^,int1);
      updatebit1(longword(state),ord(sslhs_eofflag),int2 < int1);
      seekoffset:= seekoffset + ((count div blocksize) * blocksize - int2);
                       //set to zero later if eofflag
      pb:= pointer(padbuf);
      padindex:= 0;
      padcount:= 0;
      int4:= (int2 div blocksize - 1) * blocksize; 
      if int4 > count then begin
       int4:= (count div blocksize) * blocksize;
      end;
      if int4 > 0 then begin
       cipherupdate(aclient,ps,int4,pd,int3);
//       checknullerror(evp_cipherupdate(ctx,pointer(pd),int3,pointer(ps),int4));
       inc(result,int3);
       inc(pd,int3);
       dec(count,int3);
       inc(ps,int4);
      end
      else begin
       int4:= 0;
      end;
      int4:= int2-int4;
      if int4 > 0 then begin
       cipherupdate(aclient,ps,int4,pb,padcount);
//       checknullerror(evp_cipherupdate(ctx,pointer(pb),padcount,
//                                            pointer(ps),int4));
       inc(pb,padcount);
      end;
      if sslhs_eofflag in state then begin
       cipherfinal(aclient,pb,int3);
//       checknullerror(evp_cipherfinal(ctx,pointer(pb),int3));
       include(state,sslhs_finalized);
       padcount:= padcount + int3;
      end;
      checkpadding;
      if sslhs_eofflag in state then begin
       seekoffset:= 0;
      end;
     finally
      freemem(po1);
     end;
    end
    else begin
     getmem(ps,int1);
     try
      int2:= inherited read(aclient,ps^,int1);
      if int2 > 0 then begin
       cipherupdate(aclient,ps,int2,@buffer,result);
//       checknullerror(evp_cipherupdate(ctx,@buffer,result,pointer(ps),int2));
      end;
     finally
      freemem(ps);
     end;
    end;
   end;
  end;
 end
 else begin
  result:= inherited read(aclient,buffer,count);
 end;
end;

function tpaddedcryptohandler.write(var aclient: cryptoclientinfoty;
                                   const buffer; count: longint): longint;
var
 po1: pointer;
 int1: integer;
begin
testvar:= @sslhandlerdataty(aclient.handlerdata).d;
 if count > 0 then begin
  with sslhandlerdataty(aclient.handlerdata).d do begin
   getmem(po1,count+ctx^.cipher^.block_size);
   try
    cipherupdate(aclient,@buffer,count,po1,int1);
//    checknullerror(evp_cipherupdate(ctx,po1,int1,@buffer,count));
    if int1 > 0 then begin
     result:= inherited write(aclient,po1^,int1);
     if result = int1 then begin
      result:= count;
      seekoffset:= seekoffset + count - int1;
     end
     else begin
      error(cerr_cannotwrite);
     end;
    end
    else begin
     result:= count;
     seekoffset:= seekoffset + count;
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

function tpaddedcryptohandler.seek(var aclient: cryptoclientinfoty;
               const offset: int64; origin: tseekorigin): int64;
begin
 if offset <> 0 then begin //todo
  error(cerr_notseekable);
 end
 else begin
  result:= internalseek(aclient,offset,origin);
  with sslhandlerdataty(aclient.handlerdata).d do begin
   case origin of
    socurrent: begin
     result:= result + seekoffset;
    end;
    sobeginning: begin
     restartcipher(aclient);
    end;
    soend: begin
     error(cerr_notseekable);
    end;
   end;
  end;
 end;
end;

function tpaddedcryptohandler.getsize(var aclient: cryptoclientinfoty): int64;
var
 lint1: int64;
begin
 with aclient do begin
  if stream.handle <> thandle(invalidfilehandle) then begin
   lint1:= fileseek(stream.handle,int64(0),ord(socurrent));
   result:= fileseek(stream.handle,int64(0),ord(soend));
   fileseek(stream.handle,lint1,ord(sobeginning));
  end
  else begin
   result:= inherited getsize(aclient);
  end;
 end; 
end;

procedure tpaddedcryptohandler.checkerror(const err: cryptoerrorty);
begin
 //dummy
end;

function tpaddedcryptohandler.checknullerror(const avalue: integer;
                                          const err: cryptoerrorty): integer;
begin
 result:= avalue;
 if avalue = 0 then begin
  error(err);
 end;
end;

function tpaddedcryptohandler.checknilerror(const avalue: pointer;
                                         const err: cryptoerrorty): pointer;
begin
 result:= avalue;
 if avalue = nil then begin
  error(err);
 end;
end;

procedure tpaddedcryptohandler.error(const err: cryptoerrorty);
begin
 checkerror(err);
 raise essl.create(cryptoerrormessages[err]); 
           //there was no queued error
end;

function tpaddedcryptohandler.internalseek(var aclient: cryptoclientinfoty;
               const offset: int64; origin: tseekorigin): int64;
begin
 result:= inherited seek(aclient,offset,origin);
end;

function tpaddedcryptohandler.internalread(var aclient: cryptoclientinfoty;
               var buffer; count: longint): longint;
begin
 result:= inherited read(aclient,buffer,count);
end;

function tpaddedcryptohandler.internalwrite(var aclient: cryptoclientinfoty;
               const buffer; count: longint): longint;
begin
 result:= inherited write(aclient,buffer,count);
end;

procedure tpaddedcryptohandler.restartcipher(
                                      var aclient: cryptoclientinfoty);
var
 int1: integer;
 buffer: blockbufty;
begin
 if not (sslco_canrestart in foptions) then begin
  error(cerr_cannotrestart);
 end;
 with sslhandlerdataty(aclient.handlerdata).d do begin
  if not (sslhs_finalized in state) and 
            (aclient.stream.openmode in [fm_write,fm_create])then begin
   cipherfinal(aclient,@buffer,int1);
//   checknullerror(evp_cipherfinal(ctx,@buffer,int1));
   if int1 > 0 then begin
    if inherited write(aclient,buffer,int1) <> int1 then begin
     error(cerr_cannotwrite);
    end;
   end;
  end;
//  checknullerror(evp_cipherinit_ex(ctx,nil,nil,pointer(keybuf),
//                               pointer(ivbuf),mode),cerr_cipherinit);
//  ctx^.iv:= ctx^.iov;
  padindex:= 0;
  padcount:= 0;
  seekoffset:= 0;
  state:= [];
  if headersize > 0 then begin
   internalseek(aclient,int64(headersize),sobeginning);
  end;
 end;
end;

procedure tpaddedcryptohandler.open(var aclient: cryptoclientinfoty);
var
 int1: integer;
begin
testvar:= @sslhandlerdataty(aclient.handlerdata).d;
 initsslinterface;
 with sslhandlerdataty(aclient.handlerdata).d do begin
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
  initializedata(aclient);
  if not (sslco_canrestart in foptions) then begin
   fillchar(keybuf^,sizeof(keybuf^),0);
   fillchar(ivbuf^,sizeof(ivbuf^),0);
  end;
 end;
 inherited;
end;

procedure tpaddedcryptohandler.close(var aclient: cryptoclientinfoty);
var
 buf1: blockbufty;
 int1: integer;
begin
testvar:= @sslhandlerdataty(aclient.handlerdata).d;
 try
  with sslhandlerdataty(aclient.handlerdata).d do begin
   if ctx <> nil then begin
    if (aclient.stream.openmode in [fm_write,fm_create]) and
               (cipher <> nil) then begin
     if not (sslhs_finalized in state) then begin
      checknullerror(evp_cipherfinal(ctx,@buf1,int1));
      include(state,sslhs_finalized);
      if int1 > 0 then begin
       if inherited write(aclient,buf1,int1) <> int1 then begin
        error(cerr_cannotwrite);
       end;
      end;
     end;
    end;
//    else begin
//     checknullerror(evp_cipherfinal(ctx,@buffer,int1));
//    end;
   end;
  end;
 finally
  finalizedata(aclient);
  inherited;
 end;
end;

procedure tpaddedcryptohandler.initializedata(var adata: cryptoclientinfoty);
begin
 //dummy
end;

procedure tpaddedcryptohandler.finalizedata(var adata: cryptoclientinfoty);
begin
 //dummy
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
  raise essl.create(cryptoerrormessages[err]+lineend+str1);
 end;
end;

procedure tcustomopensslcryptohandler.initializedata(
                                    var aclient: cryptoclientinfoty);
var
 int1: integer;
begin
 with sslhandlerdataty(aclient.handlerdata).d do begin
  getmem(ctx,sizeof(ctx^));
  evp_cipher_ctx_init(ctx);
  getmem(padbuf,sizeof(padbuf^));
  getmem(keybuf,sizeof(keybuf^));
  getmem(ivbuf,sizeof(ivbuf^));

  cipher:= checknilerror(evp_get_cipherbyname(pchar(fciphername)),
                                                     cerr_ciphernotfound);
  checknullerror(evp_cipherinit_ex(ctx,cipher,nil,nil,nil,mode),
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
 end;
 initcipher(aclient);
end;

procedure tcustomopensslcryptohandler.finalizedata(
                                            var aclient: cryptoclientinfoty);
var
 data1: psslhandlerdatadty;
begin
 data1:= @sslhandlerdataty(aclient.handlerdata).d;
 with data1^ do begin
  if ctx <> nil then begin
   evp_cipher_ctx_cleanup(ctx);
   freemem(ctx);
  end;
  if padbuf <> nil then begin
   fillchar(padbuf^,sizeof(padbuf^),0);  
   freemem(padbuf);
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
 inherited;
 with sslhandlerdataty(aclient.handlerdata).d do begin
  checknullerror(evp_cipherinit_ex(ctx,nil,nil,pointer(keybuf),
                               pointer(ivbuf),mode),cerr_cipherinit);
  ctx^.iv:= ctx^.iov;
 end;
end;

procedure tcustomopensslcryptohandler.setkeyphrase(const avalue: msestring);
begin
 fkey:= stringtoutf8(avalue);
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
testvar:= @sslhandlerdataty(aclient.handlerdata).d;
 with sslhandlerdataty(aclient.handlerdata).d do begin
  checknullerror(evp_cipherupdate(ctx,pointer(dest),destlen,
                                               pointer(source),sourcelen));
 end;
end;

procedure tcustomopensslcryptohandler.cipherfinal(
               var aclient: cryptoclientinfoty;
               const dest: pbyte; out destlen: integer);
begin
testvar:= @sslhandlerdataty(aclient.handlerdata).d;
 with sslhandlerdataty(aclient.handlerdata).d do begin
  checknullerror(evp_cipherfinal(ctx,dest,destlen));
 end;
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
  digest:= checknilerror(evp_get_digestbyname(pchar(fkeydigestname)),
                                                     cerr_digestnotfound);
  getkey(key1,salt1);
  if key1 = '' then begin
   error(cerr_nokey);
  end;
  if salt1 <> '' then begin
   salt1:= salt1 + nullstring(8-length(salt1));
  end;
  if sslco_salt in foptions then begin
   if mode = 0 then begin
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
   headersize:= headerlength;
  end;
  checknullerror(evp_bytestokey(cipher,digest,
        pointer(pchar(pointer(salt1))+taglength),pointer(key1),
                         length(key1),fkeygeniterationcount,
                                               pointer(keybuf),pointer(ivbuf)));
  checknullerror(evp_cipherinit_ex(ctx,nil,nil,pointer(keybuf),pointer(ivbuf),
                                                         mode),cerr_cipherinit);
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
   if mode = 1 then begin //encrypt
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
    asymkey:= readprivkey(fprivkeyfile,@getkey);
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
   headersize:= int1 + cipher^.iv_len;
  finally
   freekey(asymkey);
  end;
  checknullerror(evp_cipherinit_ex(ctx,nil,nil,pointer(keybuf),
                                       pointer(ivbuf),mode),cerr_cipherinit);
 end;
end;

end.
