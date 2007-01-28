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
 msedrawtext,msestrings,mserichstring,msedb,db,msethread;

const
 defaultrepppmm = 3;
 defaultreppagewidth = 190;
 defaultreppageheight = 270;
 defaultrepfontheight = 14;
 defaultrepfontname = 'stf_report';
 
 defaultreptabtextflags = [tf_ycentered];
 defaultbandanchors = [an_top];
 defaultbandoptionswidget = defaultoptionswidget + [ow_fontlineheight];
  
type
 linevisiblety = (lv_first,lv_normal,lv_last);
 linevisiblesty = set of linevisiblety;
  
 tablineinfoty = record
  widthmm: real;
  color: colorty;
  colorgap: colorty;
  capstyle: capstylety;
  dashes: string;
  dist: integer;
  visible: linevisiblesty; 
 end;
 tablinekindty = (tlk_top,tlk_vert,tlk_bottom);
 tablineinfoarty = array[tablinekindty] of tablineinfoty;
const
 defaulttablinewidth = 0;
 defaulttablinecolor = cl_black;
 defaulttablinecolorgap = cl_transparent;
 defaulttablinecapstyle = cs_projecting;
 defaulttablinedashes = '';
 defaulttablinedist = 0;
 defaulttablinevisible = [lv_first,lv_normal,lv_last];
 defaulttablineinfo: tablineinfoty = (widthmm: defaulttablinewidth; 
         color: defaulttablinecolor; colorgap: defaulttablinecolorgap;
         capstyle: defaulttablinecapstyle;
         dashes: defaulttablinedashes; dist: defaulttablinedist;
         visible: defaulttablinevisible);
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

 treptabulatoritem = class;
 
 treptabitemdatalink = class(tfielddatalink)
  private
   fowner: treptabulatoritem;
  protected
   procedure recordchanged(afield: tfield); override;
  public
   constructor create(const aowner: treptabulatoritem);
 end;

 getrichstringeventty = procedure(const sender: tobject; 
                                   var avalue: richstringty) of object;
               
 treptabulatoritem = class(ttabulatoritem,idbeditinfo)
  private
   fvalue: richstringty;
   ffont: treptabfont;
   ftextflags: textflagsty;
   fdatalink: treptabitemdatalink;
   fongetvalue: getrichstringeventty;
   flineinfos: tablineinfoarty;
   procedure setvalue(const avalue: msestring);
   procedure setrichvalue(const avalue: richstringty);
   function getdisptext: richstringty;
   function getfont: treptabfont;
   procedure setfont(const avalue: treptabfont);
   function isfontstored: boolean;
   procedure createfont;
   procedure changed;
   procedure fontchanged(const asender: tobject);
   procedure settextflags(const avalue: textflagsty);
   procedure setdatafiled(const avalue: string);
   function getdatasource1: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
   function getdatafield: string;
   procedure setdatafield(const avalue: string);

   procedure setlitop_widthmm(const avalue: real);
   procedure setlitop_color(const avalue: colorty);
   procedure setlitop_colorgap(const avalue: colorty);
   procedure setlitop_capstyle(const avalue: capstylety);
   procedure setlitop_dashes(const avalue: string);
   procedure setlitop_dist(const avalue: integer);
   procedure setlitop_visible(const avalue: linevisiblesty);

   procedure setlivert_widthmm(const avalue: real);
   function islivert_widthmmstored: boolean;
   procedure setlivert_color(const avalue: colorty);
   function islivert_colorstored: boolean;
   procedure setlivert_colorgap(const avalue: colorty);
   function islivert_colorgapstored: boolean;
   procedure setlivert_capstyle(const avalue: capstylety);
   function islivert_capstylestored: boolean;
   procedure setlivert_dashes(const avalue: string);
   function islivert_dashesstored: boolean;
   procedure setlivert_dist(const avalue: integer);
   function islivert_diststored: boolean;
   procedure setlivert_visible(const avalue: linevisiblesty);
   function islivert_visiblestored: boolean;

   procedure setlibottom_widthmm(const avalue: real);
   procedure setlibottom_color(const avalue: colorty);
   procedure setlibottom_colorgap(const avalue: colorty);
   procedure setlibottom_capstyle(const avalue: capstylety);
   procedure setlibottom_dashes(const avalue: string);
   procedure setlibottom_dist(const avalue: integer);
   procedure setlibottom_visible(const avalue: linevisiblesty);

               //idbeditinfo
   function getdatasource(const aindex: integer): tdatasource;
   procedure getfieldtypes(out apropertynames: stringarty;
                           out afieldtypes: fieldtypesarty);
  protected
   function xlineoffset: integer;
  public 
   constructor create(aowner: tobject); override;
   destructor destroy; override;
   property richvalue: richstringty read fvalue write setrichvalue;
  published
   property value: msestring read fvalue.text write setvalue;
   property font: treptabfont read getfont write setfont stored isfontstored;
   property textflags: textflagsty read ftextflags write settextflags 
                   default defaultreptabtextflags;
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource1 write setdatasource;

   property litop_widthmm: real read flineinfos[tlk_top].widthmm write
                 setlitop_widthmm;
   property litop_color: colorty read flineinfos[tlk_top].color write
                 setlitop_color default defaulttablinecolor;
   property litop_colorgap: colorty read flineinfos[tlk_top].colorgap write
                 setlitop_colorgap default defaulttablinecolorgap;
   property litop_capstyle: capstylety read flineinfos[tlk_top].capstyle write
                 setlitop_capstyle default defaulttablinecapstyle;
   property litop_dashes: string read flineinfos[tlk_top].dashes write
                 setlitop_dashes;
   property litop_dist: integer read flineinfos[tlk_top].dist write
                 setlitop_dist default defaulttablinedist;
   property litop_visible: linevisiblesty read flineinfos[tlk_top].visible write
                 setlitop_visible default defaulttablinevisible;

   property livert_widthmm: real read flineinfos[tlk_vert].widthmm write
                 setlivert_widthmm stored islivert_widthmmstored;
   property livert_color: colorty read flineinfos[tlk_vert].color write
                 setlivert_color stored islivert_colorstored
                                  default defaulttablinecolor;
   property livert_colorgap: colorty read flineinfos[tlk_vert].colorgap write
                 setlivert_colorgap stored islivert_colorgapstored
                                  default defaulttablinecolorgap;
   property livert_capstyle: capstylety read flineinfos[tlk_vert].capstyle write
                 setlivert_capstyle stored islivert_capstylestored
                                  default defaulttablinecapstyle;
   property livert_dashes: string read flineinfos[tlk_vert].dashes write
                 setlivert_dashes stored islivert_dashesstored;
   property livert_dist: integer read flineinfos[tlk_vert].dist write
                 setlivert_dist stored islivert_diststored
                                  default defaulttablinedist;
   property livert_visible: linevisiblesty read flineinfos[tlk_vert].visible write
                 setlivert_visible stored islivert_visiblestored 
                                  default defaulttablinevisible;
                 
   property libottom_widthmm: real read flineinfos[tlk_bottom].widthmm write
                 setlibottom_widthmm;
   property libottom_color: colorty read flineinfos[tlk_bottom].color write
                 setlibottom_color default defaulttablinecolor;
   property libottom_colorgap: colorty read flineinfos[tlk_bottom].colorgap write
                 setlibottom_colorgap default defaulttablinecolorgap;
   property libottom_capstyle: capstylety read flineinfos[tlk_bottom].capstyle write
                 setlibottom_capstyle default defaulttablinecapstyle;
   property libottom_dashes: string read flineinfos[tlk_bottom].dashes write
                                         setlibottom_dashes;
   property libottom_dist: integer read flineinfos[tlk_bottom].dist write
                                 setlibottom_dist default defaulttablinedist;
   property libottom_visible: linevisiblesty read flineinfos[tlk_bottom].visible write
                 setlibottom_visible default defaulttablinevisible;

   property ongetvalue: getrichstringeventty read fongetvalue write fongetvalue;
 end;
 
                 
 treptabulators = class(tcustomtabulators)
  private
   finfo: drawtextinfoty;
   fband: tcustomrecordband;
   fminsize: sizety;
   fsizevalid: boolean;
   flineinfos: tablineinfoarty;
   flistart: tablineinfoty;
   fliend: tablineinfoty;

   procedure setlitop_widthmm(const avalue: real);
   procedure setlitop_color(const avalue: colorty);
   procedure setlitop_colorgap(const avalue: colorty);
   procedure setlitop_capstyle(const avalue: capstylety);
   procedure setlitop_dashes(const avalue: string);
   procedure setlitop_dist(const avalue: integer);
   procedure setlitop_visible(const avalue: linevisiblesty);

   procedure setlistart_widthmm(const avalue: real);
   procedure setlistart_color(const avalue: colorty);
   procedure setlistart_colorgap(const avalue: colorty);
   procedure setlistart_capstyle(const avalue: capstylety);
   procedure setlistart_dashes(const avalue: string);
   procedure setlistart_dist(const avalue: integer);
   procedure setlistart_visible(const avalue: linevisiblesty);

   procedure setlivert_widthmm(const avalue: real);
   procedure setlivert_color(const avalue: colorty);
   procedure setlivert_colorgap(const avalue: colorty);
   procedure setlivert_capstyle(const avalue: capstylety);
   procedure setlivert_dashes(const avalue: string);
   procedure setlivert_dist(const avalue: integer);
   procedure setlivert_visible(const avalue: linevisiblesty);

   procedure setliend_widthmm(const avalue: real);
   procedure setliend_color(const avalue: colorty);
   procedure setliend_colorgap(const avalue: colorty);
   procedure setliend_capstyle(const avalue: capstylety);
   procedure setliend_dashes(const avalue: string);
   procedure setliend_dist(const avalue: integer);
   procedure setliend_visible(const avalue: linevisiblesty);

   procedure setlibottom_widthmm(const avalue: real);
   procedure setlibottom_color(const avalue: colorty);
   procedure setlibottom_colorgap(const avalue: colorty);
   procedure setlibottom_capstyle(const avalue: capstylety);
   procedure setlibottom_dashes(const avalue: string);
   procedure setlibottom_dist(const avalue: integer);
   procedure setlibottom_visible(const avalue: linevisiblesty);

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
                 
   property litop_widthmm: real read flineinfos[tlk_top].widthmm write
                 setlitop_widthmm;
   property litop_color: colorty read flineinfos[tlk_top].color write
                 setlitop_color default defaulttablinecolor;
   property litop_colorgap: colorty read flineinfos[tlk_top].colorgap write
                 setlitop_colorgap default defaulttablinecolorgap;
   property litop_capstyle: capstylety read flineinfos[tlk_top].capstyle write
                 setlitop_capstyle default defaulttablinecapstyle;
   property litop_dashes: string read flineinfos[tlk_top].dashes write
                 setlitop_dashes;
   property litop_dist: integer read flineinfos[tlk_top].dist write
                 setlitop_dist default defaulttablinedist;
   property litop_visible: linevisiblesty read flineinfos[tlk_top].visible write
                 setlitop_visible default defaulttablinevisible;

   property listart_widthmm: real read flistart.widthmm write
                 setlistart_widthmm;
   property listart_color: colorty read flistart.color write
                 setlistart_color default defaulttablinecolor;
   property listart_colorgap: colorty read flistart.colorgap write
                 setlistart_colorgap default defaulttablinecolorgap;
   property listart_capstyle: capstylety read flistart.capstyle write
                 setlistart_capstyle default defaulttablinecapstyle;
   property listart_dashes: string read flistart.dashes write
                 setlistart_dashes;
   property listart_dist: integer read flistart.dist write
                 setlistart_dist default defaulttablinedist;
   property listart_visible: linevisiblesty read flistart.visible write
                 setlistart_visible default defaulttablinevisible;

   property livert_widthmm: real read flineinfos[tlk_vert].widthmm write
                 setlivert_widthmm;
   property livert_color: colorty read flineinfos[tlk_vert].color write
                 setlivert_color default defaulttablinecolor;
   property livert_colorgap: colorty read flineinfos[tlk_vert].colorgap write
                 setlivert_colorgap default defaulttablinecolorgap;
   property livert_capstyle: capstylety read flineinfos[tlk_vert].capstyle write
                 setlivert_capstyle default defaulttablinecapstyle;
   property livert_dashes: string read flineinfos[tlk_vert].dashes write
                 setlivert_dashes;
   property livert_dist: integer read flineinfos[tlk_vert].dist write
                 setlivert_dist default defaulttablinedist;
   property livert_visible: linevisiblesty read flineinfos[tlk_vert].visible write
                 setlivert_visible default defaulttablinevisible;
                 
   property liend_widthmm: real read fliend.widthmm write
                 setliend_widthmm;
   property liend_color: colorty read fliend.color write
                 setliend_color default defaulttablinecolor;
   property liend_colorgap: colorty read fliend.colorgap write
                 setliend_colorgap default defaulttablinecolorgap;
   property liend_capstyle: capstylety read fliend.capstyle write
                 setliend_capstyle default defaulttablinecapstyle;
   property liend_dashes: string read fliend.dashes write
                 setliend_dashes;
   property liend_dist: integer read fliend.dist write
                 setliend_dist default defaulttablinedist;
   property liend_visible: linevisiblesty read fliend.visible write
                 setliend_visible default defaulttablinevisible;

   property libottom_widthmm: real read flineinfos[tlk_bottom].widthmm write
                 setlibottom_widthmm;
   property libottom_color: colorty read flineinfos[tlk_bottom].color write
                 setlibottom_color default defaulttablinecolor;
   property libottom_colorgap: colorty read flineinfos[tlk_bottom].colorgap write
                 setlibottom_colorgap default defaulttablinecolorgap;
   property libottom_capstyle: capstylety read flineinfos[tlk_bottom].capstyle
               write setlibottom_capstyle default defaulttablinecapstyle;
   property libottom_dashes: string read flineinfos[tlk_bottom].dashes write
                 setlibottom_dashes;
   property libottom_dist: integer read flineinfos[tlk_bottom].dist write
                 setlibottom_dist default defaulttablinedist;
   property libottom_visible: linevisiblesty read flineinfos[tlk_bottom].visible
               write setlibottom_visible default defaulttablinevisible;

   property defaultdist;
 end;
  
 recordbandstatety = (rbs_rendering,rbs_showed,rbs_pageshowed);
 recordbandstatesty = set of recordbandstatety; 
 
 ibandparent = interface(inullinterface)
                        ['{B02EE732-4686-4E0C-8C18-419D7D020386}']
  function beginband(const acanvas: tcanvas;
                              const sender: tcustomrecordband): boolean;
                   //true if area full
  procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
  function isfirstband: boolean;
  function islastband(const addheight: integer = 0): boolean;
  procedure updatevisible;
  function getwidget: twidget;
  function remainingheight: integer;
  function pagenum: integer; //null based
 end;

 trecordbanddatalink = class(tmsedatalink)
 end;

 bandvisibilityty = (bv_once,bv_evenpage,bv_oddpage,   
                          //page nums are null based
                  bv_firstofpageshow,bv_firstofpagehide,
                  bv_normalshow,bv_normalhide,
                  bv_lastofpageshow,bv_lastofpagehide);
 bandvisibilitiesty = set of bandvisibilityty;

const 
 visibilitymask = [bv_firstofpageshow,bv_firstofpagehide,
                    bv_normalshow,bv_normalhide,
                    bv_lastofpageshow,bv_lastofpagehide];

type                     
 tcustomrecordband = class(tcustomscalingwidget)
  private
   fparentintf: ibandparent;
   fonbeforerender: beforerenderrecordeventty;
   fonpaint: painteventty;
   fonafterpaint: painteventty;
   fstate: recordbandstatesty;
   ftabs: treptabulators;
   fupdating: integer;
   fdatalink: trecordbanddatalink;
   fvisibility: bandvisibilitiesty;
   procedure settabs(const avalue: treptabulators);
   procedure setdatasource(const avalue: tdatasource); virtual;
   function getdatasource: tdatasource;
   procedure setvisibility(const avalue: bandvisibilitiesty);
  protected
   procedure minclientsizechanged;
   procedure fontchanged; override;
   procedure inheritedpaint(const acanvas: tcanvas);
   procedure paint(const canvas: tcanvas); override;
   procedure setparentwidget(const avalue: twidget); override;   
   function getminbandsize: sizety; virtual;
   function calcminscrollsize: sizety; override;
   procedure render(const acanvas: tcanvas; var empty: boolean); virtual;
   procedure init; virtual;
   procedure initpage; virtual;
   procedure beginrender; virtual;
   procedure endrender; virtual;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doafterpaint(const acanvas: tcanvas); override;
   function rendering: boolean;
   function bandheight: integer;
   procedure dobeforerender(var empty: boolean); virtual;
   procedure synctofontheight; override;
   procedure updatevisibility; virtual;
   function lastbandheight: integer; virtual;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure beginupdate;
   procedure endupdate;
   function remainingbands: integer;
   
   property onbeforerender: beforerenderrecordeventty read fonbeforerender
                               write fonbeforerender;
   property onpaint: painteventty read fonpaint write fonpaint;
   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;
   property tabs: treptabulators read ftabs write settabs;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property datasource: tdatasource read getdatasource write setdatasource;
   property visibility: bandvisibilitiesty read fvisibility write setvisibility
                                                 default [];
  published
   property anchors default defaultbandanchors;
 end;

 trecordband = class(tcustomrecordband)
  published
   property font;
   property tabs;
   property datasource;
   property visibility;
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
   procedure setdatasource(const avalue: tdatasource); override;
  protected
   procedure setparentwidget(const avalue: twidget); override;   
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure dobeforerender(var empty: boolean); override;
//   procedure dorender(const acanvas: tcanvas); override;
//   procedure render(const acanvas: tcanvas; var empty: boolean); override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure updatevisibility; override;
   function getminbandsize: sizety; override;
   procedure init; override;
   procedure beginrender; override;
   procedure endrender; override;
   function lastbandheight: integer; override;
  public
   property font: twidgetfont read getfont write setfont stored isfontstored;
 end;

 tbandgroup = class(tcustombandgroup)
  published
   property font;
//   property tabs;
   property datasource;
   property visibility;
   property optionsscale;
   property onfontheightdelta;
   property onchildscaled;

   property onbeforerender;
   property onpaint;
   property onafterpaint;
 end;
 
 bandareastatety = (bas_inited,bas_backgroundrendered,bas_areafull,
                    bas_rendering,bas_notfirstband,bas_lastband,bas_bandstarted{,
                    bas_lastchecking,bas_lastchecked});
 bandareastatesty = set of bandareastatety; 

 tcustomreportpage = class;
   
 tcustombandarea = class(tpublishedwidget,ibandparent)
  private
   fbands: recordbandarty;
   fstate: bandareastatesty;
   factiveband: integer;
   facty: integer;
   factybefore: integer;
   fbandnum: integer;
   fsaveindex: integer;
   freportpage: tcustomreportpage;
   fonbeforerender: notifyeventty;
   fonpaint: painteventty;
   fonafterpaint: painteventty;
   function getareafull: boolean;
   procedure setareafull(const avalue: boolean);
   function getacty: integer;
  protected
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure setparentwidget(const avalue: twidget); override;   
   procedure paint(const canvas: tcanvas); override;
   procedure renderbackground(const acanvas: tcanvas);
   function render(const acanvas: tcanvas): boolean;
          //true if finished
   function rendering: boolean;
   procedure beginrender;
   procedure endrender;
   procedure dobeforerender; virtual;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doafterpaint1(const acanvas: tcanvas); virtual;
   procedure init; virtual;
   procedure initareapage;
   procedure initpage;
   function checkareafull(ay: integer): boolean;
           //ibandparent
   function beginband(const acanvas: tcanvas;
                               const sender: tcustomrecordband): boolean;
                    //true if area full
   procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
   procedure updatevisible;
  public
   function isfirstband: boolean;
   function islastband(const addheight: integer = 0): boolean;
   function remainingheight: integer;
   function pagenum: integer; //null based
   property acty: integer read getacty;
   property areafull: boolean read getareafull write setareafull;
   
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
   fonfirstpage: notifyeventty;
   fonafterlastpage: notifyeventty;
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
   procedure dofirstpage; virtual;
   procedure dobeforerender; virtual;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doafterpaint1(const acanvas: tcanvas); virtual;
   procedure doafterlastpage; virtual;
   procedure init; virtual;
   property ppmm: real read fppmm write setppmm; //pixel per mm
  public
   constructor create(aowner: tcomponent); override;
   function render(const acanvas: tcanvas): boolean;
          //true if empty
   property pagenum: integer read fpagenum write fpagenum; 
                            //null-based, local to this page
   property onfirstpage: notifyeventty read fonfirstpage
                               write fonfirstpage;
   property onbeforerender: notifyeventty read fonbeforerender
                               write fonbeforerender;
   property onpaint: painteventty read fonpaint write fonpaint;
   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;
   property onafterlastpage: notifyeventty read fonafterlastpage
                               write fonafterlastpage;

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
 
   property onfirstpage;
   property onbeforerender;
   property onpaint;   
   property onafterpaint;
   property onafterlastpage;
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
   fcanvas: tcanvas;
   fpagenum: integer;
   fthread: tmsethread;
   fppmmbefore: real;
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
   function exec(thread: tmsethread): integer;
   function getcanceled: boolean;
   procedure setcanceled(const avalue: boolean);
   function getrunning: boolean;
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
   procedure waitfor;
   
   property ppmm: real read fppmm write setppmm; //pixel per mm
   function reppagecount: integer;
   property reppages[index: integer]: tcustomreportpage read getreppages 
                                                write setreppages; default;
   property pagenum: integer read fpagenum {write fpagenum}; 
                            //null-based
   property font: twidgetfont read getfont write setfont;
   property color default cl_transparent;
   property grid_show: boolean read frepdesigninfo.showgrid write setgrid_show default true;
   property grid_snap: boolean read frepdesigninfo.snaptogrid write setgrid_snap default true;
   property grid_size: real read frepdesigninfo.gridsize write setgrid_size;   
   property canceled: boolean read getcanceled write setcanceled;
   property running: boolean read getrunning;

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
 msedatalist,sysutils,msestreaming,msebits;
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

{ treptabfont }

class function treptabfont.getinstancepo(owner: tobject): pfont;
begin
 result:= @treptabulatoritem(owner).ffont;
end;

{ treptabitemdatalink }

constructor treptabitemdatalink.create(const aowner: treptabulatoritem);
begin
 fowner:= aowner;
 inherited create;
end;

procedure treptabitemdatalink.recordchanged(afield: tfield);
begin
 if (afield = nil) or (afield = field) then begin
  treptabulators(fowner.fowner).fband.invalidate;
 end;
end;

{ treptabulatoritem }

constructor treptabulatoritem.create(aowner: tobject);
var
 kind1: tablinekindty;
begin
 ftextflags:= defaultreptabtextflags;
 fdatalink:= treptabitemdatalink.create(self);
 for kind1:= low(tablinekindty) to high(tablinekindty) do begin
  flineinfos[kind1]:= defaulttablineinfo;
 end;
 inherited;
 with treptabulators(aowner),fband do begin
  self.flineinfos[tlk_vert]:= flineinfos[tlk_vert];
  if not (csloading in componentstate) then begin
   self.datasource:= datasource;
  end;
 end;
end;

destructor treptabulatoritem.destroy;
begin
 inherited;
 ffont.free;
 fdatalink.free;
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

procedure treptabulatoritem.settextflags(const avalue: textflagsty);
begin
 if ftextflags <> avalue then begin
  ftextflags:= checktextflags(ftextflags,avalue);
  changed;
 end;
end;

procedure treptabulatoritem.setdatafiled(const avalue: string);
begin
 fdatalink.fieldname:= avalue
end;

function treptabulatoritem.getdatasource1: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure treptabulatoritem.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
 changed;
end;

function treptabulatoritem.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure treptabulatoritem.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

function treptabulatoritem.getdatasource(const aindex: integer): tdatasource;
begin
 result:= datasource;
end;

procedure treptabulatoritem.getfieldtypes(out apropertynames: stringarty;
               out afieldtypes: fieldtypesarty);
begin
 apropertynames:= nil;
 afieldtypes:= nil;
end;

function treptabulatoritem.getdisptext: richstringty;
begin
 if fdatalink.fieldactive then begin
  result.text:= fdatalink.msedisplaytext;
  result.format:= nil;
 end
 else begin
  result:= fvalue;
 end;
 if treptabulators(fowner).fband.canevent(tmethod(fongetvalue)) then begin
  fongetvalue(self,result);
 end;
end;

procedure treptabulatoritem.setlitop_widthmm(const avalue: real);
begin
 flineinfos[tlk_top].widthmm:= avalue;
 changed;
end;

procedure treptabulatoritem.setlitop_color(const avalue: colorty);
begin
 flineinfos[tlk_top].color:= avalue;
 changed;
end;

procedure treptabulatoritem.setlitop_colorgap(const avalue: colorty);
begin
 flineinfos[tlk_top].colorgap:= avalue;
 changed;
end;

procedure treptabulatoritem.setlitop_capstyle(const avalue: capstylety);
begin
 flineinfos[tlk_top].capstyle:= avalue;
 changed;
end;

procedure treptabulatoritem.setlitop_dashes(const avalue: string);
begin
 flineinfos[tlk_top].dashes:= avalue;
 changed;
end;

procedure treptabulatoritem.setlitop_dist(const avalue: integer);
begin
 flineinfos[tlk_top].dist:= avalue;
 changed;
end;

procedure treptabulatoritem.setlitop_visible(const avalue: linevisiblesty);
begin
 flineinfos[tlk_top].visible:= avalue;
 changed;
end;

procedure treptabulatoritem.setlivert_widthmm(const avalue: real);
begin
 flineinfos[tlk_vert].widthmm:= avalue;
 changed;
end;

function treptabulatoritem.islivert_widthmmstored: boolean;
begin
 result:= flineinfos[tlk_vert].widthmm <> 
                treptabulators(fowner).flineinfos[tlk_vert].widthmm;
end;

procedure treptabulatoritem.setlivert_color(const avalue: colorty);
begin
 flineinfos[tlk_vert].color:= avalue;
 changed;
end;

function treptabulatoritem.islivert_colorstored: boolean;
begin
 result:= flineinfos[tlk_vert].color <> 
               treptabulators(fowner).flineinfos[tlk_vert].color;
end;

procedure treptabulatoritem.setlivert_colorgap(const avalue: colorty);
begin
 flineinfos[tlk_vert].colorgap:= avalue;
 changed;
end;

function treptabulatoritem.islivert_colorgapstored: boolean;
begin
 result:= flineinfos[tlk_vert].colorgap <> 
              treptabulators(fowner).flineinfos[tlk_vert].colorgap;
end;

procedure treptabulatoritem.setlivert_capstyle(const avalue: capstylety);
begin
 flineinfos[tlk_vert].capstyle:= avalue;
 changed;
end;

function treptabulatoritem.islivert_capstylestored: boolean;
begin
 result:= flineinfos[tlk_vert].capstyle <> 
              treptabulators(fowner).flineinfos[tlk_vert].capstyle;
end;

procedure treptabulatoritem.setlivert_dashes(const avalue: string);
begin
 flineinfos[tlk_vert].dashes:= avalue;
 changed;
end;

function treptabulatoritem.islivert_dashesstored: boolean;
begin
 result:= flineinfos[tlk_vert].dashes <> 
              treptabulators(fowner).flineinfos[tlk_vert].dashes;
end;

procedure treptabulatoritem.setlivert_dist(const avalue: integer);
begin
 flineinfos[tlk_vert].dist:= avalue;
 changed;
end;

function treptabulatoritem.islivert_diststored: boolean;
begin
 result:= flineinfos[tlk_vert].dist <> 
              treptabulators(fowner).flineinfos[tlk_vert].dist;
end;

procedure treptabulatoritem.setlivert_visible(const avalue: linevisiblesty);
begin
 flineinfos[tlk_vert].visible:= avalue;
 changed;
end;

function treptabulatoritem.islivert_visiblestored: boolean;
begin
 result:= flineinfos[tlk_vert].visible <> 
              treptabulators(fowner).flineinfos[tlk_vert].visible;
end;

procedure treptabulatoritem.setlibottom_widthmm(const avalue: real);
begin
 flineinfos[tlk_bottom].widthmm:= avalue;
 changed;
end;

procedure treptabulatoritem.setlibottom_color(const avalue: colorty);
begin
 flineinfos[tlk_bottom].color:= avalue;
 changed;
end;

procedure treptabulatoritem.setlibottom_colorgap(const avalue: colorty);
begin
 flineinfos[tlk_bottom].colorgap:= avalue;
 changed;
end;

procedure treptabulatoritem.setlibottom_capstyle(const avalue: capstylety);
begin
 flineinfos[tlk_bottom].capstyle:= avalue;
 changed;
end;

procedure treptabulatoritem.setlibottom_dashes(const avalue: string);
begin
 flineinfos[tlk_bottom].dashes:= avalue;
 changed;
end;

procedure treptabulatoritem.setlibottom_dist(const avalue: integer);
begin
 flineinfos[tlk_bottom].dist:= avalue;
 changed;
end;

procedure treptabulatoritem.setlibottom_visible(const avalue: linevisiblesty);
begin
 flineinfos[tlk_bottom].visible:= avalue;
 changed;
end;

function treptabulatoritem.xlineoffset: integer;
begin
 with flineinfos[tlk_vert] do begin
  if kind = tak_left then begin
   result:= -dist;
  end
  else begin
   result:= dist;
  end;
 end; 
end;

{ treptabulators }

constructor treptabulators.create(const aowner: tcustomrecordband);
var
 kind1: tablinekindty;
begin
 fband:= aowner;
 flistart:= defaulttablineinfo;
 fliend:= defaulttablineinfo;
 for kind1:= low(tablinekindty) to high(tablinekindty) do begin
  flineinfos[kind1]:= defaulttablineinfo;
 end;
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
 bo1: boolean;
 bandcx: integer;
 visiblemask: linevisiblesty;
 
 procedure checkinit(const ainfo: tablineinfoty);
 begin
  if not bo1 then begin
   bo1:= true;
   acanvas.save;
   acanvas.move(makepoint(adest.x,0));
   acanvas.addclipframe(makerect(nullpoint,fband.paintsize),1000);
  end;
  with ainfo do begin
   acanvas.linewidthmm:= widthmm;
   acanvas.capstyle:= capstyle;
   if (dashes <> '') and (colorgap <> cl_transparent) then begin
    acanvas.dashes:= copy(dashes+#0,1,high(dashesstringty));
    acanvas.colorbackground:= colorgap;
   end
   else begin
    acanvas.dashes:= copy(dashes,1,high(dashesstringty));
   end;
  end;
 end;
 
 procedure drawhorzline(const aindex: integer; const akind: tablinekindty);
  function nextx: integer;
  begin
   if aindex < high(ftabs) then begin
    with ftabs[aindex+1] do begin
     result:= pos + treptabulatoritem(fitems[index]).xlineoffset;
    end;
   end
   else begin
    result:= bandcx;
   end;
  end;
  
 var
  startx,endx,y: integer;
 begin
  with treptabulatoritem(fitems[ftabs[aindex].index]) do begin
   with flineinfos[akind] do begin
    if widthmm > 0 then begin
     if visible * visiblemask <> [] then begin
      checkinit(flineinfos[akind]);
      with ftabs[aindex] do begin     
       case kind of
        tak_left: begin
         startx:= pos + xlineoffset;
         endx:= nextx;
        end;
        else begin
         if aindex > 0 then begin
          with ftabs[aindex-1] do begin
           startx:= pos + treptabulatoritem(fitems[index]).xlineoffset;
          end;
         end
         else begin
          startx:= 0;
         end;
         if kind = tak_centered then begin
          endx:= nextx;
         end
         else begin
          endx:= pos + xlineoffset;
         end;
        end;
       end;
      end;
      if akind = tlk_top then begin
       y:= - flineinfos[tlk_top].dist;
      end
      else begin
       y:= treptabulators(fowner).fband.clientheight + 
                      flineinfos[tlk_bottom].dist;
      end;
      acanvas.drawline(makepoint(startx,y),makepoint(endx,y),color);
     end;
    end;
   end;
  end;
 end;
 
var
 int1,int2,int3: integer;
 bo2: boolean;
 rstr1: richstringty;
 
begin
 fminsize:= nullsize;
 bandcx:= fband.innerclientsize.cx;
 bo1:= false;
 if apaint then begin
  with fband do begin
   if not rendering or (fparentintf = nil) then begin 
    visiblemask:= [lv_first,lv_normal,lv_last];
   end
   else begin
    visiblemask:= [lv_normal];    
    with fparentintf do begin
     if isfirstband then begin
      include(visiblemask,lv_first);
      exclude(visiblemask,lv_normal);
     end;
     if islastband then begin
      include(visiblemask,lv_last);
      exclude(visiblemask,lv_normal);
     end;
    end;
   end;
  end;
 end;
 if count > 0 then begin
  checkuptodate;
  with finfo do begin
   for int1:= 0 to count - 1 do begin
    with ftabs[int1] do begin
     with treptabulatoritem(fitems[index]) do begin
      text:= getdisptext;
      finfo.font:= font;
      flags:= ftextflags;
     end;
     dest:= adest;
     if (kind = tak_left) and (int1 = high(ftabs)) then begin
      dest.cx:= adest.cx - pos;
     end
     else begin
      dest.cx:= width;
     end;
     textrect(acanvas,finfo);
     dest.cx:= res.cx;
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
       int2:= findlastchar(text.text,msechar(decimalseparator));
       if int2 > 0 then begin
        rstr1:= richcopy(text,int2,bigint);
        int3:= textrect(acanvas,rstr1,[],finfo.font).cx;
       end
       else begin
        int3:= 0;
       end;
       dest.x:= adest.x + pos - res.cx + int3; 
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
  if apaint then begin
   for int1:= 0 to count - 1 do begin
    with treptabulatoritem(fitems[ftabs[int1].index]) do begin
     with flineinfos[tlk_vert] do begin
      if widthmm > 0 then begin
       if visible * visiblemask <> [] then begin
        checkinit(flineinfos[tlk_vert]);
        with ftabs[int1] do begin
         case kind of 
          tak_left: begin
           int2:= pos - dist
          end
          else begin
           int2:= pos + dist;
          end;
         end;
        end;
        acanvas.drawline(makepoint(int2,fband.clientheight),
                                              makepoint(int2,0),color);
       end;
      end;
     end;
    end;
    drawhorzline(int1,tlk_top);
    drawhorzline(int1,tlk_bottom);
   end;
  end;
 end;
 bo2:= bo1;
 acanvas.remove(makepoint(adest.x,0));
 if apaint then begin
  bandcx:= fband.clientwidth;
  with flistart do begin
   if widthmm > 0 then begin
    if visible * visiblemask <> [] then begin
     checkinit(flistart);
     acanvas.drawline(makepoint(-dist,
            fband.clientheight+flineinfos[tlk_bottom].dist),
                          makepoint(-dist,-flineinfos[tlk_top].dist),color);
    end;
   end;
  end;
  with fliend do begin
   if widthmm > 0 then begin
    if visible * visiblemask <> [] then begin
     checkinit(fliend);
     acanvas.drawline(makepoint(bandcx+dist,fband.clientheight+
                               flineinfos[tlk_bottom].dist),
                    makepoint(bandcx+dist,-flineinfos[tlk_top].dist),color);
    end;
   end;
  end;
  with flineinfos[tlk_top] do begin
   if widthmm > 0 then begin
    if visible * visiblemask <> [] then begin
     checkinit(flineinfos[tlk_top]);
     acanvas.drawline(makepoint(-flistart.dist,-dist),
                                makepoint(bandcx+fliend.dist,-dist),color);
    end;
   end;
  end;
  with flineinfos[tlk_bottom] do begin
   if widthmm > 0 then begin
    if visible * visiblemask <> [] then begin
     checkinit(flineinfos[tlk_bottom]);
     int2:= fband.clientheight+dist;
     acanvas.drawline(makepoint(-flistart.dist,int2),
                               makepoint(bandcx+fliend.dist,int2),color);
    end;
   end;
  end;
 end;
 if bo1 then begin
  acanvas.restore;
  if not bo2 then begin
   acanvas.move(makepoint(adest.x,0));
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

procedure treptabulators.setlitop_widthmm(const avalue: real);
begin
 if avalue <> flineinfos[tlk_top].widthmm then begin
  flineinfos[tlk_top].widthmm:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlitop_color(const avalue: colorty);
begin
 if avalue <> flineinfos[tlk_top].color then begin
  flineinfos[tlk_top].color:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlitop_colorgap(const avalue: colorty);
begin
 if avalue <> flineinfos[tlk_top].colorgap then begin
  flineinfos[tlk_top].colorgap:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlitop_capstyle(const avalue: capstylety);
begin
 if avalue <> flineinfos[tlk_top].capstyle then begin
  flineinfos[tlk_top].capstyle:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlitop_dashes(const avalue: string);
begin
 if avalue <> flineinfos[tlk_top].dashes then begin
  flineinfos[tlk_top].dashes:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlitop_dist(const avalue: integer);
begin
 if avalue <> flineinfos[tlk_top].dist then begin
  flineinfos[tlk_top].dist:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlitop_visible(const avalue: linevisiblesty);
begin
 if avalue <> flineinfos[tlk_top].visible then begin
  flineinfos[tlk_top].visible:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlistart_widthmm(const avalue: real);
begin
 if avalue <> flistart.widthmm then begin
  flistart.widthmm:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlistart_color(const avalue: colorty);
begin
 if avalue <> flistart.color then begin
  flistart.color:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlistart_colorgap(const avalue: colorty);
begin
 if avalue <> flistart.colorgap then begin
  flistart.colorgap:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlistart_capstyle(const avalue: capstylety);
begin
 if avalue <> flistart.capstyle then begin
  flistart.capstyle:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlistart_dashes(const avalue: string);
begin
 if avalue <> flistart.dashes then begin
  flistart.dashes:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlistart_dist(const avalue: integer);
begin
 if avalue <> flistart.dist then begin
  flistart.dist:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlistart_visible(const avalue: linevisiblesty);
begin
 if avalue <> flistart.visible then begin
  flistart.visible:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlivert_widthmm(const avalue: real);
var
 int1: integer;
begin
 if avalue <> flineinfos[tlk_vert].widthmm then begin
  flineinfos[tlk_vert].widthmm:= avalue;
  for int1:= 0 to high(fitems) do begin
   treptabulatoritem(fitems[int1]).livert_widthmm:= avalue;
  end;
 end;
end;

procedure treptabulators.setlivert_color(const avalue: colorty);
var
 int1: integer;
begin
 if avalue <> flineinfos[tlk_vert].color then begin
  flineinfos[tlk_vert].color:= avalue;
  for int1:= 0 to high(fitems) do begin
   treptabulatoritem(fitems[int1]).livert_color:= avalue;
  end;
 end;
end;

procedure treptabulators.setlivert_colorgap(const avalue: colorty);
var
 int1: integer;
begin
 if avalue <> flineinfos[tlk_vert].colorgap then begin
  flineinfos[tlk_vert].colorgap:= avalue;
  for int1:= 0 to high(fitems) do begin
   treptabulatoritem(fitems[int1]).livert_colorgap:= avalue;
  end;
 end;
end;

procedure treptabulators.setlivert_capstyle(const avalue: capstylety);
var
 int1: integer;
begin
 if avalue <> flineinfos[tlk_vert].capstyle then begin
  flineinfos[tlk_vert].capstyle:= avalue;
  for int1:= 0 to high(fitems) do begin
   treptabulatoritem(fitems[int1]).livert_capstyle:= avalue;
  end;
 end;
end;

procedure treptabulators.setlivert_dashes(const avalue: string);
var
 int1: integer;
begin
 if avalue <> flineinfos[tlk_vert].dashes then begin
  flineinfos[tlk_vert].dashes:= avalue;
  for int1:= 0 to high(fitems) do begin
   treptabulatoritem(fitems[int1]).livert_dashes:= avalue;
  end;
 end;
end;

procedure treptabulators.setlivert_dist(const avalue: integer);
var
 int1: integer;
begin
 if avalue <> flineinfos[tlk_vert].dist then begin
  flineinfos[tlk_vert].dist:= avalue;
  for int1:= 0 to high(fitems) do begin
   treptabulatoritem(fitems[int1]).livert_dist:= avalue;
  end;
 end;
end;

procedure treptabulators.setlivert_visible(const avalue: linevisiblesty);
var
 int1: integer;
begin
 if avalue <> flineinfos[tlk_vert].visible then begin
  flineinfos[tlk_vert].visible:= avalue;
  for int1:= 0 to high(fitems) do begin
   treptabulatoritem(fitems[int1]).livert_visible:= avalue;
  end;
 end;
end;

procedure treptabulators.setliend_widthmm(const avalue: real);
begin
 if avalue <> fliend.widthmm then begin
  fliend.widthmm:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setliend_color(const avalue: colorty);
begin
 if avalue <> fliend.color then begin
  fliend.color:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setliend_colorgap(const avalue: colorty);
begin
 if avalue <> fliend.colorgap then begin
  fliend.colorgap:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setliend_capstyle(const avalue: capstylety);
begin
 if avalue <> fliend.capstyle then begin
  fliend.capstyle:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setliend_dashes(const avalue: string);
begin
 if avalue <> fliend.dashes then begin
  fliend.dashes:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setliend_dist(const avalue: integer);
begin
 if avalue <> fliend.dist then begin
  fliend.dist:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setliend_visible(const avalue: linevisiblesty);
begin
 if avalue <> fliend.visible then begin
  fliend.visible:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlibottom_widthmm(const avalue: real);
begin
 if avalue <> flineinfos[tlk_bottom].widthmm then begin
  flineinfos[tlk_bottom].widthmm:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlibottom_color(const avalue: colorty);
begin
 if avalue <> flineinfos[tlk_bottom].color then begin
  flineinfos[tlk_bottom].color:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlibottom_colorgap(const avalue: colorty);
begin
 if avalue <> flineinfos[tlk_bottom].colorgap then begin
  flineinfos[tlk_bottom].colorgap:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlibottom_capstyle(const avalue: capstylety);
begin
 if avalue <> flineinfos[tlk_bottom].capstyle then begin
  flineinfos[tlk_bottom].capstyle:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlibottom_dashes(const avalue: string);
begin
 if avalue <> flineinfos[tlk_bottom].dashes then begin
  flineinfos[tlk_bottom].dashes:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlibottom_dist(const avalue: integer);
begin
 if avalue <> flineinfos[tlk_bottom].dist then begin
  flineinfos[tlk_bottom].dist:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlibottom_visible(const avalue: linevisiblesty);
begin
 if avalue <> flineinfos[tlk_bottom].visible then begin
  flineinfos[tlk_bottom].visible:= avalue;
  fband.invalidate;
 end;
end;

{ tcustomrecordband }

constructor tcustomrecordband.create(aowner: tcomponent);
begin
 ftabs:= treptabulators.create(self);
 fdatalink:= trecordbanddatalink.create;
 inherited;
 fanchors:= defaultbandanchors;
 foptionswidget:= defaultbandoptionswidget;
end;

destructor tcustomrecordband.destroy;
begin
 ftabs.free;
 fdatalink.free;
 inherited;
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
 if fdatalink.active then begin
  empty:= fdatalink.dataset.eof;
 end;
 if canevent(tmethod(fonbeforerender)) then begin
  application.lock;
  try
   fonbeforerender(self,empty);
  finally
   application.unlock;
  end;
 end;
end;

procedure tcustomrecordband.doonpaint(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonpaint)) then begin
  application.lock;
  try
   fonpaint(self,acanvas);
  finally
   application.unlock;
  end;
 end;
end;

procedure tcustomrecordband.render(const acanvas: tcanvas; var empty: boolean);
var
 widget1: twidget;
begin
 widget1:= rootwidget;
 if (widget1 is tcustomreport) and 
                       tcustomreport(widget1).fthread.terminated then begin
  abort;
 end;
 application.checkoverload;
 fparentintf.updatevisible; //??
 dobeforerender(empty);
 fparentintf.updatevisible;
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
 //dummy
end;

procedure tcustomrecordband.initpage;
begin
 exclude(fstate,rbs_pageshowed);
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
 if (rbs_rendering in fstate) then begin
  if canevent(tmethod(fonafterpaint)) then begin
   application.lock;
   try
    fonafterpaint(self,acanvas);
   finally
    application.unlock;
   end;
  end;
  if fdatalink.active then begin
   fdatalink.dataset.next;
  end;
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

function tcustomrecordband.getminbandsize: sizety;
begin
 ftabs.checksize;
 result:= ftabs.fminsize;
end;

function tcustomrecordband.calcminscrollsize: sizety;
var
 size1: sizety;
begin
 result:= inherited calcminscrollsize;
 size1:= getminbandsize;
 if fframe <> nil then begin
  addsize1(size1,tcustomframe1(fframe).fi.innerframe.bottomright);
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

procedure tcustomrecordband.setdatasource(const avalue: tdatasource);
var
 int1: integer;
begin
 fdatalink.datasource:= avalue;
 if (componentstate*[csdesigning,csloading] = [csdesigning]) and 
                           (avalue <> nil) then begin
  for int1:= 0 to ftabs.count - 1 do begin
   ftabs[int1].datasource:= avalue;
  end;
 end;
end;

function tcustomrecordband.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tcustomrecordband.setvisibility(const avalue: bandvisibilitiesty);
const
 firstmask: bandvisibilitiesty = [bv_firstofpageshow,bv_firstofpagehide];
 normalmask: bandvisibilitiesty = [bv_normalshow,bv_normalhide];
 lastmask: bandvisibilitiesty = [bv_lastofpageshow,bv_lastofpagehide];
var
 vis1: bandvisibilitiesty;
begin
 vis1:= bandvisibilitiesty(setsinglebit(longword(avalue),longword(fvisibility),
                                 longword(firstmask)));
 vis1:= bandvisibilitiesty(setsinglebit(longword(vis1),longword(fvisibility),
                                 longword(normalmask)));
 fvisibility:= bandvisibilitiesty(setsinglebit(longword(vis1),
                                 longword(fvisibility),longword(lastmask)));
end;

procedure tcustomrecordband.synctofontheight;
begin
 syncsinglelinefontheight(true);
end;

procedure tcustomrecordband.updatevisibility;
var
 first,last,showed,hidden: boolean;
begin
 if fparentintf <> nil then begin
  if fvisibility * visibilitymask <> [] then begin
   first:= fparentintf.isfirstband;
   last:= fparentintf.islastband;
   if first then begin
    if bv_firstofpageshow in fvisibility then begin
     visible:= true;
     exit;
    end
    else begin
     if bv_firstofpagehide in fvisibility then begin
      visible:= false;
     end;
    end;
   end;
   if last then begin
    if bv_lastofpageshow in fvisibility then begin
     exit;
     visible:= true;
    end
    else begin
     if bv_lastofpagehide in fvisibility then begin
      visible:= false;
     end;
    end;
   end;
   if not first and not last then begin
    if bv_normalshow in fvisibility then begin
     exit;
     visible:= true;
    end
    else begin
     if bv_normalhide in fvisibility then begin
      visible:= false;
     end;
    end;
   end;
  end;
 end;
end;

function tcustomrecordband.lastbandheight: integer;
begin
 result:= bounds_cy;
end;

function tcustomrecordband.remainingbands: integer;
var
 widget1,widget2,widget3: twidget;
 int1,int2: integer;
begin
 result:= 0;
 if fparentintf <> nil then begin
  widget3:= fparentintf.getwidget;
  widget1:= self;
  repeat
   widget2:= widget1;
   widget1:= widget1.parentwidget;
  until (widget1 = widget3);
  if widget2 is tcustomrecordband then begin
   with tcustomrecordband(widget2) do begin
    int2:= fparentintf.remainingheight - lastbandheight;
    if int2 >= 0 then begin
     if bounds_cy <= 0 then begin
      result:= bigint;
     end
     else begin
      result:= 1 + int2 div bounds_cy;
     end;
    end;
   end;
  end;
 end;
end;

{ tcustombandgroup }

procedure tcustombandgroup.registerchildwidget(const child: twidget);
begin
 if child is tcustomrecordband then begin
  inherited;
  additem(pointerarty(fbands),child);
  with tcustomrecordband(child) do begin
   fparentintf:= self.fparentintf;
   include(fwidgetstate1,ws1_nominsize);
  end;
 end
 else begin
  raise exception.create('Widget must be tcustomrecordband.');
 end;
end;

procedure tcustombandgroup.unregisterchildwidget(const child: twidget);
begin
 removeitem(pointerarty(fbands),child);
 inherited;
 exclude(tcustomrecordband(child).fwidgetstate1,ws1_nominsize);
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

procedure tcustombandgroup.dopaint(const acanvas: tcanvas);
var
 int1,int2,int3: integer;
 pt1: pointty;
begin
 inherited;
 if rendering then begin
  pt1:= acanvas.origin;
  int2:= pt1.x - paintpos.x;
  int3:= pt1.y + innerclientpos.y;
  for int1:= 0 to high(fbands) do begin
   with fbands[int1] do begin
    if visible then begin
     acanvas.origin:= makepoint(int2 + bounds_x,int3);
     inheritedpaint(acanvas);
     inc(int3,bounds_cy);
//     acanvas.move(makepoint(0,bounds_cy));
    end;
   end;
  end;
  acanvas.origin:= pt1;
 end;
end;

procedure tcustombandgroup.setdatasource(const avalue: tdatasource);
var
 int1,int2: integer;
begin
 inherited;
 if (componentstate*[csdesigning,csloading] = [csdesigning]) and 
                                               (avalue <> nil) then begin
  for int1:= 0 to high(fbands) do begin
   with fbands[int1] do begin
    if datasource = nil then begin
     for int2:= 0 to ftabs.count - 1 do begin
      ftabs[int1].datasource:= avalue;
     end;
    end;
   end;
  end;
 end; 
end;

procedure tcustombandgroup.setparentwidget(const avalue: twidget);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].fparentintf:= fparentintf;
 end;
end;

procedure tcustombandgroup.updatevisibility;
var
 int1: integer;
begin
 inherited;
 beginscaling;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].updatevisibility;
 end;
 endscaling;
end;

function tcustombandgroup.getminbandsize: sizety;
var
 int1,int2,int3: integer;
begin
 result:= inherited getminbandsize;
 int2:= 0;
 for int1:= 0 to high(fbands) do begin
  with fbands[int1] do begin
   if visible then begin
    int3:= bounds_x + bounds_cx;
    if int3 > result.cx then begin
     result.cx:= int3;
    end;
    inc(int2,bounds_cy);
   end;
  end;
 end;
 if int2 > result.cy then begin
  result.cy:= int2;
 end;
end;

function tcustombandgroup.lastbandheight: integer;
var
 int1,int2: integer;
begin
 result:= inherited lastbandheight;
 if osc_expandy in optionsscale then begin
  int2:= innerclientframewidth.cy;
  for int1:= 0 to high(fbands) do begin
   with fbands[int1] do begin
    if visible and not (bv_lastofpagehide in visibility) or 
           (bv_lastofpageshow in visibility) then begin
     int2:= int2 + bounds_cy;
    end;
   end;
  end;
  if int2 > result then begin
   result:= int2;
  end;
 end;
end;

procedure tcustombandgroup.init;
begin
 sortwidgetsyorder(widgetarty(fbands));
 inherited;
end;

procedure tcustombandgroup.beginrender;
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].beginrender;
 end;
end;

procedure tcustombandgroup.endrender;
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].endrender;
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

procedure tcustombandarea.init;
var
 int1: integer;
begin
 factiveband:= 0;
 include(fstate,bas_inited);
 sortwidgetsyorder(widgetarty(fbands));
 for int1:= 0 to high(fbands) do begin
  fbands[int1].init;
 end;
 initareapage;
end;

procedure tcustombandarea.initpage;
var
 int1: integer;
begin
  factiveband:= 0;
  sortwidgetsyorder(widgetarty(fbands));
  for int1:= 0 to high(fbands) do begin
   fbands[int1].initpage;
  end;
 fstate:= fstate - [bas_areafull,bas_backgroundrendered,bas_notfirstband,
                             bas_lastband];
end;

function tcustombandarea.render(const acanvas: tcanvas): boolean;
var                     //true if finished
 bo1,bo2: boolean;
begin
 result:= true;
 if not (bas_inited in fstate) then begin
  init;
 end;
 try
  initpage;
  if factiveband <= high(fbands) then begin
   updatevisible;
   dobeforerender;
   while (factiveband <= high(fbands)) and not areafull do begin
    exclude(fstate,bas_bandstarted);
    while (factiveband <= high(fbands)) and 
                            not fbands[factiveband].visible do begin
     inc(factiveband);
    end;
    if factiveband <= high(fbands) then begin
     with fbands[factiveband] do begin
      bo2:= odd(fparentintf.pagenum);
      bo2:= bo2 and (bv_oddpage in fvisibility) or 
            not bo2 and (bv_evenpage in fvisibility);
      bo1:= ((rbs_showed in fstate) or not(bv_once in fvisibility)) and
            ((rbs_pageshowed in fstate) or not bo2);   //empty    
      render(acanvas,bo1);
      bo1:= bo1 or bo2{(bv_everypage in fvisibility)};
      fstate:= fstate + [rbs_showed,rbs_pageshowed];
     end;
     result:= bo1;
//     result:= result and bo1;
     if bo1 then begin
      repeat
       inc(factiveband);
      until (factiveband > high(fbands)) or fbands[factiveband].visible;
     end;
    end;
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

procedure tcustombandarea.initareapage;
begin
 exclude(fstate,bas_notfirstband);
 facty:= innerclientwidgetpos.y + bounds_y;
 fbandnum:= 0;
end;

procedure tcustombandarea.dobeforerender;
begin
 if canevent(tmethod(fonbeforerender)) then begin
  application.lock;
  try
   fonbeforerender(self);
  finally
   application.unlock;
  end;
 end;
end;

procedure tcustombandarea.doonpaint(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonpaint)) then begin
  application.lock;
  try
   fonpaint(self,acanvas);
  finally
   application.unlock;
  end;
 end;
end;

procedure tcustombandarea.doafterpaint1(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonafterpaint)) then begin
  application.lock;
  try
   fonafterpaint(self,acanvas);
  finally
   application.unlock;
  end;
 end;
end;

procedure tcustombandarea.renderbackground(const acanvas: tcanvas);
begin
 freportpage.beginarea(acanvas,self);
 acanvas.origin:= pos;
 inherited paint(acanvas);
end;

function tcustombandarea.checkareafull(ay: integer): boolean;
begin
 if frame <> nil then begin
  ay:= ay + fframe.innerframe.bottom;
 end;
 result:= ay > bounds_y + bounds_cy;
end;

function tcustombandarea.getacty: integer;
begin
 if (bas_bandstarted in fstate) then begin
  result:= factybefore;
 end
 else begin
  result:= facty;
 end;
 result:= result - (innerclientwidgetpos.y + bounds_y);
end;

function tcustombandarea.remainingheight: integer;
begin
 result:= facty - (bounds_y + bounds_cy);
 if fframe <> nil then begin
  result:= result - fframe.innerframe.bottom;
 end;
end;

function tcustombandarea.beginband(const acanvas: tcanvas;
                             const sender: tcustomrecordband): boolean;
var
 bo1: boolean;
begin
 fsaveindex:= acanvas.save;
 bo1:= (bas_backgroundrendered in fstate);
 if not bo1 then begin
  include(fstate,bas_backgroundrendered);
  renderbackground(acanvas);
  initareapage
 end;
 acanvas.origin:= makepoint(sender.bounds_x+bounds_x,facty);
 factybefore:= facty;
 inc(facty,sender.bandheight);
 include(fstate,bas_bandstarted);
 result:= bo1 and checkareafull(facty);
                //print minimum one band
 if result then begin
  include(fstate,bas_areafull);
  initareapage;
 end;
end;

procedure tcustombandarea.endband(const acanvas: tcanvas;
                                      const sender: tcustomrecordband);
begin
 acanvas.restore(fsaveindex); 
 include(fstate,bas_notfirstband);
 inc(fbandnum);
end;

function tcustombandarea.getareafull: boolean;
begin
 result:= bas_areafull in fstate;
end;

procedure tcustombandarea.setareafull(const avalue: boolean);
begin
 if avalue then begin
  include(fstate,bas_areafull);
 end
 else begin
  exclude(fstate,bas_areafull);
 end;
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

function tcustombandarea.isfirstband: boolean;
begin
 result:= not (rbs_pageshowed in fbands[factiveband].fstate);
// result:= not (bas_notfirstband in fstate);
end;

function tcustombandarea.islastband(const addheight: integer = 0): boolean;
var
 int1: integer;
begin
 result:= fstate * [bas_lastband{,bas_lastchecking}] <> [];
 if not result {and not(bas_lastchecked in fstate)} then begin
  with fbands[factiveband] do begin
   int1:= facty + addheight + lastbandheight;
   if not (bas_bandstarted in self.fstate) then begin
    int1:= int1 + bounds_cy;
   end;
  end;
  result:= checkareafull(int1);
 end;
end;

procedure tcustombandarea.updatevisible;
var
 int1: integer;
begin
 for int1:= 0 to high(fbands) do begin
  fbands[int1].updatevisibility;
 end;
end;

function tcustombandarea.pagenum: integer;
begin
 result:= tcustomreport(freportpage.owner).pagenum;
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
 bo1: boolean;
begin
 if not (rpps_inited in fstate) then begin
  init;
 end;
 fpagenum:= 0;
 dofirstpage;
 result:= true;
 repeat
  exclude(fstate,rpps_backgroundrendered);
  acanvas.reset;
  acanvas.intersectcliprect(makerect(nullpoint,fwidgetrect.size));
  dobeforerender;
  bo1:= true;
  for int1:= 0 to high(fareas) do begin
   bo1:= fareas[int1].render(acanvas) and bo1;
  end;
  if rpps_backgroundrendered in fstate then begin
   doafterpaint1(acanvas);
  end;
  inc(fpagenum);
  if freport <> nil then begin
   inc(freport.fpagenum);
  end;
  result:= result and bo1;
 until bo1;
 doafterlastpage;
end;

function tcustomreportpage.rendering: boolean;
begin
 result:= rpps_rendering in fstate;
end;

procedure tcustomreportpage.dobeforerender;
begin
 if canevent(tmethod(fonbeforerender)) then begin
  application.lock;
  try
   fonbeforerender(self);
  finally
   application.unlock;
  end;
 end;
end;

procedure tcustomreportpage.doonpaint(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonpaint)) then begin
  application.lock;
  try
   fonpaint(self,acanvas);
  finally
   application.unlock;
  end;
 end;
end;

procedure tcustomreportpage.doafterpaint1(const acanvas: tcanvas);
begin
 if canevent(tmethod(fonafterpaint)) then begin
  application.lock;
  try
   fonafterpaint(self,acanvas);
  finally
   application.unlock;
  end;
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

procedure tcustomreportpage.dofirstpage;
begin
 if canevent(tmethod(fonfirstpage)) then begin
  application.lock;
  try
   fonfirstpage(self);
  finally
   application.unlock;
  end;
 end;
end;

procedure tcustomreportpage.doafterlastpage;
begin
 if canevent(tmethod(fonafterlastpage)) then begin
  application.lock;
  try
   fonafterlastpage(self);
  finally
   application.unlock;
  end;
 end;
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
begin
 fthread.free;
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

function tcustomreport.exec(thread: tmsethread): integer;

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
 
 procedure dofinish;
 var
  int1: integer;
 begin
  fakevisible(self,false);
  for int1:= 0 to high(freppages) do begin
   freppages[int1].endrender;
  end;
  if fprinter <> nil then begin
   fprinter.endprint;
//   fprinter.ppmm:= fpmmbefore;
  end;
  fcanvas.ppmm:= fppmmbefore;
 end;

var               
 int1: integer;
 bo1: boolean;

begin
 result:= 0;
 fakevisible(self,true);
 for int1:= 0 to high(freppages) do begin
  freppages[int1].beginrender;
 end;
 try
  if canevent(tmethod(fonbeforerender)) then begin
   application.lock;
   try
    fonbeforerender(self);
   finally
    application.unlock;
   end;
  end;
 except
  dofinish;
  raise;
 end;
 try
  for int1:= 0 to high(freppages) do begin
   freppages[int1].render(fcanvas);
   if fthread.terminated then begin
    break;
   end;
  end;
 finally
  try
   if canevent(tmethod(fonafterrender)) then begin
    application.lock;
    try
     fonafterrender(self);
    finally
     application.unlock;
    end;
   end;
  finally
   dofinish;
  end;
 end;
end;

function tcustomreport.internalrender(const acanvas: tcanvas;
               const aprinter: tprinter; const acommand: string;
               const astream: ttextstream): boolean;
begin
 result:= true;
 fprinter:= aprinter;
 fcanvas:= acanvas;
 fpagenum:= 0;
 fppmmbefore:= acanvas.ppmm;
 acanvas.ppmm:= fppmm;
 if aprinter <> nil then begin
//  aprinter.ppmm:= fppmm;
  if astream <> nil then begin
   aprinter.beginprint(astream);
  end
  else begin
   aprinter.beginprint(acommand);
  end;
 end;
 freeandnil(fthread);
 fthread:= tmsethread.create({$ifdef FPC}@{$endif}exec);
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
 if root = self then begin
  for int1 := 0 to componentcount - 1 do begin
   comp1 := components[int1];
   if not comp1.hasparent then begin
    proc(comp1);
   end;
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

function tcustomreport.getcanceled: boolean;
begin
 result:= (fthread <> nil) and fthread.terminated;
end;

procedure tcustomreport.setcanceled(const avalue: boolean);
begin
 if avalue and (fthread <> nil) then begin
  fthread.terminate;
 end;
end;

function tcustomreport.getrunning: boolean;
begin
 result:= (fthread <> nil) and fthread.running;
end;

procedure tcustomreport.waitfor;
var
 int1: integer;
begin
 if running then begin
  int1:= application.unlockall;
  fthread.waitfor;
  application.relockall(int1);
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
