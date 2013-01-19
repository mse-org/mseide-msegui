{ MSEgui Copyright (c) 2011-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesercomm;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 classes,mclasses,msesockets,msecommport,mseclasses;
//todo: timeouts, cryptio
 
type
 tasyncserport = class(tcustomrs232)
  public
   constructor create(const aowner: tmsecomponent;  //aowner can be nil
                                  const aoncheckabort: checkeventty = nil);
  published
   property commnr;
   property baud;
   property databits;
   property stopbit;
   property parity;
 end;
 
 tsercommwriter = class(tcommwriter)
 end;
 
 tsercommreader = class(tcommreader)
 end;
  
 tsercommpipes = class(tcustomcommpipes)
  protected
   procedure createpipes; override;
  published
   property optionsreader;
   property overloadsleepus;
   property oninputavailable;
   property oncommbroken;
 end;
 
 tcustomsercommcomp = class(tcustomcommcomp)
  private
   procedure setpipes(const avalue: tsercommpipes);
   procedure setport(const avalue: tasyncserport);
  protected
   fpipes: tsercommpipes;
   fport: tasyncserport;
   procedure internalconnect; override;
   procedure internaldisconnect; override;
   procedure closepipes(const sender: tcustomcommpipes); override;
   procedure doasyncevent(var atag: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property pipes: tsercommpipes read fpipes write setpipes;
   property port: tasyncserport read fport write setport;
 end;
 
 tsercommcomp = class(tcustomsercommcomp)
  published
   property pipes;
   property port;
   property active;
   property activator;
   property cryptoio;   
   property onbeforeconnect;
   property onafterconnect;
   property onbeforedisconnect;
   property onafterdisconnect;
 end;
 
implementation
uses
 msecryptio,msesys,msesystypes,mseapplication,msestream;
 
{ tcustomsercommcomp }

constructor tcustomsercommcomp.create(aowner: tcomponent);
begin
 if fpipes = nil then begin
  fpipes:= tsercommpipes.create(self,cyk_none); //todo: cyk_sercomm
 end;
 fport:= tasyncserport.create(self);
 inherited;
end;

destructor tcustomsercommcomp.destroy;
begin
 fport.free;
 fpipes.free;
 inherited;
end;

procedure tcustomsercommcomp.setpipes(const avalue: tsercommpipes);
begin
 fpipes.assign(avalue);
end;

procedure tcustomsercommcomp.internalconnect;
begin
 if not (csdesigning in componentstate) then begin
  fport.open;
  {$ifdef unix}
  setfilenonblock(fport.handle,false);
  {$endif};
  fpipes.handle:= fport.handle;
 end;
 factive:= true;
end;

procedure tcustomsercommcomp.internaldisconnect;
begin
 fpipes.handle:= msesystypes.invalidfilehandle;
 inherited;
 fport.close;
end;

procedure tcustomsercommcomp.closepipes(const sender: tcustomcommpipes);
begin
 if (csdestroying in componentstate) and application.ismainthread then begin
  disconnect;
 end
 else begin
  asyncevent(closepipestag);
 end;
end;

procedure tcustomsercommcomp.doasyncevent(var atag: integer);
begin
 if atag = closepipestag then begin
  disconnect;
 end;
end;

procedure tcustomsercommcomp.setport(const avalue: tasyncserport);
begin
 fport.assign(avalue);
end;

{ tsercommpipes }

procedure tsercommpipes.createpipes;
begin
 ftx:= tsercommwriter.create(self);
 frx:= tsercommreader.create(self);
end;

{ tasyncserport }

constructor tasyncserport.create(const aowner: tmsecomponent;
               const aoncheckabort: checkeventty = nil);
begin
 inherited;
 fvmin:= #1; //blocking
end;

end.
