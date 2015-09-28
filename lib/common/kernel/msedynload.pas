unit msedynload;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesystypes,{$ifdef FPC}dynlibs,{$endif}msestrings,sysutils,msetypes,msesys;

{$ifndef cpuarm}{$define set8087cw}{$endif}

type
 funcinfoty = record
               n: string;      //name
               d: ppointer;    //destination
              end;
 dynlibinfoty = record
  libhandle: tlibhandle;
  libname: filenamety;
  refcount: integer;
  inithooks: pointerarty;       //array of dynlibprocty
  deinithooks: pointerarty;     //array of dynlibprocty
  cw8087: word;             //fpu control word after lib load
 end;
 dynlibprocty = procedure(const dynlib: dynlibinfoty);

 edynload = class(ecrashstatfile)
 end;
  
procedure initializelibinfo(var info: dynlibinfoty);
procedure finalizelibinfo(var info: dynlibinfoty);

function initializedynlib(var info: dynlibinfoty;
                              const libnames: array of filenamety;
                              const libnamesdefault: array of filenamety;
                              const funcs: array of funcinfoty;
                              const funcsopt: array of funcinfoty;
                              const errormessage: msestring = '';
                              const callback: procedurety = nil;
                              const noexception: boolean = false): boolean;
                                        //called after lib load
                              //returns true if all funcsopt found
procedure releasedynlib(var info: dynlibinfoty;
                         const callback: procedurety = nil;
                         const nodlunload: boolean = false);
                               //called before lib unload
procedure regdynlibinit(var info: dynlibinfoty; const initproc: dynlibprocty);
procedure regdynlibdeinit(var info: dynlibinfoty; const initproc: dynlibprocty);

procedure dynloadlock;
procedure dynloadunlock;

function loadlib(const libnames: array of filenamety; out libname: filenamety;
                        const errormessage: msestring = '';
                  const noexception: boolean = false): tlibhandle;
              
function getprocaddresses(const lib: tlibhandle;
                       const procedures: array of funcinfoty;
                       const noexception: boolean = false;
                       const libname: msestring = ''): boolean; overload;
function getprocaddresses(const lib: tlibhandle; const anames: array of string;
               const adest: array of ppointer;
               const noexception: boolean = false;
               const libname: msestring = ''): boolean; overload;
function getprocaddresses(const libinfo: dynlibinfoty;
                       const procedures: array of funcinfoty;
                       const noexception: boolean = false): boolean; overload;
function getprocaddresses(const libnames: array of msestring;
                       const procedures: array of funcinfoty;
                       const noexception: boolean = false):  tlibhandle; overload;
function getprocaddresses(const libinfo: dynlibinfoty;
               const anames: array of string;
               const adest: array of ppointer;
               const noexception: boolean = false): boolean; overload;
function getprocaddresses(const libnames: array of filenamety; 
                             const anames: array of string; 
                             const adest: array of ppointer;
                             const noexception: boolean = false): tlibhandle; overload;
function checkprocaddresses(const libnames: array of filenamety; 
                             const anames: array of string; 
                             const adest: array of ppointer): boolean;
function checkprocaddresses(const libnames: array of filenamety; 
                             const procedures: array of funcinfoty): boolean;
function quotelibnames(const libnames: array of filenamety): msestring;

implementation

uses
 msesysintf1{$ifndef FPC}{$ifdef mswindows},windows{$endif}{$endif}
 {,msedatalist},msearrayutils;

function getprocaddresses(const lib: tlibhandle;
                          const procedures: array of funcinfoty;
                          const noexception: boolean = false;
                          const libname: msestring = ''): boolean; overload;
var
 int1: integer;
 mstr1: msestring;
begin
 result:= true;
 mstr1:= '';
 for int1:= 0 to high(procedures) do begin
  with procedures[int1] do begin
  {$ifdef FPC}
   d^:= getprocedureaddress(lib,n);
  {$else}
   d^:= getprocaddress(lib,pansichar(n));
  {$endif}
   if (d^ = nil) then begin
    result:= false;
    if not noexception then begin
     if libname <> '' then begin
      mstr1:= libname + lineend;
     end;
     mstr1:= mstr1 + 'Function "'+msestring(n)+'" not found.';
     raise edynload.create(ansistring(mstr1));
    end;
   end;
  end;
 end;
end;

function getprocaddresses(const lib: tlibhandle; const anames: array of string; 
             const adest: array of ppointer;
             const noexception: boolean = false;
                                const libname: msestring = ''): boolean;
var
 int1: integer;
 mstr1: msestring;
begin
 if high(anames) <> high(adest) then begin
  raise exception.create('Invalid parameter.');
 end;
 mstr1:= '';
 result:= true;
 for int1:= 0 to high(anames) do begin
  adest[int1]^:= getprocaddress(lib,pansichar(anames[int1]));
  if (adest[int1]^ = nil) then begin
   result:= false;
   if not noexception then begin
    if libname <> '' then begin
     mstr1:= libname + lineend;
    end;
    mstr1:= mstr1 + 'Function "'+msestring(anames[int1])+'" not found.';
    raise exception.create(ansistring(mstr1));
   end;
  end;
 end;
end;

function getprocaddresses(const libinfo: dynlibinfoty;
                       const procedures: array of funcinfoty;
                       const noexception: boolean = false): boolean;
begin
 with libinfo do begin
  result:= getprocaddresses(libhandle,procedures,noexception,libname);
 end;
end;

function getprocaddresses(const libnames: array of msestring;
                       const procedures: array of funcinfoty;
                       const noexception: boolean = false): tlibhandle;
var
 str1: msestring;
begin
 result:= loadlib(libnames,str1,'',noexception);
 if result <> 0 then begin
  if not getprocaddresses(result,procedures,noexception,str1) then begin
   unloadlibrary(result);
   result:= 0;
  end;
 end;
end;

function getprocaddresses(const libinfo: dynlibinfoty;
               const anames: array of string;
               const adest: array of ppointer;
               const noexception: boolean = false): boolean; overload;
begin
 with libinfo do begin
  result:= getprocaddresses(libhandle,anames,adest,noexception,libname);
 end;
end;

function loadlib(const libnames: array of filenamety; out libname: filenamety; 
                 const errormessage: msestring = '';
                  const noexception: boolean = false): tlibhandle;
var
 int1: integer;
begin
 result:= 0;
 libname:= '';
 for int1:= 0 to high(libnames) do begin
 {$ifdef FPC}
  result:= loadlibrary(libnames[int1]);
 {$else}
  result:= loadlibrary(pansichar(string(libnames[int1])));
 {$endif}
  if result <> 0 then begin
   libname:= libnames[int1];
   break;
  end;
 end;
 if (result = 0) and not noexception then begin
  raise exception.create(ansistring(errormessage+
                   'Library '+quotelibnames(libnames)+' not found.'));
 end;
end;

function getprocaddresses(const libnames: array of filenamety;
                 const anames: array of string; const adest: array of ppointer;
                 const noexception: boolean = false): tlibhandle; overload;
var
 mstr1: filenamety;
begin
 result:= loadlib(libnames,mstr1);
 getprocaddresses(result,anames,adest,noexception);
end;

function checkprocaddresses(const libnames: array of filenamety; 
                             const anames: array of string; 
                             const adest: array of ppointer): boolean;
var
 int1: integer;
begin
 for int1:= 0 to high(adest) do begin
  adest[int1]^:= nil;
 end;
 result:= true;
 try
  getprocaddresses(libnames,anames,adest,true);
 except
  result:= false;
  exit;
 end;
 for int1:= 0 to high(adest) do begin
  if adest[int1]^ = nil then begin
   result:= false;
   break;
  end;
 end;
end;

function checkprocaddresses(const libnames: array of filenamety; 
                             const procedures: array of funcinfoty): boolean;
var
 int1: integer;
begin
 for int1:= 0 to high(procedures) do begin
  procedures[int1].d^:= nil;
 end;
 result:= true;
 try
  getprocaddresses(libnames,procedures,true);
 except
  result:= false;
  exit;
 end;
 for int1:= 0 to high(procedures) do begin
  if procedures[int1].d^ = nil then begin
   result:= false;
   break;
  end;
 end;
end;

function quotelibnames(const libnames: array of filenamety): msestring;
var 
 int1: integer;
begin
 result:= '';
 for int1:= 0 to high(libnames) do begin
  result:= result+'"'+libnames[int1]+'",';
 end;  
 if length(result) > 0 then begin
  setlength(result,length(result)-1);
 end;
end;

{$ifndef FPC}
const
 nilhandle = 0;
 
Function UnloadLibrary(Lib : TLibHandle) : Boolean;
begin
 result:= freelibrary(lib);
end;
{$endif}

var
 lock: mutexty;

function adduniqueitem(var dest: pointerarty; const value: pointer): integer;
                        //returns index
var
 int1: integer;
begin
 for int1:= 0 to high(dest) do begin
  if dest[int1] = value then begin
   result:= int1;
   exit;
  end;
 end;
 result:= high(dest) + 1;
 setlength(dest,result+1);
 dest[result]:= value;
end;

procedure regdynlibinit(var info: dynlibinfoty; const initproc: dynlibprocty);
begin
 sys_mutexlock(lock);
 adduniqueitem(info.inithooks,pointer({$ifndef FPC}@{$endif}initproc));
 sys_mutexunlock(lock);
end;

procedure regdynlibdeinit(var info: dynlibinfoty; const initproc: dynlibprocty);
begin
 sys_mutexlock(lock);
 adduniqueitem(info.deinithooks,pointer({$ifndef FPC}@{$endif}initproc));
 sys_mutexunlock(lock);
end;

function initializedynlib(var info: dynlibinfoty;
                              const libnames: array of filenamety;
                              const libnamesdefault: array of filenamety;
                              const funcs: array of funcinfoty;
                              const funcsopt: array of funcinfoty;
                              const errormessage: msestring = '';
                              const callback: procedurety = nil;
                              const noexception: boolean = false): boolean;
                              //true if all funcsopt found
var
 int1: integer;
 {$ifdef set8087cw}
 wo1: word;
 {$endif}
begin
 with info do begin
  sys_mutexlock(lock);
  try
   result:= true;
   if refcount = 0 then begin
    if (high(libnames) >= 0) or (high(libnamesdefault) >= 0) then begin
 {$ifdef set8087cw}
     wo1:= get8087cw;
 {$endif}
     if (high(libnames) >= 0) then begin
      libhandle:= loadlib(libnames,libname,errormessage,noexception);
     end
     else begin
      libhandle:= loadlib(libnamesdefault,libname,errormessage,noexception);
     end;
     if libhandle <> nilhandle then begin
 {$ifdef set8087cw}
      cw8087:= get8087cw;
      set8087cw(wo1);
 {$endif}
      try
       result:= getprocaddresses(libhandle,funcs,noexception);
       if not result then begin
        if unloadlibrary(libhandle) then begin
         libhandle:= nilhandle;
        end;
        exit;
       end;
      except
       on e: exception do begin
        e.message:= ansistring(
         errormessage+'Library "'+libname+'": '+msestring(e.message));
        if unloadlibrary(libhandle) then begin
         libhandle:= nilhandle;
        end;
        raise;
       end;
      end;
      result:= getprocaddresses(libhandle,funcsopt,true);
     end;
    end
    else begin
 {$ifdef set8087cw}
     cw8087:= get8087cw; //refresh
 {$endif}
    end;
    if libhandle <> nilhandle then begin
     inc(refcount);
     for int1:= 0 to high(inithooks) do begin
      dynlibprocty(inithooks[int1])(info);
     end;
     if ({$ifndef FPC}@{$endif}callback <> nil) then begin
      callback();
     end;
    end;
   end
   else begin
    inc(refcount);
   end;
  finally
   sys_mutexunlock(lock);
  end;
 end;
end;

procedure releasedynlib(var info: dynlibinfoty;
                      const callback: procedurety = nil;
                      const nodlunload: boolean = false);
var
 int1: integer;
begin
 with info do begin
  sys_mutexlock(lock);
  try
   if refcount > 1 then begin
    dec(refcount);
   end
   else begin
    if refcount = 1 then begin //not initialized otherwise
     try
      if {$ifndef FPC}@{$endif}callback <> nil then begin
       callback();
      end;
      for int1:= 0 to high(deinithooks) do begin
       dynlibprocty(deinithooks[int1])(info);
      end;
     finally
      if nodlunload then begin
       dec(refcount);
      end
      else begin
       if (libhandle = nilhandle) or unloadlibrary(libhandle) then begin
        dec(refcount);
        libhandle:= nilhandle;
       end;
      end;
     end;
    end;
   end;
  finally
   sys_mutexunlock(lock);
  end;  
 end;
end;

procedure initializelibinfo(var info: dynlibinfoty);
begin
 sys_mutexcreate(lock);
 with info do begin
  libname:= '';
  refcount:= 0;
  libhandle:= 0;
 end;
end;

procedure finalizelibinfo(var info: dynlibinfoty);
begin
 with info do begin
 end;
end;

procedure dynloadlock;
begin
 sys_mutexlock(lock);
end;

procedure dynloadunlock;
begin
 sys_mutexunlock(lock);
end;

initialization
 sys_mutexcreate(lock);
finalization
 sys_mutexdestroy(lock);
end.