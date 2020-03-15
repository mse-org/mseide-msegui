{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedockpanelform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

uses
 classes,mclasses,mselist,msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,
 msestat,msemenus,msegui,msedatalist,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedock,
 msestrings,msestatfile;

const
 defaultdockpanelgripoptions = defaultgripoptions +
             [go_fixsizebutton,go_topbutton,go_backgroundbutton,go_lockbutton];
 defaultdockpaneloptionsdock = defaultoptionsdock +
       [od_canmove,od_canfloat,od_candock,od_acceptsdock,od_dockparent,
        od_splitvert,od_splithorz,od_tabed,od_proportional,od_propsize];
 defaultdockpanelwidth = 350;
 defaultdockpanelheight = 200;
 defaultdockpaneloptions =
                (defaultformoptions - [fo_autoreadstat,fo_autowritestat]) +
                [fo_globalshortcuts,fo_screencentered];
 defaultdockpaneloptionswidget =
                (defaultformwidgetoptions - [ow_destroywidgets]) +
                [ow_mousefocus,ow_arrowfocusin,ow_arrowfocusout];
 defaultdockstatprio = 256;
type
 tdockpanelformcontroller = class;
 tdockpanelform = class;

 tdockpanelformmenuitem = class(tmenuitem)
  private
   fpanel: tdockpanelform;
  public
   constructor create(const apanel: tdockpanelform);
   destructor destroy; override;
 end;

 tdockpanelformscrollbox = class(tdockformscrollbox)
  protected
   fdockingareacaption: msestring;
   procedure dopaintbackground(const canvas: tcanvas) override;
 end;

 tdockpanelform = class(tdockformwidget)
  private
   fmenuitem: tdockpanelformmenuitem;
   fnameindex: integer; //0 for unnumbered
   fcontroller: tdockpanelformcontroller;
   procedure showexecute(const sender: tobject);
   procedure setdockingareacaption(const avalue: msestring);
   function getdockingareacaption: msestring;
  protected
   procedure updatecaption(acaption: msestring);
   procedure dodockcaptionchanged(const sender: tdockcontroller); override;
   procedure dolayoutchanged(const sender: tdockcontroller); override;
   class function hasresource: boolean; override;
   class function getmoduleclassname: string; override;
//   constructor docreate(aowner: tcomponent); override;
   procedure docreate(aowner: tcomponent); override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure doonclose; override;
   function canclose(const newfocus: twidget): boolean; override;
  published
   property visible default false;
   property bounds_cx default defaultdockpanelwidth;
   property bounds_cy default defaultdockpanelheight;
   property options default defaultdockpaneloptions;
   property optionswidget default defaultdockpaneloptionswidget;
   property dockingareacaption: msestring read getdockingareacaption
                                                   write setdockingareacaption;
 end;

 panelfoclassty = class of tdockpanelform;

 dockpanelupdatecaptioneventty =
     procedure(const sender: tdockpanelformcontroller; const apanel: tdockpanelform;
                                  var avalue: msestring) of object;
 dockpanelupdatemenueventty =
     procedure(const sender: tdockpanelformcontroller; const apanel: tdockpanelform;
                                  const avalue: tmenuitem) of object;
 createpaneleventty =
     procedure(const sender: tdockpanelformcontroller;
                                  var apanel: tdockpanelform) of object;
{ getpanelclasseventty =
     procedure(const sender: tdockpanelcontroller;
                                  var aclass: panelfoclassty) of object;
}
 createdynamiccompeventty =
     procedure(const sender: tdockpanelformcontroller;
                  const aclassname: string;
                  const aname: string; var acomponent: tmsecomponent) of object;
 dynamiccompeventty = procedure(const sender: tdockpanelformcontroller;
                           const acomponent: tmsecomponent) of object;

 tdockpanelformcontroller = class(tmsecomponent,istatfile)
  private
   fpanellist: tpointerlist;
   fmenu: tcustommenu;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   fmenunamepath: string;
   fonupdatecaption: dockpanelupdatecaptioneventty;
   fonupdatemenu: dockpanelupdatemenueventty;
   fstatfileclient: tstatfile;
   foncreatepanel: createpaneleventty;
   foptionsdock: optionsdockty;
   foptionsgrip: gripoptionsty;
   fcaption: msestring;
   fstatfileclients: tstatfilearrayprop;
   fstatpriority: integer;
   fdockingareacaption: msestring;
   fdynamiccomps: msecomponentarty;
   foncreatedynamiccomp: createdynamiccompeventty;
   fonregisterdynamiccomp: dynamiccompeventty;
   fonunregisterdynamiccomp: dynamiccompeventty;
   procedure updatestat(const filer: tstatfiler);
   procedure setmenu(const avalue: tcustommenu);
//   procedure checkstatfile(const avalue: tstatfile; const ref: tstatfile);
   procedure setstatfile(const avalue: tstatfile);
   procedure setstatfileclient(const avalue: tstatfile);
   procedure setstatfileclients(const avalue: tstatfilearrayprop);
  protected
   procedure objectevent(const sender: tobject;
                                 const event: objecteventty) override;
    //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getstatpriority: integer;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function newpanel(aname: string = ''): tdockpanelform;
   procedure updatewindowcaptions(const avalue: msestring);
   procedure removepanels;
   function createdynamiccomp(const aclassname: string): tmsecomponent;
                                            //nil if not found
   function createdynamiccomp(
                 const aclass: msecomponentclassty): tmsecomponent;
   function createdynamicwidget(const aclass: widgetclassty): twidget;
   procedure registerdynamiccomp(const acomp: tmsecomponent);
   procedure unregisterdynamiccomp(const acomp: tmsecomponent);
   property dynamiccomps: msecomponentarty read fdynamiccomps;
  published
   property menu: tcustommenu read fmenu write setmenu;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority
               write fstatpriority default defaultdockstatprio;
   property statfileclients: tstatfilearrayprop read fstatfileclients
                   write setstatfileclients; //called before statfileclient
   property statfileclient: tstatfile read fstatfileclient
                         write setstatfileclient; //last called

   property menunamepath: string read fmenunamepath write fmenunamepath;
                      //delimiter = '.'
   property caption: msestring read fcaption write fcaption;
   property dockingareacaption: msestring read fdockingareacaption
                                                   write fdockingareacaption;
   property optionsdock: optionsdockty read foptionsdock
                   write foptionsdock default defaultdockpaneloptionsdock;
   property optionsgrip: gripoptionsty read foptionsgrip
                   write foptionsgrip default defaultdockpanelgripoptions;
   property onupdatecaption: dockpanelupdatecaptioneventty
                     read fonupdatecaption write fonupdatecaption;
   property onupdatemenu: dockpanelupdatemenueventty
                     read fonupdatemenu write fonupdatemenu;
   property oncreatepanel: createpaneleventty read foncreatepanel
                                                      write foncreatepanel;
   property oncreatedynamiccomp: createdynamiccompeventty
                       read foncreatedynamiccomp write foncreatedynamiccomp;
   property onregisterdynamiccomp: dynamiccompeventty
           read fonregisterdynamiccomp write fonregisterdynamiccomp;
   property onunregisterdynamiccomp: dynamiccompeventty
           read fonunregisterdynamiccomp write fonunregisterdynamiccomp;
 end;

function createdockpanelform(const aclass: tclass;
                    const aclassname: pshortstring): tmsecomponent;

implementation
uses
 {msedockpanelform_mfm,}sysutils,msekeyboard,mseactions,msearrayutils,
 mseformatstr;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 tcomponent1 = class(tcomponent);
 tmsecomponent1 = class(tmsecomponent);

 pdockpanelform = ^tdockpanelform;

 tpanelformdockcontroller = class(tformdockcontroller)
  public
   constructor create(const aowner: tcustomdockform);
//   constructor create(aintf: idockcontroller);
  published
   property optionsdock default defaultoptionsdock;
 end;

function createdockpanelform(const aclass: tclass;
                    const aclassname: pshortstring): tmsecomponent;

begin
 result:= tmsecomponent(aclass.newinstance);
{$warnings off}
 tcomponent1(result).setdesigning(true); //used for wo_groupleader
{$warnings on}
 tdockpanelform(result).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

{ tdockpanelformcontroller }

constructor tdockpanelformcontroller.create(aowner: tcomponent);
begin
 fstatpriority:= defaultdockstatprio;
 foptionsdock:= defaultdockpaneloptionsdock;
 foptionsgrip:= defaultdockpanelgripoptions;
// fcaption:= 'Panel';
 fpanellist:= tpointerlist.create;
 fstatfileclients:= tstatfilearrayprop.create;
 inherited;
end;

destructor tdockpanelformcontroller.destroy;
var
 i1: int32;
begin
 for i1:= high(fdynamiccomps) downto 0 do begin
  ievent(fdynamiccomps[i1]).unlink(ievent(self),
                                        ievent(fdynamiccomps[i1]));
 end;
 fdynamiccomps:= nil;
 inherited;
 freeandnil(fpanellist);
 fstatfileclients.free;
end;

procedure tdockpanelformcontroller.updatestat(const filer: tstatfiler);
var
 ar1,ar2,ar3: msestringarty;
 i1: integer;
 comp1: tmsecomponent;
begin
 ar1:= nil;
 if filer.iswriter then begin
  setlength(ar1,fpanellist.count);
  for i1:= 0 to high(ar1) do begin
   ar1[i1]:= msestring(tdockpanelform(fpanellist[i1]).name);
  end;
  setlength(ar2,length(fdynamiccomps));
  for i1:= 0 to high(ar2) do begin
   ar2[i1]:= msestring(fdynamiccomps[i1].classname+','+fdynamiccomps[i1].name);
  end;
 end;
 filer.updatevalue('panels',ar1);
 filer.updatevalue('dynamiccomps',ar2);
 if not filer.iswriter then begin
  if canevent(tmethod(foncreatedynamiccomp)) then begin
   for i1:= 0 to high(ar2) do begin
    ar3:= splitstring(ar2[i1],',');
    if high(ar3) > 0 then begin
     comp1:= nil;
     foncreatedynamiccomp(self,string(ar3[0]),string(ar3[1]),comp1);
     if comp1 <> nil then begin
      comp1.name:= string(ar3[1]);
      registerdynamiccomp(comp1);
     end;
    end;
   end;
  end;
  for i1:= fpanellist.count - 1 downto 0 do begin
   tdockpanelform(fpanellist[i1]).free;
  end;
  for i1:= 0 to high(ar1) do begin
   try
    with newpanel(ansistring(ar1[i1])) do begin
     if statfile = self.statfile then begin
      statreading();
     end;
    end;
   except
   end;
  end;
 end;
 with fstatfileclients do begin
  for i1:= 0 to count - 1 do begin
   with items[i1] do begin
    if (statfile <> nil) and (statfile <> fstatfile) then begin
     statfile.updatestat('client_'+inttostrmse(i1),filer);
    end;
   end;
  end;
 end;
 if (fstatfileclient <> nil) and (fstatfile <> fstatfileclient) then begin
  fstatfileclient.updatestat('clients',filer);
 end;
end;

function tdockpanelformcontroller.newpanel(aname: string = ''): tdockpanelform;
var
 item1: tmenuitem;
 int1,int2: integer;
 ar1: integerarty;
begin
 result:= nil;
 item1:= nil;
 int2:= 0;
 if fmenu <> nil then begin
  if fmenunamepath <> '' then begin
   item1:= fmenu.menu.itembynames(splitstring(fmenunamepath,'.'));
  end;
 end;
 if aname = '' then begin
  setlength(ar1,fpanellist.count);
  for int1:= 0 to high(ar1) do begin
   ar1[int1]:= tdockpanelform(fpanellist[int1]).fnameindex;
  end;
  sortarray(ar1);
  int2:= length(ar1);
  for int1:= 0 to high(ar1) do begin //find first gap
   if ar1[int1] <> int1 then begin
    int2:= int1;
    break;
   end;
  end;
 end
 else begin
  int2:= strtoint(copy(aname,6,bigint))-1;
 end;

 if canevent(tmethod(foncreatepanel)) then begin
  foncreatepanel(self,result);
 end;
 if result = nil then begin
  result:= tdockpanelform.create(self);
  with result do begin
   createframe;
   dragdock.optionsdock:= defaultdockpaneloptionsdock;
   frame.grip_options:= defaultdockpanelgripoptions;
   dragdock.optionsdock:= foptionsdock;
   frame.grip_options:= foptionsgrip;
   container.frame.framei:= nullframe;
   statfile:= self.fstatfileclient;
  end;
 end;

 int1:= int2 + 1;
 if aname = '' then begin
  aname:= 'panel'+inttostr(int1);
 end;
 with result do begin
  name:= aname;
  fnameindex:= int2;
  if dockingareacaption = '' then begin
   dockingareacaption:= self.dockingareacaption;
  end;
  if item1 <> nil then begin
   tdockpanelformmenuitem.create(result);
//   fmenuitem:= tmenuitem.create(nil,nil);
  end;
  updatecaption('');
 end;
 if item1 <> nil then begin
  if int2 >= fpanellist.count then begin
   int2:= fpanellist.count-1;
  end;
  if int2 > item1.count - 2 then begin
   int2:= item1.count - 2;
  end;
  if int2 < 0 then begin
   int2:= 0;
  end;
  item1.submenu.insert(int2,result.fmenuitem);
 end;
end;

procedure tdockpanelformcontroller.setmenu(const avalue: tcustommenu);
begin
 setlinkedvar(avalue,tmsecomponent(fmenu));
end;
{
procedure tdockpanelformcontroller.checkstatfile(
             const avalue: tstatfile; const ref: tstatfile);
begin
 if (avalue <> nil) and (avalue = ref) then begin
  raise exception.create(self.name+':Invalid statfile '+avalue.name+'.');
 end;
end;
}
procedure tdockpanelformcontroller.setstatfile(const avalue: tstatfile);
begin
// checkstatfile(avalue,fstatfileclient);
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

procedure tdockpanelformcontroller.dostatread(const reader: tstatreader);
begin
 updatestat(reader);
end;

procedure tdockpanelformcontroller.dostatwrite(const writer: tstatwriter);
begin
 updatestat(writer);
end;

procedure tdockpanelformcontroller.statreading;
begin
 while high(fdynamiccomps) >= 0 do begin
  fdynamiccomps[high(fdynamiccomps)].destroy();
 end;
end;

procedure tdockpanelformcontroller.statread;
begin
 //dummy
end;

function tdockpanelformcontroller.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tdockpanelformcontroller.setstatfileclient(const avalue: tstatfile);
begin
// checkstatfile(avalue,fstatfile);
 setlinkedvar(avalue,tmsecomponent(fstatfileclient));
end;

procedure tdockpanelformcontroller.updatewindowcaptions(const avalue: msestring);
var
 po1: pdockpanelform;
 int1: integer;
begin
 with fpanellist do begin
  po1:= pointer(datapo);
  for int1:= 0 to count - 1 do begin
   po1^.caption:= avalue;
   inc(po1);
  end;
 end;
end;

procedure tdockpanelformcontroller.setstatfileclients(
                                     const avalue: tstatfilearrayprop);
begin
 fstatfileclients.assign(avalue);
end;

procedure tdockpanelformcontroller.removepanels;
begin
 while fpanellist.count > 0 do begin
  tobject(fpanellist.items[fpanellist.count-1]).free;
 end;
end;

function tdockpanelformcontroller.createdynamiccomp(
                                  const aclassname: string): tmsecomponent;
var
 cla1: tpersistentclass;
begin
 result:= nil;
 cla1:= getclass(aclassname);
 if cla1.inheritsfrom(tmsecomponent) then begin
  application.createdatamodule(msecomponentclassty(cla1),result);
//  result:= msecomponentclassty(cla1).create(nil);
 end;
end;

function tdockpanelformcontroller.createdynamiccomp(
              const aclass: msecomponentclassty): tmsecomponent;
begin
 application.createdatamodule(aclass,result);
 registerdynamiccomp(result);
end;

function tdockpanelformcontroller.createdynamicwidget(
                                   const aclass: widgetclassty): twidget;
begin
 application.createform(aclass,result);
 registerdynamiccomp(result);
end;

procedure tdockpanelformcontroller.objectevent(const sender: tobject;
               const event: objecteventty);
var
 i1: int32;
begin
 if event = oe_destroyed then begin
  for i1:= high(fdynamiccomps) downto 0 do begin
   if fdynamiccomps[i1] = sender then begin
    deleteitem(pointerarty(fdynamiccomps),i1);
    if canevent(tmethod(fonunregisterdynamiccomp)) then begin
     fonunregisterdynamiccomp(self,tmsecomponent(sender));
    end;
    break;
   end;
  end;
 end;
 inherited;
end;

procedure tdockpanelformcontroller.registerdynamiccomp(
                                               const acomp: tmsecomponent);
var
 i1: int32;
begin
 for i1:= 0 to high(fdynamiccomps) do begin
  if fdynamiccomps[i1] = acomp then begin
   exit;
  end;
 end;
 setlength(fdynamiccomps,high(fdynamiccomps)+2);
 fdynamiccomps[high(fdynamiccomps)]:= acomp;
 ievent(acomp).link(ievent(self),ievent(acomp));
 if canevent(tmethod(fonregisterdynamiccomp)) then begin
  fonregisterdynamiccomp(self,acomp);
 end;
end;

procedure tdockpanelformcontroller.unregisterdynamiccomp(
              const acomp: tmsecomponent);
var
 i1: int32;
begin
 for i1:= high(fdynamiccomps) downto 0 do begin
  if fdynamiccomps[i1] = acomp then begin
   ievent(fdynamiccomps[i1]).unlink(ievent(self),
                                        ievent(fdynamiccomps[i1]));
   deleteitem(pointerarty(fdynamiccomps),i1);
   if canevent(tmethod(fonunregisterdynamiccomp)) then begin
    fonunregisterdynamiccomp(self,acomp);
   end;
   exit;
  end;
 end;
end;

function tdockpanelformcontroller.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

{ tdockpanelformmenuitem }

constructor tdockpanelformmenuitem.create(const apanel: tdockpanelform);
begin
 inherited create(nil,nil);
 fpanel:= apanel;
 apanel.fmenuitem:= self;
end;

destructor tdockpanelformmenuitem.destroy;
begin
 if fpanel <> nil then begin
  fpanel.fmenuitem:= nil;
 end;
 inherited;
end;

{ tdockpanelform }

constructor tdockpanelform.create(aowner: tcomponent);
begin
 if aowner is tdockpanelformcontroller then begin
  setlinkedvar(tmsecomponent(aowner),tmsecomponent(fcontroller));
 end;
 inherited;
end;

constructor tdockpanelform.create(aowner: tcomponent; load: boolean);
begin
 if fdragdock = nil then begin
//  fdragdock:= tpanelformdockcontroller.create(idockcontroller(self));
  fdragdock:= tpanelformdockcontroller.create(self);
 end;
 include(fmsecomponentstate,cs_ismodule);
 fscrollbox:= tdockpanelformscrollbox.create(self);
 inherited;
end;

//constructor tdockpanelform.docreate(aowner: tcomponent);
procedure tdockpanelform.docreate(aowner: tcomponent);
begin
 inherited;
 visible:= false;
 options:= defaultdockpaneloptions;
 optionswidget:= defaultdockpaneloptionswidget;
 {
 createframe;
 options:= (options - [fo_autoreadstat,fo_autowritestat]) +
                      [fo_globalshortcuts,fo_screencentered];
 optionswidget:= (optionswidget - [ow_destroywidgets]) +
                  [ow_mousefocus,ow_arrowfocusin,ow_arrowfocusout];
 dragdock.optionsdock:= defaultdockpaneloptionsdock;
 frame.grip_options:= defaultdockpanelgripoptions;
 }
 size:= makesize(defaultdockpanelwidth,defaultdockpanelheight);
 if fcontroller <> nil then begin
  statfile:= fcontroller.statfileclient;
  fcontroller.fpanellist.add(self);
 end;
end;

destructor tdockpanelform.destroy;
begin
 if fcontroller <> nil then begin
  with fcontroller do begin
   if fpanellist <> nil then begin
    fpanellist.remove(self);
   end;
   if (fmenuitem <> nil) then begin
    if (fmenuitem.owner <> nil) and
             not (csdestroying in fmenuitem.owner.componentstate) then begin
     fmenuitem.parentmenu.submenu.delete(fmenuitem.index);
    end
    else begin
     fmenuitem.fpanel:= nil;
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tdockpanelform.updatecaption(acaption: msestring);
var
 menucapt: msestring;
begin
 if acaption = '' then begin
  if fcontroller <> nil then begin
   acaption:= fcontroller.caption;
  end;
 end;
 if fmenuitem <> nil then begin
  menucapt:= acaption;
  with fmenuitem do begin
   onexecute:= {$ifdef FPC}@{$endif}showexecute;
   if fnameindex < 9 then begin
    shortcut:= (ord(key_f1) or key_modctrl) + fnameindex;
    if menucapt <> '' then begin
     menucapt:= acaption + ' ';
    end;
    menucapt:= menucapt + '&' + inttostrmse(fnameindex+1);
   end
   else begin
    shortcut:= 0;
   end;
   caption:= menucapt;
   if (fcontroller <> nil) and
                  fcontroller.canevent(tmethod(fcontroller.fonupdatemenu)) then begin
    fcontroller.fonupdatemenu(fcontroller,self,fmenuitem);
   end;
   if shortcut <> 0 then begin
    acaption:= acaption + ' ('+encodeshortcutname(shortcut)+')';
   end;
  end;
 end
 else begin
  acaption:= acaption+' '+inttostrmse(fnameindex+1);
 end;
 if (fcontroller <> nil) and
           fcontroller.canevent(tmethod(fcontroller.fonupdatecaption)) then begin
  fcontroller.fonupdatecaption(fcontroller,self,acaption);
 end;
 dragdock.caption:= acaption;
end;

procedure tdockpanelform.showexecute(const sender: tobject);
begin
 activate;
end;

function tdockpanelform.canclose(const newfocus: twidget): boolean;

 function containerempty: boolean;
 var
  int1: integer;
 begin
  result:= container.widgetcount = 0;
  if not result then begin
   for int1:= 0 to container.widgetcount - 1 do begin
    if container.widgets[int1].visible then begin
     exit;
    end;
   end;
  end;
  result:= true;
 end;

begin
 result:= inherited canclose(newfocus);
 {
 if result and (newfocus = nil) and containerempty then begin
  release;
 end;
 }
end;

procedure tdockpanelform.doonclose;
 function containerempty: boolean;
 var
  int1: integer;
 begin
  result:= container.widgetcount = 0;
  if not result then begin
   for int1:= 0 to container.widgetcount - 1 do begin
    if container.widgets[int1].visible then begin
     exit;
    end;
   end;
  end;
  result:= true;
 end;
begin
 inherited;
 if containerempty and not (csdesigning in componentstate) then begin
  release;
 end;
end;

procedure tdockpanelform.dodockcaptionchanged(const sender: tdockcontroller);
var
 intf1: idocktarget;
 mstr1: msestring;
 int1: integer;
 ar1: widgetarty;
begin
 mstr1:= '';
 ar1:= sender.getitems;
 for int1:= 0 to high(ar1) do begin
  if ar1[int1].getcorbainterface(typeinfo(idocktarget),intf1) then begin
   mstr1:= mstr1 + intf1.getdockcontroller.getdockcaption+',';
  end;
 end;
 updatecaption(copy(mstr1,1,length(mstr1)-1)); //remove last comma
end;

procedure tdockpanelform.dolayoutchanged(const sender: tdockcontroller);
begin
 dodockcaptionchanged(sender);
end;

{
procedure tdockpanelform.dolayoutchanged(const sender: tdockcontroller);
var
 intf1: idocktarget;
 mstr1: msestring;
 int1: integer;
 ar1: widgetarty;
begin
 mstr1:= '';
 ar1:= sender.getitems;
 for int1:= 0 to high(ar1) do begin
  if ar1[int1].getcorbainterface(typeinfo(idocktarget),intf1) then begin
   mstr1:= mstr1 + intf1.getdockcontroller.getdockcaption+',';
  end;
 end;
 updatecaption(copy(mstr1,1,length(mstr1)-1)); //remove last comma
end;
}

class function tdockpanelform.hasresource: boolean;
begin
 result:= self <> tdockpanelform;
end;

class function tdockpanelform.getmoduleclassname: string;
begin
 result:= 'tdockpanelform';
end;

procedure tdockpanelform.setdockingareacaption(const avalue: msestring);
begin
 with tdockpanelformscrollbox(fscrollbox) do begin
  fdockingareacaption:= avalue;
  invalidate;
 end;
end;

function tdockpanelform.getdockingareacaption: msestring;
begin
 result:= tdockpanelformscrollbox(fscrollbox).fdockingareacaption;
end;

{ tpanelformdockcontroller }

constructor tpanelformdockcontroller.create(const aowner: tcustomdockform);
//constructor tpanelformdockcontroller.create(aintf: idockcontroller);
begin
 inherited;
 foptionsdock:= defaultoptionsdock;
end;

{ tdockpanelformscrollbox }

procedure tdockpanelformscrollbox.dopaintbackground(const canvas: tcanvas);
begin
 inherited;
 if fdockingareacaption <> '' then begin
  paintdockingareacaption(canvas,self,fdockingareacaption);
 end;
end;

end.
