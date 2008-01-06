unit mseifigui;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseclasses,mseifiglob,mseifi,mseact,msegui,typinfo,msestrings,
 msearrayprops,mseglob,msetypes,mseifilink,msewidgetgrid;
 
type

 
 tvaluewidgetlink = class(tvaluelink)
  private
   fwidget: twidget;
   fintf: iifiwidget;
   fvalueproperty: ppropinfo;
   fupdatelock: integer;
   procedure setwidget(const avalue: twidget);
   procedure checkwidget;
  protected
   procedure sendvalue(const aproperty: ppropinfo); overload;
   procedure setdata(const adata: pifidataty); override;
  public
   procedure sendproperties;
  published
   property widget: twidget read fwidget write setwidget;
 end; 

 tvaluewidgetlinks = class(tvaluelinks) 
  private
   function getitems(const index: integer): tvaluewidgetlink;
  protected
   function getitemclass: modulelinkpropclassty; override;  
  public
   function byname(const aname: string): tvaluewidgetlink;
   property items[const index: integer]: tvaluewidgetlink read getitems; default;   
 end;

 tformlink = class(tcustommodulelink)
  private
   function getvaluewidgets: tvaluewidgetlinks;
   procedure setvaluewidgets(const avalue: tvaluewidgetlinks);
  protected
   function widgetcommandreceived(const atag: integer; const aname: string;
                      const acommand: ifiwidgetcommandty): boolean;
   function widgetpropertiesreceived(const atag: integer; const aname: string;
                      const adata: pifibytesty): boolean;
   function processdataitem(const adata: pifirecty; var adatapo: pchar;
                  const atag: integer; const aname: string): boolean; override;
   procedure valuechanged(const sender: iifiwidget);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property valuewidgets: tvaluewidgetlinks read getvaluewidgets 
                                                      write setvaluewidgets;
   property linkname;
   property actionsrx;
   property actionstx;
   property modulesrx;
   property modulestx;
   property channel;
   property options;
 end;

 trxwidgetgrid = class;
 
 tifiwidgetgridcontroller = class(tifirxcontroller)
  public
   constructor create(const aowner: trxwidgetgrid);
 end;
 
 trxwidgetgrid = class(twidgetgrid)
  private
   fifi: tifiwidgetgridcontroller;
   procedure setifi(const avalue: tifiwidgetgridcontroller);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property ifi: tifiwidgetgridcontroller read fifi write setifi;
 end;
 
implementation
uses
 sysutils,msestream,msesysutils,msetmpmodules;
type
 tcustommodulelink1 = class(tcustommodulelink);
// tlinkdata1 = class(tlinkdata);
  
{ tvaluewidgetlink }

procedure tvaluewidgetlink.setwidget(const avalue: twidget);
var
 intf1: iifiwidget;
begin
 intf1:= nil;
 fvalueproperty:= nil;
 if (avalue <> nil) and 
    not getcorbainterface(avalue,typeinfo(iifiwidget),intf1) then begin
  raise exception.create(avalue.name+': No ifiwidget.');
 end;
 if fintf <> nil then begin
  fintf.setifiserverintf(nil);
 end;
 fintf:= intf1;
 if fintf <> nil then begin
  fintf.setifiserverintf(iifiserver(tcustommodulelink(fowner)));
 end;
 fwidget:= avalue;
 if avalue <> nil then begin
  fvalueproperty:= getpropinfo(avalue,'value');
 end;
end;

procedure tvaluewidgetlink.checkwidget;
begin
 if fwidget = nil then begin
  exception.create(tcustommodulelink(fowner).name+': No widget.');
 end;
end;

procedure tvaluewidgetlink.setdata(const adata: pifidataty);
begin
 inherited;
 with adata^ do begin
  if fvalueproperty <> nil then begin
   inc(fupdatelock);
   try
    case fvalueproperty^.proptype^.kind of
     tkInteger,tkBool,tkInt64: begin
      setordprop(fwidget,fvalueproperty,aslargeint);
     end;
     tkFloat: begin
      setfloatprop(fwidget,fvalueproperty,asfloat);
     end;
     tkWString: begin
      setwidestrprop(fwidget,fvalueproperty,asmsestring);
     end;
     tkSString,tkLString,tkAString: begin
      setstrprop(fwidget,fvalueproperty,asstring);
     end;
    end;
   finally
    dec(fupdatelock);
   end;
  end;
 end;
end;

procedure tvaluewidgetlink.sendvalue(const aproperty: ppropinfo);
begin
 if aproperty <> nil then begin
  case aproperty^.proptype^.kind of
   tkInteger,tkBool,tkInt64: begin
    sendvalue(aproperty^.name,getordprop(fwidget,aproperty));
   end;
   tkFloat: begin
    sendvalue(aproperty^.name,double(getfloatprop(fwidget,aproperty)));
   end;
   tkWString: begin
    sendvalue(aproperty^.name,getwidestrprop(fwidget,aproperty));
   end;
   tkSString,tkLString,tkAString: begin
    sendvalue(aproperty^.name,getstrprop(fwidget,aproperty));
   end;
  end;
 end;
end;

procedure tvaluewidgetlink.sendproperties;
var
 stream1: tmemorystream;
 str1: string;
 po1: pchar;
begin
 checkwidget;
 stream1:= tmemorystream.create;
 try
  stream1.writecomponent(fwidget);
  inititemheader(str1,ik_widgetproperties,0,stream1.size,po1);
  setifibytes(stream1.memory,stream1.size,pifibytesty(po1));
 finally
  stream1.free;
 end;
 tcustommodulelink1(fowner).senddata(str1);
end;

{ tvaluewidgetlinks }

function tvaluewidgetlinks.getitems(const index: integer): tvaluewidgetlink;
begin
 result:= tvaluewidgetlink(inherited getitems(index));
end;

function tvaluewidgetlinks.byname(const aname: string): tvaluewidgetlink;
begin
 result:= tvaluewidgetlink(inherited byname(aname));
end;

function tvaluewidgetlinks.getitemclass: modulelinkpropclassty;
begin
 result:= tvaluewidgetlink;
end;

{ tformlink }

constructor tformlink.create(aowner: tcomponent);
begin
 if fvalues = nil then begin
  fvalues:= tvaluewidgetlinks.create(self);
 end;
 inherited;
end;

destructor tformlink.destroy;
begin
// fdatas.free;
 inherited;
end;

function tformlink.getvaluewidgets: tvaluewidgetlinks;
begin
 result:= tvaluewidgetlinks(fvalues);
end;

procedure tformlink.setvaluewidgets(const avalue: tvaluewidgetlinks);
begin
 fvalues.assign(avalue);
end;

function tformlink.processdataitem(const adata: pifirecty; 
           var adatapo: pchar; const atag: integer; const aname: string): boolean;
var
 command1: ifiwidgetcommandty;
 str2: string;
begin
 with adata^ do begin
  case header.kind of
   ik_widgetcommand: begin
    command1:= pifiwidgetcommandty(adatapo)^;
    result:= widgetcommandreceived(atag,aname,command1);
   end;
   ik_widgetproperties: begin
    result:= widgetpropertiesreceived(atag,aname,pifibytesty(adatapo));     
   end;
   else begin
    result:= inherited processdataitem(adata,adatapo,atag,aname);
   end;
  end;
 end;
end;

function tformlink.widgetcommandreceived(const atag: integer;
             const aname: string; const acommand: ifiwidgetcommandty): boolean;
var
 wi1: tvaluewidgetlink;
begin
 wi1:= tvaluewidgetlink(fvalues.finditem(aname));
 result:= wi1 <> nil;
 if result and (wi1.fwidget <> nil) then begin
  with wi1.widget do begin
   case acommand of
    iwc_enable: begin
     enabled:= true;
    end;
    iwc_disable: begin
     enabled:= false;
    end;
    iwc_show: begin
     visible:= true;
    end;
    iwc_hide: begin
     visible:= false;
    end;
   end;
  end;
 end;    
end;

function tformlink.widgetpropertiesreceived(const atag: integer;
                     const aname: string; const adata: pifibytesty): boolean;
var
 wi1: tvaluewidgetlink;
 stream1: tmemorystream;
begin
 wi1:= tvaluewidgetlink(fvalues.finditem(aname));
 result:= wi1 <> nil;
 if result and (wi1.fwidget <> nil) then begin
  stream1:= tmemorycopystream.create(@adata^.data,adata^.length);
  try
   stream1.readcomponent(wi1.fwidget);
  finally
   stream1.free;
  end;
 end;
end;

procedure tformlink.valuechanged(const sender: iifiwidget);
var
 int1: integer;
begin
 if hasconnection then begin
  with tvaluewidgetlinks(fvalues ) do begin
   for int1:= 0 to high(fitems) do begin
    with tvaluewidgetlink(fitems[int1]) do begin
     if fupdatelock = 0 then begin
      if (fintf = sender) then begin
       sendvalue(fvalueproperty);
       break;
      end;
     end;
    end;
   end;
  end;
 end;
end;

{ tifiwidgetgridcontroller }

constructor tifiwidgetgridcontroller.create(const aowner: trxwidgetgrid);
begin
 inherited create(aowner);
end;

{ trxwidgetgrid }

constructor trxwidgetgrid.create(aowner: tcomponent);
begin
 fifi:= tifiwidgetgridcontroller.create(self);
 inherited;
end;

destructor trxwidgetgrid.destroy;
begin
 inherited;
 fifi.free;
end;

procedure trxwidgetgrid.setifi(const avalue: tifiwidgetgridcontroller);
begin
 fifi.assign(avalue);
end;

end.
