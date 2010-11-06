unit msedockpanelform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mselist,msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,
 msemenus,msegui,msedatalist,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msedock,
 msestrings,msestatfile;

type
 tdockpanelcontroller = class;
 
 tpanelfo = class(tdockform)
   procedure onclo(const sender: TObject);
   procedure panellayoutchanged(const sender: tdockcontroller);
  private
   fmenuitem: tmenuitem;
   fnameindex: integer; //0 for unnumbered
   procedure showexecute(const sender: tobject);
  protected
   procedure updatecaption(acaption: msestring);
  public
   constructor create(const aowner: tdockpanelcontroller); reintroduce;
   destructor destroy; override;
   function canclose(const newfocus: twidget): boolean; override;
 end;

 tdockpanelcontroller = class(tmsecomponent,istatfile)
  private
   fpanellist: tpointerlist;
   fmenu: tcustommenu;
   fstatfile: tstatfile;
   fstatvarname: msestring;
   procedure updatestat(const filer: tstatfiler);
   procedure setmenu(const avalue: tcustommenu);
   procedure setstatfile(const avalue: tstatfile);
  protected
    //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function newpanel(aname: string = ''): tpanelfo;
  published
   property menu: tcustommenu read fmenu write setmenu;
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
 end;
 
implementation
uses
 msedockpanelform_mfm,sysutils,msekeyboard;

constructor tdockpanelcontroller.create(aowner: tcomponent);
begin
 fpanellist:= tpointerlist.create;
 inherited;
end;

destructor tdockpanelcontroller.destroy;
begin
 inherited;
 freeandnil(fpanellist);
end;

procedure tdockpanelcontroller.updatestat(const filer: tstatfiler);
var
 ar1: msestringarty;
 int1: integer;
begin
 ar1:= nil;
 if filer.iswriter then begin
  setlength(ar1,fpanellist.count);
  for int1:= 0 to high(ar1) do begin
   ar1[int1]:= tpanelfo(fpanellist[int1]).name;
  end;
 end;
 filer.updatevalue('panels',ar1);
 if not filer.iswriter then begin
  for int1:= fpanellist.count - 1 downto 0 do begin
   tpanelfo(fpanellist[int1]).free;
  end;
  for int1:= 0 to high(ar1) do begin
   try
    newpanel(ar1[int1]);
   except
   end;
  end;
 end;
end;

function tdockpanelcontroller.newpanel(aname: string = ''): tpanelfo;
var
 item1: tmenuitem;
 int1,int2: integer;
 ar1: integerarty;
begin
 item1:= nil;
 int2:= 0;
 if fmenu <> nil then begin
  item1:= fmenu.menu.itembyname('view');
  if item1 <> nil then begin
   item1:= item1.itembyname('panels');
  end;
  if aname = '' then begin
   setlength(ar1,fpanellist.count);
   for int1:= 0 to high(ar1) do begin
    ar1[int1]:= tpanelfo(fpanellist[int1]).fnameindex;
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
 end;
 result:= tpanelfo.create(self);
 int1:= int2 + 1;
 if aname = '' then begin
  aname:= 'panel'+inttostr(int1);
 end;
 with result do begin
  name:= aname;
  fnameindex:= int2;
  if item1 <> nil then begin
   fmenuitem:= tmenuitem.create(nil,nil);
  end;
  updatecaption('');
 end;
 if int2 > item1.count - 2 then begin
  int2:= item1.count - 2;
 end;
 if item1 <> nil then begin
  item1.submenu.insert(int2,result.fmenuitem);
 end;
end;

procedure tdockpanelcontroller.setmenu(const avalue: tcustommenu);
begin
 setlinkedvar(avalue,tmsecomponent(fmenu));
end;

procedure tdockpanelcontroller.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

procedure tdockpanelcontroller.dostatread(const reader: tstatreader);
begin
 updatestat(reader);
end;

procedure tdockpanelcontroller.dostatwrite(const writer: tstatwriter);
begin
 updatestat(writer);
end;

procedure tdockpanelcontroller.statreading;
begin
end;

procedure tdockpanelcontroller.statread;
begin
end;

function tdockpanelcontroller.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

{ tpanelfo }

constructor tpanelfo.create(const aowner: tdockpanelcontroller);
begin
 inherited create(aowner);
 statfile:= aowner.statfile;
 aowner.fpanellist.add(self);
end;

destructor tpanelfo.destroy;
begin
 with tdockpanelcontroller(owner) do begin
  if fpanellist <> nil then begin
   fpanellist.remove(self);
  end;
  if (fmenuitem <> nil) and (fmenuitem.owner <> nil) and 
            not (csdestroying in fmenuitem.owner.componentstate) then begin
   fmenuitem.parentmenu.submenu.delete(fmenuitem.index);
  end;
 end;
 inherited;
end;

procedure tpanelfo.updatecaption(acaption: msestring);

begin
 if acaption = '' then begin
  acaption:= 'Panel';
 end;
 with fmenuitem do begin
  onexecute:= {$ifdef FPC}@{$endif}showexecute;
  if fnameindex < 9 then begin
   shortcut:= (ord(key_f1) or key_modctrl) + fnameindex;
   caption:= acaption + ' &' + inttostr(fnameindex+1);
  end
  else begin
   shortcut:= 0;
   caption:= acaption;
  end;
  if shortcut <> 0 then begin
   acaption:= acaption + ' (Ctrl+F' + inttostr(fnameindex+1)+')';
  end;
  self.caption:= acaption;
 end;
end;

procedure tpanelfo.showexecute(const sender: tobject);
begin
 activate;
end;

function tpanelfo.canclose(const newfocus: twidget): boolean;

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

procedure tpanelfo.onclo(const sender: TObject);
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
 if containerempty then begin
  release;
 end;
end;

procedure tpanelfo.panellayoutchanged(const sender: tdockcontroller);
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

end.
