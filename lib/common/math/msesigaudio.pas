{ MSEgui Copyright (c) 2010-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesigaudio;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
 {$if fpc_fullversion >= 030300}
  {$warn 6060 off}
  {$warn 6018 off}
  {$endif}
{$endif}
uses
 mseaudio,msesignal,classes,mclasses,msethread,msetypes,msestrings;

const
 defaultblocksize = 1000;

type
 tsigoutaudio = class;

 tsigaudioout = class(tcustomaudioout)
  private
  protected
   fsigout: tsigoutaudio;
   fblocksize: integer;
   fbuffer: bytearty;
   function threadproc(sender: tmsethread): integer; override;
   procedure run; override;
   procedure stop; override;
   procedure initnames; override;
  public
   constructor create(const aowner: tsigoutaudio); reintroduce;
  published
   property blocksize: integer read fblocksize write fblocksize
                                                  default defaultblocksize;
   property active;
   property server;
   property dev;
   property appname;
   property streamname;
//   property channels;
   property format;
   property rate;
   property latency;
   property stacksizekb;
//   property onsend;
//   property onerror;

 end;

 tsigoutaudio = class(tsigmultiinp)
  private
   faudio: tsigaudioout;
   fbuffer: doublearty;
   fbufpo: pdouble;
   procedure setaudio(const avalue: tsigaudioout);
  protected
    //isigclient
   function gethandler: sighandlerprocty; override;
   procedure sighandler(const ainfo: psighandlerinfoty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property audio: tsigaudioout read faudio write setaudio;
 end;

implementation
uses
 msesysintf,msepulsesimple,sysutils{$ifndef FPC},classes_del{$endif};

{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
 {$if fpc_fullversion >= 030300}
  {$warn 6060 off}
  {$warn 6018 off}
  {$endif}
{$endif}

{ tsigaudioout }

constructor tsigaudioout.create(const aowner: tsigoutaudio);
begin
 fblocksize:= defaultblocksize;
 fsigout:= aowner;
 inherited create(aowner);
 setsubcomponent(true);
end;

type
 convertinfoty = record
  source: pdouble;
  dest: pointer;
  valuehigh: integer;
 end;
 convertprocty = procedure(var info: convertinfoty);

procedure convert8(var info: convertinfoty);
var
 int1: integer;
 do1: double;
begin
 with info do begin
  for int1:= valuehigh downto 0 do begin
   do1:= source^;
   if do1 > 1 then begin
    do1:= 1;
   end;
   if do1 < -1 then begin
    do1:= -1;
   end;
   pbyte(dest)^:= $80+round(do1*$7f);
   inc(source);
   inc(pbyte(dest));
  end;
 end;
end;

procedure convert16(var info: convertinfoty);
var
 int1: integer;
 do1: double;
begin
 with info do begin
  for int1:= valuehigh downto 0 do begin
   do1:= source^;
   if do1 > 1 then begin
    do1:= 1;
   end;
   if do1 < -1 then begin
    do1:= -1;
   end;
   psmallint(dest)^:= round(do1*$7fff);
   inc(source);
   inc(psmallint(dest));
  end;
 end;
end;

procedure convert24(var info: convertinfoty);
var
 int1: integer;
 do1: double;
 int2: integer;
begin
 with info do begin
  for int1:= valuehigh downto 0 do begin
   do1:= source^;
   if do1 > 1 then begin
    do1:= 1;
   end;
   if do1 < -1 then begin
    do1:= -1;
   end;
   int2:= round(do1*$7fffff);
  {$ifdef FPC}
   pbyte(dest)[0]:= pbyte(@int2)[0];
   pbyte(dest)[1]:= pbyte(@int2)[1];
   pbyte(dest)[2]:= pbyte(@int2)[2];
  {$else}
   pchar(dest)[0]:= pchar(@int2)[0];
   pchar(dest)[1]:= pchar(@int2)[1];
   pchar(dest)[2]:= pchar(@int2)[2];
  {$endif}
   inc(source);
   inc(pbyte(dest),3);
  end;
 end;
end;

procedure convert32(var info: convertinfoty);
var
 int1: integer;
 do1: double;
begin
 with info do begin
  for int1:= valuehigh downto 0 do begin
   do1:= source^;
   if do1 > 1 then begin
    do1:= 1;
   end;
   if do1 < -1 then begin
    do1:= -1;
   end;
   pinteger(dest)^:= round(do1*$7fffffff);
   inc(source);
   inc(pinteger(dest));
  end;
 end;
end;

procedure convert32f(var info: convertinfoty);
var
 int1: integer;
begin
 with info do begin
  for int1:= valuehigh downto 0 do begin
   psingle(dest)^:= source^;
   inc(source);
   inc(psingle(dest));
  end;
 end;
end;

procedure convert2432(var info: convertinfoty);
var
 int1: integer;
 do1: double;
begin
 with info do begin
  for int1:= valuehigh downto 0 do begin
   do1:= source^;
   if do1 > 1 then begin
    do1:= 1;
   end;
   if do1 < -1 then begin
    do1:= -1;
   end;
   pinteger(dest)^:= round(do1*$7fffff);
   inc(source);
   inc(pinteger(dest));
  end;
 end;
end;

procedure convert16swap(var info: convertinfoty);
var
 int1: integer;
 do1: double;
begin
 with info do begin
  for int1:= valuehigh downto 0 do begin
   do1:= source^;
   if do1 > 1 then begin
    do1:= 1;
   end;
   if do1 < -1 then begin
    do1:= -1;
   end;
   psmallint(dest)^:= swapendian(smallint(round(do1*$7fff)));
   inc(source);
   inc(psmallint(dest));
  end;
 end;
end;

procedure convert24swap(var info: convertinfoty);
var
 int1: integer;
 do1: double;
 int2: integer;
begin
 with info do begin
  for int1:= valuehigh downto 0 do begin
   do1:= source^;
   if do1 > 1 then begin
    do1:= 1;
   end;
   if do1 < -1 then begin
    do1:= -1;
   end;
   int2:= round(do1*$7fffff);
  {$ifdef FPC}
   pbyte(dest)[0]:= pbyte(@int2)[2];
   pbyte(dest)[1]:= pbyte(@int2)[1];
   pbyte(dest)[2]:= pbyte(@int2)[0];
  {$else}
   pchar(dest)[0]:= pchar(@int2)[2];
   pchar(dest)[1]:= pchar(@int2)[1];
   pchar(dest)[2]:= pchar(@int2)[0];
  {$endif}
   inc(source);
   inc(pbyte(dest),3);
  end;
 end;
end;

procedure convert32swap(var info: convertinfoty);
var
 int1: integer;
 do1: double;
begin
 with info do begin
  for int1:= valuehigh downto 0 do begin
   do1:= source^;
   if do1 > 1 then begin
    do1:= 1;
   end;
   if do1 < -1 then begin
    do1:= -1;
   end;
   pinteger(dest)^:= swapendian(integer(round(do1*$7fffffff)));
   inc(source);
   inc(pinteger(dest));
  end;
 end;
end;

procedure convert32fswap(var info: convertinfoty);
var
 int1: integer;
 si1: single;
begin
 with info do begin
  for int1:= valuehigh downto 0 do begin
 {$ifdef FPC}
   si1:= single(source^);
 {$else}
   si1:= source^;
 {$endif}
   plongword(dest)^:= swapendian(longword(plongword(@si1)^));
   inc(source);
   inc(psingle(dest));
  end;
 end;
end;

procedure convert2432swap(var info: convertinfoty);
var
 int1: integer;
 do1: double;
begin
 with info do begin
  for int1:= valuehigh downto 0 do begin
   do1:= source^;
   if do1 > 1 then begin
    do1:= 1;
   end;
   if do1 < -1 then begin
    do1:= -1;
   end;
   pinteger(dest)^:= swapendian(integer(round(do1*$7fffff)));
   inc(source);
   inc(pinteger(dest));
  end;
 end;
end;

function tsigaudioout.threadproc(sender: tmsethread): integer;
var
// data: pointer;
 int1: integer;
 datasize1,blocksize1,bufferlength1,valuehigh1: integer;
 controller1: tsigcontroller;
// po1: pointer;
// po2: pdouble;
// do1: double;
 convert: convertprocty;
 info: convertinfoty;
begin
 result:= 0;
 controller1:= fsigout.controller;
 if controller1 <> nil then begin
  factive:= true;
  datasize1:= samplebuffersizematrix[fformat];
  blocksize1:= fblocksize;
  valuehigh1:= fsigout.inputs.count*blocksize1;
  bufferlength1:= datasize1*valuehigh1;
  dec(valuehigh1);
  info.valuehigh:= valuehigh1;
  setlength(fbuffer,bufferlength1);
  case fformat of
   sfm_u8,sfm_8alaw,sfm_8ulaw: begin
    convert:= @convert8;
   end;
   sfm_s16{$ifdef endian_little},sfm_s16le{$else},sfm_s16be{$endif}: begin
    convert:= @convert16;
   end;
   sfm_s24{$ifdef endian_little},sfm_s24le{$else},sfm_s24be{$endif}: begin
    convert:= @convert24;
   end;
   sfm_s32{$ifdef endian_little},sfm_s32le{$else},sfm_s32be{$endif}: begin
    convert:= @convert32;
   end;
   sfm_f32{$ifdef endian_little},sfm_f32le{$else},sfm_f32be{$endif}: begin
    convert:= @convert32f;
   end;
   smf_s2432{$ifdef endian_little},smf_s2432le{$else},smf_s2432be{$endif}: begin
    convert:= @convert2432;
   end;
 {$ifdef endian_little}
   sfm_s16be: begin
    convert:= @convert16swap;
   end;
   sfm_s24be: begin
    convert:= @convert24swap;
   end;
   sfm_s32be: begin
    convert:= @convert32swap;
   end;
   sfm_f32be: begin
    convert:= @convert32fswap;
   end;
   smf_s2432be: begin
    convert:= @convert2432swap;
   end;
 {$else}
   sfm_s16le: begin
    convert:= @convert16swap;
   end;
   sfm_s24le: begin
    convert:= @convert24swap;
   end;
   sfm_s32le: begin
    convert:= @convert32swap;
   end;
   sfm_f32le: begin
    convert:= @convert32fswap;
   end;
   smf_s2432le: begin
    convert:= @convert2432swap;
   end;
 {$endif}
   else begin
    exit;
   end;
  end;

  while not sender.terminated do begin
   controller1.lock;
   try
    fsigout.fbufpo:= pointer(fsigout.fbuffer);
    controller1.step(blocksize1);
    info.source:= pointer(fsigout.fbuffer);
    info.dest:= pointer(fbuffer);
    convert(info);
   finally
    controller1.unlock;
   end;
   if pa_simple_write(fpulsestream,pointer(fbuffer),
                                      bufferlength1,@int1) <> 0 then begin
    doerror(int1);
    break;
   end;
  end;
 end;
end;

procedure tsigaudioout.run;
var
 int1: integer;
begin
 int1:= fsigout.inputs.count;
 channels:= int1;
 setlength(fsigout.fbuffer,int1*fblocksize);
 inherited;
end;

procedure tsigaudioout.stop;
begin
 inherited;
 fsigout.fbufpo:= nil;
end;

procedure tsigaudioout.initnames;
begin
 inherited;
 if fstreamname = '' then begin
  fstreamname:= msestring(fsigout.name);
 end;
end;

{ tsigoutaudio }

constructor tsigoutaudio.create(aowner: tcomponent);
begin
 faudio:= tsigaudioout.create(self);
 inherited;
// finputs:= taudioinpconnarrayprop.create(self);
end;

destructor tsigoutaudio.destroy;
begin
 faudio.free;
 inherited;
// finputs.free;
end;
{
procedure tsigoutaudio.setinputs(const avalue: taudioinpconnarrayprop);
begin
 finputs.assign(avalue);
end;
}
procedure tsigoutaudio.setaudio(const avalue: tsigaudioout);
begin
 faudio.assign(avalue);
end;

function tsigoutaudio.gethandler: sighandlerprocty;
begin
 result:= {$ifdef FPC}@{$endif}sighandler;
end;

procedure tsigoutaudio.sighandler(const ainfo: psighandlerinfoty);
var
 int1: integer;
begin
 if fbufpo <> nil then begin
  for int1:= 0 to finphigh do begin
   fbufpo^:= finps[int1]^.value;
   inc(fbufpo);
  end;
 end;
end;

end.
