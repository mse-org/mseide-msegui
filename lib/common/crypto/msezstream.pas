{ MSEgui Copyright (c) 2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msezstream;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,msezlib,msecryptohandler,msestream,mseclasses;

const
 defaultzstreambuffersize = 16384;
 minzstreambuffersize = 16;
 
type
 zstreamstatety = (zs_inflate,zs_inited);
 zstreamstatesty = set of zstreamstatety;
 
 zstreamhandlerdatadty = record
  strm: pz_stream;
  buf: pbyte;
  bufsize: integer;
  state: zstreamstatesty;
 end;
 pzstreamhandlerdatadty = ^zstreamhandlerdatadty;
 {$if sizeof(zstreamhandlerdatadty) > sizeof(cryptohandlerdataty)} 
  {$error 'buffer overflow'}
 {$endif}
 zstreamhandlerdataty = record
  case integer of
   0: (d: zstreamhandlerdatadty;);
   1: (_bufferspace: cryptohandlerdataty;);
 end;

 tzstreamhandler = class(tbasecryptohandler)
  private
   fcompressionlevel: integer;
   fbuffersize: integer;
   procedure setbuffersize(avalue: integer);
  protected
   procedure checkinflate(var aclient: cryptoclientinfoty); inline;
   procedure checknoinflate(var aclient: cryptoclientinfoty); inline;
   function writedeflate(var aclient: cryptoclientinfoty;
                                 const aflush: integer): boolean;
   procedure open(var aclient: cryptoclientinfoty); override;
   procedure close(var aclient: cryptoclientinfoty);  override;
   procedure checkerror(const aerror: integer;
                         const aclient: cryptoclientinfoty); reintroduce;
   function read(var aclient: cryptoclientinfoty;
                   var buffer; count: longint): longint; override;
   function write(var aclient: cryptoclientinfoty;
                   const buffer; count: longint): longint; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property compressionlevel: integer read fcompressionlevel 
                  write fcompressionlevel default Z_DEFAULT_COMPRESSION;
   property buffersize: integer read fbuffersize write setbuffersize
                                   default defaultzstreambuffersize;
                  
 end;
 
implementation
uses
 msesys,mseapplication;
 
{ tzstreamhandler }

constructor tzstreamhandler.create(aowner: tcomponent);
begin
 fcompressionlevel:= Z_DEFAULT_COMPRESSION;
 fbuffersize:= defaultzstreambuffersize;
 inherited;
end;

procedure tzstreamhandler.checkinflate(var aclient: cryptoclientinfoty);
begin
 with zstreamhandlerdataty(aclient.handlerdata).d do begin
  if not (zs_inflate in state) then begin
   error(cerr_wrongdatadirection);
  end;
 end;
end;

procedure tzstreamhandler.checknoinflate(var aclient: cryptoclientinfoty);
begin
 with zstreamhandlerdataty(aclient.handlerdata).d do begin
  if (zs_inflate in state) then begin
   error(cerr_wrongdatadirection);
  end;
 end;
end;
var testvar: pzstreamhandlerdatadty;
procedure tzstreamhandler.open(var aclient: cryptoclientinfoty);
begin
testvar:= @zstreamhandlerdataty(aclient.handlerdata).d;
 if not (aclient.stream.openmode in [fm_read,fm_create,fm_write]) then begin
  error(cerr_invalidopenmode);
 end;
 initzlib;
 inherited;
 with zstreamhandlerdataty(aclient.handlerdata).d do begin
  getmem(strm,sizeof(z_stream));
  getmem(buf,fbuffersize);
  bufsize:= fbuffersize;
  if aclient.stream.openmode in [fm_read] then begin
   include(state,zs_inflate);
  end;
  with strm^ do begin
   zalloc:= nil;
   zfree:= nil;
   opaque:= nil;   
  end;
  if zs_inflate in state then begin
  end
  else begin
   deflateinit(strm,fcompressionlevel);
   include(state,zs_inited);
  end;
 end; 
end;

procedure tzstreamhandler.close(var aclient: cryptoclientinfoty);
begin
testvar:= @zstreamhandlerdataty(aclient.handlerdata).d;
 with zstreamhandlerdataty(aclient.handlerdata).d do begin
  if strm <> nil then begin
   if zs_inited in state then begin
    if zs_inflate in state then begin
     inflateend(strm);
    end
    else begin
     strm^.next_in:= nil;
     strm^.avail_in:= 0;
     try
      if not writedeflate(aclient,z_finish) then begin
       writeerror(aclient);
      end;
     except
      application.handleexception;
     end;
     deflateend(strm);
    end;
   end;
   freemem(strm);
   strm:= nil;
  end;
  if buf <> nil then begin
   freemem(buf);
   buf:= nil;
  end;
  state:= [];
 end; 
 inherited;
end;

procedure tzstreamhandler.checkerror(const aerror: integer;
               const aclient: cryptoclientinfoty);
begin
 if aerror < 0 then begin
  with zstreamhandlerdataty(aclient.handlerdata).d do begin
   componentexception(self,string(strm^.msg));
  end;
 end;
end;

function tzstreamhandler.read(var aclient: cryptoclientinfoty; var buffer;
               count: longint): longint;
begin
 checkinflate(aclient);
 with zstreamhandlerdataty(aclient.handlerdata).d do begin
 end;
 inherited;
end;

function tzstreamhandler.writedeflate(var aclient: cryptoclientinfoty;
                   const aflush: integer): boolean;
var
 int1: integer;
begin
 result:= true;
 with zstreamhandlerdataty(aclient.handlerdata).d do begin
  while true do begin
   strm^.next_out:= pointer(buf);
   strm^.avail_out:= bufsize;
   deflate(strm,aflush);
   int1:= pointer(strm^.next_out) - buf;
   if int1 = 0 then begin
    break;
   end;
   if result then begin
    if inherited write(aclient,buf,int1) <> int1 then begin
     result:= false; //can not write
    end;
   end;
  end;
 end;
end;

function tzstreamhandler.write(var aclient: cryptoclientinfoty; const buffer;
               count: longint): longint;
var
 int1: integer;
begin
 checknoinflate(aclient);
 result:= count;
 with zstreamhandlerdataty(aclient.handlerdata).d do begin
  if count > 0 then begin
   with strm^ do begin
    next_in:= @buffer;
    avail_in:= count;
    if not writedeflate(aclient,z_no_flush) then begin
     result:= 0; //can not write
    end;
   end;
  end;
 end;
end;

procedure tzstreamhandler.setbuffersize(avalue: integer);
begin
 if avalue < minzstreambuffersize then begin
  avalue:= minzstreambuffersize;
 end;
 fbuffersize:= avalue;
end;

end.
