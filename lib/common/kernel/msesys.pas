{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesys;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 mseerror,msetypes,msestrings{$ifdef FPC},dynlibs{$endif};

type
 {$ifndef FPC}
 tlibhandle = thandle;
 {$endif}
 threadty = cardinal;
 internalthreadprocty = function(): integer of object;

 procitemty = record
  pid,ppid: integer;
  children: integerarty;
 end;
 procitemarty = array of procitemty;

 threadinfoty = record
  id: threadty;
  threadproc: internalthreadprocty;
  platformdata: array[0..3] of cardinal;
 end;

 mutexty = array[0..7] of cardinal;
 semty = array[0..7] of cardinal;
 condty = array[0..31] of cardinal;

const
 invalidfilehandle = -1;
type
 fileopenmodety = (fm_read,fm_write,fm_readwrite,fm_create,fm_append);
 fileaccessmodety = (fa_denywrite,fa_denyread);
 fileaccessmodesty = set of fileaccessmodety;
 filerightty = (s_irusr,s_iwusr,s_ixusr,
                s_irgrp,s_iwgrp,s_ixgrp,
                s_iroth,s_iwoth,s_ixoth,
                s_isuid,s_isgid,s_isvtx);
 filerightsty = set of filerightty;
 filetypety = (ft_unknown,ft_dir,ft_blk,ft_chr,ft_reg,ft_lnk,ft_sock,ft_fifo);
 fileattributety = (fa_rusr,fa_wusr,fa_xusr,
                    fa_rgrp,fa_wgrp,fa_xgrp,
                    fa_roth,fa_woth,fa_xoth,
                    fa_suid,fa_sgid,fa_svtx,
                    fa_dir,
                    fa_archive,fa_compressed,fa_encrypted,fa_hidden,
                    fa_offline,fa_reparsepoint,fa_sparsefile,fa_system,fa_temporary,
                    fa_all);

 fileattributesty = set of fileattributety;
type
 fileinfolevelty = (fil_name,fil_ext1,fil_ext2);

 dirstreamty = record
  infolevel: fileinfolevelty;
  dirname: filenamety;
  mask: filenamearty;
  include,exclude: fileattributesty;
  platformdata: array[0..7] of cardinal;
 end;

 ext1fileinfoty = record
  filetype: filetypety;
  attributes: fileattributesty;
  size: int64;
  modtime: tdatetime;
  accesstime: tdatetime;
  ctime: tdatetime;
 end;

 ext2fileinfoty = record
  id: int64;
  owner: cardinal;
  group: cardinal;
 end;

 fileinfostatety = (fis_extinfo1valid,fis_extinfo2valid,fis_diropen);
 fileinfostatesty = set of fileinfostatety;

 fileinfoty = record
  name: filenamety;
  state: fileinfostatesty;
  extinfo1: ext1fileinfoty;
  extinfo2: ext2fileinfoty;
 end;
 pfileinfoty = ^fileinfoty;

 syserrorty = (sye_ok,sye_lasterror,sye_busy,sye_dirstream,sye_network,
                sye_thread,sye_mutex,sye_semaphore,sye_cond,sye_timeout,
                sye_copyfile,sye_createdir,sye_noconsole
               );

 esys = class(eerror)
  private
    function geterror: syserrorty;
  public
   constructor create(aerror: syserrorty; atext: string);
   property error: syserrorty read geterror;
 end;

procedure syserror(error: syserrorty; text: string = ''); overload;
procedure syserror(error: syserrorty; sender: tobject; text: string = ''); overload;

function syelasterror: syserrorty; //returns sye_lasterror, sets mselasterror
function syeseterror(aerror: integer): syserrorty;
          //if aerror <> 0 -> returns sye_lasterror, sets mselasterror,
          //                  returns sye_ok othrewise
function getcommandlinearguments: stringarty;
                 //refcount of result = 1
function getcommandlineargument(const index: integer): string;
procedure deletecommandlineargument(const index: integer);
                //index 1..argumentcount-1, no action otherwise
procedure getprocaddresses(const lib: tlibhandle; const anames: array of string;
                             const adest: array of ppointer); overload;
procedure getprocaddresses(const libname: string; const anames: array of string; 
                             const adest: array of ppointer); overload;

threadvar
 mselasterror: integer;

implementation
uses
 Classes,msestreaming,msesysintf,msedatalist,sysutils
          {$ifndef FPC}{$ifdef mswindows},windows{$endif}{$endif};

procedure getprocaddresses(const lib: tlibhandle; const anames: array of string; 
                             const adest: array of ppointer);
var
 int1: integer;
begin
 if high(anames) <> high(adest) then begin
  raise exception.create('Invalid parameter.');
 end;
 for int1:= 0 to high(anames) do begin
 {$ifdef FPC}
  adest[int1]^:= getprocedureaddress(lib,anames[int1]);
  {$else}
  adest[int1]^:= getprocaddress(lib,pansichar(anames[int1]));
  {$endif}
  if adest[int1]^ = nil then begin
   raise exception.create('Function "'+anames[int1]+'" not found.');
  end;
 end;
end;

procedure getprocaddresses(const libname: string; const anames: array of string; 
                             const adest: array of ppointer); overload;
var
 libha: tlibhandle;
begin
 libha:= 0;
 {$ifdef FPC}
 libha:= loadlibrary(libname);
 {$else}
 libha:= loadlibrary(pansichar(libname));
 {$endif}
 if libha = 0 then begin
  raise exception.create('Library "'+libname+'" not found.');
 end;
 getprocaddresses(libha,anames,adest);
end;

const
 errortexts: array[syserrorty] of string =
  ('','','Busy','Dirstream','Network error',
     'Thread error',
    'Mutex error',
    'Semaphore error',
    'Condition error',
    'Time out',
    'Copy file error',
    'Can not create directory',
    'No console'
   );

var
 commandlineargs: stringarty;

procedure initcommandlineargs;
begin
 if commandlineargs = nil then begin
  commandlineargs:= sys_getcommandlinearguments;
 end;
end;

function getcommandlineargument(const index: integer): string;
begin
 initcommandlineargs;
 if index > high(commandlineargs) then begin
  result:= '';
 end
 else begin
  result:= commandlineargs[index];
 end;
end;

function getcommandlinearguments: stringarty;
begin
 initcommandlineargs;
 result:= copy(commandlineargs);
end;

procedure deletecommandlineargument(const index: integer);
begin
 initcommandlineargs;
 if (index > 0) and (index <= high(commandlineargs)) then begin
  deleteitem(commandlineargs,index);
 end;
end;

function syeseterror(aerror: integer): syserrorty;
          //if aerror <> 0 -> returns sye_lasterror, sets mselasterror,
          //                  returns sye_ok othrewise
begin
 if aerror <> 0 then begin
  result:= sye_lasterror;
  mselasterror:= aerror;
 end
 else begin
  result:= sye_ok;
 end;
end;

function syelasterror: syserrorty; //returns sye_lasterror, sets mselasterror
begin
 result:= sye_lasterror;
 mselasterror:= sys_getlasterror;
end;

procedure syserror(error: syserrorty; text: string); overload;
begin
 if error = sye_ok then begin
  exit;
 end;
 if error = sye_lasterror then begin
  raise esys.create(error,text+sys_geterrortext(mselasterror));
 end
 else begin
  raise esys.create(error,text);
 end;
end;

procedure syserror(error: syserrorty; sender: tobject;
                       text: string = ''); overload;
begin
 if error = sye_ok then begin
  exit;
 end;
 if sender <> nil then begin
  text:= sender.classname + ' ' + text;
  if sender is tcomponent then begin
   text:= text + fullcomponentname(tcomponent(sender));
  end;
 end;
 syserror(error,text);
end;

{ esys }

constructor esys.create(aerror: syserrorty;  atext: string);
begin
 inherited create(integer(aerror),atext,errortexts);
end;

function esys.geterror: syserrorty;
begin
 result:= syserrorty(ferror);
end;


end.
