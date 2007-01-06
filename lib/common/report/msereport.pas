{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msereport;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,msegui,msegraphics,msetypes,msewidgets,msegraphutils,mseclasses,
 msetabs,mseprinter,msestream;

const
 defaultrepppmm = 10;
 defaultreppagewidth = 190;
 defaultreppageheight = 270;
  
type
 tcustombandarea = class;
 tcustomrecordband = class;
 rendereventty = procedure(const sender: tobject;
                               const acanvas: tcanvas) of object;
 beforerenderrecordeventty = procedure(const sender: tcustomrecordband;
                                          var empty: boolean) of object;
 
 recordbandstatety = (rbs_rendering);
 recordbandstatesty = set of recordbandstatety; 
 
 tcustomrecordband = class(tpublishedwidget)
  private
   fbandarea: tcustombandarea;
   fonbeforerender: beforerenderrecordeventty;
   fonrender: rendereventty;
   fstate: recordbandstatesty;
  protected
   procedure setparentwidget(const avalue: twidget); override;   
   procedure internalpaint(const canvas: tcanvas); override;
   procedure render(const acanvas: tcanvas; var empty: boolean); virtual;
   procedure init; virtual;
   procedure beginrender;
   procedure endrender;
   function rendering: boolean;
   function bandheight: integer;
   procedure dobeforerender(var empty: boolean); virtual;
   procedure dorender(const acanvas: tcanvas); virtual;
  public
   property bandarea: tcustombandarea read fbandarea;
   property onbeforerender: beforerenderrecordeventty read fonbeforerender
                               write fonbeforerender;
   property onrender: rendereventty read fonrender write fonrender;
 end;

 trecordband = class(tcustomrecordband)
  published
   property onbeforerender;
   property onrender;
 end;
 
 recordbandarty = array of tcustomrecordband;
 
 bandareastatety = (bas_inited,bas_backgroundrendered,bas_areafull,
                    bas_rendering);
 bandareastatesty = set of bandareastatety; 

 tcustomreportpage = class;
   
 tcustombandarea = class(tpublishedwidget)
  private
   fbands: recordbandarty;
   fstate: bandareastatesty;
   factiveband: integer;
   facty: integer;
   fsaveindex: integer;
   freportpage: tcustomreportpage;
   fonbeforerender: notifyeventty;
   fonrender: rendereventty;
  protected
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure setparentwidget(const avalue: twidget); override;   
   procedure internalpaint(const canvas: tcanvas); override;
   function beginband(const acanvas: tcanvas;
                               const sender: tcustomrecordband): boolean;
                    //true if area full
   procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
   procedure renderbackground(const acanvas: tcanvas);
   function areafull: boolean;
   function render(const acanvas: tcanvas): boolean;
          //true if finished
   function rendering: boolean;
   procedure beginrender;
   procedure endrender;
   procedure dobeforerender; virtual;
   procedure dorender(const acanvas: tcanvas); virtual;
   procedure init; virtual;
  public
   property onbeforerender: notifyeventty read fonbeforerender
                               write fonbeforerender;
   property onrender: rendereventty read fonrender write fonrender;
 end; 
 
 tbandarea = class(tcustombandarea)
  published
   property onbeforerender;
   property onrender;
 end;

 reportpagestatety = (rpps_inited,rpps_rendering,rpps_backgroundrendered);
 reportpagestatesty = set of reportpagestatety;
 
 bandareaarty = array of tcustombandarea;
  
 tcustomreportpage = class(twidget)
  private
   fareas: bandareaarty;
   fstate: reportpagestatesty;
   fonbeforerender: notifyeventty;
   fonrender: rendereventty;
   fpagewidth: real;
   fpageheight: real;
   fppmm: real;
   procedure setpagewidth(const avalue: real);
   procedure setpageheight(const avalue: real);
   procedure updatepagesize;
   procedure setppmm(const avalue: real);
  protected
   procedure setname(const newname: tcomponentname); override;
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure setparentwidget(const avalue: twidget); override;   

   procedure renderbackground(const acanvas: tcanvas);
   procedure beginrender;
   procedure endrender;
   function rendering: boolean;
   procedure beginarea(const acanvas: tcanvas; const sender: tcustombandarea);
   procedure dobeforerender; virtual;
   procedure dorender(const acanvas: tcanvas); virtual;
   procedure init; virtual;
   property ppmm: real read fppmm write setppmm; //pixel per mm
  public
   constructor create(aowner: tcomponent); override;
   function render(const acanvas: tcanvas): boolean;
          //true if finished
   property onbeforerender: notifyeventty read fonbeforerender
                               write fonbeforerender;
   property onrender: rendereventty read fonrender write fonrender;
   property pagewidth: real read fpagewidth write setpagewidth;
   property pageheight: real read fpageheight write setpageheight;
   property font: twidgetfont read getfont write setfont stored isfontstored;
 end;
 
 treportpage = class(tcustomreportpage)
  published
   property pagewidth;
   property pageheight;
   property color;
   property frame;
   property face;
   property visible;
   property font;
 
   property onbeforerender;
   property onrender;   
 end;

 treporttab = class(ttabpage)
  private
   fpage: tcustomreportpage;
   fppmm: real;
  protected
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure setparentwidget(const avalue: twidget); override;   
  public
   constructor create(aowner: tcomponent);overload; override;
   constructor create(const aowner: tcomponent;
                         const apage: tcustomreportpage); reintroduce; overload;
   destructor destroy; override;
 end;
 
 tcustomreport = class(tcustomtabwidget)
  private
   fppmm: real;
   procedure setppmm(const avalue: real);
  protected
   procedure insertwidget(const awidget: twidget; const apos: pointty); override;
   function internalrender(const acanvas: tcanvas; const aprinter: tprinter;
                   const acommand: string; const astream: ttextstream): boolean;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function render(const acanvas: tcanvas): boolean; overload;
                    //true if empty
   function render(const aprinter: tprinter; const command: string = ''): boolean;
                                       overload;  //true if empty
   function render(const aprinter: tprinter; const astream: ttextstream): boolean;
                                       overload;  //true if empty
   property ppmm: real read fppmm write setppmm; //pixel per mm
 end;

 treport = class(tcustomreport)
  protected
   class function getmoduleclassname: string; override;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean); 
                                     overload; virtual;   
  published    
   property bounds_x;
   property bounds_y;
   property bounds_cx;
   property bounds_cy;
   property color;
   property ppmm;
 end;

 reportclassty = class of treport;
  
function createreport(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
procedure initreportcomponent(const amodule: tcomponent; 
                                         const acomponent: tcomponent);

implementation
uses
 msedatalist,sysutils,msedrawtext;
type
 twidget1 = class(twidget);
 tmsecomponent1 = class(tmsecomponent);
 
function createreport(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
begin
 result:= reportclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

procedure initreportcomponent(const amodule: tcomponent;
                                           const acomponent: tcomponent);
begin
 if acomponent is twidget then begin
  twidget(acomponent).scale(tcustomreport(amodule).fppmm/defaultppmm);
 end;
end;

{ tcustomrecordband }

procedure tcustomrecordband.setparentwidget(const avalue: twidget);
begin
 if avalue is tcustombandarea then begin
  fbandarea:= tcustombandarea(avalue);
 end
 else begin
  fbandarea:= nil;
 end;
 inherited;
end;

procedure tcustomrecordband.dobeforerender(var empty: boolean);
begin
 if canevent(tmethod(fonbeforerender)) then begin
  fonbeforerender(self,empty);
 end;
end;

procedure tcustomrecordband.dorender(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonrender)) then begin
  fonrender(self,acanvas);
 end;
end;

procedure tcustomrecordband.render(const acanvas: tcanvas; var empty: boolean);
begin
 dobeforerender(empty);
 if not empty and visible then begin
  if fbandarea.beginband(acanvas,self) then begin
   exit;
  end;
  try
   inherited internalpaint(acanvas);
   dorender(acanvas);
  finally
   fbandarea.endband(acanvas,self);
  end;
 end;
end;

procedure tcustomrecordband.init;
begin
// fstate:= [];
end;

function tcustomrecordband.rendering: boolean;
begin
 result:= rbs_rendering in fstate;
end;

function tcustomrecordband.bandheight: integer;
begin
 result:= bounds_cy;
end;

procedure tcustomrecordband.internalpaint(const canvas: tcanvas);
begin
 if not rendering then begin
  inherited;
 end;
end;

procedure tcustomrecordband.beginrender;
begin
 fstate:= [rbs_rendering];
 include(fwidgetstate1,ws1_noclipchildren);
end;

procedure tcustomrecordband.endrender;
begin
 exclude(fstate,rbs_rendering);
 exclude(fwidgetstate1,ws1_noclipchildren);
end;

{ tcustombandarea }

procedure tcustombandarea.registerchildwidget(const child: twidget);
begin
 inherited;
 if child is tcustomrecordband then begin
  additem(pointerarty(fbands),child);
 end;
end;

procedure tcustombandarea.unregisterchildwidget(const child: twidget);
begin
 removeitem(pointerarty(fbands),child);
 inherited;
end;

procedure tcustombandarea.setparentwidget(const avalue: twidget);
begin
 if avalue is tcustomreportpage then begin
  freportpage:= tcustomreportpage(avalue);
 end
 else begin
  freportpage:= nil;
 end;
 inherited;
end;

function tcustombandarea.render(const acanvas: tcanvas): boolean;
var
 bo1: boolean;
begin
 result:= true;
 if not (bas_inited in fstate) then begin
  init;
 end;
 try
  dobeforerender;
  while (factiveband <= high(fbands)) and not areafull do begin
   bo1:= true;
   fbands[factiveband].render(acanvas,bo1);
   if bo1 or (bas_areafull in fstate) then begin
    result:= result and bo1;
    inc(factiveband);
   end;
  end;
 finally
  if result then begin
   exclude(fstate,bas_inited);
  end;
  exclude(fstate,bas_rendering);
 end;
end;

procedure tcustombandarea.init;
var
 int1: integer;
begin
  factiveband:= 0;
  include(fstate,bas_inited);
  for int1:= 0 to high(fbands) do begin
   fbands[int1].init;
  end;
end;

procedure tcustombandarea.dobeforerender;
begin
 if canevent(tmethod(fonbeforerender)) then begin
  fonbeforerender(self);
 end;
end;

procedure tcustombandarea.dorender(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonrender)) then begin
  fonrender(self,acanvas);
 end;
end;

procedure tcustombandarea.renderbackground(const acanvas: tcanvas);
begin
 freportpage.beginarea(acanvas,self);
 acanvas.origin:= pos;
 inherited internalpaint(acanvas);
 dorender(acanvas);
end;

function tcustombandarea.beginband(const acanvas: tcanvas;
                             const sender: tcustomrecordband): boolean;
begin
 fsaveindex:= acanvas.save;
 if not (bas_backgroundrendered in fstate) then begin
  include(fstate,bas_backgroundrendered);
  renderbackground(acanvas);
  facty:= innerclientwidgetpos.y + bounds_y;
 end;
 acanvas.origin:= makepoint(sender.bounds_x+bounds_x,facty);
 inc(facty,sender.bandheight);
 result:= facty > bounds_y + bounds_cy;
 if result then begin
  include(fstate,bas_areafull);
 end;
end;

procedure tcustombandarea.endband(const acanvas: tcanvas;
                                      const sender: tcustomrecordband);
begin
 acanvas.restore(fsaveindex); 
end;

function tcustombandarea.areafull: boolean;
begin
 result:= bas_areafull in fstate;
end;

procedure tcustombandarea.internalpaint(const canvas: tcanvas);
begin
 if not rendering then begin
  inherited;
 end;
end;

function tcustombandarea.rendering: boolean;
begin
 result:= bas_rendering in fstate;
end;

procedure tcustombandarea.beginrender;
var
 int1: integer;
begin
 fstate:= [bas_rendering];
 include(fwidgetstate1,ws1_noclipchildren);
 for int1:= 0 to high(fbands) do begin
  fbands[int1].beginrender;
 end;
end;

procedure tcustombandarea.endrender;
var
 int1: integer;
begin
 exclude(fstate,bas_rendering);
 exclude(fwidgetstate1,ws1_noclipchildren);
 for int1:= 0 to high(fbands) do begin
  fbands[int1].endrender;
 end;
end;

{ tcustomreportpage }

constructor tcustomreportpage.create(aowner: tcomponent);
begin
 inherited;
 fpagewidth:= defaultreppagewidth;
 fpageheight:= defaultreppageheight; 
 fppmm:= defaultrepppmm;
 with fwidgetrect do begin
  cx:= round(defaultreppagewidth*defaultrepppmm);
  cy:= round(defaultreppageheight*defaultrepppmm);
 end;
end;

procedure tcustomreportpage.registerchildwidget(const child: twidget);
begin
 inherited;
 if child is tcustombandarea then begin
  additem(pointerarty(fareas),child);
 end;
end;

procedure tcustomreportpage.unregisterchildwidget(const child: twidget);
begin
 removeitem(pointerarty(fareas),child);
 inherited;
end;

procedure tcustomreportpage.setparentwidget(const avalue: twidget);
begin
 inherited;
end;

procedure tcustomreportpage.init;
var
 int1: integer;
begin
 include(fstate,rpps_inited);
 for int1:= 0 to high(fareas) do begin
  fareas[int1].init;
 end;
end;

function tcustomreportpage.render(const acanvas: tcanvas): boolean;
var
 int1: integer;
begin
 if not (rpps_inited in fstate) then begin
  init;
 end;
 acanvas.reset;
 acanvas.intersectcliprect(makerect(nullpoint,fwidgetrect.size));
 dobeforerender;
 for int1:= 0 to high(fareas) do begin
  fareas[int1].render(acanvas);
 end;
 result:= not (rpps_backgroundrendered in fstate);
end;

function tcustomreportpage.rendering: boolean;
begin
 result:= rpps_rendering in fstate;
end;

procedure tcustomreportpage.dobeforerender;
begin
 if canevent(tmethod(fonbeforerender)) then begin
  fonbeforerender(self);
 end;
end;

procedure tcustomreportpage.dorender(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonrender)) then begin
  fonrender(self,acanvas);
 end;
end;

procedure tcustomreportpage.renderbackground(const acanvas: tcanvas);
begin
 acanvas.origin:= pos;
 inherited internalpaint(acanvas);
 dorender(acanvas);
 include(fstate,rpps_backgroundrendered);
end;

procedure tcustomreportpage.beginarea(const acanvas: tcanvas;
                                              const sender: tcustombandarea);
begin
 if not (rpps_backgroundrendered in fstate) then begin
  include(fstate,rpps_backgroundrendered);
  renderbackground(acanvas);
 end;
end;

procedure tcustomreportpage.beginrender;
var
 int1: integer;
begin
 fstate:= [rpps_rendering];
 include(fwidgetstate1,ws1_noclipchildren);
 for int1:= 0 to high(fareas) do begin
  fareas[int1].beginrender;
 end;
end;

procedure tcustomreportpage.endrender;
var
 int1: integer;
begin
 exclude(fstate,rpps_rendering);
 exclude(fwidgetstate1,ws1_noclipchildren);
 for int1:= 0 to high(fareas) do begin
  fareas[int1].endrender;
 end;
end;

procedure tcustomreportpage.setname(const newname: tcomponentname);
begin
 inherited;
 if fparentwidget is treporttab then begin
  treporttab(fparentwidget).caption:= newname;
 end;
end;

procedure tcustomreportpage.setpagewidth(const avalue: real);
begin
 if fpagewidth <> avalue then begin
  fpagewidth:= avalue;
  updatepagesize;
 end;
end;

procedure tcustomreportpage.setpageheight(const avalue: real);
begin
 if fpageheight <> avalue then begin
  fpageheight:= avalue;
  updatepagesize;
 end;
end;

procedure tcustomreportpage.updatepagesize;
begin
 size:= makesize(round(fpagewidth*fppmm),round(fpageheight*fppmm));
end;

procedure tcustomreportpage.setppmm(const avalue: real);
var
 rea1: real;
 int1: integer;
begin
 if avalue <> fppmm then begin
  rea1:= avalue/fppmm;
  fppmm:= avalue;
  if not (csloading in componentstate) then begin
   scale(rea1);
  end;
  updatepagesize;
 end;
end;

 {tcustomreport}
 
constructor tcustomreport.create(aowner: tcomponent);
begin
 fppmm:= defaultrepppmm;
 inherited;
end;

destructor tcustomreport.destroy;
var
 int1: integer;
begin
 for int1:= count - 1 downto 0 do begin
  items[int1].free; //tabs have no ws_iswidget
 end;
 inherited;
end;

procedure tcustomreport.setppmm(const avalue: real);
var
 int1: integer;
begin
 if avalue <> fppmm then begin
  if avalue <= 0 then begin
   raise exception.create('Invalid value');
  end;
  fppmm:= avalue;
  for int1:= 0 to count - 1 do begin
   with treporttab(items[int1]) do begin
    if fpage <> nil then begin
     fpage.ppmm:= avalue;
    end;
   end;
  end;
 end;
end;

procedure tcustomreport.insertwidget(const awidget: twidget;
               const apos: pointty);
var
 page1: treporttab;
begin
 if csloading in componentstate then begin
  inherited;
 end
 else begin
  if not (awidget is tcustomreportpage) then begin
   raise exception.create('Invalid widget');
  end
  else begin
   page1:= treporttab.create(self,tcustomreportpage(awidget));
   inherited insertwidget(page1,apos);
  end;
 end;
end;

function tcustomreport.internalrender(const acanvas: tcanvas;
               const aprinter: tprinter; const acommand: string;
               const astream: ttextstream): boolean;
var
 int1: integer;
 bo1: boolean;
 rea1: real;
begin
 result:= true;
 if aprinter <> nil then begin
  rea1:= aprinter.ppmm;
  aprinter.ppmm:= fppmm;
  if astream <> nil then begin
   aprinter.beginprint(astream);
  end
  else begin
   aprinter.beginprint(acommand);
  end;
 end;
 for int1:= 0 to count - 1 do begin
  with treporttab(items[int1]) do begin
   if fpage <> nil then begin
    fpage.beginrender;
   end;
  end;
 end;
 try
  for int1:= 0 to count - 1 do begin
   with treporttab(items[int1]) do begin
    if fpage <> nil then begin
     result:= result and fpage.render(acanvas);
    end;
   end;
  end;
 finally
  for int1:= 0 to count - 1 do begin
   with treporttab(items[int1]) do begin
    if fpage <> nil then begin
     fpage.endrender;
    end;
   end;
  end;
  if aprinter <> nil then begin
   aprinter.endprint;
   aprinter.ppmm:= rea1;
  end;
 end;
end;

function tcustomreport.render(const acanvas: tcanvas): boolean;
begin
 result:= internalrender(acanvas,nil,'',nil);
end;

function tcustomreport.render(const aprinter: tprinter;
               const command: string = ''): boolean;
begin
 result:= internalrender(aprinter.canvas,aprinter,command,nil);
end;

function tcustomreport.render(const aprinter: tprinter;
               const astream: ttextstream): boolean;
begin
 result:= internalrender(aprinter.canvas,aprinter,'',astream);
end;

 {treport}
 
constructor treport.create(aowner: tcomponent);
begin
 create(aowner,true);
end;

constructor treport.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstyle,cs_ismodule);
 inherited create(aowner);
 if load and not (csdesigning in componentstate) and
          (cs_ismodule in fmsecomponentstyle) then begin
  loadmsemodule(self,treport);
 end;
end;

class function treport.getmoduleclassname: string;
begin
 result:= 'treport';
end;

{ treporttab }

constructor treporttab.create(aowner: tcomponent);
begin
 fppmm:= defaultrepppmm;
 inherited;
 exclude(fwidgetstate,ws_iswidget);
end;

constructor treporttab.create(const aowner: tcomponent;
               const apage: tcustomreportpage);
begin
 create(aowner);
 caption:= apage.name;
 apage.parentwidget:= self;
end;

destructor treporttab.destroy;
begin
 inherited;
end;

procedure treporttab.registerchildwidget(const child: twidget);
begin
 if (fpage = nil) and (child is tcustomreportpage) then begin
  fpage:= tcustomreportpage(child);
  fpage.ppmm:= fppmm;
 end;
 inherited;
end;

procedure treporttab.unregisterchildwidget(const child: twidget);
begin
 inherited;
 if child is tcustomreportpage then begin
  fpage:= nil;
  if not (csdestroying in componentstate) then begin
   free;
  end;
 end;
end;

procedure treporttab.setparentwidget(const avalue: twidget);
begin
 inherited;
end;

initialization
 registerclass(treporttab);
end.
