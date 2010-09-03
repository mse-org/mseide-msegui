{ MSEgui Copyright (c) 2008-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseprocmonitorcomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 mseclasses,msesys,mseevent,mseprocmonitor;
 
type
 proclisteninfoty = record
  prochandle: prochandlety;
  data: pointer;
 end;
 proclisteninfoarty = array of proclisteninfoty;
 
 childdiedeventty = procedure(const sender: tobject;
                     const prochandle: prochandlety; const execresult: integer;
                     const data: pointer) of object;
                               
 tprocessmonitor = class(tmsecomponent,iprocmonitor)
  private
   fonchilddied: childdiedeventty;
   finfos: proclisteninfoarty;
  protected
   procedure receiveevent(const event: tobjectevent); override;
   procedure internalunlistentoprocess(const aprochandle: prochandlety;
                                       const internal: boolean);
    //iprocmonitor
   procedure processdied(const aprochandle: prochandlety;
                              const aexecresult: integer; const adata: pointer);
  public
   destructor destroy; override;
   function listentoprocess(const aprochandle: prochandlety;
                                 const adata: pointer = nil): boolean;
          //does nothing and returns false if aprochandle = invalidprochandle
   procedure unlistentoprocess(const aprochandle: prochandlety);
   function exec(const acommandline: string;
                       const inactive: boolean = true; 
                          //windows only
                       const nostdhandle: boolean = false): prochandlety;
                          //windows only
  published
   property onchilddied: childdiedeventty read fonchilddied write fonchilddied;
 end;
 
implementation
uses
 msedatalist,mseapplication,mseprocutils;
 
{ tprocessmonitor }

destructor tprocessmonitor.destroy;
var
 int1: integer;
begin
 for int1:= high(finfos) downto 0 do begin
  pro_unlistentoprocess(finfos[int1].prochandle,iprocmonitor(self));
 end;
 inherited;
end;

function tprocessmonitor.listentoprocess(const aprochandle: prochandlety;
               const adata: pointer): boolean;
begin
 result:= aprochandle <> invalidprochandle;
 if result then begin
  setlength(finfos,high(finfos)+2);
  with finfos[high(finfos)] do begin
   prochandle:= aprochandle;
   data:= adata;
  end;
  pro_listentoprocess(aprochandle,iprocmonitor(self),adata);
 end;
end;

procedure tprocessmonitor.internalunlistentoprocess(
      const aprochandle: prochandlety; const internal: boolean);
var
 int1: integer;
begin
 for int1:= high(finfos) downto 0 do begin
  with finfos[int1] do begin
   if prochandle = aprochandle then begin 
    if not internal then begin
     pro_unlistentoprocess(aprochandle,iprocmonitor(self));
    end;
    deleteitem(finfos,typeinfo(proclisteninfoarty),int1);
   end;
  end;
 end;
end;

procedure tprocessmonitor.processdied(const aprochandle: prochandlety;
               const aexecresult: integer; const adata: pointer);
begin
 application.postevent(tchildprocevent.create(ievent(self),aprochandle,
                                   aexecresult,adata));
end;

procedure tprocessmonitor.receiveevent(const event: tobjectevent);
begin
 if (event.kind = ek_childproc) then begin 
  with tchildprocevent(event) do begin
   if canevent(tmethod(fonchilddied)) then begin
     fonchilddied(self,prochandle,execresult,data);
   end;
   internalunlistentoprocess(prochandle,true);
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tprocessmonitor.unlistentoprocess(const aprochandle: prochandlety);
begin
 internalunlistentoprocess(aprochandle, false);
end;

function tprocessmonitor.exec(const acommandline: string;
               const inactive: boolean = true;
               const nostdhandle: boolean = false): prochandlety;
begin
 application.lock;
 try
  result:= execmse4(acommandline,inactive,nostdhandle);
  listentoprocess(result);
 finally
  application.unlock;
 end; 
end;

end.
