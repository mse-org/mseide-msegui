unit mseificomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 classes,mseclasses,msegui,mseifiglob,mseglob,typinfo,msestrings;
type
 tifilinkcomp = class;
 iifidatawidget = interface(iifiwidget)
                        ['{29DE5F47-87D3-408A-8BAB-1DDE945938F1}']
  procedure setifilink(const avalue: tifilinkcomp);
 end;
 
 ifiwidgeteventty = procedure(const sender: tobject;
                             const alink: iifiwidget) of object;
 ifiwidgetstateeventty = procedure(const sender: tobject;
                           const alink: iifiwidget;
                           const astate: ifiwidgetstatesty) of object;
 ifiwidgetmodalresulteventty = procedure(const sender: tobject;
                             const link: iifiwidget; 
                             const amodalresult: modalresultty) of object;

 ifivaluelinkstatety = (ivs_linking,ivs_valuesetting);
 ifivaluelinkstatesty = set of ifivaluelinkstatety;
  
 tcustomifivaluewidgetcontroller = class(tlinkedpersistent,iifiserver)
  private
   fonvaluechanged: ifiwidgeteventty;
   fonstatechanged: ifiwidgetstateeventty;
   fonmodalresult: ifiwidgetmodalresulteventty;
   fowner: tmsecomponent;
   function getwidget: twidget;
   procedure setwidget(const avalue: twidget);
  protected
   fvalueproperty: ppropinfo;
   fkind: ttypekind;
   fintf: iifiwidget;
   fcomponent: tmsecomponent;
   fstate: ifivaluelinkstatesty;
   procedure valuechanged(const sender: iifiwidget); virtual;
   procedure statechanged(const sender: iifiwidget;
                            const astate: ifiwidgetstatesty); virtual;
   procedure setvalue(var avalue; var accept: boolean); virtual;
   procedure sendmodalresult(const sender: iifiwidget; 
                             const amodalresult: modalresultty); virtual;
   procedure setcomponent(const acomponent: tmsecomponent; 
                                                 const aintf: iifiwidget);
   procedure valuetowidget; virtual; 
   procedure widgettovalue; virtual;
   procedure change;
  public
   constructor create(const aowner: tmsecomponent; const akind: ttypekind);
   function canconnect(const acomponent: tcomponent): boolean; virtual;
   property kind: ttypekind read fkind;
   property onvaluechanged: ifiwidgeteventty read fonvaluechanged 
                                                    write fonvaluechanged;
   property onstatechanged: ifiwidgetstateeventty read fonstatechanged 
                                                    write fonstatechanged;
   property onmodalresult: ifiwidgetmodalresulteventty read fonmodalresult 
                                                    write fonmodalresult;
   property widget: twidget read getwidget write setwidget;
 end;

 tifivaluewidgetcontroller = class(tcustomifivaluewidgetcontroller)
  public
   constructor create(const aowner: tmsecomponent); virtual; overload;
  published
   property onvaluechanged;
   property onstatechanged;
   property onmodalresult;
   property widget;
 end;
                             
 ifivaluewidgetcontrollerclassty = class of tifivaluewidgetcontroller;

 tstringwidgetcontroller = class(tifivaluewidgetcontroller)
  private
   fvalue: msestring;
   fonsetvalue: setstringeventty;
   procedure setvalue(const avalue: msestring);
  protected
   procedure valuetowidget; override;
   procedure widgettovalue; override;
   procedure setvalue(var avalue; var accept: boolean); override;
  public
   constructor create(const aowner: tmsecomponent); override;
  published
   property value: msestring read fvalue write setvalue;
   property onsetvalue: setstringeventty read fonsetvalue write fonsetvalue;
 end;
  
 tifilinkcomp = class(tmsecomponent)
  private
   fcontroller: tifivaluewidgetcontroller;
   procedure setcontroller(const avalue: tifivaluewidgetcontroller);
  protected
   function getcontrollerclass: ifivaluewidgetcontrollerclassty; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property controller: tifivaluewidgetcontroller read fcontroller 
                                                         write setcontroller;
  published
 end;
 
 tifistringlinkcomp = class(tifilinkcomp)
  private
   function getcontroller: tstringwidgetcontroller;
   procedure setcontroller(const avalue: tstringwidgetcontroller);
  protected
   function getcontrollerclass: ifivaluewidgetcontrollerclassty; override;
  published
   property controller: tstringwidgetcontroller read getcontroller
                                                         write setcontroller;
 end;
 
procedure setifilinkcomp(const sender: tmsecomponent; 
                      const awidgetlink: iifidatawidget;
                      const alinkcomp: tifilinkcomp; var dest: tifilinkcomp);
implementation
uses
 sysutils;
 
type
 tmsecomponent1 = class(tmsecomponent);
 
procedure setifilinkcomp(const sender: tmsecomponent;
                      const awidgetlink: iifidatawidget;
                      const alinkcomp: tifilinkcomp; var dest: tifilinkcomp);
begin
 if dest <> nil then begin
  dest.fcontroller.setcomponent(nil,nil);
 end;
 tmsecomponent1(sender).setlinkedvar(alinkcomp,dest);
 if alinkcomp <> nil then begin
  alinkcomp.fcontroller.setcomponent(sender,awidgetlink);
 end;
end;

{ tcustomifivaluewidgetcontroller}

constructor tcustomifivaluewidgetcontroller.create(const aowner: tmsecomponent; 
                               const akind: ttypekind);
begin
 fowner:= aowner;
 fkind:= akind;
 inherited create;
end;

procedure tcustomifivaluewidgetcontroller.setcomponent(const acomponent: tmsecomponent;
                                    const aintf: iifiwidget);
var
 kind1: ttypekind;
 prop1: ppropinfo;
begin
 if not (ivs_linking in fstate) then begin
  include(fstate,ivs_linking);
  try
   prop1:= nil;
   kind1:= tkunknown;
   if acomponent <> nil then begin
    prop1:= getpropinfo(acomponent,'value');
    if prop1 = nil then begin
     raise exception.create(acomponent.name+' has no value property.');
    end
    else begin
     kind1:= prop1^.proptype^.kind;
     if kind1 <> fkind then begin
      raise exception.create(acomponent.name+' wrong value data kind.');
     end;
    end;
   end;
   if fintf <> nil then begin
    fintf.setifiserverintf(nil);
   end;
   setlinkedvar(acomponent,fcomponent);
   fintf:= aintf;
   fvalueproperty:= prop1;
   if fintf <> nil then begin
    fintf.setifiserverintf(iifiserver(self));
    valuetowidget;
//    if not (csloading in fowner.componentstate) then begin
//     updatestate;
//    end;
   end;
  finally
   exclude(fstate,ivs_linking);
  end;
 end;
end;

procedure tcustomifivaluewidgetcontroller.valuechanged(const sender: iifiwidget);
begin
 if fowner.canevent(tmethod(fonvaluechanged)) then begin
  fonvaluechanged(self,sender);
 end;
 if (fvalueproperty <> nil) and not (ivs_valuesetting in fstate) and 
               not(csloading in fowner.componentstate) then begin
  include(fstate,ivs_valuesetting);
  try
   widgettovalue;
  finally
   exclude(fstate,ivs_valuesetting);
  end;
 end;
end;

procedure tcustomifivaluewidgetcontroller.statechanged(const sender: iifiwidget;
               const astate: ifiwidgetstatesty);
begin
 if fowner.canevent(tmethod(fonstatechanged)) then begin
  fonstatechanged(self,sender,astate);
 end;
end;

procedure tcustomifivaluewidgetcontroller.sendmodalresult(const sender: iifiwidget;
               const amodalresult: modalresultty);
begin
 if fowner.canevent(tmethod(fonmodalresult)) then begin
  fonmodalresult(self,sender,amodalresult);
 end;
end;

procedure tcustomifivaluewidgetcontroller.widgettovalue;
begin
 //dummy
end;

procedure tcustomifivaluewidgetcontroller.valuetowidget;
begin
 //dummy
end;

function tcustomifivaluewidgetcontroller.getwidget: twidget;
begin
 result:= twidget(fcomponent);
end;

procedure tcustomifivaluewidgetcontroller.setwidget(const avalue: twidget);
var
 intf1: iifidatawidget;
begin
 intf1:= nil;
 if (avalue <> nil) and 
       not getcorbainterface(avalue,typeinfo(iifidatawidget),intf1) then begin
  raise exception.create(avalue.name + ' is no IfI data widget.');
 end;
 setcomponent(avalue,intf1);
end;

procedure tcustomifivaluewidgetcontroller.change;
begin
 if (fvalueproperty <> nil) and not (ivs_valuesetting in fstate) then begin
  include(fstate,ivs_valuesetting);
  try
   valuetowidget;
  finally
   exclude(fstate,ivs_valuesetting);
  end;
 end;
end;

procedure tcustomifivaluewidgetcontroller.setvalue(var avalue;
               var accept: boolean);
begin
 //dummy
end;

function tcustomifivaluewidgetcontroller.canconnect(const acomponent: tcomponent): boolean;
var
 intf1: pointer;
 prop1: ppropinfo;
begin
 result:= getcorbainterface(acomponent,typeinfo(iifidatawidget),intf1);
 if result then begin
  prop1:= getpropinfo(acomponent,'value');
  result:= (prop1 <> nil) and (prop1^.proptype^.kind = fkind);
 end;
end;

{ tifilinkcomp }

constructor tifilinkcomp.create(aowner: tcomponent);
begin
 fcontroller:= getcontrollerclass.create(self);
 inherited;
end;

destructor tifilinkcomp.destroy;
begin
 inherited;
 fcontroller.free;
end;

procedure tifilinkcomp.setcontroller(const avalue: tifivaluewidgetcontroller);
begin
 fcontroller.assign(avalue);
end;

function tifilinkcomp.getcontrollerclass: ifivaluewidgetcontrollerclassty;
begin
 result:= tifivaluewidgetcontroller;
end;

{ tstringwidgetcontroller }

constructor tstringwidgetcontroller.create(const aowner: tmsecomponent);
begin
 inherited create(aowner,msestringtypekind);
end;

procedure tstringwidgetcontroller.setvalue(const avalue: msestring);
begin
 fvalue:= avalue;
 change;
end;

procedure tstringwidgetcontroller.valuetowidget;
begin
 setmsestringprop(fcomponent,fvalueproperty,fvalue);
end;

procedure tstringwidgetcontroller.widgettovalue;
begin
 value:= getmsestringprop(fcomponent,fvalueproperty);
end;

procedure tstringwidgetcontroller.setvalue(var avalue; var accept: boolean);
begin
 if fowner.canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,msestring(avalue),accept);
 end;
end;

{ tifistringlinkcomp }

function tifistringlinkcomp.getcontrollerclass: ifivaluewidgetcontrollerclassty;
begin
 result:= tstringwidgetcontroller;
end;

function tifistringlinkcomp.getcontroller: tstringwidgetcontroller;
begin
 result:= tstringwidgetcontroller(inherited controller);
end;

procedure tifistringlinkcomp.setcontroller(const avalue: tstringwidgetcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tifivaluewidgetcontroller }

constructor tifivaluewidgetcontroller.create(const aowner: tmsecomponent);
begin
 inherited create(aowner,tkunknown);
end;

end.
