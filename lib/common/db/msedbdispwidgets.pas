unit msedbdispwidgets;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 db,classes,msesimplewidgets,msedb,msetypes,mseclasses,mseguiglob,
 msedispwidgets,msestrings,mselookupbuffer;
 
type 

 idbdispfieldlink = interface(inullinterface)
  procedure fieldtovalue;
  procedure setnullvalue;
 end;
 
 tdispfielddatalink = class(tfielddatalink)
  private
   fintf: idbdispfieldlink;
  protected
   procedure recordchanged(afield: tfield); override;
  public
   constructor create(const intf: idbdispfieldlink);
 end;
 
 tdblabel = class(tcustomlabel,idbeditinfo,idbdispfieldlink)
  private
   fdatalink: tdispfielddatalink;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
     //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
     //idbdispfieldlink
   procedure fieldtovalue;
   procedure setnullvalue;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property datalink: tdispfielddatalink read fdatalink;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
   property bounds_cx default defaultlabelwidgetwidth;
   property bounds_cy default defaultlabelwidgetheight;
   property optionswidget default defaultlabeloptionswidget;
 end;

 tdbstringdisp = class(tcustomstringdisp,idbeditinfo,idbdispfieldlink)
  private
   fdatalink: tdispfielddatalink;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
     //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty); virtual;
     //idbdispfieldlink
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property datalink: tdispfielddatalink read fdatalink;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
 end;
  
 tdbstringdisplb = class(tdbstringdisp,idbeditinfo,idbdispfieldlink)
  private
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: integer;
   flookupvaluefieldno: integer;   
   fkeyvalue: integer;
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
     //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty); override;
     //idbdispfieldlink
   procedure fieldtovalue; override;
   procedure setkeyvalue(const avalue: integer);
  protected
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
  public
   property keyvalue: integer read fkeyvalue write setkeyvalue;
  published
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer write setlookupbuffer;
   property lookupkeyfieldno: integer read flookupkeyfieldno write flookupkeyfieldno default 0;
   property lookupvaluefieldno: integer read flookupvaluefieldno write flookupvaluefieldno default 0;
 end;
 
 tdbintegerdisp = class(tcustomintegerdisp,idbeditinfo,idbdispfieldlink)
  private
   fdatalink: tdispfielddatalink;
   fisnotnull: boolean;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
     //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
     //idbdispfieldlink
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
  protected
   function getvaluetext: msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property datalink: tdispfielddatalink read fdatalink;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
 end;
 
 tdbintegerdisplb = class(tdbintegerdisp,idbeditinfo,idbdispfieldlink)
  private
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: integer;
   flookupvaluefieldno: integer;   
   fkeyvalue: integer;
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
     //idbdispfieldlink
   procedure fieldtovalue; override;
   procedure setkeyvalue(const avalue: integer);
  protected
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
  public
   property keyvalue: integer read fkeyvalue write setkeyvalue;
  published
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer write setlookupbuffer;
   property lookupkeyfieldno: integer read flookupkeyfieldno write flookupkeyfieldno default 0;
   property lookupvaluefieldno: integer read flookupvaluefieldno write flookupvaluefieldno default 0;
 end;
 
 tdbbooleandisp = class(tcustombooleandisp,idbeditinfo,idbdispfieldlink)
  private
   fisnotnull: boolean;
   fdatalink: tdispfielddatalink;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
     //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
     //idbdispfieldlink
   procedure fieldtovalue;
   procedure setnullvalue;
  protected
   function getvaluetext: msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property datalink: tdispfielddatalink read fdatalink;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
 end;
 
 tdbrealdisp = class(tcustomrealdisp,idbeditinfo,idbdispfieldlink)
  private
   fdatalink: tdispfielddatalink;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
     //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty); virtual;
     //idbdispfieldlink
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property datalink: tdispfielddatalink read fdatalink;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
 end;
  
 tdbrealdisplb = class(tdbrealdisp,idbeditinfo,idbdispfieldlink)
  private
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: integer;
   flookupvaluefieldno: integer;   
   fkeyvalue: integer;
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
     //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty); override;
     //idbdispfieldlink
   procedure fieldtovalue; override;
   procedure setkeyvalue(const avalue: integer);
  protected
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
  public
   property keyvalue: integer read fkeyvalue write setkeyvalue;
  published
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer write setlookupbuffer;
   property lookupkeyfieldno: integer read flookupkeyfieldno write flookupkeyfieldno default 0;
   property lookupvaluefieldno: integer read flookupvaluefieldno write flookupvaluefieldno default 0;
 end;
 
 tdbdatetimedisp = class(tcustomdatetimedisp,idbeditinfo,idbdispfieldlink)
  private
   fdatalink: tdispfielddatalink;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
     //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty); virtual;
     //idbdispfieldlink
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property datalink: tdispfielddatalink read fdatalink;
  published
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource write setdatasource;
 end;
 
 tdbdatetimedisplb = class(tdbdatetimedisp,idbeditinfo,idbdispfieldlink)
  private
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: integer;
   flookupvaluefieldno: integer;   
   fkeyvalue: integer;
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
     //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty); override;
     //idbdispfieldlink
   procedure fieldtovalue; override;
   procedure setkeyvalue(const avalue: integer);
  protected
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
  public
   property keyvalue: integer read fkeyvalue write setkeyvalue;
  published
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer write setlookupbuffer;
   property lookupkeyfieldno: integer read flookupkeyfieldno write flookupkeyfieldno default 0;
   property lookupvaluefieldno: integer read flookupvaluefieldno write flookupvaluefieldno default 0;
 end;
 
implementation
uses
 msereal;
 
{ tdispfielddatalink }

constructor tdispfielddatalink.create(const intf: idbdispfieldlink);
begin
 fintf:= intf;
 inherited create;
 visualcontrol:= true;
end;

procedure tdispfielddatalink.recordchanged(afield: tfield);
begin
 if (afield = nil) or (afield = field) then begin
  if field <> nil then begin
   if field.isnull then begin
    fintf.setnullvalue;
   end
   else begin 
    fintf.fieldtovalue;
   end;
  end
  else begin
   fintf.setnullvalue;
  end;
 end;
end;

{ tdblabel }

constructor tdblabel.create(aowner: tcomponent);
begin
 fdatalink:= tdispfielddatalink.create(idbdispfieldlink(self));
 inherited;
end;

destructor tdblabel.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdblabel.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdblabel.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tdblabel.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tdblabel.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tdblabel.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 fieldtypes:= nil;
end;

procedure tdblabel.fieldtovalue;
begin
 caption:= datalink.field.displaytext;
end;

procedure tdblabel.setnullvalue;
begin
 caption:= '';
end;

{ tdbstringdisp }

constructor tdbstringdisp.create(aowner: tcomponent);
begin
 fdatalink:= tdispfielddatalink.create(idbdispfieldlink(self));
 inherited;
end;

destructor tdbstringdisp.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbstringdisp.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdbstringdisp.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tdbstringdisp.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tdbstringdisp.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tdbstringdisp.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= textfields;
end;

procedure tdbstringdisp.fieldtovalue;
begin
 value:= datalink.field.asstring;
end;

procedure tdbstringdisp.setnullvalue;
begin
 value:= '';
end;

{ tdbstringdisplb }

procedure tdbstringdisplb.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= integerfields;
end;

procedure tdbstringdisplb.fieldtovalue;
begin
 keyvalue:= datalink.field.asinteger;
end;

procedure tdbstringdisplb.setlookupbuffer(const avalue: tcustomlookupbuffer);
begin
 setlinkedvar(avalue,tmsecomponent(flookupbuffer));
end;

procedure tdbstringdisplb.setkeyvalue(const avalue: integer);
var
 int1: integer;
begin
 fkeyvalue:= avalue;
 if flookupbuffer <> nil then begin
  if flookupbuffer.findphys(flookupkeyfieldno,fkeyvalue,int1) then begin
   value:= flookupbuffer.textvaluephys(flookupvaluefieldno,int1);
  end
  else begin
   setnullvalue;
  end;
 end
 else begin
  setnullvalue;
 end;
end;

procedure tdbstringdisplb.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event = oe_changed) and (sender = flookupbuffer) then begin
  fdatalink.recordchanged(nil);
 end;
end;

{ tdbintegerdisp }

constructor tdbintegerdisp.create(aowner: tcomponent);
begin
 fdatalink:= tdispfielddatalink.create(idbdispfieldlink(self));
 inherited;
end;

destructor tdbintegerdisp.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbintegerdisp.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdbintegerdisp.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tdbintegerdisp.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tdbintegerdisp.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tdbintegerdisp.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= integerfields;
end;

procedure tdbintegerdisp.fieldtovalue;
begin
 fisnotnull:= true;
 value:= datalink.field.asinteger;
end;

procedure tdbintegerdisp.setnullvalue;
begin
 fisnotnull:= false;
 value:= 0;
end;

function tdbintegerdisp.getvaluetext: msestring;
begin
 if fisnotnull then begin
  result:= inherited getvaluetext;
 end
 else begin
  result:= '';
 end;
end;

{ tdbintegerdisplb }

procedure tdbintegerdisplb.fieldtovalue;
begin
 keyvalue:= datalink.field.asinteger;
end;

procedure tdbintegerdisplb.setlookupbuffer(const avalue: tcustomlookupbuffer);
begin
 setlinkedvar(avalue,tmsecomponent(flookupbuffer));
end;

procedure tdbintegerdisplb.setkeyvalue(const avalue: integer);
var
 int1: integer;
begin
 fkeyvalue:= avalue;
 if flookupbuffer <> nil then begin
  if flookupbuffer.findphys(flookupkeyfieldno,fkeyvalue,int1) then begin
   fisnotnull:= true;
   value:= flookupbuffer.integervaluephys(flookupvaluefieldno,int1);
  end
  else begin
   setnullvalue;
  end;
 end
 else begin
  setnullvalue;
 end;
end;

procedure tdbintegerdisplb.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event = oe_changed) and (sender = flookupbuffer) then begin
  fdatalink.recordchanged(nil);
 end;
end;

{ tdbbooleandisp }

constructor tdbbooleandisp.create(aowner: tcomponent);
begin
 fdatalink:= tdispfielddatalink.create(idbdispfieldlink(self));
 inherited;
end;

destructor tdbbooleandisp.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbbooleandisp.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdbbooleandisp.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tdbbooleandisp.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tdbbooleandisp.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tdbbooleandisp.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= booleanfields;
end;

procedure tdbbooleandisp.fieldtovalue;
begin
 fisnotnull:= true;
 value:= datalink.field.asboolean;
end;

procedure tdbbooleandisp.setnullvalue;
begin
 fisnotnull:= false;
 value:= false;
end;

function tdbbooleandisp.getvaluetext: msestring;
begin
 if fisnotnull then begin
  result:= inherited getvaluetext;
 end
 else begin
  result:= '';
 end;
end;

{ tdbrealdisp }

constructor tdbrealdisp.create(aowner: tcomponent);
begin
 fdatalink:= tdispfielddatalink.create(idbdispfieldlink(self));
 inherited;
end;

destructor tdbrealdisp.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbrealdisp.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdbrealdisp.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tdbrealdisp.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tdbrealdisp.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tdbrealdisp.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= realfields;
end;

procedure tdbrealdisp.fieldtovalue;
begin
 value:= datalink.field.asfloat;
end;

procedure tdbrealdisp.setnullvalue;
begin
 value:= emptyreal;
end;

{ tdbrealdisplb }

procedure tdbrealdisplb.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= integerfields;
end;

procedure tdbrealdisplb.fieldtovalue;
begin
 keyvalue:= datalink.field.asinteger;
end;

procedure tdbrealdisplb.setlookupbuffer(const avalue: tcustomlookupbuffer);
begin
 setlinkedvar(avalue,tmsecomponent(flookupbuffer));
end;

procedure tdbrealdisplb.setkeyvalue(const avalue: integer);
var
 int1: integer;
begin
 fkeyvalue:= avalue;
 if flookupbuffer <> nil then begin
  if flookupbuffer.findphys(flookupkeyfieldno,fkeyvalue,int1) then begin
   value:= flookupbuffer.floatvaluephys(flookupvaluefieldno,int1);
  end
  else begin
   setnullvalue;
  end;
 end
 else begin
  setnullvalue;
 end;
end;

procedure tdbrealdisplb.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event = oe_changed) and (sender = flookupbuffer) then begin
  fdatalink.recordchanged(nil);
 end;
end;

{ tdbdatetimedisp }

constructor tdbdatetimedisp.create(aowner: tcomponent);
begin
 fdatalink:= tdispfielddatalink.create(idbdispfieldlink(self));
 inherited;
end;

destructor tdbdatetimedisp.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbdatetimedisp.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdbdatetimedisp.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function tdbdatetimedisp.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tdbdatetimedisp.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tdbdatetimedisp.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= datetimefields;
end;

procedure tdbdatetimedisp.fieldtovalue;
var
 da1: tdatetime;
begin
 da1:= datalink.field.asdatetime;
// if da1 = 0 then begin
//  da1:= nulltime;
// end;
 value:= da1;
end;

procedure tdbdatetimedisp.setnullvalue;
begin
 value:= emptydatetime;
end;

{ tdbdatetimedisplb }

procedure tdbdatetimedisplb.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= integerfields;
end;

procedure tdbdatetimedisplb.fieldtovalue;
begin
 keyvalue:= datalink.field.asinteger;
end;

procedure tdbdatetimedisplb.setlookupbuffer(const avalue: tcustomlookupbuffer);
begin
 setlinkedvar(avalue,tmsecomponent(flookupbuffer));
end;

procedure tdbdatetimedisplb.setkeyvalue(const avalue: integer);
var
 int1: integer;
begin
 fkeyvalue:= avalue;
 if flookupbuffer <> nil then begin
  if flookupbuffer.findphys(flookupkeyfieldno,fkeyvalue,int1) then begin
   value:= flookupbuffer.floatvaluephys(flookupvaluefieldno,int1);
  end
  else begin
   setnullvalue;
  end;
 end
 else begin
  setnullvalue;
 end;
end;

procedure tdbdatetimedisplb.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event = oe_changed) and (sender = flookupbuffer) then begin
  fdatalink.recordchanged(nil);
 end;
end;

end.
