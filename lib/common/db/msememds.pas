{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msememds;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,db,memds,msedb;
type
 tmsememdataset = class(tmemdataset,imselocate,idscontroller,igetdscontroller)
  private
   fcontroller: tdscontroller;
   procedure setcontroller(const avalue: tdscontroller);
   function getcontroller: tdscontroller;
       //idscontroller
   procedure inheritedresync(const mode: tresyncmode);
   procedure inheriteddataevent(const event: tdataevent; const info: ptrint);
   procedure inheritedcancel;
   procedure inheritedpost;
   function inheritedmoveby(const distance: integer): integer;
   procedure inheritedinternalinsert;
   procedure inheritedinternalopen;
  protected
   procedure setactive (value : boolean);{ override;}
   function getactive: boolean;
   procedure loaded; override;
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
   procedure internalopen; override;
   procedure internalinsert; override;

   procedure DoAfterCancel; override;
   procedure DoAfterClose; override;
   procedure DoAfterDelete; override;
   procedure DoAfterEdit; override;
   procedure DoAfterInsert; override;
   procedure DoAfterOpen; override;
   procedure DoAfterPost; override;
   procedure DoAfterScroll; override;
   procedure DoAfterRefresh; override;
   procedure DoBeforeCancel; override;
   procedure DoBeforeClose; override;
   procedure DoBeforeDelete; override;
   procedure DoBeforeEdit; override;
   procedure DoBeforeInsert; override;
   procedure DoBeforeOpen; override;
   procedure DoBeforePost; override;
   procedure DoBeforeScroll; override;
   procedure DoBeforeRefresh; override;
   procedure DoOnCalcFields; override;
   procedure DoOnNewRecord; override;

  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
   function locate(const key: string; const field: tfield; 
                 const options: locateoptionsty = []): locateresultty;
   procedure AppendRecord(const Values: array of const);
   procedure cancel; override;
   procedure post; override;
   function moveby(const distance: integer): integer;
  published
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive;
 end;
 
implementation

{ tmsememdataset }

constructor tmsememdataset.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= tdscontroller.create(self,idscontroller(self));
end;

destructor tmsememdataset.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsememdataset.locate(const key: integer; const field: tfield;
                   const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

function tmsememdataset.locate(const key: string;
        const field: tfield; const options: locateoptionsty = []): locateresultty;
begin
 result:= fcontroller.locate(key,field,options);
end;

procedure tmsememdataset.AppendRecord(const Values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsememdataset.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

function tmsememdataset.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsememdataset.setactive(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  inherited;
 end;
end;

procedure tmsememdataset.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmsememdataset.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

function tmsememdataset.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmsememdataset.inheritedresync(const mode: tresyncmode);
begin
 inherited resync(mode);
end;

procedure tmsememdataset.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmsememdataset.inheritedcancel;
begin
 inherited cancel;
end;

procedure tmsememdataset.cancel;
begin
 fcontroller.cancel;
end;

function tmsememdataset.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

procedure tmsememdataset.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmsememdataset.internalinsert;
begin
 fcontroller.internalinsert;
end;

function tmsememdataset.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmsememdataset.DoAfterCancel;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoAfterClose;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoAfterDelete;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoAfterEdit;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoAfterInsert;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoAfterOpen;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoAfterPost;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoAfterScroll;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoAfterRefresh;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoBeforeCancel;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoBeforeClose;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoBeforeDelete;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoBeforeEdit;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoBeforeInsert;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoBeforeOpen;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoBeforePost;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoBeforeScroll;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoBeforeRefresh;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoOnCalcFields;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.DoOnNewRecord;
begin
 if not (csdesigning in componentstate) then begin
  inherited;
 end;
end;

procedure tmsememdataset.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tmsememdataset.internalopen;
begin
 fcontroller.internalopen;
end;

procedure tmsememdataset.inheritedpost;
begin
 inherited post;
end;

procedure tmsememdataset.post;
begin
 fcontroller.post;
end;

end.
