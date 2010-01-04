{ MSEgui Copyright (c) 2009-2010 by Martin Schreiber

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
 classes,mseclasses,msegui,mseifiglob,mseglob,typinfo,msestrings,msetypes,
 mseificompglob;

type
 tifilinkcomp = class;
 
 ificlienteventty = procedure(const sender: tobject;
                             const alink: iificlient) of object;
 ificlientstateeventty = procedure(const sender: tobject;
                           const alink: iificlient;
                           const astate: ifiwidgetstatesty;
                           const achangedstate: ifiwidgetstatesty) of object;
 ificlientmodalresulteventty = procedure(const sender: tobject;
                             const link: iificlient; 
                             const amodalresult: modalresultty) of object;

 ifivaluelinkstatety = (ivs_linking,ivs_valuesetting,ivs_loadedproc);
 ifivaluelinkstatesty = set of ifivaluelinkstatety;

 tcustomificlientcontroller = class(tlinkedpersistent,iifiserver)
  private
   fonclientvaluechanged: ificlienteventty;
   fonclientexecute: ificlienteventty;
   fonclientstatechanged: ificlientstateeventty;
   fonclientmodalresult: ificlientmodalresulteventty;
   fowner: tmsecomponent;
   function getintegerpro(const aname: string): integer;
   procedure setintegerpro(const aname: string; const avalue: integer);
   function getmsestringpro(const aname: string): msestring;
   procedure setmsestringpro(const aname: string; const avalue: msestring);
   function getbooleanpro(const aname: string): boolean;
   procedure setbooleanpro(const aname: string; const avalue: boolean);
   function getrealtypro(const aname: string): realty;
   procedure setrealtypro(const aname: string; const avalue: realty);
   function getdatetimepro(const aname: string): tdatetime;
   procedure setdatetimepro(const aname: string; const avalue: tdatetime);
  protected
   fkind: ttypekind;
   fstate: ifivaluelinkstatesty;
   fwidgetstate: ifiwidgetstatesty;
   fwidgetstatebefore: ifiwidgetstatesty;
   fchangedclient: pointer;
   
   fapropname: string;
   fapropkind: ttypekind;
   fapropvalue: pointer;

   procedure dogetprop(const alink: pointer);
   procedure getprop(const aname: string; const akind: ttypekind;
                                                const avaluepo: pointer);
   procedure dosetprop(const alink: pointer);
   procedure setprop(const aname: string; const akind: ttypekind;
                                                const avaluepo: pointer);
   procedure finalizelink(const alink: pointer);
   procedure finalizelinks;
   procedure loaded; virtual;
   function errorname(const ainstance: tobject): string;
   function checkcomponent(const aintf: iificlient): pointer;
                     //returns interface info
   procedure valuestootherclient(const alink: pointer); 
   procedure valuestoclient(const alink: pointer); virtual; 
   procedure clienttovalues(const alink: pointer); virtual; 
   procedure change(const alink: iificlient = nil);
   
   function setmsestringval(const alink: iificlient; const aname: string;
                                 const avalue: msestring): boolean;
                                    //true if found
   function getmsestringval(const alink: iificlient; const aname: string;
                                 var avalue: msestring): boolean;
                                    //true if found
   function setintegerval(const alink: iificlient; const aname: string;
                                 const avalue: integer): boolean;
                                    //true if found
   function getintegerval(const alink: iificlient; const aname: string;
                                 var avalue: integer): boolean;
                                    //true if found
   function setbooleanval(const alink: iificlient; const aname: string;
                                 const avalue: boolean): boolean;
                                    //true if found
   function getbooleanval(const alink: iificlient; const aname: string;
                                 var avalue: boolean): boolean;
                                    //true if found
   function setrealtyval(const alink: iificlient; const aname: string;
                                 const avalue: realty): boolean;
                                    //true if found
   function getrealtyval(const alink: iificlient; const aname: string;
                                 var avalue: realty): boolean;
                                    //true if found
   function setdatetimeval(const alink: iificlient; const aname: string;
                                 const avalue: tdatetime): boolean;
                                    //true if found
   function getdatetimeval(const alink: iificlient; const aname: string;
                                 var avalue: tdatetime): boolean;
                                    //true if found
  //iifiserver
   procedure execute(const sender: iificlient); virtual;
   procedure valuechanged(const sender: iificlient); virtual;
   procedure statechanged(const sender: iificlient;
                            const astate: ifiwidgetstatesty); virtual;
   procedure setvalue(const sender: iificlient; var avalue;
                                            var accept: boolean); virtual;
   procedure sendmodalresult(const sender: iificlient; 
                             const amodalresult: modalresultty); virtual;
  public
   constructor create(const aowner: tmsecomponent; const akind: ttypekind);
   function canconnect(const acomponent: tcomponent): boolean; virtual;

   property msestringprop[const aname: string]: msestring read getmsestringpro 
                                                       write setmsestringpro;
   property integerprop[const aname: string]: integer read getintegerpro 
                                                       write setintegerpro;
   property booleanprop[const aname: string]: boolean read getbooleanpro 
                                                       write setbooleanpro;
   property realtyprop[const aname: string]: realty read getrealtypro 
                                                       write setrealtypro;
   property datetimeprop[const aname: string]: tdatetime read getdatetimepro 
                                                       write setdatetimepro;

   property onclientvaluechanged: ificlienteventty read fonclientvaluechanged 
                                                    write fonclientvaluechanged;
   property onclientstatechanged: ificlientstateeventty 
                     read fonclientstatechanged write fonclientstatechanged;
   property onclientmodalresult: ificlientmodalresulteventty 
                     read fonclientmodalresult write fonclientmodalresult;
   property onclientexecute: ificlienteventty read fonclientexecute 
                     write fonclientexecute;
 end;

 tificlientcontroller = class(tcustomificlientcontroller)
  public
   constructor create(const aowner: tmsecomponent); virtual; overload;
  published
   property onclientvaluechanged;
   property onclientstatechanged;
   property onclientmodalresult;
   property onclientexecute;
 end;
                             
 ificlientcontrollerclassty = class of tificlientcontroller;

 texecclientcontroller = class(tificlientcontroller)
  protected
   function canconnect(const acomponent: tcomponent): boolean; override;
 end;
 
 tvalueclientcontroller = class(tificlientcontroller)
  protected
   function canconnect(const acomponent: tcomponent): boolean; override;
 end;
 
 tstringclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: msestring;
   fonclientsetvalue: setstringeventty;
   procedure setvalue(const avalue: msestring);
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
                              var avalue; var accept: boolean); override;
  public
   constructor create(const aowner: tmsecomponent); override;
  published
   property value: msestring read fvalue write setvalue;
   property onclientsetvalue: setstringeventty 
                read fonclientsetvalue write fonclientsetvalue;
 end;

 tintegerclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: integer;
   fmin: integer;
   fmax: integer;
   fonclientsetvalue: setintegereventty;
   procedure setvalue(const avalue: integer);
   procedure setmin(const avalue: integer);
   procedure setmax(const avalue: integer);
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
                              var avalue; var accept: boolean); override;
  public
   constructor create(const aowner: tmsecomponent); override;
  published
   property value: integer read fvalue write setvalue default 0;
   property min: integer read fmin write setmin default 0;
   property max: integer read fmax write setmax default maxint;
   property onclientsetvalue: setintegereventty 
                read fonclientsetvalue write fonclientsetvalue;
 end;

 tbooleanclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: boolean;
   fonclientsetvalue: setbooleaneventty;
   procedure setvalue(const avalue: boolean);
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
                              var avalue; var accept: boolean); override;
  public
   constructor create(const aowner: tmsecomponent); override;
  published
   property value: boolean read fvalue write setvalue default false;
   property onclientsetvalue: setbooleaneventty 
                read fonclientsetvalue write fonclientsetvalue;
 end;

 trealclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: realty;
   fmin: realty;
   fmax: realty;
   fonclientsetvalue: setrealeventty;
   procedure setvalue(const avalue: realty);
   procedure setmin(const avalue: realty);
   procedure setmax(const avalue: realty);
   procedure readvalue(reader: treader);
   procedure writevalue(writer: twriter);
   procedure readmin(reader: treader);
   procedure writemin(writer: twriter);
   procedure readmax(reader: treader);
   procedure writemax(writer: twriter);
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
                              var avalue; var accept: boolean); override;
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(const aowner: tmsecomponent); override;
  published
   property value: realty read fvalue write setvalue stored false;
   property min: realty read fmin write setmin stored false;
   property max: realty read fmax write setmax stored false;
   property onclientsetvalue: setrealeventty 
                       read fonclientsetvalue write fonclientsetvalue;
 end;

 tdatetimeclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: tdatetime;
   fmin: tdatetime;
   fmax: tdatetime;
   fonclientsetvalue: setrealeventty;
   procedure setvalue(const avalue: tdatetime);
   procedure setmin(const avalue: tdatetime);
   procedure setmax(const avalue: tdatetime);
   procedure readvalue(reader: treader);
   procedure writevalue(writer: twriter);
   procedure readmin(reader: treader);
   procedure writemin(writer: twriter);
   procedure readmax(reader: treader);
   procedure writemax(writer: twriter);
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
                              var avalue; var accept: boolean); override;
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(const aowner: tmsecomponent); override;
  published
   property value: tdatetime read fvalue write setvalue stored false;
   property min: tdatetime read fmin write setmin stored false;
   property max: tdatetime read fmax write setmax stored false;
   property onclientsetvalue: setrealeventty 
                       read fonclientsetvalue write fonclientsetvalue;
 end;

 tgridclientcontroller = class(tificlientcontroller)
  private
   frowcount: integer;
   procedure setrowcount(const avalue: integer);
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
  public
  published
   property rowcount: integer read frowcount write setrowcount default 0;
//  property onclientcellevent: celleventty read fclientcellevent 
//                                                 write fclientcellevent;
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

 tifiintegerlinkcomp = class(tifilinkcomp)
  private
   function getcontroller: tintegerclientcontroller;
   procedure setcontroller(const avalue: tintegerclientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; override;
  published
   property controller: tintegerclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifibooleanlinkcomp = class(tifilinkcomp)
  private
   function getcontroller: tbooleanclientcontroller;
   procedure setcontroller(const avalue: tbooleanclientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; override;
  published
   property controller: tbooleanclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifireallinkcomp = class(tifilinkcomp)
  private
   function getcontroller: trealclientcontroller;
   procedure setcontroller(const avalue: trealclientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; override;
  published
   property controller: trealclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifidatetimelinkcomp = class(tifilinkcomp)
  private
   function getcontroller: tdatetimeclientcontroller;
   procedure setcontroller(const avalue: tdatetimeclientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; override;
  published
   property controller: tdatetimeclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifiactionlinkcomp = class(tifilinkcomp)
  private
   function getcontroller: texecclientcontroller;
   procedure setcontroller(const avalue: texecclientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; override;
  published
   property controller: texecclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifigridlinkcomp = class(tifilinkcomp)
  private
   function getcontroller: tgridclientcontroller;
   procedure setcontroller(const avalue: tgridclientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; override;
  published
   property controller: tgridclientcontroller read getcontroller
                                                         write setcontroller;
 end;
   
procedure setifilinkcomp(const alink: iifilink;
                      const alinkcomp: tifilinkcomp; var dest: tifilinkcomp);
implementation
uses
 sysutils,mseapplication,msereal,msestreaming;
 
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
procedure tcustomificlientcontroller.execute(const sender: iificlient);
begin
 if fowner.canevent(tmethod(fonclientexecute)) then begin
  fonclientexecute(self,sender);
 end;
end;

procedure tcustomificlientcontroller.valuechanged(const sender: iificlient);
begin
 if {(fvalueproperty <> nil) and} not (ivs_valuesetting in fstate) and 
               not(csloading in fowner.componentstate) then begin
  include(fstate,ivs_valuesetting);
  try
   clienttovalues(sender);
   fchangedclient:= sender;
   tmsecomponent1(fowner).getobjectlinker.forall(@valuestootherclient,self);
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
var
 obj: tobject;
begin
 if not (ivs_loadedproc in fstate) and 
      (fowner.componentstate * [csdesigning,csloading,csdestroying] = 
                                                [csdesigning]) then begin
  obj:= iobjectlink(alink).getinstance;
  if (obj is tcomponent) and (tcomponent(obj).owner <> fowner.owner) then begin
   designchanged(tcomponent(obj));
  end;
 end;
end;

procedure tcustomificlientcontroller.valuestootherclient(const alink: pointer);
begin
 if alink <> fchangedclient then begin
  valuestoclient(alink);
 end;
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

procedure tcustomificlientcontroller.setvalue(const sender: iificlient;
                   var avalue; var accept: boolean);
begin
 //dummy
end;

function tcustomificlientcontroller.canconnect(const acomponent: tcomponent): boolean;
var
 po1: pointer;
begin
 result:= getcorbainterface(acomponent,typeinfo(iifilink),po1);
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

function tcustomificlientcontroller.setintegerval(const alink: iificlient;
               const aname: string; const avalue: integer): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkinteger);
 if result then begin
  setordprop(inst,prop,avalue);
 end; 
end;

function tcustomificlientcontroller.getintegerval(
                     const alink: iificlient; const aname: string;
                     var avalue: integer): boolean;
                                    //true if found
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkinteger);
 if result then begin
  avalue:= getordprop(inst,prop);
 end; 
end;

function tcustomificlientcontroller.setbooleanval(const alink: iificlient;
               const aname: string; const avalue: boolean): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkbool);
 if result then begin
  setordprop(inst,prop,ord(avalue));
 end; 
end;

function tcustomificlientcontroller.getbooleanval(
                     const alink: iificlient; const aname: string;
                     var avalue: boolean): boolean;
                                    //true if found
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkenumeration);
 if result then begin
  avalue:= getordprop(inst,prop) <> 0;
 end; 
end;

function tcustomificlientcontroller.setrealtyval(const alink: iificlient;
               const aname: string; const avalue: realty): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkfloat);
 if result then begin
  setfloatprop(inst,prop,avalue);
 end; 
end;

function tcustomificlientcontroller.getrealtyval(
                     const alink: iificlient; const aname: string;
                     var avalue: realty): boolean;
                                    //true if found
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkfloat);
 if result then begin
  avalue:= getfloatprop(inst,prop);
 end; 
end;

function tcustomificlientcontroller.setdatetimeval(const alink: iificlient;
               const aname: string; const avalue: tdatetime): boolean;
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkfloat);
 if result then begin
  setfloatprop(inst,prop,avalue);
 end; 
end;

function tcustomificlientcontroller.getdatetimeval(
                     const alink: iificlient; const aname: string;
                     var avalue: tdatetime): boolean;
                                    //true if found
var
 inst: tobject;
 prop: ppropinfo;
 
begin
 inst:= alink.getinstance;
 prop:= getpropinfo(inst,aname);
 result:= (prop <> nil) and (prop^.proptype^.kind = tkfloat);
 if result then begin
  avalue:= getfloatprop(inst,prop);
 end; 
end;


procedure tcustomificlientcontroller.loaded;
begin
 include(fstate,ivs_loadedproc);
 try
  change;
 finally
  exclude(fstate,ivs_loadedproc);
 end;
end;

procedure tcustomificlientcontroller.dogetprop(const alink: pointer); 
begin
 case fapropkind of
  tkinteger: begin
   getintegerval(iificlient(alink),fapropname,pinteger(fapropvalue)^);
  end;
  tkbool: begin
   getbooleanval(iificlient(alink),fapropname,pboolean(fapropvalue)^);
  end;
  tkfloat: begin
   getrealtyval(iificlient(alink),fapropname,prealty(fapropvalue)^);
  end;
  msestringtypekind: begin
   getmsestringval(iificlient(alink),fapropname,pmsestring(fapropvalue)^);
  end;
 end;
end;

procedure tcustomificlientcontroller.getprop(const aname: string;
               const akind: ttypekind; const avaluepo: pointer);
begin
 fapropname:= aname;
 fapropkind:= akind;
 fapropvalue:= avaluepo;
 tmsecomponent1(fowner).getobjectlinker.forall(@dogetprop,self);
end;

procedure tcustomificlientcontroller.dosetprop(const alink: pointer);
begin
 case fapropkind of
  tkinteger: begin
   setintegerval(iificlient(alink),fapropname,pinteger(fapropvalue)^);
  end;
 end;
end;

procedure tcustomificlientcontroller.setprop(const aname: string;
               const akind: ttypekind; const avaluepo: pointer);
begin
 fapropname:= aname;
 fapropkind:= akind;
 fapropvalue:= avaluepo;
 tmsecomponent1(fowner).getobjectlinker.forall(@dosetprop,self);
end;

function tcustomificlientcontroller.getintegerpro(const aname: string): integer;
begin
 result:= 0;
 getprop(aname,tkinteger,@result);
end;

procedure tcustomificlientcontroller.setintegerpro(const aname: string;
               const avalue: integer);
begin
 setprop(aname,tkinteger,@avalue);
end;

function tcustomificlientcontroller.getmsestringpro(const aname: string): msestring;
begin
 result:= '';
 getprop(aname,msestringtypekind,@result);
end;

procedure tcustomificlientcontroller.setmsestringpro(const aname: string;
               const avalue: msestring);
begin
 setprop(aname,msestringtypekind,@avalue);
end;

function tcustomificlientcontroller.getbooleanpro(const aname: string): boolean;
begin
 result:= false;
 getprop(aname,tkbool,@result);
end;

procedure tcustomificlientcontroller.setbooleanpro(const aname: string;
               const avalue: boolean);
begin
 setprop(aname,tkbool,@avalue);
end;

function tcustomificlientcontroller.getrealtypro(const aname: string): realty;
begin
 result:= emptyreal;
 getprop(aname,tkfloat,@result);
end;

procedure tcustomificlientcontroller.setrealtypro(const aname: string;
               const avalue: realty);
begin
 setprop(aname,tkfloat,@avalue);
end;

function tcustomificlientcontroller.getdatetimepro(const aname: string): tdatetime;
begin
 result:= emptydatetime;
 getprop(aname,tkfloat,@result);
end;

procedure tcustomificlientcontroller.setdatetimepro(const aname: string;
               const avalue: tdatetime);
begin
 setprop(aname,tkfloat,@avalue);
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

{ tvalueclientcontroller }

function tvalueclientcontroller.canconnect(const acomponent: tcomponent): boolean;
var
 intf1: pointer;
 prop1: ppropinfo;
begin
 result:= inherited canconnect(acomponent);
 if result then begin
  prop1:= getpropinfo(acomponent,'value');
  result:= (prop1 <> nil) and (prop1^.proptype^.kind = fkind);
 end;
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
 setmsestringval(iificlient(alink),'value',fvalue);
 inherited;
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
procedure tstringclientcontroller.setvalue(const sender: iificlient;
                                         var avalue; var accept: boolean);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,msestring(avalue),accept);
 end;
end;

{ tintegerclientcontroller }

constructor tintegerclientcontroller.create(const aowner: tmsecomponent);
begin
 fmax:= maxint;
 inherited create(aowner,tkinteger);
end;

procedure tintegerclientcontroller.setvalue(const avalue: integer);
begin
 fvalue:= avalue;
 change;
end;

procedure tintegerclientcontroller.valuestoclient(const alink: pointer);
begin
 setintegerval(iificlient(alink),'value',fvalue);
 setintegerval(iificlient(alink),'min',fmin);
 setintegerval(iificlient(alink),'max',fmax);
 inherited;
end;

procedure tintegerclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getintegerval(iificlient(alink),'value',fvalue);
end;

procedure tintegerclientcontroller.setvalue(const sender: iificlient;
                                         var avalue; var accept: boolean);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,integer(avalue),accept);
 end;
end;

procedure tintegerclientcontroller.setmin(const avalue: integer);
begin
 fmin:= avalue;
 change;
end;

procedure tintegerclientcontroller.setmax(const avalue: integer);
begin
 fmax:= avalue;
 change;
end;

{ tbooleanclientcontroller }

constructor tbooleanclientcontroller.create(const aowner: tmsecomponent);
begin
 inherited create(aowner,tkbool);
end;

procedure tbooleanclientcontroller.setvalue(const avalue: boolean);
begin
 fvalue:= avalue;
 change;
end;

procedure tbooleanclientcontroller.valuestoclient(const alink: pointer);
begin
 setbooleanval(iificlient(alink),'value',fvalue);
 inherited;
end;

procedure tbooleanclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getbooleanval(iificlient(alink),'value',fvalue);
end;

procedure tbooleanclientcontroller.setvalue(const sender: iificlient;
                                         var avalue; var accept: boolean);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,boolean(avalue),accept);
 end;
end;

{ trealclientcontroller }

constructor trealclientcontroller.create(const aowner: tmsecomponent);
begin
 fvalue:= emptyreal;
 fmin:= emptyreal;
 fmax:= bigreal;
 inherited create(aowner,tkfloat);
end;

procedure trealclientcontroller.setvalue(const avalue: realty);
begin
 fvalue:= avalue;
 change;
end;

procedure trealclientcontroller.valuestoclient(const alink: pointer);
begin
 setrealtyval(iificlient(alink),'value',fvalue);
 setrealtyval(iificlient(alink),'min',fmin);
 setrealtyval(iificlient(alink),'max',fmax);
 inherited;
end;

procedure trealclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getrealtyval(iificlient(alink),'value',fvalue);
end;

procedure trealclientcontroller.setvalue(const sender: iificlient;
                                         var avalue; var accept: boolean);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,realty(avalue),accept);
 end;
end;

procedure trealclientcontroller.setmin(const avalue: realty);
begin
 fmin:= avalue;
 change;
end;

procedure trealclientcontroller.setmax(const avalue: realty);
begin
 fmax:= avalue;
 change;
end;

procedure trealclientcontroller.readvalue(reader: treader);
begin
 value:= readrealty(reader);
end;

procedure trealclientcontroller.writevalue(writer: twriter);
begin
 writerealty(writer,fvalue);
end;

procedure trealclientcontroller.readmin(reader: treader);
begin
 fmin:= readrealty(reader);
end;

procedure trealclientcontroller.writemin(writer: twriter);
begin
 writerealty(writer,fmin);
end;

procedure trealclientcontroller.readmax(reader: treader);
begin
 fmax:= readrealty(reader);
end;

procedure trealclientcontroller.writemax(writer: twriter);
begin
 writerealty(writer,fmax);
end;

procedure trealclientcontroller.defineproperties(filer: tfiler);
var
 bo1,bo2,bo3: boolean;
begin
 inherited;
 if filer.ancestor <> nil then begin
  with trealclientcontroller(filer.ancestor) do begin
   bo1:= self.fvalue <> fvalue;
   bo2:= self.fmin <> fmin;
   bo3:= self.fmax <> fmax;
  end;
 end
 else begin
  bo1:= not isemptyreal(fvalue);
  bo2:= not isemptyreal(fmin);
  bo3:= cmprealty(fmax,bigreal) <> 0;
//  bo3:= cmprealty(fmax,0.99*bigreal) < 0;
 end;
 
 filer.DefineProperty('val',
             {$ifdef FPC}@{$endif}readvalue,
             {$ifdef FPC}@{$endif}writevalue,bo1);
 filer.DefineProperty('mi',{$ifdef FPC}@{$endif}readmin,
          {$ifdef FPC}@{$endif}writemin,bo2);
 filer.DefineProperty('ma',{$ifdef FPC}@{$endif}readmax,
          {$ifdef FPC}@{$endif}writemax,bo3);
end;

{ tdatetimeclientcontroller }

constructor tdatetimeclientcontroller.create(const aowner: tmsecomponent);
begin
 fvalue:= emptydatetime;
 fmin:= emptydatetime;
 fmax:= bigdatetime;
 inherited create(aowner,tkfloat);
end;

procedure tdatetimeclientcontroller.setvalue(const avalue: tdatetime);
begin
 fvalue:= avalue;
 change;
end;

procedure tdatetimeclientcontroller.valuestoclient(const alink: pointer);
begin
 setdatetimeval(iificlient(alink),'value',fvalue);
 setdatetimeval(iificlient(alink),'min',fmin);
 setdatetimeval(iificlient(alink),'max',fmax);
 inherited;
end;

procedure tdatetimeclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getdatetimeval(iificlient(alink),'value',fvalue);
end;

procedure tdatetimeclientcontroller.setvalue(const sender: iificlient;
                                         var avalue; var accept: boolean);
begin
 if fowner.canevent(tmethod(fonclientsetvalue)) then begin
  fonclientsetvalue(self,tdatetime(avalue),accept);
 end;
end;

procedure tdatetimeclientcontroller.setmin(const avalue: tdatetime);
begin
 fmin:= avalue;
 change;
end;

procedure tdatetimeclientcontroller.setmax(const avalue: tdatetime);
begin
 fmax:= avalue;
 change;
end;

procedure tdatetimeclientcontroller.readvalue(reader: treader);
begin
 value:= readrealty(reader);
end;

procedure tdatetimeclientcontroller.writevalue(writer: twriter);
begin
 writerealty(writer,fvalue);
end;

procedure tdatetimeclientcontroller.readmin(reader: treader);
begin
 fmin:= readrealty(reader);
end;

procedure tdatetimeclientcontroller.writemin(writer: twriter);
begin
 writerealty(writer,fmin);
end;

procedure tdatetimeclientcontroller.readmax(reader: treader);
begin
 fmax:= readrealty(reader);
end;

procedure tdatetimeclientcontroller.writemax(writer: twriter);
begin
 writerealty(writer,fmax);
end;

procedure tdatetimeclientcontroller.defineproperties(filer: tfiler);
var
 bo1,bo2,bo3: boolean;
begin
 inherited;
 if filer.ancestor <> nil then begin
  with tdatetimeclientcontroller(filer.ancestor) do begin
   bo1:= self.fvalue <> fvalue;
   bo2:= self.fmin <> fmin;
   bo3:= self.fmax <> fmax;
  end;
 end
 else begin
  bo1:= not isemptydatetime(fvalue);
  bo2:= not isemptydatetime(fmin);
  bo3:= cmprealty(fmax,bigdatetime) <> 0;
//  bo3:= cmpdatetime(fmax,0.99*bigdatetime) < 0;
 end;
 
 filer.DefineProperty('val',
             {$ifdef FPC}@{$endif}readvalue,
             {$ifdef FPC}@{$endif}writevalue,bo1);
 filer.DefineProperty('mi',{$ifdef FPC}@{$endif}readmin,
          {$ifdef FPC}@{$endif}writemin,bo2);
 filer.DefineProperty('ma',{$ifdef FPC}@{$endif}readmax,
          {$ifdef FPC}@{$endif}writemax,bo3);
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

{ tifiintegerlinkcomp }

function tifiintegerlinkcomp.getcontrollerclass: ificlientcontrollerclassty;
begin
 result:= tintegerclientcontroller;
end;

function tifiintegerlinkcomp.getcontroller: tintegerclientcontroller;
begin
 result:= tintegerclientcontroller(inherited controller);
end;

procedure tifiintegerlinkcomp.setcontroller(const avalue: tintegerclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tifibooleanlinkcomp }

function tifibooleanlinkcomp.getcontrollerclass: ificlientcontrollerclassty;
begin
 result:= tbooleanclientcontroller;
end;

function tifibooleanlinkcomp.getcontroller: tbooleanclientcontroller;
begin
 result:= tbooleanclientcontroller(inherited controller);
end;

procedure tifibooleanlinkcomp.setcontroller(const avalue: tbooleanclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tifireallinkcomp }

function tifireallinkcomp.getcontrollerclass: ificlientcontrollerclassty;
begin
 result:= trealclientcontroller;
end;

function tifireallinkcomp.getcontroller: trealclientcontroller;
begin
 result:= trealclientcontroller(inherited controller);
end;

procedure tifireallinkcomp.setcontroller(const avalue: trealclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tifidatetimelinkcomp }

function tifidatetimelinkcomp.getcontrollerclass: ificlientcontrollerclassty;
begin
 result:= tdatetimeclientcontroller;
end;

function tifidatetimelinkcomp.getcontroller: tdatetimeclientcontroller;
begin
 result:= tdatetimeclientcontroller(inherited controller);
end;

procedure tifidatetimelinkcomp.setcontroller(const avalue: tdatetimeclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tificlientcontroller }

constructor tificlientcontroller.create(const aowner: tmsecomponent);
begin
 inherited create(aowner,tkunknown);
end;

{ tifiactionlinkcomp }

function tifiactionlinkcomp.getcontrollerclass: ificlientcontrollerclassty;
begin
 result:= texecclientcontroller;
end;

function tifiactionlinkcomp.getcontroller: texecclientcontroller;
begin
 result:= texecclientcontroller(inherited controller);
end;

procedure tifiactionlinkcomp.setcontroller(const avalue: texecclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ texecclientcontroller }

function texecclientcontroller.canconnect(const acomponent: tcomponent): boolean;
var
 intf1: pointer;
 prop1: ppropinfo;
begin
 result:= inherited canconnect(acomponent);
 if result then begin
  prop1:= getpropinfo(acomponent,'onexecute');
  result:= (prop1 <> nil) and (prop1^.proptype^.kind = tkmethod);
 end;
end;

{ tifigridlinkcomp }

function tifigridlinkcomp.getcontrollerclass: ificlientcontrollerclassty;
begin
 result:= tgridclientcontroller;
end;

function tifigridlinkcomp.getcontroller: tgridclientcontroller;
begin
 result:= tgridclientcontroller(inherited controller);
end;

procedure tifigridlinkcomp.setcontroller(const avalue: tgridclientcontroller);
begin
 inherited setcontroller(avalue);
end;

{ tgridclientcontroller }

procedure tgridclientcontroller.setrowcount(const avalue: integer);
begin
 frowcount:= avalue;
 change;
end;

procedure tgridclientcontroller.valuestoclient(const alink: pointer);
begin
 setintegerval(iifigridlink(alink),'rowcount',frowcount);
 inherited;
end;

procedure tgridclientcontroller.clienttovalues(const alink: pointer);
begin
 inherited;
 getintegerval(iifigridlink(alink),'rowcount',frowcount);
end;

end.
