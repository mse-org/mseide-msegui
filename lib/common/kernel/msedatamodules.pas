{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedatamodules;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 classes,mseclasses,msetypes,msegraphutils,msestatfile;
 
type
 datamoduleoptionty = (dmo_autoreadstat,dmo_autowritestat);
 datamoduleoptionsty = set of datamoduleoptionty;
const
 defaultdatamoduleoptions = [dmo_autoreadstat,dmo_autowritestat];
 
type
 tmsedatamodule = class(tmsecomponent)
  private
   fsize: sizety;
   foncreate: notifyeventty;
   fondestroy: notifyeventty;
   fondestroyed: notifyeventty;
   foptions: datamoduleoptionsty;
   fstatfile: tstatfile;
   fonloaded: notifyeventty;
   procedure writesize(writer: twriter);
   procedure readsize(reader: treader);
   procedure setstatfile(const avalue: tstatfile);
  protected
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
   class function getmoduleclassname: string; override;
   procedure defineproperties(filer: tfiler); override;
   procedure doonloaded; virtual;
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean); reintroduce; overload;
   destructor destroy; override;
   procedure beforedestruction; override;
   property size: sizety read fsize write fsize;
  published
   property options: datamoduleoptionsty read foptions write foptions 
                           default defaultdatamoduleoptions;
   property statfile: tstatfile read fstatfile write setstatfile;
   property oncreate: notifyeventty read foncreate write foncreate;
   property onloaded: notifyeventty read fonloaded write fonloaded;
   property ondestroy: notifyeventty read fondestroy write fondestroy;
   property ondestroyed: notifyeventty read fondestroyed write fondestroyed;
 end;
 datamoduleclassty = class of tmsedatamodule;
 
function createmsedatamodule(const aclass: tclass;
                     const aclassname: pshortstring): tmsecomponent;
implementation
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
 create(aowner,true);
end;

constructor tmsedatamodule.create(aowner: tcomponent; load: boolean);
begin
 foptions:= defaultdatamoduleoptions;
 include(fmsecomponentstyle,cs_ismodule);
 designinfo:= 100+(100 shl 16);
 inherited create(aowner);
 if load and not (csdesigning in componentstate) then begin
  loadmsemodule(self,tmsedatamodule);
  if (fstatfile <> nil) and (dmo_autoreadstat in foptions) then begin
   fstatfile.readstat;
  end;
  doonloaded;
 end;
end;

destructor tmsedatamodule.destroy;
var
 bo1: boolean;
begin
 bo1:= csdesigning in componentstate;
 inherited; //csdesigningflag is removed
 if not bo1 and candestroyevent(tmethod(fondestroyed)) then begin
  fondestroyed(self);
 end;
end;

procedure tmsedatamodule.doonloaded;
begin
 if canevent(tmethod(fonloaded)) then begin
  fonloaded(self);
 end;
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

procedure tmsedatamodule.getchildren(proc: tgetchildproc;
  root: tcomponent);
var
 int1: integer;
 component: tcomponent;
begin
 if root = self then begin
  for int1 := 0 to componentcount - 1 do begin
   component := components[int1];
   if not component.hasparent then begin
    proc(component);
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

procedure tmsedatamodule.writesize(writer: twriter);
begin
 with writer do begin
  writelistbegin;
  writeinteger(fsize.cx);
  writeinteger(fsize.cy);
  writelistend;
 end;
end;

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
 filer.defineproperty('size',{$ifdef FPC}@{$endif}readsize,
                       {$ifdef FPC}@{$endif}writesize, true);  
end;

procedure tmsedatamodule.loaded;
begin
 inherited;
 if canevent(tmethod(foncreate)) then begin
  foncreate(self);
 end;
end;

procedure tmsedatamodule.setstatfile(const avalue: tstatfile);
begin
 setlinkedvar(avalue,tmsecomponent(fstatfile));
end;

end.
