{ MSEgui Copyright (c) 2011 by Martin Schreiber

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
 mseglob,mseificomp,msesqlresult,msqldb,mseclasses,classes,msedatalist,msestrings,mdb,
 msedb,msetypes,mseinterfaces;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
type
{ 
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
}
 dbfieldinfoty = record
  name: msestring;
  datatype: tfieldtype;
 end;
 dbfieldinfoarty = array of dbfieldinfoty;
 
 iifidbdataconnection = interface(iifidataconnection)[miid_iifidbdataconnection]
  function getfieldinfos: dbfieldinfoarty;
 end;
 
 tifisqlresult = class(tsqlresult,iifidataconnection,iifidbdataconnection)
  protected
    //iifidataconnection
   procedure fetchdata(const acolnames: array of string; 
                                                  acols: array of tdatalist);
   function getfieldnames(const adatatype: listdatatypety): msestringarty;
   function getdatatype(const aname: ansistring): listdatatypety;
                           //dl_none if not found
    //iifidbdataconnection
   function getfieldinfos: dbfieldinfoarty;
  public
 end;
  
const
 listtypecompatibledbtypes: array[listdatatypety] of fieldtypesty =
  (
//dl_none,dl_integer,  dl_int64,                 dl_currency,
   [],    longintfcomp,largeintfcomp+[ftlargeint],realfcomp,
//dl_real,  dl_realint,dl_realsum,
  realfcomp,realfcomp, realfcomp,
//dl_datetime,
  datetimefcomp,
//dl_pointer
  [],
//dl_ansistring,dl_msestring,dl_doublemsestring,dl_msestringint,
  stringfcomp,  stringfcomp, stringfcomp,       stringfcomp,
//dl_complex,dl_rowstate,dl_custom
   [],        [],         []);       

 compatiblelisttypes: array[tfieldtype] of listdatatypety = (
  //ftUnknown,ftString,     ftSmallint,ftInteger, ftWord,
    dl_none,  dl_msestring,dl_integer,dl_integer,dl_integer,
  //  ftBoolean,ftFloat,ftCurrency,ftBCD, 
    dl_integer, dl_real,dl_real,   dl_currency,
  //ftDate,     ftTime,     ftDateTime,
    dl_datetime,dl_datetime,dl_datetime,
  //ftBytes,      ftVarBytes,   ftAutoInc, ftBlob,       ftMemo,
    dl_ansistring,dl_ansistring,dl_integer,dl_ansistring,dl_msestring,
  //ftGraphic,    ftFmtMemo,
    dl_ansistring,dl_msestring,
  //ftParadoxOle,ftDBaseOle,ftTypedBinary,ftCursor,ftFixedChar,
    dl_none,     dl_none,   dl_none,      dl_none, dl_msestring,
  //ftWideString,ftLargeint,ftADT,  ftArray,ftReference,
    dl_msestring,dl_int64,  dl_none,dl_none,dl_none,
  //ftDataSet,ftOraBlob,ftOraClob,ftVariant,ftInterface,
    dl_none,  dl_none,  dl_none,  dl_none,  dl_none,
  //ftIDispatch,ftGuid, ftTimeStamp,ftFMTBcd,ftFixedWideChar,ftWideMemo);
    dl_none,    dl_none,dl_datetime,dl_real, dl_msestring,   dl_msestring
 );
 
implementation
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

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
    if (atype = dl_none) or 
              (datatype in listtypecompatibledbtypes[atype]) then begin
     result[int2]:= msestring(name);
     inc(int2);
    end;
   end;
  end;
  setlength(result,int2);
 end;
end;

function fielddefstodatatype(const afielddefs: tfielddefs;
                                  const aname: ansistring): listdatatypety;
var
 int1: integer;
begin
 result:= dl_none;
 for int1:= 0 to afielddefs.count - 1 do begin
  with afielddefs[int1] do begin
   if name = aname then begin
    result:= compatiblelisttypes[datatype];
    break;
   end;
  end;
 end;
end;

(*
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
*)
{ tifisqlresult }

function tifisqlresult.getfieldnames(
                     const adatatype: listdatatypety): msestringarty;
begin
 result:= matchfielddatatypes(fielddefs,adatatype);
end;

function tifisqlresult.getdatatype(const aname: ansistring): listdatatypety;
                           //dl_none if not found
begin
 result:= fielddefstodatatype(fielddefs,aname);
end;

procedure tifisqlresult.fetchdata(const acolnames: array of string;
               acols: array of tdatalist);
//var
// ar1: datalistarty;
// ar2: integerarty;
// int1: integer;
begin
 refresh;
 if high(acols) <> high(acolnames) then begin
  componentexception(self,'fetchdata() item count mismatch.');
 end;
 internalloaddatalists(datacols.colsindexbyname(acolnames),acols);
{
 ar2:= cols.colsindexbyname(acolnames);
 if high(ar2) > high(acols) then begin
  setlength(ar2,length(acols));
 end;
}
 {
 setlength(ar1,cols.count);
 for int1:= 0 to high(ar2) do begin
  ar1[ar2[int1]]:= acols[int1];
 end;
// internalloaddatalists(acols);
 }
// internalloaddatalists(ar1,ar2);
 active:= false;
end;

function tifisqlresult.getfieldinfos: dbfieldinfoarty;
var
 int1: integer;
 def1: tfielddef;
begin
 setlength(result,fielddefs.count);
 for int1:= 0 to high(result) do begin
  def1:= fielddefs[int1];
  with result[int1] do begin
   name:= msestring(def1.name);
   datatype:= def1.datatype;
  end;
 end;
end;

end.
