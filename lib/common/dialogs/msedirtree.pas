{ MSEgui Copyright (c) 1999-2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msedirtree;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msewidgetgrid,mselistbrowser,msedatanodes,msefileutils,
 msetypes,msestrings,msegui,mseglob,
 mseclasses,msegrids,msesys,msegridsglob;
type

 tdirlistitem = class(ttreelistedititem)
  private
   finfo: fileinfoty;                                           
  protected
   flistonly: boolean;
   procedure updateinfo;
  public
   constructor create(const aowner: tcustomitemlist = nil;
              const aparent: ttreelistitem = nil); override;
   procedure setentries(const list: tcustomfiledatalist;
                        const checksubdirectories,showhidden,checkbox: boolean);
   function findsubdir(const aname: filenamety): tdirlistitem;
   function getpath: filenamety;
 end;

 dirlistitemarty = array of tdirlistitem;
 
 dirtreeoptionty = (dto_casesensitive,dto_showhiddenfiles,
                                              dto_checksubdir,dto_checkbox);
 dirtreeoptionsty = set of dirtreeoptionty;
 
 tdirtreefo = class(tmseform)
   grid: twidgetgrid;
   treeitem: ttreeitemedit;
   procedure treeitemoncreateitem(const sender: tcustomitemlist;
                     var item: ttreelistedititem); virtual;
   procedure treeitemonitemnotification(const sender: tlistitem;
                 var action: nodeactionty); virtual;
   procedure treeitemondataentered(const sender: tobject); virtual;
   procedure treeitemoncellevent(const sender: tobject;
                 var info: celleventinfoty); virtual;
  private
//   fshowhiddenfiles: boolean;
//   fcasesensitive: boolean;
//   fpath: filenamety;
   fonpathchanged: notifyeventty;
//   fchecksubdir: boolean;
   foptions: dirtreeoptionsty;
//   fchecksubdir: boolean;
   procedure setpath(const avalue: filenamety);
   function getpath: filenamety;
   procedure adddir(const aitem: tdirlistitem);
   function getshowhiddenfiles: boolean;
   procedure setshowhiddenfiles(const avalue: boolean);
   function getcasesensitive: boolean;
   procedure setcasesensitive(const avalue: boolean);
   function getchecksubdir: boolean;
   procedure setchecksubdir(const avalue: boolean);
   procedure setroot(const avalue: filenamety);
  protected
   fpath: filenamety;
   froot: filenamety;
   procedure updatepath();
  public
   function getcheckednodes(const amode: getnodemodety = 
                                    gno_nochildren): dirlistitemarty;
   function getcheckedfilenames(const amode: getnodemodety = 
                                    gno_nochildren): filenamearty;
   property casesensitive: boolean read getcasesensitive write setcasesensitive;
   property showhiddenfiles: boolean read getshowhiddenfiles 
                                                   write setshowhiddenfiles;
   property checksubdir: boolean read getchecksubdir write setchecksubdir;
   property path: filenamety read getpath write setpath;
   property root: filenamety read froot write setroot;
   property options: dirtreeoptionsty read foptions write foptions default [];
   property onpathchanged: notifyeventty read fonpathchanged write fonpathchanged;
 end;
{
 tdiredit = class(tstringedit)
  private
 end;
}
//var
// dirtreefo: tdirtreefo;

implementation
uses
 msedirtree_mfm,msesysintf,mseeditglob,msefiledialog,msebitmap,mseevent,
 mseguiglob,classes,mclasses;

{ tdirlistitem }

constructor tdirlistitem.create(const aowner: tcustomitemlist;
  const aparent: ttreelistitem);
begin
 inherited;
 include(fstate,ns_subitems);
end;

function tdirlistitem.getpath: filenamety;
begin
 if fparent = nil then begin
  result:= fcaption;
 end
 else begin
  result:= copy(concatstrings(rootcaptions,'/'),2,bigint);
 end;
end;

procedure tdirlistitem.updateinfo;
begin
 updatefileinfo(self,finfo,true);
end;

procedure tdirlistitem.setentries(const list: tcustomfiledatalist;
                     const checksubdirectories,showhidden,checkbox: boolean);
var
 po1: pfileinfoty;
 ar1: treelistedititemarty;
 int1: integer;
 item1: tdirlistitem;
// dirstream: dirstreamty;
 excl: fileattributesty;
begin
 clear;
 if list <> nil then begin
  po1:= list.datapo;
  if showhidden then begin
   excl:= [];
  end
  else begin
   excl:= [fa_hidden];
  end;
  setlength(ar1,list.count);
  for int1:= 0 to list.count - 1 do begin
   item1:= tdirlistitem.create;
   if checkbox then begin
    item1.fstate:= item1.fstate + [ns_checkbox,ns_showchildchecked];
   end;
   ar1[int1]:= item1;
   item1.finfo:= po1^;
   item1.updateinfo;
   if checksubdirectories and (item1.finfo.extinfo1.filetype = ft_dir) then begin
    if dirhasentries(getpath+'/'+item1.finfo.name,[fa_dir],excl) then begin
     include(item1.fstate,ns_subitems);
    end
    else begin
     exclude(item1.fstate,ns_subitems);
    end;
   end;
   inc(po1);
  end;
  add(ar1);
 end;
end;

function tdirlistitem.findsubdir(const aname: filenamety): tdirlistitem;
begin
 result:= tdirlistitem(finditembycaption(aname,true));
 if (result = nil) and sys_filesystemiscaseinsensitive then begin
  result:= tdirlistitem(finditembycaption(aname,false));
 end;
end;

{ tdirtreefo }

procedure tdirtreefo.adddir(const aitem: tdirlistitem);
var
 list: tcustomfiledatalist;
 exclude: fileattributesty;
begin
 list:= tcustomfiledatalist.create;
 try
  if casesensitive then begin
   list.options:= [flo_sortname,flo_casesensitive];
  end
  else begin
   list.options:= [flo_sortname];
  end;
  if showhiddenfiles then begin
   exclude:= [];
  end
  else begin
   exclude:= [fa_hidden];
  end;
  list.adddirectory(aitem.getpath,fil_name,nil,[fa_dir],exclude);
  aitem.setentries(list,checksubdir,showhiddenfiles,dto_checkbox in foptions);
 finally
  list.free;
 end;
end;

function tdirtreefo.getshowhiddenfiles: boolean;
begin
 result:= dto_showhiddenfiles in foptions;
end;

procedure tdirtreefo.setshowhiddenfiles(const avalue: boolean);
begin
 if avalue then begin
  include(foptions,dto_showhiddenfiles);
 end
 else begin
  exclude(foptions,dto_showhiddenfiles);
 end;
end;

function tdirtreefo.getcasesensitive: boolean;
begin
 result:= dto_casesensitive in foptions;
end;

procedure tdirtreefo.setcasesensitive(const avalue: boolean);
begin
 if avalue then begin
  include(foptions,dto_casesensitive);
 end
 else begin
  exclude(foptions,dto_casesensitive);
 end;
end;

function tdirtreefo.getchecksubdir: boolean;
begin
 result:= dto_checksubdir in foptions;
end;

procedure tdirtreefo.setchecksubdir(const avalue: boolean);
begin
 if avalue then begin
  include(foptions,dto_checksubdir);
 end
 else begin
  exclude(foptions,dto_checksubdir);
 end;
end;

procedure tdirtreefo.setroot(const avalue: filenamety);
begin
 froot:= avalue;
 updatepath();
end;

function tdirtreefo.getcheckednodes(const amode: getnodemodety = 
                                    gno_nochildren): dirlistitemarty;
begin
 result:= dirlistitemarty(treeitem.itemlist.getcheckednodes(amode));
end;

function tdirtreefo.getcheckedfilenames(const amode: getnodemodety = 
                                    gno_nochildren): filenamearty;
var
 ar1: dirlistitemarty;
 int1: integer;
begin
 ar1:= getcheckednodes(amode);
 setlength(result,length(ar1));
 for int1:= 0 to high(ar1) do begin
  result[int1]:= ar1[int1].getpath;
 end;
end;

function tdirtreefo.getpath: filenamety;
begin
 if treeitem.item = nil then begin
  result:= '';
 end
 else begin
  result:= filepath(tdirlistitem(treeitem.item).getpath,fk_dir);
 end;
end;

procedure tdirtreefo.updatepath();
var
 ar1: msestringarty;
 int1: integer;
 aitem,item1: tdirlistitem;
 {$ifdef mswindows}
 uncitem: tdirlistitem;
 {$endif}
 avalue: filenamety;
begin
 avalue:= fpath;
 if dto_checkbox in foptions then begin
  treeitem.itemlist.options:= treeitem.itemlist.options + 
                                         [no_checkbox,no_updatechildchecked];
 end
 else begin
  treeitem.itemlist.options:= treeitem.itemlist.options - 
                                         [no_checkbox,no_updatechildchecked];
 end;
 treeitem.itemlist.clear;
 treeitem.itemlist.count:= 1;
 aitem:= tdirlistitem(treeitem.itemlist[0]);
 int1:= 0;
 if froot = '' then begin
  ar1:= splitrootpath(avalue);
  {$ifdef mswindows}
  treeitem.itemlist.count:= 2;
  uncitem:= tdirlistitem(treeitem.itemlist[1]);
  initdirfileinfo(uncitem.finfo,'//'); //UNC
  uncitem.updateinfo;
  {$endif}
 
  if (high(ar1) > 0) and (ar1[0] = '') then begin
  {$ifdef mswindows}
   initdirfileinfo(aitem.finfo,'/');
   aitem.updateinfo;
   aitem:= uncitem;
  {$else}
   initdirfileinfo(aitem.finfo,'//'); //UNC simulation
  {$endif}
   int1:= 1;
  end
  else begin
   initdirfileinfo(aitem.finfo,'/');
  end;
 end
 else begin
  ar1:= splitfilepath(relativepath(filepath(froot,avalue),froot,fk_file));
  initdirfileinfo(aitem.finfo,'/'+filepath(froot)); //UNC simulation
 end;
 aitem.updateinfo;
 item1:= aitem;
 for int1:= int1 to high(ar1) do begin
  aitem.expanded:= true;
  aitem:= aitem.findsubdir(ar1[int1]);
  if aitem = nil then begin
   break;
  end;
  item1:= aitem;
 end;
 grid.focuscell(makegridcoord(0,treeitem.itemlist.indexof(item1)),
                                                       fca_setfocusedcell);
end;

procedure tdirtreefo.setpath(const avalue: filenamety);
begin
 fpath:= avalue;
 updatepath();
end;

procedure tdirtreefo.treeitemoncellevent(const sender: tobject;
  var info: celleventinfoty);
begin
 case info.eventkind of
  cek_enter: begin
   if assigned(fonpathchanged) then begin
    fonpathchanged(self);
   end;
  end;
 end;
 if iscellclick(info) and (info.zone = cz_caption) then begin
  treeitem.checkvalue;
 end;
end;

procedure tdirtreefo.treeitemoncreateitem(const sender: tcustomitemlist;
  var item: ttreelistedititem);
begin
 item:= tdirlistitem.create(sender);
 if dto_checkbox in foptions then begin
  with tdirlistitem(item) do begin
   fstate:= fstate + [ns_checkbox,ns_showchildchecked];
  end;
 end;
end;

procedure tdirtreefo.treeitemondataentered(const sender: tobject);
begin
 window.modalresult:= mr_ok;
end;

procedure tdirtreefo.treeitemonitemnotification(const sender: tlistitem;
  var action: nodeactionty);
var
 bo1: boolean;
begin
 with tdirlistitem(sender) do begin
  case action of
   na_expand: begin
    include(finfo.state,fis_diropen);
    updateinfo;
    if (count = 0) or not(dto_checkbox in foptions) then begin
     adddir(tdirlistitem(sender));
    end;
    if count = 0 then begin
     state:= state - [ns_subitems,ns_expanded];
     action:= na_none;
    end;
   end;
   na_collapse: begin
    bo1:= count > 0;
    if not (dto_checkbox in foptions) then begin
     clear;
    end;
    if bo1 then begin
     state:= state + [ns_subitems];
    end;
    exclude(finfo.state,fis_diropen);
    updateinfo;
   end;
  end;
 end;
end;

end.
