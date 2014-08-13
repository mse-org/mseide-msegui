{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msefilechange;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}

interface

uses
 mseclasses,SysUtils,msethread,msefileutils,msesys,
 msetypes,msestrings,classes,mseapplication,mseevent;

{$ifdef UNIX}
const
 sigpuffermask = 32-1; //maximale anzahl pending notifications
{$endif}

type
  tfilechangenotifyer = class;

  filechangeinfoty = record
   dir: filenamety;
   infovorher: fileinfoty;
   info: fileinfoty;
   tag: integer;
   force: boolean;
   changed: filechangesty;
  end;

  filechangedeventty = procedure(const sender: tfilechangenotifyer;
                                const info: filechangeinfoty) of object;

  filechangeinfo1ty = record
   info: filechangeinfoty;
   owner: tfilechangenotifyer;
   isroot: boolean;
  end;
  fileinfosty = array of filechangeinfo1ty;

  tdirinfo = class
   private
    ffileinfos: fileinfosty;
    fpath: filenamety;
    fdirhandle: integer;
    procedure deleteinfo(index: integer);
   public
    constructor create(afd: integer; const apath: string); //owns the fd
    destructor destroy; override;
    procedure addfile(root: boolean; const sender: tfilechangenotifyer;
                      const tag: integer; const aforce: boolean;
                      const ainfo: fileinfoty);
    procedure changed;
    property path: filenamety read fpath;
  end;

  dirchangedeventty = procedure(const sender: tdirinfo) of object;

  tdirchangethread = class(tsemthread)
   private
{$ifdef mswindows}
    sem: cardinal;
    dirdescriptors: integerarty;
{$endif}
    fdirs: array of tdirinfo;
{$ifdef UNIX}
    fsigqueue: array[0..sigpuffermask] of integer;
    fsiginpo,fsigoutpo: integer;
    procedure changesignal(const afd: integer);
{$endif}
    procedure dochange(const afd: integer);
    procedure deletedirinfo(index: integer);
   protected
    function execute(thread: tmsethread): integer; override;
   public
    constructor Create;
    destructor Destroy; override;
    procedure addnotification(const sender: tfilechangenotifyer;
                              const filename: filenamety;
                              const tag: integer; const force: boolean);
    procedure removenotification(const sender: tfilechangenotifyer;
                              const filename: filenamety; tag: integer);
    procedure clear;
    //filename = '' -> filename nicht auswerten,
    //onchanged = nil -> onchanged nicht auswerten. tag = 0 -> tag nicht auswerten
  end;

 tfilechangenotifyer = class(tactcomponent)
  private
   fonfilechanged: filechangedeventty;
   fpath: filenamety;
   feventtag: integer;
   procedure dofilechanged(const sender: tfilechangenotifyer;
                      const info: filechangeinfoty);
   procedure setpath(const Value: filenamety);
   procedure removepath;
   procedure addpath;
   procedure seteventtag(const Value: integer);
  protected
   procedure loaded; override;
   procedure receiveevent(const event: tobjectevent); override;
  public
   destructor destroy; override;
   procedure addnotification(const filename: filenamety; const atag: integer = 0;
                             const force: boolean = false);
   procedure removenotification(const filename: filenamety; atag: integer = 0);
   procedure clear;
  published
   property onfilechanged: filechangedeventty read fonfilechanged write fonfilechanged;
   property path: filenamety read fpath write setpath;
   property eventtag: integer read feventtag write seteventtag default 0;

  end;

implementation
uses
 msedatalist,rtlconsts,msesysintf1,msesysintf,mselist,msearrayutils
{$ifdef mswindows}
 ,windows
{$else}
 ,mselibc
{$endif}
 ;
var
 fchangethread: tdirchangethread;

function changethread: tdirchangethread;
begin
 if fchangethread = nil then begin
  fchangethread:= tdirchangethread.Create;
 end;
 result:= fchangethread;
end;

{$ifdef UNIX}
var
 dirinfosig: integer;

procedure DirChanged(SigNum : Integer; context: psiginfo; p: pointer); cdecl;
          //kernel 2.6.25.18 does not return si_fd!
begin
 if SigNum = dirinfosig then begin
  if fchangethread <> nil then begin
   fchangethread.changesignal(context^._sigpoll.si_fd);
  end;
 end;
end;

const
 notifyflags = DN_MODIFY or DN_CREATE or DN_DELETE or DN_RENAME or DN_ATTRIB;
 
function adddir(const sender: tdirchangethread; 
                               const name: filenamety): integer;
var
 flags: longword;
 action: tsigactionex;
 str1: string;
begin
 str1:= name;
 result:= mselibc.open(PChar(str1),o_rdonly);
// if sys_openfile(name,fm_read,[],[],result) = sye_ok then begin
{$ifdef linux}
 if result >= 0 then begin
  FillChar(action, SizeOf(action), 0);
  with action do begin
   sa_sigaction:= @DirChanged;
   sa_flags := SA_SIGINFO or SA_RESTART;
  end;
  Flags:= notifyflags;
  if not((sigactionex(dirinfosig,action, nil) = 0) and
    (fcntl(result, F_SETSIG,[dirinfosig]) = 0) and
        (fcntl(result, F_NOTIFY,[Flags]) = 0)) then begin
   sys_closefile(result);  //es hat nicht geklappt
   result:= -1;
   exit;
  end;
  unblocksignal(dirinfosig);
 end;
{$endif}
end;

{$ENDIF unix}

{ tdirinfo }

constructor tdirinfo.create(afd: integer; const apath: string);
begin
 fdirhandle:= afd;
 fpath:= apath;
 inherited create;
end;

destructor tdirinfo.destroy;
begin
 {$ifdef mswindows}
 findclosechangenotification(fdirhandle);
 {$else}
 sys_closefile(fdirhandle);
 {$endif}
 inherited
end;

procedure tdirinfo.deleteinfo(index: integer);
var
 info1: array[0..sizeof(filechangeinfo1ty)-1] of byte;
begin
 move(ffileinfos[index],info1,sizeof(info1));
 move(ffileinfos[index+1],ffileinfos[index],
         (length(ffileinfos)-index-1)*sizeof(ffileinfos[0]));
 move(info1,ffileinfos[high(ffileinfos)],sizeof(info1));
 setlength(ffileinfos,high(ffileinfos));
end;

procedure tdirinfo.addfile(root: boolean; const sender:tfilechangenotifyer;
        const tag: integer; const aforce: boolean; const ainfo: fileinfoty);
var
 int1: integer;
begin
 int1:= length(ffileinfos);
 setlength(ffileinfos,int1+1);
 with ffileinfos[int1] do begin
  info.dir:= fpath;
  info.infovorher:= ainfo;
  info.tag:= tag;
  info.force:= aforce;
  isroot:= root;
  owner:= sender;
 end;
end;

type
 tfilechangeevent = class(tasyncevent)
  public
   info: filechangeinfoty;
 end;

procedure tdirinfo.changed;
const
 notcheckflags = [fc_accesstime];
var
 int1: integer;
 bo1: boolean;
 str1: string;
 aevent: tfilechangeevent;
begin
{$ifdef UNIX}
 {$ifdef linux}
 fcntl(fdirhandle,F_NOTIFY,[notifyflags]);
 {$endif}
{$endif}
 for int1:= 0 to length(ffileinfos) - 1 do begin
  with ffileinfos[int1] do begin
   if isroot then begin
    bo1:= getfileinfo(filedir(fpath),info.info);
   end
   else begin
    bo1:= getfileinfo(fpath+info.infovorher.name,info.info);
   end;
   if bo1 then begin
    info.changed:= compfileinfos(info.infovorher,info.info);
   end
   else begin
    info.changed:= [fc_removed];
   end;
   if isroot and (info.changed = []) then begin
    include(info.changed,fc_direntries);
   end;
   if info.force then begin
    include(info.changed,fc_force);
    info.force:= false;
   end;
   if info.changed - notcheckflags <> [] then begin
    aevent:= tfilechangeevent.Create(ievent(owner),0);
    aevent.info:= info;
    application.postevent(aevent);
    str1:= info.infovorher.name;
    info.infovorher:= info.info;
    info.infovorher.name:= str1;
    info.changed:= [];
   end;
  end;
 end;
end;

constructor tdirchangethread.Create;
begin
 {$ifdef mswindows}
 setlength(dirdescriptors,1);
 sem:= createsemaphore(nil,0,bigint,nil);
 dirdescriptors[0]:= sem;
 {$endif}
 inherited Create({$ifdef FPC}@{$endif}execute);
end;

destructor tdirchangethread.Destroy;
begin
 terminate;
 clear;
{$ifdef mswindows}
 closehandle(sem);
{$endif}
 inherited;
end;

procedure tdirchangethread.deletedirinfo(index: integer);
begin
 lock;
 fdirs[index].Free;

 move(fdirs[index+1],fdirs[index],(length(fdirs)-index-1)*sizeof(fdirs[0]));
 setlength(fdirs,length(fdirs)-1);
{$ifdef mswindows}
 deleteitem(integerarty(dirdescriptors),index+1);
 releasesemaphore(sem,1,nil);
{$endif}
 unlock;
end;

procedure tdirchangethread.clear;
var
 int1: integer;
begin
 lock;
 for int1:= 0 to length(fdirs) - 1 do begin
  fdirs[int1].Free;
 end;
 setlength(fdirs,0);
{$ifdef mswindows}
 setlength(dirdescriptors,1);
 releasesemaphore(sem,1,nil);
{$endif}
 unlock;
end;

{$ifdef UNIX}
procedure tdirchangethread.changesignal(const afd: integer);
var
 int1: integer;
begin
 if not terminated then begin
  int1:= fsigoutpo;
  while int1 <> fsiginpo do begin
   if fsigqueue[int1] = afd then begin
    exit; //allready seen
   end;
   int1:= (int1 + 1) and sigpuffermask;
  end; 
  int1:= (fsiginpo + 1) and sigpuffermask;
  if int1 <> fsigoutpo then begin
   fsigqueue[fsiginpo]:= afd;
//   fsiginpo:= int1;
   interlockedexchange(fsiginpo,int1);
  end;
  sempost;
 end;
end;
{$endif}

procedure tdirchangethread.dochange(const afd: integer);
var
 int1: integer;
begin
 if terminated or application.terminated then begin
  exit;
 end;
 lock;
 try
  if afd = -1 then begin
   for int1:= 0 to high(fdirs) do begin
    fdirs[int1].changed;    
   end;
  end
  else begin
   for int1:= 0 to high(fdirs) do begin
    if (fdirs[int1].fdirhandle = afd) then begin
             //ev. unzuverlaessig bei wiederverwendetem fd?
     fdirs[int1].changed;    
     break;
    end;
   end;
  end;
 finally
  unlock;
 end;
end;

function tdirchangethread.execute(thread: tmsethread): integer;
{$ifdef mswindows}
var
 Obj: DWORD;
 Handles: integerarty;
 fafd: integer;
begin
 result:= 0;
 handles:= nil; //compilerwarning
 while not Terminated and not application.terminated do begin
  lock;
  handles:= copy(dirdescriptors);
  unlock;
  Obj := WaitForMultipleObjects(length(handles), @Handles[0], False, INFINITE);
  if not terminated and not application.terminated then begin
   if obj <> wait_failed then begin //else closed handle
    obj:= obj - wait_object_0;
    if (obj > 0) and (integer(obj) < length(handles)) then begin
     fafd:= handles[obj];
     FindNextChangeNotification(fafd);
     dochange(fafd);
    end;
   end;
  end;
 end;
end;
{$else}    //unix
var
 int1: integer;
begin
 while not terminated  do begin
 {$ifdef linux}
  semwait;
  while not terminated and not (application.terminated) and
                                     (fsiginpo <> fsigoutpo) do begin
   int1:= fsigoutpo;
   interlockedexchange(fsigoutpo,(fsigoutpo + 1) and sigpuffermask);
   dochange(fsigqueue[int1]);
  end;
 {$else}
  semwait(500000); //freebsd needs polling
  if not terminated and not (application.terminated) then begin
   dochange(-1);
  end;
 {$endif}
  if not terminated then begin
   sleep(500);
  end;
 end;
 result:= 0;
end;
{$endif}

procedure tdirchangethread.addnotification(const sender: tfilechangenotifyer;
                  const filename: filenamety; const tag: integer;
                                     const force: boolean);
var
 int1: integer;
 apath: filenamety;
 fname: filenamety;
 wstr1: filenamety;
 dirinfo: tdirinfo;
 info: fileinfoty;
 fd: integer;

begin
 wstr1:= filepath(filename);
 if not getfileinfo(wstr1,info) then begin
{$ifdef FPC}
   raise EFCreateError.CreateFmt(SFCreateError,[filepath(FileName),
        sys_geterrortext(mselasterror)]);
{$else}

 {$if RTLVersion > 14.1}
  raise EFOpenError.CreateResFmt(@SFOpenErrorEx, [filepath(FileName),
             SysErrorMessage(mselasterror)]);
  {$else}
  raise EFOpenError.CreateResFmt(@SFOpenError, [filepath(FileName),
             SysErrorMessage(mselasterror)]);
  {$ifend}
{$endif}
 end;
 if info.extinfo1.filetype = ft_dir then begin
  apath:= filepath(wstr1,fk_dir);
  fname:= '';
 end
 else begin
  splitfilepath(wstr1,apath,fname);
//  apath:= extractfilepath(str1);
//  fname:= extractfilename(str1);
 end;
 tosysfilepath1(apath);
 dirinfo:= nil;
 for int1:= 0 to length(fdirs) - 1 do begin
  if fdirs[int1].path = apath then begin
   dirinfo:= fdirs[int1];
   break;
  end;
 end;
 lock;
 if dirinfo = nil then begin
  int1:= length(fdirs);
{$ifdef mswindows}
  if iswin95 then begin
   fd:= FindFirstChangeNotificationA(PChar(string(apath)),
     False, FILE_NOTIFY_CHANGE_FILE_NAME or FILE_NOTIFY_CHANGE_DIR_NAME or
     FILE_NOTIFY_CHANGE_ATTRIBUTES or FILE_NOTIFY_CHANGE_SIZE or
     file_notify_change_last_write or file_notify_change_security);
  end
  else begin
   fd:= FindFirstChangeNotificationW(PwideChar(apath),
     False, FILE_NOTIFY_CHANGE_FILE_NAME or FILE_NOTIFY_CHANGE_DIR_NAME or
     FILE_NOTIFY_CHANGE_ATTRIBUTES or FILE_NOTIFY_CHANGE_SIZE or
     file_notify_change_last_write or file_notify_change_security);
  end;
  if cardinal(fd) <> invalid_handle_value then begin
   setlength(dirdescriptors,int1+2);
   dirdescriptors[int1+1]:= fd;
{$else unix}
  fd:= adddir(self,apath);
  if fd >= 0 then begin
{$endif}
   setlength(fdirs,int1+1);
   dirinfo:= tdirinfo.Create(fd,apath);
   fdirs[int1]:= dirinfo;

  {$ifdef mswindows}
   releasesemaphore(sem,1,nil);
  {$endif}
  end;
 end;
 if dirinfo <> nil then begin
  dirinfo.addfile(fname = '',sender,tag,force,info);
 end;
 unlock;
end;

procedure tdirchangethread.removenotification(const sender: tfilechangenotifyer;
                              const filename: filenamety; tag: integer);
var
 apath,aname: filenamety;
 int1,int2: integer;

begin
 if filename = '' then begin
  apath:= '';
 end
 else begin
  apath:= tosysfilepath(filepath(filename,fk_dir));
 end;
 lock;
 for int1:= 0 to length(fdirs) - 1 do begin
  with fdirs[int1] do begin
   if (apath = '') or (fpath = apath) then begin
    int2:= 0;
    while int2 < length(ffileinfos) do begin
     with ffileinfos[int2] do begin
      if isroot and (owner = sender) and
            ((tag = 0) or (info.tag = tag)) then begin
       deleteinfo(int2);
      end
      else begin
       inc(int2);
      end;
     end;
    end;
   end;
  end;
 end;
 if filename = '' then begin
  apath:= '';
  aname:= '';
 end
 else begin
  splitfilepath(filename,apath,aname);
 end;
 tosysfilepath1(apath);
 for int1:= 0 to length(fdirs) - 1 do begin
  with fdirs[int1] do begin
   if (apath = '') or (fpath = apath) then begin
    int2:= 0;
    while int2 < length(ffileinfos) do begin
     with ffileinfos[int2] do begin
      if ((aname = '') or (info.infovorher.name = aname)) and
         (owner = sender) and ((tag = 0) or (info.tag = tag)) then begin
       deleteinfo(int2);
      end
      else begin
       inc(int2);
      end;
     end;
    end;
   end;
  end;
 end;
 int1:= 0;
 while int1 < length(fdirs) do begin
  if length(fdirs[int1].ffileinfos) = 0 then begin
   deletedirinfo(int1);
  end
  else begin
   inc(int1);
  end;
 end;
 unlock;
end;

{ tfilechangenotifyer }

destructor tfilechangenotifyer.destroy;
begin
 clear;
 inherited;
end;

procedure tfilechangenotifyer.dofilechanged(const sender: tfilechangenotifyer;
                          const info: filechangeinfoty);
begin
 if assigned(fonfilechanged) then begin
  fonfilechanged(self,info);
 end;
end;

procedure tfilechangenotifyer.setpath(const Value: filenamety);
begin
 if fpath <> value then begin
  removepath;
  fpath := Value;
  addpath;
 end;
end;

procedure tfilechangenotifyer.seteventtag(const Value: integer);
begin
 if feventtag <> value then begin
  removepath;
  feventtag := Value;
  addpath;
 end;
end;

procedure tfilechangenotifyer.loaded;
begin
 inherited;
 addpath;
end;

procedure tfilechangenotifyer.receiveevent(const event: tobjectevent);
begin
 if event is tfilechangeevent then begin
  dofilechanged(self,tfilechangeevent(event).info);
 end
 else begin
  inherited;
 end;
end;

procedure tfilechangenotifyer.addpath;
begin
 if (fpath <> '') and (componentstate * [csdesigning,csloading] = []) then begin
  addnotification(fpath,feventtag);
 end;
end;

procedure tfilechangenotifyer.removepath;
begin
 if (fpath <> '') and (componentstate * [csdesigning,csloading] = []) then begin
  removenotification(fpath,feventtag);
 end;
end;

procedure tfilechangenotifyer.addnotification(const filename: filenamety;
               const atag: integer = 0; const force: boolean = false);
begin
 changethread.addnotification(self,filename,atag,force);
end;

procedure tfilechangenotifyer.removenotification(const filename: filenamety;
                                             atag: integer = 0);
begin
 if fchangethread <> nil then begin
  fchangethread.removenotification(self,filename,atag);
 end;
end;

procedure tfilechangenotifyer.clear;
begin
 removenotification('');
end;

initialization
{$ifdef UNIX}
 dirinfosig:= sigrtmin + 10;
 if dirinfosig > sigrtmax then begin
  dirinfosig:= sigrtmax;
 end;
{$endif unix}
finalization
 freeandnil(fchangethread);
end.
