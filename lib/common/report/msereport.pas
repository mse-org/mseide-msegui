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
 msepointer,mseevent,msesplitter,msestatfile,mselookupbuffer,mseformatstr,
 msegdiprint;

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
 defaultbandoptionswidget = defaultoptionswidget;
               {(defaultoptionswidget + [ow_fontlineheight]) - 
                                    [ow_fontglyphheight];}
 
 defaultrepvaluedisptextflags = [tf_ycentered];
 defaultrepvaluedispoptionsscale = 
               [osc_expandx,osc_shrinkx,osc_expandy,osc_shrinky];
 defaultrepfontcolor = cl_black;
  
type
 lookupkindty = (lk_text,lk_integer,lk_float,lk_date,lk_time,lk_datetime);
 linevisiblety = (lv_topofpage,lv_nottopofpage,
                  lv_firstofpage,lv_normal,lv_lastofpage,
                  lv_firstofgroup,lv_lastofgroup,
                  lv_firstrecord,lv_lastrecord);
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
 defaulttablinevisible = [lv_topofpage,lv_nottopofpage,
                          lv_firstofpage,lv_normal,lv_lastofpage,
                          lv_firstofgroup,lv_lastofgroup,    
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
 reptabulatoritemoptionty = (rto_sum,rto_shownull,rto_nocurrentvalue,rto_noreset);
 reptabulatoritemoptionsty = set of reptabulatoritemoptionty;

 itemsumty = record
  count: integer;
  resetpending: boolean;
  reset: boolean;
  case tfieldtype of
   ftinteger,ftword,ftsmallint,ftboolean: (integervalue: integer);
   ftlargeint: (largeintvalue: int64);
   ftfloat: (floatvalue: double);
   ftbcd: (bcdvalue: currency);
 end;
  
 treptabulatoritem = class(ttabulatoritem,idbeditinfo)
  private
   fvalue: richstringty;
   ffont: treptabfont;
   ftextflags: textflagsty;
   fdatalink: treptabitemdatalink;
   fongetvalue: getrichstringeventty;
   flineinfos: tablineinfoarty;
   flookupbuffer: tcustomlookupbuffer;
   flookupkeyfieldno: integer;
   flookupvaluefieldno: integer;
   flookupkind: lookupkindty;
   fformat: msestring;
   fcolor: colorty;
   ftag: integer;
   foptions: reptabulatoritemoptionsty;
   fsum: itemsumty;
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
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
   procedure setlookupkeyfieldno(const avalue: integer);
   procedure setlookupvaluefieldno(const avalue: integer);
   procedure setlookupkind(const avalue: lookupkindty);
   procedure setformat(const avalue: msestring);
   procedure setcolor(const avalue: colorty);
   
   function getsumasinteger: integer;
   function getsumaslargeint: int64;
   function getsumasfloat: double;
   function getsumascurrency: currency;
   procedure initsum;
  protected
   function xlineoffset: integer;
   procedure dobeforenextrecord(const adatasource: tdatasource);
  public 
   constructor create(aowner: tobject); override;
   destructor destroy; override;
   procedure resetsum(const skipcurrent: boolean);
   property sumasinteger: integer read getsumasinteger;
   property sumaslargeint: int64 read getsumaslargeint;
   property sumasfloat: double read getsumasfloat;
   property sumascurrency: currency read getsumascurrency;
   property richvalue: richstringty read fvalue write setrichvalue;
  published
   property tag: integer read ftag write ftag;
   property options: reptabulatoritemoptionsty read foptions write foptions;
   property value: msestring read fvalue.text write setvalue;
   property font: treptabfont read getfont write setfont stored isfontstored;
   property color: colorty read fcolor write setcolor default cl_none;
   property textflags: textflagsty read ftextflags write settextflags 
                   default defaultreptabtextflags;
   property datafield: string read getdatafield write setdatafield;
   property datasource: tdatasource read getdatasource1 write setdatasource;
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer 
                                      write setlookupbuffer;
   property lookupkeyfieldno: integer read flookupkeyfieldno 
                                      write setlookupkeyfieldno default 0;
   property lookupvaluefieldno: integer read flookupvaluefieldno 
                                      write setlookupvaluefieldno default 0;
   property lookupkind: lookupkindty read flookupkind 
                                      write setlookupkind default lk_text;
   property format: msestring read fformat write setformat;

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
   procedure dobeforenextrecord(const adatasource: tdatasource);
   procedure initsums;
  public
   constructor create(const aowner: tcustomrecordband);
   procedure resetsums(const skipcurrent: boolean);
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
                      rbs_notfirstrecord,rbs_lastrecord,rbs_visibilitychecked{,
                      rbs_empty});
 recordbandstatesty = set of recordbandstatety; 
 
 ireportclient = interface(inullinterface)
  function getwidget: twidget;
  procedure updatevisibility;
  procedure beginrender(const arestart: boolean);
  procedure endrender;
  procedure adddatasets(var adatasets: datasetarty);
  procedure init;
 end;
 ireportclientarty = array of ireportclient;
 
 ibandparent = interface(inullinterface)
                        ['{B02EE732-4686-4E0C-8C18-419D7D020386}']
  procedure registerclient(const aclient: ireportclient);
  procedure unregisterclient(const aclient: ireportclient);
  function beginband(const acanvas: tcanvas;
                              const sender: tcustomrecordband): boolean;
                   //true if area full
  procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
  function istopband: boolean;
  function isfirstband: boolean;
  function islastband(const addheight: integer = 0): boolean;
  function isfirstrecord: boolean;
  function islastrecord: boolean;
//  function isfirstofgroup: boolean;
//  function islastofgroup: boolean;
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
                  //defines hasdata, page nums are null based
                 bo_visigroupfirst,bo_visigroupnotfirst,
                 bo_visigrouplast,bo_visigroupnotlast,
                 bo_localvalue 
                  //used in treppagenumdisp to show the number of the current 
                  //treportpage instead the number of the printed pages
                  //and in trepprinttimedisp to show now instead of 
                  //print start time
                 );
 bandoptionsty = set of bandoptionty;

 bandoptionshowty = (
                   //show only on first/last record of group
                 bos_showfirstpage,bos_hidefirstpage,
                 bos_shownormalpage,bos_hidenormalpage,
                  //checks current treportpage
                 bos_showevenpage,bos_hideevenpage,
                 bos_showoddpage,bos_hideoddpage,
                  //checks the printed page number
                 bos_showtopofpage,bos_hidetopofpage,
                 bos_shownottopofpage,bos_hidenottopofpage,
                 bos_showfirstofpage,bos_hidefirstofpage,
                 bos_shownormalofpage,bos_hidenormalofpage,                 
                 bos_showlastofpage,bos_hidelastofpage,
                  //checks the position in the bandarea                 
                 bos_showfirstrecord,bos_hidefirstrecord, 
                 bos_shownormalrecord,bos_hidenormalrecord,
                 bos_showlastrecord,bos_hidelastrecord
                  //checks the connected dataset
                  );
 bandoptionshowsty = set of bandoptionshowty;

const 
 visibilitymask = [bos_showfirstpage,bos_hidefirstpage,
                   bos_shownormalpage,bos_hidenormalpage,
                   bos_showevenpage,bos_hideevenpage,
                   bos_showoddpage,bos_hideoddpage,
                   bos_showtopofpage,bos_hidetopofpage,
                   bos_shownottopofpage,bos_hidenottopofpage,
                   bos_showfirstofpage,bos_hidefirstofpage,
                   bos_shownormalofpage,bos_hidenormalofpage,
                   bos_showlastofpage,bos_hidelastofpage,
                   bos_showfirstrecord,bos_hidefirstrecord,
                   bos_shownormalrecord,bos_hidenormalrecord,
                   bos_showlastrecord,bos_hidelastrecord
                   ];
 defaultrepvaluedispoptions = [bo_evenpage,bo_oddpage];
type                     
 trepspacer = class(tspacer,ireportclient)
  private
   foptionsrep: bandoptionshowsty;   
   fparentintf: ibandparent;
   procedure setoptionsrep(const avalue: bandoptionshowsty);
  protected
   procedure parentchanged; override; //update fparentintf
   procedure updatevisibility;
   procedure beginrender(const arestart: boolean);
   procedure endrender;
   procedure adddatasets(var adatasets: datasetarty);
   procedure init;
  published
   property optionsrep: bandoptionshowsty read foptionsrep 
                                        write setoptionsrep default [];
 end;
 
 bandareaarty = array of tcustombandarea;
 
 tcustomrecordband = class(tcustomscalingwidget,idbeditinfo,ireccontrol,
                                iobjectpicker,ireportclient)
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
   foptionsshow: bandoptionshowsty;
   fgroupnum: integer;
   fnextgroupnum: integer;
   fobjectpicker: tobjectpicker;
   fnextband: tcustomrecordband;
   fnextbandifempty: tcustomrecordband;
   fareas: bandareaarty;
   fonbeforepaint: painteventty;
   fonbeforenextrecord: notifyeventty;
   fonafternextrecord: notifyeventty;
   procedure settabs(const avalue: treptabulators);
   procedure setoptionsshow(const avalue: bandoptionshowsty);
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
   procedure setnextband(const avalue: tcustomrecordband);
   procedure setnextbandifempty(const avalue: tcustomrecordband);
  protected
   procedure setfont(const avalue: trepwidgetfont);
   function getfont: trepwidgetfont;
   function getfontclass: widgetfontclassty; override;
   
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
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
   procedure beginrender(const arestart: boolean); virtual;
   procedure endrender; virtual;
   procedure adddatasets(var adatasets: datasetarty); virtual;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doafterpaint(const acanvas: tcanvas); override;
   procedure dobeforenextrecord(const adatasource: tdatasource); virtual;
   procedure dosyncnextrecord; virtual;
   
   procedure nextrecord(const setflag: boolean = true);
   function rendering: boolean;
   function bandheight: integer;
   procedure dobeforerender(var empty: boolean); virtual;
   procedure synctofontheight; override;
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
   function isfirstrecord: boolean;
   function islastrecord: boolean;
   function isfirstofgroup: boolean;
   function islastofgroup: boolean;
   procedure restart;
   
   property tabs: treptabulators read ftabs write settabs;
   property font: trepwidgetfont read getfont write setfont stored isfontstored;
   property datasource: tdatasource read getdatasource write setdatasource;
   property visidatasource: tdatasource read getvisidatasource 
                          write setvisidatasource;
   property visidatafield: string read getvisidatafield write setvisidatafield;
               //controls visibility not null -> visible
   property visigroupfield: string read getvisigroupfield write setvisigroupfield;
   property options: bandoptionsty read foptions write foptions default [];
   property optionsshow: bandoptionshowsty read foptionsshow write setoptionsshow default [];
   property nextband: tcustomrecordband read fnextband write setnextband;
                       //used by tcustombandarea
   property nextbandifempty: tcustomrecordband read fnextbandifempty 
                                       write setnextbandifempty;
                       //used by tcustombandarea
   property onbeforerender: beforerenderrecordeventty read fonbeforerender
                               write fonbeforerender;
   property onbeforepaint: painteventty read fonbeforepaint write fonbeforepaint;
   property onpaint: painteventty read fonpaint write fonpaint;
   property onafterpaint: painteventty read fonafterpaint write fonafterpaint;
   property onbeforenextrecord: notifyeventty read fonbeforenextrecord 
                                                 write fonbeforenextrecord;
   property onafternextrecord: notifyeventty read fonafternextrecord 
                                                 write fonafternextrecord;
  published
   property anchors default defaultbandanchors;
   property optionswidget default defaultbandoptionswidget;
 end;

 trecordband = class(tcustomrecordband)
  published
   property font;
   property tabs;
   property datasource;
   property options;
   property optionsshow;
   property optionsscale;
   property visidatasource;
   property visidatafield;
   property visigroupfield;
   property nextband;
   property nextbandifempty;
   property onfontheightdelta;
   property onchildscaled;

   property onbeforerender;
   property onbeforepaint;
   property onpaint;
   property onafterpaint;
   property onbeforenextrecord;
   property onafternextrecord;
  end;

 tcustomrepvaluedisp = class; 
 getrepvaluetexteventty = procedure(const sender: tcustomrepvaluedisp; 
                                          var atext: msestring) of object;
                                          
 tcustomrepvaluedisp = class(tcustomrecordband)
  private
   ftextflags: textflagsty;
   fformat: msestring;
   fongettext: getrepvaluetexteventty;
   procedure setformat(const avalue: msestring);
   procedure settextflags(const avalue: textflagsty);
  protected
   function calcminscrollsize: sizety; override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure dogettext(var atext: msestring);
   function getdisptext: msestring; virtual;
   procedure render(const acanvas: tcanvas; var empty: boolean); override;
  public
   constructor create(aowner: tcomponent); override;
   property textflags: textflagsty read ftextflags write settextflags default 
                                            defaultrepvaluedisptextflags;
   property format: msestring read fformat write setformat;
   property optionsscale default defaultrepvaluedispoptionsscale;
   property ongettext: getrepvaluetexteventty read fongettext write fongettext;
   property options default defaultrepvaluedispoptions;
  published
   property anchors default [an_left,an_top];
 end;
 
 trepvaluedisp = class(tcustomrepvaluedisp)
  private
   fvalue: msestring;
   procedure setvalue(const avalue: msestring);
  protected
   function getdisptext: msestring; override;
   procedure dobeforerender(var empty: boolean); override;
  published
   property value: msestring read fvalue write setvalue;
   property font;
//   property tabs;
//   property datasource;
   property textflags;
   property options;
   property optionsshow;
   property optionsscale;
   property visidatasource;
   property visidatafield;
   property visigroupfield;
   property onfontheightdelta;
   property onchildscaled;

   property onbeforerender;
   property onpaint;
   property onafterpaint;
   property ongettext;
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
   procedure initpage; override;
   procedure parentchanged; override;
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
   procedure registerclient(const aclient: ireportclient);
   procedure unregisterclient(const aclient: ireportclient);
   function beginband(const acanvas: tcanvas;
                              const sender: tcustomrecordband): boolean;
                   //true if area full
   procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
   function istopband: boolean;
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
   procedure dobeforenextrecord(const adatasource: tdatasource); override;
   procedure dosyncnextrecord; override;
  protected
   procedure setparentwidget(const avalue: twidget); override;   
   procedure registerchildwidget(const child: twidget); override;
   procedure unregisterchildwidget(const child: twidget); override;
   procedure dobeforerender(var empty: boolean); override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure updatevisibility; override;
   function getminbandsize: sizety; override;
   procedure initpage; override;
   procedure init; override;
   procedure beginrender(const arestart: boolean); override;
   procedure endrender; override;
   procedure adddatasets(var adatasets: datasetarty); override;
   function lastbandheight: integer; override;
  public
   property font: trepwidgetfont read getfont write setfont stored isfontstored;
 end;

 tbandgroup = class(tcustombandgroup)
  published
   property font;
//   property tabs;
   property datasource;
   property nextband;
   property nextbandifempty;
   property options;
   property optionsshow;
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
 
 bandareastatety = (bas_inited,bas_backgroundrendered,bas_areafull,
                    bas_rendering,
                    bas_top,bas_notfirstband,bas_lastband,bas_bandstarted,
                    bas_activebandchanged);
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
   frecordband: tcustomrecordband;
   fonbeforerender: bandareaeventty;
   fonpaint: bandareapainteventty;
   fonafterpaint: bandareapainteventty;
   fonfirstarea: bandareaeventty;
   forigin: pointty;
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
   procedure beginrender(const arestart: boolean);
   procedure endrender;
   procedure adddatasets(var adatasets: datasetarty);
   procedure dofirstarea; virtual;
   procedure dobeforerender; virtual;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doafterpaint1(const acanvas: tcanvas); virtual;
   procedure init; virtual;
   procedure initareapage;
   procedure initband;
   procedure initpage;
   procedure dobeforenextrecord(const adatasource: tdatasource);
   procedure dosyncnextrecord;
   function checkareafull(ay: integer): boolean;
           //ibandparent
   procedure registerclient(const aclient: ireportclient);
   procedure unregisterclient(const aclient: ireportclient);
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
   function istopband: boolean;
   function isfirstband: boolean;
   function islastband(const addheight: integer = 0): boolean;
   function isfirstrecord: boolean;
   function islastrecord: boolean;
//   function isfirstofgroup: boolean;
//   function islastofgroup: boolean;
   function remainingheight: integer;
   function pagepagenum: integer; //null based
   function reppagenum: integer; //null based
   function pageprintstarttime: tdatetime;
   function repprintstarttime: tdatetime;
   function getreppage: tcustomreportpage;

   procedure restart;
   
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
 
 tcustomreport = class;
   
 treportpagedatalink = class(tmsedatalink)
 end;

 reportpageoptionty = (rpo_once,rpo_firsteven,rpo_firstodd);
 reportpageoptionsty = set of reportpageoptionty;

 reportpageeventty = procedure(const sender: tcustomreportpage) of object;
 reportpagepainteventty = procedure(const sender: tcustomreportpage;
                              const acanvas: tcanvas) of object;
 beforerenderpageeventty = procedure(const sender: tcustomreportpage;
                                          var empty: boolean) of object;
 reppageorientationty = (rpo_default,rpo_portrait,rpo_landscape);
 
 tcustomreportpage = class(twidget,ibandparent)
  private
   fbands: recordbandarty;
   fclients: ireportclientarty;
   fareas: bandareaarty;
   fstate: reportpagestatesty;
   fonbeforerender: beforerenderpageeventty;
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
   fprintorientation: reppageorientationty;
   flastpagecount: integer;
   fonbeforenextrecord: notifyeventty;
   fonafternextrecord: notifyeventty;
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
   procedure adddatasets(var adatasets: datasetarty);
   function rendering: boolean;
   procedure beginarea(const acanvas: tcanvas; const sender: tcustombandarea);
   procedure dofirstpage; virtual;
   procedure dobeforerender(var empty: boolean); virtual;
   procedure doonpaint(const acanvas: tcanvas); override;
   procedure doafterpaint1(const acanvas: tcanvas); virtual;
   procedure doafterlastpage; virtual;
   procedure dobeforenextrecord(const adatasource: tdatasource);
   procedure dosyncnextrecord;
   property ppmm: real read fppmm write setppmm; //pixel per mm
   
   procedure init; virtual;
   function render(const acanvas: tcanvas): boolean;
          //true if empty

              //ibandparent
   procedure registerclient(const aclient: ireportclient);
   procedure unregisterclient(const aclient: ireportclient);
   function beginband(const acanvas: tcanvas;
                               const sender: tcustomrecordband): boolean;
   procedure endband(const acanvas: tcanvas; const sender: tcustomrecordband);  
   function istopband: boolean;
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
   procedure restart;
   
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
   property onbeforerender: beforerenderpageeventty read fonbeforerender
                               write fonbeforerender;
   property onpaint: reportpagepainteventty read fonpaint write fonpaint;
   property onafterpaint: reportpagepainteventty read fonafterpaint 
                        write fonafterpaint;
   property onbeforenextrecord: notifyeventty read fonbeforenextrecord 
                                                 write fonbeforenextrecord;
   property onafternextrecord: notifyeventty read fonafternextrecord 
                                                 write fonafternextrecord;
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
   property onbeforenextrecord;
   property onafternextrecord;
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
 preambleeventty = procedure(const sender: tcustomreport; var apreamble: string) of object;
 

 reportoptionty = (reo_autorelease,reo_prepass,reo_nodisablecontrols,
                   reo_nothread,reo_waitdialog,
                      reo_autoreadstat,reo_autowritestat);
 reportoptionsty = set of reportoptionty;

const
 defaultreportoptions = [];
 
type 
 tcustomreport = class(twidget)
  private
   fppmm: real;
   fonbeforerender: notifyeventty;
   fonafterrender: notifyeventty;
//   fprinter: tstreamprinter; //preliminary 
   fprinter: tcustomprinter; //preliminary 
   fstream: ttextstream;
   fstreamset: boolean;
   fcommand: string;
   fcanvas: tcanvas;
   fpagenum: integer;
   fthread: tmsethread;
   fcanceled: boolean;
   fppmmbefore: real;
   fstate: repstatesty;
   factivepage: integer;
   fprintstarttime: tdatetime;
   fonprogress: notifyeventty;
   fonrenderfinish: reporteventty;
   fnilstream: boolean;
   foptions: reportoptionsty;
   flastpagecount: integer;
   foncreate: notifyeventty;
   fondestroy: notifyeventty;
   fondestroyed: notifyeventty;
   fstatfile: tstatfile;
   fonpreamble: preambleeventty;
   fdialogtext: msestring;
   fdialogcaption: msestring;
   fdatasets: datasetarty;
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
   procedure doexec(const sender: tobject);
   procedure docancel(const sender: tobject);
  protected
   frepdesigninfo: repdesigninfoty;
   freppages: reportpagearty;
   fdefaultprintorientation: pageorientationty;
   procedure insertwidget(const awidget: twidget; const apos: pointty); override;
   procedure internalrender(const acanvas: tcanvas; const aprinter: tcustomprinter;
                  const acommand: string; const astream: ttextstream;
                  const anilstream: boolean; const onafterrender: reporteventty);
   procedure unregisterchildwidget(const child: twidget); override;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
   procedure defineproperties(filer: tfiler); override;
   procedure nextpage(const acanvas: tcanvas);
   procedure doprogress;
   procedure doasyncevent(var atag: integer); override;
   procedure notification(acomponent: tcomponent; 
                                        operation: toperation); override;
   procedure setfont(const avalue: trepfont);
   function getfont: trepfont;
   function getfontclass: widgetfontclassty; override;
   procedure beforedestruction; override;
   procedure doloaded; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure render(const acanvas: tcanvas;
                        const onafterrender: reporteventty = nil); overload;
   procedure render(const aprinter: tstreamprinter; const command: string = '';
                        const onafterrender: reporteventty = nil); overload;
   procedure render(const aprinter: tstreamprinter; const astream: ttextstream;
                        const onafterrender: reporteventty = nil); overload;
   procedure render(const aprinter: tgdiprinter;
                           const onafterrender: reporteventty = nil); overload;
   procedure waitfor;         //returns before calling of onafterrender
   function prepass: boolean; //true if in prepass render state
   procedure restart;
   procedure recordchanged;  
     //calls recordchanged of active page
   
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
   property options: reportoptionsty read foptions write foptions 
                                  default defaultreportoptions;
   property dialogtext: msestring read fdialogtext write fdialogtext;
   property dialogcaption: msestring read fdialogcaption write fdialogcaption;

   property onpreamble: preambleeventty read fonpreamble write fonpreamble;
   property onbeforerender: notifyeventty read fonbeforerender
                               write fonbeforerender;
   property onafterrender: notifyeventty read fonafterrender
                               write fonafterrender;
        //executed in main thread context
   property onprogress: notifyeventty read fonprogress write fonprogress;
   property oncreate: notifyeventty read foncreate write foncreate;
   property ondestroy: notifyeventty read fondestroy write fondestroy;
   property ondestroyed: notifyeventty read fondestroyed write fondestroyed;
 end;

 treport = class(tcustomreport)
  private
   fonloaded: notifyeventty;
   procedure setstatfile(const avalue: tstatfile);
  protected
   class function getmoduleclassname: string; override;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean); 
                                     overload; virtual;   
  published    
   property statfile: tstatfile read fstatfile write setstatfile;
   property color;
   property ppmm;
   property font;
   property grid_show;
   property grid_snap;
   property grid_size;
   property options;
   property dialogtext;
   property dialogcaption;
   property onpreamble;
   property onbeforerender;
   property onafterrender;
   property onprogress;
   property oncreate;
   property onloaded: notifyeventty read fonloaded write fonloaded;
   property ondestroy;
   property ondestroyed;
 end;

 reportclassty = class of treport;
  
function createreport(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;
procedure initreportcomponent(const amodule: tcomponent; 
                                         const acomponent: tcomponent);
function getreportscale(const amodule: tcomponent): real;

implementation
uses
 msedatalist,sysutils,msestreaming,msebits,msereal;
type
 tcustomframe1 = class(tcustomframe);
 twidget1 = class(twidget);
 twindow1 = class(twindow);
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
  fowner.changed;
  {
  with treptabulators(fowner.fowner).fband do begin
   invalidate;
  end;
  }
 end;
end;

{ treptabulatoritem }

constructor treptabulatoritem.create(aowner: tobject);
var
 kind1: tablinekindty;
begin
 fcolor:= cl_none;
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
 lookupbuffer:= nil;
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
  if rendering or ([csdesigning,csdestroying] * componentstate = [csdesigning]) then begin
   minclientsizechanged;
   change(-1);
  end;
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
var
 key: integer;
 mstr1: msestring;
 int1: integer;
 rea1: realty; 
begin
 if fdatalink.fieldactive then begin
  result.format:= nil;
  if flookupbuffer <> nil then begin
   try
    result.text:= '';
    key:= fdatalink.field.asinteger;
    case flookupkind of
     lk_text: begin
      result.text:= flookupbuffer.lookuptext(flookupkeyfieldno,
                   flookupvaluefieldno,key);
     end;
     lk_integer: begin
      int1:= flookupbuffer.lookupinteger(flookupkeyfieldno,
                   flookupvaluefieldno,key);
//      result.text:= inttostr(int1);
      result.text:= realtytostr(int1,fformat);
     end;
     lk_float: begin
      rea1:= flookupbuffer.lookupfloat(flookupkeyfieldno,
                   flookupvaluefieldno,key);
      result.text:= realtytostr(rea1,fformat)
     end;
     lk_date,lk_datetime: begin
      rea1:= flookupbuffer.lookupfloat(flookupkeyfieldno,
                   flookupvaluefieldno,key);
      result.text:= mseformatstr.datetimetostring(rea1,fformat);
     end;
     lk_time: begin
      rea1:= flookupbuffer.lookupfloat(flookupkeyfieldno,
                   flookupvaluefieldno,key);
      result.text:= mseformatstr.timetostring(rea1,fformat);
     end;
    end;
   except
   end;
  end
  else begin
   if rto_sum in foptions then begin
    with fdatalink.field do begin
     if not (rto_shownull in foptions) and 
      ((rto_nocurrentvalue in foptions) or fsum.resetpending or isnull) and 
                             (fsum.count = 0) then begin
      result.text:= '';
     end
     else begin
      case datatype of 
       ftinteger,ftword,ftsmallint,ftboolean: begin
        result.text:= realtytostr(sumasinteger,fformat);
       end;
       ftlargeint: begin
        result.text:= realtytostr(sumaslargeint,fformat);
       end;
       ftfloat: begin
        result.text:= realtytostr(sumasfloat,fformat);
       end;
       ftbcd: begin
        result.text:= realtytostr(sumascurrency,fformat);
       end;
      end;
     end;
    end;
   end
   else begin
    result.text:= fdatalink.msedisplaytext(fformat);
   end;
  end;
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

procedure treptabulatoritem.setlookupbuffer(const avalue: tcustomlookupbuffer);
begin
 treptabulators(fowner).fband.setlinkedvar(avalue,tmsecomponent(flookupbuffer));
 changed;
end;

procedure treptabulatoritem.setlookupkeyfieldno(const avalue: integer);
begin
 flookupkeyfieldno:= avalue;
 changed;
end;

procedure treptabulatoritem.setlookupvaluefieldno(const avalue: integer);
begin
 flookupvaluefieldno:= avalue;
 changed;
end;

procedure treptabulatoritem.setlookupkind(const avalue: lookupkindty);
begin
 flookupkind:= avalue;
 changed;
end;

procedure treptabulatoritem.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 changed;
end;

procedure treptabulatoritem.setcolor(const avalue: colorty);
begin
 if fcolor <> avalue then begin
  fcolor:= avalue;
  treptabulators(fowner).fband.invalidate;  
 end
end;

procedure treptabulatoritem.resetsum(const skipcurrent: boolean);
begin
 fillchar(fsum,sizeof(fsum),0);
 fsum.resetpending:= skipcurrent;
 fsum.reset:= true;
end;

procedure treptabulatoritem.initsum;
begin
 fillchar(fsum,sizeof(fsum),0);
end;

procedure treptabulatoritem.dobeforenextrecord(const adatasource: tdatasource);
begin
 if (rto_sum in foptions) and (fdatalink.datasource = adatasource) and 
           fdatalink.fieldactive then begin
  with fdatalink.field,fsum do begin
   if not isnull then begin
    inc(count);
    case datatype of
     ftinteger,ftword,ftsmallint,ftboolean: begin
      integervalue:= integervalue + asinteger;
     end;
     ftlargeint: begin
      largeintvalue:= largeintvalue + aslargeint;
     end;
     ftfloat: begin
      floatvalue:= floatvalue + asfloat;
     end;
     ftbcd: begin
      bcdvalue:= bcdvalue + ascurrency;
     end;
    end;
   end;
  end;
  if fsum.resetpending then begin
   initsum;
  end;
 end;
end;

function treptabulatoritem.getsumasinteger: integer;
begin
 if fsum.resetpending and fsum.reset or not fdatalink.fieldactive then begin
  result:= 0;
 end
 else begin
  result:= fsum.integervalue;
  if not (rto_nocurrentvalue in foptions) then begin
   result:= result + fdatalink.field.asinteger;
  end;
 end;
end;

function treptabulatoritem.getsumaslargeint: int64;
begin
 if fsum.resetpending and fsum.reset or not fdatalink.fieldactive then begin
  result:= 0;
 end
 else begin
  result:= fsum.largeintvalue;
  if not (rto_nocurrentvalue in foptions) then begin
   result:= result + fdatalink.field.aslargeint;
  end;
 end;
end;

function treptabulatoritem.getsumasfloat: double;
begin
 if fsum.resetpending and fsum.reset or not fdatalink.fieldactive then begin
  result:= 0;
 end
 else begin
  result:= fsum.floatvalue;
  if not (rto_nocurrentvalue in foptions) then begin
   result:= result + fdatalink.field.asfloat;
  end;
 end;
end;

function treptabulatoritem.getsumascurrency: currency;
begin
 if fsum.resetpending and fsum.reset or not fdatalink.fieldactive then begin
  result:= 0;
 end
 else begin
  result:= fsum.bcdvalue;
  if not (rto_nocurrentvalue in foptions) then begin
   result:= result + fdatalink.field.ascurrency;
  end;
 end;
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
   acanvas.addcliprect(inflaterect(makerect(nullpoint,fband.size),1000));
                   //allow line drawing everywhere
//   acanvas.addclipframe(makerect(nullpoint,fband.paintsize),1000);
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
 int1,int2,int3,int4: integer;
 bo2: boolean;
 rstr1: richstringty;
 rect1: rectty;
 isdecimal: boolean;
 cellrect: rectty;
 
begin
 fminsize:= nullsize;
// bandcx:= fband.innerclientsize.cx;
 bandcx:= adest.cx;
 bo1:= false;
 if apaint then begin  
  with fband do begin
   cellrect:= adest;
//   if fframe <> nil then begin
//    inflaterect1(cellrect,fframe.innerframe);
//   end;
   if not rendering or (fparentintf = nil) then begin 
    visiblemask:= [lv_topofpage,lv_nottopofpage,
                   lv_firstofpage,lv_normal,lv_lastofpage,
                   lv_firstofgroup,lv_lastofgroup,
                   lv_firstrecord,lv_lastrecord];
   end
   else begin
    visiblemask:= [lv_normal];    
    with fparentintf do begin
     if istopband then begin
      include(visiblemask,lv_topofpage);
      exclude(visiblemask,lv_nottopofpage);
     end
     else begin
      include(visiblemask,lv_nottopofpage);
      exclude(visiblemask,lv_topofpage);
     end;
     if isfirstband then begin
      include(visiblemask,lv_firstofpage);
      exclude(visiblemask,lv_normal);
     end;
     if islastband then begin
      include(visiblemask,lv_lastofpage);
      exclude(visiblemask,lv_normal);
     end;
     if fband.isfirstofgroup then begin
      include(visiblemask,lv_firstofgroup);
     end;
     if fband.islastofgroup then begin
      include(visiblemask,lv_lastofgroup);
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
      if apaint and (foptions*[rto_sum,rto_noreset]=[rto_sum]) then begin
       fsum.resetpending:= true;
      end;
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
      dest.x:= adest.x + textpos;
      if apaint and (fcolor <> cl_none) then begin
       cellrect.x:= adest.x + linepos;
       if int1 < high(ftabs) then begin
        cellrect.cx:= cellwidth;
       end
       else begin
        cellrect.cx:= adest.cx - linepos;
       end;
       acanvas.fillrect(cellrect,fcolor);
      end;
     end;
     isdecimal:= tabkind = tak_decimal;
     case tabkind of 
      tak_centered: begin
       flags:= (flags - [tf_right]) + [tf_xcentered];
       dec(dest.x,dest.cx div 2);
      end;
      tak_right,tak_decimal: begin   
       flags:= (flags - [tf_xcentered]) + [tf_right];
       dec(dest.x,dest.cx);
      end;
     end;
    end;
    if isdecimal then begin
     int2:= findlastchar(text.text,msechar(decimalseparator));
     if int2 > 0 then begin
      rstr1:= text;
      text:= richcopy(rstr1,1,int2-1);
      if apaint then begin
       drawtext(acanvas,finfo);
      end
      else begin
       textrect(acanvas,finfo);
      end;
      int3:= res.x;
      int4:= res.cx;
      text:= richcopy(rstr1,int2,bigint);
      inc(dest.x,dest.cx);
      exclude(flags,tf_right);
      if apaint then begin
       drawtext(acanvas,finfo);
      end
      else begin
       textrect(acanvas,finfo);
      end;
      res.x:= int3;
      res.cx:= res.cx + int4;
      text:= rstr1;
     end
     else begin
      if apaint then begin
       drawtext(acanvas,finfo);
      end
      else begin
       textrect(acanvas,finfo);
      end;
     end;
    end
    else begin            //not decimal
     if apaint then begin
      drawtext(acanvas,finfo);
     end
     else begin
      textrect(acanvas,finfo);
     end;
    end;
    int2:= res.x + res.cx;
    if int2 > fminsize.cx then begin
     fminsize.cx:= int2;
    end;
    if res.cy = 0 then begin
     res.cy:= font.lineheight;
    end;
    int2:= dest.y + res.cy;
    if int2 > fminsize.cy then begin
     fminsize.cy:= int2;
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
        acanvas.drawline(makepoint(int2,fband.clientheight+libottom_dist),
                                              makepoint(int2,-litop_dist),color);
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

procedure treptabulators.resetsums(const skipcurrent: boolean);
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  treptabulatoritem(fitems[int1]).resetsum(skipcurrent);
 end;
end;

procedure treptabulators.dobeforenextrecord(const adatasource: tdatasource);
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  treptabulatoritem(fitems[int1]).dobeforenextrecord(adatasource);
 end;
end;

procedure treptabulators.initsums;
var
 int1: integer;
begin
 for int1:= 0 to high(fitems) do begin
  treptabulatoritem(fitems[int1]).initsum;
 end;
end;

procedure setbandoptionsshow(const avalue: bandoptionshowsty;
                                           var foptions: bandoptionshowsty);
const
 topmask: bandoptionshowsty = [bos_showtopofpage,bos_hidetopofpage];
 nottopmask: bandoptionshowsty = [bos_shownottopofpage,bos_hidenottopofpage];
 firstmask: bandoptionshowsty = [bos_showfirstpage,bos_hidefirstpage];
 normalmask: bandoptionshowsty = [bos_shownormalpage,bos_hidenormalpage];
 evenmask: bandoptionshowsty = [bos_showevenpage,bos_hideevenpage];
 oddmask: bandoptionshowsty = [bos_showoddpage,bos_hideoddpage];
 firstofpagemask: bandoptionshowsty = [bos_showfirstofpage,bos_hidefirstofpage];
 normalofpagemask: bandoptionshowsty = [bos_shownormalofpage,bos_hidenormalofpage];
 lastofpagemask: bandoptionshowsty = [bos_showlastofpage,bos_hidelastofpage];
 firstrecmask: bandoptionshowsty = [bos_showfirstrecord,bos_hidefirstrecord];
 normalrecmask: bandoptionshowsty = [bos_shownormalrecord,bos_hidenormalrecord];
 lastrecmask: bandoptionshowsty = [bos_showlastrecord,bos_hidelastrecord];
var
 vis1: bandoptionshowsty;
begin
 vis1:= bandoptionshowsty(setsinglebit(longword(avalue),longword(foptions),
                                 longword(topmask)));
 vis1:= bandoptionshowsty(setsinglebit(longword(avalue),longword(foptions),
                                 longword(nottopmask)));
 vis1:= bandoptionshowsty(setsinglebit(longword(avalue),longword(foptions),
                                 longword(firstmask)));
 vis1:= bandoptionshowsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(normalmask)));
 vis1:= bandoptionshowsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(evenmask)));
 vis1:= bandoptionshowsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(oddmask)));
 vis1:= bandoptionshowsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(firstofpagemask)));
 vis1:= bandoptionshowsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(normalofpagemask)));
 vis1:= bandoptionshowsty(setsinglebit(longword(vis1),
                                 longword(foptions),longword(lastofpagemask)));
 vis1:= bandoptionshowsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(firstrecmask)));
 vis1:= bandoptionshowsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(normalrecmask)));
 foptions:= bandoptionshowsty(setsinglebit(longword(vis1),longword(foptions),
                                 longword(lastrecmask)));
end;

function checkvisibility(const fparentintf: ibandparent;
                 const foptions: bandoptionshowsty; checklast: boolean;
                 var aresult: boolean; out show: boolean): boolean;
                  //true if more checks possible
label
 endlab;
var
 topofpage,firstofpage,lastofpage: boolean;
 even1,first1: boolean;
begin
 result:= false;
 show:= false;
 if foptions * visibilitymask <> [] then begin
  if fparentintf <> nil then begin
   first1:= fparentintf.pagepagenum = 0;
   if first1 and (bos_hidefirstpage in foptions) then begin
    aresult:= false;
    goto endlab;
   end;
   if first1 and (bos_showfirstpage in foptions) then begin
    aresult:= true;
    goto endlab;
   end;
   if not first1 and (bos_hidenormalpage in foptions) then begin
    aresult:= false;
    goto endlab;
   end;
   if not first1 and (bos_shownormalpage in foptions) then begin
    aresult:= true;
    goto endlab;
   end;

   even1:= not odd(fparentintf.reppagenum);
   if even1 and (bos_hideevenpage in foptions) then begin
    aresult:= false;
    goto endlab;
   end;
   if not even1 and (bos_hideoddpage in foptions) then begin
    aresult:= false;
    goto endlab;
   end;
   show:= even1 and (bos_showevenpage in foptions);
   show:= show or not even1 and (bos_showoddpage in foptions);

   topofpage:= fparentintf.istopband;
   firstofpage:= fparentintf.isfirstband;
   lastofpage:= checklast and fparentintf.islastband;
   if topofpage then begin
    if bos_showtopofpage in foptions then begin
     aresult:= true;
     goto endlab;
    end
    else begin
     if bos_hidetopofpage in foptions then begin
      aresult:= false;
     end;
    end;
   end
   else begin
    if bos_shownottopofpage in foptions then begin
     aresult:= true;
     goto endlab;
    end
    else begin
     if bos_hidenottopofpage in foptions then begin
      aresult:= false;
     end;
    end;
   end;
   if firstofpage then begin
    if bos_showfirstofpage in foptions then begin
     aresult:= true;
     goto endlab;
    end
    else begin
     if bos_hidefirstofpage in foptions then begin
      aresult:= false;
     end;
    end;
   end;
   if lastofpage then begin
    if bos_showlastofpage in foptions then begin
     aresult:= true;
     goto endlab;
    end
    else begin
     if bos_hidelastofpage in foptions then begin
      aresult:= false;
      show:= false;
     end;
    end;
   end;
   if not firstofpage and not lastofpage then begin
    if bos_shownormalofpage in foptions then begin
     aresult:= true;
     goto endlab;
    end
    else begin
     if bos_hidenormalofpage in foptions then begin
      aresult:= false;
      show:= false;
     end;
    end;
   end;   
  end;
 end;
 result:= true;
endlab:
end;
 
procedure updateparentintf(const sender: ireportclient; var fparentintf: ibandparent);
var
 widget1: twidget;
begin
 with twidget1(sender.getwidget) do begin
  if fparentwidget <> nil then begin
   if fparentintf <> nil then begin
    fparentintf.unregisterclient(sender);
   end;
   widget1:= fparentwidget;
   while (widget1 <> nil) and 
     not widget1.getcorbainterface(typeinfo(ibandparent),fparentintf) do begin
    widget1:= widget1.parentwidget;
   end; 
   if fparentintf <> nil then begin
    fparentintf.registerclient(sender);
   end;
  end
  else begin
   if fparentintf <> nil then begin
    fparentintf.unregisterclient(sender);
   end;
   fparentintf:= nil;
  end;
 end;
end;

{ trepspacer }

procedure trepspacer.updatevisibility;
var
 bo1,bo2: boolean;
begin
 bo1:= visible;
 checkvisibility(fparentintf,foptionsrep,true,bo1,bo2);
 visible:= bo1 or bo2;
end;

procedure trepspacer.setoptionsrep(const avalue: bandoptionshowsty);
const
 spacerbandoptions =  [
                 bos_showtopofpage,bos_hidetopofpage,
                 bos_shownottopofpage,bos_hidenottopofpage,
                 bos_showfirstpage,bos_hidefirstpage,
                 bos_shownormalpage,bos_hidenormalpage,
                 bos_showevenpage,bos_hideevenpage,
                 bos_showoddpage,bos_hideoddpage,
                 bos_showfirstofpage,bos_hidefirstofpage,
                 bos_shownormalofpage,bos_hidenormalofpage,                 
                 bos_showlastofpage,bos_hidelastofpage
 //                bo_showfirstrecord,bo_hidefirstrecord, 
 //                bo_shownormalrecord,bo_hidenormalrecord,
 //                bo_showlastrecord,bo_hidelastrecord,
            //todo: check first-last record
 //                bo_localvalue
                 ];
                 

begin
 setbandoptionsshow(avalue * spacerbandoptions,foptionsrep);
end;

procedure trepspacer.parentchanged;
begin
 updateparentintf(ireportclient(self),fparentintf);
 inherited;
end;

procedure trepspacer.beginrender(const arestart: boolean);
begin
 include(widgetstate1,ws1_noclipchildren);
end;

procedure trepspacer.endrender;
begin
 exclude(widgetstate1,ws1_noclipchildren);
end;

procedure trepspacer.adddatasets(var adatasets: datasetarty);
begin
 //dummy
end;

procedure trepspacer.init;
begin
 //dummy
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
begin
 updateparentintf(ireportclient(self),fparentintf);
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
 int1: integer;
begin
 widget1:= rootwidget;
 if (widget1 is tcustomreport) and 
                       tcustomreport(widget1).canceled then begin
  abort;
 end;
 application.checkoverload;
 fparentintf.updatevisible; //??
 include(fstate,rbs_visibilitychecked);
 empty:= empty or (rbs_finish in fstate);
 dobeforerender(empty);
 if not empty then begin
  if not (rbs_visibilitychecked in fstate) then begin
   fparentintf.updatevisible;
  end;
  if visible then begin
   if fparentintf.beginband(acanvas,self) then begin
    exit; //area full
   end;
   try
    for int1:= 0 to high(fareas) do begin
     fareas[int1].initband;
    end;
    inherited paint(acanvas);
   finally
    fparentintf.endband(acanvas,self);
   end;
  end;
  nextrecord;
 end;
end;

procedure tcustomrecordband.init;
var
 int1: integer;
begin
 exclude(fstate,rbs_finish);
 if fvisigrouplink.fieldactive then begin
  fgroupnum:= fvisigrouplink.asinteger;
//  fnextgroupnum:= fgroupnum; set by beginrender
 end;
 for int1:= 0 to high(fareas) do begin
  fareas[int1].init;
 end;
end;

procedure tcustomrecordband.initpage;
var
 int1: integer;
begin
 exclude(fstate,rbs_pageshowed);
 for int1:= 0 to high(fareas) do begin
  fareas[int1].initpage;
 end;
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

procedure tcustomrecordband.beginrender(const arestart: boolean);
var
 int1: integer;
begin
 ftabs.initsums;
 if arestart then begin
  fstate:= (fstate * [rbs_pageshowed]) + [rbs_rendering]
 end
 else begin
  fstate:= [rbs_rendering];
 end;
 include(widgetstate1,ws1_noclipchildren);
 if fdatalink.active then begin
  application.lock;
  try
   fdatalink.dataset.first;
   if checkislastrecord(fdatalink,@dosyncnextrecord) then begin
    include(fstate,rbs_lastrecord);
   end;
   recchanged;
  finally
   application.unlock;
  end;
 end; 
 for int1:= 0 to high(fareas) do begin
  fareas[int1].beginrender(arestart);
 end;
end;

procedure tcustomrecordband.restart;
begin
 beginrender(true);
end;

procedure tcustomrecordband.endrender;
var
 int1: integer;
begin
 for int1:= 0 to high(fareas) do begin
  fareas[int1].endrender;
 end;
 exclude(fstate,rbs_rendering);
 exclude(widgetstate1,ws1_noclipchildren);
end;

procedure tcustomrecordband.adddatasets(var adatasets: datasetarty);
var
 int1: integer;
begin
 for int1:= 0 to high(fareas) do begin
  fareas[int1].adddatasets(adatasets);
 end;
 if fdatalink.dataset <> nil then begin
  adduniqueitem(pointerarty(adatasets),fdatalink.dataset);
 end;
end;

procedure tcustomrecordband.settabs(const avalue: treptabulators);
begin
 ftabs.assign(avalue);
end;

procedure tcustomrecordband.dobeforenextrecord(const adatasource: tdatasource);
begin
 ftabs.dobeforenextrecord(adatasource);
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
 application.lock;
 try
  if canevent(tmethod(fonbeforenextrecord)) then begin
   fonbeforenextrecord(self);
  end;
  if setflag then begin
   include(fstate,rbs_notfirstrecord);
   dobeforenextrecord(fdatalink.datasource);
  end;
  if fdatalink.active then begin
   fdatalink.dataset.next;
   if setflag then begin
    if checkislastrecord(fdatalink,@dosyncnextrecord) then begin
     include(fstate,rbs_lastrecord);
    end; 
    fparentintf.getreppage.recordchanged;
   end;
  end;
  if canevent(tmethod(fonafternextrecord)) then begin
   fonafternextrecord(self);
  end;
 finally
  application.unlock;
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
 if canevent(tmethod(fonbeforepaint)) then begin
  fonbeforepaint(self,acanvas);
 end;
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

procedure tcustomrecordband.setoptionsshow(const avalue: bandoptionshowsty);
begin
 setbandoptionsshow(avalue,foptionsshow);
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

function tcustomrecordband.isfirstofgroup: boolean;
begin
 result:= fvisigrouplink.fieldactive and (isfirstrecord or 
                   (fvisigrouplink.field.asinteger <> fgroupnum));
end;

function tcustomrecordband.islastofgroup: boolean;
begin
 result:= fvisigrouplink.fieldactive and (islastrecord or 
                   (fvisigrouplink.field.asinteger <> fnextgroupnum));
end;

function tcustomrecordband.bandisvisible(const checklast: boolean): boolean;
label
 endlab;
var
 firstrecord,lastrecord: boolean;
 bo1: boolean;
begin
 result:= visible;
 firstrecord:= isfirstrecord;
 lastrecord:= islastrecord;
 if fvisigrouplink.fieldactive then begin
  if (bo_visigroupfirst in foptions) and (firstrecord or 
                  (fvisigrouplink.field.asinteger <> fgroupnum)) or
         (bo_visigrouplast in foptions) and (lastrecord or 
                  (fvisigrouplink.field.asinteger <> fnextgroupnum)) or 
         (bo_visigroupnotfirst in foptions) and not (firstrecord or 
                  (fvisigrouplink.field.asinteger <> fgroupnum)) or
         (bo_visigroupnotlast in foptions) and not(lastrecord or 
                  (fvisigrouplink.field.asinteger <> fnextgroupnum)) then begin
   result:= true;
  end
  else begin
   result:= false;
  end;
 end; 
 if fvisidatalink.fieldactive then begin
  if fvisidatalink.field.isnull then begin
   result:= false;
  end
  else begin
   result:= true;
  end;
 end;
 if checkvisibility(fparentintf,foptionsshow,checklast,result,bo1) then begin
  if firstrecord then begin
   if bos_showfirstrecord in foptionsshow then begin
    result:= true;
    goto endlab;
   end
   else begin
    if bos_hidefirstrecord in foptionsshow then begin
     result:= false;
     bo1:= false;
    end;
   end;
  end;
  if lastrecord then begin
   if bos_showlastrecord in foptionsshow then begin
    result:= true;
    goto endlab;
   end
   else begin
    if bos_hidelastrecord in foptionsshow then begin
     result:= false;
     bo1:= false;
    end;
   end;
  end;
  if not firstrecord and not lastrecord then begin
   if bos_shownormalrecord in foptionsshow then begin
    result:= true;
    goto endlab;
   end
   else begin
    if bos_hidenormalrecord in foptionsshow then begin
     result:= false;
     bo1:= false;
    end;
   end;
  end;
  if bo1 then begin
   result:= true;
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

procedure tcustomrecordband.setnextband(const avalue: tcustomrecordband);
begin
 setlinkedvar(avalue,fnextband);
end;

procedure tcustomrecordband.setnextbandifempty(const avalue: tcustomrecordband);
begin
 setlinkedvar(avalue,fnextbandifempty);
end;

procedure tcustomrecordband.registerchildwidget(const child: twidget);
begin
 inherited;
 if child is tcustombandarea then begin
  additem(pointerarty(fareas),child);
 end;
end;

procedure tcustomrecordband.unregisterchildwidget(const child: twidget);
begin
 removeitem(pointerarty(fareas),child);
 inherited;
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

procedure tcustombandgroup.registerclient(const aclient: ireportclient);
begin
 //dummy, register children only
end;

procedure tcustombandgroup.unregisterclient(const aclient: ireportclient);
begin
 //dummy, register children only
end;

procedure tcustombandgroup.dobeforerender(var empty: boolean);
var
 int1: integer;
 bo1: boolean;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  bo1:= empty;
  fbands[int1].dobeforerender(bo1);
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
     nextrecord;
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
  with fbands[int1] do begin
   updatevisibility;
  end;
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
    if bandisvisible(false) and not (bos_hidelastofpage in foptionsshow) or 
           (bos_showlastofpage in foptionsshow) then begin
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

procedure tcustombandgroup.beginrender(const arestart: boolean);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].beginrender(arestart);
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

procedure tcustombandgroup.adddatasets(var adatasets: datasetarty);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].adddatasets(adatasets);
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

function tcustombandgroup.istopband: boolean;
begin
 result:= fparentintf.istopband;
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

procedure tcustombandgroup.dobeforenextrecord(const adatasource: tdatasource);
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].dobeforenextrecord(adatasource);
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

procedure tcustombandgroup.initpage;
var
 int1: integer;
begin
 inherited;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].initpage;
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

procedure tcustombandarea.registerclient(const aclient: ireportclient);
begin
 //dummy, register children only
end;

procedure tcustombandarea.unregisterclient(const aclient: ireportclient);
begin
 //dummy, register children only
end;

procedure tcustombandarea.setparentwidget(const avalue: twidget);
var
 widget1: twidget;
begin
 if avalue is tcustomrecordband then begin
  frecordband:= tcustomrecordband(avalue);
 end
 else begin
  frecordband:= nil;
 end;
 if avalue is tcustomreportpage then begin
  freportpage:= tcustomreportpage(avalue);
 end
 else begin
  freportpage:= nil;
  widget1:= avalue.parentwidget;
  while widget1 <> nil do begin
   if widget1 is tcustomreportpage then begin
    freportpage:= tcustomreportpage(widget1);
    break;
   end;
   widget1:= widget1.parentwidget;
  end;
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

procedure tcustombandarea.initband;
begin
 factiveband:= 0;
 sortwidgetsyorder(widgetarty(fbands));
 fstate:= fstate - [bas_areafull,bas_backgroundrendered,bas_notfirstband,
                             bas_lastband];
end;

procedure tcustombandarea.initpage;
var
 int1: integer;
begin
 include(fstate,bas_top);
 for int1:= 0 to high(fbands) do begin
  fbands[int1].initpage;
 end;
 initband;
end;

function tcustombandarea.render(const acanvas: tcanvas): boolean;
var                     //true if finished
 bo1,bo2: boolean;
 int1,int2: integer;
begin
 result:= true;
 if not (bas_inited in fstate) then begin
  init;
  dofirstarea;
 end;
 try
//  if frecordband = nil then begin
//   initpage;
//  end;
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
     exclude(fstate,bas_activebandchanged);
     with fbands[factiveband] do begin
      bo2:= odd(fparentintf.reppagenum);
      bo2:= bo2 and (bo_oddpage in foptions) or 
            not bo2 and (bo_evenpage in foptions); //has data
      bo1:= ((rbs_showed in fstate) or not(bo_once in foptions)) and
            (not(rbs_pageshowed in fstate) or not bo2);   //empty    
      render(acanvas,bo1);
      if bas_activebandchanged in self.fstate then begin
       updatevisible;
       continue;
      end;
      bo1:= bo1 or bo2{(bv_everypage in fvisibility)};
//      fstate:= fstate + [rbs_showed,rbs_pageshowed];
      result:= bo1;
//      result:= result and bo1;
      if bo1 then begin //empty
       if fnextbandifempty <> nil then begin
        for int1:= 0 to high(fbands) do begin
         if fbands[int1] = fnextbandifempty then begin
          for int2:= int1 to factiveband do begin
           exclude(fbands[int2].fstate,rbs_showed);
          end;
          factiveband:= int1-1;
          break;
         end;         
        end;
       end;
       repeat
        inc(factiveband);
       until (factiveband > high(fbands)) or fbands[factiveband].visible;
      end
      else begin
       if not (bas_areafull in self.fstate) and (fnextband <> nil) and 
                  not (fdatalink.active and fdatalink.dataset.eof) then begin
        for int1:= 0 to high(fbands) do begin
         if fbands[int1] = fnextband then begin
          for int2:= int1 to factiveband do begin
           exclude(fbands[int2].fstate,rbs_showed);
          end;
          factiveband:= int1;
          while (factiveband <= high(fbands)) and 
                          not fbands[factiveband].visible do begin
           inc(factiveband);
          end;
          break;
         end;         
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 finally
  if result then begin
   exclude(fstate,bas_inited);
  end;
//  exclude(fstate,bas_rendering);
 end;
 if bas_backgroundrendered in fstate then begin
  doafterpaint1(acanvas);
 end;
end;

procedure tcustombandarea.initareapage;
begin
 exclude(fstate,bas_notfirstband);
 include(fstate,bas_top);
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
 if frecordband = nil then begin
  freportpage.beginarea(acanvas,self);
  acanvas.origin:= pos;
 end
 else begin
  acanvas.origin:= forigin;
 end;
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
 pt1: pointty;
begin
 fsaveindex:= acanvas.save;
 bo1:= (bas_backgroundrendered in fstate);
 if not bo1 then begin
  include(fstate,bas_backgroundrendered);
  renderbackground(acanvas);
  initareapage;
 end;
 if frecordband <> nil then begin
  pt1.x:= sender.bounds_x + forigin.x;
  pt1.y:= forigin.y + facty - sender.bounds_y;
 end
 else begin
  pt1:= makepoint(sender.bounds_x+bounds_x,facty);
 end;
 acanvas.origin:= pt1;
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
 exclude(fstate,bas_top);
 sender.fstate:= sender.fstate + [rbs_showed,rbs_pageshowed];
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
 end
 else begin
  if (frecordband <> nil) then begin
   forigin:= canvas.origin;
   render(canvas);
  end;
 end;
end;

function tcustombandarea.rendering: boolean;
begin
 result:= bas_rendering in fstate;
end;

procedure tcustombandarea.beginrender(const arestart: boolean);
var
 int1: integer;
begin
 if arestart then begin
  fstate:= fstate - [bas_notfirstband];
 end
 else begin
  fstate:= [bas_rendering];
 end;
 include(fwidgetstate1,ws1_noclipchildren);
 for int1:= 0 to high(fbands) do begin
  with fbands[int1] do begin
   beginrender(false);
  end;
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

procedure tcustombandarea.adddatasets(var adatasets: datasetarty);
var
 int1: integer;
begin
 for int1:= 0 to high(fbands) do begin
  fbands[int1].adddatasets(adatasets);
 end;
end;

function tcustombandarea.istopband: boolean;
begin
 result:= bas_top in fstate;
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
 if frecordband <> nil then begin
  result:= frecordband.isfirstrecord;
 end
 else begin
  result:= freportpage.isfirstrecord;
 end;
end;

function tcustombandarea.islastrecord: boolean;
begin
 if frecordband <> nil then begin
  result:= frecordband.islastrecord;
 end
 else begin
  result:= freportpage.islastrecord;
 end;
end;

procedure tcustombandarea.dobeforenextrecord(const adatasource: tdatasource);
var
 int1: integer;
begin
 for int1:= 0 to high(fbands) do begin
  fbands[int1].dobeforenextrecord(adatasource);
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

procedure tcustombandarea.restart;
begin
 factiveband:= 0;
 include(fstate,bas_activebandchanged);
 beginrender(true);
 if freportpage <> nil then begin
  freportpage.recordchanged;
 end;
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
 end;
end;

procedure tcustomreportpage.unregisterchildwidget(const child: twidget);
begin
 removeitem(pointerarty(fareas),child);
 inherited;
end;

procedure tcustomreportpage.registerclient(const aclient: ireportclient);
var
 widget1: twidget;
begin
 if finditem(pointerarty(fclients),aclient) < 0 then begin
  additem(pointerarty(fclients),aclient);
 end;
 widget1:= aclient.getwidget;
 if widget1 is tcustomrecordband then begin
  if finditem(pointerarty(fbands),widget1) < 0 then begin
   additem(pointerarty(fbands),widget1);
  end;
 end;
end;

procedure tcustomreportpage.unregisterclient(const aclient: ireportclient);
begin
 removeitem(pointerarty(fclients),aclient);
 removeitem(pointerarty(fbands),aclient.getwidget);
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
 for int1:= 0 to high(fclients) do begin
  fclients[int1].init;
 end;
// for int1:= 0 to high(fareas) do begin
//  fareas[int1].init;
// end;
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

procedure tcustomreportpage.dobeforenextrecord(const adatasource: tdatasource);
var
 int1: integer;
begin
 for int1:= 0 to high(fareas) do begin
  fareas[int1].dobeforenextrecord(adatasource);
 end;
 for int1:= 0 to high(fbands) do begin
  fbands[int1].dobeforenextrecord(adatasource);
 end;
end;

function tcustomreportpage.render(const acanvas: tcanvas): boolean;
var
 int1: integer;
 bo1,bo2,bo3,bo4,bo5: boolean;
 hascustomdata: boolean;
 
 procedure renderband(const aband: tcustomrecordband);
 begin
  with aband do begin
   bo4:= bo5 and (bo2 and (bo_oddpage in foptions) or 
           not bo2 and (bo_evenpage in foptions)); //has data
   bo4:= not(bo4 or ((bo_once in foptions) and not (rbs_showed in fstate)));
                //empty
  
   render(acanvas,bo4);
   bo1:= bo1 and bo4;
  end;
 end;

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
  bo1:= (not fdatalink.active or fdatalink.dataset.eof) and
         not ((rpo_once in foptions) and not (rpps_showed in fstate));
  dobeforerender(bo1);
  bo3:= bo1; //customdata empty
  for int1:= 0 to high(fareas) do begin
   fareas[int1].initpage;
  end;
  for int1:= 0 to high(fbands) do begin
   fbands[int1].initpage;
  end;
  updatevisible;
  for int1:= 0 to high(fareas) do begin
   bo1:= fareas[int1].render(acanvas) and bo1;
  end;
  sortwidgetsyorder(widgetarty(fbands),self);
  bo2:= odd(reppagenum);
//  bo5:= true;
  bo5:= rpps_backgroundrendered in fstate;
  for int1:= 0 to high(fbands) do begin
   if not (fbands[int1] is tcustomrepvaluedisp) then begin
    renderband(fbands[int1]);
   end;
  end;
  bo5:= rpps_backgroundrendered in fstate;
  for int1:= 0 to high(fbands) do begin
   if fbands[int1] is tcustomrepvaluedisp then begin
    renderband(fbands[int1]);
   end;
  end;
  if not (rpps_backgroundrendered in fstate) and not bo3 then begin
   renderbackground(acanvas);  
  end;
              
  if rpps_backgroundrendered in fstate then begin
   doafterpaint1(acanvas);
   if fdatalink.active then begin
    bo1:= false;
    application.lock;
    try
     if canevent(tmethod(fonbeforenextrecord)) then begin
      fonbeforenextrecord(self);
     end;
     dobeforenextrecord(fdatalink.datasource);
     fdatalink.dataset.next;
     if checkislastrecord(fdatalink,@dosyncnextrecord) then begin
      include(fstate,rpps_lastrecord);
     end; 
     if canevent(tmethod(fonafternextrecord)) then begin
      fonafternextrecord(self);
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

procedure tcustomreportpage.dobeforerender(var empty: boolean);
begin
 if canevent(tmethod(fonbeforerender)) then begin
  application.lock;
  try
   fonbeforerender(self,empty);
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
   application.lock;
   try
    dataset.first;
    if checkislastrecord(fdatalink,@dosyncnextrecord) then begin
     include(fstate,rpps_lastrecord);
    end;
   finally
    application.unlock;
   end;
   self.recordchanged;
  end;
 end;
 {
 for int1:= 0 to high(fbands) do begin
  fbands[int1].beginrender;
 end;
 }
 for int1:= 0 to high(fclients) do begin
  fclients[int1].beginrender(false);
 end;
 for int1:= 0 to high(fareas) do begin
  fareas[int1].beginrender(false);
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
 {
 for int1:= 0 to high(fbands) do begin
  fbands[int1].endrender;
 end;
 }
 for int1:= 0 to high(fclients) do begin
  fclients[int1].endrender;
 end;
 for int1:= 0 to high(fareas) do begin
  fareas[int1].endrender;
 end;
end;

procedure tcustomreportpage.adddatasets(var adatasets: datasetarty);
var
 int1: integer;
begin
 if fdatalink.dataset <> nil then begin
  adduniqueitem(pointerarty(adatasets),fdatalink.dataset);
 end;
 for int1:= 0 to high(fclients) do begin
  fclients[int1].adddatasets(adatasets);
 end;
 for int1:= 0 to high(fareas) do begin
  fareas[int1].adddatasets(adatasets);
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
 acanvas.origin:= translatewidgetpoint(sender.pos,sender.parentwidget,self);
 result:= false;
end;

procedure tcustomreportpage.endband(const acanvas: tcanvas;
               const sender: tcustomrecordband);
begin
 acanvas.restore(fsaveindex);
 include(sender.fstate,rbs_showed);
end;

function tcustomreportpage.istopband: boolean;
begin
 result:= false;
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
 for int1:= 0 to high(fclients) do begin
  fclients[int1].updatevisibility;
 end;
 {
 for int1:= 0 to high(fbands) do begin
  fbands[int1].updatevisibility;
 end;
 }
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

procedure tcustomreportpage.restart;
begin
 beginrender;
 recordchanged;
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
{
function tcustomreportpage.isfirstofgroup: boolean;
begin
 result:= false;
end;

function tcustomreportpage.islastofgroup: boolean;
begin
 result:= false;
end;
}
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
 foptions:= defaultreportoptions;
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
var
 bo1: boolean;
begin
 bo1:= csdesigning in componentstate;
 if fthread <> nil then begin
  fthread.terminate;
  application.waitforthread(fthread);
 end;
 fthread.free;
 inherited; //csdesigningflag is removed
 if not bo1 and candestroyevent(tmethod(fondestroyed)) then begin
  fondestroyed(self);
 end;
end;

procedure tcustomreport.beforedestruction;
begin
 if (fstatfile <> nil) and (reo_autowritestat in foptions) and
                 not (csdesigning in componentstate) then begin
  fstatfile.writestat;
 end;
 inherited;
 if candestroyevent(tmethod(fondestroy)) then begin
  fondestroy(self);
 end;
end;

procedure tcustomreport.doloaded;
begin
 if canevent(tmethod(foncreate)) then begin
  foncreate(self);
 end;
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

 function checkterminated: boolean;
 begin
  result:= (thread <> nil) and thread.terminated or fcanceled;
 end;
 
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
//   updateopaque(false);
   for int1:= 0 to high(fwidgets) do begin
    fakevisible(fwidgets[int1],aset);
   end;
  end;
 end;

var
 terminated1: boolean; 
 recnos: integerarty;
 
 procedure dofinish(const islast: boolean);
 var
  int1: integer;
 begin
  application.lock;
  try
   fakevisible(self,false);
   flastpagecount:= fpagenum;
   for int1:= 0 to high(freppages) do begin
    freppages[int1].endrender;
   end;
   terminated1:= checkterminated;
   if islast or (rs_endpass in fstate) or terminated1 then begin
    exclude(fstate,rs_running);
    fstream.free;
    if fprinter <> nil then begin
     fprinter.endprint;
     fprinter.canvas.printorientation:= fdefaultprintorientation;
    end;
    fcanvas.ppmm:= fppmmbefore;
    asyncevent(endrendertag);
    for int1:= 0 to high(fdatasets) do begin
     with fdatasets[int1] do begin
      if active then begin
       try
        recno:= recnos[int1];
       except;
       end;
      end;
      if not (reo_nodisablecontrols in foptions) then begin
       try
        enablecontrols;
       except
       end;
      end;
     end;
    end;
    fdatasets:= nil;
   end;
  finally
   application.unlock;
  end;
 end;

var               
 int1: integer;
 bo1: boolean;
 page1: tcustomreportpage;
 stream1: ttextstream;
 str1: string;
 
begin
 fstate:= [rs_running];
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
 application.lock;
 try
  twindow1(window).setasynccanvas(fcanvas);
 finally
  application.unlock;
 end;
 for int1:= 0 to high(freppages) do begin
  freppages[int1].adddatasets(fdatasets);
 end;
 setlength(recnos,length(fdatasets));
 for int1:= 0 to high(fdatasets) do begin
  with fdatasets[int1] do begin
   if not (reo_nodisablecontrols in foptions) then begin
    disablecontrols;
   end;
   recnos[int1]:= recno;
  end;
 end;
 try
  repeat
   fpagenum:= 0;
   factivepage:= 0;
   fakevisible(self,true);
   try
    if fprinter <> nil then begin
     str1:= '';
     if canevent(tmethod(fonpreamble)) then begin
      application.lock;
      try
       fonpreamble(self,str1);
      finally
       application.unlock;
      end;
     end;
     if rs_endpass in fstate then begin
      if fprinter is tgdiprinter then begin
       with tgdiprinter(fprinter) do begin
        beginprint(false);
       end;
      end
      else begin
       with tstreamprinter(fprinter) do begin
        if fstreamset then begin
         stream1:= fstream;
         fstream:= nil;
         beginprint(stream1,str1);
        end
        else begin
         beginprint(fcommand,str1);
        end;
       end;
      end;
     end
     else begin
      if fprinter is tgdiprinter then begin
       with tgdiprinter(fprinter) do begin
        beginprint(true);
       end;
      end
      else begin
       with tstreamprinter(fprinter) do begin
        beginprint(nil,str1);
       end;
      end;
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
      if page1.visiblepage and not checkterminated then begin
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
 finally
  application.lock;
  try
   twindow1(window).releaseasynccanvas;
  finally
   application.unlock;
  end;
  if {(fthread <> nil) and }(reo_waitdialog in foptions) then begin
   application.terminatewait;
  end;
 end;
end;

procedure tcustomreport.doexec(const sender: tobject);
begin
 exec(nil);
end;

procedure tcustomreport.docancel(const sender: tobject);
begin
 canceled:= true;
end;

procedure tcustomreport.internalrender(const acanvas: tcanvas;
               const aprinter: tcustomprinter; const acommand: string;
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
 fcanceled:= false;
 if reo_nothread in foptions then begin
  application.beginwait;
  try
   if reo_waitdialog in foptions then begin
    application.waitdialog(nil,fdialogtext,fdialogcaption,@docancel,@doexec);
    if not canceled then begin
     application.terminatewait;
    end;
   end
   else begin
    exec(nil);
   end;
  finally
   application.endwait;
  end;
 end
 else begin
  if reo_waitdialog in foptions then begin
   application.resetwaitdialog;
  end;
  fthread:= tmsethread.create({$ifdef FPC}@{$endif}exec);
  if reo_waitdialog in foptions then begin
   application.waitdialog(nil,fdialogtext,fdialogcaption);
   waitfor;
  end;
 end;
end;

procedure tcustomreport.render(const acanvas: tcanvas;
              const onafterrender: reporteventty = nil);
begin
 internalrender(acanvas,nil,'',nil,false,onafterrender);
end;

procedure tcustomreport.render(const aprinter: tstreamprinter;
               const command: string = '';
              const onafterrender: reporteventty = nil);
begin
 internalrender(aprinter.canvas,aprinter,command,nil,false,onafterrender);
end;

procedure tcustomreport.render(const aprinter: tstreamprinter;
               const astream: ttextstream;
              const onafterrender: reporteventty = nil);
begin
 internalrender(aprinter.canvas,aprinter,'',astream,astream = nil,onafterrender);
end;

procedure tcustomreport.render(const aprinter: tgdiprinter;
                                   const onafterrender: reporteventty = nil);
begin
 internalrender(aprinter.canvas,aprinter,'',nil,true,onafterrender);
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
 result:= (fthread <> nil) and 
                (fthread.terminated or ((reo_waitdialog in foptions) and 
                            application.waitcanceled)) or fcanceled;
end;

procedure tcustomreport.setcanceled(const avalue: boolean);
begin
 fcanceled:= fcanceled or avalue;
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
 if running and (fthread <> nil) then begin
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
 if (fthread = nil) and (reo_waitdialog in foptions) and not canceled then begin
  application.processmessages;
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
end;

function tcustomreport.getfont: trepfont;
begin
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

procedure tcustomreport.restart;
var
 int1: integer;
begin
 for int1:= 0 to high(freppages) do begin
  freppages[int1].restart;
 end;
 activepage:= 0;
end;

procedure tcustomreport.recordchanged;
begin
 freppages[factivepage].recordchanged;
end;

{
procedure tcustomreport.notifycontrols;
var
 int1: integer;
begin
 if running then begin
  application.lock;
  try
   for int1:= 0 to high(fdatasets) do begin
    try
     fdatasets[int1].enablecontrols;
    finally
     fdatasets[int1].disablecontrols;
    end;
   end;
  finally
   application.unlock;
  end;
 end;
end;
}
 {treport}
 
constructor treport.create(aowner: tcomponent);
begin
 create(aowner,true);
end;

constructor treport.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstate,cs_ismodule);
 inherited create(aowner);
 if load and not (csdesigning in componentstate) and
          (cs_ismodule in fmsecomponentstate) then begin
  loadmsemodule(self,treport);
  if (fstatfile <> nil) and (reo_autoreadstat in foptions) then begin
   fstatfile.readstat;
  end;
  if canevent(tmethod(fonloaded)) then begin
   fonloaded(self);
  end;
 end;
end;

class function treport.getmoduleclassname: string;
begin
 result:= 'treport';
end;

procedure treport.setstatfile(const avalue: tstatfile);
begin
 setlinkedvar(avalue,tmsecomponent(fstatfile));
end;

{ tcustomrepvaluedisp }

constructor tcustomrepvaluedisp.create(aowner: tcomponent);
begin
 ftextflags:= defaultrepvaluedisptextflags;
 foptionsscale:= defaultrepvaluedispoptionsscale;
 inherited;
 foptions:= defaultrepvaluedispoptions;
 foptionsscale:= defaultrepvaluedispoptionsscale;
 fanchors:= [an_left,an_top];
end;

procedure tcustomrepvaluedisp.dopaint(const acanvas: tcanvas);
begin
 inherited;
 drawtext(acanvas,getdisptext,innerclientrect,ftextflags,font);
end;

procedure tcustomrepvaluedisp.dogettext(var atext: msestring);
begin
 if canevent(tmethod(fongettext)) then begin
  fongettext(self,atext);
 end;
end;

function tcustomrepvaluedisp.getdisptext: msestring;
begin
 result:= name;
 dogettext(result);
end;

procedure tcustomrepvaluedisp.setformat(const avalue: msestring);
begin
 if fformat <> avalue then begin
  fformat:= avalue;
  minclientsizechanged;
 end;
// invalidate;
end;

procedure tcustomrepvaluedisp.settextflags(const avalue: textflagsty);
begin
 if ftextflags <> avalue then begin
  ftextflags:= avalue;
  minclientsizechanged;
 end;
end;

function tcustomrepvaluedisp.calcminscrollsize: sizety;
var
 size1: sizety;
begin
 result:= inherited calcminscrollsize;
 size1:= textrect(getcanvas,getdisptext,innerclientrect,ftextflags,font).size;
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

procedure tcustomrepvaluedisp.render(const acanvas: tcanvas;
               var empty: boolean);
begin
 inherited;
// empty:= true;
end;

{ trepvaluedisp }

procedure trepvaluedisp.setvalue(const avalue: msestring);
begin
// if fvalue <> avalue then begin
  fvalue:= avalue;
  minclientsizechanged;
// end;
end;

function trepvaluedisp.getdisptext: msestring;
begin
 result:= fvalue;
 if (csdesigning in componentstate) and (result = '') then begin
  result:= name;
 end;
 if rendering then begin
  dogettext(result);
 end;
end;

procedure trepvaluedisp.dobeforerender(var empty: boolean);
begin
 inherited;
 minclientsizechanged;
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
  dogettext(result);
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
  dogettext(result);
 end
 else begin
  result:= inherited getdisptext;
 end;
end;

procedure trepprintdatedisp.initpage;
begin
 inherited;
 minclientsizechanged;
end;

procedure trepprintdatedisp.parentchanged;
begin
 inherited;
 minclientsizechanged;
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
(*
{ tcustomreplookupdisp }

constructor tcustomreplookupdisp.create(aowner: tcomponent);
begin
 fkeydatalink:= treplookupdatalink.create(self);
 inherited;
end;

destructor tcustomreplookupdisp.destroy;
begin
 fkeydatalink.free;
 inherited;
end;

procedure tcustomreplookupdisp.setlookupbuffer(const avalue: tcustomlookupbuffer);
begin
 setlinkedvar(avalue,tmsecomponent(flookupbuffer));
 change;
end;

function tcustomreplookupdisp.getdatasource(const aindex: integer): tdatasource;
begin
 result:= keydatasource;
end;

procedure tcustomreplookupdisp.getfieldtypes(out propertynames: stringarty;
               out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= integerfields;
end;

function tcustomreplookupdisp.getkeydatasource: tdatasource;
begin
 result:= fkeydatalink.datasource;
end;

procedure tcustomreplookupdisp.setkeydatasource(const avalue: tdatasource);
begin
 fkeydatalink.datasource:= avalue;
end;

function tcustomreplookupdisp.getkeydatafield: string;
begin
 result:= fkeydatalink.fieldname;
end;

procedure tcustomreplookupdisp.setkeydatafield(const avalue: string);
begin
 fkeydatalink.fieldname:= avalue;
end;

procedure tcustomreplookupdisp.setlookupkeyfieldno(const avalue: integer);
begin
 if avalue <> flookupkeyfieldno then begin
  flookupkeyfieldno:= avalue;
  change;
 end;
end;

procedure tcustomreplookupdisp.setlookupvaluefieldno(const avalue: integer);
begin
 if avalue <> flookupvaluefieldno then begin
  flookupvaluefieldno:= avalue;
  change;
 end;
end;

procedure tcustomreplookupdisp.change;
begin
 minclientsizechanged;
end;

procedure tcustomreplookupdisp.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if (event in [oe_changed,oe_connect]) and (sender = flookupbuffer) then begin
  change;
 end;
end;

procedure tcustomreplookupdisp.settextdefault(const avalue: msestring);
begin
 ftextdefault:= avalue;
 change;
end;

function tcustomreplookupdisp.getdisptext: msestring;
begin
 result:= '';
 if fkeydatalink.fieldactive then begin
  keyvalue:= fkeydatalink.field.asinteger;
  result:= flookuptext;
 end;
 if (result = '') and (csdesigning in componentstate) then begin
  result:= ftextdefault;
  if result = '' then begin
   result:= inherited getdisptext;
  end;
 end
 else begin
  dogettext(result);
 end;
end;

procedure tcustomreplookupdisp.setkeyvalue(const avalue: integer);
begin
 fkeyvalue:= avalue;
 if flookupbuffer <> nil then begin
  flookuptext:= getlookuptext;
 end
 else begin
  flookuptext:= '';
 end;
end;

function tcustomreplookupdisp.getlookuptext: msestring;
begin
 result:= name;
end;

{ treplookupdatalink }

constructor treplookupdatalink.create(const aowner: tcustomreplookupdisp);
begin
 fowner:= aowner;
 inherited create;
end;

procedure treplookupdatalink.recordchanged(afield: tfield);
begin
 if (afield = nil) or (afield = field) then begin
  fowner.change;
 end;
end;

{ trepstringdisplb }

function trepstringdisplb.getlookuptext: msestring;
begin
 result:= flookupbuffer.lookuptext(flookupkeyfieldno,flookupvaluefieldno,
                                            fkeyvalue);
end;

{ trepintegerdisplb }

constructor trepintegerdisplb.create(aowner: tcomponent);
begin
 fbase:= nb_dec;
 fbitcount:= 32;
 inherited;
end;

function trepintegerdisplb.getlookuptext: msestring;
var
 int1: integer;
begin
 int1:= flookupbuffer.lookupinteger(flookupkeyfieldno,flookupvaluefieldno,
                                            fkeyvalue);
 result:= intvaluetostr(int1,fbase,fbitcount)
end;

procedure trepintegerdisplb.setbase(const avalue: numbasety);
begin
 fbase:= avalue;
 change;
end;

procedure trepintegerdisplb.setbitcount(const avalue: integer);
begin
 fbitcount:= avalue;
 change;
end;

{ treprealdisplb }

function treprealdisplb.getlookuptext: msestring;
var
 rea1: realty;
begin
 rea1:= flookupbuffer.lookupfloat(flookupkeyfieldno,flookupvaluefieldno,
                                            fkeyvalue);
 result:= realtytostr(rea1,fformat)
end;

{ trepdatetimedisplb }

constructor trepdatetimedisplb.create(aowner: tcomponent);
begin
 fkind:= dtk_date;
 inherited;
end;

function trepdatetimedisplb.getlookuptext: msestring;
var
 dat1: tdatetime;
begin
 dat1:= flookupbuffer.lookupfloat(flookupkeyfieldno,flookupvaluefieldno,
                                            fkeyvalue);
 if fkind = dtk_time then begin
  result:= mseformatstr.timetostring(dat1,fformat);
 end
 else begin
  result:= mseformatstr.datetimetostring(dat1,fformat);
 end;
end;

procedure trepdatetimedisplb.setkind(const avalue: datetimekindty);
begin
 fkind:= avalue;
 change;
end;
*)
initialization
 registerclass(treport);
end.
