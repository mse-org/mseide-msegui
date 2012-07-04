{ MSEgui Copyright (c) 2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msecryptohandler;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msestream,classes,sysutils,msestrings;
type
 ecryptohandler = class(exception)
 end;
 tbasecryptohandler = class(tcustomcryptohandler)
  protected
 end;
 
 tdummycryptohandler = class(tbasecryptohandler)
 end;

 cryptoerrorty = (cerr_error,cerr_ciphernotfound,cerr_notseekable,
                  cerr_cipherinit,cerr_invalidopenmode,cerr_digestnotfound,
                  cerr_cannotwrite,cerr_invalidblocksize,
                  cerr_invalidkeylength,cerr_invaliddatalength,
                  cerr_readheader,cerr_writeheader,cerr_nobio,
                  cerr_nopubkey,cerr_encrypt,cerr_norsakey,
                  cerr_noprivkey,cerr_decrypt,cerr_nokey,
                  cerr_cannotrestart);

 sslhandlerstatety = (sslhs_hasfirstblock,sslhs_eofflag,sslhs_finalized);
 sslhandlerstatesty = set of sslhandlerstatety;
 
 padbufty = array[0..0] of byte; //variable

 paddedhandlerdatadty = record
  mode: integer;
  headersize: integer;
  blocksize: integer;
  bufsize: integer;
  padindex: integer;
  padcount: integer;
  seekoffset: integer;
  padbuf: ^padbufty;
  blockbuf: pbyte;
  state: sslhandlerstatesty;
 end;
 ppaddedhandlerdatadty = ^paddedhandlerdatadty;
 {$if sizeof(paddedhandlerdatadty) > sizeof(cryptohandlerdataty)} 
  {$error 'buffer overflow'}
 {$endif}
 paddedhandlerdataty = record
  case integer of
   0: (d: paddedhandlerdatadty;);
   1: (_bufferspace: cryptohandlerdataty;);
 end;
 
 tpaddedcryptohandler = class(tbasecryptohandler)
  private
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
   procedure initializedata(var aclient: cryptoclientinfoty); virtual;
   procedure finalizedata(var aclient: cryptoclientinfoty); virtual;
   function padbufsize: integer; virtual;
 end;
 
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
 
implementation
uses
 msebits,msesystypes,msesys;
 
{ tpaddedcryptohandler }
var testvar: ppaddedhandlerdatadty;
function tpaddedcryptohandler.read(var aclient: cryptoclientinfoty;
                                         var buffer; count: longint): longint;
var
 ps,pd: pbyte;
 blocksize: integer;

 procedure checkpadding;
 var
  int1,int2: integer;
 begin
  with paddedhandlerdataty(aclient.handlerdata).d do begin
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
testvar:= @paddedhandlerdataty(aclient.handlerdata).d;
 if count > 0 then begin
  with paddedhandlerdataty(aclient.handlerdata).d do begin
//   blocksize:= ctx^.cipher^.block_size;
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
testvar:= @paddedhandlerdataty(aclient.handlerdata).d;
 if count > 0 then begin
  with paddedhandlerdataty(aclient.handlerdata).d do begin
//   getmem(po1,count+ctx^.cipher^.block_size);
   getmem(po1,count+blocksize);
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
  with paddedhandlerdataty(aclient.handlerdata).d do begin
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
 raise ecryptohandler.create(cryptoerrormessages[err]); 
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
begin
 with paddedhandlerdataty(aclient.handlerdata).d do begin
  if not (sslhs_finalized in state) and 
            (aclient.stream.openmode in [fm_write,fm_create])then begin
   cipherfinal(aclient,blockbuf,int1);
//   checknullerror(evp_cipherfinal(ctx,@buffer,int1));
   if int1 > 0 then begin
    if inherited write(aclient,blockbuf^,int1) <> int1 then begin
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
testvar:= @paddedhandlerdataty(aclient.handlerdata).d;
 with paddedhandlerdataty(aclient.handlerdata).d do begin
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
 end;
 inherited;
end;

procedure tpaddedcryptohandler.close(var aclient: cryptoclientinfoty);
var
// buf1: blockbufty;
 int1: integer;
begin
testvar:= @paddedhandlerdataty(aclient.handlerdata).d;
 try
  with paddedhandlerdataty(aclient.handlerdata).d do begin
//   if ctx <> nil then begin
    if (aclient.stream.openmode in [fm_write,fm_create]) {and
               (cipher <> nil)} then begin
     if not (sslhs_finalized in state) then begin
      cipherfinal(aclient,blockbuf,int1);
//      checknullerror(evp_cipherfinal(ctx,@buf1,int1));
      include(state,sslhs_finalized);
      if int1 > 0 then begin
       if inherited write(aclient,blockbuf^,int1) <> int1 then begin
        error(cerr_cannotwrite);
       end;
      end;
     end;
    end;
//    else begin
//     checknullerror(evp_cipherfinal(ctx,@buffer,int1));
//    end;
//   end;
  end;
 finally
  finalizedata(aclient);
  inherited;
 end;
end;

procedure tpaddedcryptohandler.initializedata(var aclient: cryptoclientinfoty);
begin
 with paddedhandlerdataty(aclient.handlerdata).d do begin
  bufsize:= padbufsize;
  getmem(padbuf,bufsize);
  getmem(blockbuf,bufsize);
 end;
end;

procedure tpaddedcryptohandler.finalizedata(var aclient: cryptoclientinfoty);
begin
 with paddedhandlerdataty(aclient.handlerdata).d do begin
  if padbuf <> nil then begin
   fillchar(padbuf^,bufsize,0);  
   freemem(padbuf);
  end;
  if blockbuf <> nil then begin
   fillchar(blockbuf^,bufsize,0);  
   freemem(blockbuf);
  end;
 end;
end;

function tpaddedcryptohandler.padbufsize: integer;
begin
 result:= 1; //dummy
end;

end.
