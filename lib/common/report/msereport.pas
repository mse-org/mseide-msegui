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
 msedrawtext,msestrings,mserichstring,msedb,db,msethread,mseobjectpicker,
 msepointer,mseevent;

const
 defaultrepppmm = 3;
 defaultreppagewidth = 190;
 defaultreppageheight = 270;
 defaultrepfontheight = 14;
 defaultrepfontname = 'stf_report';
 tabpickthreshold = 3;
 endrendertag = 49125363;
 
 defaultreptabtextflags = [tf_ycentered];
 defaultbandanchors = [an_top];
 defaultbandoptionswidget = defaultoptionswidget + [ow_fontlineheight];
 
 defaultrepvaluedisptextflags = [tf_ycentered];
 defaultrepvaluedispoptionsscale = 
               [osc_expandx,osc_shrinkx,osc_expandy,osc_shrinky];
 defaultrepfontcolor = cl_black;
  
type
 linevisiblety = (lv_firstofpage,lv_normal,lv_lastofpage,lv_firstrecord,lv_lastrecord);
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
 defaulttablinevisible = [lv_firstofpage,lv_normal,lv_lastofpage,
                          lv_firstrecord,lv_lastrecord];
 defaulttablineinfo: tablineinfoty = (widthmm: defaulttablinewidth; 
         color: defaulttablinecolor; colorgap: defaulttablinecolorgap;
         capstyle: defaulttablinecapstyle;
         dashes: defaulttablinedashes; dist: defaulttablinedist;
         visible: defaulttablinevisible);
type
 tcustombandarea = class;
 tcustomrecordband = class;
 tcustomreportpage = class;
 rendereventty = procedure(const sender: tobject;
                               const acanvas: tcanvas) of object;
 beforerenderrecordeventty = procedure(const sender: tcustomrecordband;
                                          var empty: boolean) of object;
 synceventty = procedure() of object;
 
 treptabfont = class(tparentfont)
  protected
   class function getinstancepo(owner: tobject): pfont; override;
   procedure setname(const avalue: string); override;
  public
   constructor create; override;
  published
   property color default defaultrepfontcolor;
 end;

 trepwidgetfont = class(twidgetfont)
  protected
   procedure setname(const avalue: string); override;
  public
   constructor create; override;
  published
   property color default defaultrepfontcolor;
 end;
 
 trepfont = class(tfont)
  protected
   procedure setname(const avalue: string); override;
  public
   constructor create; override;
  published
   property color default defaultrepfontcolor;
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
   procedure setlivert_color(const avalue: colorty);
   procedure setlivert_colorgap(const avalue: colorty);
   procedure setlivert_capstyle(const avalue: capstylety);
   procedure setlivert_dashes(const avalue: string);
   procedure setlivert_dist(const avalue: integer);
   procedure setlivert_visible(const avalue: linevisiblesty);

   procedure setlibottom_widthmm(const avalue: real);
   procedure setlibottom_color(const avalue: colorty);
   procedure setlibottom_colorgap(const avalue: colorty);
   procedure setlibottom_capstyle(const avalue: capstylety);
   procedure setlibottom_dashes(const avalue: string);
   procedure setlibottom_dist(const avalue: integer);
   procedure setlibottom_visible(const avalue: linevisiblesty);
   procedure recchanged;

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
   property distleft; //mm
   property distright; //mm
 end; 
                 
 treptabulators = class(tcustomtabulators)
  private
   finfo: drawtextinfoty;
   fband: tcustomrecordband;
   fminsize: sizety;
   fsizevalid: boolean;
   flineinfos: tablineinfoarty;
   flileft: tablineinfoty;
   fliright: tablineinfoty;
   fdistright: real;
   fdistleft: real;

   flinksource: tcustomrecordband;
   procedure setlitop_widthmm(const avalue: real);
   procedure setlitop_color(const avalue: colorty);
   procedure setlitop_colorgap(const avalue: colorty);
   procedure setlitop_capstyle(const avalue: capstylety);
   procedure setlitop_dashes(const avalue: string);
   procedure setlitop_dist(const avalue: integer);
   procedure setlitop_visible(const avalue: linevisiblesty);

   procedure setlileft_widthmm(const avalue: real);
   procedure setlileft_color(const avalue: colorty);
   procedure setlileft_colorgap(const avalue: colorty);
   procedure setlileft_capstyle(const avalue: capstylety);
   procedure setlileft_dashes(const avalue: string);
   procedure setlileft_dist(const avalue: integer);
   procedure setlileft_visible(const avalue: linevisiblesty);

   procedure setlivert_widthmm(const avalue: real);
   procedure setlivert_color(const avalue: colorty);
   procedure setlivert_colorgap(const avalue: colorty);
   procedure setlivert_capstyle(const avalue: capstylety);
   procedure setlivert_dashes(const avalue: string);
   procedure setlivert_dist(const avalue: integer);
   procedure setlivert_visible(const avalue: linevisiblesty);

   procedure setliright_widthmm(const avalue: real);
   procedure setliright_color(const avalue: colorty);
   procedure setliright_colorgap(const avalue: colorty);
   procedure setliright_capstyle(const avalue: capstylety);
   procedure setliright_dashes(const avalue: string);
   procedure setliright_dist(const avalue: integer);
   procedure setliright_visible(const avalue: linevisiblesty);

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
   procedure setdistleft(const avalue: real);
   procedure setdistright(const avalue: real);
   procedure setlinksource(const avalue: tcustomrecordband);
  protected
   class function getitemclass: tabulatoritemclassty; override;
   procedure paint(const acanvas: tcanvas; const adest: rectty);
   procedure checksize;
   procedure recchanged;
   procedure sourcechanged;
   procedure dochange(const aindex: integer); override;
   procedure setcount1(acount: integer; doinit: boolean); override;
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

   property lileft_widthmm: real read flileft.widthmm write
                 setlileft_widthmm;
   property lileft_color: colorty read flileft.color write
                 setlileft_color default defaulttablinecolor;
   property lileft_colorgap: colorty read flileft.colorgap write
                 setlileft_colorgap default defaulttablinecolorgap;
   property lileft_capstyle: capstylety read flileft.capstyle write
                 setlileft_capstyle default defaulttablinecapstyle;
   property lileft_dashes: string read flileft.dashes write
                 setlileft_dashes;
   property lileft_dist: integer read flileft.dist write
                 setlileft_dist default defaulttablinedist;
   property lileft_visible: linevisiblesty read flileft.visible write
                 setlileft_visible default defaulttablinevisible;

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
                 
   property liright_widthmm: real read fliright.widthmm write
                 setliright_widthmm;
   property liright_color: colorty read fliright.color write
                 setliright_color default defaulttablinecolor;
   property liright_colorgap: colorty read fliright.colorgap write
                 setliright_colorgap default defaulttablinecolorgap;
   property liright_capstyle: capstylety read fliright.capstyle write
                 setliright_capstyle default defaulttablinecapstyle;
   property liright_dashes: string read fliright.dashes write
                 setliright_dashes;
   property liright_dist: integer read fliright.dist write
                 setliright_dist default defaulttablinedist;
   property liright_visible: linevisiblesty read fliright.visible write
                 setliright_visible default defaulttablinevisible;

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
   property distleft: real read fdistleft write setdistleft; //mm
   property distright: real read fdistright write setdistright; //mm
   property linksource: tcustomrecordband read flinksource write setlinksource;
   property defaultdist;
 end;
  
 recordbandstatety = (rbs_rendering,rbs_showed,rbs_pageshowed,rbs_finish,
                      rbs_notfirstrecord,rbs_lastrecord);
 recordbandstatesty = set of recordbandstatety; 
 
 ibandparent = interface(inullinterface)
                        ['{B02EE732-4686-4E0C-8C18-419D7D020386}']
  function beginband(const acanvas: tcanvas;
                              const sender: tcustomrecordband): boolean;
                   //true if area full
  procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
  function isfirstband: boolean;
  function islastband(const addheight: integer = 0): boolean;
  function isfirstrecord: boolean;
  function islastrecord: boolean;
  procedure updatevisible;
  function getwidget: twidget;
  function remainingheight: integer;
  function pagepagenum: integer; //null based
  function reppagenum: integer; //null based
  function getlastpagepagecount: integer;
  function getlastreppagecount: integer;
  function pageprintstarttime: tdatetime;
  function repprintstarttime: tdatetime;
  function getreppage: tcustomreportpage;
 end;

 trecordbanddatalink = class(tmsedatalink)
 end;

 bandoptionty = (bo_once,bo_evenpage,bo_oddpage, 
                          //page nums are null based
                 bo_visigroupfirst,bo_visigrouplast,
                         //show only first/last record of group
                 bo_showfirstpage,bo_hidefirstpage,
                 bo_shownormalpage,bo_hidenormalpage,
                 bo_showevenpage,bo_hideevenpage,
                 bo_showoddpage,bo_hideoddpage,
                 bo_showfirstofpage,bo_hidefirstofpage,
                 bo_shownormalofpage,bo_hidenormalofpage,
                 bo_showlastofpage,bo_hidelastofpage,
                 bo_showfirstrecord,bo_hidefirstrecord,
                 bo_shownormalrecord,bo_hidenormalrecord,
                 bo_showlastrecord,bo_hidelastrecord,
                 bo_localvalue 
                  //used in treppagenumdisp to number of the current page
                  //and in trepprinttimedisp to show now
                 );
 bandoptionsty = set of bandoptionty;

const 
 visibilitymask = [bo_showfirstpage,bo_hidefirstpage,
                   bo_shownormalpage,bo_hidenormalpage,
                   bo_showevenpage,bo_hideevenpage,
                   bo_showoddpage,bo_hideoddpage,
                   bo_showfirstofpage,bo_hidefirstofpage,
                   bo_shownormalofpage,bo_hidenormalofpage,
                   bo_showlastofpage,bo_hidelastofpage,
                   bo_showfirstrecord,bo_hidefirstrecord,
                   bo_shownormalrecord,bo_hidenormalrecord,
                   bo_showlastrecord,bo_hidelastrecord
                   ];

type                     
 tcustomrecordband = class(tcustomscalingwidget,idbeditinfo,ireccontrol,iobjectpicker)
  private
   fparentintf: ibandparent;
   fonbeforerender: beforerenderrecordeventty;
   fonpaint: painteventty;
   fonafterpaint: painteventty;
   fstate: recordbandstatesty;
   ftabs: treptabulators;
   fupdating: integer;
   fdatalink: trecordbanddatalink;
   fvisidatalink: tfielddatalink;
   fvisigrouplink: tfielddatalink;
   foptions: bandoptionsty;
   fgroupnum: integer;
   fnextgroupnum: integer;
   frecnobefore: integer;
   fobjectpicker: tobjectpicker;
   procedure settabs(const avalue: treptabulators);
   procedure setoptions(const avalue: bandoptionsty);
   function getvisidatasource: tdatasource;
   procedure setvisidatasource(const avalue: tdatasource);
   function getvisidatafield: string;
   procedure setvisidatafield(const avalue: string);
   function getdatasource: tdatasource; overload;
   procedure setdatasource(const avalue: tdatasource); virtual;
   function getvisigroupfield: string;
   procedure setvisigroupfield(const avalue: string);
              //idbeditinfo
   function getdatasource(const aindex: integer): tdatasource; overload;
   procedure getfieldtypes(out apropertynames: stringarty;
                           out afieldtypes: fieldtypesarty);
              //ireccontrol
   procedure recchanged;
  protected
   procedure setfont(const avalue: trepwidgetfont);
   function getfont: trepwidgetfont;
   function getfontclass: widgetfontclassty; override;
   
   procedure minclientsizechanged;
   procedure objectevent(const sender: tobject;
                          const event: objecteventty); override;
   procedure fontchanged; override;
   procedure inheritedpaint(const acanvas: tcanvas);
   procedure paint(const canvas: tcanvas); override;
   procedure parentchanged; override; //update fparentintf
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
   procedure dobeforenextrecord; virtual;
   procedure dosyncnextrecord; virtual;
   
   procedure nextrecord(const setflag: boolean = true);
   function rendering: boolean;
   function bandheight: integer;
   procedure dobeforerender(var empty: boolean); virtual;
   procedure synctofontheight; override;
   function isfirstrecord: boolean;
   function islastrecord: boolean;
   function bandisvisible(const checklast: boolean): boolean;
   function getvisibility: boolean;
   procedure updatevisibility; virtual;
   function lastbandheight: integer; virtual;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure loaded; override;
      //iobjectpicker
   function getcursorshape(const apos: pointty; const ashiftstate: shiftstatesty; 
                                     var ashape: cursorshapety): boolean;
    //true if found
   procedure getpickobjects(const arect: rectty;  const ashiftstate: shiftstatesty;
                                     var aobjects: integerarty);
   procedure beginpickmove(const aobjects: integerarty);
   procedure endpickmove(const apos,aoffset: pointty; const aobjects: integerarty);
   procedure paintxorpic(const acanvas: tcanvas; const apos,aoffset: pointty;
                 const aobjects: integerarty);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure beginupdate;
   procedure endupdate;
   function remainingbands: integer;
   function reppage: tcustomreportpage;
   procedure finish;
   
   property tabs: treptabulators read ftabs write settabs;
   property font: trepwidgetfont read getfont write setfont stored isfontstored;
   property datasource: tdatasource read getdatasource write setdatasource;
   property visidatasource: tdatasource read getvisidatasource 
                          write setvisidatasource;
   property visidatafield: string read getvisidatafield write setvisidatafield;
               //controls visibility not null -> visible
   property visigroupfield: string read getvisigroupfield write setvisigroupfield;
   property options: bandoptionsty read foptions write setoptions default [];
   property onbeforerender: beforerenderrecordeventty read fonbeforerender
                               write fonbeforerender;
   property onpaint: painteventty read fonpaint write fonpaint;
   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;
  published
   property anchors default defaultbandanchors;
 end;

 trecordband = class(tcustomrecordband)
  published
   property font;
   property tabs;
   property datasource;
   property options;
   property optionsscale;
   property visidatasource;
   property visidatafield;
   property visigroupfield;
   property onfontheightdelta;
   property onchildscaled;

   property onbeforerender;
   property onpaint;
   property onafterpaint;
  end;

 tcustomrepvaluedisp = class(tcustomrecordband)
  private
   ftextflags: textflagsty;
   fformat: msestring;
   procedure setformat(const avalue: msestring);
  protected
   function calcminscrollsize: sizety; override;
   procedure dopaint(const acanvas: tcanvas); override;
   function getdisptext: msestring; virtual;
  public
   constructor create(aowner: tcomponent); override;
   property textflags: textflagsty read ftextflags write ftextflags default 
               defaultrepvaluedisptextflags;
   property format: msestring read fformat write setformat;
   property optionsscale default defaultrepvaluedispoptionsscale;
  published
   property anchors default [an_left,an_top];
 end;
 
 trepvaluedisp = class(tcustomrepvaluedisp)
  published
   property font;
//   property tabs;
//   property datasource;
   property options;
   property optionsscale;
   property onfontheightdelta;
   property onchildscaled;

   property onbeforerender;
   property onpaint;
   property onafterpaint;
 end;
 
 treppagenumdisp = class(trepvaluedisp)
  private
   foffset: integer;
   procedure setoffset(const avalue: integer);
  protected
   function getdisptext: msestring; override;
   procedure initpage; override;
   procedure parentchanged; override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property offset: integer read foffset write setoffset default 1;
   property format;   //'1' returns lastpagecount
 end;

 trepprintdatedisp = class(trepvaluedisp)
  protected
   function getdisptext: msestring; override;
  published
   property format;
 end;
  
 recordbandarty = array of tcustomrecordband;
 
 tcustombandgroup = class(tcustomrecordband,ibandparent)
  private
   fbands: recordbandarty;
   procedure setdatasource(const avalue: tdatasource); override;
           //ibandparent;
   function beginband(const acanvas: tcanvas;
                              const sender: tcustomrecordband): boolean;
                   //true if area full
   procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
   function isfirstband: boolean;
   function islastband(const addheight: integer = 0): boolean;
   procedure updatevisible;
   function getwidget: twidget;
   function remainingheight: integer;
   function pagepagenum: integer; //null based
   function reppagenum: integer; //null based
   function getlastpagepagecount: integer;
   function getlastreppagecount: integer;
   function pageprintstarttime: tdatetime;
   function repprintstarttime: tdatetime;
   function getreppage: tcustomreportpage;
   procedure dobeforenextrecord; override;
   procedure dosyncnextrecord; override;
  protected
   procedure setparentwidget(const avalue: twidget); override;   
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure dobeforerender(var empty: boolean); override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure updatevisibility; override;
   function getminbandsize: sizety; override;
   procedure init; override;
   procedure beginrender; override;
   procedure endrender; override;
   function lastbandheight: integer; override;
  public
   property font: trepwidgetfont read getfont write setfont stored isfontstored;
 end;

 tbandgroup = class(tcustombandgroup)
  published
   property font;
//   property tabs;
   property datasource;
   property options;
   property optionsscale;
   property visidatasource;
   property visidatafield;

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
   
 bandareaeventty = procedure(const sender: tcustombandarea) of object;
 bandareapainteventty = procedure(const sender: tcustombandarea;
                              const acanvas: tcanvas) of object;
                              
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
   fonbeforerender: bandareaeventty;
   fonpaint: bandareapainteventty;
   fonafterpaint: bandareapainteventty;
   fonfirstarea: bandareaeventty;
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
   procedure dofirstarea; virtual;
   procedure dobeforerender; virtual;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doafterpaint1(const acanvas: tcanvas); virtual;
   procedure init; virtual;
   procedure initareapage;
   procedure initpage;
   procedure dobeforenextrecord;
   procedure dosyncnextrecord;
   function checkareafull(ay: integer): boolean;
           //ibandparent
   function beginband(const acanvas: tcanvas;
                               const sender: tcustomrecordband): boolean;
                    //true if area full
   procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
   procedure updatevisible;
   function getlastpagepagecount: integer;
   function getlastreppagecount: integer;
   procedure setfont(const avalue: trepwidgetfont);
   function getfont: trepwidgetfont;
   function getfontclass: widgetfontclassty; override;
  public
   function isfirstband: boolean;
   function islastband(const addheight: integer = 0): boolean;
   function isfirstrecord: boolean;
   function islastrecord: boolean;
   function remainingheight: integer;
   function pagepagenum: integer; //null based
   function reppagenum: integer; //null based
   function pageprintstarttime: tdatetime;
   function repprintstarttime: tdatetime;
   function getreppage: tcustomreportpage;

   property acty: integer read getacty;
   property areafull: boolean read getareafull write setareafull;
   
   property font: trepwidgetfont read getfont write setfont stored isfontstored;
   property onfirstarea: bandareaeventty read fonfirstarea write fonfirstarea;
   property onbeforerender: bandareaeventty read fonbeforerender
                               write fonbeforerender;
   property onpaint: bandareapainteventty read fonpaint write fonpaint;
   property onafterpaint: bandareapainteventty read fonafterpaint write fonafterpaint;
 end; 
 
 tbandarea = class(tcustombandarea)
  published
   property font;
   property onfirstarea;
   property onbeforerender;
   property onpaint;
   property onafterpaint;
 end;

 reportpagestatety = (rpps_inited,rpps_rendering,rpps_backgroundrendered,
                      rpps_showed,rpps_finish,rpps_notfirstrecord,rpps_lastrecord);
 reportpagestatesty = set of reportpagestatety;
 
 bandareaarty = array of tcustombandarea;
 
 tcustomreport = class;
   
 treportpagedatalink = class(tmsedatalink)
 end;

 reportpageoptionty = (rpo_once,rpo_firsteven,rpo_firstodd);
 reportpageoptionsty = set of reportpageoptionty;

 reportpageeventty = procedure(const sender: tcustomreportpage) of object;
 reportpagepainteventty = procedure(const sender: tcustomreportpage;
                              const acanvas: tcanvas) of object;
 reppageorientationty = (rpo_default,rpo_portrait,rpo_landscape);
 
 tcustomreportpage = class(twidget,ibandparent)
  private
   fbands: recordbandarty;
   fareas: bandareaarty;
   fstate: reportpagestatesty;
   fonbeforerender: reportpageeventty;
   fonpaint: reportpagepainteventty;
   fonafterpaint: reportpagepainteventty;
   fpagewidth: real;
   fpageheight: real;
   fppmm: real;
   fvisiblepage: boolean;
   fpagenum: integer;
   fonfirstpage: reportpageeventty;
   fonafterlastpage: reportpageeventty;
   fnextpage: tcustomreportpage;
   fnextpageifempty: tcustomreportpage;
   fsaveindex: integer;
   fdatalink: treportpagedatalink;
   foptions: reportpageoptionsty;
   fprintstarttime: tdatetime;
   freccontrols: pointerarty;
   frecnobefore: integer;
   fprintorientation: reppageorientationty;
   flastpagecount: integer;
   procedure setpagewidth(const avalue: real);
   procedure setpageheight(const avalue: real);
   procedure updatepagesize;
   procedure setppmm(const avalue: real);
   procedure setnextpage(const avalue: tcustomreportpage);
   procedure setnextpageifempty(const avalue: tcustomreportpage);
   function getdatasource: tdatasource;
   procedure setdatasource(const avalue: tdatasource);
   procedure setoptions(const avalue: reportpageoptionsty);
  protected
   freport: tcustomreport;
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure setparentwidget(const avalue: twidget); override;   
   procedure insertwidget(const awidget: twidget; const apos: pointty); override;
   procedure sizechanged; override;

   procedure setfont(const avalue: trepwidgetfont);
   function getfont: trepwidgetfont;
   function getfontclass: widgetfontclassty; override;

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
   procedure dobeforenextrecord;
   procedure dosyncnextrecord;
   property ppmm: real read fppmm write setppmm; //pixel per mm
   
   function render(const acanvas: tcanvas): boolean;
          //true if empty

              //ibandparent
   function beginband(const acanvas: tcanvas;
                               const sender: tcustomrecordband): boolean;
   procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
   function isfirstband: boolean;
   function islastband(const addheight: integer = 0): boolean;
   procedure updatevisible;
   function remainingheight: integer;
   function pagepagenum: integer; //null based
   function reppagenum: integer; //null based
   function pageprintstarttime: tdatetime;
   function repprintstarttime: tdatetime;
   function getreppage: tcustomreportpage;
   function getlastpagepagecount: integer;
   function getlastreppagecount: integer;
  
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   function isfirstrecord: boolean;
   function islastrecord: boolean;
   procedure recordchanged;   
   property report: tcustomreport read freport;
   property pagenum: integer read fpagenum write fpagenum; 
                 //null-based, local to this page
   property lastpagecount: integer read getlastpagepagecount write flastpagecount;
                 //local to this page
   property printstarttime: tdatetime read fprintstarttime write fprintstarttime;
   property visiblepage: boolean read fvisiblepage write fvisiblepage default true;
   procedure activatepage;
   procedure finish;

   
   property pagewidth: real read fpagewidth write setpagewidth;
   property pageheight: real read fpageheight write setpageheight;
   property font: trepwidgetfont read getfont write setfont stored isfontstored;
   property nextpage: tcustomreportpage read fnextpage write setnextpage;
   property nextpageifempty: tcustomreportpage read fnextpageifempty write 
                          setnextpageifempty;
   property datasource: tdatasource read getdatasource write setdatasource;
   property options: reportpageoptionsty read foptions write setoptions
                                                 default [];
   property printorientation: reppageorientationty read fprintorientation 
                write fprintorientation default rpo_default;   
                      //default --> printer.canvas value
   
   property onfirstpage: reportpageeventty read fonfirstpage
                               write fonfirstpage;
   property onbeforerender: reportpageeventty read fonbeforerender
                               write fonbeforerender;
   property onpaint: reportpagepainteventty read fonpaint write fonpaint;
   property onafterpaint: reportpagepainteventty read fonafterpaint 
                        write fonafterpaint;
   property onafterlastpage: reportpageeventty read fonafterlastpage
                               write fonafterlastpage;
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
   property nextpage;
   property nextpageifempty;
   property visiblepage;
   property datasource;
   property options;
   property printorientation;
 
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
 
 repstatety = (rs_activepageset,rs_finish,rs_running,rs_endpass);
 repstatesty = set of repstatety;

 reporteventty = procedure(const sender: tcustomreport) of object;

 reportoptionty = (reo_autorelease,reo_prepass);
 reportoptionsty = set of reportoptionty;
 
 tcustomreport = class(twidget)
  private
   fppmm: real;
   fonbeforerender: notifyeventty;
   fonafterrender: notifyeventty;
   fprinter: tprinter;
   fstream: ttextstream;
   fstreamset: boolean;
   fcommand: string;
   fcanvas: tcanvas;
   fpagenum: integer;
   fthread: tmsethread;
   fppmmbefore: real;
   fstate: repstatesty;
   factivepage: integer;
   fprintstarttime: tdatetime;
   fonprogress: notifyeventty;
   fonrenderfinish: reporteventty;
   fnilstream: boolean;
   foptions: reportoptionsty;
   flastpagecount: integer;
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
   procedure setactivepage(const avalue: integer);
  protected
   frepdesigninfo: repdesigninfoty;
   freppages: reportpagearty;
   fdefaultprintorientation: pageorientationty;
   procedure insertwidget(const awidget: twidget; const apos: pointty); override;
   procedure internalrender(const acanvas: tcanvas; const aprinter: tprinter;
                  const acommand: string; const astream: ttextstream;
                  const anilstream: boolean; const onafterrender: reporteventty);
   procedure unregisterchildwidget(const child: twidget); override;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
//   procedure internalcreatefont; override;
   procedure defineproperties(filer: tfiler); override;
   procedure nextpage(const acanvas: tcanvas);
   procedure doprogress;
   procedure doasyncevent(var atag: integer); override;
   procedure notification(acomponent: tcomponent; 
                                        operation: toperation); override;
   procedure setfont(const avalue: trepfont);
   function getfont: trepfont;
   function getfontclass: widgetfontclassty; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure render(const acanvas: tcanvas;
                        const onafterrender: reporteventty = nil); overload;
   procedure render(const aprinter: tprinter; const command: string = '';
                        const onafterrender: reporteventty = nil); overload;
   procedure render(const aprinter: tprinter; const astream: ttextstream;
                        const onafterrender: reporteventty = nil); overload;
   procedure waitfor;         //returns before calling of onafterrender
   function prepass: boolean; //true if in prepass render state
   
   property ppmm: real read fppmm write setppmm; //pixel per mm
   function reppagecount: integer;
   property reppages[index: integer]: tcustomreportpage read getreppages 
                                                write setreppages; default;
   property pagenum: integer read fpagenum {write fpagenum}; 
                            //null-based
   property lastpagecount: integer read flastpagecount write flastpagecount;
   property activepage: integer read factivepage write setactivepage;
   procedure finish;
   property printstarttime: tdatetime read fprintstarttime write fprintstarttime;
   property nilstream: boolean read fnilstream;
                           //true if reder called with nil stream

   property font: trepfont read getfont write setfont;
   property color default cl_transparent;
   property grid_show: boolean read frepdesigninfo.showgrid write setgrid_show default true;
   property grid_snap: boolean read frepdesigninfo.snaptogrid write setgrid_snap default true;
   property grid_size: real read frepdesigninfo.gridsize write setgrid_size;   
   property canceled: boolean read getcanceled write setcanceled;
   property running: boolean read getrunning;
   property options: reportoptionsty read foptions write foptions;

   property onbeforerender: notifyeventty read fonbeforerender
                               write fonbeforerender;
   property onafterrender: notifyeventty read fonafterrender
                               write fonafterrender;
        //executed in main thread context
   property onprogress: notifyeventty read fonprogress write fonprogress;
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
   property options;
   property onbeforerender;
   property onafterrender;
   property onprogress;
 end;

 reportclassty = class of treport;
  
function createreport(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
procedure initreportcomponent(const amodule: tcomponent; 
                                         const acomponent: tcomponent);
function getreportscale(const amodule: tcomponent): real;

implementation
uses
 msedatalist,sysutils,msestreaming,msebits,msereal,mseformatstr;
type
 tcustomframe1 = class(tcustomframe);
 twidget1 = class(twidget);
 tmsecomponent1 = class(tmsecomponent);

function checkdashes(const avalue: string): string;
var
 int1: integer;
begin
 result:= avalue;
 for int1:= 1 to length(avalue) do begin
  if avalue[int1] = #0 then begin
   setlength(result,int1-1);     //remove nulls
   break;
  end;
 end;
end;

procedure renderingerror;
begin
 raise exception.create('Operation not possible while rendering');
end;
{
function checkisfirstrecord(const adatalink: tmsedatalink;
           out avalue: boolean): boolean; //true if adatalink active
begin
 result:= adatalink.active;
 if result then begin
  avalue:= adatalink.dataset.recno = 1;
 end
 else begin
  avalue:= false;
 end;
end;

function checkislastrecord(const adatalink: tmsedatalink;
           out avalue: boolean): boolean; //true if adatalink active
begin
 result:= adatalink.active;
 if result then begin
  avalue:= adatalink.dataset.recno = adatalink.dataset.recordcount;
 end
 else begin
  avalue:= false;
 end;
end;
}
function checkislastrecord(const adatalink: tmsedatalink; 
                               const syncproc: synceventty): boolean;
begin                     
 with adatalink do begin          //todo: optimize   
  if active then begin
   if not dataset.eof then begin
    dataset.next;
    if assigned(syncproc) then begin
     syncproc;
    end;
    result:= dataset.eof;
    dataset.prior;
    if result and not dataset.bof then begin
     dataset.next;
    end;
   end
   else begin
    result:= true;
   end;
  end
  else begin
   result:= false;
  end;
 end;
end;

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

constructor treptabfont.create;
begin
 inherited;
 finfo.color:= defaultrepfontcolor;
 finfo.name:= defaultrepfontname;
end;

procedure treptabfont.setname(const avalue: string);
begin
 if avalue = '' then begin
  inherited setname(defaultrepfontname);
 end
 else begin
  inherited;
 end;
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
   self.fdatalink.datasource:= datasource;
   self.fdistleft:= distleft;
   self.fdistright:= distright;
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
  change(-1);
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
 flineinfos[tlk_top].dashes:= checkdashes(avalue);
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

procedure treptabulatoritem.setlivert_color(const avalue: colorty);
begin
 flineinfos[tlk_vert].color:= avalue;
 changed;
end;

procedure treptabulatoritem.setlivert_colorgap(const avalue: colorty);
begin
 flineinfos[tlk_vert].colorgap:= avalue;
 changed;
end;

procedure treptabulatoritem.setlivert_capstyle(const avalue: capstylety);
begin
 flineinfos[tlk_vert].capstyle:= avalue;
 changed;
end;

procedure treptabulatoritem.setlivert_dashes(const avalue: string);
begin
 flineinfos[tlk_vert].dashes:= checkdashes(avalue);
 changed;
end;

procedure treptabulatoritem.setlivert_dist(const avalue: integer);
begin
 flineinfos[tlk_vert].dist:= avalue;
 changed;
end;

procedure treptabulatoritem.setlivert_visible(const avalue: linevisiblesty);
begin
 flineinfos[tlk_vert].visible:= avalue;
 changed;
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
 flineinfos[tlk_bottom].dashes:= checkdashes(avalue);
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

procedure treptabulatoritem.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

{ treptabulators }

constructor treptabulators.create(const aowner: tcustomrecordband);
var
 kind1: tablinekindty;
begin
 fband:= aowner;
 flileft:= defaulttablineinfo;
 fliright:= defaulttablineinfo;
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
     result:= linepos + treptabulatoritem(fitems[index]).xlineoffset;
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
         startx:=linepos + xlineoffset;
         endx:= nextx;
        end;
        else begin
         if aindex > 0 then begin
          with ftabs[aindex-1] do begin
           startx:= linepos + treptabulatoritem(fitems[index]).xlineoffset;
          end;
         end
         else begin
          startx:= 0;
         end;
         if kind = tak_centered then begin
          endx:= nextx;
         end
         else begin
          endx:= linepos + xlineoffset;
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
    visiblemask:= [lv_firstofpage,lv_normal,lv_lastofpage,lv_firstrecord,lv_lastrecord];
   end
   else begin
    visiblemask:= [lv_normal];    
    with fparentintf do begin
     if isfirstband then begin
      include(visiblemask,lv_firstofpage);
      exclude(visiblemask,lv_normal);
     end;
     if islastband then begin
      include(visiblemask,lv_lastofpage);
      exclude(visiblemask,lv_normal);
     end;
     if isfirstrecord then begin
      include(visiblemask,lv_firstrecord);
      exclude(visiblemask,lv_normal);
     end;
     if islastrecord then begin
      include(visiblemask,lv_lastrecord);
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
      dest:= adest;
      if width <= 0 then begin
       case kind of
        tak_left: begin
         dest.cx:= adest.cx - textpos + width;
        end;
        else begin
         dest.cx:= adest.cx + width;
        end;
       end;
      end
      else begin
       dest.cx:= width;
      end;
     end;
     textrect(acanvas,finfo);
//     dest.cx:= res.cx;
     case tabkind of
      tak_left: begin
       dest.x:= adest.x + textpos;
      end;
      tak_right: begin
       dest.cx:= res.cx;
       dest.x:= adest.x + textpos - res.cx;
      end;
      tak_centered: begin
       dest.cx:= res.cx;
       dest.x:= adest.x + textpos - res.cx div 2;
      end;
      else begin //tak_decimal
       dest.cx:= res.cx;
       int2:= findlastchar(text.text,msechar(decimalseparator));
       if int2 > 0 then begin
        rstr1:= richcopy(text,int2,bigint);
        int3:= textrect(acanvas,rstr1,[],finfo.font).cx;
       end
       else begin
        int3:= 0;
       end;
       dest.x:= adest.x + textpos - res.cx + int3; 
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
           int2:= linepos - dist
          end
          else begin
           int2:= linepos + dist;
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
  with flileft do begin
   if widthmm > 0 then begin
    if visible * visiblemask <> [] then begin
     checkinit(flileft);
     acanvas.drawline(makepoint(-dist,
            fband.clientheight+flineinfos[tlk_bottom].dist),
                          makepoint(-dist,-flineinfos[tlk_top].dist),color);
    end;
   end;
  end;
  with fliright do begin
   if widthmm > 0 then begin
    if visible * visiblemask <> [] then begin
     checkinit(fliright);
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
     acanvas.drawline(makepoint(-flileft.dist,-dist),
                                makepoint(bandcx+fliright.dist,-dist),color);
    end;
   end;
  end;
  with flineinfos[tlk_bottom] do begin
   if widthmm > 0 then begin
    if visible * visiblemask <> [] then begin
     checkinit(flineinfos[tlk_bottom]);
     int2:= fband.clientheight+dist;
     acanvas.drawline(makepoint(-flileft.dist,int2),
                               makepoint(bandcx+fliright.dist,int2),color);
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
  flineinfos[tlk_top].dashes:= checkdashes(avalue);
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

procedure treptabulators.setlileft_widthmm(const avalue: real);
begin
 if avalue <> flileft.widthmm then begin
  flileft.widthmm:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlileft_color(const avalue: colorty);
begin
 if avalue <> flileft.color then begin
  flileft.color:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlileft_colorgap(const avalue: colorty);
begin
 if avalue <> flileft.colorgap then begin
  flileft.colorgap:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlileft_capstyle(const avalue: capstylety);
begin
 if avalue <> flileft.capstyle then begin
  flileft.capstyle:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlileft_dashes(const avalue: string);
begin
 if avalue <> flileft.dashes then begin
  flileft.dashes:= checkdashes(avalue);
  fband.invalidate;
 end;
end;

procedure treptabulators.setlileft_dist(const avalue: integer);
begin
 if avalue <> flileft.dist then begin
  flileft.dist:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlileft_visible(const avalue: linevisiblesty);
begin
 if avalue <> flileft.visible then begin
  flileft.visible:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setlivert_widthmm(const avalue: real);
var
 int1: integer;
begin
 if (avalue <> flineinfos[tlk_vert].widthmm) then begin
  flineinfos[tlk_vert].widthmm:= avalue;
  if not (csloading in fband.componentstate) then begin
   for int1:= 0 to high(fitems) do begin
    treptabulatoritem(fitems[int1]).livert_widthmm:= avalue;
   end;
  end;
 end;
end;

procedure treptabulators.setlivert_color(const avalue: colorty);
var
 int1: integer;
begin
 if (avalue <> flineinfos[tlk_vert].color) then begin
  flineinfos[tlk_vert].color:= avalue;
  if not (csloading in fband.componentstate) then begin
   for int1:= 0 to high(fitems) do begin
    treptabulatoritem(fitems[int1]).livert_color:= avalue;
   end;
  end;
 end;
end;

procedure treptabulators.setlivert_colorgap(const avalue: colorty);
var
 int1: integer;
begin
 if (avalue <> flineinfos[tlk_vert].colorgap) then begin
  flineinfos[tlk_vert].colorgap:= avalue;
  if not (csloading in fband.componentstate) then begin
   for int1:= 0 to high(fitems) do begin
    treptabulatoritem(fitems[int1]).livert_colorgap:= avalue;
   end;
  end;
 end;
end;

procedure treptabulators.setlivert_capstyle(const avalue: capstylety);
var
 int1: integer;
begin
 if (avalue <> flineinfos[tlk_vert].capstyle) then begin
  flineinfos[tlk_vert].capstyle:= avalue;
  if not (csloading in fband.componentstate) then begin
   for int1:= 0 to high(fitems) do begin
    treptabulatoritem(fitems[int1]).livert_capstyle:= avalue;
   end;
  end;
 end;
end;

procedure treptabulators.setlivert_dashes(const avalue: string);
var
 int1: integer;
begin
 if (avalue <> flineinfos[tlk_vert].dashes) then begin
  flineinfos[tlk_vert].dashes:= checkdashes(avalue);
  if not (csloading in fband.componentstate) then begin
   for int1:= 0 to high(fitems) do begin
    treptabulatoritem(fitems[int1]).livert_dashes:= checkdashes(avalue);
   end;
  end;
 end;
end;

procedure treptabulators.setlivert_dist(const avalue: integer);
var
 int1: integer;
begin
 if (avalue <> flineinfos[tlk_vert].dist) then begin
  flineinfos[tlk_vert].dist:= avalue;
  if not (csloading in fband.componentstate) then begin
   for int1:= 0 to high(fitems) do begin
    treptabulatoritem(fitems[int1]).livert_dist:= avalue;
   end;
  end;
 end;
end;

procedure treptabulators.setlivert_visible(const avalue: linevisiblesty);
var
 int1: integer;
begin
 if (avalue <> flineinfos[tlk_vert].visible) and 
              not (csloading in fband.componentstate) then begin
  flineinfos[tlk_vert].visible:= avalue;
  for int1:= 0 to high(fitems) do begin
   treptabulatoritem(fitems[int1]).livert_visible:= avalue;
  end;
 end;
end;

procedure treptabulators.setliright_widthmm(const avalue: real);
begin
 if avalue <> fliright.widthmm then begin
  fliright.widthmm:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setliright_color(const avalue: colorty);
begin
 if avalue <> fliright.color then begin
  fliright.color:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setliright_colorgap(const avalue: colorty);
begin
 if avalue <> fliright.colorgap then begin
  fliright.colorgap:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setliright_capstyle(const avalue: capstylety);
begin
 if avalue <> fliright.capstyle then begin
  fliright.capstyle:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setliright_dashes(const avalue: string);
begin
 if avalue <> fliright.dashes then begin
  fliright.dashes:= checkdashes(avalue);
  fband.invalidate;
 end;
end;

procedure treptabulators.setliright_dist(const avalue: integer);
begin
 if avalue <> fliright.dist then begin
  fliright.dist:= avalue;
  fband.invalidate;
 end;
end;

procedure treptabulators.setliright_visible(const avalue: linevisiblesty);
begin
 if avalue <> fliright.visible then begin
  fliright.visible:= avalue;
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
  flineinfos[tlk_bottom].dashes:= checkdashes(avalue);
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

procedure treptabulators.setdistleft(const avalue: real);
var
 int1: integer;
begin
 if avalue <> fdistleft then begin
  fdistleft:= avalue;
  {
  if isemptyreal(fdistleft) then begin
   fdistleft:= 0;
  end;
  }
  for int1:= 0 to high(fitems) do begin
   treptabulatoritem(fitems[int1]).distleft:= fdistleft;
  end;
 end;
end;

procedure treptabulators.setdistright(const avalue: real);
var
 int1: integer;
begin
 if avalue <> fdistright then begin
  fdistright:= avalue;
  {
  if isemptyreal(fdistright) then begin
   fdistright:= 0;
  end;
  }
  for int1:= 0 to high(fitems) do begin
   treptabulatoritem(fitems[int1]).distright:= fdistright;
  end;
 end;
end;

procedure treptabulators.recchanged;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  treptabulatoritem(fitems[int1]).recchanged;
 end;
end;

procedure treptabulators.setlinksource(const avalue: tcustomrecordband);
var
 band1: tcustomrecordband;
begin
 if avalue <> flinksource then begin
  band1:= avalue;
  while band1 <> nil do begin
   if band1 = fband then begin
    raise exception.create('Recursive linksource.');
   end;
   band1:= band1.ftabs.flinksource;
  end;
  fband.setlinkedvar(avalue,flinksource);
  sourcechanged;
 end;
end;

procedure treptabulators.sourcechanged;
var
 int1: integer;
begin
 if (flinksource <> nil) and 
                   not (csloading in flinksource.componentstate) then begin
  beginupdate;
  try
   count:= flinksource.ftabs.count;
   for int1:= 0 to high(fitems) do begin
    with treptabulatoritem(fitems[int1]) do begin
     pos:= treptabulatoritem(flinksource.ftabs.fitems[int1]).pos;
    end;
   end;
  finally
   endupdate;
  end;
 end;
end;

procedure treptabulators.dochange(const aindex: integer);
begin
 inherited;
 fband.sendchangeevent(oe_designchanged); 
end;

procedure treptabulators.setcount1(acount: integer; doinit: boolean);
const
 step = 10;
var
 countbefore: integer;
 int1,int2: integer;
begin
 with fband do begin
  if (componentstate * [csdesigning,csloading] = [csdesigning]) and
              (acount > count) then begin
   countbefore:= count;
   checkuptodate;
   if countbefore > 0 then begin
    int2:= self.pos[countbefore-1] + step;
   end
   else begin
    int2:= 0;
   end;
   inherited;
   for int1:= countbefore to count - 1 do begin
    items[int1].pos:= int2 / ppmm;    
    inc(int2,step); //offset
   end;
  end
  else begin
   inherited;
  end;
 end;
end;

{ tcustomrecordband }

constructor tcustomrecordband.create(aowner: tcomponent);
begin
 ftabs:= treptabulators.create(self);
 fdatalink:= trecordbanddatalink.create;
 fvisidatalink:= tfielddatalink.create;
 fvisigrouplink:= tfielddatalink.create;
 inherited;
 fanchors:= defaultbandanchors;
 foptionswidget:= defaultbandoptionswidget;
end;

destructor tcustomrecordband.destroy;
begin
 fobjectpicker.free;
 ftabs.free;
 fdatalink.free;
 fvisidatalink.free;
 fvisigrouplink.free;
 inherited;
end;

procedure tcustomrecordband.loaded;
begin
 inherited;
 if csdesigning in componentstate then begin
  fobjectpicker:= tobjectpicker.create(iobjectpicker(self));
 end;
end;

procedure tcustomrecordband.parentchanged;
var
 widget1: twidget;
begin
 if fparentwidget <> nil then begin
  widget1:= fparentwidget;
  while (widget1 <> nil) and 
    not widget1.getcorbainterface(typeinfo(ibandparent),fparentintf) do begin
   widget1:= widget1.parentwidget;
  end; 
 end
 else begin
  fparentintf:= nil;
 end;
 inherited;
end;

procedure tcustomrecordband.dobeforerender(var empty: boolean);
begin
 if fdatalink.active then begin
  empty:= (rbs_finish in fstate) or fdatalink.dataset.eof;
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
 empty:= empty or (rbs_finish in fstate);
 dobeforerender(empty);
 fparentintf.updatevisible;
 if not empty then begin
  if visible then begin
   if fparentintf.beginband(acanvas,self) then begin
    exit;
   end;
   try
    inherited paint(acanvas);
   finally
    fparentintf.endband(acanvas,self);
   end;
  end;
  nextrecord;
 end;
end;

procedure tcustomrecordband.init;
begin
 exclude(fstate,rbs_finish);
 if fvisigrouplink.fieldactive then begin
  fgroupnum:= fvisigrouplink.asinteger;
  fnextgroupnum:= fgroupnum;
//  fgroupnum:= fvisigrouplink.aslargeint;
 end;
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
 if fdatalink.active then begin
  frecnobefore:= fdatalink.dataset.recno;
  fdatalink.dataset.disablecontrols;
  fdatalink.dataset.first;
  if checkislastrecord(fdatalink,@dosyncnextrecord) then begin
   include(fstate,rbs_lastrecord);
  end;
 end; 
end;

procedure tcustomrecordband.endrender;
begin
 exclude(fstate,rbs_rendering);
 exclude(widgetstate1,ws1_noclipchildren);
 if fdatalink.active then begin
  try
   fdatalink.dataset.recno:= frecnobefore;
  except
  end;
  fdatalink.dataset.enablecontrols;
 end; 
end;

procedure tcustomrecordband.settabs(const avalue: treptabulators);
begin
 ftabs.assign(avalue);
end;

procedure tcustomrecordband.dobeforenextrecord;
begin
 if fvisigrouplink.fieldactive then begin
  fgroupnum:= fvisigrouplink.field.asinteger;
 end;
end;

procedure tcustomrecordband.dosyncnextrecord;
begin
 if fvisigrouplink.fieldactive then begin
  fnextgroupnum:= fvisigrouplink.field.asinteger;
 end;
end;

procedure tcustomrecordband.nextrecord(const setflag: boolean = true);
begin
 if setflag then begin
  include(fstate,rbs_notfirstrecord);
  dobeforenextrecord;
 end;
 if fdatalink.active then begin
  application.lock;
  try
   fdatalink.dataset.next;
  finally
   application.unlock;
  end;
 end;
 if setflag then begin
  if checkislastrecord(fdatalink,@dosyncnextrecord) then begin
   include(fstate,rbs_lastrecord);
  end; 
  fparentintf.getreppage.recordchanged;
 end;
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
 end;
 if csdesigning in componentstate then begin
  ar2:= ftabs.tabs;
  setlength(ar1,length(ar2));
  int2:= innerclientwidgetpos.x;
  for int1:= 0 to high(ar1) do begin
   with ar1[int1] do begin
    a.x:= ar2[int1].linepos+int2;
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

procedure tcustomrecordband.setoptions(const avalue: bandoptionsty);
const
 firstmask: bandoptionsty = [bo_showfirstpage,bo_hidefirstpage];
 normalmask: bandoptionsty = [bo_shownormalpage,bo_hidenormalpage];
 evenmask: bandoptionsty = [bo_showevenpage,bo_hideevenpage];
 oddmask: bandoptionsty = [bo_showoddpage,bo_hideoddpage];
 firstofpagemask: bandoptionsty = [bo_showfirstofpage,bo_hidefirstofpage];
 normalofpagemask: bandoptionsty = [bo_shownormalofpage,bo_hidenormalofpage];
 lastofpagemask: bandoptionsty = [bo_showlastofpage,bo_hidelastofpage];
 firstrecmask: bandoptionsty = [bo_showfirstrecord,bo_hidefirstrecord];
 normalrecmask: bandoptionsty = [bo_shownormalrecord,bo_hidenormalrecord];
 lastrecmask: bandoptionsty = [bo_showlastrecord,bo_hidelastrecord];
var
 vis1: bandoptionsty;
begin
 vis1:= bandoptionsty(setsinglebit(longword(avalue),longword(foptions),
                                 longword(firstmask)));
 vis1:= bandoptionsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(normalmask)));
 vis1:= bandoptionsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(evenmask)));
 vis1:= bandoptionsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(oddmask)));
 vis1:= bandoptionsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(firstofpagemask)));
 vis1:= bandoptionsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(normalofpagemask)));
 vis1:= bandoptionsty(setsinglebit(longword(vis1),
                                 longword(foptions),longword(lastofpagemask)));
 vis1:= bandoptionsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(firstrecmask)));
 vis1:= bandoptionsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(normalrecmask)));
 foptions:= bandoptionsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(lastrecmask)));
end;

procedure tcustomrecordband.synctofontheight;
begin
 syncsinglelinefontheight(true);
end;

function tcustomrecordband.isfirstrecord: boolean;
begin
 if fdatalink.active then begin
  result:= not (rbs_notfirstrecord in fstate);
 end
 else begin
  if fparentintf <> nil then begin
   result:= fparentintf.isfirstrecord;
  end
  else begin
   result:= false;
  end;
 end;
end;

function tcustomrecordband.islastrecord: boolean;
begin
 if fdatalink.active then begin
  result:= rbs_lastrecord in fstate;
 end
 else begin
  if fparentintf <> nil then begin
   result:= fparentintf.islastrecord;
  end
  else begin
   result:= false;
  end;
 end;
end;

function tcustomrecordband.bandisvisible(const checklast: boolean): boolean;
var
 firstofpage,lastofpage,showed,hidden: boolean;
 firstrecord,lastrecord: boolean;
 even1,first1,bo1: boolean;
label
 endlab;
begin
 result:= visible;
 if fvisidatalink.fieldactive then begin
 {
  if fvisidatalink.datasource = fdatalink.datasource then begin
   bo1:= false;
   while not fdatalink.dataset.eof and fvisidatalink.field.isnull do begin
    nextrecord(false);
    bo1:= true;
   end;
   if bo1 then begin
    if checkislastrecord(fdatalink,@dosyncnextrecord) then begin
     include(fstate,rbs_lastrecord);
    end; 
   end;
  end;
  }
  if fvisidatalink.field.isnull then begin
   result:= false;
   goto endlab;
  end
  else begin
   result:= true;
  end;
 end;
 firstrecord:= isfirstrecord;
 lastrecord:= islastrecord;
 if fvisigrouplink.fieldactive then begin
 {
  if fvisigrouplink.datasource = fdatalink.datasource then begin
   bo1:= false;
   while not fdatalink.dataset.eof and 
                (fvisidatalink.field.asinteger = fgroupnum) do begin
    bo1:= true;
    nextrecord(false);
   end;
   if bo1 then begin
    if checkislastrecord(fdatalink,@dosyncnextrecord) then begin
     include(fstate,rbs_lastrecord);
    end; 
   end;
  end;
  }
  if (bo_visigroupfirst in foptions) and (firstrecord or 
                  (fvisigrouplink.field.asinteger <> fgroupnum)) or
         (bo_visigrouplast in foptions) and (lastrecord or 
                  (fvisigrouplink.field.asinteger <> fnextgroupnum)) then begin
   result:= true;
  end
  else begin
   result:= false;
   goto endlab;
  end;
 end;
 if foptions * visibilitymask <> [] then begin
  if fparentintf <> nil then begin
   first1:= fparentintf.pagepagenum = 0;
   if first1 and (bo_hidefirstpage in foptions) then begin
    result:= false;
    goto endlab;
   end;
   if first1 and (bo_showfirstpage in foptions) then begin
    result:= true;
    goto endlab;
   end;
   if not first1 and (bo_hidenormalpage in foptions) then begin
    result:= false;
    goto endlab;
   end;
   if not first1 and (bo_shownormalpage in foptions) then begin
    result:= true;
    goto endlab;
   end;

   even1:= not odd(fparentintf.reppagenum);
   if even1 and (bo_hideevenpage in foptions) then begin
    result:= false;
    goto endlab;
   end;
   if not even1 and (bo_hideoddpage in foptions) then begin
    result:= false;
    goto endlab;
   end;
   bo1:= even1 and (bo_showevenpage in foptions);
   bo1:= bo1 or not even1 and (bo_showoddpage in foptions);

   firstofpage:= fparentintf.isfirstband;
   lastofpage:= checklast and fparentintf.islastband;
   if firstofpage then begin
    if bo_showfirstofpage in foptions then begin
     result:= true;
     goto endlab;
    end
    else begin
     if bo_hidefirstofpage in foptions then begin
      result:= false;
     end;
    end;
   end;
   if lastofpage then begin
    if bo_showlastofpage in foptions then begin
     result:= true;
     goto endlab;
    end
    else begin
     if bo_hidelastofpage in foptions then begin
      result:= false;
      bo1:= false;
     end;
    end;
   end;
   if not firstofpage and not lastofpage then begin
    if bo_shownormalofpage in foptions then begin
     result:= true;
     goto endlab;
    end
    else begin
     if bo_hidenormalofpage in foptions then begin
      result:= false;
      bo1:= false;
     end;
    end;
   end;
   if firstrecord then begin
    if bo_showfirstrecord in foptions then begin
     result:= true;
     goto endlab;
    end
    else begin
     if bo_hidefirstrecord in foptions then begin
      result:= false;
      bo1:= false;
     end;
    end;
   end;
   if lastrecord then begin
    if bo_showlastrecord in foptions then begin
     result:= true;
     goto endlab;
    end
    else begin
     if bo_hidelastrecord in foptions then begin
      result:= false;
      bo1:= false;
     end;
    end;
   end;
   if not firstrecord and not lastrecord then begin
    if bo_shownormalrecord in foptions then begin
     result:= true;
     goto endlab;
    end
    else begin
     if bo_hidenormalrecord in foptions then begin
      result:= false;
      bo1:= false;
     end;
    end;
   end;
   if bo1 then begin
    result:= true;
   end;
  end;
 end;
endlab:
end;

function tcustomrecordband.getvisibility: boolean;
begin
 result:= bandisvisible(true);
end;

procedure tcustomrecordband.updatevisibility;
begin
 visible:= getvisibility;
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

function tcustomrecordband.reppage: tcustomreportpage;
begin
 if fparentintf <> nil then  begin
  result:= fparentintf.getreppage;
 end
 else begin
  result:= nil;
 end;
end;

procedure tcustomrecordband.finish;
begin
 include(fstate,rbs_finish);
end;

function tcustomrecordband.getvisidatasource: tdatasource;
begin
 result:= fvisidatalink.datasource;
end;

procedure tcustomrecordband.setvisidatasource(const avalue: tdatasource);
begin
 fvisidatalink.datasource:= avalue;
 fvisigrouplink.datasource:= avalue;
end;

function tcustomrecordband.getvisidatafield: string;
begin
 result:= fvisidatalink.fieldname;
end;

procedure tcustomrecordband.setvisidatafield(const avalue: string);
begin
 fvisidatalink.fieldname:= avalue;
end;

function tcustomrecordband.getdatasource(const aindex: integer): tdatasource;
begin
 result:= fvisidatalink.datasource;
end;

procedure tcustomrecordband.getfieldtypes(out apropertynames: stringarty;
               out afieldtypes: fieldtypesarty);
begin
 setlength(apropertynames,2);
 apropertynames[0]:= 'visidatafield';
 apropertynames[1]:= 'visigroupfield';
 setlength(afieldtypes,2);
 afieldtypes[0]:= [];
 afieldtypes[1]:= [ftinteger,ftlargeint,ftsmallint,
                     ftword,ftboolean];
end;

function tcustomrecordband.getvisigroupfield: string;
begin
 result:= fvisigrouplink.fieldname;
end;

procedure tcustomrecordband.setvisigroupfield(const avalue: string);
begin
 fvisigrouplink.fieldname:= avalue;
end;

procedure tcustomrecordband.recchanged;
begin
 fdatalink.recordchanged(nil);
 ftabs.recchanged;
end;

function tcustomrecordband.getcursorshape(const apos: pointty;
               const ashiftstate: shiftstatesty;
               var ashape: cursorshapety): boolean;
var
 ar1: integerarty;
begin
 getpickobjects(makerect(apos,nullsize),ashiftstate,ar1);
 result:= ar1 <> nil;
 if result then begin
  ashape:= cr_sizehor;
 end;
end;

procedure tcustomrecordband.getpickobjects(const arect: rectty;
               const ashiftstate: shiftstatesty; var aobjects: integerarty);
var
 int1,int2: integer;
begin
 for int1:= 0 to ftabs.count - 1 do begin
  int2:= abs(arect.x - ftabs.linepos[int1]);
  if int2 < tabpickthreshold then begin
   setlength(aobjects,1);
   aobjects[0]:= int1;
   break;
  end;
 end;
end;

procedure tcustomrecordband.beginpickmove(const aobjects: integerarty);
begin
end;

procedure tcustomrecordband.endpickmove(const apos: pointty;
               const aoffset: pointty; const aobjects: integerarty);
begin
 ftabs.linepos[aobjects[0]]:= ftabs.linepos[aobjects[0]] + aoffset.x;
 designchanged;
end;

procedure tcustomrecordband.paintxorpic(const acanvas: tcanvas;
               const apos: pointty; const aoffset: pointty;
               const aobjects: integerarty);
begin
 acanvas.fillxorrect(makerect(aoffset.x+ftabs.linepos[aobjects[0]],0,
                               1,clientheight));
end;

procedure tcustomrecordband.clientmouseevent(var info: mouseeventinfoty);
begin
 if fobjectpicker <> nil then begin
  fobjectpicker.mouseevent(info);
 end;
 inherited;
end;

procedure tcustomrecordband.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event = oe_designchanged) and (sender = ftabs.flinksource) then begin
  ftabs.sourcechanged;
  designchanged;
 end;
end;

procedure tcustomrecordband.setfont(const avalue: trepwidgetfont);
begin
 inherited setfont(avalue);
end;

function tcustomrecordband.getfont: trepwidgetfont;
begin
 result:= trepwidgetfont(inherited getfont);
end;

function tcustomrecordband.getfontclass: widgetfontclassty;
begin
 result:= trepwidgetfont;
end;

{ tcustombandgroup }

procedure tcustombandgroup.registerchildwidget(const child: twidget);
begin
 if child is tcustomrecordband then begin
  inherited;
  additem(pointerarty(fbands),child);
  with tcustomrecordband(child) do begin
   fparentintf:= ibandparent(self);
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
 tcustomrecordband(child).fparentintf:= nil;
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
    nextrecord;
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
      ftabs[int2].datasource:= avalue;
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
    if bandisvisible(false) and not (bo_hidelastofpage in options) or 
           (bo_showlastofpage in options) then begin
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
var
 int1: integer;
begin
 sortwidgetsyorder(widgetarty(fbands));
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].init;
 end;
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

function tcustombandgroup.beginband(const acanvas: tcanvas;
               const sender: tcustomrecordband): boolean;
begin
 result:= fparentintf.beginband(acanvas,sender);
end;

procedure tcustombandgroup.endband(const acanvas: tcanvas;
               const sender: tcustomrecordband);
begin
 fparentintf.endband(acanvas,sender);
end;

function tcustombandgroup.isfirstband: boolean;
begin
 result:= fparentintf.isfirstband;
end;

function tcustombandgroup.islastband(const addheight: integer = 0): boolean;
begin
 result:= fparentintf.islastband;
end;

procedure tcustombandgroup.updatevisible;
begin
 fparentintf.updatevisible;
end;

function tcustombandgroup.getwidget: twidget;
begin
 result:= fparentintf.getwidget;
end;

function tcustombandgroup.remainingheight: integer;
begin
 result:= fparentintf.remainingheight;
end;

function tcustombandgroup.pagepagenum: integer;
begin
 result:= fparentintf.pagepagenum;
end;

function tcustombandgroup.reppagenum: integer;
begin
 result:= fparentintf.reppagenum;
end;

function tcustombandgroup.getlastpagepagecount: integer;
begin
 result:= fparentintf.getlastpagepagecount;
end;

function tcustombandgroup.getlastreppagecount: integer;
begin
 result:= fparentintf.getlastreppagecount;
end;

function tcustombandgroup.pageprintstarttime: tdatetime;
begin
 result:= fparentintf.pageprintstarttime;
end;

function tcustombandgroup.repprintstarttime: tdatetime;
begin
 result:= fparentintf.repprintstarttime;
end;

function tcustombandgroup.getreppage: tcustomreportpage;
begin
 result:= fparentintf.getreppage;
end;

procedure tcustombandgroup.dobeforenextrecord;
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].dobeforenextrecord;
 end;
end;

procedure tcustombandgroup.dosyncnextrecord;
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].dosyncnextrecord;
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
  dofirstarea;
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
      bo2:= odd(fparentintf.reppagenum);
      bo2:= bo2 and (bo_oddpage in foptions) or 
            not bo2 and (bo_evenpage in foptions);
      bo1:= ((rbs_showed in fstate) or not(bo_once in foptions)) and
            ((rbs_pageshowed in fstate) or not bo2);   //empty    
      render(acanvas,bo1);
      bo1:= bo1 or bo2{(bv_everypage in fvisibility)};
      fstate:= fstate + [rbs_showed,rbs_pageshowed];
     end;
//     result:= bo1;
     result:= result and bo1;
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

procedure tcustombandarea.dofirstarea;
begin
 if canevent(tmethod(fonfirstarea)) then begin
  application.lock;
  try
   fonfirstarea(self);
  finally
   application.unlock;
  end;
 end;
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
 result:= (factiveband <= high(fbands)) and 
                    not (rbs_pageshowed in fbands[factiveband].fstate);
// result:= not (bas_notfirstband in fstate);
end;

function tcustombandarea.islastband(const addheight: integer = 0): boolean;
var
 int1: integer;
begin
 result:= fstate * [bas_lastband{,bas_lastchecking}] <> [];
 if not result and (factiveband <= high(fbands)) then begin
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

function tcustombandarea.pagepagenum: integer;
begin
 result:= freportpage.pagenum;
end;

function tcustombandarea.reppagenum: integer;
begin
 result:= freportpage.freport.pagenum;
end;

function tcustombandarea.pageprintstarttime: tdatetime;
begin
 result:= freportpage.fprintstarttime;
end;

function tcustombandarea.getlastpagepagecount: integer;
begin
 result:= freportpage.flastpagecount;
end;

function tcustombandarea.getlastreppagecount: integer;
begin
 result:= freportpage.freport.flastpagecount;
end;

function tcustombandarea.repprintstarttime: tdatetime;
begin
 result:= freportpage.freport.fprintstarttime;
end;

function tcustombandarea.getreppage: tcustomreportpage;
begin
 result:= freportpage;
end;

function tcustombandarea.isfirstrecord: boolean;
begin
 result:= freportpage.isfirstrecord;
end;

function tcustombandarea.islastrecord: boolean;
begin
 result:= freportpage.islastrecord;
end;

procedure tcustombandarea.dobeforenextrecord;
var
 int1: integer;
begin
 for int1:= 0 to high(fbands) do begin
  fbands[int1].dobeforenextrecord;
 end;
end;

procedure tcustombandarea.dosyncnextrecord;
var
 int1: integer;
begin
 for int1:= 0 to high(fbands) do begin
  fbands[int1].dosyncnextrecord;
 end;
end;

procedure tcustombandarea.setfont(const avalue: trepwidgetfont);
begin
 inherited setfont(avalue);
end;

function tcustombandarea.getfont: trepwidgetfont;
begin
 result:= trepwidgetfont(inherited getfont);
end;

function tcustombandarea.getfontclass: widgetfontclassty;
begin
 result:= trepwidgetfont;
end;

{ tcustomreportpage }

constructor tcustomreportpage.create(aowner: tcomponent);
begin
 fprintstarttime:= now;
 fvisiblepage:= true;
 fdatalink:= treportpagedatalink.create;
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

destructor tcustomreportpage.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tcustomreportpage.registerchildwidget(const child: twidget);
begin
 inherited;
 if child is tcustombandarea then begin
  additem(pointerarty(fareas),child);
 end
 else begin
  if child is tcustomrecordband then begin
   additem(pointerarty(fbands),child);
  end;
 end;
end;

procedure tcustomreportpage.unregisterchildwidget(const child: twidget);
begin
 removeitem(pointerarty(fareas),child);
 removeitem(pointerarty(fbands),child);
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
 exclude(fstate,rpps_showed);
 for int1:= 0 to high(fareas) do begin
  fareas[int1].init;
 end;
end;

procedure tcustomreportpage.dosyncnextrecord;
var
 int1: integer;
begin
 for int1:= 0 to high(fareas) do begin
  fareas[int1].dosyncnextrecord;
 end;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].dosyncnextrecord;
 end;
end;

procedure tcustomreportpage.dobeforenextrecord;
var
 int1: integer;
begin
 for int1:= 0 to high(fareas) do begin
  fareas[int1].dobeforenextrecord;
 end;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].dobeforenextrecord;
 end;
end;

function tcustomreportpage.render(const acanvas: tcanvas): boolean;
var
 int1: integer;
 bo1,bo2,bo3: boolean;
begin
 if not (rpps_inited in fstate) then begin
  init;
 end;
 fprintstarttime:= now;
 bo1:= odd(reppagenum);
 if bo1 and (rpo_firsteven in foptions) or not bo1 and 
                         (rpo_firstodd in foptions) then begin
  freport.nextpage(acanvas);  
  inc(freport.fpagenum);
 end;
 fpagenum:= 0;
 exclude(fstate,rpps_finish);
 recordchanged;
 dofirstpage;
 result:= true;
 repeat
  if rpps_finish in fstate then begin
   break;
  end;
  exclude(fstate,rpps_backgroundrendered);
  acanvas.reset;
  acanvas.intersectcliprect(makerect(nullpoint,fwidgetrect.size));
  updatevisible;
  dobeforerender;
  updatevisible;
  bo1:= true;
  for int1:= 0 to high(fareas) do begin
   bo1:= fareas[int1].render(acanvas) and bo1;
  end;
  sortwidgetsyorder(widgetarty(fbands));
  for int1:= 0 to high(fbands) do begin
   fbands[int1].initpage;
  end;
  bo2:= odd(reppagenum);
  bo3:= not ((rpo_once in foptions) and not (rpps_showed in fstate) or 
         (fdatalink.active and not fdatalink.dataset.eof));
  for int1:= 0 to high(fbands) do begin
   with fbands[int1] do begin
    bo2:= bo3 and (bo1 or (bo2 and (bo_oddpage in foptions) or 
               not bo2 and (bo_evenpage in foptions)) or
                 ((rbs_showed in fstate) and (bo_once in foptions)));
               //empty    
    fbands[int1].render(acanvas,bo2);
    bo1:= bo1 and bo2;
   end;
  end;
  if not (rpps_backgroundrendered in fstate) and 
    (not bo3 or (rpo_once in foptions) and not (rpps_showed in fstate)) then begin
   renderbackground(acanvas);  
  end;
              
  if rpps_backgroundrendered in fstate then begin
   doafterpaint1(acanvas);
   if fdatalink.active then begin
    bo1:= false;
    application.lock;
    try
     dobeforenextrecord;
     fdatalink.dataset.next;
     if checkislastrecord(fdatalink,@dosyncnextrecord) then begin
      include(fstate,rpps_lastrecord);
     end; 
    finally
     application.unlock;
    end;
    recordchanged;
   end;
   inc(fpagenum);
   inc(freport.fpagenum);
   include(fstate,rpps_showed);
  end;
  freport.doprogress;
  result:= result and bo1;
 until bo1 or (fnextpage <> nil);
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
var
 orient1: pageorientationty;
begin
 if freport.fpagenum <> 0 then begin
  freport.nextpage(acanvas);
 end;
 if acanvas is tprintercanvas then begin
  if fprintorientation = rpo_default then begin
   orient1:= freport.fdefaultprintorientation;
  end
  else begin
   orient1:= pageorientationty(pred(fprintorientation));
  end;
  tprintercanvas(acanvas).printorientation:= orient1;
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
 procedure addreccontrols(const awidget: twidget);
 var
  int1: integer;
  po1: pointer;
 begin
  for int1:= 0 to awidget.widgetcount -1 do begin
   addreccontrols(awidget.widgets[int1]);
   if awidget.widgets[int1].getcorbainterface(typeinfo(ireccontrol),po1) then begin
    additem(freccontrols,po1);
   end;
  end;
 end;
var
 int1: integer;
begin
 freccontrols:= nil;
 addreccontrols(self);
 fstate:= [rpps_rendering];
 include(fwidgetstate1,ws1_noclipchildren);
 with fdatalink do begin
  if active then begin
   frecnobefore:= dataset.recno;
   dataset.disablecontrols;
   dataset.first;
   if checkislastrecord(fdatalink,@dosyncnextrecord) then begin
    include(fstate,rpps_lastrecord);
   end;
  end;
 end;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].beginrender;
 end;
 for int1:= 0 to high(fareas) do begin
  fareas[int1].beginrender;
 end;
end;

procedure tcustomreportpage.endrender;
var
 int1: integer;
begin
 flastpagecount:= fpagenum;
 freccontrols:= nil;
 exclude(fstate,rpps_rendering);
 exclude(fwidgetstate1,ws1_noclipchildren);
 if fdatalink.active then begin
  try
   fdatalink.dataset.recno:= frecnobefore;
  except
  end;
  fdatalink.dataset.enablecontrols;
 end; 
 for int1:= 0 to high(fbands) do begin
  fbands[int1].endrender;
 end;
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

procedure tcustomreportpage.setnextpage(const avalue: tcustomreportpage);
begin
 setlinkedvar(avalue,fnextpage);
end;

procedure tcustomreportpage.setnextpageifempty(const avalue: tcustomreportpage);
begin
 setlinkedvar(avalue,fnextpageifempty);
end;

function tcustomreportpage.beginband(const acanvas: tcanvas;
               const sender: tcustomrecordband): boolean;
begin
 fsaveindex:= acanvas.save;
 if not (rpps_backgroundrendered in fstate) then begin
  renderbackground(acanvas);
 end;
 acanvas.origin:= sender.pos;
 result:= false;
end;

procedure tcustomreportpage.endband(const acanvas: tcanvas;
               const sender: tcustomrecordband);
begin
 acanvas.restore(fsaveindex);
end;

function tcustomreportpage.isfirstband: boolean;
begin
 result:= false;
end;

function tcustomreportpage.islastband(const addheight: integer = 0): boolean;
begin
 result:= false;
end;

procedure tcustomreportpage.updatevisible;
var
 int1: integer;
begin
 for int1:= 0 to high(fbands) do begin
  fbands[int1].updatevisibility;
 end;
 for int1:= 0 to high(fareas) do begin
  fareas[int1].updatevisible;
 end;
end;

function tcustomreportpage.remainingheight: integer;
begin
 result:= 0;
end;

function tcustomreportpage.pagepagenum: integer;
begin
 result:= fpagenum;
end;

function tcustomreportpage.reppagenum: integer;
begin
 result:= freport.fpagenum;
end;

function tcustomreportpage.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

function tcustomreportpage.pageprintstarttime: tdatetime;
begin
 result:= fprintstarttime;
end;

function tcustomreportpage.repprintstarttime: tdatetime;
begin
 result:= freport.fprintstarttime;
end;

procedure tcustomreportpage.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tcustomreportpage.activatepage;
begin
 freport.activepage:= finditem(pointerarty(freport.freppages),self);
end;

procedure tcustomreportpage.finish;
begin
 include(fstate,rpps_finish);
end;

procedure tcustomreportpage.setoptions(const avalue: reportpageoptionsty);
const
 mask: reportpageoptionsty = [rpo_firsteven,rpo_firstodd];
begin
 foptions:= reportpageoptionsty(setsinglebit(longword(avalue),
                 longword(foptions),longword(mask)));
end;

function tcustomreportpage.getreppage: tcustomreportpage;
begin
 result:= self;
end;

function tcustomreportpage.isfirstrecord: boolean;
begin
 if fdatalink.active then begin
  result:= not (rpps_notfirstrecord in fstate);
 end
 else begin
  result:= false;
 end;
end;

function tcustomreportpage.islastrecord: boolean;
begin
 if fdatalink.active then begin
  result:= rpps_lastrecord in fstate;
 end
 else begin
  result:= false;
 end;
end;

procedure tcustomreportpage.recordchanged;
var
 int1: integer;
begin
 application.lock;
 try
  for int1:= 0 to high(freccontrols) do begin
   ireccontrol(freccontrols[int1]).recchanged;
  end;
 finally
  application.unlock;
 end;
end;

function tcustomreportpage.getlastpagepagecount: integer;
begin
 result:= flastpagecount;
end;

function tcustomreportpage.getlastreppagecount: integer;
begin
 result:= freport.flastpagecount;
end;

procedure tcustomreportpage.setfont(const avalue: trepwidgetfont);
begin
 inherited setfont(avalue);
end;

function tcustomreportpage.getfont: trepwidgetfont;
begin
 result:= trepwidgetfont(inherited getfont);
end;

function tcustomreportpage.getfontclass: widgetfontclassty;
begin
 result:= trepwidgetfont;
end;

 {tcustomreport}
 
constructor tcustomreport.create(aowner: tcomponent);
begin
 fprintstarttime:= now;
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
 ffont:= twidgetfont(trepfont.create);
 ffont.height:= round(defaultrepfontheight * (fppmm/defaultrepppmm));
 ffont.onchange:= {$ifdef FPC}@{$endif}dofontchanged;
 //createfont;
end;

destructor tcustomreport.destroy;
begin
 if fthread <> nil then begin
  fthread.terminate;
  application.waitforthread(fthread);
 end;
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
  if not (csloading in componentstate) then begin
   postchildscaled;
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

var
 terminated1: boolean; 
 
 procedure dofinish(const islast: boolean);
 var
  int1: integer;
 begin
  fakevisible(self,false);
  flastpagecount:= fpagenum;
  for int1:= 0 to high(freppages) do begin
   freppages[int1].endrender;
  end;
  terminated1:= thread.terminated;
  if islast or (rs_endpass in fstate) or terminated1 then begin
   exclude(fstate,rs_running);
   fstream.free;
   if fprinter <> nil then begin
    fprinter.endprint;
    fprinter.canvas.printorientation:= fdefaultprintorientation;
   end;
   fcanvas.ppmm:= fppmmbefore;
   asyncevent(endrendertag);
  end;
 end;

var               
 int1: integer;
 bo1: boolean;
 page1: tcustomreportpage;
 stream1: ttextstream;
 
begin
 fstate:= [];
 result:= 0; 
 fdefaultprintorientation:= pao_portrait;
 if fprinter <> nil then begin
  fdefaultprintorientation:= fprinter.canvas.printorientation;
 end;
 fppmmbefore:= fcanvas.ppmm;
 fcanvas.ppmm:= fppmm;
 if not (reo_prepass in foptions) then begin
  include(fstate,rs_endpass);
 end;
 repeat
  fpagenum:= 0;
  factivepage:= 0;
  fakevisible(self,true);
  try
   if fprinter <> nil then begin
    if rs_endpass in fstate then begin
     if fstreamset then begin
      stream1:= fstream;
      fstream:= nil;
      fprinter.beginprint(stream1);
     end
     else begin
      fprinter.beginprint(fcommand);
     end;
    end
    else begin
     fprinter.beginprint(nil);
    end;
   end;   
   for int1:= 0 to high(freppages) do begin
    freppages[int1].beginrender;
   end;
   if canevent(tmethod(fonbeforerender)) then begin
    application.lock;
    try
     fonbeforerender(self);
    finally
     application.unlock;
    end;
   end;
  except
   dofinish(true);
   raise;
  end;
  try
   if high(freppages) >= factivepage then begin
    page1:= freppages[factivepage];
    while true do begin
     for int1:= finditem(pointerarty(freppages),page1) to high(freppages) do begin
      if freppages[int1].visiblepage then begin
       page1:= freppages[int1];
       break;
      end;
     end;
     if page1.visiblepage and not fthread.terminated then begin
      exclude(fstate,rs_activepageset);
      factivepage:= finditem(pointerarty(freppages),page1);
      bo1:= page1.render(fcanvas);
      if rs_finish in fstate then begin
       break;
      end;
      if rs_activepageset in fstate then begin
       page1:= freppages[factivepage];
      end
      else begin
       if not bo1 and (page1.nextpage <> nil) then begin
         page1:= page1.nextpage;
       end
       else begin
        if bo1 and (page1.nextpageifempty <> nil) then begin
         page1:= page1.nextpageifempty;
        end
        else begin
         int1:= finditem(pointerarty(freppages),page1);
         if (int1 >= 0) and (int1 < high(freppages)) then begin
          page1:= freppages[int1+1];
         end
         else begin
          page1:= nil;
         end;
        end;
       end;
      end;
      if finditem(pointerarty(freppages),page1) < 0 then begin
       break;
      end;
     end
     else begin
      break;
     end;
    end;
   end;
  except
   dofinish(true);
   raise;
  end;
  dofinish(false);
  if (rs_endpass in fstate) then begin
   break;
  end;
  fstate:= [rs_endpass];
 until terminated1;
end;

procedure tcustomreport.internalrender(const acanvas: tcanvas;
               const aprinter: tprinter; const acommand: string;
               const astream: ttextstream; const anilstream: boolean;
               const onafterrender: reporteventty);
begin
 if running then begin
  raise exception.create('Already rendering.');
 end;
 include(fstate,rs_running);
 fnilstream:= anilstream;
 fonrenderfinish:= onafterrender;
 if assigned(fonrenderfinish) and 
         (tobject(tmethod(fonrenderfinish).data) is tcomponent) then begin
  tcomponent(tmethod(fonrenderfinish).data).freenotification(self);
 end;
 fprintstarttime:= now;
 fprinter:= aprinter;
 fcanvas:= acanvas;
 fstream:= astream;
 fstreamset:= (astream <> nil) or nilstream;
 fcommand:= acommand;
 freeandnil(fthread);
 fthread:= tmsethread.create({$ifdef FPC}@{$endif}exec);
end;

procedure tcustomreport.render(const acanvas: tcanvas;
              const onafterrender: reporteventty = nil);
begin
 internalrender(acanvas,nil,'',nil,false,onafterrender);
end;

procedure tcustomreport.render(const aprinter: tprinter;
               const command: string = '';
              const onafterrender: reporteventty = nil);
begin
 internalrender(aprinter.canvas,aprinter,command,nil,false,onafterrender);
end;

procedure tcustomreport.render(const aprinter: tprinter;
               const astream: ttextstream;
              const onafterrender: reporteventty = nil);
begin
 internalrender(aprinter.canvas,aprinter,'',astream,astream = nil,onafterrender);
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
{
procedure tcustomreport.internalcreatefont;
var
 font1: twidgetfont;
begin
 font1:= trepwidgetfont.create;
 font1.height:= round(defaultrepfontheight * (fppmm/defaultrepppmm));
// font1.name:= defaultrepfontname;
 ffont:= font1;
 inherited;
end;
}
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
 result:= rs_running in fstate;
 {
 result:= (fthread <> nil) and fthread.running;
 }
end;

procedure tcustomreport.waitfor;
var
 int1: integer;
begin
 if running then begin
  int1:= application.unlockall;
  fthread.waitfor;
  application.relockall(int1);
//  exclude(fstate,rs_running);
 end;
end;

procedure tcustomreport.setactivepage(const avalue: integer);
begin
 checkarrayindex(freppages,avalue);
 include(fstate,rs_activepageset);
 factivepage:= avalue;
end;

procedure tcustomreport.finish;
begin
 include(fstate,rs_finish);
end;

procedure tcustomreport.doprogress;
begin
 if canevent(tmethod(fonprogress)) then begin
  application.lock;
  try
   fonprogress(self);
  finally
   application.unlock;
  end;
 end;  
end;

procedure tcustomreport.doasyncevent(var atag: integer);
begin
 inherited;
 if (atag = endrendertag) then begin
  try
   if canevent(tmethod(fonafterrender)) then begin
    fonafterrender(self);
   end;
   if canevent(tmethod(fonrenderfinish)) then begin
    fonrenderfinish(self);
   end;
//   exclude(fstate,rs_running);
  finally
   if reo_autorelease in foptions then begin
    release;
   end;
  end; 
 end;
end;

procedure tcustomreport.notification(acomponent: tcomponent;
               operation: toperation);
begin
 inherited;
 if assigned(fonrenderfinish) and 
           (tmethod(fonrenderfinish).data = pointer(acomponent)) then begin
  fonrenderfinish:= nil;
 end;
end;

procedure tcustomreport.setfont(const avalue: trepfont);
begin
 ffont.assign(avalue);
// inherited setfont(avalue);
end;

function tcustomreport.getfont: trepfont;
begin
// result:= trepwidgetfont(inherited getfont);
 result:= trepfont(ffont);      //has no parent font
end;

function tcustomreport.getfontclass: widgetfontclassty;
begin
 result:= nil; //static font
end;

function tcustomreport.prepass: boolean;
begin
 result:= not (rs_endpass in fstate);
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

{ tcustomrepvaluedisp }

constructor tcustomrepvaluedisp.create(aowner: tcomponent);
begin
 ftextflags:= defaultrepvaluedisptextflags;
 foptionsscale:= defaultrepvaluedispoptionsscale;
 inherited;
 foptionsscale:= defaultrepvaluedispoptionsscale;
 fanchors:= [an_left,an_top];
end;

procedure tcustomrepvaluedisp.dopaint(const acanvas: tcanvas);
begin
 inherited;
 drawtext(acanvas,getdisptext,innerclientrect,ftextflags,font);
end;

function tcustomrepvaluedisp.getdisptext: msestring;
begin
 result:= name;
end;

procedure tcustomrepvaluedisp.setformat(const avalue: msestring);
begin
 if fformat <> avalue then begin
  fformat:= avalue;
  minclientsizechanged;
 end;
// invalidate;
end;

function tcustomrepvaluedisp.calcminscrollsize: sizety;
var
 size1: sizety;
begin
 result:= inherited calcminscrollsize;
 size1:= textrect(getcanvas,getdisptext,ftextflags,font).size;
 if fframe <> nil then begin
  with fframe do begin
   size1.cx:= size1.cx + framei_left + framei_right;
   size1.cy:= size1.cy + framei_top + framei_bottom;
  end;
 end;
 if size1.cx > result.cx then begin
  result.cx:= size1.cx;
 end;
 if size1.cy > result.cy then begin
  result.cy:= size1.cy;
 end;
end;

{ treppagenumdisp }

constructor treppagenumdisp.create(aowner: tcomponent);
begin
 foffset:= 1;
 inherited;
end;

function treppagenumdisp.getdisptext: msestring;
var
 int1,int2: integer;
 mstr1: msestring; 
 squote,dquote: boolean;
begin
 if fparentintf <> nil then  begin
  squote:= false;
  dquote:= false;
  mstr1:= fformat;
  for int1:= 1 to length(fformat) do begin
   case fformat[int1] of
    '''': begin
     if not dquote then begin
      squote:= not squote;
     end;
    end;
    '"': begin
     if not squote then begin
      dquote:= not dquote;
     end;
    end;
    '1': begin
     if not (squote or dquote) then begin

      if bo_localvalue in foptions then begin
       int2:= fparentintf.getlastpagepagecount;
      end
      else begin
       int2:= fparentintf.getlastreppagecount;
      end;
      mstr1:= copy(fformat,1,int1-1) + '"' +inttostr(int2) +'"' +
                              copy(fformat,int1+1,bigint);
     end;
    end;
   end;
  end;
  if bo_localvalue in foptions then begin
   int1:= fparentintf.pagepagenum;
  end
  else begin
   int1:= fparentintf.reppagenum
  end;
  result:= formatfloatmse(int1+foffset,mstr1);
 end
 else begin
  result:= inherited getdisptext;
 end;
end;

procedure treppagenumdisp.setoffset(const avalue: integer);
begin
 if foffset <> avalue then begin
  foffset:= avalue;
  minclientsizechanged;
 end;
end;

procedure treppagenumdisp.initpage;
begin
 inherited;
 minclientsizechanged;
end;

procedure treppagenumdisp.parentchanged;
begin
 inherited;
 minclientsizechanged;
end;

{ trepprintdatedisp }

function trepprintdatedisp.getdisptext: msestring;
var
 ti1: tdatetime;
 str1: string;
begin
 if fparentintf <> nil then begin
  if bo_localvalue in foptions then begin
   ti1:= fparentintf.pageprintstarttime;
  end
  else begin
   ti1:= fparentintf.repprintstarttime;
  end;
  if fformat = '' then begin
   str1:= 'c';
  end
  else begin
   str1:= fformat;
  end;
  result:= formatdatetime(str1,ti1);
 end
 else begin
  result:= inherited getdisptext;
 end;
end;

{ trepwidgetfont }

constructor trepwidgetfont.create;
begin
 inherited;
 finfo.color:= defaultrepfontcolor;
 finfo.name:= defaultrepfontname;
end;

procedure trepwidgetfont.setname(const avalue: string);
begin
 if avalue = '' then begin
  inherited setname(defaultrepfontname);
 end
 else begin
  inherited;
 end;
end;

{ trepfont }

constructor trepfont.create;
begin
 inherited;
 finfo.color:= defaultrepfontcolor;
 finfo.name:= defaultrepfontname;
end;

procedure trepfont.setname(const avalue: string);
begin
 if avalue = '' then begin
  inherited setname(defaultrepfontname);
 end
 else begin
  inherited;
 end;
end;

end.
