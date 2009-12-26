unit mseificomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
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
 ifivaluelinkstatety = (ivs_linking);
 ifivaluelinkstatesty = set of ifivaluelinkstatety;
                              
 tifivaluewidgetcontroller = class(tlinkedpersistent,iifiserver)
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
   procedure sendmodalresult(const sender: iifiwidget; 
                             const amodalresult: modalresultty); virtual;
   procedure setcomponent(const acomponent: tmsecomponent; 
                                                 const aintf: iifiwidget);
   procedure updatestate; virtual;
   procedure loaded; virtual;
  public
   constructor create(const aowner: tmsecomponent; const akind: ttypekind);
   property kind: ttypekind read fkind;
  published
   property onvaluechanged: ifiwidgeteventty read fonvaluechanged 
                                                    write fonvaluechanged;
   property onstatechanged: ifiwidgetstateeventty read fonstatechanged 
                                                    write fonstatechanged;
   property onmodalresult: ifiwidgetmodalresulteventty read fonmodalresult 
                                                    write fonmodalresult;
   property widget: twidget read getwidget write setwidget;
 end;
 
 tifilinkcomp = class(tmsecomponent)
  private
   fcontroller: tifivaluewidgetcontroller;
   procedure setcontroller(const avalue: tifivaluewidgetcontroller);
  protected
   function gettypekind: ttypekind; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property controller: tifivaluewidgetcontroller read fcontroller 
                                                         write setcontroller;
 end;
 
 tifistringlinkcomp = class(tifilinkcomp)
  protected
   function gettypekind: ttypekind; override;
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

{ tifivaluewidgetcontroller}

constructor tifivaluewidgetcontroller.create(const aowner: tmsecomponent; 
                               const akind: ttypekind);
begin
 fowner:= aowner;
 fkind:= akind;
 inherited create;
end;

procedure tifivaluewidgetcontroller.setcomponent(const acomponent: tmsecomponent;
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
    if not (csloading in fowner.componentstate) then begin
     updatestate;
    end;
   end;
  finally
   exclude(fstate,ivs_linking);
  end;
 end;
end;

procedure tifivaluewidgetcontroller.valuechanged(const sender: iifiwidget);
begin
 if fowner.canevent(tmethod(fonvaluechanged)) then begin
  fonvaluechanged(self,sender);
 end;
end;

procedure tifivaluewidgetcontroller.statechanged(const sender: iifiwidget;
               const astate: ifiwidgetstatesty);
begin
 if fowner.canevent(tmethod(fonstatechanged)) then begin
  fonstatechanged(self,sender,astate);
 end;
end;

procedure tifivaluewidgetcontroller.sendmodalresult(const sender: iifiwidget;
               const amodalresult: modalresultty);
begin
 if fowner.canevent(tmethod(fonmodalresult)) then begin
  fonmodalresult(self,sender,amodalresult);
 end;
end;

procedure tifivaluewidgetcontroller.updatestate;
begin
 //dummy
end;

procedure tifivaluewidgetcontroller.loaded;
begin
 updatestate;
end;

function tifivaluewidgetcontroller.getwidget: twidget;
begin
 result:= twidget(fcomponent);
end;

procedure tifivaluewidgetcontroller.setwidget(const avalue: twidget);
var
 intf1: iifidatawidget;
begin
 intf1:= nil;
 if (avalue <> nil) and not getcorbainterface(avalue,typeinfo(iifidatawidget),intf1) then begin
  raise exception.create(avalue.name + ' is no IfI data widget.');
 end;
 setcomponent(avalue,intf1);
end;

{ tifilinkcomp }

constructor tifilinkcomp.create(aowner: tcomponent);
begin
 fcontroller:= tifivaluewidgetcontroller.create(self,gettypekind);
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

function tifilinkcomp.gettypekind: ttypekind;
begin
 result:= tkunknown;
end;

{ tifistringlinkcomp }

function tifistringlinkcomp.gettypekind: ttypekind;
begin
 result:= msestringtypekind;
end;

end.
