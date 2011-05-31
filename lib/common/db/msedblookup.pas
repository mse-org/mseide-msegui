unit msedblookup;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,db,msewidgetgrid,msedataedits,mseeditglob,msestrings,msedatalist,
 msedbedit,msedb,msegui,msegrids,msedbdispwidgets,mselookupbuffer,mseclasses,
 mseformatstr,msetypes,mseglob,msemenus,mseguiglob;

const
 defaultlookupoptionsedit = defaultoptionsedit + [oe_readonly];

type
 tdblookup32lb = class;
 
 tlookupdispfielddatalink = class(tdispfielddatalink)
  private
   fowner: tcustomdataedit;
   function getdatasource1: tdatasource;
   procedure setwidgetdatasource(const avalue: tdatasource);
   procedure griddatasourcechanged;
  public
   constructor create(const aowner: tcustomdataedit; 
                                    const intf: idbdispfieldlink);
  published
   property datasource: tdatasource read getdatasource1 write setwidgetdatasource;
 end;
 
 tlookupdatalink = class(tfielddatalink)
  private
   fkeyfield: tfield;
   fkeyfieldname: string;
  protected
   procedure updatefields; override;
 end;
 
 tlookupdbdispfielddatalink = class(tlookupdispfielddatalink)
  private
   flookupdatalink: tlookupdatalink;
   procedure setlookupkeyfield(const avalue: string);
   procedure setlookupvaluefield(const avalue: string);
   function getlookupkeyfield: string;
   function getlookupvaluefield: string;
  public
   constructor create(const aowner: tcustomdataedit; 
                                    const intf: idbdispfieldlink);
   destructor destroy; override;
  published
   property lookupkeyfield: string read getlookupkeyfield 
                                            write setlookupkeyfield;
   property lookupvaluefield: string read getlookupvaluefield 
                                            write setlookupvaluefield;
 end;
 
 tdblookup = class(tcustomdataedit,idbdispfieldlink)
  private
   fdatalink: tlookupdispfielddatalink;
   fisnull: boolean;
   procedure setdatalink(const avalue: tlookupdispfielddatalink);
  protected
   procedure updatelookupvalue; virtual; abstract;
   procedure setlookupvalue(const aindex: integer); virtual; abstract;
                  //aindex -1 -> NULL
   function getkeylbdatakind: lbdatakindty; virtual; abstract;
   function getdatalbdatakind: lbdatakindty; virtual; abstract;
   procedure dochange; override;
   function lookuptext(const aindex: integer): msestring; virtual; abstract;
   function getdatatype: listdatatypety; override;
   procedure valuetogrid(row: integer); override;
   procedure griddatasourcechanged; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getoptionsedit: optionseditty; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure setnullvalue; override;
  
    //idispfieldlink
   procedure fieldtovalue; virtual;
   procedure valuetofield;
   procedure getfieldtypes(var afieldtypes: fieldtypesty); virtual;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property isnull: boolean read fisnull;
  published
   property datalink: tlookupdispfielddatalink read fdatalink write setdatalink;

   property empty_color;
   property empty_font;
   property empty_fontstyle;
   property empty_textflags;
   property empty_text;
   property empty_options;
   property empty_textcolor;
   property empty_textcolorbackground;
   property optionsedit default defaultlookupoptionsedit;
   property font;
   property textflags;
   property textflagsactive;
   property caretwidth;
   property onchange;
   property ongettext;
//   property onsettext;
   property onkeydown;
   property onkeyup;
 end;

 tdblookupdb = class(tdblookup)
  private
  public
   constructor create(aowner: tcomponent); override;
 end;
 
 tdblookup32db = class(tdblookupdb,ireccontrol)
  private
   fkey: integer;
  protected
   procedure updatelookupvalue; override;
   function internaldatatotext(const data): msestring; override;
   function getrowdatapo(const arow: integer): pointer; override;
  //idbeditfieldlink
   procedure fieldtovalue; override;
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
  public
 end;
 
 tdblookuplb = class(tdblookup,ilookupbufferfieldinfo)
  private
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: lookupbufferfieldnoty;
   flookupvaluefieldno: lookupbufferfieldnoty;   
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
  protected
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
    //ilookupbufferfieldinfo
   function getlbdatakind(const apropname: string): lbdatakindty;
   function getlookupbuffer: tcustomlookupbuffer;
  published
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer 
                                            write setlookupbuffer;
   property lookupkeyfieldno: lookupbufferfieldnoty read flookupkeyfieldno 
                                            write flookupkeyfieldno default 0;
   property lookupvaluefieldno: lookupbufferfieldnoty read flookupvaluefieldno
                                            write flookupvaluefieldno default 0;
 end;
  
 tdblookup32lb = class(tdblookuplb,ireccontrol)
  private
   fkey: integer;
  protected
   procedure updatelookupvalue; override;
   function internaldatatotext(const data): msestring; override;
   function getrowdatapo(const arow: integer): pointer; override;
   function getkeylbdatakind: lbdatakindty; override;
  //idbeditfieldlink
   procedure fieldtovalue; override;
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
  public
 end;

 tdblookup64lb = class(tdblookuplb,ireccontrol)
  private
   fkey: int64;
  protected
   procedure updatelookupvalue; override;
   function internaldatatotext(const data): msestring; override;
   function getrowdatapo(const arow: integer): pointer; override;
   function getkeylbdatakind: lbdatakindty; override;
  //idbeditfieldlink
   procedure fieldtovalue; override;
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
  public
 end;

 tdblookupstrlb = class(tdblookuplb,ireccontrol)
  private
   fkey: msestring;
  protected
   procedure updatelookupvalue; override;
   function internaldatatotext(const data): msestring; override;
   function getrowdatapo(const arow: integer): pointer; override;
   function getkeylbdatakind: lbdatakindty; override;
  //idbeditfieldlink
   procedure fieldtovalue; override;
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
  public
 end;

 tdbstringlookuplb = class(tdblookup32lb)
  private
   fvalue: msestring;
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   property value: msestring read fvalue;
 end;

 tdbintegerlookuplb = class(tdblookup32lb)
  private
   fbase: numbasety;
   fbitcount: integer;
   fvalue: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aaowner: tcomponent); override;
   property value: integer read fvalue;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbreallookuplb = class(tdblookup32lb)
  private
   fformat: msestring;
   fvaluerange: real;
   fvaluestart: real;
   fvalue: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluerange(const avalue: real);
   procedure setvaluestart(const avalue: real);
   procedure readvaluescale(reader: treader);
  protected
   procedure defineproperties(filer: tfiler); override;
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   property value: real read fvalue;
  published
   property valuerange: real read fvaluerange write setvaluerange;
   property valuestart: real read fvaluestart write setvaluestart;
   property format: msestring read fformat write setformat;
 end;

 tdbdatetimelookuplb = class(tdblookup32lb)
  private
   fformat: msestring;
   fkind: datetimekindty;
   fvalue: tdatetime;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  published
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property format: msestring read fformat write setformat;
   property value: tdatetime read fvalue;
 end;
 
 tdbstringlookup64lb = class(tdblookup64lb)
  private
   fvalue: msestring;
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   property value: msestring read fvalue;
 end;

 tdbintegerlookup64lb = class(tdblookup64lb)
  private
   fbase: numbasety;
   fbitcount: integer;
   fvalue: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aaowner: tcomponent); override;
   property value: integer read fvalue;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbreallookup64lb = class(tdblookup64lb)
  private
   fformat: msestring;
   fvaluerange: real;
   fvaluestart: real;
   fvalue: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluerange(const avalue: real);
   procedure setvaluestart(const avalue: real);
   procedure readvaluescale(reader: treader);
  protected
   procedure defineproperties(filer: tfiler); override;
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   property value: real read fvalue;
  published
   property valuerange: real read fvaluerange write setvaluerange;
   property valuestart: real read fvaluestart write setvaluestart;
   property format: msestring read fformat write setformat;
 end;

 tdbdatetimelookup64lb = class(tdblookup64lb)
  private
   fformat: msestring;
   fkind: datetimekindty;
   fvalue: tdatetime;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   property value: tdatetime read fvalue;
  published
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property format: msestring read fformat write setformat;
 end;

 tdbstringlookupstrlb = class(tdblookupstrlb)
  private
   fvalue: msestring;
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   property value: msestring read fvalue;
 end;

 tdbintegerlookupstrlb = class(tdblookupstrlb)
  private
   fbase: numbasety;
   fbitcount: integer;
   fvalue: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aaowner: tcomponent); override;
   property value: integer read fvalue;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbreallookupstrlb = class(tdblookupstrlb)
  private
   fformat: msestring;
   fvaluerange: real;
   fvaluestart: real;
   fvalue: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluerange(const avalue: real);
   procedure setvaluestart(const avalue: real);
   procedure readvaluescale(reader: treader);
  protected
   procedure defineproperties(filer: tfiler); override;
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   property value: real read fvalue;
  published
   property valuerange: real read fvaluerange write setvaluerange;
   property valuestart: real read fvaluestart write setvaluestart;
   property format: msestring read fformat write setformat;
 end;

 tdbdatetimelookupstrlb = class(tdblookupstrlb)
  private
   fformat: msestring;
   fkind: datetimekindty;
   fvalue: tdatetime;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   function getdatalbdatakind: lbdatakindty; override;
   procedure setlookupvalue(const aindex: integer); override;
   function lookuptext(const aindex: integer): msestring; override;
  public
   property value: tdatetime read fvalue;
  published
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property format: msestring read fformat write setformat;
 end;
 
implementation
uses
 msereal;
 
{ tlookupdispfielddatalink }

constructor tlookupdispfielddatalink.create(const aowner: tcustomdataedit;
                               const intf: idbdispfieldlink);
begin
 fowner:= aowner;
 inherited create(intf);
end;

procedure tlookupdispfielddatalink.setwidgetdatasource(const avalue: tdatasource);
begin
 if not ((csloading in fowner.componentstate) and datasourcefixed or 
                  (fowner.gridintf <> nil)) then begin
  inherited datasource:= avalue;
 end;
end;

procedure tlookupdispfielddatalink.griddatasourcechanged;
var
 dso1: tdatasource;
begin
 with fowner do begin
  dso1:=  tcustomdbwidgetgrid(gridintf.getcol.grid).datalink.datasource;
 end;
 if dso1 <> datasource then begin
  inherited datasource:= dso1;
 end;
end;

function tlookupdispfielddatalink.getdatasource1: tdatasource;
begin
 result:= inherited datasource;
end;

{ tdblookup }

constructor tdblookup.create(aowner: tcomponent);
begin
 fisnull:= true;
 if fdatalink = nil then begin
  fdatalink:= tlookupdispfielddatalink.create(self,idbdispfieldlink(self));
 end;
 inherited;
 foptionsedit:= defaultlookupoptionsedit;
end;

destructor tdblookup.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdblookup.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit + [oe_readonly];
end;

procedure tdblookup.setnullvalue;
begin
 inherited;
 fisnull:= true;
 changed;
end;

procedure tdblookup.texttovalue(var accept: boolean; const quiet: boolean);
begin
 fisnull:= text = '';
end;

procedure tdblookup.valuetofield;
begin
 //dummy
end;

procedure tdblookup.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdblookup.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdblookup.setdatalink(const avalue: tlookupdispfielddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdblookup.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

function tdblookup.getdatatype: listdatatypety;
begin
 result:= dl_none;
end;

procedure tdblookup.valuetogrid(row: integer);
begin
 //dummy
end;

procedure tdblookup.fieldtovalue;	
begin
 valuetotext;
 changed;
end;

procedure tdblookup.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 //dummy
end;

procedure tdblookup.dochange;
begin
 updatelookupvalue;
 inherited;
end;

{ tdblookuplb }

function tdblookuplb.getlbdatakind(const apropname: string): lbdatakindty;
begin
 if apropname = 'lookupkeyfieldno' then begin
  result:= getkeylbdatakind;
 end
 else begin
  result:= getdatalbdatakind;
 end;
end;

function tdblookuplb.getlookupbuffer: tcustomlookupbuffer;
begin
 result:= flookupbuffer;
end;

procedure tdblookuplb.setlookupbuffer(const avalue: tcustomlookupbuffer);
begin
 setlinkedvar(avalue,tmsecomponent(flookupbuffer));
end;

procedure tdblookuplb.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event in [oe_changed,oe_connect]) and (sender = flookupbuffer) then begin
  if fdatalink.active and (fdatalink.field <> nil) then begin
   formatchanged;
   fieldtovalue;
  end;
 end;
end;

{ tdblookup32lb }

procedure tdblookup32lb.updatelookupvalue;
var
 int1: integer;
begin
 int1:= -1;
 if not fisnull and (flookupbuffer <> nil) then begin
  flookupbuffer.findphys(flookupkeyfieldno,fkey,int1);
 end;
 setlookupvalue(int1);
end;

function tdblookup32lb.internaldatatotext(const data): msestring;

 procedure lookup(const akey: integer);
 var
  int1: integer;
 begin
  result:= '';
  if flookupbuffer <> nil then begin
   if flookupbuffer.findphys(flookupkeyfieldno,akey,int1) then begin
    result:= lookuptext(int1);
   end;
  end;
 end;
  
begin
 if (@data = nil) and fisnull then begin
  result:= '';
 end
 else begin
  if @data = nil then begin
   lookup(fkey);
  end
  else begin
   lookup(integer(data));
  end;
 end;
end;

procedure tdblookup32lb.fieldtovalue;
begin
 fisnull:= false;
 fkey:= fdatalink.field.asinteger;
 inherited;
end;

function tdblookup32lb.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getintegerbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

procedure tdblookup32lb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

function tdblookup32lb.getkeylbdatakind: lbdatakindty;
begin
 result:= lbdk_integer;
end;

{ tdblookup64lb }

procedure tdblookup64lb.updatelookupvalue;
var
 int1: integer;
begin
 int1:= -1;
 if not fisnull and (flookupbuffer <> nil) then begin
  flookupbuffer.findphys(flookupkeyfieldno,fkey,int1);
 end;
 setlookupvalue(int1);
end;

function tdblookup64lb.internaldatatotext(const data): msestring;

 procedure lookup(const akey: int64);
 var
  int1: integer;
 begin
  result:= '';
  if flookupbuffer <> nil then begin
   if flookupbuffer.findphys(flookupkeyfieldno,akey,int1) then begin
    result:= lookuptext(int1);
   end;
  end;
 end;
  
begin
 if (@data = nil) and fisnull then begin
  result:= '';
 end
 else begin
  if @data = nil then begin
   lookup(fkey);
  end
  else begin
   lookup(int64(data));
  end;
 end;
end;

procedure tdblookup64lb.fieldtovalue;
begin
 fisnull:= false;
 fkey:= fdatalink.field.aslargeint;
 inherited;
end;

function tdblookup64lb.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getint64buffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

procedure tdblookup64lb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

function tdblookup64lb.getkeylbdatakind: lbdatakindty;
begin
 result:= lbdk_int64;
end;

{ tdblookupstrlb }

procedure tdblookupstrlb.updatelookupvalue;
var
 int1: integer;
begin
 int1:= -1;
 if not fisnull and (flookupbuffer <> nil) then begin
  flookupbuffer.findphys(flookupkeyfieldno,fkey,int1,false);
 end;
 setlookupvalue(int1);
end;

function tdblookupstrlb.internaldatatotext(const data): msestring;

 procedure lookup(const akey: msestring);
 var
  int1: integer;
 begin
  result:= '';
  if flookupbuffer <> nil then begin
   if flookupbuffer.findphys(flookupkeyfieldno,akey,int1,true) then begin
    result:= lookuptext(int1);
   end;
  end;
 end;
  
begin
 if (@data = nil) and fisnull then begin
  result:= '';
 end
 else begin
  if @data = nil then begin
   lookup(fkey);
  end
  else begin
   lookup(msestring(data));
  end;
 end;
end;

procedure tdblookupstrlb.fieldtovalue;
begin
 fisnull:= false;
 fkey:= fdatalink.asmsestring;
 inherited;
end;

function tdblookupstrlb.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getstringbuffer(
                                                fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

procedure tdblookupstrlb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= textfields;
end;

function tdblookupstrlb.getkeylbdatakind: lbdatakindty;
begin
 result:= lbdk_text;
end;

{ tdbstringlookuplb }

procedure tdbstringlookuplb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= '';
 end
 else begin
  fvalue:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
 end;
end;

function tdbstringlookuplb.lookuptext(const aindex: integer): msestring;
begin
 result:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
end;

function tdbstringlookuplb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_text;
end;

{ tdbintegerlookuplb }

constructor tdbintegerlookuplb.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
end;

procedure tdbintegerlookuplb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= 0;
 end
 else begin
  fvalue:= flookupbuffer.integervaluephys(flookupvaluefieldno,aindex);
 end;
end;

function tdbintegerlookuplb.lookuptext(const aindex: integer): msestring;
begin
 result:= intvaluetostr(flookupbuffer.integervaluephys(
                        flookupvaluefieldno,aindex),fbase,fbitcount);
end;

procedure tdbintegerlookuplb.setbase(const avalue: numbasety);
begin
 if fbase <> avalue then begin
  fbase := avalue;
  formatchanged;
 end;
end;

procedure tdbintegerlookuplb.setbitcount(const avalue: integer);
begin
 if fbitcount <> avalue then begin
  fbitcount := avalue;
  formatchanged;
 end;
end;

function tdbintegerlookuplb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_integer;
end;

{ tdbreallookuplb }

constructor tdbreallookuplb.create(aowner: tcomponent);
begin
 fvaluerange:= 1;
 inherited;
end;

procedure tdbreallookuplb.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

procedure tdbreallookuplb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptyreal;
 end
 else begin
  fvalue:= reapplyrange(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                           valuerange,valuestart);
 end;
end;

function tdbreallookuplb.lookuptext(const aindex: integer): msestring;
begin
 result:= realtytostr(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                                                   fformat);
end;

procedure tdbreallookuplb.setvaluerange(const avalue: real);
begin
 fvaluerange:= avalue;
 formatchanged;
end;

procedure tdbreallookuplb.setvaluestart(const avalue: real);
begin
 fvaluestart:= avalue;
 formatchanged;
end;

procedure tdbreallookuplb.readvaluescale(reader: treader);
begin
 valuerange:= valuescaletorange(reader);
end;

procedure tdbreallookuplb.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('valuescale',{$ifdef FPC}@{$endif}readvaluescale,nil,false);
end;

function tdbreallookuplb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdatetimelookuplb }

procedure tdbdatetimelookuplb.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
end;

procedure tdbdatetimelookuplb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptydatetime;
 end
 else begin
  fvalue:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
 end;
end;

function tdbdatetimelookuplb.lookuptext(const aindex: integer): msestring;
var
 dat1: tdatetime;
begin
 dat1:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
 if fkind = dtk_time then begin
  result:= mseformatstr.timetostring(dat1,fformat);
 end
 else begin
  result:= mseformatstr.datetimetostring(dat1,fformat);
 end;
end;

procedure tdbdatetimelookuplb.setkind(const avalue: datetimekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  formatchanged;
 end;
end;

function tdbdatetimelookuplb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdbstringlookup64lb }

procedure tdbstringlookup64lb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= '';
 end
 else begin
  fvalue:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
 end;
end;

function tdbstringlookup64lb.lookuptext(const aindex: integer): msestring;
begin
 result:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
end;

function tdbstringlookup64lb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_text;
end;

{ tdbintegerlookup64lb }

constructor tdbintegerlookup64lb.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
end;

procedure tdbintegerlookup64lb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= 0;
 end
 else begin
  fvalue:= flookupbuffer.integervaluephys(flookupvaluefieldno,aindex);
 end;
end;

function tdbintegerlookup64lb.lookuptext(const aindex: integer): msestring;
begin
 result:= intvaluetostr(flookupbuffer.integervaluephys(
                        flookupvaluefieldno,aindex),fbase,fbitcount);
end;

procedure tdbintegerlookup64lb.setbase(const avalue: numbasety);
begin
 if fbase <> avalue then begin
  fbase := avalue;
  formatchanged;
 end;
end;

procedure tdbintegerlookup64lb.setbitcount(const avalue: integer);
begin
 if fbitcount <> avalue then begin
  fbitcount := avalue;
  formatchanged;
 end;
end;

function tdbintegerlookup64lb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_integer;
end;

{ tdbreallookup64lb }

constructor tdbreallookup64lb.create(aowner: tcomponent);
begin
 fvaluerange:= 1;
 inherited;
end;

procedure tdbreallookup64lb.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

procedure tdbreallookup64lb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptyreal;
 end
 else begin
  fvalue:= reapplyrange(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                        valuerange,valuestart);
 end;
end;

function tdbreallookup64lb.lookuptext(const aindex: integer): msestring;
begin
 result:= realtytostr(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                                                   fformat);
end;

procedure tdbreallookup64lb.setvaluerange(const avalue: real);
begin
 fvaluerange:= avalue;
 formatchanged;
end;

procedure tdbreallookup64lb.setvaluestart(const avalue: real);
begin
 fvaluestart:= avalue;
 formatchanged;
end;

procedure tdbreallookup64lb.readvaluescale(reader: treader);
begin
 valuerange:= valuescaletorange(reader);
end;

procedure tdbreallookup64lb.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('valuescale',{$ifdef FPC}@{$endif}readvaluescale,nil,false);
end;


function tdbreallookup64lb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdatetimelookup64lb }

procedure tdbdatetimelookup64lb.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
end;

procedure tdbdatetimelookup64lb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptydatetime;
 end
 else begin
  fvalue:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
 end;
end;

function tdbdatetimelookup64lb.lookuptext(const aindex: integer): msestring;
var
 dat1: tdatetime;
begin
 dat1:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
 if fkind = dtk_time then begin
  result:= mseformatstr.timetostring(dat1,fformat);
 end
 else begin
  result:= mseformatstr.datetimetostring(dat1,fformat);
 end;
end;

procedure tdbdatetimelookup64lb.setkind(const avalue: datetimekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  formatchanged;
 end;
end;

function tdbdatetimelookup64lb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdbstringlookupstrlb }

function tdbstringlookupstrlb.lookuptext(const aindex: integer): msestring;
begin
 result:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
end;

procedure tdbstringlookupstrlb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= '';
 end
 else begin
  fvalue:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
 end;
end;

function tdbstringlookupstrlb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_text;
end;

{ tdbintegerlookupstrlb }

constructor tdbintegerlookupstrlb.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
end;

procedure tdbintegerlookupstrlb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= 0;
 end
 else begin
  fvalue:= flookupbuffer.integervaluephys(flookupvaluefieldno,aindex);
 end;
end;

function tdbintegerlookupstrlb.lookuptext(const aindex: integer): msestring;
begin
 result:= intvaluetostr(flookupbuffer.integervaluephys(
                        flookupvaluefieldno,aindex),fbase,fbitcount);
end;

procedure tdbintegerlookupstrlb.setbase(const avalue: numbasety);
begin
 if fbase <> avalue then begin
  fbase := avalue;
  formatchanged;
 end;
end;

procedure tdbintegerlookupstrlb.setbitcount(const avalue: integer);
begin
 if fbitcount <> avalue then begin
  fbitcount := avalue;
  formatchanged;
 end;
end;

function tdbintegerlookupstrlb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_integer;
end;

{ tdbreallookupstrlb }

constructor tdbreallookupstrlb.create(aowner: tcomponent);
begin
 fvaluerange:= 1;
 inherited;
end;

procedure tdbreallookupstrlb.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

procedure tdbreallookupstrlb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptyreal;
 end
 else begin
  fvalue:= reapplyrange(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                     valuerange,valuestart);
 end;
end;

function tdbreallookupstrlb.lookuptext(const aindex: integer): msestring;
begin
 result:= realtytostr(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                                                   fformat);
end;

procedure tdbreallookupstrlb.setvaluerange(const avalue: real);
begin
 fvaluerange:= avalue;
 formatchanged;
end;

procedure tdbreallookupstrlb.setvaluestart(const avalue: real);
begin
 fvaluestart:= avalue;
 formatchanged;
end;

procedure tdbreallookupstrlb.readvaluescale(reader: treader);
begin
 valuerange:= valuescaletorange(reader);
end;

procedure tdbreallookupstrlb.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('valuescale',{$ifdef FPC}@{$endif}readvaluescale,nil,false);
end;

function tdbreallookupstrlb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdatetimelookupstrlb }

procedure tdbdatetimelookupstrlb.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
end;

procedure tdbdatetimelookupstrlb.setlookupvalue(const aindex: integer);
begin
 if aindex < 0 then begin
  fvalue:= emptydatetime;
 end
 else begin
  fvalue:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
 end;
end;

function tdbdatetimelookupstrlb.lookuptext(const aindex: integer): msestring;
var
 dat1: tdatetime;
begin
 dat1:= flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex);
 if fkind = dtk_time then begin
  result:= mseformatstr.timetostring(dat1,fformat);
 end
 else begin
  result:= mseformatstr.datetimetostring(dat1,fformat);
 end;
end;

procedure tdbdatetimelookupstrlb.setkind(const avalue: datetimekindty);
begin
 if fkind <> avalue then begin
  fkind:= avalue;
  formatchanged;
 end;
end;

function tdbdatetimelookupstrlb.getdatalbdatakind: lbdatakindty;
begin
 result:= lbdk_float;
end;

{ tdblookupdb }

constructor tdblookupdb.create(aowner: tcomponent);
begin
 if fdatalink = nil then begin
  fdatalink:= tlookupdbdispfielddatalink.create(self,idbdispfieldlink(self));
 end;
 inherited;
end;

{ tlookupdatalink }

procedure tlookupdatalink.updatefields;
begin
 inherited;
 if active and (fkeyfieldname <> '') then begin
  fkeyfield:= datasource.dataset.fieldbyname(fkeyfieldname);
 end
 else begin
  fkeyfield:= nil;
 end;
end;

{ tlookupdbdispfielddatalink }

constructor tlookupdbdispfielddatalink.create(const aowner: tcustomdataedit;
               const intf: idbdispfieldlink);
begin
 flookupdatalink:= tlookupdatalink.create;
 inherited;
end;

destructor tlookupdbdispfielddatalink.destroy;
begin
 flookupdatalink.free;
 inherited;
end;

procedure tlookupdbdispfielddatalink.setlookupkeyfield(const avalue: string);
begin
 with flookupdatalink do begin
  if fkeyfieldname <> avalue then begin
   fkeyfieldname:=  avalue;
   updatefields;
  end;
 end;
end;

procedure tlookupdbdispfielddatalink.setlookupvaluefield(const avalue: string);
begin
 flookupdatalink.fieldname:= avalue;
end;

function tlookupdbdispfielddatalink.getlookupkeyfield: string;
begin
 result:= flookupdatalink.fkeyfieldname;
end;

function tlookupdbdispfielddatalink.getlookupvaluefield: string;
begin
 result:= flookupdatalink.fieldname;
end;

{ tdblookup32db }

procedure tdblookup32db.updatelookupvalue;
var
 int1: integer;
begin
 int1:= -1;
{
 if not fisnull and (flookupbuffer <> nil) then begin
  flookupbuffer.findphys(flookupkeyfieldno,fkey,int1);
 end;
}
 setlookupvalue(int1);
end;

function tdblookup32db.internaldatatotext(const data): msestring;

 procedure lookup(const akey: integer);
 var
  int1: integer;
 begin
  result:= '';
  {
  if flookupbuffer <> nil then begin
   if flookupbuffer.findphys(flookupkeyfieldno,akey,int1) then begin
    result:= lookuptext(int1);
   end;
  end;
  }
 end;
  
begin
 if (@data = nil) and fisnull then begin
  result:= '';
 end
 else begin
  if @data = nil then begin
   lookup(fkey);
  end
  else begin
   lookup(integer(data));
  end;
 end;
end;

procedure tdblookup32db.fieldtovalue;
begin
 fisnull:= false;
 fkey:= fdatalink.field.asinteger;
 inherited;
end;

function tdblookup32db.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getintegerbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

procedure tdblookup32db.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

end.
