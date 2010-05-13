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
 mseificompglob,msearrayprops,msedatalist,msestat,msestatfile;

type
 tifilinkcomp = class;
 tifivaluelinkcomp = class;
 
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

 tcustomificlientcontroller = class(tlinkedpersistent,iifiserver,istatfile)
  private
   fonclientvaluechanged: ificlienteventty;
   fonclientexecute: ificlienteventty;
   fonclientstatechanged: ificlientstateeventty;
   fonclientmodalresult: ificlientmodalresulteventty;
   fowner: tmsecomponent;
   fstatfile: tstatfile;
   fstatvarname: msestring;
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
   procedure setstatfile(const avalue: tstatfile);
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
   function getifilinkkind: ptypeinfo; virtual;
   function checkcomponent(const aintf: iifilink): pointer;
              //returns interface info, exception if link invalid
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
    //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
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
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read fstatvarname write fstatvarname;
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
   property statfile;
   property statvarname;
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

 valarsetterty = procedure(const alink: pointer; var handled: boolean) of object; 
 valargetterty = procedure(const alink: pointer; var handled: boolean) of object;

 itemsetterty = procedure(const alink: pointer; var handled: boolean) of object; 
 itemgetterty = procedure(const alink: pointer; var handled: boolean) of object;
  
 tvalueclientcontroller = class(tificlientcontroller)
  private
   fvalarpo: pointer;
   fitempo: pointer;
   fitemindex: integer;
  protected
   function getifilinkkind: ptypeinfo; override;
   function canconnect(const acomponent: tcomponent): boolean; override;

   procedure getdatalist1(const alink: pointer; var handled: boolean);
   function getdatalist: tdatalist;
   
   procedure setmsestringvalar(const alink: pointer; var handled: boolean);
   procedure getmsestringvalar(const alink: pointer; var handled: boolean);
   procedure setintegervalar(const alink: pointer; var handled: boolean);
   procedure getintegervalar(const alink: pointer; var handled: boolean);
   procedure setrealtyvalar(const alink: pointer; var handled: boolean);
   procedure getrealtyvalar(const alink: pointer; var handled: boolean);
   procedure setdatetimevalar(const alink: pointer; var handled: boolean);
   procedure getdatetimevalar(const alink: pointer; var handled: boolean);
   procedure setbooleanvalar(const alink: pointer; var handled: boolean);
   procedure getbooleanvalar(const alink: pointer; var handled: boolean);
   procedure getvalar(const agetter: valargetterty; var avalue);
   procedure setvalar(const asetter: valarsetterty; const avalue);

   procedure setmsestringitem(const alink: pointer; var handled: boolean);
   procedure getmsestringitem(const alink: pointer; var handled: boolean);
   procedure setintegeritem(const alink: pointer; var handled: boolean);
   procedure getintegeritem(const alink: pointer; var handled: boolean);
   procedure setrealtyitem(const alink: pointer; var handled: boolean);
   procedure getrealtyitem(const alink: pointer; var handled: boolean);
   procedure setdatetimeitem(const alink: pointer; var handled: boolean);
   procedure getdatetimeitem(const alink: pointer; var handled: boolean);
   procedure setbooleanitem(const alink: pointer; var handled: boolean);
   procedure getbooleanitem(const alink: pointer; var handled: boolean);
   procedure getitem(const index: integer; const agetter: itemgetterty;
                                                                 var avalue);
   procedure setitem(const index: integer; const asetter: itemsetterty;
                                                                 const avalue);

   procedure statreadlist(const alink: pointer);
   procedure statwritelist(const alink: pointer; var handled: boolean);
 end;
 
 tstringclientcontroller = class(tvalueclientcontroller)
  private
   fvalue: msestring;
   fonclientsetvalue: setstringeventty;
   procedure setvalue(const avalue: msestring);
   function getgridvalues: msestringarty;
   procedure setgridvalues(const avalue: msestringarty);
   function getgridvalue(const index: integer): msestring;
   procedure setgridvalue(const index: integer; const avalue: msestring);
   function getgriddata: tmsestringdatalist;
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
                              var avalue; var accept: boolean); override;
    //istatfile
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: tmsestringdatalist read getgriddata;
   property gridvalues: msestringarty read getgridvalues write setgridvalues;
   property gridvalue[const index: integer]: msestring read getgridvalue 
                                                             write setgridvalue;
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
   function getgridvalues: integerarty;
   procedure setgridvalues(const avalue: integerarty);
   function getgridvalue(const index: integer): integer;
   procedure setgridvalue(const index: integer; const avalue: integer);
   function getgriddata: tintegerdatalist;
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
                              var avalue; var accept: boolean); override;
    //istatfile
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: tintegerdatalist read getgriddata;
   property gridvalues: integerarty read getgridvalues write setgridvalues;
   property gridvalue[const index: integer]: integer read getgridvalue 
                                                             write setgridvalue;
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
   function getgridvalues: longboolarty;
   procedure setgridvalues(const avalue: longboolarty);
   function getgridvalue(const index: integer): boolean;
   procedure setgridvalue(const index: integer; const avalue: boolean);
   function getgriddata: tintegerdatalist;
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
                              var avalue; var accept: boolean); override;
    //istatfile
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: tintegerdatalist read getgriddata;
   property gridvalues: longboolarty read getgridvalues write setgridvalues;
   property gridvalue[const index: integer]: boolean read getgridvalue 
                                                             write setgridvalue;
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
   function getgridvalues: realarty;
   procedure setgridvalues(const avalue: realarty);
   function getgridvalue(const index: integer): real;
   procedure setgridvalue(const index: integer; const avalue: real);
   function getgriddata: trealdatalist;
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
                              var avalue; var accept: boolean); override;
   procedure defineproperties(filer: tfiler); override;
    //istatfile
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: trealdatalist read getgriddata;
   property gridvalues: realarty read getgridvalues write setgridvalues;
   property gridvalue[const index: integer]: real read getgridvalue 
                                                             write setgridvalue;
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
   function getgridvalues: datetimearty;
   procedure setgridvalues(const avalue: datetimearty);
   function getgridvalue(const index: integer): tdatetime;
   procedure setgridvalue(const index: integer; const avalue: tdatetime);
   function getgriddata: tdatetimedatalist;
  protected
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure setvalue(const sender: iificlient;
                              var avalue; var accept: boolean); override;
   procedure defineproperties(filer: tfiler); override;
    //istatfile
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   property griddata: tdatetimedatalist read getgriddata;
   property gridvalues: datetimearty read getgridvalues write setgridvalues;
   property gridvalue[const index: integer]: tdatetime read getgridvalue 
                                                             write setgridvalue;
  published
   property value: tdatetime read fvalue write setvalue stored false;
   property min: tdatetime read fmin write setmin stored false;
   property max: tdatetime read fmax write setmax stored false;
   property onclientsetvalue: setrealeventty 
                       read fonclientsetvalue write fonclientsetvalue;
 end;
 
 ificelleventty = procedure(const sender: tobject; 
                           var info: ificelleventinfoty) of object;

 tificolitem = class(tmsecomponentitem)
  private
   function getlink: tifivaluelinkcomp;
   procedure setlink(const avalue: tifivaluelinkcomp);
  published
   property link: tifivaluelinkcomp read getlink write setlink;
 end;
 
 tifilinkcomparrayprop = class(tmsecomponentarrayprop)
  private
   function getitems(const index: integer): tificolitem;
  public 
   constructor create;
   class function getitemclasstype: persistentclassty; override;
   property items[const index: integer]: tificolitem read getitems; default;
 end;

 tgridclientcontroller = class(tificlientcontroller)
  private
   frowcount: integer;
   foncellevent: ificelleventty;
   fdatacols: tifilinkcomparrayprop;
   fcheckautoappend: boolean;
   fitempo: pointer;
   procedure setrowcount(const avalue: integer);
   procedure setdatacols(const avalue: tifilinkcomparrayprop);
   function getrowstate: tcustomrowstatelist;
   procedure statreadrowstate(const alink: pointer);
   procedure statwriterowstate(const alink: pointer; var handled: boolean);
  protected
   function getifilinkkind: ptypeinfo; override;
   procedure valuestoclient(const alink: pointer); override;
   procedure clienttovalues(const alink: pointer); override;
   procedure itemappendrow(const alink: pointer);
   procedure getrowstate1(const alink: pointer; var handled: boolean);

   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
  public
   constructor create(const aowner: tmsecomponent); override;
   destructor destroy; override;
   procedure docellevent(var info: ificelleventinfoty);
   procedure appendrow(const avalues: array of const;
                         const checkautoappend: boolean = false);
   property rowstate: tcustomrowstatelist read getrowstate;
  published
   property rowcount: integer read frowcount write setrowcount default 0;
   property oncellevent: ificelleventty read foncellevent write foncellevent;
//  property onclientcellevent: celleventty read fclientcellevent 
//                                                 write fclientcellevent;
   property datacols: tifilinkcomparrayprop read fdatacols write setdatacols;
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
 
 tifivaluelinkcomp = class(tifilinkcomp)
  private
   function getcontroller: tvalueclientcontroller;
  public
   property controller: tvalueclientcontroller read getcontroller;
 end;
 
 tifistringlinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: tstringclientcontroller;
   procedure setcontroller(const avalue: tstringclientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; override;
  published
   property controller: tstringclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifiintegerlinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: tintegerclientcontroller;
   procedure setcontroller(const avalue: tintegerclientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; override;
  published
   property controller: tintegerclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifibooleanlinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: tbooleanclientcontroller;
   procedure setcontroller(const avalue: tbooleanclientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; override;
  published
   property controller: tbooleanclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifireallinkcomp = class(tifivaluelinkcomp)
  private
   function getcontroller: trealclientcontroller;
   procedure setcontroller(const avalue: trealclientcontroller);
  protected
   function getcontrollerclass: ificlientcontrollerclassty; override;
  published
   property controller: trealclientcontroller read getcontroller
                                                         write setcontroller;
 end;

 tifidatetimelinkcomp = class(tifivaluelinkcomp)
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

const
 valuevarname = 'value';
// arvaluevarname = 'arvalue';
 rowstatevarname = '_rowstate';
  
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
          const aintf: iifilink): pointer;
begin
 if not isinterface(aintf.getifilinkkind,getifilinkkind) then begin
  raise exception.create(fowner.name+' wrong iificlient interface.');
            //todo: better error message
 end;
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
 result:= (prop <> nil) and (prop^.proptype^.kind = tkbool);
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

function tcustomificlientcontroller.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifilink);
end;

procedure tcustomificlientcontroller.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

procedure tcustomificlientcontroller.dostatread(const reader: tstatreader);
begin
 //dummy
end;

procedure tcustomificlientcontroller.dostatwrite(const writer: tstatwriter);
begin
 //dummy
end;

procedure tcustomificlientcontroller.statreading;
begin
 //dummy
end;

procedure tcustomificlientcontroller.statread;
begin
 //dummy
end;

function tcustomificlientcontroller.getstatvarname: msestring;
begin
 if fstatvarname = '' then begin
  result:= ownernamepath(fowner);
  if result = '' then begin
   result:= '.'; //dummy, statfiler can not get componentname because 
                 //self is no tcomponent
  end;
 end
 else begin
  result:= fstatvarname;
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

function tvalueclientcontroller.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidatalink);
end;

procedure tvalueclientcontroller.getdatalist1(const alink: pointer;
                                                   var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist <> nil then begin
  pdatalist(fitempo)^:= datalist;
 end;
end;

function tvalueclientcontroller.getdatalist: tdatalist;
begin
 result:= nil;
 fitempo:= @result;
 tmsecomponent1(fowner).getobjectlinker.forfirst(@getdatalist1,self); 
end;

procedure tvalueclientcontroller.setmsestringvalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tmsestringdatalist then begin
  tmsestringdatalist(datalist).asarray:= pmsestringarty(fvalarpo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getmsestringvalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tmsestringdatalist then begin
  pmsestringarty(fvalarpo)^:= tmsestringdatalist(datalist).asarray;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setintegervalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  tintegerdatalist(datalist).asarray:= pintegerarty(fvalarpo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getintegervalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  pintegerarty(fvalarpo)^:= tintegerdatalist(datalist).asarray;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setrealtyvalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  trealdatalist(datalist).asarray:= prealarty(fvalarpo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getrealtyvalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  prealarty(fvalarpo)^:= trealdatalist(datalist).asarray;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setdatetimevalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  trealdatalist(datalist).asarray:= pdatetimearty(fvalarpo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getdatetimevalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  prealarty(fvalarpo)^:= trealdatalist(datalist).asarray;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setbooleanvalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  tintegerdatalist(datalist).asarray:= pintegerarty(fvalarpo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getbooleanvalar(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  pintegerarty(fvalarpo)^:= tintegerdatalist(datalist).asarray;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getvalar(const agetter: valargetterty;
                       var avalue);
begin
 fvalarpo:= @avalue;
 tmsecomponent1(fowner).getobjectlinker.forfirst(agetter,self); 
end;

procedure tvalueclientcontroller.setvalar(const asetter: valarsetterty;
                        const avalue);
begin
 fvalarpo:= @avalue;
 tmsecomponent1(fowner).getobjectlinker.forfirst(asetter,self); 
end;

procedure tvalueclientcontroller.setmsestringitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
 int1: integer;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tmsestringdatalist then begin
  int1:= fitemindex;
  if int1 = maxint then begin
   int1:= datalist.count - 1;
  end;
  tmsestringdatalist(datalist)[int1]:= pmsestring(fitempo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getmsestringitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tmsestringdatalist then begin
  pmsestring(fitempo)^:= tmsestringdatalist(datalist)[fitemindex];
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setintegeritem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
 int1: integer;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  int1:= fitemindex;
  if int1 = maxint then begin
   int1:= datalist.count - 1;
  end;
  tintegerdatalist(datalist)[int1]:= pinteger(fitempo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getintegeritem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  pinteger(fitempo)^:= tintegerdatalist(datalist)[fitemindex];
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setrealtyitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
 int1: integer;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  int1:= fitemindex;
  if int1 = maxint then begin
   int1:= datalist.count - 1;
  end;
  trealdatalist(datalist)[int1]:= prealty(fitempo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getrealtyitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  prealty(fitempo)^:= trealdatalist(datalist)[fitemindex];
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setdatetimeitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
 int1: integer;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  int1:= fitemindex;
  if int1 = maxint then begin
   int1:= datalist.count - 1;
  end;
  trealdatalist(datalist)[int1]:= pdatetime(fitempo)^;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getdatetimeitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is trealdatalist then begin
  pdatetime(fitempo)^:= trealdatalist(datalist)[fitemindex];
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.setbooleanitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
 int1: integer;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  int1:= fitemindex;
  if int1 = maxint then begin
   int1:= datalist.count - 1;
  end;
  if pinteger(fitempo)^ = 0 then begin
   tintegerdatalist(datalist)[int1]:= longint(longbool(false));
  end
  else begin
   tintegerdatalist(datalist)[int1]:= longint(longbool(true));
  end;
  handled:= true;
 end;
end;

procedure tvalueclientcontroller.getbooleanitem(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist is tintegerdatalist then begin
  pintegerarty(fitempo)^:= tintegerdatalist(datalist).asarray;
  handled:= true
 end;
end;

procedure tvalueclientcontroller.getitem(const index: integer; 
                                   const agetter: itemgetterty; var avalue);
begin
 fitempo:= @avalue;
 fitemindex:= index;
 tmsecomponent1(fowner).getobjectlinker.forfirst(agetter,self); 
end;

procedure tvalueclientcontroller.setitem(const index: integer; 
                               const asetter: itemsetterty; const avalue);
begin
 fitempo:= @avalue;
 fitemindex:= index;
 tmsecomponent1(fowner).getobjectlinker.forfirst(asetter,self); 
end;

procedure tvalueclientcontroller.statreadlist(const alink: pointer);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist <> nil then begin
  tstatreader(fitempo).readdatalist(getstatvarname,datalist);
 end;
end;

procedure tvalueclientcontroller.statwritelist(const alink: pointer;
                                                      var handled: boolean);
var
 datalist: tdatalist;
begin
 datalist:= iifidatalink(alink).ifigriddata;
 if datalist <> nil then begin
  tstatwriter(fitempo).writedatalist(getstatvarname,datalist);
  handled:= true;
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

function tstringclientcontroller.getgridvalues: msestringarty;
begin
 result:= nil;
 getvalar(@getmsestringvalar,result);
end;

procedure tstringclientcontroller.setgridvalues(const avalue: msestringarty);
begin
 setvalar(@setmsestringvalar,avalue);
end;

function tstringclientcontroller.getgridvalue(const index: integer): msestring;
begin
 result:= '';
 getitem(index,@getmsestringitem,result);
end;

procedure tstringclientcontroller.setgridvalue(const index: integer;
               const avalue: msestring);
begin
 setitem(index,@setmsestringitem,avalue);
end;

function tstringclientcontroller.getgriddata: tmsestringdatalist;
begin
 result:= tmsestringdatalist(getdatalist);
end;

procedure tstringclientcontroller.dostatread(const reader: tstatreader);
begin
 inherited;
 value:= reader.readmsestrings(valuevarname,value);
end;

procedure tstringclientcontroller.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 writer.writemsestrings(valuevarname,value);
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

function tintegerclientcontroller.getgridvalues: integerarty;
begin
 result:= nil;
 getvalar(@getintegervalar,result);
end;

procedure tintegerclientcontroller.setgridvalues(const avalue: integerarty);
begin
 setvalar(@setintegervalar,avalue);
end;

function tintegerclientcontroller.getgridvalue(const index: integer): integer;
begin
 result:= 0;
 getitem(index,@getintegeritem,result);
end;

procedure tintegerclientcontroller.setgridvalue(const index: integer;
               const avalue: integer);
begin
 setitem(index,@setintegeritem,avalue);
end;

function tintegerclientcontroller.getgriddata: tintegerdatalist;
begin
 result:= tintegerdatalist(getdatalist);
end;

procedure tintegerclientcontroller.dostatread(const reader: tstatreader);
begin
 inherited;
 value:= reader.readinteger(valuevarname,value);
end;

procedure tintegerclientcontroller.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 writer.writeinteger(valuevarname,value);
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

function tbooleanclientcontroller.getgridvalues: longboolarty;
begin
 result:= nil;
 getvalar(@getbooleanvalar,result);
end;

procedure tbooleanclientcontroller.setgridvalues(const avalue: longboolarty);
begin
 setvalar(@setbooleanvalar,avalue);
end;

function tbooleanclientcontroller.getgridvalue(const index: integer): boolean;
begin
 result:= false;
 getitem(index,@getbooleanitem,result);
end;

procedure tbooleanclientcontroller.setgridvalue(const index: integer;
               const avalue: boolean);
begin
 setitem(index,@setbooleanitem,avalue);
end;

function tbooleanclientcontroller.getgriddata: tintegerdatalist;
begin
 result:= tintegerdatalist(getdatalist);
end;

procedure tbooleanclientcontroller.dostatread(const reader: tstatreader);
begin
 inherited;
 value:= reader.readboolean(valuevarname,value);
end;

procedure tbooleanclientcontroller.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 writer.writeboolean(valuevarname,value);
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

function trealclientcontroller.getgridvalues: realarty;
begin
 result:= nil;
 getvalar(@getrealtyvalar,result);
end;

procedure trealclientcontroller.setgridvalues(const avalue: realarty);
begin
 setvalar(@setrealtyvalar,avalue);
end;

function trealclientcontroller.getgridvalue(const index: integer): real;
begin
 result:= emptyreal;
 getitem(index,@getrealtyitem,result);
end;

procedure trealclientcontroller.setgridvalue(const index: integer;
               const avalue: real);
begin
 setitem(index,@setrealtyitem,avalue);
end;

function trealclientcontroller.getgriddata: trealdatalist;
begin
 result:= trealdatalist(getdatalist);
end;

procedure trealclientcontroller.dostatread(const reader: tstatreader);
begin
 inherited;
 value:= reader.readreal(valuevarname,value);
end;

procedure trealclientcontroller.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 writer.writereal(valuevarname,value);
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

function tdatetimeclientcontroller.getgridvalues: datetimearty;
begin
 result:= nil;
 getvalar(@getdatetimevalar,result);
end;

procedure tdatetimeclientcontroller.setgridvalues(const avalue: datetimearty);
begin
 setvalar(@setdatetimevalar,avalue);
end;

function tdatetimeclientcontroller.getgridvalue(const index: integer): tdatetime;
begin
 result:= emptydatetime;
 getitem(index,@getdatetimeitem,result);
end;

procedure tdatetimeclientcontroller.setgridvalue(const index: integer;
               const avalue: tdatetime);
begin
 setitem(index,@setdatetimeitem,avalue);
end;

function tdatetimeclientcontroller.getgriddata: tdatetimedatalist;
begin
 result:= tdatetimedatalist(getdatalist);
end;

procedure tdatetimeclientcontroller.dostatread(const reader: tstatreader);
begin
 inherited;
 value:= reader.readreal(valuevarname,value);
end;

procedure tdatetimeclientcontroller.dostatwrite(const writer: tstatwriter);
begin
 inherited;
 writer.writereal(valuevarname,value);
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

{ tifilinkcomparrayprop }

constructor tifilinkcomparrayprop.create;
begin
 inherited create(tificolitem);
end;

class function tifilinkcomparrayprop.getitemclasstype: persistentclassty;
begin
 result:= tificolitem;
end;

function tifilinkcomparrayprop.getitems(const index: integer): tificolitem;
begin
 result:= tificolitem(inherited getitems(index));
end;

{ tgridclientcontroller }

constructor tgridclientcontroller.create(const aowner: tmsecomponent);
begin
 fdatacols:= tifilinkcomparrayprop.create;
 inherited;
end;

destructor tgridclientcontroller.destroy;
begin
 fdatacols.free;
 inherited;
end;

procedure tgridclientcontroller.statreadrowstate(const alink: pointer);
var
 list1: tcustomrowstatelist;
begin
 list1:= iifigridlink(alink).getrowstate;
 if list1 <> nil then begin
  tstatreader(fitempo).readdatalist(rowstatevarname,list1);
 end;
end;

procedure tgridclientcontroller.dostatread(const reader: tstatreader);
var
 int1: integer;
 lico: tifivaluelinkcomp;
begin
 inherited;
 fitempo:= reader;
 tmsecomponent1(fowner).getobjectlinker.forall(@statreadrowstate,self);
 for int1:= 0 to datacols.count - 1 do begin
  lico:= datacols[int1].link;
  if lico <> nil then begin
   with lico.controller do begin
    fitempo:= reader;
    tmsecomponent1(fowner).getobjectlinker.forall(@statreadlist,lico.controller); 
   end;
  end;
 end;
end;

procedure tgridclientcontroller.statwriterowstate(const alink: pointer;
                                           var handled: boolean);
var
 list1: tcustomrowstatelist;
begin
 list1:= iifigridlink(alink).getrowstate;
 if list1 <> nil then begin
  tstatwriter(fitempo).writedatalist(rowstatevarname,list1);
  handled:= true;
 end;
end;

procedure tgridclientcontroller.dostatwrite(const writer: tstatwriter);
var
 int1: integer;
 lico: tifivaluelinkcomp;
begin
 inherited;
 fitempo:= writer;
 tmsecomponent1(fowner).getobjectlinker.forfirst(@statwriterowstate,self);
 for int1:= 0 to datacols.count - 1 do begin
  lico:= datacols[int1].link;
  if lico <> nil then begin
   with lico.controller do begin
    fitempo:= writer;
    tmsecomponent1(fowner).getobjectlinker.forfirst(@statwritelist,lico.controller); 
   end;
  end;
 end;
end;

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

procedure tgridclientcontroller.docellevent(var info: ificelleventinfoty);
begin
 if fowner.canevent(tmethod(foncellevent)) then begin
  foncellevent(self,info);
 end;
end;

function tgridclientcontroller.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifigridlink);
end;

procedure tgridclientcontroller.setdatacols(const avalue: tifilinkcomparrayprop);
begin
 fdatacols.assign(avalue);
end;

procedure tgridclientcontroller.itemappendrow(const alink: pointer);
begin
 iifigridlink(alink).appendrow(fcheckautoappend);
end;

procedure tgridclientcontroller.getrowstate1(const alink: pointer;
                                                  var handled: boolean);
var
 list1: tcustomrowstatelist;
begin
 list1:= iifigridlink(alink).getrowstate;
 if list1 <> nil then begin
  handled:= true;
  pdatalist(fitempo)^:= list1;
 end;
end;

function tgridclientcontroller.getrowstate: tcustomrowstatelist;
begin
 result:= nil;
 fitempo:= @result;
 tmsecomponent1(fowner).getobjectlinker.forfirst(@getrowstate1,self);
end;

procedure tgridclientcontroller.appendrow(const avalues: array of const;
                                        const checkautoappend: boolean = false);
var
 int1,int2: integer;
 comp1: tifilinkcomp;
begin
 fcheckautoappend:= checkautoappend;
 tmsecomponent1(fowner).getobjectlinker.forall(@itemappendrow,self);
 int2:= high(avalues);
 if int2 >= datacols.count then begin
  int2:= datacols.count;
 end;
 for int1:= 0 to int2 do begin
  comp1:= tificolitem(fdatacols.fitems[int1]).link;
  if comp1 <> nil then begin
   with avalues[int1] do begin
    case vtype of
     vtstring: begin
      if comp1 is tifistringlinkcomp then begin
       tifistringlinkcomp(comp1).controller.gridvalue[maxint]:= vstring^;
      end;
     end;
     vtansistring: begin
      if comp1 is tifistringlinkcomp then begin
       tifistringlinkcomp(comp1).controller.gridvalue[maxint]:= ansistring(vansistring);
      end;
     end;
     vtwidestring: begin
      if comp1 is tifistringlinkcomp then begin
       tifistringlinkcomp(comp1).controller.gridvalue[maxint]:= widestring(vwidestring);
      end;
     end;
     vtpchar: begin
      if comp1 is tifistringlinkcomp then begin
       tifistringlinkcomp(comp1).controller.gridvalue[maxint]:= msestring(ansistring(vpchar));
      end;
     end;
     vtpwidechar: begin
      if comp1 is tifistringlinkcomp then begin
       tifistringlinkcomp(comp1).controller.gridvalue[maxint]:= msestring(vpwidechar);
      end;
     end;
     vtchar: begin
      if comp1 is tifistringlinkcomp then begin
       tifistringlinkcomp(comp1).controller.gridvalue[maxint]:= vchar;
      end;
     end;
     vtwidechar: begin
      if comp1 is tifistringlinkcomp then begin
       tifistringlinkcomp(comp1).controller.gridvalue[maxint]:= vwidechar;
      end;
     end;
     vtboolean: begin
      if comp1 is tifibooleanlinkcomp then begin
       tifibooleanlinkcomp(comp1).controller.gridvalue[maxint]:= vboolean;
      end;
     end;
     vtinteger: begin
      if comp1 is tifiintegerlinkcomp then begin
       tifiintegerlinkcomp(comp1).controller.gridvalue[maxint]:= vinteger;
      end;
     end;
     vtextended: begin
      if comp1 is tifireallinkcomp then begin
       tifireallinkcomp(comp1).controller.gridvalue[maxint]:= vextended^;
      end
      else begin
       if comp1 is tifidatetimelinkcomp then begin
        tifidatetimelinkcomp(comp1).controller.gridvalue[maxint]:= vextended^;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

{ tificolitem }

function tificolitem.getlink: tifivaluelinkcomp;
begin
 result:= tifivaluelinkcomp(item);
end;

procedure tificolitem.setlink(const avalue: tifivaluelinkcomp);
begin
 item:= avalue;
end;

{ tifivaluelinkcomp }

function tifivaluelinkcomp.getcontroller: tvalueclientcontroller;
begin
 result:= tvalueclientcontroller(fcontroller);
end;

end.
