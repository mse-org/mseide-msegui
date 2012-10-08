{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedatamodules;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 classes,mseclasses,msetypes,msegraphutils,msestatfile,mseevent,mseapplication;
 
type
 datamoduleoptionty = (dmo_autoreadstat,dmo_delayedreadstat,
                                              dmo_autowritestat,dmo_iconic);
 datamoduleoptionsty = set of datamoduleoptionty;
const
 defaultdatamoduleoptions = [dmo_autoreadstat,dmo_autowritestat];
 
type
 tmsedatamodule = class(tactcomponent)
  private
   fsize: sizety;
   foncreate: notifyeventty;
   foncreated: notifyeventty;
   fondestroy: notifyeventty;
   fondestroyed: notifyeventty;
   foptions: datamoduleoptionsty;
   fstatfile: tstatfile;
   fonloaded: notifyeventty;
   fonasyncevent: asynceventeventty;
   foneventloopstart: notifyeventty;
   fonevent: eventeventty;
   fonterminatequery: terminatequeryeventty;
   fonterminated: notifyeventty;
//   procedure writesize(writer: twriter);
   procedure readsize(reader: treader);
   {
   procedure readsize_x(reader: treader);
   procedure writesize_x(writer: twriter);
   procedure readsize_y(reader: treader);
   procedure writesize_y(writer: twriter);
   }
   procedure setstatfile(const avalue: tstatfile);
   function getbounds_x: integer;
   procedure setbounds_x(const avalue: integer);
   function getbounds_y: integer;
   procedure setbounds_y(const avalue: integer);
   procedure setbounds_cx(const avalue: integer);
   procedure setbounds_cy(const avalue: integer);
   procedure setsize(const avalue: sizety);
   procedure setoptions(const avalue: datamoduleoptionsty);
  protected
   procedure boundschanged;
   procedure doterminated(const sender: tobject);
   procedure doterminatequery(var terminate: boolean);
   procedure getchildren(proc: tgetchildproc;
                             root: tcomponent); override;
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
   procedure defineproperties(filer: tfiler); override;
   procedure dooncreate; virtual;
   procedure readstate(reader: treader); override;
   procedure doafterload; override;
   procedure loaded; override;
   procedure doasyncevent(var atag: integer); override;
   procedure doeventloopstart; virtual;
   procedure receiveevent(const event: tobjectevent); override;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean); reintroduce; overload;
   destructor destroy; override;
   procedure reload;
   function hasparent: boolean; override;               
   function getparentcomponent: tcomponent; override;
   procedure beforedestruction; override;
   property size: sizety read fsize write setsize;
  published
   property options: datamoduleoptionsty read foptions write setoptions 
                           default defaultdatamoduleoptions;
   property bounds_x: integer read getbounds_x write setbounds_x stored false;
   property bounds_y: integer read getbounds_y write setbounds_y stored false;
   property bounds_cx: integer read fsize.cx write setbounds_cx;
   property bounds_cy: integer read fsize.cy write setbounds_cy;
   
   property statfile: tstatfile read fstatfile write setstatfile;
   property oncreate: notifyeventty read foncreate write foncreate;
   property oncreated: notifyeventty read foncreated write foncreated;
   property onloaded: notifyeventty read fonloaded write fonloaded;
   property oneventloopstart: notifyeventty read foneventloopstart 
                                   write foneventloopstart;
   property ondestroy: notifyeventty read fondestroy write fondestroy;
   property ondestroyed: notifyeventty read fondestroyed write fondestroyed;
   property onevent: eventeventty read fonevent write fonevent;
   property onasyncevent: asynceventeventty read fonasyncevent write fonasyncevent;
   property onterminatequery: terminatequeryeventty read fonterminatequery 
                 write fonterminatequery;
   property onterminated: notifyeventty read fonterminated 
                 write fonterminated;
 end;
 datamoduleclassty = class of tmsedatamodule;
 msedatamodulearty = array of tmsedatamodule;
 
function createmsedatamodule(const aclass: tclass;
                     const aclassname: pshortstring): tmsecomponent;
implementation
uses
 sysutils;
  
type
 tmsecomponent1 = class(tmsecomponent);
  
function createmsedatamodule(const aclass: tclass;
                     const aclassname: pshortstring): tmsecomponent;
begin
 result:= datamoduleclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

{ tmsedatamodule }

constructor tmsedatamodule.create(aowner: tcomponent);
begin
 create(aowner,not (cs_noload in fmsecomponentstate));
end;

constructor tmsedatamodule.create(aowner: tcomponent; load: boolean);
begin
 foptions:= defaultdatamoduleoptions;
 include(fmsecomponentstate,cs_ismodule);
 designinfo:= 100+(100 shl 16);
 inherited create(aowner);
 application.registeronterminated({$ifdef FPC}@{$endif}doterminated);
 application.registeronterminate({$ifdef FPC}@{$endif}doterminatequery);
 if load and not (csdesigning in componentstate) then begin
  loadmsemodule(self,tmsedatamodule);
 end;
 if not (acs_dooncreatecalled in factstate) then begin
  dooncreate;
 end;
 doafterload;
end;

destructor tmsedatamodule.destroy;
var
 bo1: boolean;
begin
 application.unregisteronterminated({$ifdef FPC}@{$endif}doterminated);
 application.unregisteronterminate({$ifdef FPC}@{$endif}doterminatequery);
 bo1:= csdesigning in componentstate;
 inherited; //csdesigningflag is removed
 if not bo1 and candestroyevent(tmethod(fondestroyed)) then begin
  fondestroyed(self);
 end;
end;

procedure tmsedatamodule.reload;
begin
 name:= '';
 reloadmsecomponent(self);
 doafterload;
end;

procedure tmsedatamodule.dooncreate;
begin
 include(factstate,acs_dooncreatecalled);
 if assigned(foncreate) then begin     //csloading possibly set
  foncreate(self);
 end;
end;

procedure tmsedatamodule.doafterload;
begin
 inherited;
 if (fstatfile <> nil) and 
      (foptions*[dmo_autoreadstat,dmo_delayedreadstat] = 
                                               [dmo_autoreadstat]) then begin
  fstatfile.readstat;
 end;
 if assigned(foncreated) then begin
  foncreated(self);
 end;
end;

procedure tmsedatamodule.loaded;
begin
 inherited;
 if canevent(tmethod(fonloaded)) then begin
  fonloaded(self);
 end;
 application.postevent(tobjectevent.create(ek_loaded,ievent(self)));
end;

procedure tmsedatamodule.readstate(reader: treader);
begin
 inherited;
 if not (acs_dooncreatecalled in factstate) then begin
  dooncreate;
 end;
end;

function tmsedatamodule.getparentcomponent: tcomponent;
begin
 result:= owner;
end;

function tmsedatamodule.hasparent: boolean;
begin
 result:= getparentcomponent <> nil;
end;

procedure tmsedatamodule.beforedestruction;
begin
 if (fstatfile <> nil) and (dmo_autowritestat in foptions) and
                 not (csdesigning in componentstate) then begin
  fstatfile.writestat;
 end;
 inherited;
 if candestroyevent(tmethod(fondestroy)) then begin
  fondestroy(self);
 end;
end;

procedure tmsedatamodule.getchildren(proc: tgetchildproc; root: tcomponent);
var
 int1: integer;
 comp1: tcomponent;
begin
 if root = self then begin
  for int1:= 0 to componentcount - 1 do begin
   comp1:= components[int1];
   if not (cssubcomponent in comp1.componentstyle) and
                             (comp1.getparentcomponent = self) then begin
    proc(comp1);
   end;
  end;
  for int1:= 0 to componentcount - 1 do begin
   comp1:= components[int1];
   if not (cssubcomponent in comp1.componentstyle) and
                                      not comp1.hasparent then begin
    proc(comp1);
   end;
  end;
 end;
end;

class function tmsedatamodule.getmoduleclassname: string;
begin
// result:= tmsedatamodule.ClassName;
 //bug in dcc32: tmsedatamodule is replaced by self
 result:= 'tmsedatamodule';
end;

class function tmsedatamodule.hasresource: boolean;
begin
 result:= self <> tmsedatamodule;
end;
{
procedure tmsedatamodule.writesize(writer: twriter);
begin
 with writer do begin
  writelistbegin;
  writeinteger(fsize.cx);
  writeinteger(fsize.cy);
  writelistend;
 end;
end;
}
procedure tmsedatamodule.readsize(reader: treader);
begin
 with reader do begin
  readlistbegin;
  fsize.cx:= readinteger;
  fsize.cy:= readinteger;
  readlistend;
 end;
end;

procedure tmsedatamodule.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('size',{$ifdef FPC}@{$endif}readsize,nil,false);
end;

procedure tmsedatamodule.setstatfile(const avalue: tstatfile);
begin
 setlinkedvar(avalue,tmsecomponent(fstatfile));
end;

procedure tmsedatamodule.doasyncevent(var atag: integer);
begin
 if canevent(tmethod(fonasyncevent)) then begin
  fonasyncevent(self,atag);
 end;
 inherited;
end;

procedure tmsedatamodule.doeventloopstart;
begin
 if (fstatfile <> nil) and not (csdesigning in componentstate) and
       (foptions*[dmo_autoreadstat,dmo_delayedreadstat] = 
        [dmo_autoreadstat,dmo_delayedreadstat]) then begin
  fstatfile.readstat;
 end;
 if canevent(tmethod(foneventloopstart)) then begin
  foneventloopstart(self);
 end;
end;

procedure tmsedatamodule.receiveevent(const event: tobjectevent);
begin
 if canevent(tmethod(fonevent)) then begin
  fonevent(self,event);
 end;
 inherited;
 if event.kind = ek_loaded then begin
  doeventloopstart;
 end;
end;

procedure tmsedatamodule.doterminated(const sender: tobject);
begin
 if canevent(tmethod(fonterminated)) then begin
  fonterminated(sender);
 end;
end;

procedure tmsedatamodule.doterminatequery(var terminate: boolean);
begin
 if canevent(tmethod(fonterminatequery)) then begin
  fonterminatequery(terminate);
 end;
end;

procedure tmsedatamodule.boundschanged;
begin
 designchanged;
end;

function tmsedatamodule.getbounds_x: integer;
begin
 result:= longrec(designinfo).lo;
end;

procedure tmsedatamodule.setbounds_x(const avalue: integer);
var
 rec: longrec;
begin
 rec:= longrec(designinfo);
 if rec.lo <> avalue then begin
  rec.lo:= avalue;
  designinfo:= longint(rec);
  boundschanged;
 end;
end;

function tmsedatamodule.getbounds_y: integer;
begin
 result:= longrec(designinfo).hi;
end;

procedure tmsedatamodule.setbounds_y(const avalue: integer);
var
 rec: longrec;
begin
 rec:= longrec(designinfo);
 if rec.hi <> avalue then begin
  rec.hi:= avalue;
  designinfo:= longint(rec);
  boundschanged;
 end;
end;

procedure tmsedatamodule.setbounds_cx(const avalue: integer);
begin
 if fsize.cx <> avalue then begin
  fsize.cx:= avalue;
  boundschanged;
 end;
end;

procedure tmsedatamodule.setbounds_cy(const avalue: integer);
begin
 if fsize.cy <> avalue then begin
  fsize.cy:= avalue;
  boundschanged;
 end;
end;

procedure tmsedatamodule.setsize(const avalue: sizety);
begin
 if (fsize.cx <> avalue.cx) or (fsize.cy <> avalue.cy) then begin
  fsize:= avalue;
  boundschanged;
 end;
end;

procedure tmsedatamodule.setoptions(const avalue: datamoduleoptionsty);
var
 optionsbefore: datamoduleoptionsty;
begin
 optionsbefore:= foptions;
 foptions:= avalue;
 if (dmo_iconic in avalue) xor (dmo_iconic in optionsbefore) then begin
  boundschanged;
 end;
end;

end.
