unit msedbdispwidgets;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 db,classes,msesimplewidgets,msedb,msetypes,mseclasses,mseguiglob,mseglob,
 msedispwidgets,msestrings,mselookupbuffer,msegui,msemenus,mseevent;
 
type 

 idbdispfieldlink = interface(inullinterface)
  procedure fieldtovalue;
  procedure setnullvalue;
  function getwidget: twidget;
  procedure getfieldtypes(var afieldtypes: fieldtypesty); //[] = all
 end;
 
 tdispfielddatalink = class(tfielddatalink,idbeditinfo)
  private
   procedure readdatasource(reader: treader);
   procedure readdatafield(reader: treader);
  protected
   fintf: idbdispfieldlink;
   procedure activechanged; override;
   function getdataset(const aindex: integer): tdataset; virtual;
   procedure getfieldtypes(out apropertynames: stringarty; 
                                     out afieldtypes: fieldtypesarty); virtual;
  public
   constructor create(const intf: idbdispfieldlink);
   procedure fixupproperties(filer: tfiler); //read moved properties
   procedure recordchanged(afield: tfield); override;
  published
   property datasource;
   property fieldname;
 end;
 
 tdblabel = class(tcustomlabel,idbdispfieldlink,ireccontrol)
  private
   fdatalink: tdispfielddatalink;
  //idbdispfieldlink
   procedure getfieldtypes(var fieldtypes: fieldtypesty);
   procedure fieldtovalue;
   procedure setnullvalue;
  //ireccontrol
   procedure recchanged;
   procedure setdatalink(const avalue: tdispfielddatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tdispfielddatalink read fdatalink write setdatalink;
   property bounds_cx default defaultlabelwidgetwidth;
   property bounds_cy default defaultlabelwidgetheight;
   property optionswidget default defaultlabeloptionswidget;
   property font;
   property textflags;
   property options;
 end;

 tdbstringdisp = class(tcustomstringdisp,idbdispfieldlink,ireccontrol)
  private
   fdatalink: tdispfielddatalink;
   //idbdispfieldlink
   procedure getfieldtypes(var fieldtypes: fieldtypesty); virtual;
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
   //ireccontrol
   procedure recchanged;
   procedure setdatalink(const avalue: tdispfielddatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tdispfielddatalink read fdatalink write setdatalink;
 end;
  
 tdbstringdisplb = class(tdbstringdisp,idbdispfieldlink,ireccontrol,
                               ilookupbufferfieldinfo)
  private
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: lookupbufferfieldnoty;
   flookupvaluefieldno: lookupbufferfieldnoty;   
   fkeyvalue: integer;
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
     //idbdispfieldlink
   procedure getfieldtypes(var fieldtypes: fieldtypesty); override;
   procedure fieldtovalue; override;
   procedure setkeyvalue(const avalue: integer);
  protected
   procedure objectevent(const sender: tobject;
                                  const event: objecteventty); override;
  //ilookupbufferfieldinfo
   function getlbdatakind(const apropname: string): lbdatakindty;
   function getlookupbuffer: tcustomlookupbuffer;
  public
   property keyvalue: integer read fkeyvalue write setkeyvalue;
  published
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer
                                            write setlookupbuffer;
   property lookupkeyfieldno: lookupbufferfieldnoty read flookupkeyfieldno 
                                            write flookupkeyfieldno default 0;
   property lookupvaluefieldno: lookupbufferfieldnoty read flookupvaluefieldno
                                            write flookupvaluefieldno default 0;
 end;
 
 tdbintegerdisp = class(tcustomintegerdisp,idbdispfieldlink,ireccontrol)
  private
   fdatalink: tdispfielddatalink;
   fisnotnull: boolean;
     //idbdispfieldlink
   procedure getfieldtypes(var fieldtypes: fieldtypesty);
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
   //ireccontrol
   procedure recchanged;
   procedure setdatalink(const avalue: tdispfielddatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   function getvaluetext: msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tdispfielddatalink read fdatalink write setdatalink;
 end;
 
 tdbintegerdisplb = class(tdbintegerdisp,idbdispfieldlink,ireccontrol,
                            ilookupbufferfieldinfo)
  private
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: lookupbufferfieldnoty;
   flookupvaluefieldno: lookupbufferfieldnoty;   
   fkeyvalue: integer;
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
     //idbdispfieldlink
   procedure fieldtovalue; override;
   procedure setkeyvalue(const avalue: integer);
  protected
   procedure objectevent(const sender: tobject; 
                           const event: objecteventty); override;
  //ilookupbufferfieldinfo
   function getlbdatakind(const apropname: string): lbdatakindty;
   function getlookupbuffer: tcustomlookupbuffer;
  public
   property keyvalue: integer read fkeyvalue write setkeyvalue;
  published
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer 
                                          write setlookupbuffer;
   property lookupkeyfieldno: lookupbufferfieldnoty read flookupkeyfieldno 
                                          write flookupkeyfieldno default 0;
   property lookupvaluefieldno: lookupbufferfieldnoty read flookupvaluefieldno
                                          write flookupvaluefieldno default 0;
 end;
 
 tdbbooleandisp = class(tcustombooleandisp,idbdispfieldlink,ireccontrol)
  private
   fisnotnull: boolean;
   fdatalink: tdispfielddatalink;
     //idbdispfieldlink
   procedure getfieldtypes(var fieldtypes: fieldtypesty);
   procedure fieldtovalue;
   procedure setnullvalue;
   //ireccontrol
   procedure recchanged;
   procedure setdatalink(const avalue: tdispfielddatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   function getvaluetext: msestring; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tdispfielddatalink read fdatalink write setdatalink;
 end;
 
 tdbrealdisp = class(tcustomrealdisp,idbdispfieldlink,ireccontrol)
  private
   fdatalink: tdispfielddatalink;
     //idbdispfieldlink
   procedure getfieldtypes(var fieldtypes: fieldtypesty); virtual;
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
   //ireccontrol
   procedure recchanged;
   procedure setdatalink(const avalue: tdispfielddatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tdispfielddatalink read fdatalink write setdatalink;
 end;
  
 tdbrealdisplb = class(tdbrealdisp,idbdispfieldlink,ireccontrol,
                         ilookupbufferfieldinfo)
  private
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: lookupbufferfieldnoty;
   flookupvaluefieldno: lookupbufferfieldnoty;   
   fkeyvalue: integer;
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
     //idbdispfieldlink
   procedure getfieldtypes(var fieldtypes: fieldtypesty); override;
   procedure fieldtovalue; override;
   procedure setkeyvalue(const avalue: integer);
  protected
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
  //ilookupbufferfieldinfo
   function getlbdatakind(const apropname: string): lbdatakindty;
   function getlookupbuffer: tcustomlookupbuffer;
  public
   property keyvalue: integer read fkeyvalue write setkeyvalue;
  published
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer write setlookupbuffer;
   property lookupkeyfieldno: lookupbufferfieldnoty read flookupkeyfieldno write flookupkeyfieldno default 0;
   property lookupvaluefieldno: lookupbufferfieldnoty read flookupvaluefieldno write flookupvaluefieldno default 0;
 end;
 
 tdbdatetimedisp = class(tcustomdatetimedisp,idbdispfieldlink,ireccontrol)
  private
   fdatalink: tdispfielddatalink;
     //idbdispfieldlink
   procedure getfieldtypes(var fieldtypes: fieldtypesty); virtual;
   procedure fieldtovalue; virtual;
   procedure setnullvalue;
   //ireccontrol
   procedure recchanged;
   procedure setdatalink(const avalue: tdispfielddatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tdispfielddatalink read fdatalink write setdatalink;
 end;
 
 tdbdatetimedisplb = class(tdbdatetimedisp,idbdispfieldlink,ireccontrol,
                                         ilookupbufferfieldinfo)
  private
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: lookupbufferfieldnoty;
   flookupvaluefieldno: lookupbufferfieldnoty;   
   fkeyvalue: integer;
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
     //idbdispfieldlink
   procedure getfieldtypes(var fieldtypes: fieldtypesty); override;
   procedure fieldtovalue; override;
   procedure setkeyvalue(const avalue: integer);
  protected
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
  //ilookupbufferfieldinfo
   function getlbdatakind(const apropname: string): lbdatakindty;
   function getlookupbuffer: tcustomlookupbuffer;
  public
   property keyvalue: integer read fkeyvalue write setkeyvalue;
  published
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer write setlookupbuffer;
   property lookupkeyfieldno: lookupbufferfieldnoty read flookupkeyfieldno write flookupkeyfieldno default 0;
   property lookupvaluefieldno: lookupbufferfieldnoty read flookupvaluefieldno write flookupvaluefieldno default 0;
 end;
 
implementation
uses
 msereal,sysutils,typinfo;
type
 treader1 = class(treader); 
 
{ tdispfielddatalink }

constructor tdispfielddatalink.create(const intf: idbdispfieldlink);
begin
 fintf:= intf;
 inherited create;
 visualcontrol:= true;
end;

procedure tdispfielddatalink.readdatasource(reader: treader);
begin
 treader1(reader).readpropvalue(self,
          getpropinfo(typeinfo(tdispfielddatalink),'datasource'));
end;

procedure tdispfielddatalink.readdatafield(reader: treader);
begin
 fieldname:= reader.readstring;
end;

procedure tdispfielddatalink.fixupproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('datasource',{$ifdef FPC}@{$endif}readdatasource,nil,false);
 filer.defineproperty('datafield',{$ifdef FPC}@{$endif}readdatafield,nil,false);
               //move values to datalink
end;

function tdispfielddatalink.getdataset(const aindex: integer): tdataset;
begin
 result:= dataset;
end;

procedure tdispfielddatalink.getfieldtypes(out apropertynames: stringarty;
                          out afieldtypes: fieldtypesarty);
begin
 apropertynames:= nil;
 setlength(afieldtypes,1);
 afieldtypes[0]:= [];
 fintf.getfieldtypes(afieldtypes[0]);
 if afieldtypes[0] = [] then begin
  afieldtypes:= nil;
 end;
end;

procedure tdispfielddatalink.recordchanged(afield: tfield);
begin
 if (afield = nil) or (afield = field) then begin
  if active and (field <> nil) and not (dataset.eof and dataset.bof) then begin
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

procedure tdispfielddatalink.activechanged;
begin
 try
  inherited;
 except
  on e: exception do begin
   e.message:= fintf.getwidget.name + ': ' + e.message;
   raise
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

procedure tdblabel.getfieldtypes(var fieldtypes: fieldtypesty);
begin
 //all types
end;

procedure tdblabel.fieldtovalue;
begin
 caption:= datalink.field.displaytext;
end;

procedure tdblabel.setnullvalue;
begin
 caption:= '';
end;

procedure tdblabel.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

procedure tdblabel.setdatalink(const avalue: tdispfielddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdblabel.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
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

procedure tdbstringdisp.getfieldtypes(var fieldtypes: fieldtypesty);
begin
 fieldtypes:= textfields;
end;

procedure tdbstringdisp.fieldtovalue;
begin
 value:= datalink.asmsestring;
end;

procedure tdbstringdisp.setnullvalue;
begin
 value:= '';
end;

procedure tdbstringdisp.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

procedure tdbstringdisp.setdatalink(const avalue: tdispfielddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbstringdisp.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

{ tdbstringdisplb }

procedure tdbstringdisplb.getfieldtypes(var fieldtypes: fieldtypesty);
begin
 fieldtypes:= integerfields;
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
 if (event in [oe_changed,oe_connect]) and (sender = flookupbuffer) then begin
  setkeyvalue(fkeyvalue);
 end;
end;

function tdbstringdisplb.getlbdatakind(const apropname: string): lbdatakindty;
begin
 if apropname = 'lookupkeyfieldno' then begin
  result:= lbdk_integer;
 end
 else begin
  result:= lbdk_text;
 end;
end;

function tdbstringdisplb.getlookupbuffer: tcustomlookupbuffer;
begin
 result:= flookupbuffer;
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

procedure tdbintegerdisp.getfieldtypes(var fieldtypes: fieldtypesty);
begin
 fieldtypes:= integerfields;
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

procedure tdbintegerdisp.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

procedure tdbintegerdisp.setdatalink(const avalue: tdispfielddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbintegerdisp.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
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
 if (event in [oe_changed,oe_connect]) and (sender = flookupbuffer) then begin
  setkeyvalue(fkeyvalue);
 end;
end;

function tdbintegerdisplb.getlbdatakind(const apropname: string): lbdatakindty;
begin
 if apropname = 'lookupkeyfieldno' then begin
  result:= lbdk_integer;
 end
 else begin
  result:= lbdk_integer;
 end;
end;

function tdbintegerdisplb.getlookupbuffer: tcustomlookupbuffer;
begin
 result:= flookupbuffer;
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

procedure tdbbooleandisp.getfieldtypes(var fieldtypes: fieldtypesty);
begin
 fieldtypes:= booleanfields;
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

procedure tdbbooleandisp.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

procedure tdbbooleandisp.setdatalink(const avalue: tdispfielddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbbooleandisp.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
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

procedure tdbrealdisp.getfieldtypes(var fieldtypes: fieldtypesty);
begin
 fieldtypes:= realfields;
end;

procedure tdbrealdisp.fieldtovalue;
begin
 value:= datalink.field.asfloat;
end;

procedure tdbrealdisp.setnullvalue;
begin
 value:= emptyreal;
end;

procedure tdbrealdisp.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

procedure tdbrealdisp.setdatalink(const avalue: tdispfielddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbrealdisp.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

{ tdbrealdisplb }

procedure tdbrealdisplb.getfieldtypes(var fieldtypes: fieldtypesty);
begin
 fieldtypes:= integerfields;
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
 if (event in [oe_changed,oe_connect]) and (sender = flookupbuffer) then begin
  setkeyvalue(fkeyvalue);
 end;
end;

function tdbrealdisplb.getlbdatakind(const apropname: string): lbdatakindty;
begin
 if apropname = 'lookupkeyfieldno' then begin
  result:= lbdk_integer;
 end
 else begin
  result:= lbdk_float;
 end;
end;

function tdbrealdisplb.getlookupbuffer: tcustomlookupbuffer;
begin
 result:= flookupbuffer;
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

procedure tdbdatetimedisp.getfieldtypes(var fieldtypes: fieldtypesty);
begin
 fieldtypes:= datetimefields;
end;

procedure tdbdatetimedisp.fieldtovalue;
var
 da1: tdatetime;
begin
 da1:= datalink.field.asdatetime;
 value:= da1;
end;

procedure tdbdatetimedisp.setnullvalue;
begin
 value:= emptydatetime;
end;

procedure tdbdatetimedisp.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

procedure tdbdatetimedisp.setdatalink(const avalue: tdispfielddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbdatetimedisp.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

{ tdbdatetimedisplb }

procedure tdbdatetimedisplb.getfieldtypes(var fieldtypes: fieldtypesty);
begin
 fieldtypes:= integerfields;
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
 if (event in [oe_changed,oe_connect]) and (sender = flookupbuffer) then begin
  setkeyvalue(fkeyvalue);
 end;
end;

function tdbdatetimedisplb.getlbdatakind(const apropname: string): lbdatakindty;
begin
 if apropname = 'lookupkeyfieldno' then begin
  result:= lbdk_integer;
 end
 else begin
  result:= lbdk_float;
 end;
end;

function tdbdatetimedisplb.getlookupbuffer: tcustomlookupbuffer;
begin
 result:= flookupbuffer;
end;

end.
