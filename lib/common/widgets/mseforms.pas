{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseforms;
{$ifdef FPC}
 {$mode objfpc}{$h+}{$interfaces corba}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface
uses
 msewidgets,msemenus,msegraphics,mseapplication,msegui,msegraphutils,mseevent,
 msetypes,msestrings,mseglob,mseguiglob,mseguiintf,msedragglob,msepointer,
 msemenuwidgets,msestat,msestatfile,mseclasses,classes,mclasses,msedock,
 msesimplewidgets,msebitmap,typinfo,msesplitter,mseobjectpicker,msetabs,
 mseassistiveclient
 {$ifdef mse_with_ifi},mseifiglob,mseificompglob,mseificomp{$endif};

{$if defined(FPC) and (fpc_fullversion >= 020403)}
 {$define mse_fpc_2_4_3}
{$ifend}

type
 formoptionty = (fo_main,fo_terminateonclose,fo_freeonclose,
               fo_windowclosecancel,
               fo_defaultpos,fo_screencentered,fo_screencenteredvirt,
               fo_transientforcentered,fo_mainwindowcentered,
               fo_modal,fo_createmodal,
               fo_minimized,fo_maximized,fo_fullscreen,fo_fullscreenvirt,
               fo_closeonesc,fo_cancelonesc,fo_closeonenter,fo_closeonf10,
               fo_keycloseifwinonly,fo_nowindowclose,
               fo_globalshortcuts,fo_localshortcuts,
               fo_autoreadstat,fo_delayedreadstat,fo_autowritestat,
               fo_savepos,fo_savezorder,fo_savestate);
 formoptionsty = set of formoptionty;

const
 defaultformoptions = [fo_autoreadstat,fo_autowritestat,
                       fo_savepos,fo_savezorder,fo_savestate];
 defaultmainformoptions = defaultformoptions + [fo_main,fo_terminateonclose];
 defaultmainformoptionswindow = [wo_groupleader,wo_taskbar];

 defaultformwidgetoptions = (defaultoptionswidgetmousewheel -
                 [{ow_mousefocus}{,ow_tabfocus}]) + [ow_subfocus,ow_hinton];
 defaultcontaineroptionswidget = defaultoptionswidgetmousewheel +
                                        [ow_subfocus,ow_mousetransparent];

type
 tcustommseform = class;
 closequeryeventty = procedure(const sender: tcustommseform;
                               var amodalresult: modalresultty) of object;

 tformscrollbox = class(tscrollingwidgetnwr)
          //for internal use only
  private
   procedure readdummy(reader: treader);
   procedure writedummy(writer: twriter);
   procedure readbounds(reader: treader);
   procedure writebounds(writer: twriter);
  protected
   fboundsread: boolean;
   procedure setoptionswidget(const avalue: optionswidgetty); override;
   procedure defineproperties(filer: tfiler); override;
   procedure clientrectchanged; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure docheckautosize;
   function getassistiveflags(): assistiveflagsty override;
  public
   constructor create(aowner: tcustommseform); reintroduce;
   procedure dolayout(const sender: twidget); override;
  published
   property onscroll;
   property onscrolled;
   property onresize;
   property onfontheightdelta;
   property onlayout;
   property oncalcminscrollsize;
   property onchildmouseevent;
   property onmouseevent;
   property onclientmouseevent;
   property onmousewheelevent;
   property onbeforepaint;
   property onpaint;
   property onafterpaint;
   property optionswidget default defaultcontaineroptionswidget;
 end;

 syseventeventty = procedure(const sender: tcustommseform;
                    var aevent: syseventty; var handled: boolean) of object;

 formstatety = (fos_statreading);
 formstatesty = set of formstatety;
 optionsizingty = (osi_left,osi_top,osi_right,osi_bottom);
 optionssizingty = set of optionsizingty;

 tcustommseform = class(tcustomeventwidget,istatfile,idockcontroller
                                 {$ifdef mse_with_ifi},iififormlink{$endif})
  private
   foncreate: notifyeventty;
   foncreated: notifyeventty;
   fonloaded: notifyeventty;
   fondestroyed: notifyeventty;
   foneventloopstart: notifyeventty;
   fondestroy: notifyeventty;
   fonbeforeclosequery: closequeryeventty;
   fonclosequery: closequeryeventty;
   fonclose: notifyeventty;
   fonidle: idleeventty;
   fonterminatequery: terminatequeryeventty;
   fonterminated: notifyeventty;
   fmainmenu: tmainmenu;
   foptions: formoptionsty;
   fstatfile: tstatfile;
   fcaption: msestring;
   fmainmenuwidget: tframemenuwidget;
   foptionswindow: windowoptionsty;
   fonstatread: statreadeventty;
   fonstatafterread: notifyeventty;
   fonstatbeforeread: notifyeventty;
   fonstatafterwrite: notifyeventty;
   fonstatbeforewrite: notifyeventty;
   fonstatupdate: statupdateeventty;
   fstatvarname: msestring;
   fonstatwrite: statwriteeventty;
   fonwidgetactivechanged: widgetchangeeventty;
   fonwindowactivechanged: windowchangeeventty;
   fonwindowdestroyed: windoweventty;
   fonapplicationactivechanged: booleaneventty;
   fonfontheightdelta: fontheightdeltaeventty;
   ficon: tmaskedbitmap;
   ficonchanging: integer;
   fonsysevent: syseventeventty;
   fonsyswindowevent: syseventeventty;
   fonapplicationevent: applicationeventeventty;
   factivatortarget: tactivator;
   fstatpriority: integer;
   ftaborderoverride: ttaborderoverride;
{$ifdef mse_with_ifi}
   fifilink: tififormlinkcomp;
   fwindowopacity: realty;
   function getifilinkkind: ptypeinfo;
   procedure setifilink(const avalue: tififormlinkcomp);
{$endif}
   function getonlayout: notifyeventty;
   procedure setonlayout(const avalue: notifyeventty);
   procedure setmainmenu(const Value: tmainmenu);
   procedure updatemainmenutemplates;
   procedure setoptions(const Value: formoptionsty);
   procedure setoptionswindow(const Value: windowoptionsty);
   procedure setstatfile(const avalue: tstatfile);
   procedure setscrollbox(const avalue: tformscrollbox);
   function getonafterpaint: painteventty;
   function getonbeforepaint: painteventty;
   function getonpaint: painteventty;
   procedure setonafterpaint(const Value: painteventty);
   procedure setonbeforepaint(const Value: painteventty);
   procedure setonpaint(const Value: painteventty);
   procedure seticon(const avalue: tmaskedbitmap);
   procedure registerhandlers;
   procedure unregisterhandlers;
   procedure setonsysevent(const avalue: syseventeventty);
   procedure setonsyswindowevent(const avalue: syseventeventty);
   procedure setonapplicationevent(const avalue: applicationeventeventty);
   procedure readonchildscaled(reader: treader);
   procedure setactivatortarget(const avalue: tactivator);
   procedure settaborderoverride(const avalue: ttaborderoverride);
   procedure setwindowopacity(const avalue: realty);
  protected
   fformstate: formstatesty;
   fscrollbox: tformscrollbox; //needed to distinguish between scrolled and
                               //unscrolled  (mainmenu...) widgets
   function internalgeticon(): tmaskedbitmap; virtual;
   procedure iconchanged(const sender: tobject);
   procedure aftercreate; virtual;
   function createmainmenuwidget: tframemenuwidget; virtual;
   function ismainwindow(): boolean virtual;
   procedure updateoptions; virtual;
   function getoptions: formoptionsty; virtual;
   procedure updatescrollboxrect;
   procedure internalsetwidgetrect(Value: rectty;
                       const windowevent: boolean); override;
   procedure clientrectchanged; override;
   procedure rootchanged(const aflags: rootchangeflagsty) override;
   procedure setparentwidget(const Value: twidget); override;
   procedure updatewindowinfo(var info: windowinfoty); override;
   function isgroupleader: boolean; override;

   procedure readstate(reader: treader); override;
   procedure defineproperties(filer: tfiler); override;
   procedure dooncreate; virtual;
   procedure doafterload; override;
   procedure loaded; override;
   procedure autoreadstat;
   procedure setoptionswidget(const avalue: optionswidgetty); override;
   function nexttaborderoverride(const sender: twidget;
                                      const down: boolean): twidget override;

   function getcaption: msestring;
   procedure setcaption(const Value: msestring); virtual;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
   procedure doeventloopstart; virtual;
   procedure doterminated(const sender: tobject); virtual;
   procedure doterminatequery(var terminate: boolean); virtual;
   procedure doidle(var again: boolean); virtual;
   procedure dowidgetactivechanged(const oldwidget,newwidget: twidget); virtual;
   procedure dowindowactivechanged(const oldwindow,newwindow: twindow); virtual;
   procedure dowindowdestroyed(const awindow: twindow); virtual;
   procedure doapplicationactivechanged(const avalue: boolean); virtual;
   procedure dosysevent(const awindow: winidty; var aevent: syseventty;
                            var handled: boolean); virtual;
   procedure doapplicationevent(var aevent: tmseevent;
                                       var handled: boolean) virtual;
   procedure objectevent(const sender: tobject;
                                       const event: objecteventty); override;
   procedure receiveevent(const event: tobjectevent); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure doshortcut(var info: keyeventinfoty;
                                       const sender: twidget); override;
   procedure windowcreated; override;
   procedure dofontheightdelta(var delta: integer); override;
   procedure widgetregionchanged(const sender: twidget); override;

   function getcontainer: twidget; override;
   function getchildwidgets(const index: integer): twidget; override;
   procedure getautopaintsize(var asize: sizety); override;

   procedure dostatread1(const reader: tstatreader); virtual;
   procedure dostatwrite1(const writer: tstatwriter); virtual;
    //istatfile
   procedure dostatread(const reader: tstatreader); virtual;
   procedure dostatwrite(const writer: tstatwriter); virtual;
   procedure statreading; virtual;
   procedure statread; virtual;
   function getstatvarname: msestring;
   function getstatpriority: integer;
   function getwindowcaption: msestring; virtual;
    //idockcontroller
   function getchildicon: tmaskedbitmap; virtual;
   function checkdock(var info: draginfoty): boolean;
   function getbuttonrects(const index: dockbuttonrectty): rectty;
   function getplacementrect: rectty;
   function getminimizedsize(out apos: captionposty): sizety;
   procedure dolayoutchanged(const sender: tdockcontroller); virtual;
   procedure dodockcaptionchanged(const sender: tdockcontroller); virtual;

   procedure updatelayout(const sender: twidget); virtual;
                               //called from scrollbox.dolayout
    //iassistiveclient
   function getassistivecaption(): msestring override;
    //iificommand
   {$ifdef mse_with_ifi}
   procedure executeificommand(var acommand: ificommandcodety); override;
    //iififormlink
   procedure setmodalresult(const avalue: modalresultty);
   {$endif}

   procedure docreate(aowner: tcomponent); virtual;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean); reintroduce; overload;  virtual;
   destructor destroy; override;
   procedure afterconstruction; override;
   procedure freeinstance override;
   procedure reload(const callafterload: boolean = false);
   procedure writestate(writer: twriter); override;

   procedure insertwidget(const widget: twidget; const apos: pointty); override;
   procedure dolayout(const sender: twidget); override;
   function childrencount: integer; override;

   procedure beforeclosequery(var amodalresult: modalresultty); override;
   procedure doonclose; virtual;
   function canclose(const newfocus: twidget): boolean; override;
   function close(const amodalresult: modalresultty = mr_windowclosed): boolean;
              //true if ok
   procedure beforedestruction; override;
   property optionswidget default defaultformwidgetoptions;
   property optionswindow: windowoptionsty read foptionswindow
                                          write setoptionswindow default [];
   property mainmenu: tmainmenu read fmainmenu write setmainmenu;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property fontempty: twidgetfontempty read getfontempty
                  write setfontempty stored isfontemptystored;
   property options: formoptionsty read getoptions write setoptions
                         default defaultformoptions;

   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority
                                       write fstatpriority default 0;

   property caption: msestring read getcaption write setcaption;
   property icon: tmaskedbitmap read ficon write seticon;
   property windowopacity: realty read fwindowopacity write setwindowopacity;
                //emptyreal -> undefined, 0.0 -> trasparent, 1.0 -> opaque
                //default = emptyreal

   property oncreate: notifyeventty read foncreate write foncreate;
   property oncreated: notifyeventty read foncreated write foncreated;
   property onloaded: notifyeventty read fonloaded write fonloaded;
   property oneventloopstart: notifyeventty read foneventloopstart
                                   write foneventloopstart;
   property ondestroy: notifyeventty read fondestroy write fondestroy;
   property ondestroyed: notifyeventty read fondestroyed write fondestroyed;
   property onbeforeclosequery: closequeryeventty read fonbeforeclosequery
                                        write fonbeforeclosequery;
   property onclosequery: closequeryeventty read fonclosequery
                                        write fonclosequery;
   property onclose: notifyeventty read fonclose write fonclose;
   property onidle: idleeventty read fonidle write fonidle;
   property onterminatequery: terminatequeryeventty read fonterminatequery
                 write fonterminatequery;
   property onterminated: notifyeventty read fonterminated
                 write fonterminated;

   property onbeforepaint: painteventty read getonbeforepaint
                                                        write setonbeforepaint;
   property onpaint: painteventty read getonpaint write setonpaint;
   property onafterpaint: painteventty read getonafterpaint
                                                          write setonafterpaint;

   property onstatupdate: statupdateeventty read fonstatupdate
                                                           write fonstatupdate;
   property onstatread: statreadeventty read fonstatread write fonstatread;
   property onstatbeforeread: notifyeventty read fonstatbeforeread
                                                       write fonstatbeforeread;
   property onstatafterread: notifyeventty read fonstatafterread
                                                       write fonstatafterread;
   property onstatwrite: statwriteeventty read fonstatwrite write fonstatwrite;
   property onstatbeforewrite: notifyeventty read fonstatbeforewrite
                                               write fonstatbeforewrite;
   property onstatafterwrite: notifyeventty read fonstatafterwrite
                                               write fonstatafterwrite;

   property onwidgetactivechanged: widgetchangeeventty
                     read fonwidgetactivechanged write fonwidgetactivechanged;
   property onwindowactivechanged: windowchangeeventty
                      read fonwindowactivechanged write fonwindowactivechanged;
   property onwindowdestroyed: windoweventty read fonwindowdestroyed
                                                      write fonwindowdestroyed;
   property onapplicationactivechanged: booleaneventty
            read fonapplicationactivechanged write fonapplicationactivechanged;

   property onfontheightdelta: fontheightdeltaeventty read fonfontheightdelta
                     write fonfontheightdelta;
   property onlayout: notifyeventty read getonlayout write setonlayout;
   property onsysevent: syseventeventty read fonsysevent write setonsysevent;
   property onsyswindowevent: syseventeventty read fonsyswindowevent
                                         write setonsyswindowevent;
   property onapplicationevent: applicationeventeventty
                         read fonapplicationevent write setonapplicationevent;
  published
   property container: tformscrollbox read fscrollbox write setscrollbox;
{$ifdef mse_with_ifi}
   property ifilink: tififormlinkcomp read fifilink write setifilink;
{$endif}
   property activatortarget: tactivator read factivatortarget
                                             write setactivatortarget;
   property taborderoverride: ttaborderoverride read ftaborderoverride
                                                  write settaborderoverride;
   property onshortcut;
 end;

 custommseformclassty = class of tcustommseform;

 tmseformwidget = class(tcustommseform)
  published
   property optionswidget;
   property optionsskin;
   property optionswindow;
   property mainmenu;
   property color;
   property font;
   property fontempty;
   property options;
   property statfile;
   property statvarname;
   property statpriority;
   property caption;
   property icon;
   property windowopacity;

   property oncreate;
   property oncreated;
   property onloaded;
   property oneventloopstart;
   property ondestroy;
   property ondestroyed;
   property onbeforeclosequery;
   property onclosequery;
   property onclose;
   property onidle;
   property onwidgetactivechanged;
   property onwindowactivechanged;
   property onwindowdestroyed;
   property onapplicationactivechanged;
   property onterminatequery;
   property onterminated;

   property onmouseevent;
   property onclientmouseevent;
   property onchildmouseevent;
   property onmousewheelevent;
   property onkeydown;
   property onkeyup;
   property onshortcut;

   property onbeforepaint;
   property onpaint;
   property onafterpaint;

   property onmove;
   property onresize;
   property onshow;
   property onactivate;
   property onenter;
   property onexit;
   property onfocusedwidgetchanged;
   property ondeactivate;
   property onhide;
   property onevent;
   property oncomponentevent;
   property onasyncevent;

   property onstatupdate;
   property onstatread;
   property onstatbeforeread;
   property onstatafterread;
   property onstatwrite;
   property onstatbeforewrite;
   property onstatafterwrite;

   property onfontheightdelta;
   property onlayout;

   property onsysevent;
   property onsyswindowevent;
   property onapplicationevent;
 end;

 tmseform = class(tmseformwidget)
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
 end;

 tmainform = class(tmseform)
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
   procedure aftercreate; override;
  public
  published
   property options default defaultmainformoptions;
   property optionswindow default defaultmainformoptionswindow;
 end;

 mainformclassty = class of tmainform;
 tcustomdockform = class;

 optiondockformty = (odf_main,odf_childicons,odf_mainchildicon,odf_maintaskbar,
                     odf_mainmainwindow); //is mainwindow if it contains
                                          //an odf_main dock
 optionsdockformty = set of optiondockformty;

const
 defaultoptionsdockform = [odf_childicons,odf_mainchildicon,odf_maintaskbar,
                           odf_mainmainwindow];

type
 tformdockcontroller = class(tnochildrendockcontroller)
  private
   procedure setoptionsdockform(const avalue: optionsdockformty);
  protected
   fowner: tcustomdockform;
   foptionsdockform: optionsdockformty;
   function hasmain(): boolean;
   procedure setoptionsdock(const avalue: optionsdockty); override;
   procedure dolayoutchanged(); override;
   procedure childstatechanged(const sender: twidget;
                           const newstate,oldstate: widgetstatesty); override;
  public
   constructor create(const aowner: tcustomdockform);
   function childicon(): tmaskedbitmap override;
  published
   property optionsdockform: optionsdockformty read foptionsdockform
                     write setoptionsdockform default defaultoptionsdockform;
 end;

 tcustomdockform = class(tcustommseform,idocktarget)
  private
   fdockingareacaption: msestring;
   function getdockcontroller: tdockcontroller;
   procedure setdragdock(const Value: tformdockcontroller);
   function getframe: tgripframe;
   procedure setframe(const avalue: tgripframe);
   procedure setdockingareacaption(const avalue: msestring);
  protected
   fdragdock: tformdockcontroller;
   fhasdocktaskbaricon: boolean;
   function ismainwindow(): boolean override;
   function needsdocktaskbaricon(): boolean;
   procedure updatewindowinfo(var info: windowinfoty) override;
   procedure internalcreateframe; override;
   function internalgeticon(): tmaskedbitmap; override;
   procedure updateoptions; override;
   function getoptions: formoptionsty; override;
   procedure statreading; override;
   procedure statread; override;
   procedure dostatread1(const reader: tstatreader); override;
   procedure dostatwrite1(const writer: tstatwriter); override;
//   procedure dokeydown(var info: keyeventinfoty) override;
   procedure childmouseevent(const sender: twidget;
                          var info: mouseeventinfoty); override;
   procedure statechanged; override;
   procedure poschanged; override;
   procedure activechanged; override;
   procedure doactivate; override;
   procedure parentchanged; override;
   function getwindowcaption: msestring; override;
   procedure dolayoutchanged(const sender: tdockcontroller); override;
   procedure checkdockicon();
   function getchildicon(): tmaskedbitmap; override;
   procedure loaded(); override;
   procedure doenter(); override;
   procedure doexit(); override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
   destructor destroy(); override;
   procedure activate(const abringtofront: boolean = true;
                               const aforce: boolean = false); override;
   function canfocus: boolean; override;
   procedure dragevent(var info: draginfoty); override;
   property dockingareacaption: msestring read fdockingareacaption
                                                   write setdockingareacaption;
  published
   property dragdock: tformdockcontroller read fdragdock write setdragdock;
   property frame: tgripframe read getframe write setframe;
 end;

 tdockformwidget = class(tcustomdockform)
  published
   property optionswidget;
   property optionsskin;
   property optionswindow;
   property mainmenu;
   property color;
   property font;
   property fontempty;
   property options;
   property statfile;
   property statvarname;
   property statpriority;
   property caption;
   property icon;
   property dockingareacaption;

   property oncreate;
   property oncreated;
   property onloaded;
   property oneventloopstart;
   property ondestroy;
   property ondestroyed;
   property onbeforeclosequery;
   property onclosequery;
   property onclose;
   property onidle;
   property onwidgetactivechanged;
   property onwindowactivechanged;
   property onwindowdestroyed;
   property onapplicationactivechanged;
   property onterminatequery;
   property onterminated;

   property onmouseevent;
   property onclientmouseevent;
   property onchildmouseevent;
   property onmousewheelevent;
   property onkeydown;
   property onkeyup;
   property onshortcut;

   property onbeforepaint;
   property onpaint;
   property onafterpaint;

   property onmove;
   property onresize;
   property onshow;
   property onactivate;
   property onenter;
   property onexit;
   property onfocusedwidgetchanged;
   property ondeactivate;
   property onhide;
   property onevent;
   property oncomponentevent;
   property onasyncevent;

   property onstatupdate;
   property onstatread;
   property onstatbeforeread;
   property onstatafterread;
   property onstatwrite;
   property onstatbeforewrite;
   property onstatafterwrite;

   property onfontheightdelta;
   property onlayout;

   property onsysevent;
   property onsyswindowevent;
 end;

 tdockform = class(tdockformwidget)
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
  public
   constructor create(aowner: tcomponent; load: boolean); override;
 end;

 tdockformscrollbox = class(tformscrollbox,idocktarget)
  protected
   procedure clientrectchanged; override;
   procedure widgetregionchanged(const sender: twidget); override;
   procedure dopaintforeground(const acanvas: tcanvas); override;
   function getdockcontroller: tdockcontroller;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure dopaintbackground(const canvas: tcanvas); override;
  public
   constructor create(aowner: tcustomdockform); reintroduce;
 end;

 tsubform = class(tlayouter)
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean);
                                     reintroduce; overload; virtual;
  published
   property onloaded;
 end;

 subformclassty = class of tsubform;

 tscrollboxform = class(tscrollbox)
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
   procedure getchildren(proc: tgetchildproc; root: tcomponent); override;
  public
   constructor create(aowner: tcomponent); overload; override;
   constructor create(aowner: tcomponent; load: boolean);
                                     reintroduce; overload; virtual;
 end;

 scrollboxformclassty = class of tscrollboxform;

 ttabformfonttab = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 ttabformfontactivetab = class(tparentfont)
  public
   class function getinstancepo(owner: tobject): pfont; override;
 end;

 ttabform = class(tmseform,itabpage,iimagelistinfo)
  private
   ftabwidget: tcustomtabwidget;
   fimagelist: timagelist;
   fimagenr: integer;
   fimagenrdisabled: integer;
   fcolortab,fcoloractivetab: colorty;
   ffacetab,ffaceactivetab: tfacecomp;
   ftabhint: msestring;
   ftabnoface: boolean;
   fonselect: notifyeventty;
   fondeselect: notifyeventty;
   finvisible: boolean;
   ffonttab: ttabformfonttab;
   ffontactivetab: ttabformfontactivetab;
   procedure settabwidget(const value: tcustomtabwidget);
   function gettabwidget: tcustomtabwidget;
   function getcolortab: colorty;
   procedure setcolortab(const avalue: colorty);
   function getcoloractivetab: colorty;
   procedure setcoloractivetab(const avalue: colorty);
   function gettabindex: integer;
   procedure settabindex(const avalue: integer);
   function gettabhint: msestring;
   procedure settabhint(const avalue: msestring);
   function gettabnoface: boolean;
   procedure settabnoface(const avalue: boolean);
   function getimagelist: timagelist;
   procedure setimagelist(const avalue: timagelist);
   function getimagenr: imagenrty;
   procedure setimagenr(const avalue: imagenrty);
   function getimagenrdisabled: imagenrty;
   procedure setimagenrdisabled(const avalue: imagenrty);
   function getinvisible: boolean;
   procedure setinvisible(const avalue: boolean);
   function getfonttab: tfont;
   function getfontactivetab: tfont;
   function getfonttab1: ttabformfonttab;
   procedure setfonttab1(const avalue: ttabformfonttab);
   procedure setfonttab(const avalue: tfont);
   function isfonttabstored: boolean;
   function getfontactivetab1: ttabformfontactivetab;
   procedure setfontactivetab1(const avalue: ttabformfontactivetab);
   procedure setfontactivetab(const avalue: tfont);
   function isfontactivetabstored: boolean;
   function getfacetab: tfacecomp;
   procedure setfacetab(const avalue: tfacecomp);
   function getfaceactivetab: tfacecomp;
   procedure setfaceactivetab(const avalue: tfacecomp);
  protected
   class function getmoduleclassname: string; override;
   procedure changed;
   procedure fontchanged1(const sender: tobject);
   procedure visiblechanged; override;
   procedure setcaption(const value: msestring); override;
   procedure doselect; virtual;
   procedure dodeselect; virtual;
   procedure loaded; override;
   procedure objectevent(const sender: tobject;
                                     const event: objecteventty); override;
   class function hasresource: boolean; override;
//   constructor docreate(aowner: tcomponent); override;
   procedure docreate(aowner: tcomponent); override;
   class function classskininfo: skininfoty; override;
  public
   destructor destroy; override;
   procedure createfonttab;
   procedure createfontactivetab;
   function isactivepage: boolean;
   property tabwidget: tcustomtabwidget read ftabwidget;
   property tabindex: integer read gettabindex write settabindex;
  published
   property color default cl_default;
   property colortab: colorty read getcolortab
                                    write setcolortab default cl_default;
   property coloractivetab: colorty read getcoloractivetab
                                    write setcoloractivetab default cl_default;
   property facetab: tfacecomp read getfacetab write setfacetab;
   property faceactivetab: tfacecomp read getfaceactivetab
                                                write setfaceactivetab;
   property fonttab: ttabformfonttab read getfonttab1 write setfonttab1
                                                        stored isfonttabstored;
   property fontactivetab: ttabformfontactivetab read getfontactivetab1
                          write setfontactivetab1 stored isfontactivetabstored;
   property tabhint: msestring read gettabhint write settabhint;
   property tabnoface: boolean read gettabnoface
                                      write settabnoface default false;
   property imagelist: timagelist read getimagelist write setimagelist;
   property imagenr: imagenrty read getimagenr write setimagenr default -1;
   property imagenrdisabled: imagenrty read getimagenrdisabled
                                           write setimagenrdisabled default -2;
                //-2 -> same as imagenr
   property onselect: notifyeventty read fonselect write fonselect;
   property ondeselect: notifyeventty read fondeselect write fondeselect;
   property invisible: boolean read getinvisible write setinvisible default false;
   property visible default false;
   property optionsskin;
 end;

 tabformclassty = class of ttabform;

function createmseform(const aclass: tclass;
                   const aclassname: pshortstring): tmsecomponent;
function createmainform(const aclass: tclass;
                   const aclassname: pshortstring): tmsecomponent;
function createsubform(const aclass: tclass;
                   const aclassname: pshortstring): tmsecomponent;
function createscrollboxform(const aclass: tclass;
                   const aclassname: pshortstring): tmsecomponent;
function createtabform(const aclass: tclass;
                   const aclassname: pshortstring): tmsecomponent;

implementation
uses
 sysutils,mselist,msekeyboard,msebits,msestreaming,
  {$ifdef mse_dynpo}
 msestockobjects_dynpo;
{$else}
 msestockobjects;
{$endif}
const
 containercommonflags: optionswidgetty =
            [ow_arrowfocus,ow_arrowfocusin,ow_arrowfocusout,ow_destroywidgets,
             ow_parenttabfocus,ow_mousewheel{,
             ow_subfocus,ow_mousefocus,ow_tabfocus}];

type
 tcomponent1 = class(tcomponent);
 tmsecomponent1 = class(tmsecomponent);
 twidget1 = class(twidget);
 twindow1 = class(twindow);
 tcustomframe1 = class(tcustomframe);
 treader1 = class(treader);
 tframemenuwidget1 = class(tframemenuwidget);
 tcustomtabwidget1 = class(tcustomtabwidget);
 ttaborderoverride1 = class(ttaborderoverride);


function createmseform(const aclass: tclass;
                    const aclassname: pshortstring): tmsecomponent;

begin
 result:= custommseformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

function createmainform(const aclass: tclass;
                    const aclassname: pshortstring): tmsecomponent;

begin
 result:= tmsecomponent(aclass.newinstance);
{$warnings off}
 tcomponent1(result).setdesigning(true); //used for wo_groupleader
{$warnings on}
 tcustommseform(result).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

function createsubform(const aclass: tclass;
                    const aclassname: pshortstring): tmsecomponent;
begin
 result:= subformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

function createscrollboxform(const aclass: tclass;
                    const aclassname: pshortstring): tmsecomponent;
begin
 result:= scrollboxformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

function createtabform(const aclass: tclass;
                   const aclassname: pshortstring): tmsecomponent;
begin
 result:= tabformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

{ tformscrollbox}

constructor tformscrollbox.create(aowner: tcustommseform);
begin
// fowner:= aowner;
 inherited create(aowner); //dockcontroller needs owner
 setsubcomponent(true);
 exclude(fwidgetstate,ws_iswidget);
 include(fwidgetstate1,ws1_designactive);
 foptionswidget:= defaultcontaineroptionswidget;
// parentwidget:= aowner;
 setlockedparentwidget(aowner);
 name:= 'container';
end;

procedure tformscrollbox.setoptionswidget(const avalue: optionswidgetty);
begin
 if fparentwidget <> nil then begin
  replacebits1(longword(twidget1(fparentwidget).foptionswidget),longword(avalue),
                   longword(containercommonflags));
 end;
 inherited;
end;

procedure tformscrollbox.readdummy(reader: treader);
begin
 reader.driver.skipvalue;
end;

procedure tformscrollbox.writedummy(writer: twriter);
begin
 //dummy
end;

procedure tformscrollbox.readbounds(reader: treader);
var
 rect1: rectty;
begin
 reader.readlistbegin;
 rect1.x:= reader.readinteger;
 rect1.y:= reader.readinteger;
 rect1.cx:= reader.readinteger;
 rect1.cy:= reader.readinteger;
 reader.readlistend;
 widgetrect:= rect1;
 fboundsread:= true;
end;

procedure tformscrollbox.writebounds(writer: twriter);
begin
 writer.writelistbegin;
 writer.writeinteger(fwidgetrect.x);
 writer.writeinteger(fwidgetrect.y);
 writer.writeinteger(fwidgetrect.cx);
 writer.writeinteger(fwidgetrect.cy);
 writer.writelistend;
end;

procedure tformscrollbox.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('bounds_x',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds_y',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds_cx',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds_cy',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds_cxmin',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds_cymax',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('anchors',{$ifdef FPC}@{$endif}readdummy,
                                 {$ifdef FPC}@{$endif}writedummy,false);
 filer.defineproperty('bounds',{$ifdef FPC}@{$endif}readbounds,
                                 {$ifdef FPC}@{$endif}writebounds,true);
end;

procedure tformscrollbox.dolayout(const sender: twidget);
begin
 if owner <> nil then begin
  tcustommseform(owner).updatelayout(sender);
 end;
 inherited;
end;

procedure tformscrollbox.docheckautosize;
begin
 if owner <> nil then begin
  with tcustommseform(owner) do begin
   if optionswidget1 * [ow1_autowidth,ow1_autoheight] <> [] then begin
    checkautosize;
   end;
  end;
 end;
end;

function tformscrollbox.getassistiveflags(): assistiveflagsty;
begin
 result:= inherited getassistiveflags();
 if twidget(owner).ownswindow then begin
  include(result,asf_toplevel);
 end;
end;

procedure tformscrollbox.clientrectchanged;
begin
 inherited;
 docheckautosize;
end;

procedure tformscrollbox.widgetregionchanged(const sender: twidget);
begin
 inherited;
 docheckautosize;
end;

{ tdockformscrollbox }

constructor tdockformscrollbox.create(aowner: tcustomdockform);
begin
 inherited create(aowner);
end;

procedure tdockformscrollbox.clientrectchanged;
begin
 if not (ws_loadlock in fwidgetstate) and (owner <> nil) then begin
  tcustomdockform(owner).fdragdock.beginclientrectchanged;
 end;
 inherited;
 if not (ws_loadlock in fwidgetstate)  and (owner <> nil) then begin
  tcustomdockform(owner).fdragdock.endclientrectchanged;
 end;
end;

procedure tdockformscrollbox.widgetregionchanged(const sender: twidget);
begin
 inherited;
 if not (ws_loadlock in fwidgetstate) and
               not (ws1_updateopaque in twidget1(sender).fwidgetstate1) then begin
  tcustomdockform(owner).fdragdock.widgetregionchanged(sender);
 end;
end;

procedure tdockformscrollbox.dopaintforeground(const acanvas: tcanvas);
begin
 inherited;
 tcustomdockform(owner).fdragdock.dopaint(acanvas);
end;

function tdockformscrollbox.getdockcontroller: tdockcontroller;
begin
 result:= tcustomdockform(owner).fdragdock;
end;

procedure tdockformscrollbox.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 getdockcontroller.checkmouseactivate(self,info);
end;

procedure tdockformscrollbox.dopaintbackground(const canvas: tcanvas);
begin
 inherited;
 with tcustomdockform(owner) do begin
  if fdockingareacaption <> '' then begin
   paintdockingareacaption(canvas,self,fdockingareacaption);
  end;
 end;
end;

{ tcustommseform }

procedure tcustommseform.docreate(aowner: tcomponent);
begin
 inherited create(aowner);
 fwidgetrect.cx:= 100;
 fwidgetrect.cy:= 100;
 if fscrollbox = nil then begin
  fscrollbox:= tformscrollbox.create(self);
 end;
 optionswidget:= defaultformwidgetoptions;
end;

procedure tcustommseform.aftercreate;
begin
 //dummy
end;

constructor tcustommseform.create(aowner: tcomponent; load: boolean);

begin
 ftaborderoverride:= ttaborderoverride.create(self);
 ficon:= tmaskedbitmap.create(bmk_rgb);
 ficon.onchange:= {$ifdef FPC}@{$endif}iconchanged;
 fwindowopacity:= emptyreal;
 fwidgetrect.x:= 100;
 fwidgetrect.y:= 100;
 foptions:= defaultformoptions;
 docreate(aowner);
 aftercreate;
 registerhandlers;
 if load and not (csdesigning in componentstate) and
          (cs_ismodule in fmsecomponentstate) then begin
  loadmsemodule(self,tcustommseform);
 end;
 if not (acs_dooncreatecalled in factstate) then begin
  dooncreate;
 end;
 if not load then begin
//  autoreadstat;
  doafterload;
 end;
 if (fo_createmodal in foptions) and
         (componentstate*[csdesigning,csdestroying,csloading] = []){ and
                                                           showing} then begin
  show(true);
 end;
end;

constructor tcustommseform.create(aowner: tcomponent);
begin
 create(aowner,not (cs_noload in fmsecomponentstate));
end;

destructor tcustommseform.destroy;
var
 bo1: boolean;
begin
 bo1:= csdesigning in componentstate;
 include(fwidgetstate,ws_destroying);
 unregisterhandlers;
 mainmenu:= nil;
 ficon.free;
 fscrollbox.free;
 fmainmenuwidget.free;
 statfile:= nil; //unlink client connection
 inherited; //csdesigningflag is removed
 ftaborderoverride.free();
 if not bo1 and candestroyevent(tmethod(fondestroyed)) then begin
  fondestroyed(self);
 end;
end;

procedure tcustommseform.afterconstruction;
begin
 inherited;
 if assigned(foncreated) then begin
  foncreated(self);
 end;
end;

procedure tcustommseform.beforedestruction;
begin
 inherited;
 if candestroyevent(tmethod(fondestroy)) then begin
  fondestroy(self);
 end;
end;

procedure tcustommseform.unregisterhandlers;
begin
 application.unregisteronterminated({$ifdef FPC}@{$endif}doterminated);
 application.unregisteronterminate({$ifdef FPC}@{$endif}doterminatequery);
 application.unregisteronidle({$ifdef FPC}@{$endif}doidle);
 application.unregisteronwidgetactivechanged(
                            {$ifdef FPC}@{$endif}dowidgetactivechanged);
 application.unregisteronwindowactivechanged(
                                   {$ifdef FPC}@{$endif}dowindowactivechanged);
 application.unregisteronwindowdestroyed(
                                       {$ifdef FPC}@{$endif}dowindowdestroyed);
 application.unregisteronapplicationactivechanged(
       {$ifdef FPC}@{$endif}doapplicationactivechanged);
 if not (csdesigning in componentstate) and
            (assigned(fonsysevent) or assigned(fonsyswindowevent)) then begin
  application.unregistersyseventhandler({$ifdef FPC}@{$endif}dosysevent);
 end;
 if not (csdesigning in componentstate) and
                                 assigned(fonapplicationevent) then begin
  application.unregisterapplicationeventhandler(@doapplicationevent);
 end;
end;

procedure tcustommseform.registerhandlers;
begin
 application.registeronterminated({$ifdef FPC}@{$endif}doterminated);
 application.registeronterminate({$ifdef FPC}@{$endif}doterminatequery);
 application.registeronidle({$ifdef FPC}@{$endif}doidle);
 application.registeronwidgetactivechanged(
                                   {$ifdef FPC}@{$endif}dowidgetactivechanged);
 application.registeronwindowactivechanged(
                                    {$ifdef FPC}@{$endif}dowindowactivechanged);
 application.registeronwindowdestroyed({$ifdef FPC}@{$endif}dowindowdestroyed);
 application.registeronapplicationactivechanged(
       {$ifdef FPC}@{$endif}doapplicationactivechanged);
end;

procedure tcustommseform.dooncreate;
begin
 if not (cs_inheritedloading in msecomponentstate) then begin
  include(factstate,acs_dooncreatecalled);
  if assigned(foncreate) then begin        //csloading possibly set
   beginsuspendgloballoading;
   try
    foncreate(self);
   finally
    endsuspendgloballoading;
   end;
  end;
 end;
end;

procedure tcustommseform.doafterload;
begin
 inherited;
 autoreadstat;
 if canevent(tmethod(fonloaded)) then begin
  fonloaded(self);
 end;
end;

procedure tcustommseform.loaded;
begin
 if (factivatortarget <> nil)  and
                                not (csdesigning in componentstate) then begin
  factivatortarget.activaterecursive();
 end;
 exclude(fscrollbox.fwidgetstate,ws_loadlock);
 if not (csdesigning in componentstate) then begin
  if fo_screencentered in foptions then begin
   window.windowpos:= wp_screencentered;
  end;
  if fo_screencenteredvirt in foptions then begin
   window.windowpos:= wp_screencenteredvirt;
  end;
 end;
 inherited;
 if fmainmenuwidget <> nil then begin
  fmainmenuwidget.visible:= true;
//  fmainmenuwidget.loaded;
//  include(tframemenuwidget1(fmainmenuwidget).fwidgetstate,ws_visible);
 end;
 updateoptions;
 updatemainmenutemplates;
 application.postevent(tobjectevent.create(ek_loaded,ievent(self)){,true});
                        //to the OS queue
end;

procedure tcustommseform.freeinstance;
begin
 if (factivatortarget <> nil)  and
                                not (csdesigning in componentstate) then begin
  try
   factivatortarget.deactivaterecursive;
  finally
   inherited;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tcustommseform.readstate(reader: treader);
var
 bo1: boolean;
begin
 include(fscrollbox.fwidgetstate,ws_loadlock);
 bo1:= false;
{$warnings off}
 with treader1(reader) do begin
{$warnings on}
  if floaded <> nil then begin
   if floaded.IndexOf(fscrollbox) < 0 then begin
    floaded.add(fscrollbox);
{$warnings off}
    tcomponent1(fscrollbox).FComponentState:=
     tcomponent1(fscrollbox).FComponentState + [csloading];
{$warnings on}
   end;
  end;
  bo1:= not (csreading in fscrollbox.componentstate);
  if bo1 then begin
{$warnings off}
   tcomponent1(fscrollbox).FComponentState:=
             tcomponent1(fscrollbox).FComponentState + [csreading];
{$warnings on}
  end;
 end;
 inherited;
 ttaborderoverride1(ftaborderoverride).endread(reader);
 if bo1 then begin
{$warnings off}
  exclude(tcomponent1(fscrollbox).FComponentState,csreading);
{$warnings on}
 end;
 if not (acs_dooncreatecalled in factstate) then begin
  dooncreate;
 end;
end;

procedure tcustommseform.reload(const callafterload: boolean = false);
begin
 name:= '';
 unregisterhandlers;
 try
  reloadmsecomponent(self);
 finally
  registerhandlers;
 end;
 if callafterload then begin
  doafterload;
 end;
end;

procedure tcustommseform.writestate(writer: twriter);
begin
 tscrollboxframe(fscrollbox.frame).scrollpos:= nullpoint;
 inherited;
end;

{$ifdef mse_with_ifi}
procedure tcustommseform.executeificommand(var acommand: ificommandcodety);
begin
 inherited;
 case acommand of
  icc_close: begin
   application.postevent(tobjectevent.create(ek_closeform,ievent(self)));
  end;
  else; // Added to make compiler happy
 end;
end;

procedure tcustommseform.setmodalresult(const avalue: modalresultty);
begin
 window.modalresult:= avalue;
end;

function tcustommseform.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iififormlink);
end;

procedure tcustommseform.setifilink(const avalue: tififormlinkcomp);
begin
 mseificomp.setifilinkcomp(iififormlink(self),avalue,tifilinkcomp(fifilink));
end;

{$endif}

procedure tcustommseform.beforeclosequery(var amodalresult: modalresultty);
begin
 inherited;
 if canevent(tmethod(fonbeforeclosequery)) then begin
  fonbeforeclosequery(self,amodalresult);
 end;
 if (amodalresult = mr_windowclosed) and
                              (fo_windowclosecancel in foptions) then begin
  amodalresult:= mr_cancel;
 end;
end;

procedure tcustommseform.doonclose;
begin
 if canevent(tmethod(fonclose)) then begin
  fonclose(self);
 end;
end;

function tcustommseform.canclose(const newfocus: twidget): boolean;
var
 modres: modalresultty;
begin
 result:= inherited canclose(newfocus);
 if result and (newfocus = nil) and ((fwindow = nil) or
                  not (tws_candefocus in fwindow.state)) then begin
  modres:= twindow1(window).fmodalresult;
  if (modres = mr_windowclosed) and (fo_nowindowclose in foptions) then begin
   result:= false;
   exit;
  end;
  if modres = mr_none then begin
   modres:= mr_canclose;
  end;
  if canevent(tmethod(fonclosequery)) then begin
   fonclosequery(self,modres);
  end;
 {$ifdef mse_with_ifi}
  if fifiserverintf <> nil then begin
   fifiserverintf.closequery(iificlient(self),modres);
  end;
 {$endif}
  result:= modres <> mr_none;
//  if twindow1(window).fmodalresult <> mr_canclose then begin
  if modres <> mr_canclose then begin
   twindow1(window).fmodalresult:= modres;
  end;
  if result and ((twindow1(window).fmodalresult <> mr_none) or
    (application.terminating) or (ws1_forceclose in fwidgetstate1)) then begin
   doonclose;
 {$ifdef mse_with_ifi}
   if fifiserverintf <> nil then begin
    fifiserverintf.sendmodalresult(iificlient(self),window.modalresult);
   end;
 {$endif}
   if (fo_terminateonclose in foptions) and not application.terminating and
                  not (csdesigning in componentstate) then begin
    result:= application.terminate(window);
   end;
   if result and (fstatfile <> nil) and (fo_autowritestat in foptions) and
                               not (csdesigning in componentstate) then begin
    fstatfile.writestat;
   end;
   if result and (fo_freeonclose in foptions) and
             not (csdesigning in componentstate) then begin
    release;
   end;
  end;
 end;
end;

function tcustommseform.close(
        const amodalresult: modalresultty = mr_windowclosed): boolean;
                //simulates mr_windowclose, true if ok
begin
 if ownswindow then begin
  result:= window.close(amodalresult);
 end
 else begin
  result:= simulatemodalresult(self,amodalresult);
 end;
end;

procedure tcustommseform.doterminated(const sender: tobject);
begin
 if canevent(tmethod(fonterminated)) then begin
  fonterminated(sender);
 end;
end;

procedure tcustommseform.doterminatequery(var terminate: boolean);
begin
 if canevent(tmethod(fonterminatequery)) then begin
  fonterminatequery(terminate);
 end;
end;

procedure tcustommseform.doidle(var again: boolean);
begin
 if canevent(tmethod(fonidle)) then begin
  fonidle(again);
 end;
end;

procedure tcustommseform.dowidgetactivechanged(const oldwidget,
                                                      newwidget: twidget);
begin
 if canevent(tmethod(fonwidgetactivechanged)) then begin
  fonwidgetactivechanged(oldwidget,newwidget);
 end;
end;

procedure tcustommseform.dowindowactivechanged(const oldwindow,
                                                      newwindow: twindow);
begin
 if canevent(tmethod(fonwindowactivechanged)) then begin
  fonwindowactivechanged(oldwindow,newwindow);
 end;
end;

procedure tcustommseform.dowindowdestroyed(const awindow: twindow);
begin
 if canevent(tmethod(fonwindowdestroyed)) then begin
  fonwindowdestroyed(awindow);
 end;
end;

procedure tcustommseform.doapplicationactivechanged(const avalue: boolean);
begin
 if canevent(tmethod(fonapplicationactivechanged)) then begin
  fonapplicationactivechanged(avalue);
 end;
end;

procedure tcustommseform.getchildren(proc: tgetchildproc; root: tcomponent);
begin
 inherited;
 fscrollbox.getchildren(proc,root);
 getcompchildren(proc,root);
end;

procedure tcustommseform.setoptionswidget(const avalue: optionswidgetty);
begin
 inherited;
 replacebits1(longword(fscrollbox.foptionswidget),longword(avalue),
                   longword(containercommonflags));
end;

function tcustommseform.nexttaborderoverride(const sender: twidget;
               const down: boolean): twidget;
begin
 result:= ftaborderoverride.nexttaborder(sender,down);
 if result = nil then begin
  result:= inherited nexttaborderoverride(sender,down);
 end;
end;

procedure tcustommseform.doeventloopstart;
begin
 if (fstatfile <> nil) and not (csdesigning in componentstate) and
       (foptions*[fo_autoreadstat,fo_delayedreadstat] =
        [fo_autoreadstat,fo_delayedreadstat]) then begin
  fstatfile.readstat;
 end;
 if canevent(tmethod(foneventloopstart)) then begin
  foneventloopstart(self);
 end;
end;

procedure tcustommseform.receiveevent(const event: tobjectevent);
var
 rect1: rectty;
begin
 inherited;
 case event.kind of
  ek_loaded: begin
   doeventloopstart;
   if (fo_modal in foptions) and
          (componentstate*[csloading,csdesigning] = []){ and showing}  then begin
    show(true);
   end;
  end;
  ek_closeform: begin
   close;
  end;
  ek_checkscreenrange: begin
   if ownswindow and visible and (window.windowpos = wp_normal) then begin
    rect1:= window.decoratedwidgetrect;
    if clipinrect1(rect1,application.screenrect) then begin
     window.decoratedwidgetrect:= rect1;
    end;
   end;
  end;
  else; // Added to make compiler happy
 end;
end;

function tcustommseform.getonlayout: notifyeventty;
begin
 result:= fscrollbox.onlayout;
end;

procedure tcustommseform.setonlayout(const avalue: notifyeventty);
begin
 fscrollbox.onlayout:= avalue;
end;

procedure tcustommseform.updatemainmenutemplates;
begin
// if not (csloading in componentstate) then begin
  if (fmainmenuwidget <> nil) and
                     (fmainmenu <> nil) then begin
   fmainmenuwidget.assigntemplate(fmainmenu.template);
  end;
  updatescrollboxrect;
// end;
end;

function tcustommseform.createmainmenuwidget: tframemenuwidget;
begin
 result:= tframemenuwidget.create(self,fmainmenu);
end;

procedure tcustommseform.setmainmenu(const Value: tmainmenu);
begin
 if value <> fmainmenu then begin
  freeandnil(fmainmenuwidget);
  setlinkedvar(value,tmsecomponent(fmainmenu));
  if value <> nil then begin
   fmainmenuwidget:= createmainmenuwidget;
{$warnings off}
   twidget1(fmainmenuwidget).setdesigning(csdesigning in componentstate);
{$warnings on}
   updatemainmenutemplates;
  end
  else begin
   updatescrollboxrect;
  end;
 end;
end;

procedure tcustommseform.objectevent(const sender: tobject;
                                         const event: objecteventty);
begin
 if sender = fmainmenu then begin
  case event of
   oe_destroyed: begin
    setmainmenu(nil);
   end;
   oe_changed: begin
    if not (csdestroying in componentstate) then begin
     updatemainmenutemplates;
     if fmainmenuwidget <> nil then begin
      fmainmenuwidget.menuchanged(nil);
     end;
    end;
   end;
   else; // Added to make compiler happy
  end;
 end;
 inherited;
end;

procedure tcustommseform.setoptions(const Value: formoptionsty);
{$ifndef FPC}
const
 mask1: formoptionsty = [fo_screencentered,fo_screencenteredvirt,
                         fo_transientforcentered,fo_mainwindowcentered,
                         fo_defaultpos];
 mask2: formoptionsty = [fo_closeonesc,fo_cancelonesc];
 mask3: formoptionsty = [fo_maximized,fo_minimized,fo_fullscreen,
                         fo_fullscreenvirt];
 mask4: formoptionsty = [fo_modal,fo_createmodal];
{$endif}
//var
// opt1,opt2: formoptionsty;
begin
 if foptions <> value then begin
 {$ifdef FPC}
  foptions:= formoptionsty(setsinglebit(longword(value),longword(foptions),
   [longword([fo_screencentered,fo_screencenteredvirt,
              fo_transientforcentered,fo_mainwindowcentered,fo_defaultpos]),
    longword([fo_closeonesc,fo_cancelonesc]),
    longword([fo_maximized,fo_minimized,fo_fullscreen,fo_fullscreenvirt]),
    longword([fo_modal,fo_createmodal])
   ]));
 {$else}
  foptions:= formoptionsty(setsinglebitar32(longword(value),longword(foptions),
   [longword(mask1),longword(mask2),longword(mask3),longword(mask4)]));
 {$endif}
(*
  opt1:= formoptionsty(setsinglebit(
       {$ifdef FPC}longword{$else}longword{$endif}(value),
       {$ifdef FPC}longword{$else}longword{$endif}(foptions),
       {$ifdef FPC}longword{$else}longword{$endif}(mask2)));
  opt2:= formoptionsty(setsinglebit(
       {$ifdef FPC}longword{$else}longword{$endif}(value),
       {$ifdef FPC}longword{$else}longword{$endif}(foptions),
       {$ifdef FPC}longword{$else}longword{$endif}(mask3)));
  foptions:= formoptionsty(setsinglebit(
       {$ifdef FPC}longword{$else}longword{$endif}(value),
       {$ifdef FPC}longword{$else}longword{$endif}(foptions),
       {$ifdef FPC}longword{$else}longword{$endif}(mask1)));
  foptions:= formoptionsty(replacebits(
       {$ifdef FPC}longword{$else}longword{$endif}(opt1),
       {$ifdef FPC}longword{$else}longword{$endif}(foptions),
       {$ifdef FPC}longword{$else}longword{$endif}(mask2)));
  foptions:= formoptionsty(replacebits(
       {$ifdef FPC}longword{$else}longword{$endif}(opt2),
       {$ifdef FPC}longword{$else}longword{$endif}(foptions),
       {$ifdef FPC}longword{$else}longword{$endif}(mask3)));
*)
  updateoptions;
 end;
end;

function tcustommseform.ismainwindow(): boolean;
begin
 result:= (fo_main in foptions) and not (csdesigning in componentstate);
end;

procedure tcustommseform.updateoptions;
begin
 if (componentstate * [csloading,csdestroying,csdesigning] = []) and
                                             (window.owner = self)  then begin
  fwindow.globalshortcuts:= fo_globalshortcuts in foptions;
  fwindow.localshortcuts:= fo_localshortcuts in foptions;
  if ismainwindow() then begin
   application.mainwindow:= fwindow;
  end;
  if fo_fullscreen in foptions then begin
   fwindow.windowpos:= wp_fullscreen;
  end
  else begin
   if fo_maximized in foptions then begin
    fwindow.windowpos:= wp_maximized;
   end
   else begin
    if fo_minimized in foptions then begin
     fwindow.windowpos:= wp_minimized;
    end
    else begin
     if fo_screencentered in foptions then begin
      fwindow.windowpos:= wp_screencentered;
     end
     else begin
      if fo_transientforcentered in foptions then begin
       fwindow.windowpos:= wp_transientforcentered;
      end
      else begin
       if fo_mainwindowcentered in foptions then begin
        fwindow.windowpos:= wp_mainwindowcentered;
       end
       else begin
        if fo_defaultpos in foptions then begin
         fwindow.windowpos:= wp_default;
        end;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function tcustommseform.getoptions: formoptionsty;
begin
 result:= foptions;
end;

procedure tcustommseform.setoptionswindow(const Value: windowoptionsty);
const
 mask1: windowoptionsty = [wo_taskbar,wo_notaskbar];
begin
 foptionswindow:= windowoptionsty(setsinglebit(
                    {$ifdef FPC}longword{$else}longword{$endif}(value),
                    {$ifdef FPC}longword{$else}longword{$endif}(foptionswindow),
                    {$ifdef FPC}longword{$else}longword{$endif}(mask1)));
end;

procedure tcustommseform.setstatfile(const avalue: tstatfile);
begin
 setstatfilevar(istatfile(self),avalue,fstatfile);
end;

function tcustommseform.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tcustommseform.dostatread1(const reader: tstatreader);
var
 rect1{,rect2}: rectty;
 str1: string;
 widget1: twidget;
begin
 if fo_savepos in foptions then begin
  rect1:= widgetrect;
  with rect1 do begin
   x:= reader.readinteger('x',x);
   y:= reader.readinteger('y',y);
   cx:= reader.readinteger('cx',cx,0);
   cy:= reader.readinteger('cy',cy,0);
  end;
//  setclippedwidgetrect(rect1);
  rect1:= clipinrect(rect1,application.screenrect); //shift into screen
  widgetrect:= rect1;
  application.postevent(tobjectevent.create(ek_checkscreenrange,ievent(self)));
 end;
 if fo_savezorder in foptions then begin
  str1:= '~';
  str1:= reader.readstring('stackedunder',str1);
  if str1 <> '~' then begin
   if trim(str1) = '' then begin
    window.stackunder(nil);
   end
   else begin
    if application.findwidget(str1,widget1) and (widget1 <> nil) then begin
     window.stackunder(widget1.window);
    end;
   end;
  end;
 end;
end;

procedure tcustommseform.dostatread(const reader: tstatreader);
var
 bo1: boolean;
 pos1: windowposty;
begin
 if canevent(tmethod(fonstatupdate)) then begin
  fonstatupdate(self,reader);
 end;
 if canevent(tmethod(fonstatread)) then begin
  fonstatread(self,reader);
 end;
 dostatread1(reader);
 if fparentwidget = nil then begin
  with reader do begin
   if fo_savestate in foptions then begin
    pos1:= windowposty(readinteger('wsize',ord(window.windowpos),0,
                              ord(high(windowposty))));
    bo1:= readboolean('visible',visible);
    bo1:= visible or bo1;
    if fo_main in foptions then begin
     bo1:= true;
     if pos1 = wp_minimized then begin
      pos1:= wp_normal;
     end;
    end;
    if bo1 then begin
     if pos1 <> wp_minimized then begin
      show;
     end;
     window.windowpos:= pos1; //does not work with kde and invisible window
    end;
    if readboolean('active',active) then begin
     application.postevent(tobjectevent.create(ek_activate,ievent(self)));
                        //to the OS queue
//     activate;
    end;
   end;
  end;
 end;
end;

procedure tcustommseform.statreading;
begin
 include(fformstate,fos_statreading);
 if canevent(tmethod(fonstatbeforeread)) then begin
  fonstatbeforeread(self);
 end;
end;

procedure tcustommseform.statread;
begin
 exclude(fformstate,fos_statreading);
 if canevent(tmethod(fonstatafterread)) then begin
  fonstatafterread(self);
 end;
end;

procedure tcustommseform.dostatwrite1(const writer: tstatwriter);
var
 window1: twindow;
begin
 if fparentwidget = nil then begin
  if fo_savezorder in foptions then begin
   window1:= window.stackedunder;
   if window1 <> nil then begin
    writer.writestring('stackedunder',ownernamepath(window1.owner));
   end
   else begin
    writer.writestring('stackedunder','');
   end;
  end;
  if  fo_savepos in foptions then begin
   with window.normalwindowrect do begin
    writer.writeinteger('x',x);
    writer.writeinteger('y',y);
    writer.writeinteger('cx',cx);
    writer.writeinteger('cy',cy);
   end;
  end;
 end;
end;

procedure tcustommseform.dostatwrite(const writer: tstatwriter);
begin
 if assigned(fonstatbeforewrite) then begin
  fonstatbeforewrite(self);
 end;
 if assigned(fonstatupdate) then begin
  fonstatupdate(self,writer);
 end;
 if assigned(fonstatwrite) then begin
  fonstatwrite(self,writer);
 end;
 dostatwrite1(writer);
 if fparentwidget = nil then begin
  with writer do begin
   if fo_savestate in foptions then begin
    writeinteger('wsize',ord(window.windowpos));
    writeboolean('active',active);
    writeboolean('visible',visible);
   end;
  end;
 end;
 if assigned(fonstatafterwrite) then begin
  fonstatafterwrite(self);
 end;
end;

procedure tcustommseform.updatescrollboxrect;
var
 rect1: rectty;
begin
 if not (ws_destroying in fwidgetstate) and
                       (not (csloading in componentstate) or
                        not fscrollbox.fboundsread) then begin
  rect1:= innerwidgetrect;
  if fmainmenuwidget <> nil then begin
   with tframemenuwidget1(fmainmenuwidget) do begin
    setwidgetrect(makerect(self.paintpos,makesize(
                                        self.paintsize.cx,bounds_cy)));
    updatelayout();
    inc(rect1.y,bounds_cy);
    dec(rect1.cy,bounds_cy);
   end;
  end;
  if fscrollbox <> nil then begin
   fscrollbox.setwidgetrect(rect1);
  end;
 end;
end;

procedure tcustommseform.internalsetwidgetrect(Value: rectty;
                       const windowevent: boolean);
begin
 inherited;
 if csloading in componentstate then begin
  updatescrollboxrect; //no clientrectchanged
 end;
end;

procedure tcustommseform.clientrectchanged;
begin
 inherited;
 updatescrollboxrect;
end;

procedure tcustommseform.updatewindowinfo(var info: windowinfoty);
begin
 inherited;
 info.options:= foptionswindow;
 if csdesigning in componentstate then begin
  exclude(info.options,wo_groupleader);
 end;
 if fo_maximized in foptions then begin
  info.initialwindowpos:= wp_maximized;
 end
 else begin
  if fo_minimized in foptions then begin
   info.initialwindowpos:= wp_minimized;
  end
  else begin
   if fo_defaultpos in foptions then begin
    info.initialwindowpos:= wp_default;
   end;
  end;
 end;
 getwindowicon(ficon,info.icon,info.iconmask);
end;

procedure tcustommseform.rootchanged(const aflags: rootchangeflagsty);
begin
 inherited;
 if (rcf_windowset in aflags) and
        (foptions * [fo_main,fo_globalshortcuts] =
                             [fo_main,fo_globalshortcuts]) then begin
  window.globalshortcuts:= true;
 end;
end;

procedure tcustommseform.setparentwidget(const Value: twidget);
begin
 if (value = nil) and (fparentwidget <> nil) and (fwindow <> nil) and
        (foptions * [fo_main,fo_globalshortcuts] =
                             [fo_main,fo_globalshortcuts]) then begin
  fwindow.globalshortcuts:= false; //restore
 end;
 if fframe <> nil then begin
  exclude(tcustomframe1(fframe).fstate,fs_rectsvalid);
 end;
 inherited;
end;

function tcustommseform.isgroupleader: boolean;
begin
 result:= (wo_groupleader in foptionswindow) or (fo_main in foptions);
end;

procedure tcustommseform.insertwidget(const widget: twidget; const apos: pointty);
begin
// if not (csloading in widget.componentstate) then begin
 if not (csloading in componentstate) then begin
  fscrollbox.insertwidget(widget,subpoint(apos,fscrollbox.fwidgetrect.pos));
 end
 else begin
  fscrollbox.insertwidget(widget,apos);
 end;
end;

function tcustommseform.getcontainer: twidget;
begin
 result:= fscrollbox;
end;

function tcustommseform.getchildwidgets(const index: integer): twidget;
begin
 result:= fscrollbox.getchildwidgets(index);
end;

function tcustommseform.childrencount: integer;
begin
 result:= fscrollbox.childrencount;
end;

procedure tcustommseform.dolayout(const sender: twidget);
begin
 inherited;
 if (fmainmenuwidget <> nil) and (fmainmenuwidget = sender) then begin
  updatescrollboxrect;
 end;
end;

function tcustommseform.checkdock(var info: draginfoty): boolean;
begin
 result:= true;
end;

function tcustommseform.getbuttonrects(const index: dockbuttonrectty): rectty;
begin
 if fframe = nil then begin
  if index = dbr_handle then begin
   result:= clientrect;
  end
  else begin
   result:= nullrect;
  end;
 end
 else begin
  result:= tgripframe(fframe).buttonrects[index];
 end;
end;

function tcustommseform.getplacementrect: rectty;
begin
 with fscrollbox do begin
  result:= paintrect;
  deflaterect1(result,tcustomframe1(fframe).fi.innerframe);
  addpoint1(result.pos,clientpos); //???
 end;
end;

function tcustommseform.getminimizedsize(out apos: captionposty): sizety;
begin
 if fframe = nil then begin
  result:= nullsize;
 end
 else begin
  result:= tgripframe(fframe).getminimizedsize(apos);
 end;
end;

function tcustommseform.getcaption: msestring;
begin
 result:= fcaption;
end;

procedure tcustommseform.setcaption(const Value: msestring);
begin
 fcaption := Value;
 if ownswindow then begin
  window.caption:= fcaption;
 end;
end;

function tcustommseform.getwindowcaption: msestring;
begin
 result:= fcaption;
end;

function tcustommseform.getchildicon: tmaskedbitmap;
begin
 result:= nil;
 if not (csdestroying in componentstate) then begin
  if ficon.hasimage then begin
   result:= ficon;
  end;
 end;
end;

procedure tcustommseform.windowcreated;
var
 mstr1: msestring;
begin
 inherited;
 mstr1:= getwindowcaption;
 if mstr1 <> '' then begin
  window.caption:= mstr1;
 end;
 if fwindowopacity <> emptyreal then begin
  window.opacity:= fwindowopacity;
 end;
// if fcaption <> '' then begin
//  caption:= fcaption;                //set windowcaption
// end;
end;

procedure tcustommseform.dofontheightdelta(var delta: integer);
begin
 if canevent(tmethod(fonfontheightdelta)) then begin
  fonfontheightdelta(self,delta);
 end;
end;

procedure tcustommseform.dokeydown(var info: keyeventinfoty);
var
 modres1: modalresultty;
begin
 inherited;
 with info do begin
  if not (es_processed in eventstate) and
    (shiftstate * shiftstatesrepeatmask = []) and
    (not (fo_keycloseifwinonly in foptions) or (fparentwidget = nil)) and
    (((fo_closeonesc in foptions) or (fo_cancelonesc in foptions)) and
      (key = key_escape) or
      (fo_closeonf10 in foptions) and (key = key_f10) or
      (fo_closeonenter in foptions) and isenterkey(self,key))  then begin
   include(eventstate,es_processed);
   if key = key_f10 then begin
    modres1:= mr_f10;
   end
   else begin
    if key = key_escape then begin
     if fo_cancelonesc in foptions then begin
      modres1:= mr_cancel;
     end
     else begin
      modres1:= mr_escape;
     end;
    end
    else begin
     modres1:= mr_ok;
    end;
   end;
   close(modres1);
  end;
 end;
end;

procedure tcustommseform.doshortcut(var info: keyeventinfoty; const sender: twidget);
begin
 if not (es_processed in info.eventstate) then begin
  if (fmainmenu <> nil) and not ((csdesigning) in componentstate) then begin
   fmainmenu.doshortcut(info);
  end;
  if not (es_processed in info.eventstate) then begin
   inherited;
//   if not info.processed and (fmainmenuwidget <> nil) and (info.shiftstate = [ss_alt]) then begin
//    fmainmenuwidget.keydown
//   end;
  end;
 end;
end;
{
function tcustommseform.getframe: tgripframe;
begin
 result:= tgripframe(inherited getframe);
end;

procedure tcustommseform.setframe(const Value: tgripframe);
begin
 inherited setframe(value);
end;
}
{
function tcustommseform.getframescrollbox: tscrollboxframe;
begin
 result:= fscrollbox.frame;
end;

procedure tcustommseform.setframescrollbox(const Value: tscrollboxframe);
begin
 fscrollbox.frame:= value;
end;
}
procedure tcustommseform.setscrollbox(const avalue: tformscrollbox);
begin
 fscrollbox.Assign(avalue);
end;

function tcustommseform.getonbeforepaint: painteventty;
begin
 result:= fscrollbox.onbeforepaint;
end;

procedure tcustommseform.setonbeforepaint(const Value: painteventty);
begin
 fscrollbox.onbeforepaint:= value;
end;

function tcustommseform.getonpaint: painteventty;
begin
 result:= fscrollbox.onpaint;
end;

procedure tcustommseform.setonpaint(const Value: painteventty);
begin
 fscrollbox.onpaint:= value;
end;

function tcustommseform.getonafterpaint: painteventty;
begin
 result:= fscrollbox.onafterpaint;
end;

procedure tcustommseform.setonafterpaint(const Value: painteventty);
begin
 fscrollbox.onafterpaint:= value;
end;

procedure tcustommseform.seticon(const avalue: tmaskedbitmap);
begin
 ficon.assign(avalue);
end;

procedure tcustommseform.setwindowopacity(const avalue: realty);
begin
 fwindowopacity:= avalue;
 if ownswindow then begin
  window.opacity:= avalue;
 end;
end;

procedure tcustommseform.iconchanged(const sender: tobject);
var
 icon1,mask1: pixmapty;
begin
 if ficonchanging = 0 then begin
  inc(ficonchanging);
  if ownswindow then begin
   getwindowicon(internalgeticon(),icon1,mask1);
   gui_setwindowicon(window.winid,icon1,mask1);
   if (fo_main in foptions) and not (csdesigning in componentstate) then begin
    gui_setapplicationicon(icon1,mask1);
   end;
  end;
  dec(ficonchanging);
 end;
end;

procedure tcustommseform.widgetregionchanged(const sender: twidget);
begin
 inherited;
 if (fmainmenuwidget <> nil) and (sender = fmainmenuwidget) then begin
  updatescrollboxrect;
 end;
end;

procedure tcustommseform.setonsysevent(const avalue: syseventeventty);
begin
 if not (csdesigning in componentstate) then begin
  if assigned(avalue) then begin
   if not assigned(fonsysevent) and not assigned(fonsyswindowevent) then begin
    application.registersyseventhandler({$ifdef FPC}@{$endif}dosysevent);
   end;
  end
  else begin
   if assigned(fonsysevent) and not assigned(fonsyswindowevent) then begin
    application.unregistersyseventhandler({$ifdef FPC}@{$endif}dosysevent);
   end;
  end;
 end;
 fonsysevent:= avalue;
end;

procedure tcustommseform.setonsyswindowevent(const avalue: syseventeventty);
begin
 if not (csdesigning in componentstate) then begin
  if assigned(avalue) then begin
   if not assigned(fonsysevent) and not assigned(fonsyswindowevent) then begin
    application.registersyseventhandler({$ifdef FPC}@{$endif}dosysevent);
   end;
  end
  else begin
   if assigned(fonsyswindowevent) and not assigned(fonsysevent) then begin
    application.unregistersyseventhandler({$ifdef FPC}@{$endif}dosysevent);
   end;
  end;
 end;
 fonsyswindowevent:= avalue;
end;

procedure tcustommseform.setonapplicationevent(
                                const avalue: applicationeventeventty);
begin
 if not (csdesigning in componentstate) then begin
  if assigned(avalue) then begin
   if not assigned(fonapplicationevent) then begin
    application.registerapplicationeventhandler(@doapplicationevent);
   end;
  end
  else begin
   if assigned(fonapplicationevent) then begin
    application.unregisterapplicationeventhandler(@doapplicationevent);
   end;
  end;
 end;
 fonapplicationevent:= avalue;
end;

procedure tcustommseform.dosysevent(const awindow: winidty;
               var aevent: syseventty; var handled: boolean);
begin
 if assigned(fonsysevent) then begin
  fonsysevent(self,aevent,handled);
 end;
 if assigned(fonsyswindowevent) and not handled and
         (awindow <> 0) and (twindow1(window).fwindow.id = awindow) then begin
  fonsyswindowevent(self,aevent,handled);
 end;
end;

procedure tcustommseform.doapplicationevent(var aevent: tmseevent;
               var handled: boolean);
begin
 if assigned(fonapplicationevent) then begin
  fonapplicationevent(self,aevent,handled);
 end;
end;

procedure tcustommseform.updatelayout(const sender: twidget);
begin
 //dummy
end;

function tcustommseform.getassistivecaption(): msestring;
begin
{
 result:= '';
 if caption <> '' then begin
  if ownswindow then begin
   result:= sc(sc_window)+' '+caption;
  end
  else begin
   result:= caption;
  end;
 end;
}
 result:= caption;
 if result = '' then begin
  result:= inherited getassistivecaption();
 end;
end;

procedure tcustommseform.readonchildscaled(reader: treader);
begin
 onlayout:= notifyeventty(readmethod(reader));
end;

procedure tcustommseform.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('onchildscaled',
                 {$ifdef FPC}@{$endif}readonchildscaled,nil,false);
end;

procedure tcustommseform.dolayoutchanged(const sender: tdockcontroller);
begin
 //dummy
end;

procedure tcustommseform.dodockcaptionchanged(const sender: tdockcontroller);
begin
 //dummy
end;

procedure tcustommseform.autoreadstat;
begin
 if (fstatfile <> nil) and not (csdesigning in componentstate) and
       (foptions*[fo_autoreadstat,fo_delayedreadstat] =
                                           [fo_autoreadstat]) then begin
  fstatfile.readstat;
 end;
end;

procedure tcustommseform.getautopaintsize(var asize: sizety);
var
 size1: sizety;
begin
 with fscrollbox do begin
  asize:= calcminscrollsize;
  size1:= frame.paintframedim;
  subpoint1(pointty(size1),self.paintpos);
  asize.cx:= asize.cx + fscrollbox.bounds_x + size1.cx;
  asize.cy:= asize.cy + fscrollbox.bounds_y + size1.cy;
 end;
end;

procedure tcustommseform.setactivatortarget(const avalue: tactivator);
begin
 setlinkedvar(avalue,tmsecomponent(factivatortarget));
end;

procedure tcustommseform.settaborderoverride(const avalue: ttaborderoverride);
begin
 ftaborderoverride.assign(avalue);
end;

function tcustommseform.internalgeticon(): tmaskedbitmap;
begin
 result:= ficon;
end;

function tcustommseform.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

{ tmseform }

constructor tmseform.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstate,cs_ismodule);
 inherited;
end;

class function tmseform.getmoduleclassname: string;
begin
// result:= tmseform.ClassName;
 //bug in dcc32: tmseform is replaced by self
 result:= 'tmseform';
end;

class function tmseform.hasresource: boolean;
begin
 result:= self <> tmseform;
end;

{ tmainform }

class function tmainform.getmoduleclassname: string;
begin
// result:= tmseform.ClassName;
 //bug in dcc32: tmseform is replaced by self
 result:= 'tmainform';
end;

class function tmainform.hasresource: boolean;
begin
 result:= self <> tmainform;
end;

procedure tmainform.aftercreate;
begin
 inherited;
 foptions:= defaultmainformoptions;
 foptionswindow:= defaultmainformoptionswindow;
end;

{ tformdockcontroller }


constructor tformdockcontroller.create(const aowner: tcustomdockform);
begin
 fowner:= aowner;
 foptionsdockform:= defaultoptionsdockform;
 inherited create(idockcontroller(aowner));
end;

procedure tformdockcontroller.setoptionsdock(const avalue: optionsdockty);
begin
 inherited;
 updatebit(longword(tdockform(fintf.getwidget).foptions),
                           ord(fo_savepos),od_savepos in foptionsdock);
 updatebit(longword(tdockform(fintf.getwidget).foptions),
                     ord(fo_savezorder),od_savezorder in foptionsdock);
end;

procedure tformdockcontroller.setoptionsdockform(
                               const avalue: optionsdockformty);
begin
 if foptionsdockform <> avalue then begin
  foptionsdockform:= avalue;
  if fowner.componentstate * [csloading,csdestroying] = [] then begin
   layoutchanged();
  end;
 end;
end;

function tformdockcontroller.hasmain(): boolean;
var
 ar1: widgetarty;
 w1: twidget;
 i1: int32;
begin
 result:= false;
 if not (csdestroying in fowner.componentstate) then begin
  result:= odf_main in foptionsdockform;
  if not result then begin
   ar1:= getitems();
   for i1:= 0 to high(ar1) do begin
    w1:= ar1[i1];
    if not (csdestroying in w1.componentstate) and
                                   (w1 is tcustomdockform) then begin
     result:= tcustomdockform(w1).fdragdock.hasmain();
     if result then begin
      break;
     end;
    end;
   end;
  end;
 end;
end;

function tformdockcontroller.childicon(): tmaskedbitmap;

 function check(const avalue: tformdockcontroller): tmaskedbitmap;
 var
  ar1: widgetarty;
  w1: twidget;
  i1: int32;
 begin
  result:= nil;
  with avalue do begin
   if not (csdestroying in fowner.componentstate) then begin
    if odf_main in foptionsdockform then begin
     result:= fowner.ficon;
    end
    else begin
     ar1:= getitems();
     for i1:= 0 to high(ar1) do begin
      w1:= ar1[i1];
      if w1 is tcustomdockform then begin
       result:= check(tcustomdockform(w1).fdragdock);
       if result <> nil then begin
        break;
       end;
      end;
     end;
    end;
   end;
  end;
 end; //check

begin
 if (odf_mainchildicon in foptionsdockform) then begin
  result:= check(self);
  if result = nil then begin
   result:= inherited childicon();
  end
  else begin
   if not result.hasimage then begin
    result:= nil;
   end;
  end;
 end
 else begin
  result:= inherited childicon;
 end;
end;

procedure tformdockcontroller.dolayoutchanged();
begin
 inherited;
 if odf_childicons in foptionsdockform then begin
  fowner.iconchanged(nil);
 end;
end;

procedure tformdockcontroller.childstatechanged(const sender: twidget;
             const newstate: widgetstatesty; const oldstate: widgetstatesty);
begin
 inherited;
 if (odf_childicons in foptionsdockform) and (ws_entered in newstate) and
                            not (ws_entered in oldstate) then begin
  fowner.iconchanged(nil);
 end;
end;

{ tcustomdockform }

constructor tcustomdockform.create(aowner: tcomponent; load: boolean);
begin
 if fdragdock = nil then begin
  fdragdock:= tformdockcontroller.create(self);
 end;
 if fscrollbox = nil then begin
  fscrollbox:= tdockformscrollbox.create(self);
 end;
 inherited;
end;

destructor tcustomdockform.destroy();
begin
 inherited;
 fdragdock.Free;
end;

function tcustomdockform.getdockcontroller: tdockcontroller;
begin
 result:= fdragdock;
end;

procedure tcustomdockform.setdragdock(const value: tformdockcontroller);
begin
 fdragdock.assign(value);
end;

function tcustomdockform.getframe: tgripframe;
begin
 result:= tgripframe(inherited getframe);
end;

procedure tcustomdockform.setframe(const avalue: tgripframe);
begin
 inherited setframe(avalue);
end;

procedure tcustomdockform.internalcreateframe;
begin
 tgripframe.create(iscrollframe(self),fdragdock);
end;

function tcustomdockform.internalgeticon(): tmaskedbitmap;
begin
 result:= inherited internalgeticon();
 if (result = nil) or not result.hasimage() and
              (odf_childicons in fdragdock.optionsdockform) then begin
  result:= fdragdock.childicon();
 end;
end;

procedure tcustomdockform.dragevent(var info: draginfoty);
begin
 if not fdragdock.beforedragevent(info) then begin
  inherited;
 end;
 fdragdock.afterdragevent(info);
end;

procedure tcustomdockform.updateoptions;
begin
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fdragdock.foptionsdock),
         ord(od_savepos),fo_savepos in foptions);
 updatebit({$ifdef FPC}longword{$else}longword{$endif}(fdragdock.foptionsdock),
         ord(od_savezorder),fo_savezorder in foptions);
 inherited;
end;

function tcustomdockform.getoptions: formoptionsty;
begin
 if od_savepos in fdragdock.optionsdock then begin
  include(foptions,fo_savepos);
 end
 else begin
  exclude(foptions,fo_savepos);
 end;
 if od_savezorder in fdragdock.optionsdock then begin
  include(foptions,fo_savezorder);
 end
 else begin
  exclude(foptions,fo_savezorder);
 end;
 result:= inherited getoptions;
end;

procedure tcustomdockform.dostatread1(const reader: tstatreader);
begin
 tdockcontroller(fdragdock).dostatread(reader);
end;

procedure tcustomdockform.dostatwrite1(const writer: tstatwriter);
var
 rect1: rectty;
begin
 if fparentwidget = nil then begin
  rect1:= window.normalwindowrect;
  fdragdock.dostatwrite(writer,@rect1);
 end
 else begin
  fdragdock.dostatwrite(writer,nil);
 end;
end;
{
procedure tcustomdockform.dokeydown(var info: keyeventinfoty);
begin
 fdragdock.keydown(info);
 if not es_processed in info.eventstate then begin
  inherited;
 end;
end;
}
procedure tcustomdockform.statreading;
begin
 tdockcontroller(fdragdock).statreading;
 inherited;
end;

procedure tcustomdockform.statread;
begin
 tdockcontroller(fdragdock).statread;
 inherited;
end;
(*
procedure tcustomdockform.mouseevent(var info: mouseeventinfoty);
var
 bo1: boolean;
begin
 inherited;
 {
 bo1:= info.eventkind = ek_buttonrelease;
 if not (es_processed in info.eventstate) and bo1 then begin
  fdragdock.mouseevent(info);
 end;
 inherited;
 if not (es_processed in info.eventstate) and not bo1 then begin
  fdragdock.mouseevent(info);
 end;
 }
end;
*)
procedure tcustomdockform.childmouseevent(const sender: twidget;
               var info: mouseeventinfoty);
begin
 if not (es_processed in info.eventstate) then begin
  fdragdock.childormouseevent(sender,info);
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tcustomdockform.doactivate;
begin
 fdragdock.doactivate;
 inherited;
end;

procedure tcustomdockform.parentchanged;
begin
 inherited;
 fdragdock.parentchanged(self);
end;

function tcustomdockform.canfocus: boolean;
begin
 result:= inherited canfocus and (fdragdock.mdistate <> mds_minimized);
end;

procedure tcustomdockform.activate(const abringtofront: boolean = true;
                                        const aforce: boolean = false);
begin
 if fdragdock.mdistate = mds_minimized then begin
  fdragdock.mdistate:= mds_normal;
 end;
 if fdragdock.ismdi then begin
  bringtofront;
 end;
 inherited;
end;

procedure tcustomdockform.activechanged;
begin
 if fframe <> nil then begin
  invalidaterect(tgripframe(fframe).griprect,org_widget);
 end;
 inherited;
end;

procedure tcustomdockform.statechanged;
begin
 fdragdock.statechanged(fwidgetstate);
 inherited;
end;

procedure tcustomdockform.poschanged;
begin
 fdragdock.poschanged;
 inherited;
end;

function tcustomdockform.getwindowcaption: msestring;
begin
 result:= fdragdock.getfloatcaption;
end;

function tcustomdockform.ismainwindow(): boolean;
begin
 result:= inherited ismainwindow() or not(csdesigning in componentstate) and
               (odf_mainmainwindow in fdragdock.foptionsdockform) and
                                                          fdragdock.hasmain();
end;

procedure tcustomdockform.dolayoutchanged(const sender: tdockcontroller);
begin
 inherited;
 if not (csdestroying in componentstate) then begin
  checkdockicon();
  if (window.owner = self) then begin
   if ismainwindow() then begin
    application.mainwindow:= fwindow;
   end
   else begin
    if application.mainwindow = fwindow then begin
     application.mainwindow:= nil;
    end;
   end;
  end;
 end;
end;

procedure tcustomdockform.checkdockicon();
begin
 if odf_childicons in fdragdock.optionsdockform then begin
  iconchanged(nil);
 end;
 if fhasdocktaskbaricon <> needsdocktaskbaricon() then begin
  window.recreatewindow();
 end;
end;

function tcustomdockform.getchildicon(): tmaskedbitmap;
begin
 result:= inherited getchildicon();
 if (result = nil) and not (csdestroying in componentstate) then begin
  result:= fdragdock.childicon();
 end;
end;

procedure tcustomdockform.loaded();
begin
 inherited;
 checkdockicon();
end;

procedure tcustomdockform.doenter();
begin
 inherited;
 fdragdock.statechanged(fwidgetstate);
end;

procedure tcustomdockform.doexit();
begin
 inherited;
 fdragdock.statechanged(fwidgetstate);
end;

procedure tcustomdockform.setdockingareacaption(const avalue: msestring);
begin
 fdockingareacaption:= avalue;
 invalidate;
end;

function tcustomdockform.needsdocktaskbaricon(): boolean;
begin
 result:= (odf_maintaskbar in fdragdock.foptionsdockform) and
                                                     fdragdock.hasmain();
end;

procedure tcustomdockform.updatewindowinfo(var info: windowinfoty);
begin
 inherited;
 fhasdocktaskbaricon:= needsdocktaskbaricon();
 if fhasdocktaskbaricon then begin
  include(info.options,wo_taskbar);
 end;
end;

{ tdockform}

constructor tdockform.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstate,cs_ismodule);
 inherited;
end;

class function tdockform.getmoduleclassname: string;
begin
 result:= 'tdockform';
end;

class function tdockform.hasresource: boolean;
begin
 result:= self <> tdockform;
end;

{ tsubform }

constructor tsubform.create(aowner: tcomponent);
begin
 create(aowner,not (cs_noload in fmsecomponentstate));
end;

constructor tsubform.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstate,cs_ismodule);
 fwidgetrect.x:= 100;
 fwidgetrect.y:= 100;
 inherited create(aowner);
 fwidgetrect.cx:= 100;
 fwidgetrect.cy:= 100;
 if load and not (csdesigning in componentstate) and
          (cs_ismodule in fmsecomponentstate) then begin
  loadmsemodule(self,tsubform);
 end;
end;

class function tsubform.getmoduleclassname: string;
begin
 result:= 'tsubform';
end;

class function tsubform.hasresource: boolean;
begin
 result:= self <> tsubform;
end;

procedure tsubform.getchildren(proc: tgetchildproc; root: tcomponent);
begin
 inherited;
 getcompchildren(proc,root);
end;

{ tscrollboxform }

constructor tscrollboxform.create(aowner: tcomponent);
begin
 create(aowner,not (cs_noload in fmsecomponentstate));
end;

constructor tscrollboxform.create(aowner: tcomponent; load: boolean);
begin
 include(fmsecomponentstate,cs_ismodule);
 fwidgetrect.x:= 100;
 fwidgetrect.y:= 100;
 inherited create(aowner);
 fwidgetrect.cx:= 100;
 fwidgetrect.cy:= 100;
 if load and not (csdesigning in componentstate) and
          (cs_ismodule in fmsecomponentstate) then begin
  loadmsemodule(self,tscrollboxform);
 end;
end;

class function tscrollboxform.getmoduleclassname: string;
begin
 result:= 'tscrollboxform';
end;

class function tscrollboxform.hasresource: boolean;
begin
 result:= self <> tscrollboxform;
end;

procedure tscrollboxform.getchildren(proc: tgetchildproc; root: tcomponent);
begin
 inherited;
 getcompchildren(proc,root);
end;

{ ttabformfonttab }

class function ttabformfonttab.getinstancepo(owner: tobject): pfont;
begin
 result:= @ttabform(owner).ffonttab;
end;

{ ttabpagefontactivetab }

class function ttabformfontactivetab.getinstancepo(owner: tobject): pfont;
begin
 result:= @ttabform(owner).ffontactivetab;
end;

{ ttabform }

//constructor ttabform.docreate(aowner: tcomponent);
procedure ttabform.docreate(aowner: tcomponent);
begin
 fcolortab:= cl_default;
 fcoloractivetab:= cl_default;
 fimagenr:= -1;
 fimagenrdisabled:= -2;
 inherited;
// inherited create(aowner);
 fcolor:= cl_default;
 exclude(fwidgetstate,ws_visible);
end;

destructor ttabform.destroy;
begin
 inherited;
 freeandnil(ffonttab);
 freeandnil(ffontactivetab);
end;

class function ttabform.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_tabpage;
end;

procedure ttabform.createfonttab;
begin
 if ffonttab = nil then begin
  ffonttab:= ttabformfonttab.create;
  ffonttab.onchange:= {$ifdef FPC}@{$endif}fontchanged1;
 end;
end;

procedure ttabform.createfontactivetab;
begin
 if ffontactivetab = nil then begin
  ffontactivetab:= ttabformfontactivetab.create;
  ffontactivetab.onchange:= {$ifdef FPC}@{$endif}fontchanged1;
 end;
end;

procedure ttabform.loaded;
begin
 if fparentwidget is tcustomtabwidget then begin
  include(fwidgetstate1,ws1_nodesignvisible);
 end;
 inherited;
end;

class function ttabform.getmoduleclassname: string;
begin
 result:= 'ttabform';
end;

procedure ttabform.changed;
begin
 if ftabwidget <> nil then begin
  tcustomtabwidget1(ftabwidget).pagechanged(itabpage(self));
 end;
end;

procedure ttabform.fontchanged1(const sender: tobject);
begin
 changed;
end;

function ttabform.getcolortab: colorty;
begin
 result:= fcolortab;
end;

procedure ttabform.setcolortab(const avalue: colorty);
begin
 if fcolortab <> avalue then begin
  fcolortab:= avalue;
  changed;
 end;
end;

function ttabform.getcoloractivetab: colorty;
begin
 result:= fcoloractivetab;
end;

procedure ttabform.setcoloractivetab(const avalue: colorty);
begin
 if fcoloractivetab <> fcoloractivetab then begin
  fcoloractivetab:= avalue;
  changed;
 end;
end;

function ttabform.gettabwidget: tcustomtabwidget;
begin
 result:= ftabwidget;
end;

function ttabform.isactivepage: boolean;
begin
 result:= (ftabwidget <> nil) and (ftabwidget.activepage = self);
end;

procedure ttabform.setcaption(const value: msestring);
begin
 inherited;
 changed;
end;

function ttabform.gettabhint: msestring;
begin
 result:= ftabhint;
end;

procedure ttabform.settabhint(const avalue: msestring);
begin
 ftabhint:= avalue;
 changed;
end;

function ttabform.gettabnoface: boolean;
begin
 result:= ftabnoface;
end;

procedure ttabform.settabnoface(const avalue: boolean);
begin
 if ftabnoface <> avalue then begin
  ftabnoface:= avalue;
  changed;
 end;
end;

procedure ttabform.settabwidget(const value: tcustomtabwidget);
begin
 ftabwidget:= value;
end;

procedure ttabform.visiblechanged;
begin
 inherited;
 changed;
end;

function ttabform.gettabindex: integer;
begin
 if tabwidget = nil then begin
  result:= -1;
 end
 else begin
  result:= tabwidget.indexof(self);
 end;
end;

procedure ttabform.settabindex(const avalue: integer);
begin
 if tabwidget <> nil then begin
  tabwidget.movepage(tabindex,avalue);
 end;
end;

procedure ttabform.doselect;
begin
 if canevent(tmethod(fonselect)) then begin
  fonselect(self);
 end;
end;

procedure ttabform.dodeselect;
begin
 if canevent(tmethod(fondeselect)) then begin
  fondeselect(self);
 end;
end;

function ttabform.getimagelist: timagelist;
begin
 result:= fimagelist
end;

procedure ttabform.setimagelist(const avalue: timagelist);
begin
 if fimagelist <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(fimagelist));
  changed;
 end;
end;

function ttabform.getimagenr: imagenrty;
begin
 result:= fimagenr;
end;

procedure ttabform.setimagenr(const avalue: imagenrty);
begin
 if fimagenr <> avalue then begin
  fimagenr:= avalue;
  changed;
 end;
end;
{
function ttabform.getimagenractive: integer;
begin
 result:= fimagenractive;
end;

procedure ttabform.setimagenractive(const avalue: integer);
begin
 if fimagenractive <> avalue then begin
  fimagenractive:= avalue;
  changed;
 end;
end;
}
function ttabform.getimagenrdisabled: imagenrty;
begin
 result:= fimagenrdisabled;
end;

procedure ttabform.setimagenrdisabled(const avalue: imagenrty);
begin
 if fimagenrdisabled <> avalue then begin
  fimagenrdisabled:= avalue;
  changed;
 end;
end;

procedure ttabform.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 inherited;
 if event = oe_destroyed then begin
  if sender = fimagelist then begin
   fimagelist:= nil;
   changed;
  end;
  if sender = ffacetab then begin
   ffacetab:= nil;
   changed;
  end;
  if sender = ffaceactivetab then begin
   ffaceactivetab:= nil;
   changed;
  end;
 end
 else begin
  if event = oe_changed then begin
   changed;
  end;
 end;
end;

function ttabform.getinvisible: boolean;
begin
 result:= finvisible;
end;

procedure ttabform.setinvisible(const avalue: boolean);
begin
 if finvisible <> avalue then begin
  finvisible:= avalue;
  changed;
 end;
end;

class function ttabform.hasresource: boolean;
begin
 result:= self <> ttabform;
end;

function ttabform.getfonttab: tfont;
begin
 result:= ffonttab;
end;

function ttabform.getfontactivetab: tfont;
begin
 result:= ffontactivetab;
end;

function ttabform.getfonttab1: ttabformfonttab;
begin
 getoptionalobject(ffonttab,
                            {$ifdef FPC}@{$endif}createfonttab);
 result:= ffonttab;
end;

procedure ttabform.setfonttab1(const avalue: ttabformfonttab);
begin
 if avalue <> ffonttab then begin
  setoptionalobject(avalue,ffonttab,
                                       {$ifdef FPC}@{$endif}createfonttab);
  changed;
 end;
end;

procedure ttabform.setfonttab(const avalue: tfont);
begin
 setfonttab1(ttabformfonttab(avalue));
end;

function ttabform.isfonttabstored: boolean;
begin
 result:= ffonttab <> nil;
end;

function ttabform.getfontactivetab1: ttabformfontactivetab;
begin
 getoptionalobject(ffontactivetab,
                            {$ifdef FPC}@{$endif}createfontactivetab);
 result:= ffontactivetab;
end;

procedure ttabform.setfontactivetab1(const avalue: ttabformfontactivetab);
begin
 if avalue <> ffontactivetab then begin
  setoptionalobject(avalue,ffontactivetab,
                                       {$ifdef FPC}@{$endif}createfontactivetab);
  changed;
 end;
end;

procedure ttabform.setfontactivetab(const avalue: tfont);
begin
 setfontactivetab1(ttabformfontactivetab(avalue));
end;

function ttabform.isfontactivetabstored: boolean;
begin
 result:= ffontactivetab <> nil;
end;

function ttabform.getfacetab: tfacecomp;
begin
 result:= ffacetab;
end;

procedure ttabform.setfacetab(const avalue: tfacecomp);
begin
 if ffacetab <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(ffacetab));
  changed();
 end;
end;

function ttabform.getfaceactivetab: tfacecomp;
begin
 result:= ffaceactivetab;
end;

procedure ttabform.setfaceactivetab(const avalue: tfacecomp);
begin
 if ffaceactivetab <> avalue then begin
  setlinkedvar(avalue,tmsecomponent(ffaceactivetab));
  changed();
 end;
end;

{
function ttabform.gettabwidth: integer;
begin
 result:= ftabwidth;
end;

procedure ttabform.settabwidth(const avalue: integer);
begin
 ftabwidth:= avalue;
 changed;
end;

function ttabform.gettabwidthmin: integer;
begin
 result:= ftabwidthmin;
end;

procedure ttabform.settabwidthmin(const avalue: integer);
begin
 ftabwidthmin:= avalue;
 changed;
end;

function ttabform.gettabwidthmax: integer;
begin
 result:= ftabwidthmax;
end;

procedure ttabform.settabwidthmax(const avalue: integer);
begin
 ftabwidthmax:= avalue;
 changed;
end;
}
end.

