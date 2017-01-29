{ MSEgui Copyright (c) 1999-2015 by Martin Schreiber

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
 classes,mclasses,mdb,msebufdataset,msqldb,msedb,mseclasses,msetypes,mseglob,
 msedatabase,sysutils,msetimer,msestrings,msearrayprops,mseapplication,
 msesqlquery,mseinterfaces;

type
 fieldparamlinkoptionty = (
              fplo_autorefresh,fplo_refreshifactiveonly,
              fplo_refreshifchangedonly,fplo_checkbrowsemodeonrefresh,
              fplo_restorerecno,
              fplo_syncmasterpost,fplo_delayedsyncmasterpost,
              fplo_syncmastercancel,
              fplo_syncmastercancelupdates,
              fplo_syncmasterapplyupdate,
              fplo_syncmastercheckbrowsemode,
              fplo_syncmasteredit,
              fplo_syncmasterinsert,
              fplo_syncmasterdelete,
              fplo_syncslavepost,fplo_delayedsyncslavepost,
              fplo_syncslavecancel,
              fplo_syncslaveedit,
              fplo_syncslaveinsert,fplo_syncslaveinserttoedit,
              fplo_syncslavedelete
              );
 fieldparamlinkoptionsty = set of fieldparamlinkoptionty;
const
 defaultfieldparamlinkoptions = [fplo_autorefresh,fplo_refreshifchangedonly];

 defaultsqlcontrolleroptions = defaultdscontrolleroptions;
 defaultsqlbdsoptions = defaultbufdatasetoptions +
                                            [bdo_autoapply,bdo_autocommitret];
type
 tmsesqltransaction = class(tsqltransaction,iactivatorclient)
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
 
 applyrecupdateeventty = 
     procedure(const sender: tmsesqlquery; const updatekind: tupdatekind;
                        var asql: msestring; var done: boolean) of object;
 afterapplyrecupdateeventty = 
     procedure(const sender: tmsesqlquery; 
                           const updatekind: tupdatekind) of object;
 updateerroreventty = procedure(const sender: tmsesqlquery;
                          const aupdatekind: tupdatekind;
                          var aupdateaction: tupdateaction) of object;

 tsqldscontroller = class(tdscontroller)
  protected
   function savepointbegin: integer; override;
   procedure savepointrollback(const alevel: integer = -1); override;
   procedure savepointrelease; override;
  public
   constructor create(const aowner: tmsesqlquery);
  published
   property options default defaultsqlcontrolleroptions;
 end;

 tmsesqlquery = class(tsqlquery,imselocate,idscontroller,igetdscontroller,
                              isqlpropertyeditor,iactivatorclient)
  private
   fsqlonchangebefore: notifyeventty;
//   fcontroller: tdscontroller;
   fonapplyrecupdate: applyrecupdateeventty;
   fonapplyrecupdate2: afterapplyrecupdateeventty;
   fafterapplyrecupdate: afterapplyrecupdateeventty;
   ftransopenref: integer;
   procedure setcontroller(const avalue: tdscontroller);
   procedure setactive1(value : boolean);
   function getactive: boolean;
   procedure setonapplyrecupdate(const avalue: applyrecupdateeventty);
   procedure setonapplyrecupdate2(const avalue: afterapplyrecupdateeventty);
   function getcontroller: tdscontroller;
   function getindexdefs: TIndexDefs;
   procedure setindexdefs(const avalue: TIndexDefs);
//   function getetstatementtype: TStatementType;
//   procedure setstatementtype(const avalue: TStatementType);
   procedure checkcanupdate;
  protected
   function getdefaultoptions(): bufdatasetoptionsty override;
   procedure dobeforeapplyupdate; override;
   procedure checkpendingupdates; override;
   procedure setactive(avalue: boolean); override;
   procedure setcontrolleractive(const avalue: boolean);
   procedure idscontroller.setactive = setcontrolleractive;
   procedure iactivatorclient.setactive = setcontrolleractive;
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
   procedure inheriteddelete();
   procedure inheritedinsert();
   function inheritedmoveby(const distance: integer): integer;  
   procedure inheritedinternalinsert; virtual;
   procedure inheritedinternaldelete; virtual;
   procedure inheritedinternalopen;
   procedure inheritedinternalclose;
   procedure doidleapplyupdates() override;

//   function wantblobfetch: boolean; override;
//   function getdsoptions: datasetoptionsty; override;
   procedure afterpost(const sender: tdataset; var ok: boolean);
//   function cantransactionrefresh: boolean; override;
//,   function refreshtransdatasets: boolean; override;
      
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function isutf8: boolean; override;
   procedure appendrecord(const values: array of const);
   procedure appendrecord(const values: array of const;
                                     const aisnull: array of boolean);
   function moveby(const distance: integer): integer;
   procedure cancel; override;
   function post1(): boolean; //true if OK
   procedure post override;
   function delete1(): boolean; //true if ok
   procedure delete override;
//   procedure insert; override;
   procedure applyupdates(const maxerrors: integer; 
                const cancelonerror: boolean;
                const cancelondeleteerror: boolean = false;
                const editonerror: boolean = false); overload; override;
   procedure applyupdates(const maxerrors: integer = 0); overload; override;
   procedure applyupdate; overload; override;
  published
   property FieldDefs;
   property delayedapplycount;
   property options default defaultsqlbdsoptions;
   property controller: tdscontroller read fcontroller write setcontroller;
   property Active: boolean read getactive write setactive1 default false;
   property onapplyrecupdate: applyrecupdateeventty read fonapplyrecupdate
                                  write setonapplyrecupdate;
             //raise eupdateerror in order to skip update of the record
   property onapplyrecupdate2: afterapplyrecupdateeventty 
                                  read fonapplyrecupdate2
                                  write setonapplyrecupdate2;
             //called after inherited
   property afterapplyrecupdate: afterapplyrecupdateeventty 
                          read fafterapplyrecupdate write fafterapplyrecupdate;
   property UpdateMode default upWhereKeyOnly;
   property UsePrimaryKeyAsKey default true;
   property IndexDefs : TIndexDefs read getindexdefs write setindexdefs;
               //must be writable because it is streamed
//   property StatementType : TStatementType read getetstatementtype 
//                                  write setstatementtype default stnone;
               //must be writable because it was streamed in FPC 2.0.4
 end;

 idbparaminfo = interface(inullinterface)[miid_idbparaminfo]
  function getdestdataset: tsqlquery;
 end;
 
 tfieldparamlink = class;

 setparameventty = procedure(const sender: tfieldparamlink;
                        var done: boolean) of object;  

 tparamsourcedatalink = class(tfielddatalink)
  private
   fownerlink: tfieldparamlink;
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
   fownerlink: tfieldparamlink;
  protected
   procedure updatedata; override;
   function cansync(out sourceds: tdataset): boolean;
   procedure DataEvent(Event: TDataEvent; Info: Ptrint); override;
   procedure CheckBrowseMode; override;
  public
   constructor create(const aowner: tfieldparamlink);
 end;

 tdestvalue = class(townedpersistent,idbeditinfo,idbparaminfo)
  private
   fdatalink: tfielddatalink;
//   fparamname: string;
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
   function getfieldname: string;
   procedure setfieldname(const avalue: string);
  protected
    //idbeditinfo
   function getdataset(const aindex: integer): tdataset; virtual;
   procedure getfieldtypes(out apropertynames: stringarty;
                          out afieldtypes: fieldtypesarty); virtual;
    //idbparaminfo
   function getdestdataset: tsqlquery;
  public
   constructor create(aowner: tobject); override;
   destructor destroy; override;
  published
   property datasource: tdatasource read getdatasource write setdatasource;
   property fieldname: string read getfieldname write setfieldname;
//   property paramname: string read fparamname write fparamname;
 end;

 tdestparam = class(tdestvalue)
  private
   fparamname: string;
  published
   property paramname: string read fparamname write fparamname;
 end;

 tdestparams = class(townedpersistentarrayprop)
  public
   constructor create(const aowner: tfieldparamlink); reintroduce;
   class function getitemclasstype: persistentclassty; override;
               //used in dumpunitgroups
 end;

 destfieldoptionty = (dfo_onlyifnull,dfo_notifunmodifiedinsert);
 destfieldoptionsty = set of destfieldoptionty;
 
 tdestfield = class(tdestvalue)
  private
   fdestfieldname: string;
   foptions: destfieldoptionsty;
  protected
    //idbeditinfo
   function getdataset(const aindex: integer): tdataset; override;
   procedure getfieldtypes(out apropertynames: stringarty;
                          out afieldtypes: fieldtypesarty); override;
  published
   property destfieldname: string read fdestfieldname write fdestfieldname;
   property options: destfieldoptionsty read foptions write foptions default [];
 end;
  
 tdestfields = class(townedpersistentarrayprop)
  public
   constructor create(const aowner: tfieldparamlink); reintroduce;
   class function getitemclasstype: persistentclassty; override;
               //used in dumpunitgroups   
 end;
 
 tfieldparamlink = class(tmsecomponent,idbeditinfo,idbparaminfo)
  private
   fsourcedatalink: tparamsourcedatalink;
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
   fdestparams: tdestparams;
   fdestfields: tdestfields;
   function getdatasource: tdatasource; overload;
   procedure setdatasource(const avalue: tdatasource);
   function getvisualcontrol: boolean;
   procedure setvisualcontrol(const avalue: boolean);
   function getdestdataset: tsqlquery;
   procedure setdestdataset(const avalue: tsqlquery);
   procedure setdelayus(const avalue: integer);
   procedure setdestparams(const avalue: tdestparams);
   function getfieldname: string;
   procedure setfieldname(const avalue: string);
   procedure readdatafield(reader: treader);
   procedure setdestfields(const avalue: tdestfields);
   procedure setoptions(const avalue: fieldparamlinkoptionsty);
  protected
   fcheckbrowsemodelock: int32;
   procedure loaded; override;
   procedure defineproperties(filer: tfiler); override;
    //idbeditinfo
   function getdataset(const aindex: integer): tdataset; overload;
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
   procedure notification(acomponent: tcomponent;
                                operation: toperation); override;
   function truedelayus: integer;
   procedure checkrefresh;
   function param(const aname: string): tparam; overload;
   function field(const aname: string): tfield; overload;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function param: tparam; overload;
   function field: tfield; overload;
   procedure delayoff;
   procedure delayon;
  published
   property fieldname: string read getfieldname write setfieldname;
   property datasource: tdatasource read getdatasource write setdatasource;
   property visualcontrol: boolean read getvisualcontrol
                    write setvisualcontrol default false;
   property destdataset: tsqlquery read getdestdataset write setdestdataset;
   property paramname: string read fparamname write fparamname;
   property delayus: integer read fdelayus write setdelayus default -1;
                //-1 -> off, 0 -> on idle
   property options: fieldparamlinkoptionsty read foptions write setoptions
                      default defaultfieldparamlinkoptions;
   property destparams: tdestparams read fdestparams 
                                            write setdestparams;
   property destfields: tdestfields read fdestfields 
                                            write setdestfields;
   property onsetparam: setparameventty read fonsetparam write fonsetparam;
   property onaftersetparam: notifyeventty read fonaftersetparam
                                  write fonaftersetparam;
   property onupdatemasteredit: masterdataseteventty read fonupdatemasteredit 
                     write fonupdatemasteredit;
   property onupdatemasterinsert: masterdataseteventty read fonupdatemasterinsert 
                     write fonupdatemasterinsert;
   property onupdateslaveedit: slavedataseteventty read fonupdateslaveedit
                     write fonupdateslaveedit;
   property onupdateslaveinsert: slavedataseteventty read fonupdateslaveinsert
                     write fonupdateslaveinsert;
 end;

 tsequencelink = class;
 
 tsequencedatalink = class(tfielddatalink)
  private
   fownerlink: tsequencelink;
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
   function getdataset(const aindex: integer): tdataset; overload;
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
 {$ifdef FPC}dbconst{$else}dbconst_del{$endif},msesysutils,typinfo,msedatalist,
 msesqlresult,msebits;
 
{ tmsesqltransaction }

constructor tmsesqltransaction.create(aowner: tcomponent);
begin
 inherited;
 fcontroller:= ttacontroller.create(self,iactivatorclient(self));
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
 fcontroller:= tsqldscontroller.create(self);
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

procedure tmsesqlquery.appendrecord(const values: array of const;
                                     const aisnull: array of boolean);
begin
 fcontroller.appendrecord1(values,aisnull);
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
 if bdo_local in foptions then begin
  openlocal();
 end
 else begin
  inherited internalopen;
 end;
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
 if not streamloading and not (bdo_local in foptions) then begin
  connected:= not (bdo_offline in foptions);
 end;
end;

procedure tmsesqlquery.setonapplyrecupdate(const avalue: applyrecupdateeventty);
begin
 if not (csloading in componentstate) then begin
  checkinactive;
 end;
 if assigned(avalue) and not (csdesigning in componentstate) then begin
  include(fmstate,sqs_userapplyrecupdate);
 end
 else begin
  if not assigned(fonapplyrecupdate2) then begin
   exclude(fmstate,sqs_userapplyrecupdate);
  end;
 end;
 fonapplyrecupdate:= avalue;
end;

procedure tmsesqlquery.setonapplyrecupdate2(
                        const avalue: afterapplyrecupdateeventty);
begin
 if not (csloading in componentstate) then begin
  checkinactive;
 end;
 if assigned(avalue) and not (csdesigning in componentstate) then begin
  include(fmstate,sqs_userapplyrecupdate);
 end
 else begin
  if not assigned(fonapplyrecupdate) then begin
   exclude(fmstate,sqs_userapplyrecupdate);
  end;
 end;
 fonapplyrecupdate2:= avalue;
end;

function tmsesqlquery.getcanmodify: Boolean;
begin
 result:= fcontroller.getcanmodify and 
              (inherited getcanmodify or not readonly and 
                                    (sqs_userapplyrecupdate in fmstate));
end;

procedure tmsesqlquery.applyrecupdate(updatekind: tupdatekind);
var
 bo1: boolean;
 str1: msestring;
begin
 try
  if sqs_userapplyrecupdate in fmstate then begin
   if assigned(fonapplyrecupdate) then begin
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
    inherited;
   end;
   if assigned(fonapplyrecupdate2) then begin
    fonapplyrecupdate2(self,updatekind);
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
  if bdo_rollbackonupdateerror in foptions then begin
   if writetransaction <> nil then begin
    writetransaction.rollback();
   end;
  end;
  raise;
 end;
end;

procedure tmsesqlquery.afterpost(const sender: tdataset; var ok: boolean);
begin
 if (bdo_autoapply in foptions) and 
                       not(bs_noautoapply in fbstate) then begin
  if bdo_autoapplyexceptions in foptions then begin
   applyupdate();
  end
  else begin
   try
    applyupdate;
   except
    ok:= false;
    application.handleexception(self);
   end;
  end;
 end;
end;

function tmsesqlquery.post1(): boolean;
begin
 result:= fcontroller.post(@afterpost);
end;

procedure tmsesqlquery.post;
begin
 post1();
end;

function tmsesqlquery.delete1(): boolean;
begin
 result:= fcontroller.delete();
end;

procedure tmsesqlquery.delete;
begin
 delete1();
end;

{
procedure tmsesqlquery.insert;
begin
 fcontroller.insert();
end;
}
procedure tmsesqlquery.afterapply;
begin
 if writetransaction <> nil then begin //can be nil in local mode
  if (ftransopenref = writetransaction.opencount) then begin
   if (writetransaction.savepointlevel < 0) then begin
    if bdo_autocommitret in foptions then begin
     writetransaction.commitretaining;
    end;
    if bdo_autocommit in foptions then begin
     writetransaction.commit;
    end;
   end
   else begin
    if bdo_autocommitret in foptions then begin
     writetransaction.pendingaction:= cacommitretaining;
    end;
    if bdo_autocommit in foptions then begin
     writetransaction.pendingaction:= cacommit;
    end;
   end;
  end;
 end;
 if bdo_refreshafterapply in foptions then begin
  fcontroller.refresh(bdo_recnoapplyrefresh in foptions);
 end;
end;

procedure tmsesqlquery.dobeforeapplyupdate;
begin
 inherited;
 if writetransaction <> nil then begin
  with writetransaction do begin
   ftransopenref:= opencount;
  end;
 end;
end;

procedure tmsesqlquery.checkcanupdate;
begin
 if not islocal and (transactionwrite = nil) then begin
  checkconnected;
 end;
end;

function tmsesqlquery.getdefaultoptions(): bufdatasetoptionsty;
begin
 result:= defaultsqlbdsoptions;
end;

procedure tmsesqlquery.applyupdates(const maxerrors: integer;
                const cancelonerror: boolean;
                const cancelondeleteerror: boolean = false;
                const editonerror: boolean = false);
begin
 checkcanupdate;
 try
  fmstate:= fmstate - [sqs_updateabort,sqs_updateerror];
  inherited;
 finally
  if (sqs_updateerror in fmstate) and 
              (bdo_cancelupdatesonerror in foptions) then begin
   cancelupdates;
  end;
 end;
end;

procedure tmsesqlquery.doidleapplyupdates;
var
 bo1: boolean;
begin
 if not (bs_idle in fbstate) and (changecount > 0) and 
           (changecount >= delayedapplycount) then begin
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
 if (state <> dsinactive) and (delayedapplycount > 0) and 
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
 applyupdates(maxerrors,foptions *
      [bdo_cancelupdateonerror,bdo_cancelupdatesonerror] <> [],
      bdo_cancelupdateondeleteerror in foptions,
      bdo_editonapplyerror in foptions);
end;

procedure tmsesqlquery.applyupdate;
begin
 checkcanupdate;
 inherited applyupdate(foptions *
      [bdo_cancelupdateonerror,bdo_cancelupdatesonerror] <> [],
      bdo_cancelupdateondeleteerror in foptions,
      bdo_editonapplyerror in foptions);
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
 if (bdo_autoapply in foptions) and 
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
{
function tmsesqlquery.getdsoptions: datasetoptionsty;
begin
 result:= fcontroller.options;
end;
}
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
 result:= (bdo_local in foptions) and not connected;
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

procedure tmsesqlquery.setcontrolleractive(const avalue: boolean);
begin
 setactive(avalue);
end;

procedure tmsesqlquery.inheriteddelete();
begin
 inherited delete();
end;

procedure tmsesqlquery.inheritedinsert();
begin
 inherited insert();
end;

{
procedure tmsesqlquery.dscontrolleroptionschanged(const aoptions: datasetoptionsty);
begin
 //dummy
end;
}
{
function tmsesqlquery.cantransactionrefresh: boolean;
begin
 result:= not (dso_notransactionrefresh in fcontroller.options);
end;
}
{ tparamsourcedatalink }

constructor tparamsourcedatalink.create(const aowner: tfieldparamlink);
begin
 fownerlink:= aowner;
 inherited create;
end;

procedure tparamsourcedatalink.recordchanged(afield: tfield);
var
 bo1,bo2: boolean;
 int1: integer;
 var1: variant;
begin
 if not (csloading in fownerlink.componentstate) then begin
  inherited;
//  if frefreshlock = 0 then begin
  if active and (field <> nil) and
                ((afield = nil) or (afield = self.field)) then begin
   if fchangelock <> 0 then begin
    databaseerror('Recursive recordchanged.',fownerlink);
   end;
   inc(fchangelock);
   try
    with fownerlink do begin
     if not (csdesigning in componentstate) then begin
      fparamset:= true;
      bo1:= false;
      bo2:= not (fplo_refreshifchangedonly in foptions) or 
                                         not fdestdataset.active;
      if not bo2 then begin
       var1:= param.value;
      end;
      if assigned(fonsetparam) then begin
       fonsetparam(fownerlink,bo1);
      end;
      if not bo1 and (dataset <> nil) then begin
       if fparamname <> '' then begin
        fieldtoparam(self.field,param);
       end;
       with fdestparams do begin
        for int1:= 0 to high(fitems) do begin
         with tdestparam(fitems[int1]) do begin
          if (fdatalink.field <> nil) and (fparamname <> '') then begin
           fieldtoparam(fdatalink.field,param(fparamname));
          end;
         end;
        end;
       end;
      end;
      if assigned(fonaftersetparam) then begin
       fonaftersetparam(fownerlink);
      end;
      bo2:= bo2 or (var1 <> param.value);
      if (frefreshlock = 0) and (fplo_autorefresh in foptions) and 
                                              (destdataset <> nil) and bo2 and
         (fdestdataset.active or 
                   not (fplo_refreshifactiveonly in foptions)) and
         not((fdestdataset.state = dsinsert) and (dataset.state = dsinsert) and
                      (fplo_syncmasterinsert in foptions)) and
         not ((fplo_delayedsyncmasterpost in foptions) and
                (self.fdscontroller <> nil) and 
                                    self.fdscontroller.posting1) then begin
       if fdestdataset.active then begin
        if fplo_checkbrowsemodeonrefresh in foptions then begin
         fdestdataset.checkbrowsemode;
        end
        else begin
         fdestdataset.cancel;
        end;
        if fdestcontroller <> nil then begin
         fdestcontroller.refresh(fplo_restorerecno in foptions,truedelayus);
        end
        else begin
         fdestdataset.refresh;
        end;
       end
       else begin
        fdestdataset.active:= true;
       end;
      end;
     end;
    end;
   finally
    dec(fchangelock);
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
 with fownerlink do begin
  if (destdataset <> nil) and destdataset.active then begin
   inc(frefreshlock);
   try
    case ord(event) of
     ord(deupdatestate): begin
      if (fplo_syncmasteredit in foptions) and (dataset.state = dsedit) and 
                      not (fownerlink.destdataset.state = dsedit) then begin
       destdataset.edit;
      end;
      if (fplo_syncmasterinsert in foptions) and(dataset.state = dsinsert) and
                                   not (destdataset.state = dsinsert) then begin
       destdataset.insert();
      end;
     end;
     de_afterdelete: begin
      if (fplo_syncmasterdelete in foptions) and 
                                   not destdataset.isempty then begin
       destdataset.delete();
      end;
     end;
     de_afterpost: begin
      if (fplo_delayedsyncmasterpost in foptions) and
                           (destdataset.state in [dsinsert,dsedit]) then begin
       destdataset.post();
      end;
     end;
     de_afterapplyupdate: begin
      if (fplo_syncmasterapplyupdate in foptions) then begin
       destdataset.applyupdates();
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
 posted1: boolean;
begin
 with fownerlink do begin
  if (destdataset <> nil) and destdataset.active then begin
   inc(frefreshlock);
   try
    posted1:= false;
    if foptions * [fplo_syncmasteredit,fplo_syncmasterinsert,
                               fplo_syncmastercancel] <> [] then begin
     if mseclasses.getcorbainterface(dataset,
                     typeinfo(igetdscontroller),intf) and
                                        intf.getcontroller.canceling then begin
      destdataset.cancel;
      if fplo_syncmastercancelupdates in foptions then begin
       destdataset.cancelupdates();
      end;
      exit;
     end
     else begin
      if (destdataset.state = dsinsert) and 
                           (fplo_syncmasterpost in foptions) and 
                           (dataset.state in [dsedit,dsinsert]) then begin
       if fplo_delayedsyncmasterpost in foptions then begin
        exit;
       end;
       dataset.updaterecord;
       if dataset.modified then begin
        posted1:= true;
        destdataset.post;
        goto endlab;
       end;
      end;
     end;
    end;
    if (fplo_syncmasterpost in foptions) then begin
     if fplo_delayedsyncmasterpost in foptions then begin
      exit;
     end;
     posted1:= true;
     destdataset.post;
//     destdataset.checkbrowsemode;
    end
    else begin
     if (fplo_syncmastercheckbrowsemode in foptions) and 
                                     (fcheckbrowsemodelock = 0) then begin
      destdataset.checkbrowsemode();
     end;
    end;
    inherited;
   endlab:
    if (dataset.state in [dsedit,dsinsert]) and 
      (foptions * [fplo_syncmasteredit,fplo_syncmasterinsert] <> []) and 
                                                            posted1 then begin
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

{ tparamdestdatalink }

constructor tparamdestdatalink.create(const aowner: tfieldparamlink);
begin
 fownerlink:= aowner;
 inherited create;
end;

function tparamdestdatalink.cansync(out sourceds: tdataset): boolean;
begin
 with fownerlink.fsourcedatalink do begin
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
 with fownerlink do begin
  if cansync(sourceds) then begin
   case ord(event) of
    ord(deupdatestate): begin
     if (fplo_syncslaveedit in foptions) and (dataset.state = dsedit) and 
                     not (sourceds.state = dsedit) then begin
      sourceds.edit;
     end;
     if ([fplo_syncslaveinsert,fplo_syncslaveinserttoedit] * foptions <>
                               []) and (dataset.state = dsinsert) then begin
      inc(fcheckbrowsemodelock);
      try
       if (fplo_syncslaveinsert in foptions) and
                                       (sourceds.state <> dsinsert) then begin
        sourceds.insert();
       end
       else begin
        if (fplo_syncslaveinserttoedit in foptions) and
                                         (sourceds.state <> dsedit) then begin
         sourceds.edit();
        end;
       end;
      finally
       dec(fcheckbrowsemodelock);
      end;
     end;
    end;
    de_afterdelete: begin
     if (fplo_syncslavedelete in foptions) and
                                     not sourceds.isempty then begin
      sourceds.delete;
     end;
    end;
    de_afterpost: begin
     if (fplo_delayedsyncslavepost in foptions) and 
                           (sourceds.state in [dsinsert,dsedit]) then begin
      sourceds.checkbrowsemode();
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
 canceling: boolean;
begin
 if cansync(sourceds) then begin
  with fownerlink do begin
   inc(fsourcedatalink.frefreshlock);
   try
    canceling:= mseclasses.getcorbainterface(
                            dataset,typeinfo(igetdscontroller),intf) and
                                        intf.getcontroller.canceling;
    if fplo_syncslavecancel in foptions then begin
     if canceling then begin
      if fsourcedatalink.frefreshlock = 1 then begin
       sourceds.cancel;
      end;
      exit;
     end
     else begin
      if (sourceds.state = dsinsert) and (dataset.state <> dsbrowse) and 
                           (fplo_syncslavepost in foptions) then begin
       dataset.updaterecord;
       if dataset.modified then begin
        destdataset.post;
        updatedata;
        goto endlab;
       end;
      end;
     end;
    end;
    if (fplo_syncslavepost in foptions) and 
                      (dataset.state <> dsbrowse) and not canceling then begin
     if fplo_delayedsyncslavepost in foptions then begin
      exit;
     end;
     sourceds.post;
     updatedata;
    end;
    inherited;
   endlab:
    if (dataset.state in [dsedit,dsinsert]) and not canceling and
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

procedure tparamdestdatalink.updatedata;
var
 int1: integer;
 field1: tfield;
begin
 with fownerlink do begin
  with fdestfields do begin
   for int1:= 0 to high(fitems) do begin
    with tdestfield(fitems[int1]) do begin
     if (fdatalink.field <> nil) and (fdestfieldname <> '') then begin
      field1:= field(fdestfieldname);
      if (not (dfo_onlyifnull in foptions) or (field1.isnull)) and 
         (not (dfo_notifunmodifiedinsert in foptions) or 
                           dataset.modified) then begin
       field1.value:= fdatalink.field.value;
      end;
     end;
    end;
   end;
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
 fdestparams:= tdestparams.create(self);
 fdestfields:= tdestfields.create(self);
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
 fdestparams.free;
 fdestfields.free;
// fdestdatasource.free;
end;
{
procedure tfieldparamlink.dotimer(const sender: tobject);
begin
 fsourcedatalink.checkrefresh;
end;
}
function tfieldparamlink.getfieldname: string;
begin
 result:= fsourcedatalink.fieldname;
end;

procedure tfieldparamlink.setfieldname(const avalue: string);
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

function tfieldparamlink.param(const aname: string): tparam;
begin
 result:= nil;
 if fdestdataset = nil then begin
  databaseerror(name+': No destdataset');
 end
 else begin
  result:= fdestdataset.params.findparam(aname);
  if result = nil then begin
   databaseerror(name+': param "'+aname+'" not found');
  end;
 end;
end;

function tfieldparamlink.field(const aname: string): tfield;
begin
 result:= nil;
 if fdestdataset = nil then begin
  databaseerror(name+': No destdataset');
 end
 else begin
  result:= fdestdataset.fieldbyname(aname);
  if result = nil then begin
   databaseerror(name+': field "'+aname+'" not found');
  end;
 end;
end;

function tfieldparamlink.param: tparam;
begin
 result:= param(fparamname);
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

function tfieldparamlink.getdataset(const aindex: integer): tdataset;
begin
 result:= fsourcedatalink.dataset;
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

procedure tfieldparamlink.setdestparams(const avalue: tdestparams);
begin
 fdestparams.assign(avalue);
end;

procedure tfieldparamlink.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('datafield',{$ifdef FPC}@{$endif}readdatafield,nil,false);
end;

procedure tfieldparamlink.readdatafield(reader: treader);
begin
 fieldname:= reader.readstring;
end;

procedure tfieldparamlink.setdestfields(const avalue: tdestfields);
begin
 fdestfields.assign(avalue);
end;

procedure tfieldparamlink.setoptions(const avalue: fieldparamlinkoptionsty);
begin
 foptions:= fieldparamlinkoptionsty(setsinglebit(card32(avalue),
              card32(foptions),
                card32([fplo_syncslaveinsert,fplo_syncslaveinserttoedit])));
 if fplo_syncmastercancelupdates in avalue then begin
  foptions:= foptions + [fplo_syncmastercancel];
 end;
 if not (fplo_syncmastercancel in avalue) then begin
  foptions:= foptions - [fplo_syncmastercancelupdates];
 end;
end;

{ tsequencedatalink }

constructor tsequencedatalink.create(const aowner: tsequencelink);
begin
 fownerlink:= aowner;
 inherited create;
end;

procedure tsequencedatalink.updatedata;
begin
 inherited;
 if (field <> nil) and field.isnull and (dataset <> nil) and 
      ((dataset.modified) or 
               (fdscontroller <> nil) and fdscontroller.posting) then begin
  if field.datatype in [ftlargeint,ftfloat,ftcurrency,ftbcd] then begin
   field.aslargeint:= fownerlink.aslargeint;
  end
  else begin
   field.asinteger:= fownerlink.asinteger;
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

function tsequencelink.getdataset(const aindex: integer): tdataset;
begin
 result:= fdatalink.dataset;
end;


{ tsqldscontroller }

function tsqldscontroller.savepointbegin: integer;
begin
 result:= 0;
 with tmsesqlquery(fowner) do begin
  if writetransaction <> nil then begin
   result:= writetransaction.savepointbegin;
  end;
 end;
end;

procedure tsqldscontroller.savepointrollback(const alevel: integer = -1);
begin
 with tmsesqlquery(fowner) do begin
  if (writetransaction <> nil) and writetransaction.active then begin
   writetransaction.savepointrollback(alevel);
  end;
 end;
end;

procedure tsqldscontroller.savepointrelease;
begin
 with tmsesqlquery(fowner) do begin
  if (writetransaction <> nil) and writetransaction.active then begin
   writetransaction.savepointrelease;
  end;
 end;
end;

constructor tsqldscontroller.create(const aowner: tmsesqlquery);
begin
 inherited create(aowner,idscontroller(aowner),-1,false);
 foptions:= defaultsqlcontrolleroptions;
end;

{ tdestparams }

constructor tdestparams.create(const aowner: tfieldparamlink);
begin
 inherited create(aowner,tdestparam);
end;

class function tdestparams.getitemclasstype: persistentclassty;
begin
 result:= tdestparam;
end;

{ tdestfields }

constructor tdestfields.create(const aowner: tfieldparamlink);
begin
 inherited create(aowner,tdestfield);
end;

class function tdestfields.getitemclasstype: persistentclassty;
begin
 result:= tdestfield;
end;

{ tdestvalue }

constructor tdestvalue.create(aowner: tobject);
begin
 inherited;
 fdatalink:= tfielddatalink.create;
end;

destructor tdestvalue.destroy;
begin
 fdatalink.free;
end;

function tdestvalue.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tdestvalue.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

function tdestvalue.getfieldname: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdestvalue.setfieldname(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tdestvalue.getdataset(const aindex: integer): tdataset;
begin
 result:= fdatalink.dataset;
end;

procedure tdestvalue.getfieldtypes(out apropertynames: stringarty;
               out afieldtypes: fieldtypesarty);
begin
 apropertynames:= nil;
 afieldtypes:= nil;
end;

function tdestvalue.getdestdataset: tsqlquery;
begin
 result:= tfieldparamlink(fowner).destdataset;
end;

{ tdestfield }

function tdestfield.getdataset(const aindex: integer): tdataset;
begin
 result:= nil;
 case aindex of
  0: result:= fdatalink.dataset;
  1: result:= tfieldparamlink(fowner).fdestdataset;
 end;
end;

procedure tdestfield.getfieldtypes(out apropertynames: stringarty;
               out afieldtypes: fieldtypesarty);
begin
 setlength(apropertynames,2);
 apropertynames[0]:= 'filedname';
 apropertynames[1]:= 'destfieldname';
 afieldtypes:= nil;
end;

end.
