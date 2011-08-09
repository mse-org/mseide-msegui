unit msedynload;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesys,{$ifdef FPC}dynlibs,{$endif}msestrings,sysutils,msetypes;
 
type
 dynlibinfoty = record
  libhandle: tlibhandle;
  libname: filenamety;
  refcount: integer;
 end;

procedure initializelibinfo(var info: dynlibinfoty);
procedure finalizelibinfo(var info: dynlibinfoty);

procedure initializedynlib(var info: dynlibinfoty;
                             const alibnames: array of filenamety;
                             const funcs: array of funcinfoty;
                             const funcsopt: array of funcinfoty;
                             const callback: procedurety = nil);
                               //called after lib load
procedure releasedynlib(var info: dynlibinfoty;
                             const callback: procedurety = nil);
                               //called before lib unload
procedure dynloadlock;
procedure dynloadunlock;

implementation

uses
 msesysintf{$ifndef FPC},windows{$endif};

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

procedure initializedynlib(var info: dynlibinfoty;
                              const alibnames: array of filenamety;
                              const funcs: array of funcinfoty;
                              const funcsopt: array of funcinfoty;
                              const callback: procedurety = nil);
begin
 with info do begin
  sys_mutexlock(lock);
  try
   if refcount = 0 then begin
    if high(alibnames) >= 0 then begin
     libhandle:= loadlib(alibnames,libname);
     try
      getprocaddresses(libhandle,funcs,false);
     except
      on e: exception do begin
       e.message:= 'Library "'+libname+'": '+e.message;
       if unloadlibrary(libhandle) then begin
        libhandle:= nilhandle;
       end;
       raise;
      end;
     end;
     getprocaddresses(libhandle,funcsopt,true);
    end;
    if (callback <> nil) then begin
     callback;
    end;
   end;
   inc(refcount);
  finally
   sys_mutexunlock(lock);
  end;
 end;
end;

procedure releasedynlib(var info: dynlibinfoty;
                      const callback: procedurety = nil);
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
      if callback <> nil then begin
       callback;
      end;
     finally
      if (libhandle = nilhandle) or unloadlibrary(libhandle) then begin
       dec(refcount);
       libhandle:= nilhandle;
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