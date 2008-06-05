{ MSEide Copyright (c) 1999-2007 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit make;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

procedure domake(atag: integer);
procedure abortmake;
function making: boolean;
function buildmakecommandline(const atag: integer): string;

procedure dodownload;
procedure abortdownload;
function downloading: boolean;
function downloadresult: integer;

implementation
uses
 classes,mseprocutils,main,msestream,projectoptionsform,sysutils,msegrids,msetypes,
 sourceform,mseclasses,mseapplication,mseeditglob,msefileutils,msesys,msepipestream,
 msesysutils,msegraphics,msestrings,messageform,msedesignintf,msedesigner;

type
 tprogrunner = class(tactcomponent)
  private
   fexitcode: integer;
   fmessagefile: ttextstream;
  protected
   procid: integer;
   procedure doasyncevent(var atag: integer); override;
   procedure inputavailable(const sender: tpipereader);
   procedure dofinished(const sender: tpipereader); virtual;
   function getcommandline: ansistring; virtual;
  public
   messagepipe: tpipereader;
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
 end;

 tmaker = class(tprogrunner)
  private
   ftargettimestamp: tdatetime;
   fmaketag: integer;
  protected
   procedure doasyncevent(var atag: integer); override;
   procedure dofinished(const sender: tpipereader); override;
   function getcommandline: ansistring; override;
  public
   constructor create(atag: integer); reintroduce;
 end;
  
 tloader = class(tprogrunner)
  protected
   procedure dofinished(const sender: tpipereader); override;
   function getcommandline: ansistring; override;
  public
   constructor create(aowner: tcomponent); override;
 end;
 
var
 maker: tmaker;
 loader: tloader;

function making: boolean;
begin
 result:= (maker <> nil) and (maker.procid <> invalidprochandle);
end;

function downloading: boolean;
begin
 result:= (loader <> nil) and (loader.procid <> invalidprochandle);
end;

function downloadresult: integer;
begin
 result:= -1;
 if loader <> nil then begin
  result:= loader.fexitcode;
 end;
end;

procedure killmake;
begin
 freeandnil(maker);
end;

procedure killload;
begin
 freeandnil(loader);
end;

procedure domake(atag: integer);
var
 bo1: boolean;
begin
 killmake;
 bo1:= false;
 designnotifications.beforemake(idesigner(designer),atag,bo1);
 if not bo1 then begin
  maker:= tmaker.Create(atag);
  if projectoptions.closemessages then begin
   messagefo.messages.show;
  end;
 end;
end;

procedure abortmake;
begin
 if maker <> nil then begin
  killmake;
  mainfo.setstattext('Make aborted.',mtk_error);
 end;
end;

procedure abortdownload;
begin
 if loader <> nil then begin
  killload;
  mainfo.setstattext('Download aborted.',mtk_error);
 end;
end;

function buildmakecommandline(const atag: integer): string;
var
 int1,int2: integer;
 str1,str2,str3: msestring;
 wstr1: filenamety;
begin
 with projectoptions,texp do begin
  str3:= quotefilename(tosysfilepath(makecommand));
  str1:= str3;
  if targetfile <> '' then begin
   str1:= str1 + ' '+quotefilename(targpref+tosysfilepath(targetfile));
//   str1:= str1 + ' '+quotefilename('-o'+filename(targetfile));
//   wstr1:= removelastpathsection(targetfile);
//   if wstr1 <> '' then begin
//    str1:= str1 + ' '+quotefilename('-FE'+tosysfilepath(wstr1));
//   end;
  end;
  int2:= high(unitdirs);
  int1:= high(unitdirson);
  if int1 < int2 then begin
   int2:= int1;
  end;
  for int1:= 0 to int2 do begin
   if (atag and unitdirson[int1] <> 0) and
         (unitdirs[int1] <> '') then begin
    str2:= tosysfilepath(trim(unitdirs[int1]));
    if unitdirson[int1] and $10000 <> 0 then begin
     str1:= str1 + ' ' + quotefilename(unitpref+str2);
    end;
    if unitdirson[int1] and $20000 <> 0 then begin
     str1:= str1 + ' ' + quotefilename(incpref+str2);
    end;
    if unitdirson[int1] and $40000 <> 0 then begin
     str1:= str1 + ' ' + quotefilename(libpref+str2);
    end;
    if unitdirson[int1] and $80000 <> 0 then begin
     str1:= str1 + ' ' + quotefilename(objpref+str2);
    end;
   end;
  end;
  for int1:= 0 to high(makeoptions) do begin
   if (atag and makeoptionson[int1] <> 0) and
         (makeoptions[int1] <> '') then begin
    str1:= str1 + ' ' + makeoptions[int1];
   end;
  end;
  str1:= str1 + ' ' + quotefilename(tosysfilepath(mainfile));
 end;
 result:= str1;
end;

procedure dodownload;
begin
 killload;
 if projectoptions.closemessages then begin
  messagefo.messages.show;
 end;
 loader:= tloader.create(nil);
end;

{ tprogrunner }

constructor tprogrunner.create(aowner: tcomponent);
var
 str3: string;
 wdbefore: filenamety;
begin
 inherited;
 str3:= getcommandline; 
 with projectoptions,texp do begin
  if copymessages and (messageoutputfile <> '') then begin
   fmessagefile:= ttextstream.create(messageoutputfile,fm_create);
  end;
  messagepipe:= tpipereader.create;
  messagepipe.oninputavailable:= {$ifdef FPC}@{$endif}inputavailable;
  messagepipe.onpipebroken:= {$ifdef FPC}@{$endif}dofinished;
  messagefo.messages.rowcount:= 0;
  procid:= invalidprochandle;
  fexitcode:= 1; //defaulterror
  if makedir <> '' then begin
   wdbefore:= getcurrentdir;
   setcurrentdir(makedir);
  end;
  try
   procid:= execmse2(str3,nil,messagepipe,messagepipe,false,-1,true,false,true);
  except
   on e: exception do begin
    if e is eoserror then begin
     fexitcode:= eoserror(e).error;
    end;
    application.handleexception(nil,'Runerror with "'+str3+'": ');
   end;
  end;
  if makedir <> '' then begin
   setcurrentdir(wdbefore);
  end;
 end;
end;

destructor tprogrunner.destroy;
begin
// messagepipe.handle:= invalidfilehandle;
 if (procid <> invalidprochandle) then begin
  try
   killprocess(procid);
  except
  end;
  procid:= invalidprochandle;
 end;
 messagepipe.Free;
 fmessagefile.free;
 inherited;
end;

procedure tprogrunner.doasyncevent(var atag: integer);
begin
 if not getprocessexitcode(procid,fexitcode,5000000) then begin
  messagefo.messages.appendrow(['Error: Timeout.']);
  messagefo.messages.appendrow(['']);
 end;
 procid:= invalidprochandle;
// mainfo.makefinished(fexitcode);
 messagefo.messages.font.options:= messagefo.messages.font.options +
             [foo_antialiased] - [foo_nonantialiased];
end;

procedure tprogrunner.dofinished(const sender: tpipereader);
begin
 asyncevent(0);
end;

procedure tprogrunner.inputavailable(const sender: tpipereader);
var
 str1: string;
begin
 str1:= sender.readdatastring;
 while application.checkoverload(-1) do begin
  if procid = invalidprochandle then begin
   exit;
  end;
  application.unlock;
  sleepus(100000);
  application.lock;
 end;
 with messagefo.messages do begin
  datacols[0].readpipe(str1,true);
  showlastrow;
 end;
 if fmessagefile <> nil then begin
  fmessagefile.writestr(str1);
 end;
end;

function tprogrunner.getcommandline: ansistring;
begin
 result:= ''; //dummy
end;

{ tmaker }

constructor tmaker.create(atag: integer);
begin
 fmaketag:= atag;
 ftargettimestamp:= getfilemodtime(projectoptions.texp.targetfile);
 inherited create(nil);
 if procid <> invalidprochandle then begin
  mainfo.setstattext('Making.',mtk_running);
  messagefo.messages.font.options:= messagefo.messages.font.options -
               [foo_antialiased] + [foo_nonantialiased];
 end
 else begin
  mainfo.setstattext('Make not running.',mtk_error);
  designnotifications.aftermake(idesigner(designer),fexitcode);
 end;
end;

procedure tmaker.dofinished(const sender: tpipereader);
begin
 if ftargettimestamp <> getfilemodtime(projectoptions.texp.targetfile) then begin
  mainfo.targetfilemodified;
 end;
 inherited;
end;

function tmaker.getcommandline: ansistring;
begin
 result:= buildmakecommandline(fmaketag);
end;

procedure tmaker.doasyncevent(var atag: integer);
begin
 inherited;
 designnotifications.aftermake(idesigner(designer),fexitcode);
end;

{ tloader }

constructor tloader.create(aowner: tcomponent);
begin
 inherited;
 if procid <> invalidprochandle then begin
  mainfo.setstattext('Downloading.',mtk_running);
  messagefo.messages.font.options:= messagefo.messages.font.options -
               [foo_antialiased] + [foo_nonantialiased];
 end
 else begin
  mainfo.setstattext('Download not running.',mtk_error);
//  designnotifications.aftermake(idesigner(designer),int1);
 end;
end;

procedure tloader.dofinished(const sender: tpipereader);
begin
 inherited;
end;

function tloader.getcommandline: ansistring;
begin
 result:= projectoptions.texp.uploadcommand;
end;

end.
