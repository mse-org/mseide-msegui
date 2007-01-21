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
 msetabs,mseprinter,msestream,msearrayprops,mseguiglob,msesimplewidgets,
 msedrawtext,msestrings,mserichstring;

const
 defaultrepppmm = 3;
 defaultreppagewidth = 190;
 defaultreppageheight = 270;
 defaultrepfontheight = 14;
 defaultrepfontname = 'stf_report';
  
type
 tcustombandarea = class;
 tcustomrecordband = class;
 rendereventty = procedure(const sender: tobject;
                               const acanvas: tcanvas) of object;
 beforerenderrecordeventty = procedure(const sender: tcustomrecordband;
                                          var empty: boolean) of object;

 treptabfont = class(tparentfont)
  protected
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 treptabulatoritem = class(ttabulatoritem)
  private
   fvalue: richstringty;
   ffont: treptabfont;
   procedure setvalue(const avalue: msestring);
   procedure setrichvalue(const avalue: richstringty);
   function getfont: treptabfont;
   procedure setfont(const avalue: treptabfont);
   function isfontstored: boolean;
   procedure createfont;
   procedure changed;
   procedure fontchanged(const asender: tobject);
  public 
   destructor destroy; override;
   property richvalue: richstringty read fvalue write setrichvalue;
  published
   property value: msestring read fvalue.text write setvalue;
   property font: treptabfont read getfont write setfont stored isfontstored;
 end;
 
 treptabulators = class(tcustomtabulators)
  private
   finfo: drawtextinfoty;
   fband: tcustomrecordband;
   fminsize: sizety;
   fsizevalid: boolean;
   function getitems(const index: integer): treptabulatoritem;
   procedure setitems(const index: integer; const avalue: treptabulatoritem);
   procedure processvalues(const acanvas: tcanvas; const adest: rectty;
                        const apaint: boolean);
  protected
   class function getitemclass: tabulatoritemclassty; override;
   procedure paint(const acanvas: tcanvas; const adest: rectty);
   procedure checksize;
  public
   constructor create(const aowner: tcustomrecordband);
   property items[const index: integer]: treptabulatoritem read getitems 
                       write setitems; default;
 published
   property defaultdist;
 end;
  
 recordbandstatety = (rbs_rendering);
 recordbandstatesty = set of recordbandstatety; 
 
 ibandparent = interface(inullinterface)
                        ['{B02EE732-4686-4E0C-8C18-419D7D020386}']
  function beginband(const acanvas: tcanvas;
                              const sender: tcustomrecordband): boolean;
                   //true if area full
  procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
 end;
 
 tcustomrecordband = class(tcustomscalingwidget)
  private
   fparentintf: ibandparent;
   fonbeforerender: beforerenderrecordeventty;
   fonpaint: painteventty;
   fonafterpaint: painteventty;
   fstate: recordbandstatesty;
   ftabs: treptabulators;
   fupdating: integer;
   procedure settabs(const avalue: treptabulators);
  protected
   procedure minclientsizechanged;
   procedure fontchanged; override;
   procedure inheritedpaint(const acanvas: tcanvas);
   procedure paint(const canvas: tcanvas); override;
   procedure setparentwidget(const avalue: twidget); override;   
   function calcminscrollsize: sizety; override;
   procedure render(const acanvas: tcanvas; var empty: boolean); virtual;
   procedure init; virtual;
   procedure beginrender;
   procedure endrender;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doafterpaint(const acanvas: tcanvas); override;
   function rendering: boolean;
   function bandheight: integer;
   procedure dobeforerender(var empty: boolean); virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure beginupdate;
   procedure endupdate;
   property onbeforerender: beforerenderrecordeventty read fonbeforerender
                               write fonbeforerender;
   property onpaint: painteventty read fonpaint write fonpaint;
   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;
   property tabs: treptabulators read ftabs write settabs;
   property font: twidgetfont read getfont write setfont stored isfontstored;
 end;

 trecordband = class(tcustomrecordband)
  published
   property font;
   property tabs;
   property optionsscale;
   property onfontheightdelta;
   property onchildscaled;

   property onbeforerender;
   property onpaint;
   property onafterpaint;
  end;
 
 recordbandarty = array of tcustomrecordband;
 
 tcustombandgroup = class(tcustomrecordband)
  private
   fbands: recordbandarty;
  protected
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure dobeforerender(var empty: boolean); override;
//   procedure dorender(const acanvas: tcanvas); override;
   procedure render(const acanvas: tcanvas; var empty: boolean); override;
  public
   property font: twidgetfont read getfont write setfont stored isfontstored;
 end;

 tbandgroup = class(tcustombandgroup)
  published
   property font;
   property onbeforerender;
   property onpaint;
   property onafterpaint;
 end;
 
 bandareastatety = (bas_inited,bas_backgroundrendered,bas_areafull,
                    bas_rendering);
 bandareastatesty = set of bandareastatety; 

 tcustomreportpage = class;
   
 tcustombandarea = class(tpublishedwidget,ibandparent)
  private
   fbands: recordbandarty;
   fstate: bandareastatesty;
   factiveband: integer;
   facty: integer;
   fsaveindex: integer;
   freportpage: tcustomreportpage;
   fonbeforerender: notifyeventty;
   fonpaint: painteventty;
   fonafterpaint: painteventty;
  protected
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure setparentwidget(const avalue: twidget); override;   
   procedure paint(const canvas: tcanvas); override;
   procedure renderbackground(const acanvas: tcanvas);
   function areafull: boolean;
   function render(const acanvas: tcanvas): boolean;
          //true if finished
   function rendering: boolean;
   procedure beginrender;
   procedure endrender;
   procedure dobeforerender; virtual;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doafterpaint1(const acanvas: tcanvas); virtual;
   procedure init; virtual;
           //ibandparent
   function beginband(const acanvas: tcanvas;
                               const sender: tcustomrecordband): boolean;
                    //true if area full
   procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
  public
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property onbeforerender: notifyeventty read fonbeforerender
                               write fonbeforerender;
   property onpaint: painteventty read fonpaint write fonpaint;
   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;
 end; 
 
 tbandarea = class(tcustombandarea)
  published
   property font;
   property onbeforerender;
   property onpaint;
   property onafterpaint;
 end;

 reportpagestatety = (rpps_inited,rpps_rendering,rpps_backgroundrendered);
 reportpagestatesty = set of reportpagestatety;
 
 bandareaarty = array of tcustombandarea;
 
 tcustomreport = class;
   
 tcustomreportpage = class(twidget)
  private
   fareas: bandareaarty;
   fstate: reportpagestatesty;
   fonbeforerender: notifyeventty;
   fonpaint: painteventty;
   fonafterpaint: painteventty;
   fpagewidth: real;
   fpageheight: real;
   fppmm: real;
   fpagenum: integer;
   procedure setpagewidth(const avalue: real);
   procedure setpageheight(const avalue: real);
   procedure updatepagesize;
   procedure setppmm(const avalue: real);
  protected
   freport: tcustomreport;
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure setparentwidget(const avalue: twidget); override;   
   procedure insertwidget(const awidget: twidget; const apos: pointty); override;
   procedure sizechanged; override;

   procedure renderbackground(const acanvas: tcanvas);
   procedure beginrender;
   procedure endrender;
   function rendering: boolean;
   procedure beginarea(const acanvas: tcanvas; const sender: tcustombandarea);
   procedure dobeforerender; virtual;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doafterpaint1(const acanvas: tcanvas); virtual;
   procedure init; virtual;
   property ppmm: real read fppmm write setppmm; //pixel per mm
  public
   constructor create(aowner: tcomponent); override;
   function render(const acanvas: tcanvas): boolean;
          //true if finished
   property onbeforerender: notifyeventty read fonbeforerender
                               write fonbeforerender;
   property onpaint: painteventty read fonpaint write fonpaint;
   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;

   property pagewidth: real read fpagewidth write setpagewidth;
   property pageheight: real read fpageheight write setpageheight;
   property font: twidgetfont read getfont write setfont stored isfontstored;
 end;
 
 reportpagearty = array of tcustomreportpage;
 
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
   property onpaint;   
   property onafterpaint;
 end;

 repdesigninfoty = record
  widgetrect: rectty;
  gridsize: real;
  showgrid: boolean;
  snaptogrid: boolean;
 end;
 
 tcustomreport = class(twidget)
  private
   fppmm: real;
   fonbeforerender: notifyeventty;
   fonafterrender: notifyeventty;
   fprinter: tprinter;
   procedure setppmm(const avalue: real);
   function getreppages(index: integer): tcustomreportpage;
   procedure setreppages(index: integer; const avalue: tcustomreportpage);
   function getgrid_show: boolean;
   procedure setgrid_show(const avalue: boolean);
   function getgrid_snap: boolean;
   procedure setgrid_snap(const avalue: boolean);
   function getgrid_size: real;
   procedure setgrid_size(avalue: real);
   procedure writerepdesigninfo(writer: twriter);
   procedure readrepdesigninfo(reader: treader);
  protected
   frepdesigninfo: repdesigninfoty;
   freppages: reportpagearty;
   procedure insertwidget(const awidget: twidget; const apos: pointty); override;
   function internalrender(const acanvas: tcanvas; const aprinter: tprinter;
                   const acommand: string; const astream: ttextstream): boolean;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
   procedure internalcreatefont; override;
   procedure defineproperties(filer: tfiler); override;
   procedure nextpage(const acanvas: tcanvas);
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
   function reppagecount: integer;
   property reppages[index: integer]: tcustomreportpage read getreppages 
                                                write setreppages; default;
   property font: twidgetfont read getfont write setfont;
   property color default cl_transparent;
   property grid_show: boolean read frepdesigninfo.showgrid write setgrid_show default true;
   property grid_snap: boolean read frepdesigninfo.snaptogrid write setgrid_snap default true;
   property grid_size: real read frepdesigninfo.gridsize write setgrid_size;   

   property onbeforerender: notifyeventty read fonbeforerender
                               write fonbeforerender;
   property onafterrender: notifyeventty read fonafterrender
                               write fonafterrender;
 end;

 treport = class(tcustomreport)
  protected
   class function getmoduleclassname: string; override;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean); 
                                     overload; virtual;   
  published    
   property color;
   property ppmm;
   property font;
   property grid_show;
   property grid_snap;
   property grid_size;
   property onbeforerender;
   property onafterrender;
 end;

 reportclassty = class of treport;
  
function createreport(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
procedure initreportcomponent(const amodule: tcomponent; 
                                         const acomponent: tcomponent);
function getreportscale(const amodule: tcomponent): real;

implementation
uses
 msedatalist,sysutils,msestreaming;
type
 tcustomframe1 = class(tcustomframe);
 twidget1 = class(twidget);
 tmsecomponent1 = class(tmsecomponent);
 
function createreport(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
begin
 result:= reportclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

function getreportscale(const amodule: tcomponent): real;
begin
 result:= tcustomreport(amodule).fppmm/defaultppmm;
end;

procedure initreportcomponent(const amodule: tcomponent;
                                           const acomponent: tcomponent);
begin
// if acomponent is twidget then begin
//  twidget(acomponent).scale(getreportscale(amodule));
// end;
end;

{ treptabfot }

class function treptabfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @treptabulatoritem(owner).ffont;
end;

{ treptabulatoritem }

destructor treptabulatoritem.destroy;
begin
 inherited;
 ffont.free;
end;

procedure treptabulatoritem.setvalue(const avalue: msestring);
begin
 fvalue.text:= avalue;
 fvalue.format:= nil;
 changed;
end;

procedure treptabulatoritem.setrichvalue(const avalue: richstringty);
begin
 fvalue:= avalue;
 changed;
end;

function treptabulatoritem.getfont: treptabfont;
begin
 getoptionalobject(treptabulators(fowner).fband.componentstate,ffont,
                     {$ifdef FPC}@{$endif}createfont);
 if ffont <> nil then begin
  result:= ffont;
 end
 else begin
  result:= treptabfont(treptabulators(fowner).fband.getfont);
 end;
end;

procedure treptabulatoritem.createfont;
begin
 if ffont = nil then begin
  ffont:= treptabfont.create;
  ffont.onchange:= {$ifdef FPC}@{$endif}fontchanged;
 end;
end;

procedure treptabulatoritem.setfont(const avalue: treptabfont);
begin
 if avalue <> ffont then begin
  setoptionalobject(treptabulators(fowner).fband.componentstate,avalue,
                 ffont,{$ifdef fpc}@{$endif}createfont);
  changed;
 end;
end;

function treptabulatoritem.isfontstored: boolean;
begin
 result:= ffont <> nil;
end;

procedure treptabulatoritem.changed;
begin
 with treptabulators(fowner),fband do begin
  fsizevalid:= false;
  minclientsizechanged;
 end;
end;

procedure treptabulatoritem.fontchanged(const asender: tobject);
begin
 changed;
end;

{ treptabulators }

constructor treptabulators.create(const aowner: tcustomrecordband);
begin
 fband:= aowner;
 inherited create;
end;

class function treptabulators.getitemclass: tabulatoritemclassty;
begin
 result:= treptabulatoritem;
end;

function treptabulators.getitems(const index: integer): treptabulatoritem;
begin
 result:= treptabulatoritem(inherited items[index]);
end;

procedure treptabulators.setitems(const index: integer;
               const avalue: treptabulatoritem);
begin
 inherited items[index]:= avalue;
end;

procedure treptabulators.processvalues(const acanvas: tcanvas;
               const adest: rectty; const apaint: boolean);
var
 int1,int2,int3: integer;
 rstr1: richstringty;
begin
 fminsize:= nullsize;
 if count > 0 then begin
  checkuptodate;
  with finfo do begin
   for int1:= 0 to count - 1 do begin
    with treptabulatoritem(fitems[int1]) do begin
     finfo.font:= font;
     text:= fvalue;
     dest:= adest;
     textrect(acanvas,finfo);
     with ftabs[int1] do begin
      case kind of
       tak_left: begin
        dest.x:= adest.x + pos;
       end;
       tak_right: begin
        dest.x:= adest.x + pos - res.cx;
       end;
       tak_centered: begin
        dest.x:= adest.x + pos - res.cx div 2;
       end;
       else begin //tak_decimal
        int2:= findlastchar(fvalue.text,msechar(decimalseparator));
        if int2 > 0 then begin
         rstr1:= richcopy(fvalue,int2,bigint);
         int3:= textrect(acanvas,rstr1,[],finfo.font).cx;
        end
        else begin
         int3:= 0;
        end;
        dest.x:= adest.x + pos - res.cx + int3; 
       end;
      end;
     end;
    end;
    int2:= dest.x + res.cx;
    if int2 > fminsize.cx then begin
     fminsize.cx:= int2;
    end;
    int2:= dest.y + res.cy;
    if int2 > fminsize.cy then begin
     fminsize.cy:= int2;
    end;
    if apaint then begin
     drawtext(acanvas,finfo);
    end;
   end;
  end;
 end;
 fsizevalid:= true;
end;

procedure treptabulators.paint(const acanvas: tcanvas; const adest: rectty);
begin
 processvalues(acanvas,adest,true);
end;

procedure treptabulators.checksize;
begin
 if not fsizevalid then begin
  processvalues(fband.getcanvas,fband.innerclientrect,false);
 end;
end;

{ tcustomrecordband }

constructor tcustomrecordband.create(aowner: tcomponent);
begin
 ftabs:= treptabulators.create(self);
 inherited;
end;

destructor tcustomrecordband.destroy;
begin
 inherited;
 ftabs.free;
end;

procedure tcustomrecordband.setparentwidget(const avalue: twidget);
begin
 if avalue <> nil then begin
  avalue.getcorbainterface(typeinfo(ibandparent),fparentintf);
 end
 else begin
  fparentintf:= nil;
 end;
 inherited;
end;

procedure tcustomrecordband.dobeforerender(var empty: boolean);
begin
 if canevent(tmethod(fonbeforerender)) then begin
  fonbeforerender(self,empty);
 end;
end;

procedure tcustomrecordband.doonpaint(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonpaint)) then begin
  fonpaint(self,acanvas);
 end;
end;

procedure tcustomrecordband.render(const acanvas: tcanvas; var empty: boolean);
begin
 dobeforerender(empty);
 if not empty and visible then begin
  if fparentintf.beginband(acanvas,self) then begin
   exit;
  end;
  try
   inherited paint(acanvas);
  finally
   fparentintf.endband(acanvas,self);
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

procedure tcustomrecordband.inheritedpaint(const acanvas: tcanvas);
begin
 inherited paint(acanvas);
end;

procedure tcustomrecordband.paint(const canvas: tcanvas);
begin
 if not rendering then begin
  inherited;
 end;
end;

procedure tcustomrecordband.beginrender;
begin
 fstate:= [rbs_rendering];
 include(widgetstate1,ws1_noclipchildren);
end;

procedure tcustomrecordband.endrender;
begin
 exclude(fstate,rbs_rendering);
 exclude(widgetstate1,ws1_noclipchildren);
end;

procedure tcustomrecordband.settabs(const avalue: treptabulators);
begin
 ftabs.assign(avalue);
end;

procedure tcustomrecordband.doafterpaint(const acanvas: tcanvas);
var
 ar1: segmentarty;
 ar2: tabulatorarty;
 int1,int2: integer;
begin
 inherited;
 if canevent(tmethod(fonafterpaint)) then begin
  fonafterpaint(self,acanvas);
 end;
 if csdesigning in componentstate then begin
  ar2:= ftabs.tabs;
  setlength(ar1,length(ar2));
  int2:= innerclientwidgetpos.x;
  for int1:= 0 to high(ar1) do begin
   with ar1[int1] do begin
    a.x:= ar2[int1].pos+int2;
    a.y:= 0;
    b.x:= a.x;
    b.y:= fwidgetrect.cy;
   end;
  end;
  acanvas.dashes:= #2#2;
  acanvas.drawlinesegments(ar1,cl_red);
  acanvas.dashes:= '';
 end;
end;

procedure tcustomrecordband.dopaint(const acanvas: tcanvas);
begin
 inherited;
 ftabs.paint(acanvas,innerclientrect);
end;

function tcustomrecordband.calcminscrollsize: sizety;
var
 size1: sizety;
begin
 result:= inherited calcminscrollsize;
 ftabs.checksize;
 if fframe = nil then begin
  size1:= ftabs.fminsize;
 end
 else begin
  size1:= addsize(tcustomframe1(fframe).fi.innerframe.bottomright,
                          ftabs.fminsize);
 end;
 with size1 do begin
  if cx > result.cx then begin
   result.cx:= cx;
  end;
  if cy > result.cy then begin
   result.cy:= cy
  end;
 end;
end;

procedure tcustomrecordband.minclientsizechanged;
begin
 if (fupdating <= 0) and not (csloading in componentstate) then begin
  clientrectchanged;
 end;
end;

procedure tcustomrecordband.fontchanged;
begin
 ftabs.fsizevalid:= false;
 inherited;
 minclientsizechanged;
end;

procedure tcustomrecordband.beginupdate;
begin
 inc(fupdating);
end;

procedure tcustomrecordband.endupdate;
begin
 dec(fupdating);
 if fupdating = 0 then begin
  clientrectchanged;
 end;
end;

{ tcustombandgroup }

procedure tcustombandgroup.registerchildwidget(const child: twidget);
begin
 inherited;
 if child is tcustomrecordband then begin
  additem(pointerarty(fbands),child);
 end;
end;

procedure tcustombandgroup.unregisterchildwidget(const child: twidget);
begin
 removeitem(pointerarty(fbands),child);
 inherited;
end;

procedure tcustombandgroup.dobeforerender(var empty: boolean);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].dobeforerender(empty);
 end;
end;
{
procedure tcustombandgroup.dorender(const acanvas: tcanvas);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].dorender(acanvas);
 end;
end;
}

procedure tcustombandgroup.render(const acanvas: tcanvas;
               var empty: boolean);
var
 int1,int2: integer;
 
begin
 dobeforerender(empty);
 if not empty and visible then begin
  if fparentintf.beginband(acanvas,self) then begin
   exit;
  end;
  try
   inheritedpaint(acanvas);
  finally
   fparentintf.endband(acanvas,self);
  end;
 end;
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
var                     //true if finished
 bo1: boolean;
begin
 result:= true;
 if not (bas_inited in fstate) then begin
  init;
 end;
 try
  fstate:= fstate - [bas_areafull,bas_backgroundrendered];
  dobeforerender;
  while (factiveband <= high(fbands)) and not areafull do begin
   bo1:= true; //empty
   fbands[factiveband].render(acanvas,bo1);
   result:= result and bo1;
   if bo1 then begin
    inc(factiveband);
   end;
  end;
 finally
  if result then begin
   exclude(fstate,bas_inited);
  end;
  exclude(fstate,bas_rendering);
 end;
 if bas_backgroundrendered in fstate then begin
  doafterpaint1(acanvas);
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

procedure tcustombandarea.doonpaint(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonpaint)) then begin
  fonpaint(self,acanvas);
 end;
end;

procedure tcustombandarea.doafterpaint1(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonafterpaint)) then begin
  fonafterpaint(self,acanvas);
 end;
end;

procedure tcustombandarea.renderbackground(const acanvas: tcanvas);
begin
 freportpage.beginarea(acanvas,self);
 acanvas.origin:= pos;
 inherited paint(acanvas);
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

procedure tcustombandarea.paint(const canvas: tcanvas);
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
 fwidgetstate1:= fwidgetstate1 + [ws1_nodesignvisible,ws1_nodesignhandles,
                                       ws1_nodesigndelete];
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
 if avalue is tcustomreport then begin
  freport:= tcustomreport(avalue);
 end
 else begin
  freport:= nil;
 end;
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
 fpagenum:= 0;
 repeat
  exclude(fstate,rpps_backgroundrendered);
  acanvas.reset;
  acanvas.intersectcliprect(makerect(nullpoint,fwidgetrect.size));
  dobeforerender;
  for int1:= 0 to high(fareas) do begin
   fareas[int1].render(acanvas);
  end;
  result:= not (rpps_backgroundrendered in fstate);
  if not result then begin
   doafterpaint1(acanvas);
  end;
  inc(fpagenum);
 until result;
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

procedure tcustomreportpage.doonpaint(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonpaint)) then begin
  fonpaint(self,acanvas);
 end;
end;

procedure tcustomreportpage.doafterpaint1(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonafterpaint)) then begin
  fonafterpaint(self,acanvas);
 end;
end;

procedure tcustomreportpage.renderbackground(const acanvas: tcanvas);
begin
 if fpagenum <> 0 then begin
  freport.nextpage(acanvas);
 end;
 acanvas.origin:= pos;
 inherited paint(acanvas);
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

procedure tcustomreportpage.insertwidget(const awidget: twidget;
               const apos: pointty);
begin
 if (awidget is tcustomreportpage) and (fparentwidget <> nil) then begin
  fparentwidget.insertwidget(awidget,addpoint(apos,pos));
 end
 else begin
  inherited;
 end;
  
end;

procedure tcustomreportpage.sizechanged;
begin
 if (freport <> nil) and visible then begin
  freport.size:= size;
 end;
 inherited;
end;

 {tcustomreport}
 
constructor tcustomreport.create(aowner: tcomponent);
begin
 fppmm:= defaultrepppmm;
 with frepdesigninfo do begin
  widgetrect:= makerect(50,50,50,50);
  gridsize:= 2; //mm
  showgrid:= true;
  snaptogrid:= true;
 end;
 inherited;
 visible:= false;
 color:= cl_transparent;
 createfont;
end;

destructor tcustomreport.destroy;
var
 int1: integer;
begin
{
 for int1:= count - 1 downto 0 do begin
  items[int1].free; //tabs have no ws_iswidget
 end;
 }
 inherited;
end;

procedure tcustomreport.unregisterchildwidget(const child: twidget);
begin
 removeitem(pointerarty(freppages),child);
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
  if (ffont <> nil) and (fppmm > 0) then begin
   include(fwidgetstate1,ws1_fontheightlock);
   ffont.scale(avalue/fppmm);
   exclude(fwidgetstate1,ws1_fontheightlock);
  end;
  fppmm:= avalue;
  for int1:= 0 to high(freppages) do begin
   freppages[int1].ppmm:= avalue;
  end;
 end;
end;

procedure tcustomreport.insertwidget(const awidget: twidget;
               const apos: pointty);
begin
 if not (awidget is tcustomreportpage) then begin
  raise exception.create('Invalid widget');
 end;
 additem(pointerarty(freppages),awidget);
 tcustomreportpage(awidget).ppmm:= fppmm;
 inherited insertwidget(awidget,nullpoint);
end;

function tcustomreport.internalrender(const acanvas: tcanvas;
               const aprinter: tprinter; const acommand: string;
               const astream: ttextstream): boolean;
 procedure fakevisible(const awidget: twidget; const aset: boolean);
 var 
  int1: integer;
 begin
  with twidget1(awidget) do begin
   if aset then begin
    include(fwidgetstate1,ws1_fakevisible);
   end
   else begin
    exclude(fwidgetstate1,ws1_fakevisible);
   end;
   for int1:= 0 to high(fwidgets) do begin
    fakevisible(fwidgets[int1],aset);
   end;
  end;
 end;
 
var               
 rea1: real;

 procedure dofinish;
 var
  int1: integer;
 begin
  fakevisible(self,false);
  for int1:= 0 to high(freppages) do begin
   freppages[int1].endrender;
  end;
  if aprinter <> nil then begin
   aprinter.endprint;
   aprinter.ppmm:= rea1;
  end;
 end;
 
var
 int1: integer;
 bo1: boolean;
begin
 result:= true;
 fprinter:= aprinter;
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
 fakevisible(self,true);
 for int1:= 0 to high(freppages) do begin
  freppages[int1].beginrender;
 end;
 try
  if canevent(tmethod(fonbeforerender)) then begin
   fonbeforerender(self);
  end;
 except
  dofinish;
  raise;
 end;
 try
  for int1:= 0 to high(freppages) do begin
   freppages[int1].render(acanvas);
  end;
 finally
  try
   if canevent(tmethod(fonafterrender)) then begin
    fonafterrender(self);
   end;
  finally
   dofinish;
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

procedure tcustomreport.getchildren(proc: tgetchildproc; root: tcomponent);
var
 int1: integer;
 comp1: tcomponent;
begin
 for int1:= 0 to high(freppages) do begin
  comp1:= freppages[int1];
  if ((comp1.owner = root) or (csinline in root.componentstate) and
      not (csancestor in comp1.componentstate) and
                                 issubcomponent(comp1.owner,root)) then begin
   proc(comp1);
  end;
 end;
end;

function tcustomreport.getreppages(index: integer): tcustomreportpage;
begin
 checkarrayindex(freppages,index);
 result:= freppages[index];
end;

procedure tcustomreport.setreppages(index: integer;
               const avalue: tcustomreportpage);
begin
 checkarrayindex(freppages,index);
 freppages[index].assign(avalue);
end;

function tcustomreport.reppagecount: integer;
begin
 result:= length(freppages);
end;

procedure tcustomreport.internalcreatefont;
var
 font1: twidgetfont;
begin
 font1:= twidgetfont.create;
 font1.height:= round(defaultrepfontheight * (fppmm/defaultrepppmm));
 font1.name:= defaultrepfontname;
 ffont:= font1;
 inherited;
end;

function tcustomreport.getgrid_show: boolean;
begin
 result:= frepdesigninfo.showgrid;
end;

procedure tcustomreport.setgrid_show(const avalue: boolean);
begin
 frepdesigninfo.showgrid:= avalue;
 designchanged;
end;

function tcustomreport.getgrid_snap: boolean;
begin
 result:= frepdesigninfo.snaptogrid;
end;

procedure tcustomreport.setgrid_snap(const avalue: boolean);
begin
 frepdesigninfo.snaptogrid:= avalue;
 designchanged;
end;

function tcustomreport.getgrid_size: real;
begin
 result:= frepdesigninfo.gridsize;
end;

procedure tcustomreport.setgrid_size(avalue: real);
begin
 if avalue < 2/ppmm then begin
  avalue:= 2/ppmm;
 end;
 frepdesigninfo.gridsize:= avalue;
 designchanged;
end;

procedure tcustomreport.writerepdesigninfo(writer: twriter);
begin
 writerectty(writer,frepdesigninfo.widgetrect);
end;

procedure tcustomreport.readrepdesigninfo(reader: treader);
begin
 frepdesigninfo.widgetrect:= readrectty(reader);
end;

procedure tcustomreport.defineproperties(filer: tfiler);
begin
 filer.defineproperty('repdesigninfo',{$ifdef FPC}@{$endif}readrepdesigninfo,
                                 {$ifdef FPC}@{$endif}writerepdesigninfo,true);
 inherited;
end;

procedure tcustomreport.nextpage(const acanvas: tcanvas);
begin
 if acanvas is tcustomprintercanvas then begin
  tcustomprintercanvas(acanvas).nextpage;
 end;
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

end.
