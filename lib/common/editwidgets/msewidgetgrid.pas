{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msewidgetgrid;

{$ifdef FPC}
 {$mode objfpc}{$h+}{$interfaces corba}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface
uses
 mseclasses,msegrids,msegui,msegraphutils,mseglob,mseguiglob,mseeditglob,
 Classes,msemenus,msearrayutils,
 msegraphics,mseevent,msedatalist,msetypes,msepointer,msestrings,
 msegridsglob{$ifdef mse_with_ifi},mseificomp{$endif};

//todo: simplify handling of changed column widgets in inherited grids

type

 twidgetcol = class;
 tcustomwidgetgrid = class;
 
 iwidgetgrid = interface(inullinterface)
  function getgrid: tcustomwidgetgrid;
  function getbrushorigin: pointty;
  function getcol: twidgetcol;
  function getdatapo(const arow: integer): pointer;
  function getrowdatapo: pointer;
  procedure getdata(var index: integer; var dest);
  procedure setdata(var index: integer; const source;
                        const noinvalidate: boolean = false);
  procedure datachange(const index: integer);
  function getrow: integer;
  procedure setrow(arow: integer);
  procedure changed;
  function empty(index: integer): boolean;
  function cangridcopy: boolean;
  procedure updateeditoptions(var aoptions: optionseditty);
  procedure coloptionstoeditoptions(var dest: optionseditty);
  function showcaretrect(const arect: rectty; const aframe: tcustomframe): pointty;
  procedure widgetpainted(const canvas: tcanvas);
  function nullcheckneeded(const newfocus: twidget): boolean;
  function nonullcheck: boolean;
  function nocheckvalue: boolean;
  property grid: tcustomwidgetgrid read getgrid;
 {$ifdef mse_with_ifi}
  procedure updateifigriddata(const alist: tdatalist);
 {$endif}
 end;

 igridwidget = interface(inullinterface) ['{CB4BC9B0-A6C2-4929-9E5F-92406B6617B4}']
  procedure setfirstclick;
  function getwidget: twidget;
  procedure updatepopupmenu(var amenu: tpopupmenu; 
                                          var mouseinfo: mouseeventinfoty);
  function getcellframe: framety;
  function getcellcursor(const arow: integer; //-1 -> widget
                const acellzone: cellzonety): cursorshapety;
  procedure updatecellzone(const arow: integer; //-1 -> widget
                         const apos: pointty;
                           var result: cellzonety);
  function createdatalist(const sender: twidgetcol): tdatalist;
  procedure datalistdestroyed;
  function getdatatype: listdatatypety;
  function getdefaultvalue: pointer;
//  function getrowdatapo(const info: cellinfoty): pointer;
  function getrowdatapo(const arow: integer): pointer;
  function getoptionsedit: optionseditty;
  procedure setgridintf(const intf: iwidgetgrid);
  function getgridintf: iwidgetgrid;
  procedure drawcell(const canvas: tcanvas);
  procedure updateautocellsize(const canvas: tcanvas);
  procedure beforecelldragevent(var ainfo: draginfoty; const arow: integer;
                               var processed: boolean);
  procedure aftercelldragevent(var ainfo: draginfoty; const arow: integer;
                               var processed: boolean);
  procedure initgridwidget;
  procedure gridtovalue(row: integer);  //row = -1 -> focused row, -2 -> default value
  procedure valuetogrid(row: integer);  //row = -1 -> focused row
  function getnulltext: msestring;
  procedure docellevent(const ownedcol: boolean; var info: celleventinfoty);
  function sortfunc(const l,r): integer;
  procedure gridvaluechanged(const index: integer); //index = -1 -> undefined, all
  procedure updatecoloptions(const aoptions: coloptionsty);
  procedure statdataread;
  procedure griddatasourcechanged;
  procedure setreadonly(const avalue: boolean);
 {$ifdef mse_with_ifi}
  function getifilink: tifilinkcomp;
 {$endif}  
 end;

 twidgetcol = class(tdatacol,iwidgetgrid,idatalistclient)
  private
   fwidgetname: string;
   ffixrowwidgets: widgetarty;
   ffixrowwidgetnames: stringarty;
   procedure updatewidgetrect(const updatedata: boolean = false);
   procedure readwidgetname(reader: treader);
   procedure writewidgetname(writer: twriter);
   procedure readfixwidgetnames(reader: treader);
   procedure writefixwidgetnames(writer: twriter);
   procedure readdataclass(reader: treader);
   procedure writedataclass(writer: twriter);
   procedure readdatatype(reader: treader);
   procedure writedatatype(writer: twriter);
   procedure readdata(reader: treader);
   procedure writedata(writer: twriter);
   procedure readdataprops(reader: treader);
   procedure writedataprops(writer: twriter);
  protected
   fintf: igridwidget;
    //iwidgetgrid
   function getgrid: tcustomwidgetgrid;
   function getbrushorigin: pointty;
   function getcol: twidgetcol;
   procedure getdata(var arow: integer; var dest);
   procedure setdata(var arow: integer;
                const source; const noinvalidate: boolean = false); virtual;
   procedure datachange(const arow: integer); virtual;
   function getrow: integer;
   procedure setrow(arow: integer);
   function empty(arow: integer): boolean;
   function cangridcopy: boolean;
   procedure updateeditoptions(var aoptions: optionseditty);
   function showcaretrect(const arect: rectty; const aframe: tcustomframe): pointty;
   procedure widgetpainted(const canvas: tcanvas);
   function nullcheckneeded(const newfocus: twidget): boolean;
   function nonullcheck: boolean;
   function nocheckvalue: boolean;
  {$ifdef mse_with_ifi}
   procedure updateifigriddata(const alist: tdatalist);
  {$endif}

   procedure checkcanclose(var accepted: boolean);
   procedure docellfocuschanged(enter: boolean;
               const cellbefore: gridcoordty; var newcell: gridcoordty;
               const selectaction: focuscellactionty); override;
   procedure defineproperties(filer: tfiler); override;
   function getdatapo(const arow: integer): pointer; override;
   procedure drawcell(const canvas: tcanvas); override;
   procedure drawfocusedcell(const acanvas: tcanvas); override;
   procedure drawfocus(const acanvas: tcanvas); override;
   function sortcompare(const index1,index2: integer): integer; override;
   procedure itemchanged(const sender: tdatalist; 
                                  const aindex: integer); override;
   procedure setwidget(const awidget: twidget); virtual;
   procedure seteditwidget(const value: twidget);
   procedure setfixrowwidget(const awidget: twidget; const rowindex: integer);
   function geteditwidget: twidget;
   function getinnerframe: framety; override;
   procedure setoptions(const avalue: coloptionsty); override;
   function getcursor(const arow: integer; 
                       const actcellzone: cellzonety): cursorshapety; override;
   procedure datasourcechanged;
   procedure beforedragevent(var ainfo: draginfoty; const arow: integer;
                                var processed: boolean); override;
   procedure afterdragevent(var ainfo: draginfoty; const arow: integer;
                                var processed: boolean); override;

  public
   constructor create(const agrid: tcustomgrid;
                     const aowner: tgridarrayprop); override;
   destructor destroy; override;
   procedure sourcenamechanged(const atag: integer);
   procedure updatecellzone(const row: integer; const pos: pointty;
                                             var result: cellzonety); override;
   function actualfont: tfont; override;
//   procedure cellchanged(const row: integer); override;
   property editwidget: twidget read geteditwidget write seteditwidget;
   property grid: tcustomwidgetgrid read getgrid;
  published
//   property datalist;
   property datalist stored false; //stored by defineproperties
 end;

 twidgetfixrow = class(tfixrow)
 end;
  
 twidgetfixrows = class(tfixrows)
  private
   fwidgetrectupdating: integer;
   procedure unregisterchildwidget(const child: twidget);
   function getrows(const aindex: integer): twidgetfixrow;
   procedure updatewidgetrect;
  protected
   procedure countchanged; override;
  public
   constructor create(const owner: tcustomwidgetgrid);
   procedure move(const curindex,newindex: integer); override;
   property rows[const index: integer]: twidgetfixrow read getrows; default;
 end;
 
 twidgetcols = class(tdatacols)
  private
   function getcols(const index: integer): twidgetcol;
   procedure unregisterchildwidget(const child: twidget);
  protected
   procedure updatedatastate(var accepted: boolean); override;
  public
   constructor create(const aowner: tcustomwidgetgrid);
   class function getitemclasstype: persistentclassty; override;
   procedure datasourcechanged; override;
   property cols[const index: integer]: twidgetcol read getcols; default;
 end;

 twidgetfixcol = class(tfixcol)
  private
   ffixrowwidgets: widgetarty;
   ffixrowwidgetnames: stringarty;
   procedure readfixwidgetnames(reader: treader);
   procedure writefixwidgetnames(writer: twriter);
  protected
   procedure defineproperties(filer: tfiler); override;
   procedure setfixrowwidget(const awidget: twidget; const rowindex: integer);
  public
   constructor create(const agrid: tcustomgrid;
                            const aowner: tgridarrayprop); override;
   destructor destroy; override;
 end;
 
 twidgetfixcols = class(tfixcols)
  private
   function getcols(const index: integer): twidgetfixcol;
  protected
   procedure unregisterchildwidget(const child: twidget);
  public
   constructor create(const aowner: tcustomwidgetgrid);
   property cols[const index: integer]: twidgetfixcol read getcols; default;
 end;

 tdummywidget = class(twidget)
  public
   constructor create(aowner: tcomponent); override;
   function setfocus(aactivate: boolean = true): boolean; override;
              //unsetsfocus if not focusable
 end;
  
 tcustomwidgetgrid = class(tcustomgrid)
  private
   fcontainer0: twidget; //for nohascroll widgets
   fcontainer1: twidget;
   fcontainer2: twidget;
   fcontainer3: twidget;
   flastfocusedfixwidget: twidget;
   fwidgetdummy: tdummywidget;
   fmousefocusedcell: gridcoordty;
   fmouseactivewidget: twidget;
   fmouseinfopo: pmouseeventinfoty;
   function getdatacols: twidgetcols;
   procedure setdatacols(const avalue: twidgetcols);
   function checkreflectmouseevent(var info: mouseeventinfoty;
                     iscellcall: boolean): boolean;
   procedure initcopyars(out dataedits: widgetarty; out datalists: datalistarty);
   procedure dowidgetcellevent(var info: celleventinfoty);
   function getfixrows: twidgetfixrows;
   procedure setfixrows(const avalue: twidgetfixrows);
   function getfixcols: twidgetfixcols;
   procedure setfixcols(const avalue: twidgetfixcols);
  protected
   ffocuslock: integer;
   factivewidget: twidget;
   function getgriddatalink: pointer; virtual;
   procedure setoptionswidget(const avalue: optionswidgetty); override;
   procedure setoptionsgrid(const avalue: optionsgridty); override;
//   procedure focusedcellchanged; override;
   procedure dofocus; override;
   procedure dochildfocused(const sender: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure widgetregionchanged(const sender: twidget); override;
   function createdatacols: tdatacols; override;
   function createfixrows: tfixrows; override;
   function createfixcols: tfixcols; override;
   procedure createdatacol(const index: integer; out item: tdatacol); override;
   procedure scrolled(const dist: pointty); override;
   procedure updatecontainerrect;
   procedure updatelayout; override;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
//   procedure loaded; override;
   procedure doendread; override;
   function scrollcaret(const vertical: boolean): boolean; override;
   procedure docellevent(var info: celleventinfoty); override;
   procedure checkcellvalue(var accept: boolean); override; //store edited value to grid
   procedure dofocusedcellposchanged; override;
   procedure dorowsmoved(const fromindex,toindex,count: integer); override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure childmouseevent(const sender: twidget; var info: mouseeventinfoty); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure doexit; override;
   procedure navigrequest(var info: naviginfoty); override;
   procedure checkrowreadonlystate; override;
   procedure updaterowdata; override;
   function cellhasfocus: boolean; override;

   function getcontainer: twidget; override;
   function getchildwidgets(const index: integer): twidget; override;
   procedure removefixwidget(const awidget: twidget);
   procedure updatepopupmenu(var amenu: tpopupmenu; 
                         var mouseinfo: mouseeventinfoty); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure insertwidget(const awidget: twidget; const apos: pointty); override;
   function childrencount: integer; override;
   function getlogicalchildren: widgetarty; override;
   
   procedure focuslock; //beginupdate + no cell widget focus/defocus
   procedure focusunlock;

   procedure seteditfocus;   
   function editwidgetatpos(const apos: pointty; out cell: gridcoordty): twidget;
   function widgetcell(const awidget: twidget): gridcoordty;
   function cellwidget(const acell: gridcoordty): twidget;
   function copyselection: boolean; override;
    //false if no copy
   function pasteselection: boolean; override;
    //false if no paste
   property datacols: twidgetcols read getdatacols write setdatacols;
   property fixcols: twidgetfixcols read getfixcols write setfixcols;
   property fixrows: twidgetfixrows read getfixrows write setfixrows;
  end;

 twidgetgrid = class(tcustomwidgetgrid)
  published
   property optionsgrid;
   property optionsgrid1;
   property optionsfold;
   property rowstatelist;
   property fixcols;
   property fixrows;
   property rowcount;
   property rowcountmax;
   property gridframecolor;
   property gridframewidth;
   property rowcolors;
   property rowfonts;
   property zebra_color;
   property zebra_start;
   property zebra_height;
   property zebra_step;
   property datacols;
  {$ifdef mse_with_ifi}
   property ifilink;
  {$endif}
  
   property datarowlinewidth;
   property datarowlinecolorfix;
   property datarowlinecolor;
   property datarowheight;
   property datarowheightmin;
   property datarowheightmax;

   property statfile;
   property statvarname;

   property oncopyselection;
   property onpasteselection;
   property onbeforeupdatelayout;
   property onlayoutchanged;
   property oncolmoved;
   property onrowcountchanged;
   property onrowdatachanged;
   property onrowsdatachanged;
   property onrowsmoved;
   property onrowsinserting;
   property onrowsinserted;
   property onrowsdeleting;
   property onrowsdeleted;
   property onscrollrows;
   property oncellevent;
   property onselectionchanged;
   property onsort;
   property onsortchanged;
   property drag;
 end;

 tgridmsestringdatalist = class(tmsestringdatalist)
  private
   fowner: twidgetcol;
  protected
   function getdefault: pointer; override;
  public
   constructor create(owner: twidgetcol); reintroduce;
   function empty(const index: integer): boolean; override;   //true wenn leer
 end;
 
 tgridansistringdatalist = class(tansistringdatalist)
  private
   fowner: twidgetcol;
  protected
   function getdefault: pointer; override;
  public
   constructor create(owner: twidgetcol); reintroduce;
 end;

 tgridpointerdatalist = class(tpointerdatalist)
  private
   fowner: twidgetcol;
  protected
   function getdefault: pointer; override;
  public
   constructor create(owner: twidgetcol); reintroduce;
 end;

 tgridintegerdatalist = class(tintegerdatalist)
  private
   fowner: twidgetcol;
  protected
   function getdefault: pointer; override;
  public
   constructor create(owner: twidgetcol); reintroduce;
 end;

 tgridint64datalist = class(tint64datalist)
  private
   fowner: twidgetcol;
  protected
   function getdefault: pointer; override;
  public
   constructor create(owner: twidgetcol); reintroduce;
 end;

 tgridenumdatalist = class(tenumdatalist)
  private
   fowner: twidgetcol;
  protected
   function getdefaultenum: integer;
  public
   constructor create(owner: twidgetcol); reintroduce;
 end;

 tgridenum64datalist = class(tenum64datalist)
  private
   fowner: twidgetcol;
  protected
   function getdefaultenum: int64;
  public
   constructor create(owner: twidgetcol); reintroduce;
 end;

 tgridrealdatalist = class(trealdatalist)
  private
   fowner: twidgetcol;
  protected
   function getdefault: pointer; override;
  public
   constructor create(owner: twidgetcol); reintroduce;
   function empty(const index: integer): boolean; override;   //true wenn leer
 end;

type
 creategriddatalistty = function(const aowner: twidgetcol): tdatalist;

procedure registergriddatalistclass(const tag: ansistring;
       const createfunc: creategriddatalistty);

procedure gridwidgetfontheightdelta(const sender: twidget; const gridintf: iwidgetgrid;
                        const delta: integer);
procedure defaultinitgridwidget(const awidget: twidget; const agridintf: iwidgetgrid);

implementation
uses
 sysutils,msebits,msedataedits,msewidgets,mseshapes,msekeyboard,typinfo,
 msereal,mseapplication,msehash,msesumlist;

type
 tdatalist1 = class(tdatalist);
 twidget1 = class(twidget);
 tcustomgrid1 = class(tcustomgrid);
 tdataedit1 = class(tdataedit);
 twriter1 = class(twriter);
 treader1 = class(treader);

 tcontainer1 = class(twidget)
  private
  protected
   fgrid: tcustomwidgetgrid;
   procedure doexit; override;
   procedure doenter; override;
  public
 end;
 
 tfixcontainer = class(tcontainer1)
  protected
   procedure unregisterchildwidget(const child: twidget); override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure dochildfocused(const sender: twidget); override;
   procedure doenter; override;
//   procedure dokeydown(var info: keyeventinfoty); override;
  public
   constructor create(aowner: tcustomwidgetgrid); reintroduce;
   function focusback(const aactivate: boolean = true): boolean; override;
 end;
 
 ttopcontainer = class(tfixcontainer)
 end;
 
 tbottomcontainer = class(tfixcontainer)
 end;
 
 twidgetdummy = class(twidget)
  protected
   fgrid: tcustomwidgetgrid;
  public
   constructor create(aowner: tcustomwidgetgrid); reintroduce;
 end;
 
 tgridcontainer = class(tcontainer1)
  private
   flayoutupdating: integer;
  protected
   procedure unregisterchildwidget(const child: twidget); override;
   procedure doenter; override;
   procedure doexit; override;   
   procedure dofocus; override;
  public
   constructor create(aowner: tcustomwidgetgrid); reintroduce;
   function focusback(const aactivate: boolean = true): boolean; override;
 end;

 tscrollgridcontainer = class(tgridcontainer)
  protected
   procedure widgetregionchanged(const sender: twidget); override;
 end;
 
 tnoscrollgridcontainer = class(tgridcontainer)
  public
//   constructor create(aowner: tcustomwidgetgrid);
 end;
 
var
 griddatalists: tpointeransistringhashdatalist;
 
procedure defaultinitgridwidget(const awidget: twidget; 
                                         const agridintf: iwidgetgrid);

begin
 with twidget1(awidget) do begin
  optionswidget:= optionswidget - [ow_autoscale];
  optionsskin:= optionsskin + defaultgridskinoptions;
  if (fframe <> nil) then begin
   if (ws_staticframe in fwidgetstate) then begin
    fframe.initgridframe;
    if agridintf <> nil then begin
     fframe.framei:= agridintf.getgrid.datacols.innerframe;
    end;
   end
   else begin
    freeandnil(fframe);
   end;
  end;
  synctofontheight;
 end;
end;

procedure gridwidgetfontheightdelta(const sender: twidget; const gridintf: iwidgetgrid;
                        const delta: integer);
var
 cell1: gridcoordty;
 widget1: twidget;
begin
 with twidget1(sender) do begin
  if (ow_autoscale in foptionswidget) and 
          not (csdesigning in componentstate) then begin
          //in designmode widgetsize -> cellsize
   if gridintf <> nil then begin
    with gridintf.getcol.grid do begin
     datarowheight:= datarowheight + delta;
    end;
   end
   else begin
    widget1:= parentofcontainer;
    if widget1 is tcustomwidgetgrid then begin
     with tcustomwidgetgrid(widget1) do begin
      cell1:= widgetcell(sender);
      if (cell1.row < 0) and (cell1.row >= -fixrows.count) then begin
       fixrows[cell1.row].height:= fixrows[cell1.row].height + delta;
      end;
     end;
    end;
   end;
  end;
 end;
end;

{ tgridmsestringdatalist }

constructor tgridmsestringdatalist.create(owner: twidgetcol);
begin
 fowner:= owner;
 inherited create;
 include(fstate,dls_nostreaming);
end;

function tgridmsestringdatalist.getdefault: pointer;
begin
 if fowner.fintf <> nil then begin
  result:= fowner.fintf.getdefaultvalue;
 end
 else begin
  result:= inherited getdefault;
 end;
end;

function tgridmsestringdatalist.empty(const index: integer): boolean;
var
 po1: pmsestring;
begin
 po1:= nil;
 if fowner.fintf <> nil then begin
  po1:= fowner.fintf.getdefaultvalue;
 end;
 if po1 <> nil then begin
  result:= msestring(getitempo(index)^) = po1^;
 end
 else begin
  result:= inherited empty(index);
 end;
end;

{ tgridansistringdatalist }

constructor tgridansistringdatalist.create(owner: twidgetcol);
begin
 fowner:= owner;
 inherited create;
 include(fstate,dls_nostreaming);
end;

function tgridansistringdatalist.getdefault: pointer;
begin
 if fowner.fintf <> nil then begin
  result:= fowner.fintf.getdefaultvalue;
 end
 else begin
  result:= inherited getdefault;
 end;
end;

{ tgridpointerdatalist }

constructor tgridpointerdatalist.create(owner: twidgetcol);
begin
 fowner:= owner;
 inherited create;
 include(fstate,dls_nostreaming);
end;

function tgridpointerdatalist.getdefault: pointer;
begin
 if fowner.fintf <> nil then begin
  result:= fowner.fintf.getdefaultvalue;
 end
 else begin
  result:= inherited getdefault;
 end;
end;

{ tgridintegerdatalist }

constructor tgridintegerdatalist.create(owner: twidgetcol);
begin
 fowner:= owner;
 inherited create;
 include(fstate,dls_nostreaming);
end;

function tgridintegerdatalist.getdefault: pointer;
begin
 if fowner.fintf <> nil then begin
  result:= fowner.fintf.getdefaultvalue;
 end
 else begin
  result:= inherited getdefault;
 end;
end;

{ tgridint64datalist }

constructor tgridint64datalist.create(owner: twidgetcol);
begin
 fowner:= owner;
 inherited create;
 include(fstate,dls_nostreaming);
end;

function tgridint64datalist.getdefault: pointer;
begin
 if fowner.fintf <> nil then begin
  result:= fowner.fintf.getdefaultvalue;
 end
 else begin
  result:= inherited getdefault;
 end;
end;

{ tgridenumdatalist }

constructor tgridenumdatalist.create(owner: twidgetcol);
begin
 fowner:= owner;
 inherited create({$ifdef FPC}@{$endif}getdefaultenum);
 include(fstate,dls_nostreaming);
end;

function tgridenumdatalist.getdefaultenum: integer;
begin
 if fowner.fintf <> nil then begin
  result:= integer(fowner.fintf.getdefaultvalue^);
 end
 else begin
  result:= 0;
//  result:= integer(inherited getdefault^);
 end;
end;

{ tgridenum64datalist }

constructor tgridenum64datalist.create(owner: twidgetcol);
begin
 fowner:= owner;
 inherited create({$ifdef FPC}@{$endif}getdefaultenum);
 include(fstate,dls_nostreaming);
end;

function tgridenum64datalist.getdefaultenum: int64;
begin
 if fowner.fintf <> nil then begin
  result:= int64(fowner.fintf.getdefaultvalue^);
 end
 else begin
//  result:= int64(inherited getdefault^);
  result:= 0;
 end;
end;

{ tgridrealdatalist }

constructor tgridrealdatalist.create(owner: twidgetcol);
begin
 fowner:= owner;
 inherited create;
 include(fstate,dls_nostreaming);
end;

function tgridrealdatalist.getdefault: pointer;
begin
 if fowner.fintf <> nil then begin
  result:= fowner.fintf.getdefaultvalue;
 end
 else begin
  result:= nil;
 end;
 if result = nil then begin
  result:= inherited getdefault;
 end;
end;

function tgridrealdatalist.empty(const index: integer): boolean;
var
 po1: prealty;
begin
 po1:= nil;
 if fowner.fintf <> nil then begin
  po1:= fowner.fintf.getdefaultvalue;
 end;
 if po1 <> nil then begin
  result:= realty(getitempo(index)^) = po1^;
 end
 else begin
  result:= inherited empty(index);
 end;
end;

{ twidgetfixrow }


{ twidgetfixrows }

constructor twidgetfixrows.create(const owner: tcustomwidgetgrid);
begin
 inherited create(owner);
 fitemclasstype:= twidgetfixrow;
end;

procedure twidgetfixrows.unregisterchildwidget(const child: twidget);
var
 int1,int2: integer;
begin
 if (fwidgetrectupdating = 0) and 
        not (csdestroying in fgrid.componentstate) then begin
  for int1:= 0 to fgrid.datacols.count - 1 do begin
   with tcustomwidgetgrid(fgrid).datacols[int1] do begin
    for int2:= 0 to high(ffixrowwidgets) do begin
     if ffixrowwidgets[int2] = child then begin
      ffixrowwidgets[int2]:= nil;
      break;
     end;
    end;
   end;
  end;
 end;
end;

function twidgetfixrows.getrows(const aindex: integer): twidgetfixrow;
begin
 result:= twidgetfixrow(inherited rows[aindex]);
end;

procedure twidgetfixrows.updatewidgetrect;
var
 rect1: rectty;
 int1,int2: integer;
 coord1: gridcoordty;
begin
 inc(fwidgetrectupdating);
 try
  for int1:= 0 to fgrid.datacols.count - 1 do begin
   with tcustomwidgetgrid(fgrid).datacols[int1] do begin
    for int2:= 0 to high(ffixrowwidgets) do begin
     if ffixrowwidgets[int2] <> nil then begin
      with ffixrowwidgets[int2] do begin
       if co_nohscroll in foptions then begin
        parentwidget:= fgrid;
       end
       else begin
        if int2 >= fgrid.fixrows.count - fgrid.fixrows.oppositecount then begin
         parentwidget:= tcustomwidgetgrid(fgrid).fcontainer3;
        end
        else begin
         parentwidget:= tcustomwidgetgrid(fgrid).fcontainer1;
        end;
       end;
       coord1:= makegridcoord(int1,-int2-1);
       if fgrid.cellvisible(coord1) then begin
        rect1:= fgrid.cellrect(coord1,cil_noline);
        rect1.pos:= translatewidgetpoint(addpoint(rect1.pos,fgrid.paintpos),
                               fgrid,parentwidget);
        widgetrect:= rect1;
       end
       else begin
        bounds_y:= -bounds_cy;      //shift out of view
       end;
      end;
     end;
    end;
   end;
  end;
  for int1:= -fgrid.fixcols.count to -1 do begin
   with tcustomwidgetgrid(fgrid).fixcols[int1] do begin
    for int2:= 0 to high(ffixrowwidgets) do begin
     if ffixrowwidgets[int2] <> nil then begin
      with ffixrowwidgets[int2] do begin
       parentwidget:= fgrid;
       coord1:= makegridcoord(int1,-int2-1);
       if fgrid.cellvisible(coord1) then begin
        rect1:= fgrid.cellrect(coord1,cil_noline);
        rect1.pos:= translatewidgetpoint(addpoint(rect1.pos,fgrid.paintpos),
                               fgrid,parentwidget);
        widgetrect:= rect1;
       end
       else begin
        bounds_y:= -bounds_cy;      //shift out of view
       end;
      end;
     end;
    end;
   end;
  end;
  with tcustomwidgetgrid(fgrid) do begin
   if fcontainer1 <> nil then begin //else call from tcustomwidgetgrid.create
    if fcontainer1.widgetcount = 0 then begin
     exclude(twidget1(fcontainer1).foptionswidget,ow_arrowfocus);
    end
    else begin
     include(twidget1(fcontainer1).foptionswidget,ow_arrowfocus);
    end;
    if fcontainer3.widgetcount = 0 then begin
     exclude(twidget1(fcontainer3).foptionswidget,ow_arrowfocus);
    end
    else begin
     include(twidget1(fcontainer3).foptionswidget,ow_arrowfocus);
    end;
   end;
  end;
 finally
  dec(fwidgetrectupdating);
 end;
end;

procedure twidgetfixrows.countchanged;
var
 int1,int2: integer;
 ar1: widgetarty;
begin
 if not (csdestroying in fgrid.componentstate) then begin
  for int1:= 0 to fgrid.datacols.count - 1 do begin
   with tcustomwidgetgrid(fgrid).datacols[int1] do begin
    ar1:= ffixrowwidgets;
    setlength(ffixrowwidgets,self.count);
    for int2:= high(ar1) downto self.count do begin
     if ar1[int2] <> nil then begin
      freedesigncomponent(ar1[int2]); //inhibit deleting of inherited widget
     end;
    end;
   end;
  end;
  for int1:= 0 to fgrid.fixcols.count - 1 do begin
   with twidgetfixcol(fgrid.fixcols.items[int1]) do begin
    ar1:= ffixrowwidgets;
    setlength(ffixrowwidgets,self.count);
    for int2:= high(ar1) downto self.count do begin
     if ar1[int2] <> nil then begin
      freedesigncomponent(ar1[int2]); //inhibit deleting of inherited widget
     end;
    end;
   end;
  end;
 end;
 inherited;
end;

procedure twidgetfixrows.move(const curindex,newindex: integer);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to fgrid.datacols.count - 1 do begin
  with tcustomwidgetgrid(fgrid).datacols[int1] do begin
   moveitem(pointerarty(ffixrowwidgets),curindex,newindex);
  end;
 end;
 for int1:= 0 to fgrid.fixcols.count - 1 do begin
  with twidgetfixcol(fgrid.fixcols.items[int1]) do begin
   moveitem(pointerarty(ffixrowwidgets),curindex,newindex);
  end;
 end;
end;

{ twidgetcol }

constructor twidgetcol.create(const agrid: tcustomgrid;
               const aowner: tgridarrayprop);
begin
 setlength(ffixrowwidgets,agrid.fixrows.count);
 inherited;
end;

destructor twidgetcol.destroy;
var
 aintf: igridwidget;
 int1: integer;
begin
 if not (csdestroying in fgrid.componentstate) then begin
  if fintf <> nil then begin
   aintf:= fintf;
   fintf:= nil;
   aintf.setgridintf(nil);
   if not (csreading in fgrid.componentstate) then begin
                           //refreshancestor otherwise
    freedesigncomponent(aintf.getwidget); //inhibit deleting of inherited widget
   end;
  end;
  if not (csreading in fgrid.componentstate) then begin
                           //refreshancestor otherwise
   for int1:= 0 to high(ffixrowwidgets) do begin
    if ffixrowwidgets[int1] <> nil then begin
     freedesigncomponent(ffixrowwidgets[int1]); 
                      //inhibit deleting of inherited widget
    end;
   end;
  end;
 end;
{$ifndef FPC}
 pointer(fintf):= nil; //workaround for com decref
{$endif}
 inherited;
end;

{$ifdef FPC}{$checkpointer off}{$endif} 
procedure twidgetcol.updatewidgetrect(const updatedata: boolean = false);
var
 rect1: rectty;
 widget1: twidget;
begin
 with tcustomwidgetgrid(fgrid) do begin
  if (fintf <> nil) then begin //bug in fixes_2_0 2850 with checkpointer
   widget1:= fintf.getwidget;
   if co_nohscroll in foptions then begin
    widget1.parentwidget:= fcontainer0;
//    widget1.parentwidget:= fgrid;
   end
   else begin
    widget1.parentwidget:= fcontainer2;
   end;
   if (csdesigning in componentstate) or (ffocusedcell.row < 0) then begin
    rect1:= cellrect(makegridcoord(colindex,0),cil_noline);
    if not (csdesigning in componentstate) then begin
     rect1.cx:= rect1.cx + fdatacols.mergedwidth(index,row);
    end;
    if co_nohscroll in self.foptions then begin
//     rect1.y:= fdatarect.y;
//     widget1.widgetrect:= moverect(rect1,paintpos);
     rect1.y:= 0;
     rect1.x:= rect1.x - fdatarecty.x;
     widget1.widgetrect:= rect1;
    end
    else begin
     rect1.y:= 0;
     dec(rect1.x,fdatarect.x);
     widget1.widgetrect:= rect1;
    end;
   end
   else begin
    rect1:= cellrect(makegridcoord(colindex,ffocusedcell.row),cil_noline);
    if co_nohscroll in self.foptions then begin
//     removerect1(rect1,fdatarecty.pos);
     removerect1(rect1,fdatarecty.pos);
//     moverect1(rect1,subpoint(fcontainer2.pos,fcontainer0.pos));
    end
    else begin
     removerect1(rect1,fdatarect.pos);
    end;
    widget1.widgetrect:= rect1;
   end;
   if updatedata then begin
    fintf.gridtovalue(-1);
   end;
  end;
 end;
end;
{$ifdef FPC}{$checkpointer default}{$endif} 

procedure twidgetcol.checkcanclose(var accepted: boolean);
begin
 if (fintf <> nil) and fintf.getwidget.focused and 
       not tcustomgrid1(fgrid).nocheckvalue and accepted then begin
  accepted:= fintf.getwidget.canclose(nil);
 end;
end;

procedure twidgetcol.docellfocuschanged(enter: boolean;
                     const cellbefore: gridcoordty; var newcell: gridcoordty;
                     const selectaction: focuscellactionty);
var
 widget1: twidget;
 activewidgetbefore: twidget;
 intf: igridwidget;
 focuscount: integer;
 bo1: boolean;
 
begin
 with twidgetgrid(fgrid) do begin
  if ffocuslock > 0 then begin
   if not enter then begin
    factivewidget:= nil;
   end
   else begin
   end;
   inherited;
   exit;
  end;
  
  focuscount:= ffocuscount;
  activewidgetbefore:= factivewidget;
  if not enter and (selectaction <> fca_exitgrid) then begin
   factivewidget:= nil;
   bo1:= true;
   if not (gs1_rowdeleting in twidgetgrid(fgrid).fstate1) then begin
    checkcanclose(bo1);
   end;
   if bo1 then begin
    if (activewidgetbefore <> nil) and 
           activewidgetbefore.clicked then begin
     with fgrid do begin
      capturemouse;
      fwidgetstate:= fwidgetstate + [ws_clientmousecaptured];
      include(fstate,gs_childmousecaptured);
     end; 
    end;
    if (activewidgetbefore <> nil) then begin
     if activewidgetbefore.focused then begin
      fwidgetdummy.setfocus(active);
     end;
     activewidgetbefore.visible:= false;
    end;
    inherited;
   end
   else begin
    focuscell(cellbefore,fca_none);
   end;
  end
  else begin
   if (fintf <> nil) then begin
    updatewidgetrect;
    inherited;
    bo1:= (tcustomwidgetgrid(fgrid).fmouseinfopo <> nil) and 
              tcustomwidgetgrid(fgrid).wantmousefocus(fmouseinfopo^);
    if fgrid.entered or 
               not (gs_cellexiting in tcustomwidgetgrid(fgrid).fstate) and 
                                                                bo1 then begin
     widget1:= fintf.getwidget;
     with widget1 do begin
      visible:= true;
      if (fwindow <> nil) and 
       (canfocus and (tcustomwidgetgrid(fgrid).entered or bo1) and 
        not fgrid.checkdescendent(fwindow.focusedwidget) or
        (fwindow.focusedwidget = fgrid) or 
        fcontainer2.checkdescendent(fwindow.focusedwidget) or
        fcontainer0.checkdescendent(fwindow.focusedwidget)) then begin
       bo1:= gs1_focuscellonenterlock in twidgetgrid(fgrid).fstate1;
       include(twidgetgrid(fgrid).fstate1,gs1_focuscellonenterlock);
       try
        setfocus(fgrid.active);
       finally
        if not bo1 then begin
         exclude(twidgetgrid(fgrid).fstate1,gs1_focuscellonenterlock);
        end;
       end;
      end;
     end;
     if ffocuscount = focuscount then begin
      factivewidget:= widget1;
     end;
    end;
   end
   else begin
    if ffocuscount = focuscount then begin
     factivewidget:= nil;
    end;
   end;
   if (activewidgetbefore = nil) and (cellbefore.col >= 0) then begin
    intf:= twidgetcol(fdatacols[cellbefore.col]).fintf;
    if intf <> nil then begin
     activewidgetbefore:= intf.getwidget;
    end;
   end;
   if (activewidgetbefore <> nil) and (activewidgetbefore <> factivewidget) then begin
    activewidgetbefore.visible:= false;
   end;
  end;
 end;
end;

procedure twidgetcol.readfixwidgetnames(reader: treader);
begin
 readstringar(reader,ffixrowwidgetnames);
end;

procedure twidgetcol.writefixwidgetnames(writer: twriter);
begin
 writewidgetnames(writer,ffixrowwidgets);
end;

procedure twidgetcol.readwidgetname(reader: treader);
begin
 fwidgetname:= reader.readstring;
end;

procedure twidgetcol.writewidgetname(writer: twriter);
begin
 writer.writestring(fintf.getwidget.name);
end;

procedure twidgetcol.readdataclass(reader: treader);
var
 createproc: creategriddatalistty;
 str1: string;
begin
 str1:= reader.readident;
 if (fdata = nil) or (fdata.classname <> str1) then begin
  if fdata <> nil then begin
   if fintf <> nil then begin
    fintf.datalistdestroyed;
   end;
   freeandnil(fdata);
  end;
  if griddatalists.find(str1,pointer({$ifndef FPC}@{$endif}createproc)) then begin
   fdata:= createproc(self);
   include(fstate,gps_datalistvalid);
  end
  else begin
   raise exception.create('Unknown grid datalist type '+str1+'.');
  end;
 end;
end;

procedure twidgetcol.writedataclass(writer: twriter);
begin
 writer.writeident(fdata.classname);
end;

procedure twidgetcol.readdatatype(reader: treader);
var
 str1: string;
 int1: integer;
 licla: datalistclassty;
begin
 str1:= reader.readident;
 int1:= getenumvalue(typeinfo(listdatatypety),str1);
 if int1 >= 0 then begin
  freeandnil(fdata);
  licla:= getdatalistclass(listdatatypety(int1));
  if licla <> nil then begin
   fdata:= licla.create;
  end;
 end;
end;

procedure twidgetcol.writedatatype(writer: twriter);
begin
 writer.writeident(getenumname(typeinfo(listdatatypety),integer(fdata.datatype)));
end;

procedure twidgetcol.readdata(reader: treader);
begin
 reader.readlistbegin;
 if reader.nextvalue <> valist then begin
  readdatatype(reader);
 end;
 if fdata <> nil then begin
  tdatalist1(fdata).readdata(reader);
 end
 else begin
  reader.{$ifdef FPC}driver.{$endif}skipvalue;
 end;
 reader.readlistend;
end;

procedure twidgetcol.writedata(writer: twriter);
begin
 writer.writelistbegin;
// writedatatype(writer);
 tdatalist1(fdata).writedata(writer);
 writer.writelistend;
end;

procedure twidgetcol.readdataprops(reader: treader);
begin
 reader.readlistbegin;
 while not reader.endoflist do begin
  treader1(reader).readproperty(fdata);
 end;
 reader.readlistend;
end;

procedure twidgetcol.writedataprops(writer: twriter);
begin
 writer.writelistbegin;
 twriter1(writer).writeproperties(fdata);
 writer.writelistend;
end;

procedure twidgetcol.defineproperties(filer: tfiler);
var
 bo1: boolean;
 col1: twidgetcol;
 str1,str2: string;
begin
 inherited;
 filer.defineproperty('widgetname',{$ifdef FPC}@{$endif}readwidgetname,
                   {$ifdef FPC}@{$endif}writewidgetname,
                   (fintf <> nil) and 
                   ((filer.ancestor = nil) or 
                    (twidgetcol(filer.ancestor).fwidgetname <> fwidgetname)));
 filer.defineproperty('fixwidgetnames',{$ifdef FPC}@{$endif}readfixwidgetnames,
                   {$ifdef FPC}@{$endif}writefixwidgetnames,
     (filer.ancestor = nil) and needswidgetnamewriting(ffixrowwidgets) or
     (filer.ancestor <> nil) and 
        needswidgetnamewriting(ffixrowwidgets,
                       twidgetcol(filer.ancestor).ffixrowwidgets));
 bo1:= false;
 if (fdata <> nil) and ([dls_nogridstreaming,dls_remote] * 
                                   tdatalist1(fdata).fstate = []) then begin
  col1:= twidgetcol(filer.ancestor);
  if col1 <> nil then begin
   bo1:= (col1.fdata = nil) or (fdata.datatype <> col1.fdata.datatype);
   filer.ancestor:= col1.fdata;
  end;
  bo1:= bo1 or fdata.checkwritedata(filer);
  filer.ancestor:= col1;
 end;
 filer.defineproperty('dataclass',{$ifdef FPC}@{$endif}readdataclass,
                       {$ifdef FPC}@{$endif}writedataclass,
       (fdata <> nil) and not (dls_remote in fdata.state) and
      (not(dls_nogridstreaming in fdata.state) or
          (dls_propertystreaming in fdata.state)));
 filer.defineproperty('data',{$ifdef FPC}@{$endif}readdata,
                       {$ifdef FPC}@{$endif}writedata,bo1);
 if (fdata <> nil) and (dls_propertystreaming in 
        tdatalist1(fdata).fstate) and (filer is twriter) then begin
  with twriter1(filer) do begin
   str1:= getfproppath(twriter(filer));
   if str1 = '' then begin
    str2:= 'datalist.';
   end
   else begin
    str2:= str1+'.datalist.';
   end;
   setfproppath(twriter(filer),str2);
   writeproperties(fdata);
   setfproppath(twriter(filer),str1);
  end;
 end;
end;

procedure twidgetcol.setfixrowwidget(const awidget: twidget;
                       const rowindex: integer);
begin
 tcustomwidgetgrid(fgrid).removefixwidget(awidget);
 ffixrowwidgets[-rowindex-1]:= awidget;
 fgrid.layoutchanged;
end;

procedure twidgetcol.setwidget(const awidget: twidget);
//todo: use widget datalist if inherited column position has changed !!!!!!!!!
var
 po1: pointer;
 dl1: tdatalist;
{$ifdef mse_with_ifi}
 ifilink1: tifilinkcomp;
{$endif}
begin
 dl1:= fdata;
 fdata:= nil;
{$ifdef mse_with_ifi}
 ifilink1:= nil;
{$endif}
 try
  if fintf <> nil then begin
   if fdata <> nil then begin
    fdata.linksource(nil,0);
   end;
   fintf.setgridintf(nil);
  {$ifdef mse_with_ifi}
   updateifigriddata(nil);
  {$endif}
  end;
  if awidget <> nil then begin
   awidget.visible:= false;
   awidget.getcorbainterface(typeinfo(igridwidget),fintf);
   if not (gps_datalistvalid in fstate) then begin
    fdata:= fintf.createdatalist(self);
   end
   else begin
    fdata:= dl1;
   end;
   fintf.setgridintf(iwidgetgrid(self));
   options:= foptions; //call updatecoloptions;
  {$ifdef mse_with_ifi}
   ifilink1:= fintf.getifilink;
   if (ifilink1 <> nil) and not(csloading in ifilink1.componentstate) and
                                     (ifilink1 is tifivaluelinkcomp) then begin
    if fdata = dl1 then begin
     dl1:= nil; //no double free
    end;
    updateifigriddata(tifivaluelinkcomp(ifilink1).controller.datalist);
   end
   else begin
  {$endif}
    po1:= fintf.getdefaultvalue;
    if fdata <> nil then begin
     if dl1 <> nil then begin //from streaming
      if dl1 <> fdata then begin
       fdata.assign(dl1);
      end
      else begin
       dl1:= nil;
      end;
     end
     else begin
      if po1 <> nil then begin
       tdatalist1(fdata).internalfill(fgrid.rowcount,po1^);
      end
      else begin
       fdata.count:= fgrid.rowcount;
      end;
     end;
     fdata.maxcount:= fgrid.rowcountmax;
     fdata.onitemchange:= {$ifdef FPC}@{$endif}itemchanged;
    end;
  {$ifdef mse_with_ifi}
   end;
  {$endif}
   if gs_isdb in tcustomgrid1(fgrid).fstate then begin
    datasourcechanged;
   end;
   sourcenamechanged(-1);   
   tcustomgrid1(fgrid).layoutchanged;
  end
  else begin
   fintf:= nil;
   if (dl1 <> nil) and (dls_remote in dl1.state) then begin
    dl1:= nil; //no free
   end;
  end;
 finally
  dl1.free;
 end;
end;

procedure twidgetcol.getdata(var arow: integer; var dest);
var
 datatype: listdatatypety;
 info: cellinfoty;
 po1: pointer;
begin
 if fdata <> nil then begin
  if arow = -1 then begin
   arow:= twidgetgrid(fgrid).ffocusedcell.row;
  end;
  if arow >= 0 then begin
   tdatalist1(fdata).getgriddata(arow,dest);
  end
  else begin
   tdatalist1(fdata).getgriddefaultdata(dest);
  end;
 end
 else begin
  if fintf <> nil then begin
   datatype:= fintf.getdatatype;
   if arow >= 0 then begin
    info.cell.row:= arow;
//    info.griddatalink:= tcustomwidgetgrid(fgrid).getgriddatalink;
    po1:= fintf.getrowdatapo(info.cell.row);
   end
   else begin
    po1:= nil;
   end;
   case datatype of
    dl_integer: begin
     if po1 = nil then begin
      integer(dest):= 0;
     end
     else begin
      integer(dest):= pinteger(po1)^;
     end;
    end;
    dl_real: begin
     if po1 = nil then begin
      real(dest):= emptyreal;
     end
     else begin
      real(dest):= preal(po1)^;
     end;
    end;
    dl_datetime: begin
     if po1 = nil then begin
      tdatetime(dest):= emptydatetime;
     end
     else begin
      tdatetime(dest):= pdatetime(po1)^;
     end;
    end;
    dl_msestring: begin
     if po1 = nil then begin
      msestring(dest):= fintf.getnulltext;
     end
     else begin
      msestring(dest):= pmsestring(po1)^;
     end;
    end;
    dl_ansistring: begin
     if po1 = nil then begin
      ansistring(dest):= '';
     end
     else begin
      ansistring(dest):= pansistring(po1)^;
     end;
    end;
   end;     
  end;
 end;
end;

procedure twidgetcol.setdata(var arow: integer; const source;
                             const noinvalidate: boolean = false);
begin
 if fdata <> nil then begin
  if arow = -1 then begin
   arow:= twidgetgrid(fgrid).ffocusedcell.row;
  end;
  if arow >= 0 then begin
   if noinvalidate then begin
    fdata.beginupdate;
   end;
   tdatalist1(fdata).setgriddata(arow,source);
   if (arow = twidgetgrid(fgrid).ffocusedcell.row) and (fintf <> nil) then begin
    fintf.gridtovalue(arow);
   end;
   if noinvalidate then begin
    fdata.decupdate;
    if (not fdata.updating) and assigned(fonchange) then begin
     fonchange(self,arow);
    end;
   end;
  end;
 end
 else begin
  if assigned(fonchange) then begin
   fonchange(self,arow);
  end;
 end;
 datachange(arow);
end;

function twidgetcol.empty(arow: integer): boolean;
begin
 result:= true;
 if fdata <> nil then begin
  if arow = -1 then begin
   arow:= twidgetgrid(fgrid).ffocusedcell.row;
  end;
  if arow >= 0 then begin
   result:= tdatalist1(fdata).empty(arow);
  end;
 end;
end;

function twidgetcol.cangridcopy: boolean;
begin
 result:= tcustomwidgetgrid(fgrid).datacols.hasselection;
end;

procedure twidgetcol.updateeditoptions(var aoptions: optionseditty);
begin
 if not (gps_readonlyupdating in fstate) then begin
  updatebit(longword(foptions),ord(co_readonly),oe_readonly in aoptions);
  updatebit(longword(foptions),ord(co_savevalue),oe_savevalue in aoptions);
 end;
end;

function twidgetcol.showcaretrect(const arect: rectty;
                                       const aframe: tcustomframe): pointty;
begin
 result:= grid.showcaretrect(makerect(translateclientpoint(arect.pos,
              fintf.getwidget,fgrid),arect.size),aframe);
end;

procedure twidgetcol.widgetpainted(const canvas: tcanvas);
begin
 if co_drawfocus in foptions then begin
  with fintf.getwidget do begin
   if active then begin
    drawfocusrect(canvas,inflaterect(paintrect,ffocusrectdist));
   end;
  end;
 end;
end;

function twidgetcol.getdatapo(const arow: integer): pointer;
begin
 if (fdata = nil) then begin
  result:= nil;
  if fintf <> nil then begin
   result:= fintf.getrowdatapo(arow);
  end;
 end
 else begin
  result:= inherited getdatapo(arow);
 end;
end;

procedure twidgetcol.drawcell(const canvas: tcanvas);
var
 face1: tcustomface;
begin
 with cellinfoty(canvas.drawinfopo^) do begin
 {
  if (fdata <> nil) then begin
   if cell.row < fdata.count then begin
    datapo:= fdata.getitempo(cell.row);
   end
   else begin
    datapo:= nil;
   end;
  end
  else begin
   if fintf <> nil then begin
    datapo:= fintf.getrowdatapo(cellinfoty(canvas.drawinfopo^));
   end;
  end;
  }
  inherited;
  if fintf <> nil then begin
   if calcautocellsize then begin
    fintf.updateautocellsize(canvas);
   end
   else begin
    if (fface = nil) then begin
     face1:= fintf.getwidget.face;
     if face1 <> nil then begin
      face1.paint(canvas,cellinfoty(canvas.drawinfopo^).rect);
     end;
    end;
    fintf.drawcell(canvas);
   end;
  end;
 end;
end;

function twidgetcol.getrow: integer;
begin
 result:= twidgetgrid(fgrid).factiverow;
end;

procedure twidgetcol.setrow(arow: integer);
begin
 with twidgetgrid(fgrid) do begin
  focuscell(makegridcoord(colindex,arow));
 end;
end;

function twidgetcol.getcol: twidgetcol;
begin
 result:= self;
end;
{
procedure twidgetcol.cellchanged(const row: integer);
var
 int1: integer;
begin
 inherited;
 if (fintf <> nil) and (fdata <> nil) then begin
  int1:= fgrid.row;
  if (int1 >= 0) and ((row = int1) or (row < 0)) and (int1 < fdata.count) and
                 not (gs_rowremoving in tcustomgrid1(fgrid).fstate) then  begin
   fintf.gridtovalue(int1);
  end;
 end;
end;
}
{
procedure twidgetcol.changed;
begin
 inherited;
 if (fintf <> nil) and (fgrid.row >= 0) then begin
  fintf.gridtovalue(fgrid.row);
 end;
end;
}
function twidgetcol.getinnerframe: framety;
begin
 if fintf <> nil then begin
  result:= fintf.getcellframe;
 end
 else begin
  result:= inherited getinnerframe;
 end;
end;

function twidgetcol.geteditwidget: twidget;
begin
 if fintf = nil then begin
  result:= nil;
 end
 else begin
  result:= fintf.getwidget;
 end;
end;

procedure twidgetcol.seteditwidget(const value: twidget);
begin
 setwidget(value);
 if value <> nil then begin
  value.parentwidget:= twidgetgrid(fgrid).fcontainer2;
 end;
end;

procedure twidgetcol.drawfocusedcell(const acanvas: tcanvas);
var
 size1: sizety;
begin
 with tcustomwidgetgrid(fgrid) do begin
  if (factivewidget = nil) or not factivewidget.visible then begin
   inherited;
  end
  else begin
   with fcellinfo do begin
    if calcautocellsize then begin
     size1:= rect.size;
     twidget1(factivewidget).getautopaintsize(size1);
     factivewidget.painttowidgetsize(size1);
     if size1.cx > autocellsize.cx then begin
      autocellsize.cx:= size1.cx;
     end;
     if size1.cy > autocellsize.cy then begin
      autocellsize.cy:= size1.cy;
     end;
    end;
   end;
  end
 end;
end;

procedure twidgetcol.drawfocus(const acanvas: tcanvas);
begin
 with tcustomwidgetgrid(fgrid) do begin
  if (factivewidget = nil) or not factivewidget.visible then begin
   inherited;
  end;
 end;
 //else no paint, done in widgetpainted
end;

function twidgetcol.sortcompare(const index1,index2: integer): integer;
begin
 if (fintf <> nil) then begin
  if fdata <> nil then begin
   with tdatalist1(fdata) do begin
    result:= fintf.sortfunc((fdatapo+index1*fsize)^,(fdatapo+index2*fsize)^);
   end;
  end;
 end
 else begin
  result:= inherited sortcompare(index1,index2);
 end;
end;

procedure twidgetcol.itemchanged(const sender: tdatalist; const aindex: integer);
begin
 inherited;
 if {(tcustomwidgetgrid(fgrid).fupdating = 0) and} (fintf <> nil) and
               not (gs_rowremoving in tcustomgrid1(fgrid).fstate) and
               not (gps_changelock in fstate)then begin
  fintf.gridvaluechanged(aindex);
  if ((aindex < 0) or (aindex = grid.row)) and (grid.row >= 0) then begin
   fintf.gridtovalue(aindex);
  end;
 end;
end;

function twidgetcol.actualfont: tfont;
begin
 if fintf <> nil then begin
  result:= twidget1(fintf.getwidget).getfont;
 end
 else begin
  result:= inherited actualfont;
 end;
end;

procedure twidgetcol.setoptions(const avalue: coloptionsty);
var
 aoptions: coloptionsty;
begin
 aoptions:= avalue;
// if co_nohscroll in aoptions then begin
//  include(aoptions,co_nofocus);
// end;
 inherited setoptions(aoptions);
 if fintf <> nil then begin
//  fintf.updatecoloptions(aoptions);
  fintf.updatecoloptions(foptions);
 end;
end;

function twidgetcol.getcursor(const arow: integer; 
                            const actcellzone: cellzonety): cursorshapety;
begin
 result:= inherited getcursor(arow,actcellzone);
 if (result = cr_default) and (fintf <> nil){ and 
                         not (co_readonly in foptions)} then begin
  result:= fintf.getcellcursor(arow,actcellzone);
 end;
end;

procedure twidgetcol.datasourcechanged;
begin
 if fintf <> nil then begin
  fintf.griddatasourcechanged;
 end;
end;

function twidgetcol.nullcheckneeded(const newfocus: twidget): boolean;
begin
 with twidgetgrid(fgrid) do begin
  result:= (fnonullcheck = 0) and ({entered and} {or} 
            not (fcontainer1.checkdescendent(newfocus) or 
                  fcontainer3.checkdescendent(newfocus))) and
             (row >= 0) and not ((row = rowhigh) and isautoappend);
 end;
end;

function twidgetcol.nonullcheck: boolean;
begin
 result:= tcustomgrid1(fgrid).fnonullcheck > 0;
end;

function twidgetcol.nocheckvalue: boolean;
begin
 with tcustomgrid1(fgrid) do begin
  result:= (fnocheckvalue > 0) or (gs_rowremoving in fstate);
 end;
end;

{$ifdef mse_with_ifi}
procedure twidgetcol.updateifigriddata(const alist: tdatalist);
begin
 if (fdata <> nil) and not (dls_remote in fdata.state) {and 
                                               (alist <> nil)} then begin
  freeandnil(fdata); //free internal datalist
 end;
 if not (csdesigning in fgrid.componentstate) then begin
  setremotedatalist(idatalistclient(self),alist,fdata);
 end;
end;
{$endif}

function twidgetcol.getgrid: tcustomwidgetgrid;
begin
 result:= tcustomwidgetgrid(fgrid);
end;

function twidgetcol.getbrushorigin: pointty;
begin
 result:= tcustomwidgetgrid(fgrid).fbrushorigin;
end;

procedure twidgetcol.beforedragevent(var ainfo: draginfoty; const arow: integer;
                                      var processed: boolean);
begin
 if fintf <> nil then begin
  fintf.beforecelldragevent(ainfo,arow,processed);
 end;
end;

procedure twidgetcol.afterdragevent(var ainfo: draginfoty; const arow: integer;
                                      var processed: boolean);
begin
 if fintf <> nil then begin
  fintf.aftercelldragevent(ainfo,arow,processed);
 end;
end;

procedure twidgetcol.updatecellzone(const row: integer; const pos: pointty; var result: cellzonety);
begin
 inherited;
 if fintf <> nil then begin
  fintf.updatecellzone(row,pos,result);
 end;
end;

procedure twidgetcol.sourcenamechanged(const atag: integer);
var
 datalist1: tdatalist;
 str1: string;
 int1: integer;
begin
 if fdata <> nil then begin
  if atag >= 0 then begin
   str1:= fdata.getsourcename(atag);
   datalist1:= nil;
   if str1 <> '' then begin
    datalist1:= fgrid.datacols.datalistbyname(str1);
   end;
   fdata.linksource(datalist1,atag);
  end
  else begin
   for int1:= 0 to fdata.getsourcecount-1 do begin
    str1:= fdata.getsourcename(int1);  //link all source lists
    datalist1:= nil;
    if str1 <> '' then begin
     datalist1:= fgrid.datacols.datalistbyname(str1);
    end;
    fdata.linksource(datalist1,int1);
   end;
  end;
 end;
end;

procedure twidgetcol.datachange(const arow: integer);
begin
 if (datalist = nil) and not (gps_noinvalidate in fstate) and 
                     not (csloading in fgrid.componentstate) then begin
  checkdirtyautorowheight(arow);
 end;
end;

{ twidgetcols }

constructor twidgetcols.create(const aowner: tcustomwidgetgrid);
begin
 inherited create(aowner,twidgetcol);
end;

class function twidgetcols.getitemclasstype: persistentclassty;
begin
 result:= twidgetcol;
end;

procedure twidgetcols.datasourcechanged;
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  cols[int1].datasourcechanged;
 end;
end;

function twidgetcols.getcols(const index: integer): twidgetcol;
begin
 result:= twidgetcol(items[index]);
end;

procedure twidgetcols.unregisterchildwidget(const child: twidget);
var
 int1: integer;
begin
 with twidgetgrid(fgrid) do begin
  if factivewidget = child then begin
   factivewidget:= nil;
  end;
 end;
 int1:= 0;
 if not (gs_layoutupdating in tcustomwidgetgrid(fgrid).fstate) then begin
  while int1 < count do begin
   with cols[int1] do begin
    if (fintf <> nil) and (fintf.getwidget = child) then begin
     setwidget(nil);
     delete(int1);
    end
    else begin
     inc(int1);
    end;
   end;
  end;
 end;
end;

procedure twidgetcols.updatedatastate(var accepted: boolean);
var
 int1: integer;
begin
 if not (csdestroying in fgrid.componentstate) and 
         not (gs1_rowdeleting in twidgetgrid(fgrid).fstate1)then begin
  for int1:= 0 to count - 1 do begin
   if not accepted then begin 
    break;
   end;
   cols[int1].checkcanclose(accepted);
  end;
 end;
 inherited;
end;

{ twidgetfixcol }

constructor twidgetfixcol.create(const agrid: tcustomgrid;
                            const aowner: tgridarrayprop);
begin
 setlength(ffixrowwidgets,agrid.fixrows.count);
 inherited;
end;

destructor twidgetfixcol.destroy;
var
 int1: integer;
begin
 if not (csdestroying in fgrid.componentstate) then begin
  for int1:= 0 to high(ffixrowwidgets) do begin
   if ffixrowwidgets[int1] <> nil then begin
    freedesigncomponent(ffixrowwidgets[int1]);
                     //inhibit deleting of inherited widget
   end;
  end;
 end;
 inherited;
end;

procedure twidgetfixcol.readfixwidgetnames(reader: treader);
begin
 readstringar(reader,ffixrowwidgetnames);
end;

procedure twidgetfixcol.writefixwidgetnames(writer: twriter);
begin
 writewidgetnames(writer,ffixrowwidgets);
end;

procedure twidgetfixcol.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('fixwidgetnames',{$ifdef FPC}@{$endif}readfixwidgetnames,
                   {$ifdef FPC}@{$endif}writefixwidgetnames,
     (filer.ancestor = nil) and needswidgetnamewriting(ffixrowwidgets) or
     (filer.ancestor <> nil) and 
        needswidgetnamewriting(ffixrowwidgets,
                       twidgetfixcol(filer.ancestor).ffixrowwidgets));
end;

procedure twidgetfixcol.setfixrowwidget(const awidget: twidget; const rowindex: integer);
begin
 tcustomwidgetgrid(fgrid).removefixwidget(awidget);
 ffixrowwidgets[-rowindex-1]:= awidget;
 fgrid.layoutchanged;
end;

{ twidgetfixcols }

constructor twidgetfixcols.create(const aowner: tcustomwidgetgrid);
begin
 inherited create(aowner);
 fitemclasstype:= twidgetfixcol;
end;

function twidgetfixcols.getcols(const index: integer): twidgetfixcol;
begin
 result:= twidgetfixcol(inherited cols[index]);
end;

procedure twidgetfixcols.unregisterchildwidget(const child: twidget);
var
 int1,int2: integer;
begin
 if not (csdestroying in fgrid.componentstate) then begin
  for int1:= 0 to count - 1 do begin
   with twidgetfixcol(items[int1]) do begin
    for int2:= 0 to high(ffixrowwidgets) do begin
     if ffixrowwidgets[int2] = child then begin
      ffixrowwidgets[int2]:= nil;
      break;
     end;
    end;
   end;
  end;
 end;
end;

{ tdummywidget }

constructor tdummywidget.create(aowner: tcomponent);
begin
 inherited;
 foptionswidget:= defaultoptionswidgetnofocus; 
 exclude(fwidgetstate,ws_iswidget);
 size:= nullsize;
end;

function tdummywidget.setfocus(aactivate: boolean = true): boolean;
begin
 if canfocus then begin
  result:= inherited setfocus(aactivate);
 end
 else begin
  window.nofocus;
  result:= false;
 end;
end;

{ tcontainer }

procedure tcontainer1.doexit;
begin
// if fgrid.factivewidget <> nil then begin
//  fgrid.factivewidget.visible:= false;
// end;
 inherited;
end;

procedure tcontainer1.doenter;
begin
 if fgrid.factivewidget <> nil then begin
  fgrid.factivewidget.visible:= true;
 end;
 inherited;
end;

{ tfixcontainer }

constructor tfixcontainer.create(aowner: tcustomwidgetgrid);
begin
 fgrid:= aowner;
 inherited create({nil}aowner);
 include(fwidgetstate,ws_nopaint);
 exclude(fwidgetstate,ws_opaque);
 exclude(fwidgetstate,ws_iswidget);
 foptionswidget:= foptionswidget + 
            [ow_mousetransparent,ow_arrowfocusin,ow_arrowfocusout,ow_subfocus,
                          ow_focusbackonesc];
 setlockedparentwidget(aowner);
// parentwidget:= aowner;
end;

procedure tfixcontainer.unregisterchildwidget(const child: twidget);
begin
 twidgetfixrows(fgrid.ffixrows).unregisterchildwidget(child);
 inherited;
end;

procedure handlewidgetregionchanged(const self: twidget;
                       const grid: tcustomwidgetgrid; const sender: twidget);
var
 cell1,cell2: gridcoordty;
 int1,int2,int3: integer;
 pt1: pointty;
begin
 with self do begin 
  if not (gs_layoutupdating in grid.fstate) and 
      (grid.componentstate * [csdesigning,csloading,csdestroying] = 
       [csdesigning]) and (sender <> nil) and 
          (twidget1(sender).fparentwidget = self) then begin
   with grid do begin
    cell1:= widgetcell(sender);
    if cell1.row <> invalidaxis then begin
     if self = grid then begin
      pt1:= self.paintpos;
      pt1.x:= -pt1.x;
      pt1.y:= -pt1.y;
     end
     else begin
      pt1:= self.parentpaintpos;
     end;
     if (cellatpos(addpoint(
             rectcenter(sender.widgetrect),pt1),cell2) in 
                                               [ck_fixrow,ck_fixcolrow]) and
            ((cell1.col <> cell2.col) or (cell1.row <> cell2.row)) and
            (cellwidget(cell2) = nil) then begin
      if cell1.col >= 0 then begin
       datacols[cell1.col].ffixrowwidgets[-1-cell1.row]:= nil;
      end
      else begin
       fixcols[cell1.col].ffixrowwidgets[-1-cell1.row]:= nil;
      end;
      if cell2.col >= 0 then begin
       datacols[cell2.col].ffixrowwidgets[-1-cell2.row]:= sender;
      end
      else begin
       fixcols[cell2.col].ffixrowwidgets[-1-cell2.row]:= sender;
      end;
     end
     else begin
      with ffixrows[cell1.row] do begin
       height:= sender.bounds_cy;
       int1:= 0;
       int3:= 0;
       if cell1.col < 0 then begin
        int2:= -1-cell1.col;
        if (int2 < captionsfix.count) and (int2 >= 0) then begin
         with captionsfix[cell1.col] do begin
          int1:= mergedcx;
          int3:= mergedcy;
         end;
        end;
        ffixcols[cell1.col].width:= sender.bounds_cx - int1;
       end
       else begin
        if cell1.col < captions.count then begin
         with captions[cell1.col] do begin
          int1:= mergedcx;
          int3:= mergedcy;
         end;
        end;
        fdatacols[cell1.col].width:= sender.bounds_cx - int1;
       end;
       height:= sender.bounds_cy - int3;
      end;
     end;
     layoutchanged;
    end;
   end;
  end;
 end;
end;

procedure tfixcontainer.widgetregionchanged(const sender: twidget);
begin
 inherited;
 handlewidgetregionchanged(self,fgrid,sender);
end;
 
procedure tfixcontainer.dochildfocused(const sender: twidget);
begin
 inherited;
 fgrid.showcell(fgrid.widgetcell(sender));
end;

procedure tfixcontainer.doenter;
begin
 fgrid.flastfocusedfixwidget:= self;
 inherited;
end;

function tfixcontainer.focusback(const aactivate: boolean = true): boolean;
begin
 if (fgrid.factivewidget <> nil) and 
           (og_containerfocusbackonesc in fgrid.foptionsgrid) then begin
  fgrid.factivewidget.activate;
 end
 else begin
  result:= inherited focusback(aactivate);
 end;
end;
{
procedure tfixcontainer.dokeydown(var info: keyeventinfoty);
var
 cell1: gridcoordty;
 int1: integer;
 widget1: twidget;
 
 function checkarrowfocus(const awidget: twidget): boolean;
 begin
  if (awidget <> nil) and (ow_arrowfocus in awidget.optionswidget) and
      awidget.canfocus then begin
   result:= true;
   widget1:= awidget;
  end
  else begin
   result:= false;
  end;
 end;
 
begin
 with info do begin
  cell1:= fgrid.widgetcell(focusedchild);
  cell1.row:= cell1.row + fgrid.ffixrows.count; //positive index
  widget1:= nil;
  include(eventstate,es_processed);
  if shiftstate = [] then begin
   case key of
    key_right: begin
     if cell1.col >= 0 then begin
      for int1:= cell1.col + 1 to fgrid.datacols.count - 1 do begin
       if checkarrowfocus(twidgetcol(fgrid.fdatacols.items[int1]).
                            ffixrowwidgets[cell1.row]) then begin
        break;
       end;
      end;
      if widget1 = nil then begin
       for int1:= 0 to fgrid.ffixcols.opositecount - 1 do begin
        if checkarrowfocus(twidgetfixcol(fgrid.ffixcols.items[int1]).
                             ffixrowwidgets[cell1.row]) then begin
          break;
        end;
       end;
       if widget1 = nil then begin
        for int1:= fgrid.ffixcols.opositecount to fgrid.ffixcols.count - 1 do begin
         if checkarrowfocus(twidgetfixcol(fgrid.ffixcols.items[int1]).
                              ffixrowwidgets[cell1.row]) then begin
           break;
         end;
        end;
        if widget1 = nil then begin
         for int1:= fgrid.fdatacols.count - 1 downto cell1.col+1 do begin
          if checkarrowfocus(twidgetcol(fgrid.fdatacols.items[int1]).
                               ffixrowwidgets[cell1.row]) then begin
            break;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
    key_left: begin
     if cell1.col >= 0 then begin
      for int1:= cell1.col - 1 downto 0 do begin
       if checkarrowfocus(twidgetcol(fgrid.fdatacols.items[int1]).
                            ffixrowwidgets[cell1.row]) then begin
        break;
       end;
      end;
      if widget1 = nil then begin
       for int1:= fgrid.ffixcols.count - 1 downto fgrid.ffixcols.opositecount do begin
        if checkarrowfocus(twidgetfixcol(fgrid.ffixcols.items[int1]).
                             ffixrowwidgets[cell1.row]) then begin
          break;
        end;
       end;
       if widget1 = nil then begin
        for int1:= fgrid.ffixcols.opositecount - 1 downto 0 do begin
         if checkarrowfocus(twidgetfixcol(fgrid.ffixcols.items[int1]).
                              ffixrowwidgets[cell1.row]) then begin
           break;
         end;
        end;
        if widget1 = nil then begin
         for int1:= fgrid.fdatacols.count - 1 downto cell1.col+1 do begin
          if checkarrowfocus(twidgetcol(fgrid.fdatacols.items[int1]).
                               ffixrowwidgets[cell1.row]) then begin
            break;
          end;
         end;
        end;
       end;
      end;
     end;
    end;
    else begin
     exclude(eventstate,es_processed);
    end;
   end;
  end
  else begin
   exclude(eventstate,es_processed);
  end;
  if not (es_processed in eventstate) then begin
   inherited;
  end
  else begin
   if widget1 <> nil then begin
    widget1.setfocus;
   end;
  end;
 end;
end;
}

{ twidgetdummy }

constructor twidgetdummy.create(aowner: tcustomwidgetgrid);
begin
 fgrid:= aowner;
 inherited create(nil{aowner});
 foptionswidget:= [];
 include(fwidgetstate,ws_nopaint);
 exclude(fwidgetstate,ws_iswidget);
 widgetrect:= nullrect;
 parentwidget:= aowner.fcontainer2;
end;

{ tgridcontainer }

constructor tgridcontainer.create(aowner: tcustomwidgetgrid);
begin
 fgrid:= aowner;
 inherited create(nil{aowner});
 include(fwidgetstate,ws_nopaint);
 exclude(fwidgetstate,ws_opaque);
 exclude(fwidgetstate,ws_iswidget);
 foptionswidget:= foptionswidget + [ow_mousetransparent,
                                    ow_subfocus,ow_focusbackonesc];
 foptionswidget:= foptionswidget - [ow_tabfocus];
 setlockedparentwidget(aowner);
// parentwidget:= aowner;
end;

procedure tgridcontainer.unregisterchildwidget(const child: twidget);
begin
 twidgetcols(fgrid.fdatacols).unregisterchildwidget(child);
 inherited;
end;

procedure tgridcontainer.dofocus;
begin
 if fgrid.factivewidget = nil then begin
  fgrid.setfocus;
 end
 else begin
  fgrid.factivewidget.visible:= true;
  inherited;
 end;
end;

function tgridcontainer.focusback(const aactivate: boolean = true): boolean;
begin
 if fgrid.flastfocusedfixwidget <> nil then begin
  fgrid.flastfocusedfixwidget.setfocus(aactivate);
  result:= true;
 end
 else begin
  result:= inherited focusback(aactivate);
 end;
end;

procedure tgridcontainer.doenter;
begin
 fgrid.invalidatefocusedcell;
 inherited;
end;

procedure tgridcontainer.doexit;
begin
 fgrid.invalidatefocusedcell;
 inherited;
end;

{ tscrollgridcontainer }

procedure tscrollgridcontainer.widgetregionchanged(const sender: twidget);
var
 int1,int2,int3,int4: integer;
 po1: pointty;
 rect1: rectty;
begin
 if not (csdestroying in fgrid.componentstate) then begin
  inherited;
  if not (gs_layoutupdating in fgrid.fstate) and 
      (fgrid.componentstate * [csdesigning,csloading] = 
       [csdesigning]) and (sender <> nil) and (flayoutupdating = 0) and 
          (twidget1(sender).fparentwidget = self) then begin
   with fgrid do begin
    int3:= -1;
    for int1:= 0 to datacols.count-1 do begin
     with datacols[int1] do begin
      if sender = editwidget then begin
       int3:= int1;
       break;
      end;
     end
    end;  
    if int3 >= 0 then begin
     int4:= sender.bounds_cy; //updatelayout modifies widgetrect
     rect1:= cellrect(makegridcoord(0,0));
     po1:= translatepaintpoint(nullpoint,sender,fgrid);
     int2:= datacols.count;
     for int1:= 0 to datacols.count-1 do begin
      with datacols[int1] do begin
       if po1.x < rect1.x + width div 2 then begin
        int2:= int1;
        break;
       end;
       inc(rect1.x,step);
      end;
     end;
     if int2 > int3 then begin
      dec(int2);
     end;
     inc(flayoutupdating);
     try
      sender.bounds_cy:= int4;
      datarowheight:= int4;
      datacols[int3].width:= sender.bounds_cx;
      layoutchanged;
      if int3 <> int2 then begin
       movecol(int3,int2);
      end;
     finally
      dec(flayoutupdating);
     end;
    end;
    internalupdatelayout;
    //updatelayout;
   end;
  end;
 end;
end;

{ tnoscrollgridcontainer }
{
constructor tnoscrollgridcontainer.create(aowner: tcustomwidgetgrid);
begin
 inherited;
 optionswidget:= optionswidget - [ow_arrowfocusin];
end;
}
{ tcustomwidgetgrid }

constructor tcustomwidgetgrid.create(aowner: tcomponent);
begin
 fmousefocusedcell.col:= -1;
 inherited;
 fcontainer0:= tnoscrollgridcontainer.create(self);
 fcontainer0.name:= '_co0'; //debug purpose
 fcontainer1:= ttopcontainer.create(self);
 fcontainer1.name:= '_co1'; //debug purpose
 fcontainer2:= tscrollgridcontainer.create(self);
 fcontainer2.name:= '_co2'; //debug purpose
 fcontainer3:= tbottomcontainer.create(self);
 fcontainer3.name:= '_co3'; //debug purpose
 fwidgetdummy:= tdummywidget.create(self);
 include(fstate,gs_layoutupdating);
 fwidgetdummy.setlockedparentwidget(fcontainer2);
 exclude(fstate,gs_layoutupdating);
// fwidgetdummy.parentwidget:= fcontainer2;
 setoptionsgrid(foptionsgrid); //synchronize container
// fcontainer.Name:= 'container';
end;

destructor tcustomwidgetgrid.destroy;
begin
 flastfocusedfixwidget:= nil;
 fwidgetdummy.free;
 fcontainer1.free;
 freeandnil(fcontainer2);
 freeandnil(fcontainer0);
 fcontainer3.free;
 inherited;
end;

procedure tcustomwidgetgrid.setoptionsgrid(const avalue: optionsgridty);
begin
 if fcontainer2 <> nil then begin
  with fcontainer2 do begin
   if og_containerfocusbackonesc in avalue then begin
    optionswidget:= optionswidget + [ow_focusbackonesc];
   end
   else begin
    optionswidget:= optionswidget - [ow_focusbackonesc];
   end;
  end;
 end;
 if fcontainer0 <> nil then begin
  with fcontainer0 do begin
   if og_containerfocusbackonesc in avalue then begin
    optionswidget:= optionswidget + [ow_focusbackonesc];
   end
   else begin
    optionswidget:= optionswidget - [ow_focusbackonesc];
   end;
  end;
 end;
 inherited;
end;

procedure tcustomwidgetgrid.createdatacol(const index: integer;
  out item: tdatacol);
begin
 item:= twidgetcol.create(self,fdatacols);
end;

procedure tcustomwidgetgrid.updatecontainerrect;
var
 rect1: rectty;
begin
 if fcontainer0 <> nil then begin
  rect1:= fdatarecty;
  fcontainer0.widgetrect:= moverect(rect1,paintpos);
                      //for nohscroll widgets
 end;
 rect1:= fdatarectx;
 if fcontainer1 <> nil then begin
  rect1.cy:= fdatarect.y - rect1.y;
  fcontainer1.widgetrect:= moverect(rect1,paintpos);
 end;
 if fcontainer3 <> nil then begin
  rect1.y:= fdatarect.y + fdatarect.cy;
  rect1.cy:= fdatarectx.y + fdatarectx.cy - rect1.y;
  fcontainer3.widgetrect:= moverect(rect1,paintpos);
 end;
 if fcontainer2 <> nil then begin
  fcontainer2.widgetrect:= moverect(fdatarect,paintpos);
 {
  if csdesigning in componentstate then begin
   rect1:= fdatarect;
//   dec(rect1.x,ffirstnohscroll);
//   inc(rect1.cx,ffirstnohscroll);
  end
  else begin
   if noscrollingcol then begin
    rect1:= fdatarecty;
   end
   else begin
    rect1:= fdatarect;
   end;
  end;
  fcontainer2.widgetrect:= moverect(rect1,paintpos);
  }
 end;
end;
 
procedure tcustomwidgetgrid.updatelayout;
var
 int1: integer;
begin
 inherited;
 updatecontainerrect;
 for int1:= 0 to fdatacols.count - 1 do begin
  twidgetcols(fdatacols)[int1].updatewidgetrect
 end;
 twidgetfixrows(ffixrows).updatewidgetrect;
end;

procedure tcustomwidgetgrid.dofocusedcellposchanged;
begin
 if ffocusedcell.col >= 0 then begin
  twidgetcols(fdatacols)[ffocusedcell.col].updatewidgetrect;
 end;
 inherited;
end;

procedure tcustomwidgetgrid.dorowsmoved(const fromindex,toindex,count: integer);
var
 int1: integer;
begin
 if ffocusedcell.col >= 0 then begin
  if (focusedcell.row >= toindex) and (focusedcell.row < toindex + count) then begin
   for int1:= 0 to fdatacols.count - 1 do begin
    with twidgetcols(fdatacols)[int1] do begin
     if (co_norearange in foptions) and (fintf <> nil) then begin
      fintf.gridtovalue(ffocusedcell.row);           
     end;
    end;
   end;
  end;
 end;
 inherited;
end;

function tcustomwidgetgrid.getdatacols: twidgetcols;
begin
 result:= twidgetcols(fdatacols);
end;

procedure tcustomwidgetgrid.setdatacols(const avalue: twidgetcols);
begin
 inherited;
end;

function tcustomwidgetgrid.getfixcols: twidgetfixcols;
begin
 result:= twidgetfixcols(ffixcols);
end;

procedure tcustomwidgetgrid.setfixcols(const avalue: twidgetfixcols);
begin
 inherited;
end;

function tcustomwidgetgrid.getfixrows: twidgetfixrows;
begin
 result:= twidgetfixrows(ffixrows);
end;

procedure tcustomwidgetgrid.setfixrows(const avalue: twidgetfixrows);
begin
 inherited;
end;

procedure tcustomwidgetgrid.insertwidget(const awidget: twidget;
             const apos: pointty);
var
 po1: pointty;
 cell1,cell2: gridcoordty;
 intf: igridwidget;
begin
 if not (csloading in componentstate) then begin
  internalupdatelayout;
  po1:= subpoint(apos,paintpos);
  cell1:= cellatpos(po1);
  if (cell1.row <> invalidaxis) and (cell1.col <> invalidaxis) and 
            (cell1.row < 0) then begin
   if not checkdescendent(awidget) then begin //new insert
    exclude(twidget1(awidget).foptionswidget,ow_autoscale);
   end;
   if cell1.col >= 0 then begin
    datacols[cell1.col].setfixrowwidget(awidget,cell1.row);
   end
   else begin
    fixcols[cell1.col].setfixrowwidget(awidget,cell1.row);
   end;
  end
  else begin
   if (cell1.col >= 0) or (cell1.col = invalidaxis) then begin
    if not checkdescendent(awidget) then begin //new insert
     if not awidget.getcorbainterface(typeinfo(igridwidget),intf) then begin
      error(gre_invalidwidget);
     end;
     if cell1.col < 0 then begin
      cell1.col:= fdatacols.count;
     end
     else begin
      with twidgetcol(fdatacols[cell1.col]) do begin
       po1.x:= po1.x + (fend - fstart) div 2;
       cell2:= cellatpos(po1);
       if cell2.col <> cell1.col then begin
        inc(cell1.col); //next col
       end;
      end;
     end;
     fdatacols.insertdefault(cell1.col);
     awidget.parentwidget:= fcontainer2;
     datacols[cell1.col].setwidget(awidget);
     intf.initgridwidget;
    end;
   end
   else begin
    inherited;
   end;
  end;
 end
 else begin
  inherited;
 end;
end;

function tcustomwidgetgrid.editwidgetatpos(const apos: pointty; out cell: gridcoordty): twidget;
begin
 if cellatpos(apos,cell) = ck_data then begin
  result:= datacols[cell.col].editwidget;
 end
 else begin
  result:= nil;
 end;
end;

function tcustomwidgetgrid.widgetcell(const awidget: twidget): gridcoordty;
var
 int1,int2{,int3}: integer;
begin
 if awidget <> nil then begin
  for int1:= 0 to fdatacols.count - 1 do begin
   with twidgetcol(fdatacols.items[int1]) do begin
    if (fintf <> nil) and (fintf.getwidget = awidget) then begin
     result.col:= int1;
     result.row:= row;
     exit;
    end;
    for int2:= 0 to high(ffixrowwidgets) do begin
     if ffixrowwidgets[int2] = awidget then begin
      result.col:= int1;
      result.row:= -int2-1; //int2-ffixrows.count;
      exit;
     end;
    end;
   end;
  end;
  for int1:= 0 to ffixcols.count - 1 do begin
   with twidgetfixcol(ffixcols.items[int1]) do begin
    for int2:= 0 to high(ffixrowwidgets) do begin
     if ffixrowwidgets[int2] = awidget then begin
      result.col:= -int1 - 1; //int1 - fixcols.count;
      result.row:= -int2 - 1; //int2 - fixrows.count;
      exit;
     end;
    end;
   end;
  end;
 end;
 result:= invalidcell;
end;

function tcustomwidgetgrid.cellwidget(const acell: gridcoordty): twidget;
var
 co1,ro1: integer;
begin
 result:= nil;
 if acell.col >= 0 then begin
  if acell.col < fdatacols.count then begin
   if acell.row >= 0 then begin
    if acell.row < rowcount then begin
     result:= datacols[acell.col].getwidget;
    end;
   end
   else begin
    ro1:= -1-acell.row;
    with datacols[acell.col] do begin
     if ro1 <= high(ffixrowwidgets) then begin
      result:= ffixrowwidgets[ro1];
     end;
    end;
   end;
  end;
 end
 else begin
  co1:= -1-acell.col;
  if (co1 < fixcols.count) and (acell.row < 0) then begin
   ro1:= -1-acell.row;
   with twidgetfixcol(twidgetfixcols(ffixcols).fitems[co1]) do begin
    if ro1 <= high(ffixrowwidgets) then begin
     result:= ffixrowwidgets[ro1];
    end;
   end;
  end;
 end;
end;

function tcustomwidgetgrid.getcontainer: twidget;
begin
 result:= fcontainer2;
end;

function tcustomwidgetgrid.getchildwidgets(const index: integer): twidget;
var
 int1,int2: integer;
begin
 int2:= fcontainer2.childrencount;
 if index < int2 then begin
  result:= fcontainer2.children[index];
 end
 else begin
  int1:= index - int2;
  int2:= fcontainer0.childrencount;
  if int1 < int2 then begin
   result:= fcontainer0.children[int1];
  end;
  int1:= index - int2;
  int2:= fcontainer1.childrencount;
  if int1 < int2 then begin
   result:= fcontainer1.children[int1];
  end
  else begin
   result:= fcontainer3.children[int1-int2];
  end;
 end;
end;

procedure tcustomwidgetgrid.removefixwidget(const awidget: twidget);
var
 int1,int2: integer;
begin
 if awidget <> nil then begin
  if flastfocusedfixwidget = awidget then begin
   flastfocusedfixwidget:= nil;
  end;
  for int1:= 0 to high(twidgetcols(fdatacols).fitems) do begin
   with twidgetcol(twidgetcols(fdatacols).fitems[int1]) do begin
    for int2:= 0 to high(ffixrowwidgets) do begin
     if ffixrowwidgets[int2] = awidget then begin
      ffixrowwidgets[int2]:= nil;
     end;
    end;
   end;
  end; 
  for int1:= 0 to high(twidgetfixcols(ffixcols).fitems) do begin
   with twidgetfixcol(twidgetfixcols(ffixcols).fitems[int1]) do begin
    for int2:= 0 to high(ffixrowwidgets) do begin
     if ffixrowwidgets[int2] = awidget then begin
      ffixrowwidgets[int2]:= nil;
     end;
    end;
   end;
  end; 
 end;
end;

function tcustomwidgetgrid.childrencount: integer;
begin
 result:= fcontainer0.childrencount + fcontainer2.childrencount +
          fcontainer1.childrencount + fcontainer3.childrencount;
end;

function tcustomwidgetgrid.getlogicalchildren: widgetarty;
begin
 result:= inherited getlogicalchildren;
 fcontainer1.addlogicalchildren(result);
 fcontainer3.addlogicalchildren(result);
end;

function tcustomwidgetgrid.createdatacols: tdatacols;
begin
 result:= twidgetcols.create(self);
end;

function tcustomwidgetgrid.createfixrows: tfixrows;
begin
 result:= twidgetfixrows.create(self);
end;

function tcustomwidgetgrid.createfixcols: tfixcols;
begin
 result:= twidgetfixcols.create(self);
end;

procedure tcustomwidgetgrid.setoptionswidget(const avalue: optionswidgetty);
begin
 inherited setoptionswidget(avalue - [ow_subfocus]); 
end;
{
procedure tcustomwidgetgrid.focusedcellchanged;
begin
 inherited;
 if col >= 0 then begin
  with twidgetcol(twidgetcols(fdatacols).fitems[col]) do begin
   updatewidgetrect(true);
  end;
 end; 
end;
}
procedure tcustomwidgetgrid.dofocus;
begin
 inherited;
 if (factivewidget <> nil) and (factivewidget <> fwidgetdummy) then begin
  factivewidget.visible:= true;
  if factivewidget.canfocus then begin
   factivewidget.setfocus(false);
  end;
 end;
end;

procedure tcustomwidgetgrid.unregisterchildwidget(const child: twidget);
begin
 twidgetfixrows(ffixrows).unregisterchildwidget(child);
 twidgetfixcols(ffixcols).unregisterchildwidget(child);
 inherited;
end;

procedure tcustomwidgetgrid.widgetregionchanged(const sender: twidget);
begin
 inherited;
 handlewidgetregionchanged(self,self,sender);
end;

procedure tcustomwidgetgrid.scrolled(const dist: pointty);
var
 po1: pointty;
 bo1: boolean;
begin
 po1:= dist;
 if csdesigning in componentstate then begin
  po1.y:= 0;
 end;
 twidget1(fcontainer2).scrollwidgets(po1);
 po1.x:= 0;
 twidget1(fcontainer0).scrollwidgets(po1);
 if dist.x <> 0 then begin
  if csdesigning in componentstate then begin
   bo1:= gs_layoutupdating in fstate;
   include(fstate,gs_layoutupdating);
   try
    twidgetfixrows(ffixrows).updatewidgetrect;
   finally
    if not bo1 then begin
     exclude(fstate,gs_layoutupdating);
    end;
   end;
  end
  else begin
   twidgetfixrows(ffixrows).updatewidgetrect;
  end;
 end;
 inherited;
end;

procedure tcustomwidgetgrid.getchildren(proc: tgetchildproc; root: tcomponent);
begin
 inherited;
 twidget1(fcontainer2).getchildren(proc,root);
 twidget1(fcontainer0).getchildren(proc,root);
 twidget1(fcontainer1).getchildren(proc,root);
 twidget1(fcontainer3).getchildren(proc,root);
end;

//procedure tcustomwidgetgrid.loaded;
procedure tcustomwidgetgrid.doendread;
var
 int1,int2,int3: integer;
 ar1: widgetarty;
 ar2: array of igridwidget;
 str1: string;
 intf1: igridwidget;
begin
 inc(tgridcontainer(fcontainer2).flayoutupdating);
 include(fstate,gs_layoutupdating);
 try
  ar1:= copy(fwidgets);
  for int1:= 0 to high(fwidgets) do begin
   with twidget1(fwidgets[int1]) do begin
    for int2:= 0 to high(fwidgets) do begin
     additem(pointerarty(ar1),pointer(fwidgets[int2])); 
           //add children, possibly inherited
    end;
   end;
  end;
  if (csdesigning in componentstate) then begin
   setlength(ar2,length(ar1)); //init check deleted widgets
   for int1:= 0 to high(ar2) do begin
    if ar1[int1].getcorbainterface(typeinfo(igridwidget),intf1) and
                                (intf1.getgridintf <> nil) then begin
     ar2[int1]:= intf1;
    end;
   end;
  end;
  for int1:= 0 to fdatacols.count - 1 do begin
   with twidgetcols(fdatacols)[int1] do begin
    for int2:= 0 to high(ar1) do begin
     if ar1[int2] <> nil then begin
      str1:= findpastedcomponentname(ar1[int2]);
      if str1 = '' then begin
       str1:= ar1[int2].name;
      end;
      if str1 <> '' then begin
       if (str1 = fwidgetname) then begin
        ar1[int2].parentwidget:= fcontainer2;
        if (csdesigning in componentstate) then begin
         ar2[int2]:= nil; //linked
        end;
        fintf:= nil;    
            //do not remove existing link, inherited order could be changed
        setwidget(ar1[int2]);
        ar1[int2]:= nil;
       end;
       if ar1[int2] <> nil then begin
        for int3:= 0 to high(ffixrowwidgetnames) do begin
         if str1 = ffixrowwidgetnames[int3] then begin
          setfixrowwidget(ar1[int2],-int3-1);
          ffixrowwidgetnames[int3]:= '';
          ar1[int2]:= nil;
          break;
         end;
        end;
       end;
      end;
     end;
    end;
//    fwidgetname:= '';
    ffixrowwidgetnames:= nil;
   end;
  end;
  if csdesigning in componentstate then begin //check deleted inherited widgets
   for int1:= 0 to high(ar2) do begin
    if ar2[int1] <> nil then begin
     ar2[int1].setgridintf(nil);
    end;
   end;
  end;
  for int1:= 0 to fdatacols.count - 1 do begin
   twidgetcols(fdatacols)[int1].sourcenamechanged(-1);
  end;
  for int1:= 0 to ffixcols.count - 1 do begin
   with twidgetfixcol(ffixcols.items[int1]) do begin
    for int2:= 0 to high(ar1) do begin
     if ar1[int2] <> nil then begin
      str1:= ar1[int2].name;
      if str1 <> '' then begin
       for int3:= 0 to high(ffixrowwidgetnames) do begin
        if str1 = ffixrowwidgetnames[int3] then begin
         setfixrowwidget(ar1[int2],-int3-1);
         ffixrowwidgetnames[int3]:= '';
         ar1[int2]:= nil;
         break;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 finally
  exclude(fstate,gs_layoutupdating);
  dec(tgridcontainer(fcontainer2).flayoutupdating);
 end;
 inherited;
end;
{
procedure tcustomwidgetgrid.widgetremoved(const child: twidget);
begin
 twidgetcols(fdatacols).unregisterchildwidget(child);
end;
}
function tcustomwidgetgrid.scrollcaret(const vertical: boolean): boolean;
begin
 result:= (factivewidget <> nil) and 
            ((factivewidget.parentwidget = fcontainer2) or vertical) and
                                 twidget1(factivewidget).hascaret;
end;

function tcustomwidgetgrid.checkreflectmouseevent(var info: mouseeventinfoty;
            iscellcall: boolean): boolean;
var
 po1: pointty;
begin
 if {(fmousefocusedcell.col < 0) or }(es_child in info.eventstate) then begin
  result:= false;
 end
 else begin
  if iscellcall then begin
   po1:= cellrect(ffocusedcell).pos;
   addpoint1(po1,clientwidgetpos);
   addpoint1(info.pos,po1);
  end;
  result:= (factivewidget <> nil) and
     ((fmouseactivewidget <> factivewidget) or
      {(ffocusedcell.col <> fmousefocusedcell.col) or}
      (ffocusedcell.row <> fmousefocusedcell.row)) and
       (mouseeventwidget(info) = factivewidget);
  if iscellcall then begin
   subpoint1(info.pos,po1);
  end;
 end;
end;

procedure tcustomwidgetgrid.childmouseevent(const sender: twidget; 
                        var info: mouseeventinfoty);
var
 po1: pointty;
begin
 with info do begin
  if not (es_reflected in eventstate)  and
   (eventkind in [ek_mousemove,ek_mousepark,ek_buttonpress,ek_buttonrelease]) then begin
   po1:= translateclientpoint(nullpoint,sender,self);
   addpoint1(pos,po1);
   if sender = factivewidget then begin
    clientmouseevent(info);
   end
   else begin
    with fobjectpicker do begin
     if (sender <> fcontainer2) and (sender <> self) and
            ((fpickkind = pok_datacolsize) or (eventkind <> ek_buttonpress)) then begin
      include(fstate,gs_child);
      mouseevent(info);
      exclude(fstate,gs_child);
      if not (fpickkind in [pok_datacolsize,pok_datacol]) then begin
       exclude(eventstate,es_processed);
      end
      else begin
       include(eventstate,es_processed);
      end;
     end;
    end;
   end;
   subpoint1(pos,po1);
  end;
 end;
 inherited;
end;

procedure tcustomwidgetgrid.clientmouseevent(var info: mouseeventinfoty);
begin
 fmouseinfopo:= @info;
 try
  inherited;
 finally;
//  fmouseinfopo:= @info;
  fmouseinfopo:= nil;
 end;
 if (info.eventkind = ek_buttonpress) and 
                    (factivewidget <> nil) and entered then begin
  include(info.eventstate,es_nofocus); //do not set focus to grid
 end;
 if (info.eventkind = ek_buttonrelease) and (info.button = mb_left) and 
      (gs_childmousecaptured in fstate) then begin
  exclude(fstate,gs_childmousecaptured);
  releasemouse;
 end;
end;

procedure tcustomwidgetgrid.initcopyars(out dataedits: widgetarty;
                                              out datalists: datalistarty);
var
 int1: integer;
begin
 setlength(dataedits,datacols.count);
 setlength(datalists,length(dataedits));
 for int1:= 0 to high(dataedits) do begin
  dataedits[int1]:= datacols[int1].editwidget;
  datalists[int1]:= datacols[int1].datalist;
  if not (dataedits[int1] is tcustomdataedit) or 
        not tdataedit1(dataedits[int1]).textcellcopy then begin
   dataedits[int1]:= nil;
  end;
 end;
end;

function tcustomwidgetgrid.copyselection: boolean;
var
 ar2: widgetarty;
 ar3: datalistarty;
 ar1: gridcoordarty;
 wstr1,wstr2: msestring;
 int1,int2: integer;

begin
 result:= inherited copyselection;
 if result then begin
  exit;
 end;
 ar1:= datacols.selectedcells;
 if ar1 <> nil then begin
  initcopyars(ar2,ar3);
  wstr1:= '';
  int2:= ar1[0].row;
  for int1:= 0 to high(ar1) do begin
   with ar1[int1] do begin
    if row <> int2 then begin
     removetabterminator(wstr1);
     wstr1:= wstr1 + lineend;
     int2:= row;
    end;
    wstr2:= '';
    if co_cancopy in datacols[ar1[int1].col].foptions then begin
     if ar2[col] <> nil then begin
      with tdataedit1(ar2[col]) do begin
       wstr2:= datatotext(ar3[col].getitempo(row)^);
      end;
     end
     else begin
      if ar3[col] <> nil then begin
       wstr2:= ar3[col].getastext(row);
       {
       case ar3[col].datatype of
        dl_integer: wstr2:= inttostr(tintegerdatalist(ar3[col]).items[row]);
       end;
       }
      end;
     end;
     wstr1:= wstr1 + wstr2 + c_tab;
    end;
   end;
  end;
  removetabterminator(wstr1);
  wstr1:= wstr1 + lineend; //terminator
  copytoclipboard(wstr1);
  result:= true;
 end;
end;

function tcustomwidgetgrid.pasteselection: boolean;
var
 ar2: widgetarty;
 ar3: datalistarty;
 ar1: gridcoordarty;
 wstr1: msestring;
 int1,int2,int3,int5: integer;
 ar4,ar5: msestringarty;
 bo1,bo2: boolean;

begin
 result:= inherited pasteselection;
 if result then begin
  exit;
 end;
 ar1:= nil; //compiler warning
 ar4:= nil;
 ar5:= nil;
 initcopyars(ar2,ar3);
// result:= false;
 bo1:= false;
 for int1:= 0 to datacols.count - 1 do begin
  if co_canpaste in datacols[int1].options then begin
   bo1:= true;
  end
  else begin
   ar2[int1]:= nil;
   ar3[int1]:= nil;
  end;
 end;
 if bo1 and pastefromclipboard(wstr1) then begin
  ar4:= breaklines(wstr1);
  if high(ar4) > 0 then begin
   if ar4[high(ar4)] = '' then begin
    setlength(ar4,high(ar4)); //remove terminator
   end;
   int5:= row;
   beginupdate;
   try
    datacols.clearselection;
    int1:= row;
    bo2:= og_rowinserting in optionsgrid;
    if bo2 then begin
     insertrow(row,length(ar4));
    end;
    if high(ar4) >= rowcount - int1 then begin
     setlength(ar4,rowcount-int1);
    end;
    for int1:= 0 to high(ar4) do begin
     if bo2 then begin
      datacols.selected[makegridcoord(invalidaxis,int5)]:= true;
     end;
     ar5:= splitstring(ar4[int1],c_tab);
     int3:= 0;
     for int2:= 0 to high(ar5) do begin
      while (int3 < datacols.count) and
                 not (co_canpaste in datacols[int3].options) do begin
       inc(int3);
      end;
      if int3 >= datacols.count then begin
       break;
      end;
      if not bo2 then begin
       datacols[int3].selected[int5]:= true;
      end;
      try
       if ar2[int3] <> nil then begin
        if ar3[int3] <> nil then begin
         tdataedit1(ar2[int3]).texttodata(ar5[int2],ar3[int3].getitempo(int5)^);
         ar3[int3].change(int5);         
        end;
       end
       else begin
        if ar3[int3] <> nil then begin
         ar3[int3].setastext(int5,ar5[int2]);
         {
         case ar3[int3].datatype of
          dl_integer: begin
           tintegerdatalist(ar3[int3]).items[int5]:= strtoint(ar5[int2]);
          end;
         end;
         }
        end;
       end;
      except
      end;
      inc(int3);
     end;
     inc(int5);
    end;
   finally
    try
     updaterowdata;
    finally
     endupdate;
    end;
   end;
   result:= true;
  end;
 end;
end;

procedure tcustomwidgetgrid.mouseevent(var info: mouseeventinfoty);
begin
 fmousefocusedcell:= ffocusedcell;
 fmouseactivewidget:= factivewidget;
 inherited;
 if not(es_processed in info.eventstate) and 
          not (gs_mousecellredirected in fstate) and 
                checkreflectmouseevent(info,false) then begin
  fmousefocusedcell.col:= -1;
  releasemouse;
  if ffocusedcell.col >= 0 then begin
   with twidgetcols(fdatacols)[ffocusedcell.col] do begin
    if fintf <> nil then begin
     fintf.setfirstclick;
    end;
   end;
  end;
  reflectmouseevent(info);
 end;
 fmousefocusedcell.col:= -1;
end;

procedure tcustomwidgetgrid.dowidgetcellevent(var info: celleventinfoty);
var
 int1: integer;
begin
  if (info.cell.col >= 0) and (info.cell.col < fdatacols.count) and
   (twidgetcols(fdatacols)[info.cell.col].fintf <> nil) then begin
       twidgetcols(fdatacols)[info.cell.col].fintf.docellevent(true,info);
        //chance to update info.cellzone
  end;
  for int1:= 0 to fdatacols.count - 1 do begin
   with twidgetcols(fdatacols)[int1] do begin
    if (fintf <> nil) and (info.cell.col <> int1) then begin
     fintf.docellevent(false,info);
    end;
   end;
  end;
end;

procedure tcustomwidgetgrid.docellevent(var info: celleventinfoty);
var
 int1: integer;
begin
 if (info.cellbefore.row <> info.newcell.row) and 
         ((info.eventkind = cek_enter) or 
                (info.eventkind = cek_focusedcellchanged) and 
                 (info.newcell.col = invalidaxis)) then begin
                      //there was no cek_enter
  for int1:= 0 to fdatacols.count - 1 do begin
   with twidgetcols(fdatacols)[int1] do begin
    if fintf <> nil then begin
     fintf.gridtovalue(info.newcell.row);
    end;
   end;
  end;
 end
 else begin
  if (info.eventkind = cek_exit) and (info.newcell.row < 0) and
                (info.selectaction <> fca_exitgrid) then begin
   for int1:= 0 to fdatacols.count - 1 do begin
    with twidgetcols(fdatacols)[int1] do begin
     if fintf <> nil then begin
      fintf.gridtovalue(-2);
     end;
    end;
   end;
  end;
 end;
// if not ((info.eventkind in mousecellevents) and
//       checkreflectmouseevent(info.mouseeventinfopo^,true)) then begin
  dowidgetcellevent(info);
// end;
 inherited;
end;

procedure tcustomwidgetgrid.checkcellvalue(var accept: boolean);
begin
 twidgetcols(fdatacols)[ffocusedcell.col].checkcanclose(accept);
end;

procedure tcustomwidgetgrid.dokeydown(var info: keyeventinfoty);
begin
 if not (es_child in info.eventstate) or 
         (window.focusedwidget = factivewidget) or 
         (factivewidget = nil) and 
          not (fcontainer1.entered or fcontainer3.entered) then begin
  inherited;
 end
 else begin
  if (info.key = key_escape) and (info.shiftstate = []) and 
   (og_containerfocusbackonesc in foptionsgrid) and 
   (flastfocusedfixwidget <> nil) and (factivewidget <> nil) and
   flastfocusedfixwidget.focused then begin
   factivewidget.activate;
  end;
 end;
end;

function tcustomwidgetgrid.getgriddatalink: pointer;
begin
 result:= nil;
end;

procedure tcustomwidgetgrid.doexit;
begin
 if canclose(nil) then begin
  flastfocusedfixwidget:= nil;
  if factivewidget <> nil then begin
   factivewidget.visible:= false;
  end;
  inherited;
 end;
end;

procedure tcustomwidgetgrid.checkrowreadonlystate;
begin
 inherited;
 if isdatacell(ffocusedcell) then begin
  with datacols[ffocusedcell.col] do begin
   if fintf <> nil then begin
    include(fstate,gps_readonlyupdating);
    fintf.setreadonly(isreadonly);
    exclude(fstate,gps_readonlyupdating);
   end;
  end;
 end;
end;

procedure tcustomwidgetgrid.updaterowdata;
var
 int1: integer;
begin
 for int1:= 0 to datacols.count - 1 do begin
  with twidgetcol(fdatacols[int1]) do begin
   if fintf <> nil then begin
    fintf.gridtovalue(-1); //restore grid value
   end;
  end;
 end;
end;

procedure tcustomwidgetgrid.focuslock;
begin
 beginupdate;
 inc(ffocuslock);
end;

procedure tcustomwidgetgrid.focusunlock;
begin
 dec(ffocuslock);
 if (ffocuslock = 0) and (col >= 0) then begin
  twidgetcol(twidgetcols(fdatacols).fitems[col]).updatewidgetrect;
 end;
 endupdate;
end;

procedure tcustomwidgetgrid.updatepopupmenu(var amenu: tpopupmenu;
               var mouseinfo: mouseeventinfoty);
var
 cell1: gridcoordty;
 widget1: twidget;
begin
 if not (es_child in mouseinfo.eventstate) then begin
  cell1:= cellatpos(mouseinfo.pos);
  if (cell1.col >= 0) and 
                   ((cell1.row >= 0) or (cell1.row = invalidaxis)) then begin
   with datacols[cell1.col] do begin
    if fintf <> nil then begin
     widget1:= fintf.getwidget;
     if widget1 <> nil then begin
      translateclientpoint1(mouseinfo.pos,self,widget1);
      mouseinfo.eventstate:= mouseinfo.eventstate + [es_parent,es_child];
      try
       fintf.updatepopupmenu(amenu,mouseinfo);
      finally    
       translateclientpoint1(mouseinfo.pos,widget1,self);
       mouseinfo.eventstate:= mouseinfo.eventstate - [es_parent,es_child];
      end;
     end;
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tcustomwidgetgrid.seteditfocus;
begin
 if factivewidget <> nil then begin
  factivewidget.activate;
 end
 else begin
  activate;
 end;
end;

procedure tcustomwidgetgrid.navigrequest(var info: naviginfoty);
begin
 inherited;
 if (info.nearest = fcontainer0) or (info.nearest = fcontainer2) then begin
  if factivewidget <> nil then begin
   factivewidget.show;
   info.nearest:= factivewidget;
  end;
 end;
end;

procedure tcustomwidgetgrid.dochildfocused(const sender: twidget);
begin
 if (sender <> fcontainer2) and (sender <> fcontainer0) then begin
  flastfocusedfixwidget:= sender;
 end;
 inherited;
end;

function tcustomwidgetgrid.cellhasfocus: boolean;
begin
 result:= fcontainer2.entered or fcontainer0.entered or focused;
end;

procedure registergriddatalistclass(const tag: ansistring;
       const createfunc: creategriddatalistty);
begin
 griddatalists.addunique(tag,{$ifndef FPC}@{$endif}createfunc);
end;

function createtgridmsestringdatalist(const aowner:twidgetcol): tdatalist;
begin
 result:= tgridmsestringdatalist.create(aowner);
end;

function createtgridansistringdatalist(const aowner:twidgetcol): tdatalist;
begin
 result:= tgridansistringdatalist.create(aowner);
end;

function createtgridpointerdatalist(const aowner:twidgetcol): tdatalist;
begin
 result:= tgridpointerdatalist.create(aowner);
end;

function createtgridintegerdatalist(const aowner:twidgetcol): tdatalist;
begin
 result:= tgridintegerdatalist.create(aowner);
end;

function createtgridint64datalist(const aowner:twidgetcol): tdatalist;
begin
 result:= tgridint64datalist.create(aowner);
end;

function createtgridenumdatalist(const aowner:twidgetcol): tdatalist;
begin
 result:= tgridenumdatalist.create(aowner);
end;

function createtgridenum64datalist(const aowner:twidgetcol): tdatalist;
begin
 result:= tgridenum64datalist.create(aowner);
end;

function createtgridrealdatalist(const aowner:twidgetcol): tdatalist;
begin
 result:= tgridrealdatalist.create(aowner);
end;

initialization
 griddatalists:= tpointeransistringhashdatalist.create;
 registergriddatalistclass(tgridmsestringdatalist.classname,
                     {$ifdef FPC}@{$endif}createtgridmsestringdatalist);
 registergriddatalistclass(tgridansistringdatalist.classname,
                     {$ifdef FPC}@{$endif}createtgridansistringdatalist);
 registergriddatalistclass(tgridpointerdatalist.classname,
                     {$ifdef FPC}@{$endif}createtgridpointerdatalist);
 registergriddatalistclass(tgridintegerdatalist.classname,
                     {$ifdef FPC}@{$endif}createtgridintegerdatalist);
 registergriddatalistclass(tgridint64datalist.classname,
                     {$ifdef FPC}@{$endif}createtgridint64datalist);
 registergriddatalistclass(tgridenumdatalist.classname,
                     {$ifdef FPC}@{$endif}createtgridenumdatalist);
 registergriddatalistclass(tgridenum64datalist.classname,
                     {$ifdef FPC}@{$endif}createtgridenum64datalist);
 registergriddatalistclass(tgridrealdatalist.classname,
                     {$ifdef FPC}@{$endif}createtgridrealdatalist);
finalization
 griddatalists.free;
end.

