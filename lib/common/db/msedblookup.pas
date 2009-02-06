unit msedblookup;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,db,msewidgetgrid,msedataedits,mseeditglob,msestrings,msedatalist,
 msedbedit,msedb,msegui,msegrids,msedbdispwidgets,mselookupbuffer,mseclasses,
 mseformatstr,msetypes;

const
 defaultlookupoptionsedit = defaultoptionsedit + [oe_readonly];

type
 tdblookuplb = class;
 
 tlookupdispfielddatalink = class(tdispfielddatalink)
  private
   fowner: tdblookuplb;
   procedure setwidgetdatasource(const avalue: tdatasource);
   procedure griddatasourcechanged;
  public
   constructor create(const aowner: tdblookuplb; const intf: idbdispfieldlink);
  published
   property datasource read fdatasource write setwidgetdatasource;
 end;
 
 tdblookuplb = class(tcustomdataedit,idbdispfieldlink,ireccontrol)
  private
   fdatalink: tlookupdispfielddatalink;
   fisnull: boolean;
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: integer;
   flookupvaluefieldno: integer;   
   fkey: integer;
   procedure setdatalink(const avalue: tlookupdispfielddatalink);
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
  protected
   function lookuptext(const aindex: integer): msestring; virtual; abstract;
   function getdatatyp: datatypty; override;
   procedure valuetogrid(const row: integer); override;

//   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
//   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
//   procedure modified; override;
   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
   function internaldatatotext(const data): msestring; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure setnullvalue; override;
   function getrowdatapo(const info: cellinfoty): pointer; override;
  //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
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

 tdbstringlookuplb = class(tdblookuplb)
  protected
   function lookuptext(const aindex: integer): msestring; override;
 end;

 tdbintegerlookuplb = class(tdblookuplb)
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

 tdbreallookuplb = class(tdblookuplb)
  private
   fformat: msestring;
   procedure setformat(const avalue: msestring);
  protected
   function lookuptext(const aindex: integer): msestring; override;
  published
   property format: msestring read fformat write setformat;
 end;

 tdbdatetimelookuplb = class(tdblookuplb)
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

constructor tlookupdispfielddatalink.create(const aowner: tdblookuplb;
                               const intf: idbdispfieldlink);
begin
 fowner:= aowner;
 inherited create(intf);
end;

procedure tlookupdispfielddatalink.setwidgetdatasource(const avalue: tdatasource);
begin
 if not ((csloading in fowner.componentstate) and datasourcefixed or 
                  (fowner.fgridintf <> nil)) then begin
  inherited datasource:= avalue;
 end;
end;

procedure tlookupdispfielddatalink.griddatasourcechanged;
var
 dso1: tdatasource;
begin
 with fowner do begin
  dso1:=  tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
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
{
procedure tdblookuplb.modified;
begin
 fdatalink.modified;
 inherited;
end;
}
procedure tdblookuplb.setlookupbuffer(const avalue: tcustomlookupbuffer);
begin
 setlinkedvar(avalue,tmsecomponent(flookupbuffer));
end;

function tdblookuplb.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit + [oe_readonly];
// result:= inherited getoptionsedit;
// fdatalink.updateoptionsedit(result);
end;

procedure tdblookuplb.setnullvalue;
begin
 inherited;
 fisnull:= true;
end;

function tdblookuplb.internaldatatotext(const data): msestring;
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

procedure tdblookuplb.texttovalue(var accept: boolean; const quiet: boolean);
begin
 fisnull:= text = '';
// inherited;
end;

procedure tdblookuplb.valuetofield;
begin
{
 if fisnull then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.field.asinteger:= value;
 end;
}
end;

procedure tdblookuplb.fieldtovalue;
begin
 fisnull:= false;
 fkey:= fdatalink.field.asinteger;
end;

function tdblookuplb.getrowdatapo(const info: cellinfoty): pointer;
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

procedure tdblookuplb.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;
{
function tdblookuplb.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;
}
function tdblookuplb.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdblookuplb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;
{
function tdblookuplb.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;
}
procedure tdblookuplb.setdatalink(const avalue: tlookupdispfielddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdblookuplb.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdblookuplb.dochange;
begin
 fdatalink.dataentered;
 inherited;
end;
}
function tdblookuplb.getdatatyp: datatypty;
begin
 result:= dl_none;
end;

procedure tdblookuplb.valuetogrid(const row: integer);
begin
 //dummy
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

end.
