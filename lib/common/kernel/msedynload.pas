unit msedynload;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msesys,dynlibs,msestrings,sysutils;
 
type
 dynlibinfoty = record
  libhandle: tlibhandle;
  libname: filenamety;
  refcount: integer;
  lock: mutexty;
 end;

procedure initializelibinfo(var info: dynlibinfoty);
procedure finalizelibinfo(var info: dynlibinfoty);

procedure initializedynlib(var info: dynlibinfoty;
                             const alibnames: array of filenamety;
                             const funcs: array of funcinfoty;
                             const funcsopt: array of funcinfoty);
procedure releasedynlib(var info: dynlibinfoty);

implementation

uses
 msesysintf;
 
procedure initializedynlib(var info: dynlibinfoty;
                              const alibnames: array of filenamety;
                              const funcs: array of funcinfoty;
                              const funcsopt: array of funcinfoty);
begin
 with info do begin
  sys_mutexlock(lock); 
  try
   if refcount = 0 then begin
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
   end;
   getprocaddresses(libhandle,funcsopt,true);
   inc(refcount);
  finally
   sys_mutexunlock(lock);
  end;
 end;
end;

procedure releasedynlib(var info: dynlibinfoty);
begin
 with info do begin
  if refcount > 1 then begin
   dec(refcount);
  end
  else begin
   if unloadlibrary(libhandle) then begin
    dec(refcount);
    libhandle:= nilhandle;
   end;
  end;
 end;
end;

procedure initializelibinfo(var info: dynlibinfoty);
begin
 with info do begin
  sys_mutexcreate(lock);
  libname:= '';
  refcount:= 0;
  libhandle:= 0;
 end;
end;

procedure finalizelibinfo(var info: dynlibinfoty);
begin
 with info do begin
  sys_mutexdestroy(lock);
 end;
end;

end.
