unit msedblookup;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,db,msewidgetgrid,msedataedits,mseeditglob,msestrings,msedatalist,
 msedbedit,msedb,msegui,msegrids,msedbdispwidgets,mselookupbuffer,mseclasses,
 mseformatstr,msetypes,mseglob;

const
 defaultlookupoptionsedit = defaultoptionsedit + [oe_readonly];

type
 tdblookup32lb = class;
 
 tlookupdispfielddatalink = class(tdispfielddatalink)
  private
   fowner: tcustomdataedit;
   procedure setwidgetdatasource(const avalue: tdatasource);
   procedure griddatasourcechanged;
  public
   constructor create(const aowner: tcustomdataedit; 
                                    const intf: idbdispfieldlink);
  published
   property datasource read fdatasource write setwidgetdatasource;
 end;
 
 tdblookuplb = class(tcustomdataedit,idbdispfieldlink)
  private
   fdatalink: tlookupdispfielddatalink;
   fisnull: boolean;
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: integer;
   flookupvaluefieldno: integer;   
   procedure setdatalink(const avalue: tlookupdispfielddatalink);
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
  protected
   function lookuptext(const aindex: integer): msestring; virtual; abstract;
   function getdatatyp: datatypty; override;
   procedure valuetogrid(const row: integer); override;
   procedure griddatasourcechanged; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getoptionsedit: optionseditty; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure setnullvalue; override;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
  
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
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer write setlookupbuffer;
   property lookupkeyfieldno: integer read flookupkeyfieldno write flookupkeyfieldno default 0;
   property lookupvaluefieldno: integer read flookupvaluefieldno write flookupvaluefieldno default 0;

   property empty_color;
   property empty_font;
   property empty_textstyle;
   property empty_textflags;
   property empty_text;
   property empty_textcolor;
   property empty_textcolorbackground;
   property optionsedit default defaultlookupoptionsedit;
   property font;
   property textflags;
   property textflagsactive;
   property caretwidth;
   property ongettext;
   property onsettext;
   property onkeydown;
   property onkeyup;
 end;
 
 tdblookup32lb = class(tdblookuplb,ireccontrol)
  private
   fkey: integer;
  protected

   function internaldatatotext(const data): msestring; override;
   function getrowdatapo(const info: cellinfoty): pointer; override;
  //idbeditfieldlink
   procedure fieldtovalue; override;
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
  public
 end;

 tdblookup64lb = class(tdblookuplb,ireccontrol)
  private
   fkey: int64;
  protected

   function internaldatatotext(const data): msestring; override;
   function getrowdatapo(const info: cellinfoty): pointer; override;
  //idbeditfieldlink
   procedure fieldtovalue; override;
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
  public
 end;

 tdblookupstrlb = class(tdblookuplb,ireccontrol)
  private
   fkey: msestring;
  protected

   function internaldatatotext(const data): msestring; override;
   function getrowdatapo(const info: cellinfoty): pointer; override;
  //idbeditfieldlink
   procedure fieldtovalue; override;
   procedure getfieldtypes(var afieldtypes: fieldtypesty); override;
  public
 end;

 tdbstringlookuplb = class(tdblookup32lb)
  protected
   function lookuptext(const aindex: integer): msestring; override;
 end;

 tdbintegerlookuplb = class(tdblookup32lb)
  private
   fbase: numbasety;
   fbitcount: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aaowner: tcomponent); override;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbreallookuplb = class(tdblookup32lb)
  private
   fformat: msestring;
   fvaluescale: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluescale(const avalue: real);
  protected
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property valuescale: real read fvaluescale write setvaluescale;
   property format: msestring read fformat write setformat;
 end;

 tdbdatetimelookuplb = class(tdblookup32lb)
  private
   fformat: msestring;
   fkind: datetimekindty;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   function lookuptext(const aindex: integer): msestring; override;
  published
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property format: msestring read fformat write setformat;
 end;
 
 tdbstringlookup64lb = class(tdblookup64lb)
  protected
   function lookuptext(const aindex: integer): msestring; override;
 end;

 tdbintegerlookup64lb = class(tdblookup64lb)
  private
   fbase: numbasety;
   fbitcount: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aaowner: tcomponent); override;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbreallookup64lb = class(tdblookup64lb)
  private
   fformat: msestring;
   fvaluescale: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluescale(const avalue: real);
  protected
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property valuescale: real read fvaluescale write setvaluescale;
   property format: msestring read fformat write setformat;
 end;

 tdbdatetimelookup64lb = class(tdblookup64lb)
  private
   fformat: msestring;
   fkind: datetimekindty;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   function lookuptext(const aindex: integer): msestring; override;
  published
   property kind: datetimekindty read fkind write setkind default dtk_date;
   property format: msestring read fformat write setformat;
 end;

 tdbstringlookupstrlb = class(tdblookupstrlb)
  protected
   function lookuptext(const aindex: integer): msestring; override;
 end;

 tdbintegerlookupstrlb = class(tdblookupstrlb)
  private
   fbase: numbasety;
   fbitcount: integer;
   procedure setbase(const avalue: numbasety);
   procedure setbitcount(const avalue: integer);
  protected
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aaowner: tcomponent); override;
  published
   property base: numbasety read fbase write setbase default nb_dec;
   property bitcount: integer read fbitcount write setbitcount default 32;
 end;

 tdbreallookupstrlb = class(tdblookupstrlb)
  private
   fformat: msestring;
   fvaluescale: real;
   procedure setformat(const avalue: msestring);
   procedure setvaluescale(const avalue: real);
  protected
   function lookuptext(const aindex: integer): msestring; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property valuescale: real read fvaluescale write setvaluescale;
   property format: msestring read fformat write setformat;
 end;

 tdbdatetimelookupstrlb = class(tdblookupstrlb)
  private
   fformat: msestring;
   fkind: datetimekindty;
   procedure setformat(const avalue: msestring);
   procedure setkind(const avalue: datetimekindty);
  protected
   function lookuptext(const aindex: integer): msestring; override;
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

{ tdblookuplb }

constructor tdblookuplb.create(aowner: tcomponent);
begin
 fisnull:= true;
 fdatalink:= tlookupdispfielddatalink.create(self,idbdispfieldlink(self));
 inherited;
 foptionsedit:= defaultlookupoptionsedit;
end;

destructor tdblookuplb.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdblookuplb.setlookupbuffer(const avalue: tcustomlookupbuffer);
begin
 setlinkedvar(avalue,tmsecomponent(flookupbuffer));
end;

function tdblookuplb.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit + [oe_readonly];
end;

procedure tdblookuplb.setnullvalue;
begin
 inherited;
 fisnull:= true;
end;

procedure tdblookuplb.texttovalue(var accept: boolean; const quiet: boolean);
begin
 fisnull:= text = '';
end;

procedure tdblookuplb.valuetofield;
begin
 //dummy
end;

procedure tdblookuplb.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdblookuplb.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdblookuplb.setdatalink(const avalue: tlookupdispfielddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdblookuplb.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

function tdblookuplb.getdatatyp: datatypty;
begin
 result:= dl_none;
end;

procedure tdblookuplb.valuetogrid(const row: integer);
begin
 //dummy
end;

procedure tdblookuplb.fieldtovalue;
begin
 //dummy
end;

procedure tdblookuplb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 //dummy
end;

procedure tdblookuplb.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event in [oe_changed,oe_connect]) and (sender = flookupbuffer) then begin
  formatchanged;
 end;
end;

{ tdblookup32lb }

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
end;

function tdblookup32lb.getrowdatapo(const info: cellinfoty): pointer;
begin
 with info do begin
  if griddatalink <> nil then begin
   result:= tgriddatalink(griddatalink).getintegerbuffer(fdatalink.field,cell.row);
  end
  else begin
   result:= nil;
  end;
 end;
end;

procedure tdblookup32lb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

{ tdblookup64lb }


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
end;

function tdblookup64lb.getrowdatapo(const info: cellinfoty): pointer;
begin
 with info do begin
  if griddatalink <> nil then begin
   result:= tgriddatalink(griddatalink).getint64buffer(fdatalink.field,cell.row);
  end
  else begin
   result:= nil;
  end;
 end;
end;

procedure tdblookup64lb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

{ tdblookupstrlb }

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
end;

function tdblookupstrlb.getrowdatapo(const info: cellinfoty): pointer;
begin
 with info do begin
  if griddatalink <> nil then begin
   result:= tgriddatalink(griddatalink).getstringbuffer(
                                                 fdatalink.field,cell.row);
  end
  else begin
   result:= nil;
  end;
 end;
end;

procedure tdblookupstrlb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= textfields;
end;

{ tdbstringlookuplb }

function tdbstringlookuplb.lookuptext(const aindex: integer): msestring;
begin
 result:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
end;

{ tdbintegerlookuplb }

constructor tdbintegerlookuplb.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
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

{ tdbreallookuplb }

constructor tdbreallookuplb.create(aowner: tcomponent);
begin
 fvaluescale:= 1;
 inherited;
end;

procedure tdbreallookuplb.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

function tdbreallookuplb.lookuptext(const aindex: integer): msestring;
begin
 result:= realtytostr(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                                                   fformat);
end;

procedure tdbreallookuplb.setvaluescale(const avalue: real);
begin
 fvaluescale:= avalue;
 formatchanged;
end;

{ tdatetimelookuplb }

procedure tdbdatetimelookuplb.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
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

{ tdbstringlookup64lb }

function tdbstringlookup64lb.lookuptext(const aindex: integer): msestring;
begin
 result:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
end;

{ tdbintegerlookup64lb }

constructor tdbintegerlookup64lb.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
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

{ tdbreallookup64lb }

constructor tdbreallookup64lb.create(aowner: tcomponent);
begin
 fvaluescale:= 1;
 inherited;
end;

procedure tdbreallookup64lb.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

function tdbreallookup64lb.lookuptext(const aindex: integer): msestring;
begin
 result:= realtytostr(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                                                   fformat);
end;

procedure tdbreallookup64lb.setvaluescale(const avalue: real);
begin
 fvaluescale:= avalue;
 formatchanged;
end;

{ tdatetimelookup64lb }

procedure tdbdatetimelookup64lb.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
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

{ tdbstringlookupstrlb }

function tdbstringlookupstrlb.lookuptext(const aindex: integer): msestring;
begin
 result:= flookupbuffer.textvaluephys(flookupvaluefieldno,aindex);
end;

{ tdbintegerlookupstrlb }

constructor tdbintegerlookupstrlb.create(aaowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
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

{ tdbreallookupstrlb }

constructor tdbreallookupstrlb.create(aowner: tcomponent);
begin
 fvaluescale:= 1;
 inherited;
end;

procedure tdbreallookupstrlb.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

function tdbreallookupstrlb.lookuptext(const aindex: integer): msestring;
begin
 result:= realtytostr(flookupbuffer.floatvaluephys(flookupvaluefieldno,aindex),
                                                   fformat);
end;

procedure tdbreallookupstrlb.setvaluescale(const avalue: real);
begin
 fvaluescale:= avalue;
 formatchanged;
end;

{ tdatetimelookupstrlb }

procedure tdbdatetimelookupstrlb.setformat(const avalue: msestring);
begin
 format:= avalue;
 formatchanged;
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

end.
