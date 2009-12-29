{ MSEgui Copyright (c) 2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

   experimental user - business logic connection components.
   Warning: works with RTTI and is therefore slow.
}
unit mseificomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 classes,mseclasses,msegui,mseifiglob,mseglob,typinfo,msestrings;
type
 tifilinkcomp = class;
 
 iifilink = interface(iificlient)
                        ['{29DE5F47-87D3-408A-8BAB-1DDE945938F1}']
  procedure setifilink(const avalue: tifilinkcomp);
  function getobjectlinker: tobjectlinker;
 end;
 
 ificlienteventty = procedure(const sender: tobject;
                             const alink: iificlient) of object;
 ificlientstateeventty = procedure(const sender: tobject;
                           const alink: iificlient;
                           const astate: ifiwidgetstatesty;
                           const achangedstate: ifiwidgetstatesty) of object;
 ificlientmodalresulteventty = procedure(const sender: tobject;
                             const link: iificlient; 
                             const amodalresult: modalresultty) of object;

 ifivaluelinkstatety = (ivs_linking,ivs_valuesetting);
 ifivaluelinkstatesty = set of ifivaluelinkstatety;

 tcustomificlientcontroller = class(tlinkedpersistent,iifiserver)
  private
   fonclientvaluechanged: ificlienteventty;
   fonclientstatechanged: ificlientstateeventty;
   fonclientmodalresult: ificlientmodalresulteventty;
   fowner: tmsecomponent;
//   function getwidget: twidget;
//   procedure setwidget(const avalue: twidget);
//   function getclientinstance: tobject;
  protected
//   fvalueproperty: ppropinfo;
   fkind: ttypekind;
//   fintf: iificlient;
   fstate: ifivaluelinkstatesty;
   fwidgetstate: ifiwidgetstatesty;
   fwidgetstatebefore: ifiwidgetstatesty;

   procedure finalizelink(const alink: pointer);
   procedure finalizelinks;
   procedure loaded; virtual;
   function errorname(const ainstance: tobject): string;
   procedure valuechanged(const sender: iificlient); virtual;
   procedure statechanged(const sender: iificlient;
                            const astate: ifiwidgetstatesty); virtual;
   procedure setvalue(var avalue; var accept: boolean); virtual;
   procedure sendmodalresult(const sender: iificlient; 
                             const amodalresult: modalresultty); virtual;
//   procedure setcomponent(const aintf: iificlient);
   function checkcomponent(const aintf: iificlient): pointer;
                     //returns interface info
   procedure valuestoclient(const alink: pointer); virtual; 
   procedure clienttovalues(const alink: pointer); virtual; 
//   procedure widgettovalue; virtual;
   procedure change(const alink: iificlient = nil);
   
   function setmsestringval(const alink: iificlient; const aname: string;
                                 const avalue: msestring): boolean;
                                    //true if found
   function getmsestringval(const alink: iificlient; const aname: string;
                                 var avalue: msestring): boolean;
                                    //true if found
  public
   constructor create(const aowner: tmsecomponent; const akind: ttypekind);
   function canconnect(const acomponent: tcomponent): boolean; virtual;
//   property kind: ttypekind read fkind;
   property onclientvaluechanged: ificlienteventty read fonclientvaluechanged 
                                                    write fonclientvaluechanged;
   property onclientstatechanged: ificlientstateeventty 
                     read fonclientstatechanged write fonclientstatechanged;
   property onclientmodalresult: ificlientmodalresulteventty 
                     read fonclientmodalresult write fonclientmodalresult;
//   property clientinstance: tobject read getclientinstance;
//   property widget: twidget read getwidget write setwidget;
 end;

 tificlientcontroller = class(tcustomificlientcontroller)
  public
   constructor create(const aowner: tmsecomponent); virtual; overload;
  published
   property onclientvaluechanged;
   property onclientstatechanged;
   property onclientmodalresult;
 end;
                             
 ificlientcontrollerclassty = class of tificlientcontroller;

 tstringclientcontroller = class(tificlientcontroller)
  private
   fvalue: msestring;
   fonclientsetvalue: setstringeventty;
   procedure setvalue(const avalue: msestring);
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
//   procedure widgettovalue; override;
   procedure setvalue(var avalue; var accept: boolean); override;
  public
   constructor create(const aowner: tmsecomponent); override;
  published
   property value: msestring read fvalue write setvalue;
   property onclientsetvalue: setstringeventty 
                read fonclientsetvalue write fonclientsetvalue;
 end;
  
 tifilinkcomp = class(tmsecomponent)
  private
   fcontroller: tificlientcontroller;
   procedure setcontroller(const avalue: tificlientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; virtual;
   procedure loaded; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property controller: tificlientcontroller read fcontroller 
                                                         write setcontroller;
  published
 end;
 
 tifistringlinkcomp = class(tifilinkcomp)
  private
   function getcontroller: tstringclientcontroller;
   procedure setcontroller(const avalue: tstringclientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; override;
  published
   property controller: tstringclientcontroller read getcontroller
                                                         write setcontroller;
 end;
 
procedure setifilinkcomp(const alink: iifilink;
                      const alinkcomp: tifilinkcomp; var dest: tifilinkcomp);
implementation
uses
 sysutils;
 
type
 tmsecomponent1 = class(tmsecomponent);
 
procedure setifilinkcomp(const alink: iifilink;
                      const alinkcomp: tifilinkcomp; var dest: tifilinkcomp);
var
 po1: pointer;
begin
// if dest <> nil then begin
//  dest.fcontroller.setcomponent(nil);
// end;
 alink.setifiserverintf(nil);
 po1:= nil;
 if alinkcomp <> nil then begin
  po1:= alinkcomp.fcontroller.checkcomponent(alink);
 end; 
 alink.getobjectlinker.setlinkedvar(alink,alinkcomp,tmsecomponent(dest),po1);
 if dest <> nil then begin
  alink.setifiserverintf(iifiserver(dest.fcontroller));
  dest.fcontroller.change(alink);
 end;
end;

{ tcustomificlientcontroller}

constructor tcustomificlientcontroller.create(const aowner: tmsecomponent; 
                               const akind: ttypekind);
begin
 fowner:= aowner;
 fkind:= akind;
 inherited create;
end;

function tcustomificlientcontroller.checkcomponent(
          const aintf: iificlient): pointer;
begin
 result:= self;
end;

{
procedure tcustomifivaluewidgetcontroller.setcomponent(const aintf: iificlient);
var
 kind1: ttypekind;
 prop1: ppropinfo;
 inst1: tobject;
begin
 if not (ivs_linking in fstate) then begin
  include(fstate,ivs_linking);
  try
   prop1:= nil;
   kind1:= tkunknown;
   if aintf <> nil then begin
    inst1:= aintf.getinstance;
    prop1:= getpropinfo(inst1,'value');
    if prop1 = nil then begin
     raise exception.create(errorname(inst1)+' has no value property.');
    end
    else begin
     kind1:= prop1^.proptype^.kind;
     if kind1 <> fkind then begin
      raise exception.create(errorname(inst1)+' wrong value data kind.');
     end;
    end;
   end;
   if fintf <> nil then begin
    fintf.setifiserverintf(nil);
   end;
   setlinkedvar(aintf,iobjectlink(fintf));
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
}
procedure tcustomificlientcontroller.valuechanged(const sender: iificlient);
begin
 if {(fvalueproperty <> nil) and} not (ivs_valuesetting in fstate) and 
               not(csloading in fowner.componentstate) then begin
  include(fstate,ivs_valuesetting);
  try
   clienttovalues(sender);
  finally
   exclude(fstate,ivs_valuesetting);
  end;
 end;
 if fowner.canevent(tmethod(fonclientvaluechanged)) then begin
  fonclientvaluechanged(self,sender);
 end;
end;

procedure tcustomificlientcontroller.statechanged(const sender: iificlient;
               const astate: ifiwidgetstatesty);
begin
 fwidgetstate:= astate;
 if fowner.canevent(tmethod(fonclientstatechanged)) then begin
  fonclientstatechanged(self,sender,astate,ifiwidgetstatesty(longword(astate) xor
                                             longword(fwidgetstatebefore)));
  fwidgetstatebefore:= astate;
 end;
end;

procedure tcustomificlientcontroller.sendmodalresult(const sender: iificlient;
               const amodalresult: modalresultty);
begin
 if fowner.canevent(tmethod(fonclientmodalresult)) then begin
  fonclientmodalresult(self,sender,amodalresult);
 end;
end;
{
procedure tcustomifivaluewidgetcontroller.widgettovalue;
begin
 //dummy
end;
}
procedure tcustomificlientcontroller.valuestoclient(const alink: pointer);
begin
 //dummy
end;

procedure tcustomificlientcontroller.clienttovalues(const alink: pointer);
begin
 //dummy
end;

{
function tcustomifivaluewidgetcontroller.getclientinstance: tobject;
begin
 result:= nil;
 if fintf <> nil then begin
  result:= fintf.getinstance;
 end;
end;
}
{
function tcustomifivaluewidgetcontroller.getwidget: twidget;
begin
 result:= twidget(fcomponent);
end;

procedure tcustomifivaluewidgetcontroller.setwidget(const avalue: twidget);
var
 intf1: iifilink;
begin
 intf1:= nil;
 if (avalue <> nil) and 
       not getcorbainterface(avalue,typeinfo(iifilink),intf1) then begin
  raise exception.create(avalue.name + ' is no IfI data widget.');
 end;
 setcomponent(avalue,intf1);
end;
}
procedure tcustomificlientcontroller.change(const alink: iificlient);
begin
 if {(fvalueproperty <> nil) and} not (ivs_valuesetting in fstate) and 
            not (csloading in fowner.componentstate) then begin
  include(fstate,ivs_valuesetting);
  try
   if alink <> nil then begin
    valuestoclient(alink);
   end
   else begin
    tmsecomponent1(fowner).getobjectlinker.forall(@valuestoclient,self);
   end;
//   valuetowidget;
  finally
   exclude(fstate,ivs_valuesetting);
  end;
 end;
end;

procedure tcustomificlientcontroller.finalizelink(const alink: pointer);
begin
 iificlient(alink).setifiserverintf(nil);
end;

procedure tcustomificlientcontroller.finalizelinks;
begin
 if tmsecomponent1(fowner).fobjectlinker <> nil then begin
  tmsecomponent1(fowner).fobjectlinker.forall(@finalizelink,self);
 end;
end;

procedure tcustomificlientcontroller.setvalue(var avalue;
               var accept: boolean);
begin
 //dummy
end;

function tcustomificlientcontroller.canconnect(const acomponent: tcomponent): boolean;
var
 intf1: pointer;
 prop1: ppropinfo;
begin
 result:= getcorbainterface(acomponent,typeinfo(iifilink),intf1);
 if result then begin
  prop1:= getpropinfo(acomponent,'value');
  result:= (prop1 <> nil) and (prop1^.proptype^.kind = fkind);
 end;
end;

function tcustomificlientcontroller.errorname(const ainstance: tobject): string;
begin
 if ainstance = nil then begin
  result:= 'NIL';
 end
 else begin
  if ainstance is tcomponent then begin
   result:= tcomponent(ainstance).name;
  end
  else begin
   result:= ainstance.classname;
  end;
 end;
end;

function tcustomificlientcontroller.setmsestringval(const alink: iificlient;
               const aname: string; const avalue: msestring): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = msestringtypekind);
 if result then begin
  setmsestringprop(inst,prop,avalue);
 end; 
end;

function tcustomificlientcontroller.getmsestringval(
                     const alink: iificlient; const aname: string;
                     var avalue: msestring): boolean;
                                    //true if found
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = msestringtypekind);
 if result then begin
  avalue:= getmsestringprop(inst,prop);
 end; 
end;

procedure tcustomificlientcontroller.loaded;
begin
 change;
end;

{ tifilinkcomp }

constructor tifilinkcomp.create(aowner: tcomponent);
begin
 fcontroller:= getcontrollerclass.create(self);
 inherited;
end;

destructor tifilinkcomp.destroy;
begin
 fcontroller.finalizelinks;
 inherited;
 fcontroller.free;
end;

procedure tifilinkcomp.setcontroller(const avalue: tificlientcontroller);
begin
 fcontroller.assign(avalue);
end;

function tifilinkcomp.getcontrollerclass: ificlientcontrollerclassty;
begin
 result:= tificlientcontroller;
end;

procedure tifilinkcomp.loaded;
begin
 inherited;
 fcontroller.loaded;
end;

{ tstringclientcontroller }

constructor tstringclientcontroller.create(const aowner: tmsecomponent);
begin
 inherited create(aowner,msestringtypekind);
end;

procedure tstringclientcontroller.setvalue(const avalue: msestring);
begin
 fvalue:= avalue;
 change;
end;

procedure tstringclientcontroller.valuestoclient(const alink: pointer);
begin
 inherited;
 setmsestringval(iificlient(alink),'value',fvalue);
end;

procedure tstringclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getmsestringval(iificlient(alink),'value',fvalue);
end;

{
procedure tstringwidgetcontroller.widgettovalue;
begin
 value:= getmsestringprop(clientinstance,fvalueproperty);
end;
}
procedure tstringclientcontroller.setvalue(var avalue; var accept: boolean);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,msestring(avalue),accept);
 end;
end;

{ tifistringlinkcomp }

function tifistringlinkcomp.getcontrollerclass: ificlientcontrollerclassty;
begin
 result:= tstringclientcontroller;
end;

function tifistringlinkcomp.getcontroller: tstringclientcontroller;
begin
 result:= tstringclientcontroller(inherited controller);
end;

procedure tifistringlinkcomp.setcontroller(const avalue: tstringclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tificlientcontroller }

constructor tificlientcontroller.create(const aowner: tmsecomponent);
begin
 inherited create(aowner,tkunknown);
end;

end.
