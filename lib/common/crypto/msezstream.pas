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
 minzstreambuffersize = 256;
 
type
 zstreamstatety = (zs_inflate,zs_inited,zs_fileeof);
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
   procedure flush(var aclient: cryptoclientinfoty); override;
   procedure checkinflate(var aclient: cryptoclientinfoty); inline;
   procedure checknoinflate(var aclient: cryptoclientinfoty); inline;
   function writedeflate(var aclient: cryptoclientinfoty;
                                 const aflush: integer): boolean;
   procedure open(var aclient: cryptoclientinfoty); override;
   procedure close(var aclient: cryptoclientinfoty);  override;
   procedure checkerror(const aclient: cryptoclientinfoty;
                               const aerror: integer); reintroduce;
   function read(var aclient: cryptoclientinfoty;
                   var buffer; count: longint): longint; override;
   function write(var aclient: cryptoclientinfoty;
                   const buffer; count: longint): longint; override;
   function seek(var aclient: cryptoclientinfoty;
                   const offset: int64; origin: tseekorigin): int64; override;
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

procedure tzstreamhandler.open(var aclient: cryptoclientinfoty);
begin
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
   inflateinit(strm);
   include(state,zs_inited);
   strm^.next_in:= nil;
   strm^.avail_in:= 0;
  end
  else begin
   deflateinit(strm,fcompressionlevel);
   include(state,zs_inited);
  end;
 end; 
end;

procedure tzstreamhandler.close(var aclient: cryptoclientinfoty);
begin
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
      if not writedeflate(aclient,Z_FINISH) then begin
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

procedure tzstreamhandler.checkerror(const aclient: cryptoclientinfoty;
                     const aerror: integer);
begin
 if aerror < 0 then begin
  with zstreamhandlerdataty(aclient.handlerdata).d do begin
   componentexception(self,string(strm^.msg));
  end;
 end;
end;

function tzstreamhandler.read(var aclient: cryptoclientinfoty; var buffer;
               count: longint): longint;
var
 po1: pbyte;
 int1: integer;
begin
 checkinflate(aclient);
 result:= 0;
 po1:= @buffer;
 with zstreamhandlerdataty(aclient.handlerdata).d do begin
  while true do begin
   if not (zs_fileeof in state) and (strm^.avail_in = 0) then begin
    strm^.next_in:= pointer(buf);
    strm^.avail_in:= inherited read(aclient,buf^,bufsize);
    if strm^.avail_in < bufsize then begin
     include(state,zs_fileeof);
    end;
   end;
   strm^.avail_out:= count-result;
   if strm^.avail_out <= 0 then begin
    break;
   end;
   strm^.next_out:= pointer(po1);
   checkerror(aclient,inflate(strm,z_no_flush));
   int1:= pointer(strm^.next_out) - po1;
   if (int1 = 0) and (zs_fileeof in state) and (strm^.avail_in = 0) then begin
    break;
   end;
   result:= result + int1;
   po1:= pointer(strm^.next_out);
  end;
 end;
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
    if inherited write(aclient,buf^,int1) <> int1 then begin
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

procedure tzstreamhandler.flush(var aclient: cryptoclientinfoty);
begin
 with zstreamhandlerdataty(aclient.handlerdata).d do begin
  if not (zs_inflate in state) then begin
   strm^.next_in:= nil;
   strm^.avail_in:= 0;
   if not writedeflate(aclient,Z_SYNC_FLUSH) then begin
    writeerror(aclient);
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

function tzstreamhandler.seek(var aclient: cryptoclientinfoty;
               const offset: int64; origin: tseekorigin): int64;
begin
 if (origin <> socurrent) or (offset <> 0) then begin
  error(cerr_notseekable);
 end;
 inherited;
end;

end.
