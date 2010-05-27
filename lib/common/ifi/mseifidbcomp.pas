{ MSEgui Copyright (c) 2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

   experimental user <-> business logic connection components.
   Warning: works with RTTI and is therefore slow.
}
unit mseifidbcomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 mseificomp,msesqlresult,mseclasses,classes,msedatalist,msestrings,db;
type
 tifisqldatasource = class;
 
 tifisqlfieldlinks = class(tififieldlinks)
  protected
   fowner: tifisqldatasource;
   function getfieldnames(
                   const adatatype: listdatatypety): msestringarty; override;
 end;
 
 tifisqldatasource = class(tifidatasource)
  private
   fsource: tsqlresult;
   procedure setsource(const avalue: tsqlresult);
  public
   constructor create(aowner: tcomponent); override;
  published
   property source: tsqlresult read fsource write setsource;
 end;
 
implementation

function matchfielddatatypes(const afielddefs: tfielddefs;
                          const atype: listdatatypety): msestringarty;
var
 int1,int2: integer;
begin
 result:= nil;
 if afielddefs <> nil then begin
  int2:= 0;
  setlength(result,afielddefs.count);
  for int1:= 0 to afielddefs.count-1 do begin
   if true then begin
    result[int2]:= afielddefs[int1].name;
    inc(int2);
   end;
  end;
  setlength(result,int2);
 end;
end;

{ tifisqlfieldlinks }

function tifisqlfieldlinks.getfieldnames(const adatatype: listdatatypety): msestringarty;
begin
 result:= matchfielddatatypes(fowner.fsource.fielddefs,adatatype);
end;

{ tifisqldatasource }

constructor tifisqldatasource.create(aowner: tcomponent);
begin
 if ffields = nil then begin
  ffields:= tifisqlfieldlinks.create;
  tifisqlfieldlinks(ffields).fowner:= self;
 end;
 inherited;
end;

procedure tifisqldatasource.setsource(const avalue: tsqlresult);
begin
 setlinkedvar(avalue,tmsecomponent(fsource));
end;

end.
