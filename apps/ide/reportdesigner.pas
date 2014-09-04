{ MSEide Copyright (c) 1999-2014 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit reportdesigner;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,msegui,mseclasses,mseforms,formdesigner,msesimplewidgets,
 msetabs,msesplitter,msegraphutils,msedesigner,msedesignintf,msereport,msetypes,
 mseevent,mseglob,mseguiglob,msemenus,msedial,msedispwidgets,mseact,
 msestringcontainer,msestrings,mseactions,mseificomp,mseificompglob,mseifiglob;

const
 updatetabtag = 83684;
 
type
 treportdesignerfo = class;
 {
 treportcontainer = class(tscrollbox)
  protected
   function isdesignwidget(): boolean; override;
  public
   constructor create(aowner: tcomponent); override;
 end;
 }
 reportdesignerstatety = (rds_tabupdating,rds_mouseinclient);
 reportdesignerstatesty = set of reportdesignerstatety;
 
 treportdesignerfo = class(tformdesignerfo)
   dialh: tdial;
   dialv: tdial;
   tabbar: ttabbar;
   reportcontainer: tscrollbox;
   tspacer4: tspacer;
   xdisp: trealdisp;
   ydisp: trealdisp;
   tspacer1: tspacer;
   tspacer2: tspacer;
   tspacer3: tspacer;
   sc: tstringcontainer;
   tpopupmenu3: tpopupmenu;
   procedure repchildscaled(const sender: TObject);
   procedure tabcha(const sender: TObject);
   procedure tabmo(const sender: TObject; var curindex: Integer;
                   var newindex: Integer);
   procedure tabmouse(const sender: twidget; var info: mouseeventinfoty);
   procedure deletepage(const sender: TObject);
   procedure popupupda(const sender: tcustommenu);
   procedure addpage(const sender: TObject);
   procedure formresized(const sender: TObject);
   procedure reportchildmouseevent(const sender: twidget;
                   var info: mouseeventinfoty);
   procedure reportcontainerscroll(const sender: twidget; const point: pointty);
   procedure repcomtainerchildscaled(const sender: TObject);
//   procedure updatewidgethideexe(const sender: tcustomaction); override;
//   procedure repshowallexe(const sender: TObject);
//   procedure reptoglehideexe(const sender: TObject);
//   procedure rephidewidgetexe(const sender: TObject);
  private
//   freportcontainer: treportcontainer;
   fstate: reportdesignerstatesty;
   function ppmm: real;
  protected
   procedure setmoduleoptions(const aoptions: moduleoptionsty); override;
   function report: tcustomreport;
   function getmoduleparent: twidget; override;
   function getdesignrect: rectty; override;
   function getmodulesize: sizety; override;
   function gridrect: rectty; override;
   function insertoffset: pointty; override;
   function widgetrefpoint: pointty; override;
   function getgridsizex: integer; override;
   function getgridsizey: integer; override;
   function getshowgrid: boolean; override;
   function getsnaptogrid: boolean; override;
//   procedure poschanged(); override;
//   procedure sizechanged(); override;
   procedure checktabs;
   procedure updatetabs;
   procedure validaterename(acomponent: tcomponent;
                                      const curname, newname: string); override;
   procedure doasyncevent(var atag: integer); override;
   procedure componentselected(const aselections: tformdesignerselections);
                                                                      override;
   procedure placecomponent(const component: tcomponent; const apos: pointty;
                                 aparent: tcomponent = nil); override;
   function fixformsize: boolean; override;
//   function candelete(const acomponent: tcomponent): boolean; override;
   function checkdelete(): boolean; override;
   procedure componentmoving(const apos: pointty); override;
   procedure updatedials;
   procedure setmousemarkers(const avalue: pointty; const source: twidget);
  public
   constructor create(const aowner: tcomponent; const adesigner: tdesigner;
                      const aintf: pdesignmoduleintfty;
                      const amoduleinfo: pmoduleinfoty); override;
   procedure placemodule(); override;
   procedure beginstreaming(); override;
   procedure endstreaming(); override;
 end;

var
 reportdesignerfo: treportdesignerfo;

implementation

uses
 reportdesigner_mfm,msearrayutils,msegraphics,msewidgets,msereal;
type
 tcustomreport1 = class(tcustomreport);
 twidget1 = class(twidget);
 
 stringconsts = (
  sc_wishdelete,     //0 Do you wish to delete
  sc_warning         //1 WARNING
 );
 
{ treportcontainer }
{
constructor treportcontainer.create(aowner: tcomponent);
begin
 inherited;
 createframe;
 frame.colorclient:= cl_white;
 anchors:= [an_top,an_bottom];
end;

function treportcontainer.isdesignwidget: boolean;
begin
 result:= true;
end;
}
{ treportdesignerfo }

constructor treportdesignerfo.create(const aowner: tcomponent;
        const adesigner: tdesigner; const aintf: pdesignmoduleintfty;
        const amoduleinfo: pmoduleinfoty);
begin
 inherited;
 include(twidget1(pointer(reportcontainer)).fwidgetstate1,ws1_designwidget);
end;

function treportdesignerfo.fixformsize: boolean;
begin
 result:= true;
end;

function treportdesignerfo.getmoduleparent: twidget;
begin
 result:= reportcontainer;
end;

function treportdesignerfo.gridrect: rectty;
begin
 if reportcontainer.visible then begin
  with reportcontainer do begin
   result:= intersectrect(inherited gridrect,
       makerect(translatewidgetpoint(paintpos,reportcontainer,self),paintsize));
  end;
 end
 else begin
  with reportcontainer do begin
   result:= intersectrect(inherited gridrect,
       makerect(translatewidgetpoint(pos,reportcontainer.parentwidget,self),
                                                                        size));
  end;
 end;
end;

function treportdesignerfo.insertoffset: pointty;
begin
// result:= translateclientpoint(nullpoint,reportcontainer,self);
 if fformcont.visible then begin
  result:= translatewidgetpoint(reportcontainer.clientwidgetpos,
                                                 reportcontainer,self);
//  result:= translatewidgetpoint(nullpoint,reportcontainer,self);
 end
 else begin
  result:= inherited insertoffset;
 end;
end;

function treportdesignerfo.widgetrefpoint: pointty;
begin
 if fformcont.visible then begin
  result:= translatewidgetpoint(reportcontainer.pos,
                                      reportcontainer.parentwidget,self);
  addpoint1(result,reportcontainer.clientpos);
 end
 else begin
  result:= inherited widgetrefpoint();
 end;
end;

procedure treportdesignerfo.repchildscaled(const sender: TObject);
begin
 ydisp.bounds_cx:= getcanvas.getstringwidth('999.9') + 8;
 xdisp.bounds_cx:= getcanvas.getstringwidth('999.9mm') + 8;
 placexorder(0,[],[ydisp,xdisp,tabbar],0);
end;

procedure treportdesignerfo.checktabs;
var
 int1: integer;
begin
 if report <> nil then begin
  if report.reppagecount = 0 then begin
   addpage(nil);
   exit;
  end;
  tabbar.tabs.count:= report.reppagecount;
  for int1:= 0 to tabbar.tabs.count - 1 do begin
   tabbar.tabs[int1].caption:= report[int1].name;
  end;
  if (report.reppagecount > 0) and (tabbar.activetab < 0) then begin
   tabbar.activetab:= 0;
  end;
 end;
end;

function treportdesignerfo.report: tcustomreport;
begin
 result:= tcustomreport(module);
end;

procedure treportdesignerfo.validaterename(acomponent: tcomponent;
               const curname: string; const newname: string);
begin
 inherited;
 updatetabs;
end;

procedure treportdesignerfo.doasyncevent(var atag: integer);
begin
 if atag = updatetabtag then begin
  exclude(fstate,rds_tabupdating);
  checktabs;
 end
 else begin
  inherited;
 end;
end;

procedure treportdesignerfo.updatetabs;
begin
 if not (rds_tabupdating in fstate) then begin
  include(fstate,rds_tabupdating);
  asyncevent(updatetabtag);
 end;
end;

procedure treportdesignerfo.tabcha(const sender: TObject);
var
 reppage1: tcustomreportpage;
 int1: integer;
begin
 if tabbar.activetab >= 0 then begin
  for int1:= 0 to report.reppagecount - 1 do begin
   report[int1].visible:= int1 = tabbar.activetab;
  end;
  reppage1:= report[tabbar.activetab];
  report.size:= reppage1.size;
  reppage1.bringtofront;
//  designer.selectcomponent(report);
 end;
end;

procedure treportdesignerfo.componentselected(
                          const aselections: tformdesignerselections);
var
 int1,int2: integer;
 widget1: twidget;
begin
 with tcustomreport1(report) do begin
  for int1:= 0 to aselections.count-1 do begin
   widget1:= twidget(aselections[int1]);
   if widget1 is twidget then begin
    for int2:= high(freppages) downto 0 do begin
     if widget1.checkancestor(freppages[int2]) then begin
      checktabs;
      tabbar.activetab:= int2;
      exit;
     end;
    end;
   end;   
  end;
 end;
end;

procedure treportdesignerfo.tabmo(const sender: TObject; var curindex: Integer;
               var newindex: Integer);
begin
 moveitem(pointerarty(tcustomreport1(report).freppages),curindex,newindex);
end;

procedure treportdesignerfo.tabmouse(const sender: twidget;
               var info: mouseeventinfoty);
begin
 with info do begin
  if (eventkind = ek_buttonpress) and (button = mb_left) then begin
   designer.selectcomponent(report);
  end;
 end;
end;

procedure treportdesignerfo.placemodule();
begin
 inherited;
 with tcustomreport1(form).frepdesigninfo.widgetrect do begin
  fmodulepos:= pos;
  fmodulesize:= size;
 end;
end;

procedure treportdesignerfo.beginstreaming;
begin
// tcustomreport1(form).frepdesigninfo.widgetrect:= widgetrect;
 with tcustomreport1(form).frepdesigninfo.widgetrect do begin
  pos:= fmodulepos;
  size:= fmodulesize;
 end;
end;

procedure treportdesignerfo.endstreaming;
begin
 //dummy
end;

function treportdesignerfo.getdesignrect: rectty;
begin
 result:= tcustomreport1(form).frepdesigninfo.widgetrect;
end;

function treportdesignerfo.getmodulesize: sizety;
begin
 result:= tcustomreport1(form).frepdesigninfo.widgetrect.size;
end;

procedure treportdesignerfo.popupupda(const sender: tcustommenu);
begin
 popupme.menu.itembyname('delpage').enabled:= tabbar.activetab >= 0;
end;
{
function treportdesignerfo.candelete(const acomponent: tcomponent): boolean;
var
 int1: integer;
begin
 result:= true;
 with report do begin
  for int1:= 0 to reppagecount - 1 do begin
   if acomponent = reppages[int1] then begin
    result:= false;
    break;
   end;
  end;
 end;
end;
}

function treportdesignerfo.checkdelete(): boolean;
var
 int1,int2: integer;
 comp1: tcomponent;
 pages: reportpagearty;
 bo1: boolean;
begin
 result:= false;
 if inherited checkdelete() then begin
  pages:= tcustomreport1(report).freppages;
  bo1:= false;
  with fselections do begin  
   for int1:= 0 to count - 1 do begin
    comp1:= items[int1];
    for int2:= 0 to high(pages) do begin
     if pages[int2] = comp1 then begin
      bo1:= true;
      if not askyesno('Do you want to delete reportpage "'+
                                      comp1.name+'"?') then begin
       exit;
      end;
     end;
    end;
   end;
  end;
  if bo1 then begin
   updatetabs;
  end;
  result:= true;
 end;
end;

procedure treportdesignerfo.addpage(const sender: TObject);
var
 comp1: tcomponent;
begin
 comp1:= designer.createnewcomponent(report,treportpage);
 placecomponent(comp1,translatewidgetpoint(reportcontainer.pos,
                                    reportcontainer.parentwidget,self),report);
 updatetabs;
end;

procedure treportdesignerfo.placecomponent(const component: tcomponent;
               const apos: pointty; aparent: tcomponent = nil);
begin
 if component is tcustomreportpage then begin
  inherited placecomponent(component,
                     translatewidgetpoint(reportcontainer.pos,
                                    reportcontainer.parentwidget,self),report);
 end
 else begin
  inherited;
 end;
end;

procedure treportdesignerfo.deletepage(const sender: TObject);
var
 comp1: tcomponent;
begin
 comp1:= report[tabbar.activetab];
 if askok(sc[ord(sc_wishdelete)]+' '''+
               comp1.name+'''?',sc[ord(sc_warning)],mr_cancel) then begin
//  designer.deletecomponent(comp1);
  deletecomponent(comp1);
  updatetabs;
 end;
end;

function treportdesignerfo.getgridsizex: integer;
begin
 with tcustomreport1(form) do begin
  result:= round(frepdesigninfo.gridsize * ppmm);
 end;
 if result < 2 then begin
  result:= 2;
 end;
end;

function treportdesignerfo.getgridsizey: integer;
begin
 result:= gridsizex;
end;

function treportdesignerfo.getshowgrid: boolean;
begin
 result:= tcustomreport1(form).frepdesigninfo.showgrid;
end;

function treportdesignerfo.getsnaptogrid: boolean;
begin
 result:= tcustomreport1(form).frepdesigninfo.snaptogrid;
end;

function treportdesignerfo.ppmm: real;
begin
 if report = nil then begin
  result:= 3;
 end
 else begin
  result:= report.ppmm;
 end;
end;

procedure treportdesignerfo.setmousemarkers(const avalue: pointty;
                                                    const source: twidget);
var
 pt1: pointty;
begin
 pt1:= translatewidgetpoint(avalue,source,reportcontainer);
 xdisp.value:= pt1.x/ppmm + dialh.dial.start;
 dialh.dial.markers[0].value:= xdisp.value;
 ydisp.value:= pt1.y/ppmm + dialv.dial.start;
 dialv.dial.markers[0].value:= ydisp.value;
end;

procedure treportdesignerfo.reportchildmouseevent(const sender: twidget;
               var info: mouseeventinfoty);
//var
// pt1: pointty;
begin
 with info do begin
  case eventkind of
   ek_mouseleave: begin
    exclude(fstate,rds_mouseinclient);
    xdisp.value:= emptyreal;
    ydisp.value:= emptyreal;
    dialh.dial.markers[0].value:= emptyreal;
    dialv.dial.markers[0].value:= emptyreal;
   end;
   ek_mouseenter: begin
    include(fstate,rds_mouseinclient);
   end;
   ek_buttonpress: begin
    if (button = mb_left) and (ss_double in shiftstate) and 
             not reportcontainer.checkdescendent(sender) then begin
     designer.showobjectinspector;
     include(eventstate,es_processed);
    end;
   end;
  end;
  if (eventkind in mouseposevents) and (rds_mouseinclient in fstate) then begin
   setmousemarkers(pos,sender);
  end;
 end;
end;

procedure treportdesignerfo.updatedials;
 procedure adjustticks(const adial: tcustomdialcontroller);
 begin
  with adial do begin
   ticks[0].intervalcount:= range/10.0;
   ticks[1].intervalcount:= range/5.0;
   ticks[2].intervalcount:= range/1.0;
  end;
 end; 
begin
 if dialh.bounds_cx > 0 then begin
  dialh.dial.range:= dialh.bounds_cx / ppmm; //mm
 end;
 if dialv.bounds_cy > 0 then begin
  dialv.dial.range:= dialv.bounds_cy / ppmm; //mm
 end;
 dialh.dial.start:= -reportcontainer.clientpos.x / ppmm;
 dialv.dial.start:= -reportcontainer.clientpos.y / ppmm;
 adjustticks(dialh.dial);
 adjustticks(dialv.dial);
end;

procedure treportdesignerfo.formresized(const sender: TObject);
begin
 updatedials;
end;

procedure treportdesignerfo.reportcontainerscroll(const sender: twidget;
               const point: pointty);
begin
 updatedials;
 formcontainerscrolled; 
end;

procedure treportdesignerfo.repcomtainerchildscaled(const sender: TObject);
begin
 updatedials;
end;

procedure treportdesignerfo.componentmoving(const apos: pointty);
begin
 setmousemarkers(apos,self);
end;

procedure treportdesignerfo.setmoduleoptions(const aoptions: moduleoptionsty);
begin
 inherited;
 if mo_hidewidgets in aoptions then begin
  reportcontainer.visible:= false;
 end
 else begin
  reportcontainer.visible:= true;
  fscrollbox.visible:= true;
  fscrollbox.bringtofront();
 end;
end;
{
procedure treportdesignerfo.updatewidgethideexe(const sender: tcustomaction);
begin
 //dummy
end;

procedure treportdesignerfo.rephidewidgetexe(const sender: TObject);
begin
 hidewidgetexe(sender);
 reportcontainer.visible:= fformcont.visible;
end;

procedure treportdesignerfo.reptoglehideexe(const sender: TObject);
begin
 togglehideexe(sender);
 reportcontainer.visible:= fformcont.visible;
end;

procedure treportdesignerfo.repshowallexe(const sender: TObject);
begin
 showallexe(sender);
 reportcontainer.visible:= fformcont.visible;
end;
}
{
procedure treportdesignerfo.poschanged;
begin
 inherited;
 if parentwidget = nil then begin //not docked
  tcustomreport1(form).frepdesigninfo.widgetrect:= widgetrect;
 end;
end;

procedure treportdesignerfo.sizechanged;
begin
 inherited;
 if parentwidget = nil then begin //not docked
  tcustomreport1(form).frepdesigninfo.widgetrect:= widgetrect;
 end;
end;
}
end.

