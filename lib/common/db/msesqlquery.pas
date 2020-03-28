{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesqlquery;
{$ifdef FPC}{$mode objfpc}{$h+}{$goto on}{$endif}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
 {$if fpc_fullversion >= 030300}
  {$warn 6060 off}
  {$warn 6018 off}
  {$endif}
{$endif}
uses
 classes,mclasses,mdb,msetimer,msebufdataset,msqldb,msedb,msestrings,
 msedatabase,mseclasses,msetypes,msesqlresult;

type
 tsqlquery = class;
 tsqlmasterparamsdatalink = class(tmasterparamsdatalink)
  private
   fquery: tsqlquery;
   frefreshlock: integer;
//   fdelayus: integer;
   ftimer: tsimpletimer;
  protected
   procedure domasterdisable; override;
   procedure domasterchange; override;
   procedure CheckBrowseMode; override;
   procedure DataEvent(Event: TDataEvent; Info: Ptrint); override;
   procedure checkrefresh; //makes pending delayed refresh
   procedure dorefresh(const sender: tobject);
  public
   constructor create(const aowner: tsqlquery); reintroduce;
   destructor destroy; override;
   Procedure RefreshParamNames; override;
   Procedure CopyParamsFromMaster(CopyBound : Boolean); override;
//  published
//   property delayus: integer read fdelayus write fdelayus default -1;
 end;

 sqlquerystatety = (sqs_userapplyrecupdate,sqs_updateabort,sqs_updateerror);
 sqlquerystatesty = set of sqlquerystatety;

 tupdatestringlist = class(tsqlstringlist)
 end;

 tsqlquery = class (tmsebufdataset,isqlclient,icursorclient)
  private
   fcursor: tsqlcursor;
   fupdateable: boolean;
   fsql: tsqlstringlist;
//   fsqlupdate,fsqlinsert: tupdatesqlstringlist;
//   fsqldelete: tsqlstringlist;
   fiseof: boolean;
   floadingfielddefs: boolean;
   findexdefs: tindexdefs;
   fupdatemode: tupdatemode;
   fparams: tmseparams;
   fuseprimarykeyaskey: boolean;
   fsqlbuf: msestring;
   fsqlprepbuf: msestring;
   ffrompart: msestring;
   fwherestartpos: integer;
   fwherestoppos: integer;
   fparsesql: boolean;
   fstatementtype: tstatementtype;
   fmasterlink: tsqlmasterparamsdatalink;
   fapplyqueries: array[tupdatekind] of tsqlresult;
   fapplysql: array[tupdatekind] of tupdatestringlist;
//   fupdateqry,fdeleteqry,finsertqry: tsqlquery;
   fupdaterowsaffected: integer;
   fblobintf: iblobconnection;
   fbeforeexecute: tcustomsqlstatement;
   faftercursorclose: tcustomsqlstatement;
   fmasterdelayus: integer;
   procedure freefldbuffers;
   function getindexdefs : tindexdefs;
//   function getstatementtype : tstatementtype;
   procedure setindexdefs(avalue : tindexdefs);
   procedure setreadonly(avalue : boolean);
   procedure setparsesql(avalue : boolean);
   procedure setstatementtype(const avalue: tstatementtype);
   procedure setuseprimarykeyaskey(avalue : boolean);
   procedure setupdatemode(avalue : tupdatemode);
   procedure onchangesql(const sender : tobject);
   procedure onchangemodifysql(const sender : tobject);
   procedure execute;
   procedure sqlparser(var asql: msestring);
   procedure applyfilter;
   function addfilter(sqlstr : msestring) : msestring;
   function getdatabase1: tcustomsqlconnection;
   procedure setdatabase1(const avalue: tcustomsqlconnection);
   procedure setparams(const avalue: tmseparams);
   function getconnected: boolean;
   procedure setconnected(const avalue: boolean);
   procedure setfsql(const avalue: tsqlstringlist);
   procedure setfsqlupdate(const avalue: tupdatestringlist);
   procedure setfsqlinsert(const avalue: tupdatestringlist);
   procedure setfsqldelete(const avalue: tupdatestringlist);
   procedure setbeforeexecute(const avalue: tcustomsqlstatement);
   procedure setaftercursorclose(const avalue: tcustomsqlstatement);
   function getsqltransaction: tsqltransaction;
   procedure setsqltransaction(const avalue: tsqltransaction);
   function getsqltransactionwrite: tsqltransaction;
   procedure setsqltransactionwrite(const avalue: tsqltransaction);
   procedure resetparsing;
   procedure dorefresh;
//   procedure setmasterlink(const avalue: tsqlmasterparamsdatalink);
//   procedure setmasterdelayus(const avalue: integer);
   procedure settablename(const avalue: string);
  protected
   fmstate: sqlquerystatesty;
   FTableName: string;
   FReadOnly: boolean;
   fprimarykeyfield: tfield;
   futf8: boolean;
   foptionsmasterlink: optionsmasterlinkty;
   function getdatabase: tcustomconnection; //for isqlpropertyeditor
   procedure settransactionwrite(const avalue: tmdbtransaction); override;
   procedure checkpendingupdates; virtual;
   procedure notification(acomponent: tcomponent; operation: toperation); override;
   // abstract & virtual methods of TBufDataset
   function Fetch : boolean; override;
   function getblobdatasize: integer; override;
   function getnumboolean: boolean; virtual;
   function getfloatdate: boolean; virtual;
   function getint64currency: boolean; virtual;
   function blobscached: boolean; override;
   function loadfield(const afieldno: integer; const afieldtype: tfieldtype;
           const buffer: pointer; var bufsize: integer): boolean; override;
          //if bufsize < 0 -> buffer was to small, should be -bufsize
   // abstract & virtual methods of TDataset
//   procedure dscontrolleroptionschanged(const aoptions: datasetoptionsty);
   procedure updateindexdefs; override;
   procedure setdatabase(const value: tmdatabase); override;
   procedure settransaction(const value : tmdbtransaction); override;
   procedure internaladdrecord(buffer: pointer; aappend: boolean); override;
   procedure internalclose; override;
   procedure internalinitfielddefs; override;
   procedure connect(const aexecute: boolean);
   procedure freemodifyqueries;
   procedure freequery;
   procedure disconnect{(const aexecute: boolean)};
   procedure checkrecursivedatasource(const avalue: tdatasource);
   procedure internalopen; override;
   procedure internalrefresh; override;
   procedure refreshtransaction; override;
   procedure dobeforeedit; override;
   procedure dobeforeinsert; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;

   function  getcanmodify: boolean; override;
   procedure updatewherepart(var sql_where : msestring; const afield: tfield);
   procedure internalapplyrecupdate(updatekind : tupdatekind);
   procedure dobeforeapplyupdate; override;
   procedure applyrecupdate(updatekind : tupdatekind); override;
   function isprepared: boolean; virtual;
   Procedure SetActive (Value : Boolean); override;
   procedure SetFiltered(Value: Boolean); override;
   procedure SetFilterText(const Value: string); override;
   Function GetDataSource : TDatasource; override;
   Procedure SetDataSource(AValue : TDatasource);
    //icursorclient
   function stringmemo: boolean; virtual;
        //memo fields are text(0) fields
  public
   constructor Create(AOwner : TComponent); override;
   destructor Destroy; override;
   function isutf8: boolean; override;
   procedure applyupdate(const cancelonerror: boolean;
                const cancelondeleteerror: boolean = false;
                const editonerror: boolean = false); override;
   procedure applyupdates(const maxerrors: integer;
                const cancelonerror: boolean;
                const cancelondeleteerror: boolean = false;
                const editonerror: boolean = false); override;
   function refreshrecquery(const update: boolean): msestring;
   procedure checktablename;
   function updaterecquery : msestring;
   function insertrecquery : msestring;
   function deleterecquery : msestring;
   function writetransaction: tsqltransaction;
                  //self.transaction if self.transactionwrite = nil
   procedure refresh(const aparams: array of variant); overload;
   procedure Prepare; virtual;
   procedure UnPrepare; virtual;
   procedure ExecSQL; virtual;
   function executedirect(const asql: msestring): integer;
             //uses writetransaction of tsqlquery
   function rowsreturned: integer; //-1 if not supported
   function rowsaffected: integer; //-1 if not supported
   property updaterowsaffected: integer read fupdaterowsaffected;
          //sum of rowsaffected of insert, update and delete query,
          //reset by close, applyupdate and applyupdates, -1 if not supported.
//   procedure SetSchemaInfo( SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string); virtual;
   function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
   property Prepared : boolean read IsPrepared;
   property connected: boolean read getconnected write setconnected;
  published
   property ReadOnly : Boolean read FReadOnly write SetReadOnly default false;
   property ParseSQL : Boolean read FParseSQL write SetParseSQL default true;
   property params : tmseparams read fparams write setparams;
                       //before SQL
   property SQL : tsqlstringlist read FSQL write setFSQL;
   property SQLUpdate : tupdatestringlist read Fapplysql[ukmodify]
                                                         write setFSQLUpdate;
   property SQLInsert : tupdatestringlist read Fapplysql[ukinsert]
                                                         write setFSQLInsert;
   property SQLDelete : tupdatestringlist read Fapplysql[ukdelete]
                                                         write setFSQLDelete;
   property beforeexecute: tcustomsqlstatement read fbeforeexecute write setbeforeexecute;
   property aftercursorclose: tcustomsqlstatement read faftercursorclose
                                                write setaftercursorclose;
   property IndexDefs : TIndexDefs read GetIndexDefs;
   property UpdateMode : TUpdateMode read FUpdateMode write SetUpdateMode;
   property UsePrimaryKeyAsKey : boolean read FUsePrimaryKeyAsKey write SetUsePrimaryKeyAsKey;
   property tablename: string read ftablename write settablename;
   property StatementType : TStatementType read fstatementtype
                           write setstatementtype default stnone;
   Property DataSource : TDatasource Read GetDataSource Write SetDatasource;
   property masterdelayus: integer read fmasterdelayus
                                write fmasterdelayus default -1;
   property optionsmasterlink: optionsmasterlinkty read foptionsmasterlink
                                     write foptionsmasterlink default [];
 //   property masterlink: tsqlmasterparamsdatalink read fmasterlink
 //                     write setmasterlink;
   property database: tcustomsqlconnection read getdatabase1 write setdatabase1;

//    property SchemaInfo : TSchemaInfo read FSchemaInfo default stNoSchema;
    // redeclared data set properties
   property Active;
   property Filter;
   property Filtered;
//    property FilterOptions;
   property BeforeOpen;
   property AfterOpen;
   property BeforeClose;
   property AfterClose;
   property BeforeInsert;
   property AfterInsert;
   property BeforeEdit;
   property AfterEdit;
   property BeforePost;
   property AfterPost;
   property BeforeCancel;
   property AfterCancel;
   property BeforeDelete;
   property AfterDelete;
   property BeforeScroll;
   property AfterScroll;
   property BeforeRefresh;
   property AfterRefresh;
   property OnCalcFields;
   property OnDeleteError;
   property OnEditError;
   property OnFilterRecord;
   property OnNewRecord;
   property OnPostError;
   property onmodified;
   property AutoCalcFields;
//    property Database;

   property Transaction: tsqltransaction read getsqltransaction write setsqltransaction;
   property transactionwrite: tsqltransaction read getsqltransactionwrite
                                    write setsqltransactionwrite;
  end;

procedure querytoupdateparams(const source: tsqlquery; const dest: tparams);
function SkipComments(var p: PmseChar) : boolean;

implementation
uses
 sysutils,{$ifdef FPC}dbconst{$else}dbconst_del,classes_del{$endif},msearrayutils,typinfo;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
 {$if fpc_fullversion >= 030300}
  {$warn 6060 off}
  {$warn 6018 off}
  {$endif}
{$endif}
type
 tcustomsqlconnection1 = class(tcustomsqlconnection);
 tcustomsqlstatement1 = class(tcustomsqlstatement);
 tsqltransaction1 = class(tsqltransaction);
 tsqlresult1 = class(tsqlresult);
 tdataset1 = class(tdataset);

function SkipComments(var p: PmseChar) : boolean;
begin
  result := false;
  case p^ of
    '''': // single quote delimited string
      begin
        Inc(p);
        Result := True;
        while not ((p^ = #0) or (p^ = '''')) do
        begin
          if p^='\' then Inc(p,2) // make sure we handle \' and \\ correct
          else Inc(p);
        end;
        if p^='''' then Inc(p); // skip final '
      end;
    '"':  // double quote delimited string
      begin
        Inc(p);
        Result := True;
        while not ((p^ = #0) or (p^ = '"')) do
        begin
          if p^='\'  then Inc(p,2) // make sure we handle \" and \\ correct
          else Inc(p);
        end;
        if p^='"' then Inc(p); // skip final "
      end;
    '-': // possible start of -- comment
      begin
        Inc(p);
        if p^='-' then // -- comment
        begin
          Result := True;
          repeat // skip until at end of line
            Inc(p);
          until (p^ = #10) or (p^ = #0);
        end
      end;
    '/': // possible start of /* */ comment
      begin
        Inc(p);
        if p^='*' then // /* */ comment
        begin
          Result := True;
          repeat
            Inc(p);
            if p^='*' then // possible end of comment
            begin
              Inc(p);
              if p^='/' then Break; // end of comment
            end;
          until p^=#0;
          if p^='/' then Inc(p); // skip final /
        end;
      end;
  end; {case}
end;

procedure querytoupdateparams(const source: tsqlquery; const dest: tparams);
var
 x: integer;
 param1,param2: tparam;
 fld: tfield;
begin
 for x := 0 to dest.Count-1 do begin
  param1:= dest[x];
  with param1 do begin
   if leftstr(name,4)='OLD_' then begin
    Fld:= source.FieldByName(copy(name,5,length(name)-4));
    source.oldfieldtoparam(fld,param1);
//     AssignFieldValue(Fld,Fld.OldValue);
   end
   else begin
    fld:= source.findfield(name);
    if fld = nil then begin     //search for param
     param2:= source.params.findparam(name);
     if param2 = nil then begin
      source.fieldbyname(name); //raise exception
     end
     else begin
      value:= param2.value;
     end;
    end
    else begin             //use field
     source.fieldtoparam(fld,param1);
    end;
   end;
  end;
 end;
end;

{ tsqlmasterparamsdatalink }

constructor tsqlmasterparamsdatalink.create(const aowner: tsqlquery);
begin
 fquery:= aowner;
 inherited create(aowner);
end;

destructor tsqlmasterparamsdatalink.destroy;
begin
 freeandnil(ftimer);
 inherited;
end;

procedure tsqlmasterparamsdatalink.dorefresh(const sender: tobject);
begin
 if Assigned(Params) and Assigned(DetailDataset) and
                                 DetailDataset.Active then begin
  detaildataset.refresh;
 end;
end;

procedure tsqlmasterparamsdatalink.checkrefresh;
begin
 if ftimer <> nil then begin
  ftimer.firependingandstop; //cancel wait
 end;
end;

procedure tsqlmasterparamsdatalink.domasterchange;
var
 intf: igetdscontroller;
begin
 if (frefreshlock = 0) and
    (not getcorbainterface(dataset,typeinfo(igetdscontroller),intf) or
      not intf.getcontroller.posting) then begin
  if assigned(onmasterchange) then begin
   onmasterchange(self);
  end;
  if assigned(params) and assigned(detaildataset) and
                (detaildataset.state = dsbrowse) and
                 not (mdlo_norefresh in fquery.foptionsmasterlink) then begin
   if fquery.masterdelayus < 0 then begin
    freeandnil(ftimer);
    dorefresh(nil);
   end
   else begin
    if ftimer = nil then begin
     ftimer:= tsimpletimer.create(fquery.masterdelayus,
                      {$ifdef FPC}@{$endif}dorefresh,true,[to_single]);
    end
    else begin
     ftimer.interval:= fquery.masterdelayus; //single shot
     ftimer.enabled:= true;
    end;
   end;
  end;
 end;
end;

procedure tsqlmasterparamsdatalink.domasterdisable;
var
 intf: imasterlink;
begin
 if (dataset = nil) or
          not getcorbainterface(dataset,typeinfo(imasterlink),intf) or
          not intf.refreshing then begin
  if assigned(onmasterdisable) then begin
   onmasterdisable(self);
  end;
  if assigned(detaildataset) and detaildataset.active then begin
   detaildataset.close;
  end;
 end;
end;

procedure tsqlmasterparamsdatalink.DataEvent(Event: TDataEvent; Info: Ptrint);
begin
 inherited;
 with tsqlquery(detaildataset) do begin
  if active then begin
   case ord(event) of
    ord(deupdaterecord): begin
     if state in [dsinsert,dsedit] then begin
      updaterecord;
      if modified then begin
       tdataset1(dataset).setmodified(true); //FPC fixes_2_6 compatibility
//       dataset.modified:= true;
      end;
     end;
    end;
    ord(deupdatestate): begin
     if (mdlo_syncedit in foptionsmasterlink) and
         (dataset.state = dsedit) and not (state = dsedit) then begin
      edit;
     end;
     if (mdlo_syncinsert in foptionsmasterlink) and
         (dataset.state = dsinsert) and not (state = dsinsert) then begin
      insert;
     end;
    end;
    ord(de_afterdelete): begin
     if (mdlo_syncdelete in foptionsmasterlink) then begin
      delete;
     end;
    end;
    ord(de_afterpost): begin
     if (mdlo_delayeddetailpost in foptionsmasterlink) then begin
      if (mdlo_inserttoupdate in foptionsmasterlink) and
             (state = dsinsert) then begin
       tdataset1(detaildataset).setmodified(true); //FPC fixes_2_6 compatibility
//       detaildataset.modified:= true;
       include(fbstate,bs_inserttoupdate);
       try
        detaildataset.checkbrowsemode;
       finally
        exclude(fbstate,bs_inserttoupdate);
       end;
      end
      else begin
       detaildataset.checkbrowsemode;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tsqlmasterparamsdatalink.CheckBrowseMode;
label
 endlab;
var
 intf: igetdscontroller;
 detailoptions: optionsmasterlinkty;
begin
 if detaildataset.active then begin
  inc(frefreshlock);
  try
   detailoptions:= tsqlquery(detaildataset).foptionsmasterlink;
   if detailoptions *
         [mdlo_syncedit,mdlo_syncinsert] <> [] then begin
    if getcorbainterface(dataset,typeinfo(igetdscontroller),intf) and
                                       intf.getcontroller.canceling then begin
     detaildataset.cancel;
     exit;
    end
    else begin
     if mdlo_delayeddetailpost in detailoptions then begin
      exit;
     end;
     if detaildataset.state = dsinsert then begin
      dataset.updaterecord;
      if dataset.modified then begin
       detaildataset.post;
       goto endlab;
      end;
     end;
    end;
   end;
   inherited;
  endlab:
   if (dataset.state in [dsedit,dsinsert]) and
         (detailoptions * [mdlo_syncedit,mdlo_syncinsert] <> []) then begin
    dataset.updaterecord; //synchronize fields
   end;
   if getcorbainterface(detaildataset,typeinfo(igetdscontroller),intf) then begin
    with intf.getcontroller do begin
     if (dataset.state = dsinsert) and assigned(onupdatemasterinsert) then begin
      onupdatemasterinsert(detaildataset,dataset);
     end;
     if (dataset.state = dsedit) and assigned(onupdatemasteredit) then begin
      onupdatemasteredit(detaildataset,dataset);
     end;
    end;
   end;
  finally
   dec(frefreshlock);
  end;
 end;
end;

procedure tsqlmasterparamsdatalink.CopyParamsFromMaster(CopyBound: Boolean);
begin
 if not (mdlo_norefresh in fquery.foptionsmasterlink) then begin
  inherited;
 end;
end;

procedure tsqlmasterparamsdatalink.RefreshParamNames;
begin
 if not (mdlo_norefresh in fquery.foptionsmasterlink) then begin
  inherited;
 end
 else begin
  fieldnames:= '';
 end;
end;

{ TSQLQuery }

constructor TSQLQuery.Create(AOwner : TComponent);
var
 k1: tupdatekind;
begin
 fmasterdelayus:= -1;
  inherited Create(AOwner);
  FParams := TmseParams.create(self);
  FSQL := TsqlStringList.Create;
  FSQL.OnChange := {$ifdef FPC}@{$endif}OnChangeSQL;

  for k1:= low(tupdatekind) to high(tupdatekind) do begin
   fapplysql[k1]:= tupdatestringlist.create;
   fapplysql[k1].onchange:= {$ifdef FPC}@{$endif}onchangemodifysql;
  end;
  {
  FSQLUpdate := TupdatesqlStringList.Create;
  FSQLUpdate.OnChange := @OnChangeModifySQL;
  FSQLInsert := TupdatesqlStringList.Create;
  FSQLInsert.OnChange := @OnChangeModifySQL;
  FSQLDelete := TsqlStringList.Create;
  FSQLDelete.OnChange := @OnChangeModifySQL;
}
  FIndexDefs := TIndexDefs.Create(Self);
  FReadOnly := false;
  FParseSQL := True;
  fstatementtype:= stnone;
// Delphi has upWhereAll as default, but since strings and oldvalue's don't work yet
// (variants) set it to upWhereKeyOnly
  FUpdateMode := upWhereKeyOnly;
  FUsePrimaryKeyAsKey := True;
end;

destructor TSQLQuery.Destroy;
var
 k1: tupdatekind;
begin
  if Active then Close;
  UnPrepare;
  if assigned(FCursor) then (Database as tcustomsqlconnection).DeAllocateCursorHandle(FCursor);
  FreeAndNil(FMasterLink);
  FreeAndNil(FParams);
  FreeAndNil(FSQL);
  for k1:= low(tupdatekind) to high(tupdatekind) do begin
   freeandnil(fapplyqueries[k1]);
   freeandnil(fapplysql[k1]);
  end;
  {
  FreeAndNil(FSQLInsert);
  FreeAndNil(FSQLDelete);
  FreeAndNil(FSQLUpdate);
  }
  FreeAndNil(FIndexDefs);
  {
  freeandnil(finsertqry);
  freeandnil(fupdateqry);
  freeandnil(fdeleteqry);
  }
  inherited Destroy;
end;

procedure TSQLQuery.OnChangeSQL(const Sender : TObject);

//var ParamName : String;
begin
  UnPrepare;
  if (FSQL <> nil) then
    begin
    FParams.ParseSQL(FSQL.Text,True);
    If Assigned(FMasterLink) then
      FMasterLink.RefreshParamNames;
    end;
end;

procedure TSQLQuery.OnChangeModifySQL(const Sender : TObject);
var
 k1: tupdatekind;
begin
 if not (csdesigning in componentstate) then begin
//  CheckInactive;
  if connected then begin
   for k1:= low(tupdatekind) to high(tupdatekind) do begin
    if sender = fapplysql[k1] then begin
     with fapplyqueries[k1] do begin
      active:= false;
      sql.assign(fapplysql[k1]);
     end;
     break;
    end;
   end;
  end;
 end;
end;

Procedure TSQLQuery.SetTransaction(const Value : tmdbtransaction);
begin
 if ftransaction <> value then begin
  checksqltransaction(name,value);
  UnPrepare;
  inherited;
 end;
end;

procedure TSQLQuery.SetDatabase(const Value : tmdatabase);
begin
 dosetsqldatabase(isqlclient(self),value,fcursor,fdatabase);
{
 if (fDatabase <> Value) then begin
  checksqlconnection(name,value);
  UnPrepare;
  if assigned(FCursor) then begin
   tcustomsqlconnection(database).DeAllocateCursorHandle(FCursor);
  end;
  dosetsqldatabase(isqlclient(self),tcustomsqlconnection(value),
                                          tcustomsqlconnection(fdatabase));
  }
  {
  inherited setdatabase(value);
  with tcustomsqlconnection(value) do begin
   if (value <> nil) and (self.Transaction = nil) and
                   (Transaction <> nil) then begin
    self.transaction:= Transaction;
   end;
  end;
  }
// end;
end;

Function TSQLQuery.IsPrepared : Boolean;

begin
  Result := Assigned(FCursor) and FCursor.FPrepared;
end;

Function TSQLQuery.AddFilter(SQLstr : msestring) : msestring;

begin
  if FWhereStartPos = 0 then
    SQLstr := SQLstr + ' where (' + msestring(Filter) + ')'
  else if FWhereStopPos > 0 then
    system.insert(' and ('+msestring(Filter)+') ',SQLstr,FWhereStopPos+1)
  else
    system.insert(' where ('+msestring(Filter)+') ',SQLstr,FWhereStartPos);
  Result := SQLstr;
end;

procedure tsqlquery.applyfilter;
//var
// s: string;
begin
 freefldbuffers;
 tcustomsqlconnection(database).unpreparestatement(fcursor);
 fiseof := false;
 inherited internalclose;
 if filtered and (filter <> '') then begin
  fsqlprepbuf:= addfilter(fsqlbuf);
 end
 else begin
  fsqlprepbuf:= fsqlbuf;
 end;
 if not (bdo_noprepare in foptions) then begin
  tcustomsqlconnection(database).preparestatement(fcursor,
                             tsqltransaction(transaction),fsqlprepbuf,fparams);
 end;
 execute;
 inherited internalopen;
 first;
end;

Procedure TSQLQuery.SetActive (Value : Boolean);

begin
  inherited SetActive(Value);
// The query is UnPrepared, so that if a transaction closes all datasets
// they also get unprepared
  if not Value and IsPrepared then UnPrepare;
end;


procedure TSQLQuery.SetFiltered(Value: Boolean);

begin
 if Value and not FParseSQL and (filter <> '') then begin
  DatabaseErrorFmt(SNoParseSQL,['Filtering ']);
 end;
 if (Filtered <> Value) then begin
  inherited setfiltered(Value);
  if active then begin
   if filter <> '' then begin
    ApplyFilter;
   end
   else begin
    resync([]);
   end;
  end;
 end;
end;

procedure TSQLQuery.SetFilterText(const Value: string);
begin
  if Value <> Filter then
    begin
    inherited SetFilterText(Value);
    if active then ApplyFilter;
    end;
end;

procedure tsqlquery.refresh(const aparams: array of variant);
var
 i1: int32;
begin
 for i1:= 0 to high(aparams) do begin
  params[i1].value:= aparams[i1];
 end;
 if active then begin
  inherited refresh();
 end
 else begin
  active:= true;
 end;
end;

procedure TSQLQuery.Prepare;
var
 db: tcustomsqlconnection;
 sqltr: tsqltransaction;
 int1: integer;
const
 endchars = ' '#$09#$0a#$0d;
begin
 if not IsPrepared then begin
  db:= tcustomsqlconnection(database);
  sqltr:= tsqltransaction(transaction);
  checkdatabase(name,db);
  checktransaction(name,sqltr);

  if not Db.Connected then begin
   db.Open;
  end;
  if not sqltr.Active then begin
   sqltr.StartTransaction;
  end;

  if not assigned(fcursor) then begin
   FCursor:= Db.AllocateCursorHandle(icursorclient(self),name);
  end;
  fcursor.ftrans:= sqltr.handle;

  FSQLBuf:= TrimRight(FSQL.Text);

  if FSQLBuf = '' then begin
    DatabaseError(SErrNoStatement);
  end;
  SQLParser(FSQLBuf);

  if filtered and (filter <> '') then begin
   fsqlprepbuf:= AddFilter(FSQLBuf);
  end
  else begin
   fsqlprepbuf:= fsqlbuf;
  end;
  if not (bdo_noprepare in foptions) then begin
   Db.PrepareStatement(Fcursor,sqltr,fsqlprepBuf,FParams);
  end;
//  ftablename:= '';
  if (FCursor.FStatementType in datareturningtypes) then begin
   FCursor.FInitFieldDef := True;
   fupdateable:= not readonly and
         (
         (sqs_userapplyrecupdate in fmstate) or
         (fapplysql[ukmodify].count > 0) and
         (fapplysql[ukinsert].count > 0) and
         (fapplysql[ukdelete].count > 0)
         );
   if fparsesql and (pos(',',FFromPart) <= 0) then begin
            //don't change tablename otherwise
    ftablename:= ansistring(ffrompart);
    int1:= findchars(ftablename,endchars);
    if int1 > 0 then begin
     setlength(ftablename,int1-1); //use real name only
    end;
//    fupdateable:= not readonly;
   end;
   fupdateable:= fupdateable or not readonly and (ftablename <> '');
  end;
 end;
end;

procedure TSQLQuery.UnPrepare;

begin
 if connected then begin
  CheckInactive;
 end;
 if IsPrepared and not (bs_refreshing in fbstate) then begin
  with tcustomsqlconnection(Database) do begin
   UnPrepareStatement(FCursor);
  end;
 end;
end;

procedure TSQLQuery.FreeFldBuffers;
begin
 if not (bs_refreshing in fbstate) and assigned(FCursor) then begin
  tcustomsqlconnection(database).FreeFldBuffers(FCursor);
 end;
end;

function TSQLQuery.Fetch : boolean;
begin
 if not (Fcursor.FStatementType in datareturningtypes) then begin
  result:= false;
  Exit;
 end;
 if not FIsEof then begin
  FIsEOF:= not tcustomsqlconnection(database).Fetch(Fcursor);
  if fiseof then begin
   fcursor.close;
  end;
 end;
 Result := not FIsEOF;
end;

procedure TSQLQuery.Execute;
var
// int1: integer;
 bo1: boolean;
begin
 If (FParams.Count>0) and Assigned(FMasterLink) then begin
  FMasterLink.CopyParamsFromMaster(False);
 end;
 bo1:= isutf8;
 updateparams(fparams,bo1);
 fcursor.ftrans:= tsqltransaction(ftransaction).handle;
 if bdo_noprepare in foptions then begin
  tcustomsqlconnection1(fdatabase).executeunprepared(fcursor,
               tsqltransaction(ftransaction),fParams,fsqlprepbuf,bo1);
 end
 else begin
  tcustomsqlconnection1(fdatabase).execute(fcursor,
              tsqltransaction(ftransaction),fParams,bo1);
 end;
// doexecute(fparams,ftransaction,fcursor,fdatabase,isutf8);
end;

function tsqlquery.loadfield(const afieldno: integer;
                     const afieldtype: tfieldtype; const buffer: pointer;
                     var bufsize: integer): boolean;
           //if bufsize < 0 -> buffer was to small, should be -bufsize
begin
 result:= tcustomsqlconnection(database).LoadField(FCursor,aFieldtype,
         afieldno,buffer,bufsize,isutf8)
end;

procedure TSQLQuery.InternalAddRecord(Buffer: Pointer; AAppend: Boolean);
begin
  // not implemented - sql dataset
end;

procedure tsqlquery.freemodifyqueries;
var
 k1: tupdatekind;
begin
 fbstate:= fbstate - [bs_refreshinsert,bs_refreshupdate,
                      bs_refreshinsertindex,bs_refreshupdateindex];
 for k1:= low(tupdatekind) to high(tupdatekind) do begin
  freeandnil(fapplyqueries[k1]);
 end;
 {
 FreeAndNil(FUpdateQry);
 FreeAndNil(FInsertQry);
 FreeAndNil(FDeleteQry);
 }
end;

procedure tsqlquery.freequery;
begin
 if not (bs_refreshing in fbstate) then begin
  if ({not }IsPrepared) and (assigned(database)) and (assigned(FCursor)) then begin
        tcustomsqlconnection(database).UnPrepareStatement(FCursor);
  end;
  if ftransactionwrite = nil then begin
   freemodifyqueries;
  end;
 end;
end;

procedure TSQLQuery.disconnect{(const aexecute: boolean)};
begin
 if bs_connected in fbstate then begin
  if fcursor <> nil then begin
   fcursor.close;
  end;
  freequery;
  if not (bs_refreshing in fbstate) then begin
   database.deallocatecursorhandle(fcursor);
  end;
  exclude(fbstate,bs_connected);
   if faftercursorclose <> nil then begin
    tcustomsqlstatement1(faftercursorclose).execute;
//    faftercursorclose.execute(database,tsqltransaction(transaction));
   end;
 end;
end;

procedure TSQLQuery.InternalClose;
begin
// Database and FCursor could be nil, for example if the database is not
// assigned, and .open is called
 try
  disconnect{(true)};
 finally
  if not (bs_refreshing in fbstate) then begin
   freemodifyqueries;
   fprimarykeyfield:= nil;
   if DefaultFields then begin
    DestroyFields;
   end;
  end;
  fupdaterowsaffected:= 0;
  fblobintf:= nil;
//  if StatementType in datareturningtypes then FreeFldBuffers;
  FIsEOF := False;
  inherited internalclose;
 end;
end;

procedure TSQLQuery.InternalInitFieldDefs;
begin
 if FLoadingFieldDefs then begin
  Exit;
 end;
 FLoadingFieldDefs := True;
 try
  tcustomsqlconnection(database).AddFieldDefs(fcursor,FieldDefs);
 finally
  FLoadingFieldDefs := False;
 end;
end;

procedure tsqlquery.resetparsing;
begin
 FWhereStartPos := 0;
 FWhereStopPos := 0;
 ffrompart:= '';
// ftablename:= '';
end;

procedure TSQLQuery.SQLParser(var ASQL: msestring);

type TParsePart = (ppStart,ppSelect,ppWhere,ppFrom,ppGroup,ppOrder,ppComment,ppBogus);

Var
  PSQL,CurrentP,
  PhraseP, PStatementPart : pmsechar;
  S                       : msestring;
  ParsePart               : TParsePart;
  StrLength               : Integer;

begin
 PSQL:=Pmsechar(ASQL);
 ParsePart := ppStart;
 PStatementPart:= nil;
 CurrentP := PSQL-1;
 PhraseP := PSQL;
 resetparsing;

 repeat begin
 	inc(CurrentP);

  if SkipComments(CurrentP) then
   if ParsePart = ppStart then PhraseP := CurrentP;
 	if (currentp^<#128) and
         (char(byte(CurrentP^)) in [' ',#13,#10,#9,#0,'(',')',';']) then begin { if(1) }
   if (CurrentP-PhraseP > 0) or (CurrentP^ = ';') or
                                      (currentp^ = #0) then begin { if(2) }
		strLength := CurrentP-PhraseP;
		Setlength(S,strLength);

		if strLength > 0 then Move(PhraseP^,S[1],strLength*sizeof(msechar));
		s := uppercase(s);

		case ParsePart of
		    ppStart  : begin
			FCursor.FStatementType:=
			 tcustomsqlconnection1(database).StrToStatementType(s);

			if FCursor.FStatementType = stSelect then
			    ParsePart := ppSelect
			else
			    break;

			if not FParseSQL then break;
		        PStatementPart := CurrentP;
		    end; {ppStart}
		    ppSelect : begin
			if s = 'FROM' then begin
			    ParsePart := ppFrom;
			    PhraseP := CurrentP;
			    PStatementPart := CurrentP;
			end;
		    end; {ppSelect}
		    ppFrom   : begin

			if (s = 'WHERE') or (s = 'GROUP') or (s = 'ORDER') or (CurrentP^=#0) or (CurrentP^=';') then begin
			    if (s = 'WHERE') then begin
			        ParsePart := ppWhere;
			        StrLength := PhraseP-PStatementPart;
			    end else if (s = 'GROUP') then begin
			        ParsePart := ppGroup;
			        StrLength := PhraseP-PStatementPart
			    end else if (s = 'ORDER') then begin
			        ParsePart := ppOrder;
			        StrLength := PhraseP-PStatementPart
			    end else begin
			        ParsePart := ppBogus;
			        StrLength := CurrentP-PStatementPart;
			    end;

			    Setlength(FFromPart,StrLength);
			    Move(PStatementPart^,FFromPart[1],StrLength*sizeof(msechar));
			    FFrompart := trim(FFrompart);
			    FWhereStartPos := PStatementPart-PSQL+StrLength+1;
			    PStatementPart := CurrentP;
			end;

		    end; {ppFrom}
		    ppWhere  : begin
			if (s = 'GROUP') or (s = 'ORDER') or (CurrentP^=#0) or (CurrentP^=';') then begin
			    ParsePart := ppBogus;
			    FWhereStartPos := PStatementPart-PSQL;

			    if (s = 'GROUP') or (s = 'ORDER') then
			        FWhereStopPos := PhraseP-PSQL+1
			    else
			        FWhereStopPos := CurrentP-PSQL+1;
			    end;
			end;
		    end; {ppWhere}

		end; {case}

		PhraseP := CurrentP+1;
	    end; { if(2) }
	end; { if(1) }
    until CurrentP^=#0; {repeat}

 if (FWhereStartPos > 0) and (FWhereStopPos > 0) and
              filtered and (filter <> '') then begin
 	system.insert('(',ASQL,FWhereStartPos+1);
 	inc(FWhereStopPos);
 	system.insert(')',ASQL,FWhereStopPos);
 end;
 if not fparsesql and (fstatementtype <> stnone) then begin
  fCursor.FStatementType := fstatementtype;
 end;
//writeln(ASQL);
end;
(*
procedure TSQLQuery.SQLParser(var ASQL : string);

type TParsePart = (ppStart,ppSelect,ppWhere,ppFrom,ppOrder,ppComment,ppBogus);

Var
  PSQL,CurrentP,
  PhraseP, PStatementPart : pchar;
  S                       : string;
  ParsePart               : TParsePart;
  StrLength               : Integer;

begin
  PSQL:=Pchar(ASQL);
  ParsePart := ppStart;

  CurrentP := PSQL-1;
  PhraseP := PSQL;

  FWhereStartPos := 0;
  FWhereStopPos := 0;

  repeat
    begin
    inc(CurrentP);

    if CurrentP^ in [' ',#13,#10,#9,#0,'(',')',';'] then
      begin
      if (CurrentP-PhraseP > 0) or (CurrentP^ in [';',#0]) then
        begin
        strLength := CurrentP-PhraseP;
        Setlength(S,strLength);
        if strLength > 0 then Move(PhraseP^,S[1],(strLength));
        s := uppercase(s);

        case ParsePart of
          ppStart  : begin
                     FCursor.FStatementType := (Database as tcustomsqlconnection).StrToStatementType(s);
                     if FCursor.FStatementType = stSelect then ParsePart := ppSelect
                       else break;
                     if not FParseSQL then break;
                     PStatementPart := CurrentP;
                     end;
          ppSelect : begin
                     if s = 'FROM' then
                       begin
                       ParsePart := ppFrom;
                       PhraseP := CurrentP;
                       PStatementPart := CurrentP;
                       end;
                     end;
          ppFrom   : begin
                     if (s = 'WHERE') or (s = 'ORDER') or (CurrentP^=#0) or (CurrentP^=';') then
                       begin
                       if (s = 'WHERE') then
                         begin
                         ParsePart := ppWhere;
                         StrLength := PhraseP-PStatementPart;
                         end
                       else if (s = 'ORDER') then
                         begin
                         ParsePart := ppOrder;
                         StrLength := PhraseP-PStatementPart
                         end
                       else
                         begin
                         ParsePart := ppBogus;
                         StrLength := CurrentP-PStatementPart;
                         end;
                       Setlength(FFromPart,StrLength);
                       Move(PStatementPart^,FFromPart[1],(StrLength));
                       FFrompart := trim(FFrompart);
                       FWhereStartPos := PStatementPart-PSQL+StrLength+1;
                       PStatementPart := CurrentP;
                       end;
                     end;
          ppWhere  : begin
                     if (s = 'ORDER') or (CurrentP^=#0) or (CurrentP^=';') then
                       begin
                       ParsePart := ppBogus;
                       FWhereStartPos := PStatementPart-PSQL;
                       if s = 'ORDER' then
                         FWhereStopPos := PhraseP-PSQL+1
                       else
                         FWhereStopPos := CurrentP-PSQL+1;
                       end;
                     end;
        end; {case}
        end;
      PhraseP := CurrentP+1;
      end
    end;
  until CurrentP^=#0;
  if (FWhereStartPos > 0) and (FWhereStopPos > 0) then
    begin
    system.insert('(',ASQL,FWhereStartPos+1);
    inc(FWhereStopPos);
    system.insert(')',ASQL,FWhereStopPos);
    end
end;
*)
{
procedure TSQLQuery.InitUpdates(ASQL : string);
begin
 if pos(',',FFromPart) > 0 then begin
  FUpdateable:= (fsqlupdate.count > 0) and (fsqlinsert.count > 0) and
                         (fsqldelete.count > 0);
           // select-statements from more then one table are not updateable
 end
 else begin
  FUpdateable := True;
  FTableName := FFromPart;
 end;
end;
}

procedure tsqlquery.connect(const aexecute: boolean);
var
 tel{,fieldc}: integer;
 f: TField;
// s: string;
 ar1: stringarty;
 IndexFields: stringarty;
 str1: string;
 int1: integer;
 k1: tupdatekind;
begin
 if database <> nil then begin
  getcorbainterface(database,typeinfo(iblobconnection),fblobintf);
 end;
 if not streamloading then begin
  try
   Prepare;
   if FCursor.FStatementType in datareturningtypes then begin
    indexfields:= nil;
    if FUpdateable then begin
     if FusePrimaryKeyAsKey and not (bs_refreshing in fbstate) then begin
      UpdateIndexDefs;  //must be before execute because
                        //of MS SQL ODBC one statement per connection limitation
      for tel := 0 to indexdefs.count-1 do  begin
       if ixPrimary in indexdefs[tel].options then begin
        ar1:= nil;
        splitstringquoted(indexdefs[tel].fields,ar1,'"',';');
        stackarray(ar1,indexfields);
       end;
      end;
     end;
    end;

    if aexecute then begin
     if fbeforeexecute <> nil then begin
      tcustomsqlstatement1(fbeforeexecute).execute;
//      fbeforeexecute.execute(database,tsqltransaction(transaction));
     end;
     Execute;
     if FCursor.FInitFieldDef and not (bs_refreshing in fbstate) then begin
      InternalInitFieldDefs;
     end;
    end;
    if not (bs_refreshing in fbstate) then begin
     if DefaultFields and aexecute then begin
      CreateFields;
     end;
     for int1:= 0 to high(indexfields) do begin
      F := Findfield(IndexFields[int1]);
      if F <> nil then begin
       F.optionsfield:= F.optionsfield + [of_InKey];
      end;
     end;
     if (database <> nil) and (ftablename <> '') then begin
      str1:= tcustomsqlconnection1(database).getprimarykeyfield(
                                                      ftablename,fcursor);
      if (str1 <> '') then begin
       fprimarykeyfield:= fields.findfield(str1);
      end;
     end;
     if fupdateable then begin
      for k1:= low(tupdatekind) to high(tupdatekind) do begin
       if fapplyqueries[k1] = nil then begin
        fapplyqueries[k1]:= tsqlresult.create(nil);
        with fapplyqueries[k1] do begin
         transaction:= self.writetransaction;
         database:= self.database;
         sql.assign(fapplysql[k1]);
         statementtype:= updatestatementtypes[k1];
        end;
       end;
      end;
     end;
    end;
   end
   else begin
    DatabaseError(SErrNoSelectStatement,Self);
   end;
  except
   on E:Exception do
    raise;
  end;
  include(fbstate,bs_connected);
 end;
end;

procedure tsqlquery.internalopen;
{$ifdef mse_debugdataset}
var
 ts: longword;
{$endif}
begin
{$ifdef mse_debugdataset}
 debugoutstart(ts,self,'connect');
{$endif}
 connect(true);
{$ifdef mse_debugdataset}
 debugoutend(ts,self,'connect');
{$endif}
{$ifdef mse_debugdataset}
 debugoutstart(ts,self,'internalopen');
{$endif}
 if fmasterlink <> nil then begin
  checkrecursivedatasource(fmasterlink.datasource);
 end;
 inherited;
{$ifdef mse_debugdataset}
 debugoutend(ts,self,'internalopen');
{$endif}
end;

procedure tsqlquery.dorefresh;
var
 int1: integer;
begin
 int1:= recno;
 include(fbstate,bs_refreshing);
 try
  active:= false;
  active:= true;
  if (recno <> int1) and (bs_restorerecno in fbstate) then begin
   setrecno1(int1,true);
  end;
 finally
  exclude(fbstate,bs_refreshing);
  if not active then begin
   freefieldbuffers;
   freequery;
  end;
 end;
end;

procedure tsqlquery.refreshtransaction;
var
 bo1: boolean;
begin
 if not (bdo_notransactionrefresh in foptions) then begin
  if bdo_recnotransactionrefresh in foptions then begin
   bo1:= bs_restorerecno in fbstate;
   include(fbstate,bs_restorerecno);
   try
    dorefresh;
   finally
    if not bo1 then begin
     exclude(fbstate,bs_restorerecno);
    end;
   end;
  end
  else begin
   dorefresh;
  end;
 end;
end;

procedure tsqlquery.internalrefresh;
begin
 if bdo_refreshtransaction in foptions then begin
  if transaction.savepointlevel < 0 then begin
   transaction.refresh;
  end
  else begin
   transaction.pendingrefresh:= true;
  end;
 end
 else begin
  dorefresh;
 end;
end;

procedure TSQLQuery.ExecSQL;
begin
 try
  Prepare;
  Execute;
 finally
   // FCursor has to be assigned, or else the prepare went wrong before PrepareStatment was
   // called, so UnPrepareStatement shoudn't be called either
  if (not IsPrepared) and (assigned(database)) and (assigned(FCursor)) then begin
   (database as tcustomsqlconnection).UnPrepareStatement(Fcursor);
  end;
 end;
end;

procedure TSQLQuery.SetReadOnly(AValue : Boolean);

begin
 CheckInactive;
 freadonly:= avalue;
//  if not AValue then
//    begin
//    if FParseSQL then FReadOnly := False
//      else DatabaseErrorFmt(SNoParseSQL,['Updating ']);
//    end
//  else FReadOnly := True;
end;

procedure TSQLQuery.SetParseSQL(AValue : Boolean);

begin
 CheckInactive;
 if fparsesql <> avalue then begin
  fparsesql:= avalue;
  if not AValue then begin
   Filtered:= False;
   resetparsing;
  end;
  unprepare; //refresh sqlparser
 end;
end;

procedure tsqlquery.setstatementtype(const avalue: tstatementtype);
begin
 CheckInactive;
 if fstatementtype <> avalue then begin
  fstatementtype:= avalue;
  unprepare; //refresh sqlparser
 end;
end;

procedure TSQLQuery.SetUsePrimaryKeyAsKey(AValue : Boolean);

begin
  if not Active then FusePrimaryKeyAsKey := AValue
  else
    begin
    // Just temporary, this should be possible in the future
    DatabaseError(SActiveDataset);
    end;
end;

Procedure TSQLQuery.UpdateIndexDefs;

begin
 findexdefs.clear;
 if assigned(DataBase) and (ftablename <> '') then begin
  tcustomsqlconnection1(database).UpdateIndexDefs(FIndexDefs,FTableName,fcursor);
 end;
end;

procedure tsqlquery.updatewherepart(var sql_where : msestring; const afield: tfield);
var
 quotechar: msestring;
begin
 if database <> nil then begin
  quotechar:= tcustomsqlconnection1(database).identquotechar;
 end
 else begin
  quotechar:= '"';
 end;
 with afield do begin
  if (of_InKey in optionsfield) or
    ((FUpdateMode = upWhereAll) and (of_InWhere in optionsfield)) or
    ((FUpdateMode = UpWhereChanged) and
    (of_InWhere in optionsfield) and
    (value <> oldvalue)) then begin
   sql_where := sql_where + '(' + quotechar+msestring(FieldName)+quotechar+
             '= :OLD_' + msestring(FieldName) + ') and ';
  end;
 end;
end;

function tsqlquery.refreshrecquery(const update: boolean): msestring;
var
 int1,int2: integer;
// intf1: imsefield;
 field1: tfield;
// flags1: providerflags1ty;
begin
 result:= '';
 int2:= 0;
 for int1:= 0 to fields.count - 1 do begin
  field1:= fields[int1];
  if (field1.fieldkind = fkdata) {and
    getcorbainterface(field1,typeinfo(imsefield),intf1)} then begin
//   flags1:= intf1.getproviderflags1;
   if (of_refreshupdate in field1.optionsfield) and update or
      (of_refreshinsert in field1.optionsfield) and not update then begin
    if int2 = 0 then begin
     result:= ' returning ';
    end;
    result:= result + msestring(field1.fieldname) + ',';
    inc(int2);
    if update then begin
     if not (bs_refreshupdateindex in fbstate) and
                    indexlocal.hasfield(field1) then begin
      include(fbstate,bs_refreshupdateindex);
     end;
    end
    else begin
     if not (bs_refreshinsertindex in fbstate) and
                    indexlocal.hasfield(field1) then begin
      include(fbstate,bs_refreshinsertindex);
     end;
    end;
   end;
  end;
 end;
 if int2 > 0 then begin
  if update then begin
   include(fbstate,bs_refreshupdate);
  end
  else begin
   include(fbstate,bs_refreshinsert);
  end;
  setlength(result,length(result)-1);
 end
 else begin
 end;
end;

procedure tsqlquery.checktablename;
begin
 if ftablename = '' then begin
  databaseerror('No table name in apply recupdate statement',self);
 end;
end;

function tsqlquery.updaterecquery : msestring;
var
 x: integer;
 sql_set: msestring;
 sql_where: msestring;
 field1: tfield;
 quotechar: msestring;
begin
 checktablename;
 quotechar:= tcustomsqlconnection1(database).identquotechar;
 sql_set:= '';
 sql_where:= '';
 for x := 0 to Fields.Count -1 do begin
  field1:= fields[x];
  with field1 do begin
   if fieldkind = fkdata then begin
    UpdateWherePart(sql_where,field1);
    if (of_InUpdate in optionsfield) then begin
     sql_set:= sql_set + quotechar+msestring(FieldName)+quotechar + '=:' +
               msestring(FieldName) + ',';
    end;
   end;
  end;
 end;
 if sql_set = '' then begin
  databaseerror('No "set" part in SQLUpdate statement.',self);
 end;
 if sql_where = '' then begin
  databaseerror('No "where" part in SQLUpdate statement.',self);
 end;
 setlength(sql_set,length(sql_set)-1);
 setlength(sql_where,length(sql_where)-5);
 result := 'update ' + msestring(FTableName) + ' set ' + sql_set +
                                                   ' where ' + sql_where;
 result:= result + refreshrecquery(true);
end;


function tsqlquery.insertrecquery: msestring;
var
 x: integer;
 sql_fields: msestring;
 sql_values: msestring;
 quotechar: msestring;
begin
 checktablename;
 quotechar:= tcustomsqlconnection1(database).identquotechar;
 sql_fields := '';
 sql_values := '';
 for x := 0 to Fields.Count -1 do begin
  with fields[x] do begin
   if (fieldkind = fkdata) {and not IsNull} and
                          (of_InInsert in optionsfield) then begin
    sql_fields:= sql_fields + quotechar+msestring(FieldName)+quotechar+ ',';
    sql_values:= sql_values + ':' + msestring(FieldName) + ',';
   end;
  end;
 end;
 if sql_fields = '' then begin
  databaseerror('No "values" part in SQLInsert statement.',self);
 end;
 setlength(sql_fields,length(sql_fields)-1);
 setlength(sql_values,length(sql_values)-1);
 result := 'insert into ' + msestring(FTableName) +
                 ' (' + sql_fields + ') values (' +sql_values + ')';
 result:= result + refreshrecquery(false);
end;

function tsqlquery.deleterecquery : msestring;
var
 x: integer;
 sql_where: msestring;
 field1: tfield;
begin
 checktablename;
 sql_where := '';
 for x := 0 to Fields.Count -1 do begin
  field1:= fields[x];
  if field1.fieldkind = fkdata then begin
   UpdateWherePart(sql_where,field1);
  end;
 end;
 if sql_where = '' then begin
  databaseerror('No "where" part in SQLDelete statement.',self);
 end;
 setlength(sql_where,length(sql_where)-5);
 result := 'delete from ' + msestring(FTableName) + ' where ' + sql_where;
end;

Procedure TSQLQuery.internalApplyRecUpdate(UpdateKind : TUpdateKind);
var
 x: integer;
 fld1: tfield;
 param1,param2: tparam;
 int1: integer;
 blobspo: pblobinfoarty;
 str1: string;
 bo1: boolean;
 freeblobar: pointerarty;
 statementtypebefore: tstatementtype;
 oldisnew: boolean;
 rowsaffected1: integer;

begin
 oldisnew:= (updatekind = ukinsert) and (bs_inserttoupdate in fbstate);
 if oldisnew then begin
  updatekind:= ukmodify;
 end;
 blobspo:= getintblobpo;
 if fapplyqueries[updatekind] = nil then begin
  databaseerror(name+': No rec apply query for '+
                   getenumname(typeinfo(tupdatekind),ord(updatekind))+'.');
 end;
 with tsqlresult1(fapplyqueries[updatekind]) do begin
  if sql.count = 0 then begin
   case updatekind of
    ukinsert: begin
     sql.add(self.insertrecquery);
    end;
    ukmodify: begin
     sql.add(self.updaterecquery);
    end;
    ukdelete: begin
     sql.add(self.deleterecquery);
    end;
   end;
  end;
  futf8:= self.isutf8;
  transaction.active:= true;
  freeblobar:= nil;
  try
   for x := 0 to Params.Count-1 do begin
    param1:= params[x];
    with param1 do begin
     str1:= name;
     bo1:= pos('OLD_',str1) = 1;
     if bo1 then begin
      str1:= copy(str1,5,bigint);
     end;
     if bo1 and not oldisnew then begin
      fld1:= self.FieldByName(str1);
      oldfieldtoparam(fld1,param1);
     end
     else begin
      fld1:= self.findfield(str1);
      if fld1 = nil then begin     //search for param
       param2:= self.params.findparam(str1);
       if param2 = nil then begin
        fieldbyname(str1); //raise exception
       end
       else begin
        value:= param2.value;
       end;
      end
      else begin             //use field
       if (fld1 is tblobfield) and (self.fblobintf <> nil) then begin
        if fld1.isnull then begin
         clear;
         datatype:= fld1.datatype;
        end
        else begin
         bo1:= false;
         for int1:= 0 to high(blobspo^) do begin
          if blobspo^[int1].field = fld1 then begin
           self.fblobintf.writeblobdata(tsqltransaction(self.transaction),
             self.ftablename,self.fcursor,
             blobspo^[int1].data,blobspo^[int1].datalength,fld1,params[x],str1);
           if str1 <> '' then begin
            self.setdatastringvalue(fld1,str1);
            additem(freeblobar,fld1);
           end;
           bo1:= true;
           break;
          end;
         end;
         if not bo1 then begin
          self.fblobintf.setupblobdata(fld1,self.fcursor,params[x]);
         end;
        end;
       end
       else begin
        self.fieldtoparam(fld1,param1);
       end;
      end;
     end;
    end;
   end;

   if (updatekind = ukmodify) and
                          (bs_refreshupdate in self.fbstate) or
      (updatekind = ukinsert) and
                          (bs_refreshinsert in self.fbstate) then begin
    statementtypebefore:= statementtype;
    try
     statementtype:= stselect;
     refresh;
     if not eof then begin
      for int1:= 0 to datacols.count - 1 do begin
       with datacols[int1] do begin
        fld1:= self.fields.fieldbyname(fieldname);
        fld1.value:= asvariant;
       end;
      end;
     end;
     rowsaffected1:= fcursor.frowsaffected;
    finally
     clear;
     statementtype:= statementtypebefore;
    end;
   end
   else begin
    execute;
    rowsaffected1:= fcursor.frowsaffected;
   end;

   if not (bs_refreshinsert in fbstate) and (updatekind = ukinsert) and
                                      (self.fprimarykeyfield <> nil) then begin
    tcustomsqlconnection1(database).updateprimarykeyfield(
                   self.fprimarykeyfield,transaction);
   end;
   if (self.fupdaterowsaffected < 0) or (rowsaffected1 < 0) then begin
    self.fupdaterowsaffected:= rowsaffected1;
   end
   else begin
    self.fupdaterowsaffected:= self.fupdaterowsaffected + rowsaffected1;
   end;
   {
   if self.fupdaterowsaffected >= 0 then begin
    if self.fcursor.frowsaffected < 0 then begin
     self.fupdaterowsaffected:= -1;
    end
    else begin
     inc(self.fupdaterowsaffected,rowsaffected1);
    end;
   end;
   }
  finally
   for int1:= high(freeblobar) downto 0 do begin
    deleteblob(blobspo^,tfield(freeblobar[int1]),true);
   end;
  end;
 end;
end;

Procedure TSQLQuery.ApplyRecUpdate(UpdateKind : TUpdateKind);
begin
 internalapplyrecupdate(updatekind);
end;

{
Procedure TSQLQuery.ApplyRecUpdate(UpdateKind : TUpdateKind);

var
    s : string;

  procedure UpdateWherePart(var sql_where : string;x : integer);

  begin
    if (pfInKey in Fields[x].ProviderFlags) or
       ((FUpdateMode = upWhereAll) and (pfInWhere in Fields[x].ProviderFlags)) or
       ((FUpdateMode = UpWhereChanged) and (pfInWhere in Fields[x].ProviderFlags) and (fields[x].value <> fields[x].oldvalue)) then
      sql_where := sql_where + '(' + fields[x].FieldName + '= :OLD_' + fields[x].FieldName + ') and ';
  end;

  function ModifyRecQuery : string;

  var x          : integer;
      sql_set    : string;
      sql_where  : string;

  begin
    sql_set := '';
    sql_where := '';
    for x := 0 to Fields.Count -1 do
      begin
      UpdateWherePart(sql_where,x);

      if (pfInUpdate in Fields[x].ProviderFlags) then
        sql_set := sql_set + fields[x].FieldName + '=:' + fields[x].FieldName + ',';
      end;

    setlength(sql_set,length(sql_set)-1);
    setlength(sql_where,length(sql_where)-5);
    result := 'update ' + FTableName + ' set ' + sql_set + ' where ' + sql_where;

  end;

  function InsertRecQuery : string;

  var x          : integer;
      sql_fields : string;
      sql_values : string;

  begin
    sql_fields := '';
    sql_values := '';
    for x := 0 to Fields.Count -1 do
      begin
      if not fields[x].IsNull then
        begin
        sql_fields := sql_fields + fields[x].FieldName + ',';
        sql_values := sql_values + ':' + fields[x].FieldName + ',';
        end;
      end;
    setlength(sql_fields,length(sql_fields)-1);
    setlength(sql_values,length(sql_values)-1);

    result := 'insert into ' + FTableName + ' (' + sql_fields + ') values (' + sql_values + ')';
  end;

  function DeleteRecQuery : string;

  var x          : integer;
      sql_where  : string;

  begin
    sql_where := '';
    for x := 0 to Fields.Count -1 do
      UpdateWherePart(sql_where,x);

    setlength(sql_where,length(sql_where)-5);

    result := 'delete from ' + FTableName + ' where ' + sql_where;
  end;

var qry : TSQLQuery;
    x   : integer;
    Fld : TField;

begin
    case UpdateKind of
      ukModify : begin
                 qry := FUpdateQry;
                 if trim(qry.sql.Text) = '' then qry.SQL.Add(ModifyRecQuery);
                 end;
      ukInsert : begin
                 qry := FInsertQry;
                 if trim(qry.sql.Text) = '' then qry.SQL.Add(InsertRecQuery);
                 end;
      ukDelete : begin
                 qry := FDeleteQry;
                 if trim(qry.sql.Text) = '' then qry.SQL.Add(DeleteRecQuery);
                 end;
    end;
  with qry do
    begin
    for x := 0 to Params.Count-1 do with params[x] do if leftstr(name,4)='OLD_' then
      begin
      Fld := self.FieldByName(copy(name,5,length(name)-4));
      AssignFieldValue(Fld,Fld.OldValue);
      end
    else
      begin
      Fld := self.FieldByName(name);
      AssignFieldValue(Fld,Fld.Value);
      end;
    execsql;
    end;
end;
}

Function TSQLQuery.GetCanModify: Boolean;

begin
 if not connected then begin
  result:= active and not freadonly;
 end
 else begin
  if (fcursor <> nil) and
                     (FCursor.FStatementType in datareturningtypes) then begin
   Result:= Active and
        (FUpdateable or (bdo_noapply in foptions)) and (not FReadOnly)
  end
  else begin
   Result:= False;
  end;
 end;
end;

function TSQLQuery.GetIndexDefs : TIndexDefs;

begin
  Result := FIndexDefs;
end;

procedure TSQLQuery.SetIndexDefs(AValue : TIndexDefs);

begin
  FIndexDefs := AValue;
end;

procedure TSQLQuery.SetUpdateMode(AValue : TUpdateMode);

begin
  FUpdateMode := AValue;
end;
{
procedure TSQLQuery.SetSchemaInfo( SchemaType : TSchemaType; SchemaObjectName, SchemaPattern : string);

begin
  ReadOnly := True;
  SQL.Clear;
  SQL.Add(tcustomsqlconnection1(database).GetSchemaInfoSQL(
                             SchemaType, SchemaObjectName, SchemaPattern));
end;
}
function TSQLQuery.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
var
 info: blobcacheinfoty;
// int1: integer;
 blob1: blobinfoty;
begin
 result:= inherited createblobstream(field,mode);
 if result = nil then begin
  if (bs_blobsfetched in fbstate) and (mode = bmread) then begin
   info.id:= 0; //fieldsize can be 32 bit
   if field.getdata(@info.id) and findcachedblob(info) then begin
    blob1.data:= pointer(info.data);
    blob1.datalength:= length(info.data);
    result:= tblobcopy.create(blob1);
   end;
  end
  else begin
   if database = nil then begin
    if mode = bmwrite then begin
     result:= createblobbuffer(field);
    end;
   end
   else begin
    result:= tcustomsqlconnection1(database).CreateBlobStream(Field,
                                        Mode,fcursor);
   end;
  end;
 end;
end;
{
function TSQLQuery.GetStatementType : TStatementType;

begin
  if assigned(FCursor) then Result := FCursor.FStatementType
    else Result := stNone;
end;
}
procedure tsqlquery.checkrecursivedatasource(const avalue: tdatasource);
var
 dso1: tdatasource;
 ds1: tdataset;
 int1: integer;
begin
 dso1:= avalue;
 int1:= 0;
 while dso1 <> nil do begin
  inc(int1);
  if (dso1.dataset = self) or (int1 > 100) then begin
   databaseerror('Recursive datasource.',self);
  end;
  ds1:= dso1.dataset;
  if ds1 is tsqlquery then begin
   dso1:= tsqlquery(ds1).datasource;
  end
  else begin
   break;
  end;
 end;
end;

Procedure TSQLQuery.SetDataSource(AVAlue : TDatasource);
Var
 DS : TDatasource;
begin
 checkrecursivedatasource(avalue);
 DS:=DataSource;
 If (AValue<>DS) then begin
  If Assigned(DS) then begin
   DS.RemoveFreeNotification(Self);
  end;
  If Assigned(AValue) then begin
   AValue.FreeNotification(Self);
   FMasterLink:= TsqlMasterParamsDataLink.Create(Self);
   FMasterLink.Datasource:= AValue;
  end
  else begin
   FreeAndNil(FMasterLink);
  end;
 end;
end;

Function TSQLQuery.GetDataSource : TDatasource;

begin
  If Assigned(FMasterLink) then
    Result:=FMasterLink.DataSource
  else
    Result:=Nil;
end;

procedure tsqlquery.notification(acomponent: tcomponent; operation: toperation);
begin
 inherited;
 if operation = opremove then begin
  if acomponent = datasource then begin
   datasource:= nil;
  end;
  if acomponent = fbeforeexecute then begin
   fbeforeexecute:= nil;
  end;
  if acomponent = faftercursorclose then begin
   faftercursorclose:= nil;
  end;
 end;
end;

function TSQLQuery.getblobdatasize: integer;
begin
 if database = nil then begin
  result:= sizeof(int64); //max
 end
 else begin
  result:= tcustomsqlconnection1(database).getblobdatasize;
 end;
end;

function TSQLQuery.getdatabase1: tcustomsqlconnection;
begin
 result:= tcustomsqlconnection(inherited database);
end;

function tsqlquery.getdatabase: tcustomconnection; //for isqlpropertyeditor
begin
 result:= database;
end;

procedure TSQLQuery.setdatabase1(const avalue: tcustomsqlconnection);
begin
 inherited database:= avalue;
end;
{
procedure TSQLQuery.checkdatabase;
begin
 docheckdatabase(name,fdatabase);
 if inherited database = nil then begin
  databaseerror(serrdatabasenassigned);
 end;
end;
}
function TSQLQuery.executedirect(const asql: msestring): integer;
begin
 checkdatabase(name,fdatabase);
 result:= database.executedirect(asql,writetransaction);
end;

procedure TSQLQuery.setparams(const avalue: TmseParams);
begin
 fparams.assign(avalue);
end;

function tsqlquery.getconnected: boolean;
begin
 result:= bs_connected in fbstate;
// result:= (transaction <> nil) and transaction.active;
end;

function tsqlquery.blobscached: boolean;
begin
 result:= (fblobintf <> nil) and fblobintf.blobscached;
end;

procedure TSQLQuery.setconnected(const avalue: boolean);
var
 int1: integer;
 uk1: tupdatekind;
begin         //todo: check connect disconnect sequence
 if not (bs_opening in fbstate) then begin
  checkactive;
 end;
 if avalue <> connected then begin
  if avalue then begin
   closelogger;
   connect(false);
  end
  else begin
   if transaction.active then begin
    fetchallblobs;
    int1:= 0;
    if (ftransactionwrite = nil) or (ftransactionwrite = ftransaction) then begin
     for uk1:= low(tupdatekind) to high(tupdatekind) do begin
      if fapplyqueries[uk1] <> nil then begin
       inc(int1);
      end;
     end;
    end;
    tsqltransaction1(transaction).disconnect(self,int1);
    disconnect{(false)};
    unprepare;
    tcustomsqlconnection(database).DeAllocateCursorHandle(FCursor);
    startlogger;
   end;
  end;
 end;
end;

procedure tsqlquery.setfsql(const avalue: tsqlstringlist);
begin
 fsql.assign(avalue);
end;

procedure tsqlquery.setfsqlupdate(const avalue: tupdatestringlist);
begin
 fapplysql[ukmodify].assign(avalue);
end;

procedure tsqlquery.setfsqlinsert(const avalue: tupdatestringlist);
begin
 fapplysql[ukinsert].assign(avalue);
end;

procedure tsqlquery.setfsqldelete(const avalue: tupdatestringlist);
begin
 fapplysql[ukdelete].assign(avalue);
end;

procedure TSQLQuery.setbeforeexecute(const avalue: tcustomsqlstatement);
begin
 if fbeforeexecute <> nil then begin
  fbeforeexecute.removefreenotification(self);
 end;
 fbeforeexecute:= avalue;
 if fbeforeexecute <> nil then begin
  fbeforeexecute.freenotification(self);
 end;
end;

procedure TSQLQuery.setaftercursorclose(const avalue: tcustomsqlstatement);
begin
 if faftercursorclose <> nil then begin
  faftercursorclose.removefreenotification(self);
 end;
 faftercursorclose:= avalue;
 if faftercursorclose <> nil then begin
  faftercursorclose.freenotification(self);
 end;
end;

function TSQLQuery.getnumboolean: boolean;
begin
 result:= tcustomsqlconnection1(database).getnumboolean;
end;

function TSQLQuery.getfloatdate: boolean;
begin
 result:= tcustomsqlconnection1(database).getfloatdate;
end;

function TSQLQuery.getint64currency: boolean;
begin
 result:= tcustomsqlconnection1(database).getint64currency;
end;

function TSQLQuery.getsqltransaction: tsqltransaction;
begin
 result:= tsqltransaction(inherited transaction);
end;

procedure TSQLQuery.setsqltransaction(const avalue: tsqltransaction);
begin
 inherited transaction:= avalue;
end;

function TSQLQuery.getsqltransactionwrite: tsqltransaction;
begin
 result:= tsqltransaction(inherited transactionwrite);
end;

procedure TSQLQuery.settransactionwrite(const avalue: tmdbtransaction);
begin
 if avalue <> ftransactionwrite then begin
  checkpendingupdates;
 end;
 inherited;
end;

procedure TSQLQuery.setsqltransactionwrite(const avalue: tsqltransaction);
begin
 inherited transactionwrite:= avalue;
end;

procedure TSQLQuery.applyupdate(const cancelonerror: boolean;
                               const cancelondeleteerror: boolean = false;
                               const editonerror: boolean = false);
begin
 fupdaterowsaffected:= 0;
 inherited;
end;

procedure TSQLQuery.applyupdates(const maxerrors: integer;
                                  const cancelonerror: boolean;
                                  const cancelondeleteerror: boolean = false;
                                  const editonerror: boolean = false);
begin
 fupdaterowsaffected:= 0;
 if fdatabase = nil then begin
  inherited;
 end
 else begin
  tcustomsqlconnection1(fdatabase).beginupdate;
  try
   inherited;
  finally
   tcustomsqlconnection1(fdatabase).endupdate;
  end;
 end;
end;

function TSQLQuery.writetransaction: tsqltransaction;
begin
 result:= tsqltransaction(ftransactionwrite);
 if result = nil then begin
  result:= transaction;
 end;
end;

procedure TSQLQuery.dobeforeapplyupdate;
begin
 inherited;
 if writetransaction <> nil then begin
  writetransaction.active:= true;
 end;
end;

function TSQLQuery.rowsreturned: integer;
begin
 if active and (fcursor <> nil) then begin
  result:= fcursor.frowsreturned;
 end
 else begin
  result:= -1;
 end;
end;

function TSQLQuery.rowsaffected: integer;
begin
 if active and (fcursor <> nil) then begin
  result:= fcursor.frowsaffected;
 end
 else begin
  result:= -1;
 end;
end;

procedure TSQLQuery.checkpendingupdates;
begin
 //dummy
end;

function TSQLQuery.stringmemo: boolean;
begin
 result:= false;
 //dummy
end;

function TSQLQuery.isutf8: boolean;
begin
 result:= futf8;
// if fdatabase <> nil then begin
//  tcustomsqlconnection(fdatabase).updateutf8(result);
// end;
end;
{
procedure TSQLQuery.dscontrolleroptionschanged(const aoptions: datasetoptionsty);
begin
 fmasterlinkoptions:= [];
 if dso_syncmasteredit in aoptions then begin
  include(fmasterlinkoptions,mdlo_syncedit);
 end;
 if dso_syncmasterinsert in aoptions then begin
  include(fmasterlinkoptions,mdlo_syncinsert);
 end;
 if dso_syncmasterdelete in aoptions then begin
  include(fmasterlinkoptions,mdlo_syncdelete);
 end;
 if dso_delayeddetailpost in aoptions then begin
  include(fmasterlinkoptions,mdlo_delayeddetailpost);
 end;
 if dso_syncinsertfields in aoptions then begin
  include(fmasterlinkoptions,mdlo_syncinsertfields);
 end;
end;
}
{
procedure TSQLQuery.setmasterlink(const avalue: tsqlmasterparamsdatalink);
begin
 fmasterlink.assign(avalue);
end;
}
procedure TSQLQuery.dobeforeedit;
begin
 if (fmasterlink <> nil) then begin
  fmasterlink.checkrefresh;
 end;
 inherited;
end;

procedure TSQLQuery.dobeforeinsert;
begin
 if (fmasterlink <> nil) then begin
  fmasterlink.checkrefresh;
 end;
 inherited;
end;

procedure TSQLQuery.settablename(const avalue: string);
begin
 checkinactive;
 ftablename:= avalue;
end;

procedure TSQLQuery.dataevent(event: tdataevent; info: ptrint);
var
 int1: integer;
 sf,df: tfield;
 str1: string;
begin
 case event of
  deupdaterecord: begin
   if (mdlo_syncfields in foptionsmasterlink) and (fmasterlink <> nil) and
              fmasterlink.active then begin
    for int1:= 0 to fparams.count - 1 do begin
     str1:= fparams[int1].name;
     if (str1 <> '') then begin
      df:= findfield(str1);
      if df <> nil then begin
       sf:= fmasterlink.dataset.findfield(str1);
       if (sf <> nil) and (df.value <> sf.value) then begin
                          //no modified touch
        df.value:= sf.value;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 inherited;
end;

end.
