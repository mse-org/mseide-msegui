{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesqldb;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$goto on}{$endif}
interface
uses
 classes,db,msebufdataset,msqldb,msedb,mseclasses,msetypes,mseglob,
 msedatabase,sysutils,msetimer;
  
type
 tmsesqltransaction = class(tsqltransaction)
  private
   fcontroller: ttacontroller;
   function getactive: boolean;
   procedure setactive(const avalue: boolean);
   procedure setcontroller(const avalue: ttacontroller);
  protected
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property Active : boolean read getactive write setactive default false;
   property controller: ttacontroller read fcontroller write setcontroller;
 end;

 tmsesqlquery = class;
 
 sqlquerystatety = (sqs_userapplayrecupdate,sqs_updateabort,sqs_updateerror);
 sqlquerystatesty = set of sqlquerystatety;
 applyrecupdateeventty = 
     procedure(const sender: tmsesqlquery; const updatekind: tupdatekind;
                        var asql: string; var done: boolean) of object;
 afterapplyrecupdateeventty = 
     procedure(const sender: tmsesqlquery; 
                           const updatekind: tupdatekind) of object;
 updateerroreventty = procedure(const sender: tmsesqlquery;
                          const aupdatekind: tupdatekind;
                          var aupdateaction: tupdateaction) of object;
                             
 tmsesqlquery = class(tsqlquery,imselocate,idscontroller,igetdscontroller,
                              isqlpropertyeditor)
  private
   fsqlonchangebefore: notifyeventty;
   fcontroller: tdscontroller;
   fmstate: sqlquerystatesty;
   fonapplyrecupdate: applyrecupdateeventty;
   fafterapplyrecupdate: afterapplyrecupdateeventty;
   procedure setcontroller(const avalue: tdscontroller);
   procedure setactive1(value : boolean);
   function getactive: boolean;
   procedure setonapplyrecupdate(const avalue: applyrecupdateeventty);
   function getcontroller: tdscontroller;
   function getindexdefs: TIndexDefs;
   procedure setindexdefs(const avalue: TIndexDefs);
//   function getetstatementtype: TStatementType;
//   procedure setstatementtype(const avalue: TStatementType);
   procedure checkcanupdate;
  protected
   procedure checkpendingupdates; override;
   procedure setactive(avalue: boolean); override;
   procedure afterapply; override;
   procedure updateindexdefs; override;
   procedure sqlonchange(const sender: tobject);
   procedure loaded; override;
   procedure internalopen; override;
   procedure internalclose; override;
   procedure DoAfterDelete; override;
   procedure internalinsert; override;
   procedure internaldelete; override;
   procedure applyrecupdate(updatekind: tupdatekind); override;
   function  getcanmodify: boolean; override;
   function  getfieldclass(fieldtype: tfieldtype): tfieldclass; override;
   procedure dataevent(event: tdataevent; info: ptrint); override;
   function islocal: boolean; override;
  //icursorclient
   function stringmemo: boolean; override;
       //memo fields are text(0) fields
  //idscontroller
   procedure inheriteddataevent(const event: tdataevent; const info: ptrint);
   procedure inheritedcancel;
   procedure inheritedpost;
   function inheritedmoveby(const distance: integer): integer;  
   procedure inheritedinternalinsert; virtual;
   procedure inheritedinternaldelete; virtual;
   procedure inheritedinternalopen;
   procedure inheritedinternalclose;
   procedure doidleapplyupdates;

//   function wantblobfetch: boolean; override;
   function getdsoptions: datasetoptionsty; override;
   procedure afterpost(const sender: tdataset; var ok: boolean);
//   function cantransactionrefresh: boolean; override;
//,   function refreshtransdatasets: boolean; override;
      
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function isutf8: boolean; override;
   procedure appendrecord(const values: array of const);
   function moveby(const distance: integer): integer;
   procedure cancel; override;
   procedure post; override;
   procedure applyupdates(const maxerrors: integer;
                     const cancelonerror: boolean); override; overload;
   procedure applyupdates(const maxerrors: integer = 0); override; overload;
   procedure applyupdate; override; overload;
  published
   property FieldDefs;
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive1 default false;
   property onapplyrecupdate: applyrecupdateeventty read fonapplyrecupdate
                                  write setonapplyrecupdate;
             //raise eupdateerror in order to skip update of the record
   property afterapplyrecupdate: afterapplyrecupdateeventty read fafterapplyrecupdate 
                                  write fafterapplyrecupdate;
   property UpdateMode default upWhereKeyOnly;
   property UsePrimaryKeyAsKey default true;
   property IndexDefs : TIndexDefs read getindexdefs write setindexdefs;
               //must be writable because it is streamed
//   property StatementType : TStatementType read getetstatementtype 
//                                  write setstatementtype default stnone;
               //must be writable because it was streamed in FPC 2.0.4
 end;

 idbparaminfo = interface(inullinterface)['{D0EDEE1E-A4CC-DA11-9F9B-00C0CA1308FF}']
  function getdestdataset: tsqlquery;
 end;
 
 tfieldparamlink = class;

 setparameventty = procedure(const sender: tfieldparamlink;
                        var done: boolean) of object;  
                        
 tparamsourcedatalink = class(tfielddatalink)
  private
   fowner: tfieldparamlink;
   fparamset: boolean;
   fchangelock: integer;
   frefreshlock: integer;
  protected
//   procedure checkrefresh;
   procedure recordchanged(afield: tfield); override;
   procedure DataEvent(Event: TDataEvent; Info: Ptrint); override;
   procedure CheckBrowseMode; override;
  public
   constructor create(const aowner: tfieldparamlink);
   procedure loaded;
 end;

 tparamdestdatalink = class(tmsedatalink)
  private
   fowner: tfieldparamlink;
  protected
   function cansync(out sourceds: tdataset): boolean;
   procedure DataEvent(Event: TDataEvent; Info: Ptrint); override;
   procedure CheckBrowseMode; override;
  public
   constructor create(const aowner: tfieldparamlink);
 end;
  
 fieldparamlinkoptionty = (fplo_autorefresh,fplo_restorerecno,
              fplo_syncmasterpost,
              fplo_syncmasteredit,
              fplo_syncmasterinsert,
              fplo_syncmasterdelete,
              fplo_syncslavepost,
              fplo_syncslaveedit,
              fplo_syncslaveinsert,
              fplo_syncslavedelete
              );
 fieldparamlinkoptionsty = set of fieldparamlinkoptionty;
const
 defaultfieldparamlinkoptions = [fplo_autorefresh];
 
type  
 tfieldparamlink = class(tmsecomponent,idbeditinfo,idbparaminfo)
  private
   fsourcedatalink: tparamsourcedatalink;
//   fdestdatasource: tlinkdatasource;
   fdestdataset: tsqlquery;
   fdestdatasource: tdatasource;
   fdestdatalink: tparamdestdatalink;
   fdestcontroller: tdscontroller;
   fparamname: string;
   fonsetparam: setparameventty;
   fonaftersetparam: notifyeventty;
   foptions: fieldparamlinkoptionsty;
   fdelayus: integer;
   fnodelay: integer;
   fonupdatemasteredit: masterdataseteventty;
   fonupdatemasterinsert: masterdataseteventty;
   fonupdateslaveedit: slavedataseteventty;
   fonupdateslaveinsert: slavedataseteventty;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource; overload;
   procedure setdatasource(const avalue: tdatasource);
   function getvisualcontrol: boolean;
   procedure setvisualcontrol(const avalue: boolean);
   function getdestdataset: tsqlquery;
   procedure setdestdataset(const avalue: tsqlquery);
   procedure setdelayus(const avalue: integer);
  protected
   procedure loaded; override;
  //idbeditinfo
   function getdatasource(const aindex: integer): tdatasource; overload;
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
//   procedure dotimer(const sender: tobject);
   procedure notification(acomponent: tcomponent;
                                operation: toperation); override;
   function truedelayus: integer;
   procedure checkrefresh;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function param: tparam;
   function field: tfield;
   procedure delayoff;
   procedure delayon;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
   property visualcontrol: boolean read getvisualcontrol 
                    write setvisualcontrol default false;
   property destdataset: tsqlquery read getdestdataset write setdestdataset;
   property paramname: string read fparamname write fparamname;
   property delayus: integer read fdelayus write setdelayus default -1;
                //-1 -> off, 0 -> on idle
   property options: fieldparamlinkoptionsty read foptions write foptions
                      default defaultfieldparamlinkoptions;
   property onsetparam: setparameventty read fonsetparam write fonsetparam;
   property onaftersetparam: notifyeventty read fonaftersetparam
                                  write fonaftersetparam;
   property onupdatemasteredit: masterdataseteventty read fonupdatemasteredit 
                     write fonupdatemasteredit;
   property onupdatemasterinsert: masterdataseteventty read fonupdatemasterinsert 
                     write fonupdatemasterinsert;
   property onupdateslaveedit: slavedataseteventty read fonupdateslaveedit 
                     write fonupdatemasteredit;
   property onupdateslaveinsert: slavedataseteventty read fonupdateslaveinsert 
                     write fonupdatemasterinsert;
 end;

 tsequencelink = class;
 
 tsequencedatalink = class(tfielddatalink)
  private
   fowner: tsequencelink;
  protected
   procedure updatedata; override;
  public
   constructor create(const aowner: tsequencelink);
 end;
  
 tsequencelink = class(tmsecomponent,idbeditinfo)
  private
   fsequencename: string;
   fdatabase: tsqlconnection;
   fdbintf: idbcontroller;
   fdatalink: tfielddatalink;
   fonupdatevalue: updateint64eventty;
   flastvalue: largeint;
   procedure checkintf;
   procedure setdatabase(const avalue: tsqlconnection);
   procedure setsequencename(const avalue: string);
   function getaslargeint: largeint;
   procedure setaslargeint(const avalue: largeint);
   function getasinteger: integer;
   procedure setasinteger(const avalue: integer);
   function getdatasource: tdatasource; overload;
   procedure setdatasource(const avalue: tdatasource);
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   //idbeditinfo
   function getdatasource(const aindex: integer): tdatasource; overload;
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
  protected
   procedure notification(acomponent: tcomponent; operation: toperation); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property aslargeint: largeint read getaslargeint write setaslargeint;
   property asinteger: integer read getasinteger write setasinteger;
   function assql: string;
   property lastvalue: largeint read flastvalue;
   function currvalue: largeint;
  published
   property database: tsqlconnection read fdatabase write setdatabase;
   property datasource: tdatasource read getdatasource write setdatasource;
   property datafield: string read getdatafield write setdatafield;
   property sequencename: string read fsequencename write setsequencename;

   property onupdatevalue: updateint64eventty read fonupdatevalue write fonupdatevalue;
 end;
 
implementation
uses
 msestrings,dbconst,msesysutils,typinfo,msedatalist,mseapplication,msesqlresult;
 
{ tmsesqltransaction }

constructor tmsesqltransaction.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= ttacontroller.create(self);
end;

destructor tmsesqltransaction.destroy;
begin
 inherited;
 fcontroller.free;
end;

function tmsesqltransaction.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsesqltransaction.setactive(const avalue: boolean);
begin
 if fcontroller.setactive(avalue) then begin
  inherited active:= avalue;
 end;
end;

procedure tmsesqltransaction.setcontroller(const avalue: ttacontroller);
begin
 fcontroller.assign(avalue);
end;

procedure tmsesqltransaction.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

{ tmsesqlquery }

constructor tmsesqlquery.create(aowner: tcomponent);
begin
 inherited;
// updatemode:= upwhereall;
 fsqlonchangebefore:= sql.onchange;
 sql.onchange:= {$ifdef FPC}@{$endif}sqlonchange;
 fcontroller:= tdscontroller.create(self,idscontroller(self),-1,false);
end;

destructor tmsesqlquery.destroy;
begin
 fcontroller.free;
 inherited;
end;

function tmsesqlquery.getindexdefs: TIndexDefs;
begin
 result:= inherited indexdefs;
end;

procedure tmsesqlquery.setindexdefs(const avalue: TIndexDefs);
begin
 inherited indexdefs.assign(avalue);
end;

procedure tmsesqlquery.updateindexdefs;
begin
 indexdefs.clear;
 inherited;
end;

procedure tmsesqlquery.appendrecord(const values: array of const);
begin
 fcontroller.appendrecord(values);
end;

procedure tmsesqlquery.sqlonchange(const sender: tobject);
begin
 if (csdesigning in componentstate) and active then begin
  active:= false;
  fsqlonchangebefore(sender);
  active:= true;
 end
 else begin
  fsqlonchangebefore(sender);
 end;
end;

procedure tmsesqlquery.setcontroller(const avalue: tdscontroller);
begin
 fcontroller.assign(avalue);
end;

procedure tmsesqlquery.setactive1(value: boolean);
begin
 if fcontroller.setactive(value) then begin
  setactive(value);
 end;
end;

procedure tmsesqlquery.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

function tmsesqlquery.getactive: boolean;
begin
 result:= inherited active;
end;

procedure tmsesqlquery.inheritedinternalopen;
begin
 inherited internalopen;
end;

procedure tmsesqlquery.internalopen;
var
 intf1: idbcontroller;
 bo1: boolean;
begin
 if dso_initinternalcalc in fcontroller.options then begin
  include(fbstate,bs_initinternalcalc);
 end
 else begin
  exclude(fbstate,bs_initinternalcalc);
 end;
 if (database <> nil) and 
          getcorbainterface(database,typeinfo(idbcontroller),intf1) then begin
  bo1:= dso_utf8 in fcontroller.options;
  intf1.updateutf8(bo1);
  if bo1 then begin
   fcontroller.options:= fcontroller.options + [dso_utf8];
  end
  else begin
   fcontroller.options:= fcontroller.options - [dso_utf8];
  end;
 end;
 fcontroller.internalopen;
 if not streamloading and not (dso_local in fcontroller.options) then begin
  connected:= not (dso_offline in fcontroller.options);
 end;
end;

procedure tmsesqlquery.setonapplyrecupdate(const avalue: applyrecupdateeventty);
begin
 if not (csloading in componentstate) then begin
  checkinactive;
 end;
 if assigned(avalue) and not (csdesigning in componentstate) then begin
  include(fmstate,sqs_userapplayrecupdate);
 end
 else begin
  exclude(fmstate,sqs_userapplayrecupdate);
 end;
 fonapplyrecupdate:= avalue;
end;

function tmsesqlquery.getcanmodify: Boolean;
begin
 result:= fcontroller.getcanmodify and 
              (inherited getcanmodify or not readonly and 
                                    (sqs_userapplayrecupdate in fmstate));
end;

procedure tmsesqlquery.applyrecupdate(updatekind: tupdatekind);
var
 bo1: boolean;
 str1: string;
begin
 try
  if sqs_userapplayrecupdate in fmstate then begin
   bo1:= false;
   fonapplyrecupdate(self,updatekind,str1,bo1);
   if not bo1 then begin
    if str1 = '' then begin
     inherited;
    end
    else begin
 {$ifdef debugsqlquery}  
     debugwriteln(getenumname(typeinfo(tupdatekind),ord(updatekind))+' '+str1);
 {$endif}  
     tsqlconnection(database).executedirect(str1,writetransaction);
    end;
   end;
  end
  else begin
   internalapplyrecupdate(updatekind);
  end;
  if checkcanevent(self,tmethod(fafterapplyrecupdate)) then begin
   fafterapplyrecupdate(self,updatekind);
  end;
 except
  include(fmstate,sqs_updateerror);
  raise;
 end;
end;

procedure tmsesqlquery.afterpost(const sender: tdataset; var ok: boolean);
begin
 if (dso_autoapply in fcontroller.options) and 
                       not(bs_noautoapply in fbstate) then begin
  try
   applyupdate;
  except
   ok:= false;
   application.handleexception(self);
  end;
 end;
end;

procedure tmsesqlquery.post;
begin
 fcontroller.post(@afterpost);
end;

procedure tmsesqlquery.afterapply;
begin
 if writetransaction <> nil then begin //can be nil in local mode
  if dso_autocommitret in fcontroller.options then begin
   writetransaction.commitretaining;
  end;
  if dso_autocommit in fcontroller.options then begin
   writetransaction.commit;
  end;
 end;
 if dso_refreshafterapply in fcontroller.options then begin
  fcontroller.refresh(dso_recnoapplyrefresh in fcontroller.options);
 end;
end;

procedure tmsesqlquery.checkcanupdate;
begin
 if not islocal and (transactionwrite = nil) then begin
  checkconnected;
 end;
end;

procedure tmsesqlquery.applyupdates(const maxerrors: integer;
                const cancelonerror: boolean = false);
begin
 checkcanupdate;
 try
  fmstate:= fmstate - [sqs_updateabort,sqs_updateerror];
  inherited;
 finally
  if (sqs_updateerror in fmstate) and 
              (dso_cancelupdatesonerror in fcontroller.options) then begin
   cancelupdates;
  end;
 end;
end;

procedure tmsesqlquery.doidleapplyupdates;
var
 bo1: boolean;
begin
 if not (bs_idle in fbstate) and (changecount > 0) and 
           (changecount >= fcontroller.delayedapplycount) then begin
  application.beginwait;
  include(fbstate,bs_idle);
  bo1:= false;
  try
   applyupdates;
  except
   bo1:= true;
   application.endwait;
   application.handleexception(self);
  end;
  exclude(fbstate,bs_idle);
  if not bo1 then begin
   application.endwait;
  end;
 end;
end;

procedure tmsesqlquery.checkpendingupdates;
begin
 if (state <> dsinactive) and (fcontroller.delayedapplycount > 0) and 
                                  (changecount > 0) then begin
//  (dso_applyonidle in fcontroller.options) and (changecount > 0) then begin
  applyupdates;
 end;
end;

procedure tmsesqlquery.setactive(avalue: boolean);
begin
 if not avalue then begin
  checkpendingupdates;
 end;
 inherited;
end;

procedure tmsesqlquery.applyupdates(const maxerrors: integer = 0);
begin
 applyupdates(maxerrors,fcontroller.options *
      [dso_cancelupdateonerror,dso_cancelupdatesonerror] <> []);
end;

procedure tmsesqlquery.applyupdate;
begin
 checkcanupdate;
 inherited applyupdate(fcontroller.options *
      [dso_cancelupdateonerror,dso_cancelupdatesonerror] <> []);
end;

function tmsesqlquery.getfieldclass(fieldtype: tfieldtype): tfieldclass;
begin
 fcontroller.getfieldclass(fieldtype,result);
end;

procedure tmsesqlquery.cancel;
begin
 fcontroller.cancel;
end;

procedure tmsesqlquery.dataevent(event: tdataevent; info: ptrint);
begin
 fcontroller.dataevent(event,info);
end;

function tmsesqlquery.getcontroller: tdscontroller;
begin
 result:= fcontroller;
end;

procedure tmsesqlquery.inheriteddataevent(const event: tdataevent;
               const info: ptrint);
begin
 inherited dataevent(event,info);
end;

procedure tmsesqlquery.inheritedcancel;
begin
 inherited cancel;
end;

function tmsesqlquery.inheritedmoveby(const distance: integer): integer;
begin
 result:= inherited moveby(distance);
end;

function tmsesqlquery.moveby(const distance: integer): integer;
begin
 result:= fcontroller.moveby(distance);
end;

procedure tmsesqlquery.internalinsert;
begin
 fcontroller.internalinsert;
end;

procedure tmsesqlquery.inheritedinternalinsert;
begin
 inherited internalinsert;
end;

procedure tmsesqlquery.internaldelete;
begin
 fcontroller.internaldelete;
end;

procedure tmsesqlquery.inheritedinternaldelete;
begin
 inherited internaldelete;
end;

procedure tmsesqlquery.DoAfterDelete;
begin
 inherited;
 if (dso_autoapply in fcontroller.options) and 
                   not(bs_noautoapply in fbstate) then begin
  applyupdates;
 end;
end;
{
function tmsesqlquery.getetstatementtype: TStatementType;
begin
 result:= inherited statementtype;
end;

procedure tmsesqlquery.setstatementtype(const avalue: TStatementType);
begin
 //dummy
end;
}
procedure tmsesqlquery.inheritedpost;
begin
 inherited post;
end;

function tmsesqlquery.isutf8: boolean;
begin
 result:= fcontroller.isutf8;
end;

function tmsesqlquery.getdsoptions: datasetoptionsty;
begin
 result:= fcontroller.options;
end;

{
function tmsesqlquery.wantblobfetch: boolean;
begin
 result:= (dso_cacheblobs in fcontroller.options);
end;

function tmsesqlquery.closetransactiononrefresh: boolean;
begin
 result:= (dso_refreshtransaction in fcontroller.options);
end;
}
{
function tmsesqlquery.refreshtransdatasets: boolean;
begin
 result:= (dso_refreshtransdatasets in fcontroller.options);
end;
}

function tmsesqlquery.islocal: boolean;
begin
 result:= dso_local in fcontroller.options;
end;

procedure tmsesqlquery.inheritedinternalclose;
begin
 inherited internalclose;
end;

procedure tmsesqlquery.internalclose;
begin
 fcontroller.internalclose;
end;

function tmsesqlquery.stringmemo: boolean;
begin
 result:= dso_stringmemo in fcontroller.options;
end;
{
function tmsesqlquery.cantransactionrefresh: boolean;
begin
 result:= not (dso_notransactionrefresh in fcontroller.options);
end;
}
{ tparamsourcedatalink }

constructor tparamsourcedatalink.create(const aowner: tfieldparamlink);
begin
 fowner:= aowner;
 inherited create;
end;
{
procedure tparamsourcedatalink.checkrefresh;
begin
 with fowner do begin
  if (fplo_autorefresh in foptions) and (destdataset <> nil) and 
                        (destdataset.state = dsbrowse) then begin
   if fplo_waitcursor in fowner.foptions then begin
    application.beginwait;
   end;
   try
    if fdestcontroller <> nil then begin
     fdestcontroller.refresh(fplo_restorerecno in foptions);
    end
    else begin
     fdestdataset.refresh;
    end;
   finally
    if fplo_waitcursor in fowner.foptions then begin
     application.endwait;
    end;
   end;
  end;
 end;
end;
}
procedure tparamsourcedatalink.recordchanged(afield: tfield);
var
 bo1: boolean;
begin
 if not (csloading in fowner.componentstate) then begin
  inherited;
  if frefreshlock = 0 then begin
   if active and (field <> nil) and
                 ((afield = nil) or (afield = self.field)) then begin
    if fchangelock <> 0 then begin
     databaseerror('Recursive recordchanged.',fowner);
    end;
    inc(fchangelock);
    try
     with fowner do begin
      if not (csdesigning in componentstate) then begin
       fparamset:= true;
       bo1:= false;
       if assigned(fonsetparam) then begin
        fonsetparam(fowner,bo1);
       end;
       if not bo1 and (fparamname <> '') and (dataset <> nil) then begin
        fieldtoparam(self.field,param);
       end;
       if assigned(fonaftersetparam) then begin
        fonaftersetparam(fowner);
       end;
       if (fplo_autorefresh in foptions) and (destdataset <> nil) and 
          not((destdataset.state = dsinsert) and (dataset.state = dsinsert) and
                       (fplo_syncmasterinsert in foptions))and
                   (destdataset.state in [dsbrowse,dsedit,dsinsert]) then begin
        fdestdataset.cancel;
        if fdestcontroller <> nil then begin
         fdestcontroller.refresh(fplo_restorerecno in foptions,truedelayus);
        end
        else begin
         fdestdataset.refresh;
        end;
       end;
       {
       if ftimer <> nil then begin
        ftimer.interval:= ftimer.interval;
        ftimer.enabled:= true;
       end
       else begin
        checkrefresh;
       end;
       }
      end;
     end;
    finally
     dec(fchangelock);
    end;
   end;
  end;
 end;
end;

procedure tparamsourcedatalink.loaded;
begin
 if not fparamset then begin
  recordchanged(nil);
 end;
end;

procedure tparamsourcedatalink.DataEvent(Event: TDataEvent; Info: Ptrint);
begin
 inherited;
 with fowner do begin
  if (destdataset <> nil) and destdataset.active then begin
   inc(frefreshlock);
   try
    case ord(event) of
     ord(deupdatestate): begin
      if (fplo_syncmasteredit in foptions) and (dataset.state = dsedit) and 
                      not (fowner.destdataset.state = dsedit) then begin
       destdataset.edit;
      end;
      if (fplo_syncmasterinsert in foptions) and(dataset.state = dsinsert) and
                                   not (destdataset.state = dsinsert) then begin
       destdataset.insert;
      end;
     end;
     de_afterdelete: begin
      if (fplo_syncmasterdelete in foptions) then begin
       destdataset.delete;
      end;
     end;
    end;
   finally
    dec(frefreshlock);
   end;
  end;
 end;
end;

procedure tparamsourcedatalink.CheckBrowseMode;
label
 endlab;
var
 intf: igetdscontroller;
begin
 with fowner do begin
  if (destdataset <> nil) and destdataset.active then begin
   inc(frefreshlock);
   try
    if foptions * [fplo_syncmasteredit,fplo_syncmasterinsert] <> [] then begin
     if mseclasses.getcorbainterface(dataset,typeinfo(igetdscontroller),intf) and
                                        intf.getcontroller.canceling then begin
      destdataset.cancel;
      exit;
     end
     else begin
      if (destdataset.state = dsinsert) and 
                           (fplo_syncmasterpost in foptions) then begin
       dataset.updaterecord;
       if dataset.modified then begin
        destdataset.post;
        goto endlab;
       end;
      end;
     end;
    end;
    if (fplo_syncmasterpost in foptions) then begin
     destdataset.post;
//     destdataset.checkbrowsemode;
    end;
    inherited;
   endlab:
    if (dataset.state in [dsedit,dsinsert]) and 
      (foptions * [fplo_syncmasteredit,fplo_syncmasterinsert] <> []) then begin
     dataset.updaterecord; //synchronize fields
    end;
    if (dataset.state = dsinsert) and assigned(onupdatemasterinsert) then begin
     onupdatemasterinsert(destdataset,dataset);
    end;
    if (dataset.state = dsedit) and assigned(onupdatemasteredit) then begin
     onupdatemasteredit(destdataset,dataset);
    end;
   finally
    dec(frefreshlock);
   end;
  end
  else begin
   inherited;
  end;
 end;
end;

{ tfieldparamlink }

constructor tfieldparamlink.create(aowner: tcomponent);
begin
 fdelayus:= -1;
 foptions:= defaultfieldparamlinkoptions;
 fsourcedatalink:= tparamsourcedatalink.create(self);
 fdestdatasource:= tdatasource.create(nil);
 fdestdatalink:= tparamdestdatalink.create(self);
 fdestdatalink.datasource:= fdestdatasource;
// fdestdatasource:= tlinkdatasource.create(nil);
 inherited;
end;

destructor tfieldparamlink.destroy;
begin
// freeandnil(ftimer);
 inherited;
 fsourcedatalink.free;
 fdestdatalink.free;
 fdestdatasource.free;
// fdestdatasource.free;
end;
{
procedure tfieldparamlink.dotimer(const sender: tobject);
begin
 fsourcedatalink.checkrefresh;
end;
}
function tfieldparamlink.getdatafield: string;
begin
 result:= fsourcedatalink.fieldname;
end;

procedure tfieldparamlink.setdatafield(const avalue: string);
begin
 fsourcedatalink.fieldname:= avalue;
end;

function tfieldparamlink.getdatasource: tdatasource;
begin
 result:= fsourcedatalink.datasource;
end;

procedure tfieldparamlink.setdatasource(const avalue: tdatasource);
begin
 fsourcedatalink.datasource:= avalue;
end;

function tfieldparamlink.getvisualcontrol: boolean;
begin
 result:= fsourcedatalink.visualcontrol;
end;

procedure tfieldparamlink.setvisualcontrol(const avalue: boolean);
begin
 fsourcedatalink.visualcontrol:= avalue;
end;

function tfieldparamlink.getdestdataset: tsqlquery;
begin
 result:= fdestdataset;
end;

procedure tfieldparamlink.setdestdataset(const avalue: tsqlquery);
var
 intf: igetdscontroller;
begin
 fdestdatasource.dataset:= avalue;
 if fdestdataset <> nil then begin
  fdestdataset.removefreenotification(self);
 end;
 fdestdataset:= avalue;
 fdestcontroller:= nil;
 if avalue <> nil then begin
  avalue.freenotification(self);
  if mseclasses.getcorbainterface(avalue,
                              typeinfo(igetdscontroller),intf) then begin
   fdestcontroller:= intf.getcontroller;
  end;
 end;
end;

procedure tfieldparamlink.notification(acomponent: tcomponent;
                                operation: toperation);
begin
 if (operation = opremove) and (acomponent = fdestdataset) then begin
  fdestdataset:= nil;
 end;
 inherited;
end;

function tfieldparamlink.param: tparam;
begin
 if fdestdataset = nil then begin
  databaseerror(name+': No destdataset');
 end
 else begin
  result:= fdestdataset.params.findparam(fparamname);
  if result = nil then begin
   databaseerror(name+': param "'+fparamname+'" not found');
  end;
 end;
end;

function tfieldparamlink.field: tfield;
begin
 result:= fsourcedatalink.field;
end;

procedure tfieldparamlink.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 fieldtypes:= nil;
end;

procedure tfieldparamlink.loaded;
begin
 inherited;
 fsourcedatalink.loaded;
end;

function tfieldparamlink.getdatasource(const aindex: integer): tdatasource;
begin
 result:= datasource;
end;

procedure tfieldparamlink.setdelayus(const avalue: integer);
begin
 fdelayus:= avalue;
 if fdelayus < 0 then begin
  fdelayus:= -1;
  checkrefresh;
 end;
end;

function tfieldparamlink.truedelayus: integer;
begin
 result:= fdelayus;
 if fnodelay > 0 then begin
  result:= -1;
 end;
end;

procedure tfieldparamlink.checkrefresh;
begin
 if fdestcontroller <> nil then begin
  fdestcontroller.checkrefresh;
 end;
end;

procedure tfieldparamlink.delayoff;
begin
 inc(fnodelay);
 if fnodelay = 1 then begin
  checkrefresh;
 end;
end;

procedure tfieldparamlink.delayon;
begin
 dec(fnodelay);
end;

{ tsequencedatalink }

constructor tsequencedatalink.create(const aowner: tsequencelink);
begin
 fowner:= aowner;
 inherited create;
end;

procedure tsequencedatalink.updatedata;
begin
 inherited;
 if (field <> nil) and field.isnull and (dataset <> nil) and 
      ((dataset.modified) or 
               (fdscontroller <> nil) and fdscontroller.posting) then begin
  if field.datatype in [ftlargeint,ftfloat,ftcurrency,ftbcd] then begin
   field.aslargeint:= fowner.aslargeint;
  end
  else begin
   field.asinteger:= fowner.asinteger;
  end;
 end;
end;

{ tsequencelink }

constructor tsequencelink.create(aowner: tcomponent);
begin
 fdatalink:= tsequencedatalink.create(self);
 inherited;
end;

destructor tsequencelink.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tsequencelink.setdatabase(const avalue: tsqlconnection);
begin
 if fdatabase <> avalue then begin
  fdbintf:= nil;
  if fdatabase <> nil then begin
   fdatabase.removefreenotification(self);
  end;
  if avalue <> nil then begin
   avalue.freenotification(self);
   mseclasses.getcorbainterface(avalue,typeinfo(idbcontroller),fdbintf);
  end;
  fdatabase:= avalue;
 end;
end;

procedure tsequencelink.setsequencename(const avalue: string);
begin
 fsequencename:= avalue;
end;

procedure tsequencelink.notification(acomponent: tcomponent;
               operation: toperation);
begin
 inherited;
 if (acomponent = fdatabase) and (operation = opremove) then begin
  fdatabase:= nil;
 end;
end;

procedure tsequencelink.checkintf;
begin
 if fdbintf = nil then begin
  raise edatabaseerror.create(name+': Database has no idscontroller interface.');
 end;
 if fsequencename = '' then begin
  raise edatabaseerror.create(name+': No sequencename.');
 end;
end;

function tsequencelink.getaslargeint: largeint;
begin
 checkintf;
 flastvalue:= getsqlresultvar(fdatabase.transaction,
                         fdbintf.readsequence(fsequencename),[]);
 if canevent(tmethod(fonupdatevalue)) then begin
  fonupdatevalue(self,flastvalue);
 end;
 result:= flastvalue;
end;
{
function tsequencelink.getaslargeint: largeint;
var                       //todo: optimize
 ds1: tsqlquery;
begin
 checkintf;
 ds1:= tsqlquery.create(nil);
 try
  ds1.parsesql:= false;
  ds1.sql.add(fdbintf.readsequence(fsequencename));
  ds1.database:= fdatabase;
  ds1.active:= true;
  flastvalue:= ds1.fields[0].aslargeint;
 finally
  ds1.free;
 end;
 if canevent(tmethod(fonupdatevalue)) then begin
  fonupdatevalue(self,flastvalue);
 end;
 result:= flastvalue;
end;
}
function tsequencelink.currvalue: largeint;
begin
 checkintf;
 result:= getsqlresultvar(fdatabase.transaction,
                         fdbintf.sequencecurrvalue(fsequencename),[]);
end;

procedure tsequencelink.setaslargeint(const avalue: largeint);
begin
 checkintf;
 fdbintf.executedirect(
   fdbintf.writesequence(fsequencename,avalue),false);
end;

function tsequencelink.getasinteger: integer;
begin
 result:= getaslargeint;
end;

procedure tsequencelink.setasinteger(const avalue: integer);
begin
 setaslargeint(avalue); 
end;

function tsequencelink.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tsequencelink.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
 if (csdesigning in componentstate) and (fdatabase = nil) and 
      (fdatalink.dataset is tsqlquery) then begin
  database:= tsqlconnection(tsqlquery(fdatalink.dataset).database);
 end;
end;

function tsequencelink.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tsequencelink.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

procedure tsequencelink.getfieldtypes(out propertynames: stringarty;
               out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= integerfields;
end;

function tsequencelink.assql: string;
begin
 result:= inttostr(aslargeint);
end;

function tsequencelink.getdatasource(const aindex: integer): tdatasource;
begin
 result:= datasource;
end;

{ tparamdestdatalink }

constructor tparamdestdatalink.create(const aowner: tfieldparamlink);
begin
 fowner:= aowner;
 inherited create;
end;

function tparamdestdatalink.cansync(out sourceds: tdataset): boolean;
begin
 with fowner.fsourcedatalink do begin
  result:= false;
  sourceds:= dataset;
  if sourceds <> nil then begin
   result:= sourceds.active;
  end;
 end;
end;

procedure tparamdestdatalink.DataEvent(Event: TDataEvent; Info: Ptrint);
var
 sourceds: tdataset;
begin
 inherited;
 with fowner do begin
  if cansync(sourceds) then begin
   case ord(event) of
    ord(deupdatestate): begin
     if (fplo_syncslaveedit in foptions) and (dataset.state = dsedit) and 
                     not (sourceds.state = dsedit) then begin
      sourceds.edit;
     end;
     if (fplo_syncslaveinsert in foptions) and(dataset.state = dsinsert) and
                                  not (sourceds.state = dsinsert) then begin
      sourceds.insert;
     end;
    end;
    de_afterdelete: begin
     if (fplo_syncslavedelete in foptions) then begin
      sourceds.delete;
     end;
    end;
   end;
  end;
 end;
end;

procedure tparamdestdatalink.CheckBrowseMode;
label
 endlab;
var
 intf: igetdscontroller;
 sourceds: tdataset;
begin
 if cansync(sourceds) then begin
  with fowner do begin
   inc(fsourcedatalink.frefreshlock);
   try
    if foptions * [fplo_syncslaveedit,fplo_syncslaveinsert] <> [] then begin
     if mseclasses.getcorbainterface(dataset,typeinfo(igetdscontroller),intf) and
                                        intf.getcontroller.canceling then begin
      sourceds.cancel;
      exit;
     end
     else begin
      if (sourceds.state = dsinsert) and 
                           (fplo_syncslavepost in foptions) then begin
       dataset.updaterecord;
       if dataset.modified then begin
        destdataset.post;
        goto endlab;
       end;
      end;
     end;
    end;
    if (fplo_syncslavepost in foptions) then begin
     sourceds.post;
//     destdataset.checkbrowsemode;
    end;
    inherited;
   endlab:
    if (dataset.state in [dsedit,dsinsert]) and 
      (foptions * [fplo_syncslaveedit,fplo_syncslaveinsert] <> []) then begin
     dataset.updaterecord; //synchronize fields
    end;
    if (dataset.state = dsinsert) and assigned(onupdateslaveinsert) then begin
     onupdateslaveinsert(destdataset,dataset);
    end;
    if (dataset.state = dsedit) and assigned(onupdateslaveedit) then begin
     onupdateslaveedit(destdataset,dataset);
    end;
   finally
    dec(fsourcedatalink.frefreshlock);
   end;
  end;
 end
 else begin
  inherited;
 end;
end;


end.
