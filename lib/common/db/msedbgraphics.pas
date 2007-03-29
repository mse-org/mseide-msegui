{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedbgraphics;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 classes,db,mseimage,msedataimage,msedbdispwidgets,msedb,msetypes,msedbedit,
 msegrids,msewidgetgrid,msedatalist;

{ add the needed graphic format units to your project:
 mseformatbmpico,mseformatjpg,mseformatpng,
 mseformatpnm,mseformattga,mseformatxpm
}

type
 idbgraphicfieldlink = interface(idbeditfieldlink)
  procedure setformat(const avalue: string);
 end;
 
 tgraphicdatalink = class(teditwidgetdatalink)
  protected
   procedure setfield(const value: tfield); override;
  public
   constructor create(const intf: idbgraphicfieldlink);
 end;

 tdbdataimage = class(tcustomdataimage,idbeditinfo,idbgraphicfieldlink,ireccontrol)
  private
   fdatalink: tgraphicdatalink;
   function getdatafield: string; overload;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
   procedure griddatasourcechanged; override;
   function getrowdatapo(const info: cellinfoty): pointer; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
     //idbeditinfo
   function getdatasource(const aindex: integer): tdatasource; overload;
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty); virtual;
     //idbeditfieldlink
   function getgriddatasource: tdatasource;
   function edited: boolean;
   procedure initfocus;
   function checkvalue(const quiet: boolean = false): boolean;
   procedure valuetofield;
   procedure updatereadonlystate;
     //idbgraphicfieldlink
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
   //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property datalink: tgraphicdatalink read fdatalink;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
   property format;
 end;
 
implementation
uses
 msebitmap,msestream,msegraphics;
 
type
 tsimplebitmap1 = class(tsimplebitmap);
 
 { tdbdataimage }

constructor tdbdataimage.create(aowner: tcomponent);
begin
 fdatalink:= tgraphicdatalink.create(idbgraphicfieldlink(self));
 inherited;
 include(tsimplebitmap1(bitmap).fstate,pms_nosave);
end;

destructor tdbdataimage.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbdataimage.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdbdataimage.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tdbdataimage.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tdbdataimage.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tdbdataimage.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= blobfields;
end;

procedure tdbdataimage.fieldtovalue;
var
 stream1: tstringcopystream;
 str1: string;
begin
 str1:= datalink.field.asstring;
 if str1 = '' then begin
  setnullvalue;
 end
 else begin
  stream1:= tstringcopystream.create(str1);
  try
   bitmap.loadfromstream(stream1,format);
  except
   bitmap.clear;
  end;
  stream1.free;
 end;
end;

procedure tdbdataimage.setnullvalue;
begin
 bitmap.clear;
end;

function tdbdataimage.getdatasource(const aindex: integer): tdatasource;
begin
 result:= datasource;
end;

procedure tdbdataimage.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

procedure tdbdataimage.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbdataimage.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datasource;
end;

function tdbdataimage.edited: boolean;
begin
 result:= false;
end;

procedure tdbdataimage.initfocus;
begin
 //dummy
end;

function tdbdataimage.checkvalue(const quiet: boolean = false): boolean;
begin
 //dummy
end;

procedure tdbdataimage.valuetofield;
begin
 //dumy
end;

procedure tdbdataimage.updatereadonlystate;
begin
 //dummy
end;

function tdbdataimage.getrowdatapo(const info: cellinfoty): pointer;
begin
 with info do begin
  if griddatalink <> nil then begin
   result:= tgriddatalink(griddatalink).getansistringbuffer(
                                                 fdatalink.field,cell.row);
  end
  else begin
   result:= nil;
  end;
 end;
end;

function tdbdataimage.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

{ tgraphicdatalink }

constructor tgraphicdatalink.create(const intf: idbgraphicfieldlink);
begin
 inherited;
end;

procedure tgraphicdatalink.setfield(const value: tfield);
begin
 if value is tmsegraphicfield then begin
  idbgraphicfieldlink(fintf).setformat(tmsegraphicfield(value).format);
 end;
 inherited;
end;

end.
