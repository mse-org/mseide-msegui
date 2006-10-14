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
 classes,db,mseimage,msedbdispwidgets,msedb,msetypes;

{ add the needed graphic format units to your project:
 mseformatbmpico,mseformatjpg,mseformatpng,
 mseformatpnm,mseformattga,mseformatxpm
}

type
 idbgraphicfieldlink = interface(idbdispfieldlink)
  procedure setformat(const avalue: string);
 end;
 
 tgraphicdatalink = class(tdispfielddatalink)
  protected
   procedure setfield(const value: tfield); override;
  public
   constructor create(const intf: idbgraphicfieldlink);
 end;

 tdbimage = class(timage,idbeditinfo,idbgraphicfieldlink)
  private
   fformat: string;
   fdatalink: tgraphicdatalink;
   function getdatafield: string; overload;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
     //idbeditinfo
   function getdatasource(const aindex: integer): tdatasource; overload;
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty); virtual;
     //idbgraphicfieldlink
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
   procedure setformat(const avalue: string);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property datalink: tgraphicdatalink read fdatalink;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
 end;
 
implementation
uses
 msebitmap,msestream;
 
{ tdbimage }

constructor tdbimage.create(aowner: tcomponent);
begin
 fdatalink:= tgraphicdatalink.create(idbgraphicfieldlink(self));
 inherited;
end;

destructor tdbimage.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbimage.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdbimage.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tdbimage.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tdbimage.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tdbimage.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= blobfields;
end;

procedure tdbimage.fieldtovalue;
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
   bitmap.loadfromstream(stream1,fformat);
  finally
   stream1.free;
  end;
 end;
end;

procedure tdbimage.setnullvalue;
begin
 bitmap.clear;
end;

function tdbimage.getdatasource(const aindex: integer): tdatasource;
begin
 result:= datasource;
end;

procedure tdbimage.setformat(const avalue: string);
begin
 fformat:= avalue;
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
