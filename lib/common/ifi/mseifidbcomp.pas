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
 mseificomp,msesqlresult,mseclasses,classes,msedatalist,msestrings,db,msedb;
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
  protected
   procedure open; override;
   procedure close; override;
  public
   constructor create(aowner: tcomponent); override;
   procedure refresh;
  published
   property source: tsqlresult read fsource write setsource;
 end;

 tifisqlresult = class(tsqlresult,iifidataconnection)
  protected
    //iifidataconnection
   procedure iifidataconnection.fetchdata = loaddatalists;
  public
 end;
  
implementation

const
 listtypecompatibledbtypes: array[listdatatypety] of fieldtypesty =
  (
//dl_none,dl_integer,  dl_int64,                 dl_currency,
   [],    longintfcomp,largeintfcomp+[ftlargeint],realfcomp,
//dl_real,  dl_realint,dl_realsum,
  realfcomp,realfcomp, realfcomp,
//dl_datetime,
  datetimefcomp,
//dl_ansistring,dl_msestring,dl_doublemsestring,dl_msestringint,
  stringfcomp,  stringfcomp, stringfcomp,       stringfcomp,
//dl_complex,dl_rowstate,dl_custom
   [],        [],         []);       

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
   with afielddefs[int1] do begin
    if datatype in listtypecompatibledbtypes[atype] then begin
     result[int2]:= name;
     inc(int2);
    end;
   end;
  end;
  setlength(result,int2);
 end;
end;

{ tifisqlfieldlinks }

function tifisqlfieldlinks.getfieldnames(
                               const adatatype: listdatatypety): msestringarty;
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

procedure tifisqldatasource.open;
begin
 inherited;
 if fsource <> nil then begin
  fsource.refresh;
 end;
 afteropen;
end;

procedure tifisqldatasource.close;
begin
 if fsource <> nil then begin
  fsource.active:= false;
 end;
 inherited;
end;

procedure tifisqldatasource.refresh;
begin
 inherited close;
 open;
end;

end.
