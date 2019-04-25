{ MSEgui Copyright (c) 1999-2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegraphedits;
{$ifdef FPC}
 {$mode objfpc}{$h+}
 {$interfaces corba}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

uses
 classes,mclasses,msegui,
 mseglob,mseguiglob,msescrollbar,msegraphutils,msegraphics,mseevent,
 msewidgets,mseeditglob,msestockobjects,msestat,msestatfile,mseassistiveclient,
 mseclasses,msesimplewidgets,msemenus,mseact,typinfo,msedragglob,
 msegrids,msewidgetgrid,msedatalist,msebitmap,msetypes,msestrings,msearrayprops,
 msedrawtext,mseshapes
 {$ifdef mse_with_ifi}{,mseifi},mseifiglob,mseificomp,mseificompglob{$endif},
 msepointer,msegridsglob;

const
 defaultsliderwidth = 200;
 defaultsliderheight = 20;
 defaultboxsize = 13;
 defaultsliderscrollbaroptions = defaultscrollbaroptions + 
                                                [sbo_valuekeys,sbo_thumbtrack];
 defaultgrapheditframeoptions = defaultcaptionframeoptions + [cfo_captionfocus];
 
type
 tgrapheditframe = class(tcustomcaptionframe)
  protected
//   function getdefaultcolorclient: colorty; virtual;
//   function actualcolorclient(): colorty override;
  public
   constructor create(const aintf: icaptionframe);
  published
   property options default defaultgrapheditframeoptions;
   property levelo default -2;
   property leveli;
   property framewidth;
   property colorframe;
   property colorframeactive;
   property colorframedisabled;
   property colorframemouse;
   property colorframeclicked;
   property colorframedefault;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property hiddenedges;
   property framei_left;
   property framei_top;
   property framei_right;
   property framei_bottom;
   property frameo_left;
   property frameo_top;
   property frameo_right;
   property frameo_bottom;

   property frameimage_list;
   property frameimage_left;
   property frameimage_top;
   property frameimage_right;
   property frameimage_bottom;
   property frameimage_offset;
   property frameimage_offset1;
   property frameimage_offsetdisabled;
   property frameimage_offsetmouse;
   property frameimage_offsetclicked;
   property frameimage_offsetactive;
   property frameimage_offsetfocused;
{
   property frameimage_offsetactivemouse;
   property frameimage_offsetactiveclicked;
}
   property frameface_list;
   property frameface_offset;
   property frameface_offset1;
   property frameface_offsetdisabled;
   property frameface_offsetmouse;
   property frameface_offsetclicked;
   property frameface_offsetactive;
   property frameface_offsetfocused;
{
   property frameface_offsetactivemouse;
   property frameface_offsetactiveclicked;
}
   property colorclient {default cl_transparent};
   property caption;
   property captionpos default cp_right;
   property captiondist;
   property captionoffset;
   property font;
   property localprops; //before template
   property localprops1; //before template
   property template;
 end;

 ttogglegrapheditframe = class(tgrapheditframe)
  protected
   function actualcolorclient: colorty override;
  published
   property colorclient {default cl_foreground};
 end;
 
 tgraphdataedit = class(tactionpublishedwidget,igridwidget,istatfile,
                         iassistiveclientgridwidget
                  {$ifdef mse_with_ifi},iifidatalink{$endif})
  private
   fonchange: notifyeventty;
   fondataentered: notifyeventty;
   fcolorglyph: colorty;
   fstatvarname: msestring;
   fstatfile: tstatfile;
   foptionsedit: optionseditty;
   foptionsedit1: optionsedit1ty;
   fedited: boolean;
   fvalueread: boolean;
   fstatpriority: integer;
   procedure setcolorglyph(const Value: colorty);
   procedure setstatfile(const Value: tstatfile);
   procedure setoptionsedit(const avalue: optionseditty);
   function getreadonly: boolean;
   procedure setreadonly(const avalue: boolean);
   procedure setedited(const avalue: boolean); virtual;
   procedure setoptionsedit1(const avalue: optionsedit1ty);
  protected
   fdatalist: tdatalist;
   fgridintf: iwidgetgrid;
   fgriddatalink: pointer;
   fparentintf: igridwidget;
   fstate: dataeditstatesty;
{$ifdef mse_with_ifi}
   fifilink: tifivaluelinkcomp;
   function getdefaultifilink: iificlient; override;
   procedure ifisetvalue(var avalue; var accept: boolean);
   procedure getifivalue(var avalue) virtual;
   procedure setifivalue(const avalue) virtual;
   function getifilinkkind: ptypeinfo;
   procedure setifilink(const avalue: tifilinkcomp);
   function getifilink: tifilinkcomp;
    //iificlient
   function getifidatatype(): listdatatypety override;
//   function ifigriddata: tdatalist;
   procedure updateifigriddata(const sender: tobject; const alist: tdatalist);
   function getgriddata: tdatalist;
   function getvalueprop: ppropinfo;
   function getiassistiveclient(): iassistiveclient override;
    //iassistiveclientgridwidget
   function getifidatalinkintf(): iifidatalink; override;
   function getassistiveflags: assistiveflagsty; override;
   function getassistivecolumncaption(): msestring virtual;
{$endif}
   function getedited: boolean; virtual;
   function geteditstate: dataeditstatesty;
   procedure seteditstate(const avalue: dataeditstatesty);
   function getoptionsedit: optionseditty; virtual;
   procedure updateoptions; virtual;
   procedure loaded; override;
   procedure internalcreateframe; override;
   procedure enabledchanged() override;
   procedure setenabled(const avalue: boolean); override;
   procedure dofocus; override;

   function getgridintf: iwidgetgrid;
   procedure checkgrid;
   function checkgriddata: tdatalist;
   procedure internalfillcol(const value);
   procedure internalassigncol(const value);
   procedure internalgetgridvalue(index: integer; out value);
   procedure internalsetgridvalue(index: integer; const avalue);
   procedure dochange; virtual;
   function docheckvalue(var avalue; const quiet: boolean): boolean; virtual;
   procedure valuechanged; virtual;
   procedure modified; virtual; //for dbwidgets
   procedure formatchanged();
   procedure dopaintforeground(const canvas: tcanvas); override;
   function needsfocuspaint: boolean; override;
   procedure internalcheckvalue(var avalue; var accept: boolean);
                                                            virtual; abstract;
   procedure paintglyph(const canvas: tcanvas; const acolorglyph: colorty;
                        const avalue; const arect: rectty);
                 virtual; abstract;
   procedure dofontheightdelta(var delta: integer); override;
   procedure sizechanged; override;
   
   procedure updatereadonlystate; virtual;
   procedure initeditfocus;
   procedure updatedatalist; virtual;
   
    //igridwidget
   procedure setfirstclick(var ainfo: mouseeventinfoty);
   function createdatalist(const sender: twidgetcol): tdatalist; 
                                                     virtual; abstract;
   procedure datalistdestroyed; virtual;
   function getdatalistclass: datalistclassty; virtual; abstract;
   function getdefaultvalue: pointer; virtual;
   function getrowdatapo(const arow: integer): pointer; virtual;
   procedure setgridintf(const intf: iwidgetgrid); virtual;
   function getcellframe: framety; virtual;
   function needscellfocuspaint(): boolean;
   function getcellcursor(const arow: integer; const acellzone: cellzonety;
                                  const apos: pointty): cursorshapety; virtual;
   procedure updatecellzone(const arow: integer; const apos: pointty;
                            var result: cellzonety); virtual;
   procedure drawcell(const canvas: tcanvas);
   procedure updateautocellsize(const canvas: tcanvas); virtual;
   procedure beforecelldragevent(var ainfo: draginfoty; const arow: integer;
                               var handled: boolean); virtual;
   procedure aftercelldragevent(var ainfo: draginfoty; const arow: integer;
                               var handled: boolean); virtual;
   procedure valuetogrid(row: integer); virtual; abstract;
   procedure gridtovalue(row: integer); virtual;
   procedure setvaluedata(const source); virtual; abstract;
   procedure getvaluedata(out dest); virtual; abstract;
   function getnulltext: msestring; virtual;
   function getassistivecelltext(const arow: int32): msestring; virtual;
   procedure docellevent(const ownedcol: boolean;
                                        var info: celleventinfoty); virtual;
   function sortfunc(const l,r): integer; virtual;
   procedure gridvaluechanged(const index: integer); virtual;
   procedure updatecoloptions(const aoptions: coloptionsty);
   procedure updatecoloptions1(const aoptions: coloptions1ty);
   procedure statdataread; virtual;
   procedure griddatasourcechanged; virtual;
   procedure fontchanged; override;
   procedure setparentgridwidget(const intf: igridwidget);
   procedure childdataentered(const sender: igridwidget); virtual;
   procedure childfocused(const sender: igridwidget); virtual;

   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;
   function getstatpriority: integer;

   procedure readstatvalue(const reader: tstatreader); virtual;
   procedure writestatvalue(const writer: tstatwriter); virtual;
   procedure readstatstate(const reader: tstatreader); virtual;
   procedure writestatstate(const writer: tstatwriter); virtual;
   procedure readstatoptions(const reader: tstatreader); virtual;
   procedure writestatoptions(const writer: tstatwriter); virtual;

  public
   constructor create(aowner: tcomponent); override;
   procedure initnewcomponent(const ascale: real); override;
   procedure initnewwidget(const ascale: real); override;
   procedure initgridwidget; virtual;
   procedure paint(const canvas: tcanvas); override;

   property edited: boolean read getedited write setedited;
   function actualcolor: colorty; override;
   function widgetcol: twidgetcol;
   function grid: tcustomwidgetgrid;
   function gridrow: integer;
   function gridrowhigh: int32; //-1 if no grid
   function griddatarowhigh: int32; //-1 if no grid
   function gridcol: integer;
   function griddata: tdatalist;

   function checkvalue(const quiet: boolean = false): boolean virtual abstract;
   function seteditfocus: boolean;

   property objectlinker: tobjectlinker read getobjectlinker
                {$ifdef msehasimplements}implements istatfile{$endif};
   property colorglyph: colorty read fcolorglyph write setcolorglyph
                                                           default cl_default;
                                      //cl_default -> cl_glyph
   property readonly: boolean read getreadonly write setreadonly;
  published
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property statpriority: integer read fstatpriority 
                                       write fstatpriority default 0;
   property optionsedit: optionseditty read getoptionsedit write setoptionsedit
                              default defaultoptionsedit;
   property optionsedit1: optionsedit1ty read foptionsedit1
                         write setoptionsedit1 default defaultoptionsedit1;
   property onchange: notifyeventty read fonchange write fonchange;
   property ondataentered: notifyeventty read fondataentered 
                                                    write fondataentered;
 end;

 tpointeredit = class;
 
 paintpointerglypheventty = procedure(const sender: tpointeredit;
           const acanvas: tcanvas; const avalue: pointer;
                                      const arow: integer) of object;
                    
 tpointeredit = class(tgraphdataedit)
  private
   fvalue: pointer;
   fonpaintglyph: paintpointerglypheventty;
   procedure setvalue(const avalue: pointer);
   function getgridvalue(const index: integer): pointer;
   procedure setgridvalue(const index: integer; const avalue: pointer);
   function getgridvalues: pointerarty;
   procedure setgridvalues(const avalue: pointerarty);
  protected
   procedure setvaluedata(const source); override;
   procedure getvaluedata(out dest); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatalistclass: datalistclassty; override;
   procedure paintglyph(const canvas: tcanvas; const acolorglyph: colorty;
                const avalue; const arect: rectty); override;
   procedure gridtovalue(arow: integer); override;
   procedure valuetogrid(arow: integer); override;
  public
   procedure initnewcomponent(const ascale: real); override;
   property value: pointer read fvalue write setvalue default nil;
   property gridvalue[const index: integer]: pointer
        read getgridvalue write setgridvalue; default;
   property gridvalues: pointerarty read getgridvalues write setgridvalues;
   function griddata: tgridpointerdatalist;
  published
   property visible;
   property enabled;
   property onpaintglyph: paintpointerglypheventty read fonpaintglyph 
                                                         write fonpaintglyph;
 end;
 
 tsliderscrollbar = class(tscrollbar,iface)
  private
  protected
  public
   constructor create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: proceventty = nil); override;
   destructor destroy; override;
  published
   property options default defaultsliderscrollbaroptions;
   property buttonlength default defaultbuttonminlength;
 end;

 tcustomrealgraphdataedit = class;
 
 paintrealglypheventty = procedure(
                    const sender: tcustomrealgraphdataedit;
                    const acanvas: tcanvas; const avalue: real;
                                      const arow: integer) of object;

 tcustomrealgraphdataedit = class(tgraphdataedit)
  private
   fonsetvalue: setrealeventty;
   fdirection: graphicdirectionty;
   fonpaintglyph: paintrealglypheventty;
   procedure setvalue(const avalue: realty);
   function getgridvalue(const index: integer): realty;
   procedure setgridvalue(const index: integer; const avalue: realty);
   function getgridvalues: realarty;
   procedure setgridvalues(const avalue: realarty);
  protected
   fvalue: realty;
   procedure setvaluedata(const source); override;
   procedure getvaluedata(out dest); override;
   procedure internalcreateframe; override;
   procedure paintglyph(const canvas: tcanvas; const acolorglyph: colorty;
                        const avalue; const arect: rectty); override;
   procedure setdirection(const avalue: graphicdirectionty); virtual;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatalistclass: datalistclassty; override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   procedure internalcheckvalue(var avalue; var accept: boolean); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure setnullvalue; virtual; //for dbedits
  {$ifdef mse_with_ifi}
   function getifilink: tifireallinkcomp;
   procedure setifilink(const avalue: tifireallinkcomp);
  {$endif}
  public
   constructor create(aowner: tcomponent); override;
   procedure fillcol(const value: realty);
   procedure assigncol(const avalue: trealdatalist);
   function checkvalue(const quiet: boolean = false): boolean override;
   function isnull: boolean;
   property gridvalue[const index: integer]: realty
        read getgridvalue write setgridvalue; default;
   property gridvalues: realarty read getgridvalues write setgridvalues;
   function griddata: tgridrealdatalist;
   property value: realty read fvalue write setvalue;
   property direction: graphicdirectionty read fdirection write setdirection 
                                                               default gd_right;
   property onsetvalue: setrealeventty read fonsetvalue write fonsetvalue;
   property onpaintglyph: paintrealglypheventty read fonpaintglyph 
                                                         write fonpaintglyph;
  published
   property visible;
   property enabled;
   property bounds_cx default defaultsliderwidth;
   property bounds_cy default defaultsliderheight;
  {$ifdef mse_with_ifi}
   property ifilink: tifireallinkcomp  read getifilink write setifilink;
  {$endif}
 end;

 trealgraphdataedit = class(tcustomrealgraphdataedit)
  published
   property value;
   property onsetvalue;
   property direction;
   property onpaintglyph;
 end;
 
 tsliderframe = class(tgrapheditframe)
  protected
   procedure settemplateinfo(const ainfo: frameinfoty); override;
 end;
 
const
  defaultslideroptionswidget = defaultoptionswidget + [ow_mousewheel];
type
 tcustomslider = class(tcustomrealgraphdataedit,iscrollbar)
  private
   fscrollbar: tsliderscrollbar;
   fupdating: integer;
   procedure setscrollbar(const avalue: tsliderscrollbar);
  protected
   procedure beginpaint(); //disable invalidate and updating
   procedure endpaint();
   procedure setdirection(const avalue: graphicdirectionty); override;
   procedure objectchanged(const sender: tobject); override;
   procedure clientrectchanged; override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure doenter; override;
   procedure doexit; override;
   procedure activechanged; override;
   procedure enabledchanged; override;
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty);

   procedure dochange; override;
   procedure paintglyph(const canvas: tcanvas;  const acolorglyph: colorty;
                  const avalue; const arect: rectty); override;
   class function classskininfo: skininfoty; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure initgridwidget; override;
   property scrollbar: tsliderscrollbar read fscrollbar write setscrollbar;
  published
   property optionswidget default defaultslideroptionswidget;
 end;

 tslider = class(tcustomslider)
  published
   property value;
   property scrollbar;
   property onsetvalue;
   property direction;
   property onpaintglyph;
 end;
 
const
 defaultbarcolor = cl_ltblue;
 
type
 tbarface = class(tface)
  public
   constructor create(const intf: iface); reintroduce;
 end;

 tcustomprogressbar = class;
  
 tbarframe = class(tframe)
  private
   fowner: tcustomprogressbar;
  public
   constructor create(const aowner: tcustomprogressbar);
 end;

 tcustomprogressbar = class(tcustomrealgraphdataedit,iface)
  private
   fbar_face: tbarface;
   fbar_frame: tbarframe;
   ffacerect: rectty;
   fframebarrect: rectty;
   ffacebarrect: rectty;
   fvaluerange: real;
   fvaluestart: real;
   fformat: msestring;
   ftextflags: textflagsty;
   fonfinished: progresseventty;
   fonprogress: progresseventty;
   fcancel: boolean;
   procedure setvalue(const avalue: realty);
   procedure setbar_face(const avalue: tbarface);
   procedure updatebarrect(const avalue: realty; const arect: rectty;
                    out facedest,framebardest,facebardest: rectty);
   procedure updatebar;
   procedure setvaluerange(const avalue: real);
   procedure setvaluestart(const avalue: real);
   procedure setformat(const avalue: msestring);
   procedure settextflags(const avalue: textflagsty);
   procedure setbar_frame(const avalue: tbarframe);
   procedure readformat(reader: treader);
   procedure writeformat(writer: twriter);
   procedure readvaluescale(reader: treader);
  protected
   procedure clientrectchanged; override;
   procedure dochange; override;
   procedure paintglyph(const canvas: tcanvas;  const acolorglyph: colorty;
                  const avalue; const arect: rectty); override;
   procedure internalcreateframe; override;
   procedure defineproperties(filer: tfiler); override;
   procedure gridtovalue(arow: integer); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure changedirection(const avalue: graphicdirectionty;
                                      var dest: graphicdirectionty); override;
   procedure doprogress(const sender: tobject; const avalue: real;
                                               var acancel: boolean);
                             //threadsave
   property cancel: boolean read fcancel write fcancel;
                    //ored with doprogress.acancel, resetted by value:= 0.0
   property value: realty read fvalue write setvalue;
          //thread safe, range 0 .. 1.0
  published
   property onsetvalue;
   property direction;

   property optionswidget default defaultoptionswidgetnofocus;
   property bar_face: tbarface read fbar_face write setbar_face;
   property bar_frame: tbarframe read fbar_frame write setbar_frame;
   property valuerange: real read fvaluerange write setvaluerange; //default 100
   property valuestart: real read fvaluestart write setvaluestart;
   property format: msestring read fformat write setformat stored false;
                   //default '0%', '' for no numeric
   property textflags: textflagsty read ftextflags write settextflags default
                              [tf_ycentered,tf_xcentered];
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property onprogress: progresseventty read fonprogress write fonprogress;
               //called from doprogress
   property onfinished: progresseventty read fonfinished write fonfinished;
               //called in doprogress if avalue = 1.0 or canceled
 end;

 tprogressbar = class(tcustomprogressbar)
  published
   property value;
   property onpaintglyph;
 end;
  
 ttogglegraphdataedit = class(tgraphdataedit)
  private
   foptions: buttonoptionsty;
   function getcheckedrow: integer;
   procedure setcheckedrow(const avalue: integer);
   function getcheckedtag: integer;
   procedure setcheckedtag(const avalue: integer);
  protected
   fgroup: integer;
   fcheckcaption: boolean;
   fclickedrow: integer;
   fresetting: integer; //for db edits
   procedure internalcreateframe; override;
   procedure setoptions(const avalue: buttonoptionsty); virtual;
   procedure resetradioitems();
   procedure togglevalue(const areadonly: boolean;
                               const down: boolean) virtual abstract;
   procedure docheck() virtual abstract;
   procedure douncheck() virtual abstract;
   function ischecked(): boolean virtual abstract;
   procedure togglegridvalue(const index: integer) virtual abstract;
   procedure resetgridvalue(const index: integer) virtual abstract;
   procedure checkgridvalue(const index: integer) virtual abstract;
   function gridvaluechecked(const aindex: integer): boolean virtual abstract;
   procedure mouseevent(var info: mouseeventinfoty) override;
   procedure dokeydown(var info: keyeventinfoty) override;
   procedure dokeyup(var info: keyeventinfoty) override;
   procedure doshortcut(var info: keyeventinfoty;
                                           const sender: twidget) override;
   procedure statechanged; override;
   procedure docellevent(const ownedcol: boolean; 
                       var info: celleventinfoty); override;
   procedure modified; override;
   procedure checkradiorow(aindex: integer);
   function internalcheckeditem(out single: boolean): ttogglegraphdataedit;
                                                           //nil if none
   function navigrect: rectty; override;
  public
   constructor create(aowner: tcomponent); override;
   property group: integer read fgroup write fgroup default 0;
   property checkedrow: integer read getcheckedrow write setcheckedrow; 
          //needs bo_radiotemcol, -1 if none
   property checkedtag: integer read getcheckedtag write setcheckedtag;
                             //-1 if none checked
  published
   property options: buttonoptionsty read foptions write setoptions
               default defaultbuttonoptions;
   property colorglyph;
 end;

 tcustombooleanedit = class;
 booleaneditarty = array of tcustombooleanedit;

 tcustombooleanedit = class(ttogglegraphdataedit)
  private
   fvalue: longbool;
   fvaluedefault: longbool;
   fonsetvalue: setbooleaneventty;
   procedure setvalue(const Value: boolean); virtual;
   function getglyph: stockglyphty; virtual;
   function getgridvalue(const index: integer): longbool;
   procedure setgridvalue(const index: integer; const Value: longbool); virtual;
   function getgridvalues: longboolarty;
   procedure setgridvalues(const Value: longboolarty);
   function getgridbooleanvalues: booleanarty;
   procedure setgridbooleanvalues(const Value: booleanarty);
   function getvalue: boolean;
   function getvaluedefault: boolean;
   procedure setvaluedefault(const Value: boolean);
  {$ifdef mse_with_ifi}
   function getifilink: tifibooleanlinkcomp;
   procedure setifilink(const avalue: tifibooleanlinkcomp);
  {$endif}
  protected
   class function classskininfo: skininfoty; override;
   procedure setvaluedata(const source); override;
   procedure getvaluedata(out dest); override;
   procedure setnullvalue;
   function getdefaultvalue: pointer; override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   procedure resetgridvalue(const index: integer); override;
   procedure checkgridvalue(const index: integer); override;
   function gridvaluechecked(const aindex: integer): boolean; override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatalistclass: datalistclassty; override;
   procedure togglevalue(const areadonly: boolean;
                                    const down: boolean); override;
   procedure docheck() override;   //set value to not valuedefault
   procedure douncheck() override; //set value to valuedefault
   function ischecked(): boolean; override;
   procedure paintglyph(const canvas: tcanvas;  const acolorglyph: colorty; 
                    const avalue; const arect: rectty); override;
   procedure internalcheckvalue(var avalue; var accept: boolean); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   function getvaluebitmask: longword;
   procedure setvaluebitmask(const avalue: longword);
   function getgridvaluebitmask(const index: integer): longword;
   procedure setgridvaluebitmask(const index: integer; const avalue: longword);
   procedure dokeydown(var info: keyeventinfoty); override;
   
   function getassistivetext(): msestring override;
  public
   constructor create(aowner: tcomponent); override;
   procedure fillcol(const avalue: longbool);
   function checkvalue(const quiet: boolean = false): boolean override;
   procedure togglegridvalue(const index: integer); override;
   
   property value: boolean read getvalue write setvalue default false;
   property valuedefault: boolean read getvaluedefault 
                                       write setvaluedefault default false;
                      //streaming of longbool does not work on kylix and fpc
   property gridvalue[const index: integer]: longbool
                          read getgridvalue write setgridvalue; default;
   function valuetag(const falsevalue: integer): integer;
   function valuetagbit: longword;
                  //if value -> bits[tag] else -> 0
   function gridvaluetagbit(const index: integer): longword;
                  //if value -> bits[tag] else -> 0
   property valuebitmask: longword read getvaluebitmask write setvaluebitmask;
                  //ored valuetagbit of all edits in group
   property gridvaluebitmask[const index: integer]: longword 
                           read getgridvaluebitmask write setgridvaluebitmask;
                  //ored valuetagbit of all edits in group

   function gridvaluetag(const index: integer; 
                                         const falsevalue: integer): integer;
           //if value = true -> tag, falsevalue otherwise
   procedure updatetagvalue(const bitset: integer);
           //value -> true if bitset and tag <> 0
   procedure gridupdatetagvalue(const index: integer; const bitset: integer);
   property gridvalues: longboolarty read getgridvalues write setgridvalues;
   property gridbooleanvalues: booleanarty read getgridbooleanvalues 
                                                 write setgridbooleanvalues;
   function griddata: tgridintegerdatalist;
   function groupmembers: booleaneditarty;
   function tagitem(const atag: integer): tcustombooleanedit; //nil if none

   property bounds_cx default defaultboxsize;
   property bounds_cy default defaultboxsize;
   property onsetvalue: setbooleaneventty read fonsetvalue write fonsetvalue;
{$ifdef mse_with_ifi}
   property ifilink: tifibooleanlinkcomp read getifilink write setifilink;
{$endif}
  published
   property visible;
   property enabled;
 end;

 tbooleanedit = class(tcustombooleanedit)
  published
   property bounds_cx  default defaultboxsize;
   property bounds_cy  default defaultboxsize;
   property onsetvalue;
   property value;
   property valuedefault;
   property group;
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
 end;
 
 tcustombooleaneditradio = class(tcustombooleanedit)
  private
   function getglyph: stockglyphty; override;
//   procedure reset;
   procedure setvalue(const avalue: boolean) override;
   procedure setgridvalue(const aindex: integer; 
                                    const aValue: longbool) override;
  protected
   procedure togglevalue(const areadonly: boolean;
                              const down: boolean) override;
  public
   procedure togglegridvalue(const index: integer) override;
   function checkeditem: tcustombooleaneditradio; //nil if none
 end;

 tbooleaneditradio = class(tcustombooleaneditradio)
  published
   property bounds_cx  default defaultboxsize;
   property bounds_cy  default defaultboxsize;
   property onsetvalue;
   property value;
   property valuedefault;
   property group;
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
 end;

 tcustomintegergraphdataedit = class;
 
 paintintegerglypheventty = procedure(
                    const sender: tcustomintegergraphdataedit;
                    const acanvas: tcanvas; const avalue: integer;
                                      const arow: integer) of object;

 tcustomintegergraphdataedit = class(ttogglegraphdataedit)
  private
   fvalue: integer;
   fvaluedefault: integer;
   fonsetvalue: setintegereventty;
   fvaluemin: integer;
   fvaluemax: integer;
//   fdatalist: tintegerdatalist;
   fonpaintglyph: paintintegerglypheventty;
   procedure setvalue(const avalue: integer);
   function getgridvalue(const index: integer): integer;
   procedure setgridvalue(const index, Value: integer);
   function getgridvalues: integerarty;
   procedure setgridvalues(const Value: integerarty);
  {$ifdef mse_with_ifi}
   function getifilink: tifiintegerlinkcomp;
   procedure setifilink(const avalue: tifiintegerlinkcomp);
  {$endif}
   procedure setvaluemin(const avalue: integer);
   procedure setvaluemax(const avalue: integer);
   function getdatalist: tintegerdatalist;
   procedure readmin(reader: treader);
   procedure readmax(reader: treader);
  protected
//   procedure setgridintf(const intf: iwidgetgrid); override;
   procedure setvaluedata(const source); override;
   procedure getvaluedata(out dest); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatalistclass: datalistclassty; override;
   function getdefaultvalue: pointer; override;
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   procedure resetgridvalue(const index: integer); override;
   procedure checkgridvalue(const index: integer); override;
   function gridvaluechecked(const aindex: integer): boolean; override;
   procedure internalcheckvalue(var avalue; var accept: boolean); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure togglevalue(const areadonly: boolean;
                                   const down: boolean); override;
   function ischecked(): boolean; override;
   procedure docheck() override;   //set value to valuedefault+1
   procedure douncheck() override; //set value to valuedefault
   function doinc(var avalue: integer; const down: boolean): boolean;
                                       //false if no change
   procedure paintglyph(const canvas: tcanvas; const acolorglyph: colorty;
                const avalue; const arect: rectty); override;
   procedure datalistdestroyed; override;
   procedure updatedatalist; override;
   procedure defineproperties(filer: tfiler) override;
  public
   function checkvalue(const quiet: boolean = false): boolean override;
   procedure togglegridvalue(const index: integer); override;
   procedure fillcol(const avalue: integer);
   property gridvalue[const index: integer]: integer
        read getgridvalue write setgridvalue; default;
   property gridvalues: integerarty read getgridvalues write setgridvalues;
   function griddata: tgridintegerdatalist;
   property datalist: tintegerdatalist read getdatalist; 
   property onsetvalue: setintegereventty read fonsetvalue write fonsetvalue;
   property value: integer read fvalue write setvalue default 0;
   property valuedefault: integer read fvaluedefault 
                                       write fvaluedefault default 0;
   property valuemin: integer read fvaluemin write setvaluemin default 0; 
                                               //checked by togglevalue
   property valuemax: integer read fvaluemax write setvaluemax default 0; 
                                               //checked by togglevalue
   property onpaintglyph: paintintegerglypheventty read fonpaintglyph 
                                                         write fonpaintglyph;
  published
  {$ifdef mse_with_ifi}
   property ifilink: tifiintegerlinkcomp  read getifilink write setifilink;
  {$endif}
 end;

 tcustomdatabutton = class;
 
 tvaluefacearrayprop = class(tpersistentarrayprop)
  private
   fowner: tcustomdatabutton;
  protected
   function getitems(const index: integer): tface;
   procedure createitem(const index: integer; var item: tpersistent); override;
  public
   constructor create(const aowner: tcustomdatabutton);
   class function getitemclasstype: persistentclassty; override;
   property items[const index: integer]: tface read getitems; default;
 end;

 databuttoneventty = procedure(const sender: tcustomdatabutton) of object;

 tvaluefontarrayprop = class(tpersistentarrayprop)
  private
   fowner: tcustomdatabutton;
   procedure setitems(const index: integer; const avalue: tfont);
  protected
   function getitems(const index: integer): tfont;
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure fontchange(const sender: tobject);
  public
   constructor create(const aowner: tcustomdatabutton);
   class function getitemclasstype: persistentclassty; override;
                         //used in dumpunitgroups
   property items[const index: integer]: tfont read getitems 
                                                   write setitems; default;
 end;
  
 tcustomdatabutton = class(tcustomintegergraphdataedit,iactionlink,iimagelistinfo)
  private
//   fonexecute: notifyeventty;
   fvaluefaces: tvaluefacearrayprop;
   fimageoffset: integer;
   fimagenums: tintegerarrayprop;
   fimagenr: integer;
   fimagenrdisabled: integer;
   fimageoffsetdisabled: integer;
   fimageoffsetmouse: integer;
   fimageoffsetclicked: integer;
   fvaluecaptions: tmsestringarrayprop;
   fonupdate: databuttoneventty;
   fvaluedisabled: integer;
   fvaluefonts: tvaluefontarrayprop;
   procedure setcolorglyph(const avalue: colorty);
   function iscolorglyphstored: boolean;
   procedure setvaluefaces(const avalue: tvaluefacearrayprop);
   procedure setvaluecaptions(const avalue: tmsestringarrayprop);
   procedure setcaption(const avalue: captionty);
   function iscaptionstored: boolean;
   function getimagelist: timagelist;
   procedure setimagelist(const avalue: timagelist);
   function isimageliststored: Boolean;
   procedure setcaptiondist(const avalue: integer);
   procedure setimagepos(const avalue: imageposty);
   procedure setimagenr(const avalue: imagenrty);
   function isimagenrstored: boolean;
   procedure setimageoffset(const avalue: integer);
   procedure setimagenums(const avalue: tintegerarrayprop);
   procedure setimagenrdisabled(const avalue: imagenrty);
   function isimagenrdisabledstored: Boolean;
   procedure setimageoffsetdisabled(const avalue: integer);
   procedure setimagedist(const avalue: integer);
   procedure setimagedist1(const avalue: integer);
   procedure setimagedist2(const avalue: integer);
   procedure setshortcut(const avalue: shortcutty);
   function isshortcutstored: boolean;
   function getshortcut: shortcutty;
   function getshortcut1: shortcutty;
   procedure setshortcut1(const avalue: shortcutty);
   function isshortcut1stored: boolean;
   procedure setonexecute(const avalue: notifyeventty);
   function isonexecutestored: boolean;
   procedure setonbeforeexecute(const avalue: accepteventty);
   function isonbeforeexecutestored: boolean;
   procedure setonafterexecute(const avalue: notifyeventty);
   function isonafterexecutestored: boolean;
   procedure setstate(const avalue: actionstatesty);
   function isstatestored: boolean;

   procedure setaction(const avalue: tcustomaction);
   procedure readcaptionpos(reader: treader);
   procedure settextflags(const avalue: textflagsty);
   procedure setshortcuts(const avalue: shortcutarty);
   procedure setshortcuts1(const avalue: shortcutarty);  
   procedure readshortcut(reader: treader);
   procedure readshortcut1(reader: treader);
   procedure readsc(reader: treader);
   procedure writesc(writer: twriter);
   procedure readsc1(reader: treader);
   procedure writesc1(writer: twriter);
   procedure setimageoffsetmouse(const avalue: integer);
   procedure setimageoffsetclicked(const avalue: integer);
   procedure setvaluedisabled(const avalue: integer);
   procedure setvaluefonts(const avalue: tvaluefontarrayprop);
  protected
   finfo: shapeinfoty;
   factioninfo: actioninfoty;
   procedure doidle(var again: boolean);
   procedure internalexecute;
   procedure doasyncevent(var atag: integer); override;
   procedure defineproperties(filer: tfiler); override;
   procedure loaded; override;
   procedure setenabled(const avalue: boolean); override;
   procedure setvisible(const avalue: boolean); override;

   procedure docellevent(const ownedcol: boolean; 
                       var info: celleventinfoty); override;
   procedure gridtovalue(arow: integer); override;
   
   procedure setcolor(const avalue: colorty); override;
   procedure objectchanged(const sender: tobject); override;
   function getassistiveflags(): assistiveflagsty override;
   function getassistivecaption(): msestring override;

    //iactionlink
   function getactioninfopo: pactioninfoty;
   function shortcutseparator: msechar;
   procedure calccaptiontext(var ainfo: actioninfoty);
   procedure actionchanged;

   procedure setnullvalue;
   procedure doexecute; virtual;
   procedure domousewheelevent(var info: mousewheeleventinfoty); override;
   procedure togglevalue(const areadonly: boolean;
                                 const down: boolean); override;
   procedure statechanged; override;
   function valueenabledstate(const avalue: integer): boolean;
   procedure checkdisabled();
   procedure valuechanged(); override;

   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure dokeyup(var info: keyeventinfoty); override;
   procedure doshortcut(var info: keyeventinfoty;
                                          const sender: twidget); override;
   procedure clientrectchanged; override;
//   function getframestateflags: framestateflagsty; override;
   procedure paintglyph(const canvas: tcanvas; const acolorglyph: colorty;
                  const avalue; const arect: rectty); override;
   procedure internalcreateframe; override;
   procedure setgridintf(const intf: iwidgetgrid); override;
   function checkfocusshortcut(var info: keyeventinfoty): boolean; override;
   procedure setactualimagenr(const avalue: integer);
   procedure setoptions(const avalue: buttonoptionsty); override;
   function verticalfontheightdelta: boolean; override;

   class function classskininfo: skininfoty; override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure execute();
   procedure initnewwidget(const ascale: real); override;
   procedure updatehotkeys() override;
   procedure doupdate;
   procedure synctofontheight; override;
   procedure initgridwidget; override;
   procedure initnewcomponent(const ascale: real); override;
   procedure togglegridvalue(const index: integer); override;
   function checkeditem: tcustomdatabutton; //nil if none
   property valuefaces: tvaluefacearrayprop read fvaluefaces 
                                                     write setvaluefaces;
   property valuecaptions: tmsestringarrayprop read fvaluecaptions
                                                  write setvaluecaptions;
   property valuefonts: tvaluefontarrayprop read fvaluefonts
                                                  write setvaluefonts;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property action: tcustomaction read factioninfo.action write setaction;
   property caption: captionty read factioninfo.captiontext write setcaption 
                                                        stored iscaptionstored;
   property textflags: textflagsty read finfo.ca.textflags 
                         write settextflags default defaultcaptiontextflags;
   property imagepos: imageposty read finfo.ca.imagepos write setimagepos
                              default ip_center;
//   property captionpos: captionposty read finfo.ca.captionpos write setcaptionpos
//                              default cp_center;
   property captiondist: integer read finfo.ca.captiondist write setcaptiondist
                            default defaultshapecaptiondist;
   property imagelist: timagelist read getimagelist write setimagelist
                    stored isimageliststored;
   property imagenr: imagenrty read factioninfo.imagenr write setimagenr
                            stored isimagenrstored default -1;
   property imagenrdisabled: imagenrty read factioninfo.imagenrdisabled
                              write setimagenrdisabled
                            stored isimagenrdisabledstored default -2;
                      //-1 = none, -2 = grayed, -3 = imageoffsetdisabled
   property imagedist: integer read finfo.ca.imagedist 
                                               write setimagedist default 0;
   property imagedist1: integer read finfo.ca.imagedist1
                                               write setimagedist1 default 0;
   property imagedist2: integer read finfo.ca.imagedist2
                                            write setimagedist2 default 0;
   property colorglyph: colorty read factioninfo.colorglyph write setcolorglyph
                      stored iscolorglyphstored default cl_default;
   property shortcut: shortcutty read getshortcut write setshortcut
                            stored false default 0;
   property shortcut1: shortcutty read getshortcut1 write setshortcut1
                            stored false default 0;
   property shortcuts: shortcutarty read factioninfo.shortcut 
                                              write setshortcuts;
   property shortcuts1: shortcutarty read factioninfo.shortcut1 
                                                       write setshortcuts1;
   property onupdate: databuttoneventty read fonupdate write fonupdate;
   property onexecute: notifyeventty read factioninfo.onexecute
                            write setonexecute stored isonexecutestored;
   property onbeforeexecute: accepteventty read factioninfo.onbeforeexecute
                   write setonbeforeexecute stored isonbeforeexecutestored;
   property onafterexecute: notifyeventty read factioninfo.onafterexecute
                         write setonafterexecute stored isonafterexecutestored;

   property imageoffset: integer read fimageoffset 
                                              write setimageoffset default 0;
   property imageoffsetdisabled: integer read fimageoffsetdisabled
                                 write setimageoffsetdisabled default 0;
   property imageoffsetmouse: integer read fimageoffsetmouse 
                                       write setimageoffsetmouse default 0;
   property imageoffsetclicked: integer read fimageoffsetclicked 
                                       write setimageoffsetclicked default 0;
   property imagenums: tintegerarrayprop read fimagenums write setimagenums;

   property options;
   property focusrectdist: integer read finfo.focusrectdist
            write finfo.focusrectdist default defaultshapefocusrectdist;
   property onsetvalue;
   property value default -1;
   property valuedefault default -1;
   property valuedisabled: integer read fvaluedisabled 
                                      write setvaluedisabled default -2; 
                  //button.enabled:= value <> valuedisabled
                  //-2 -> not checked
   property valuemin default -1; 
   property valuemax default 0;
   property optionswidget default defaultoptionswidget - [ow_mousefocus];
  published
   property visible stored false;
   property enabled stored false;
   property state: actionstatesty read factioninfo.state write setstate 
                             stored isstatestored default [];
 end;

 tdatabutton = class(tcustomdatabutton)
  published
   property optionswidget;
   property optionsskin;
   property valuefaces;
   property valuecaptions;
   property valuefonts;
   property font;

   property action;
   property caption;
   property textflags;
   property shortcut;
   property shortcut1;
   property imagepos;
   property captiondist;
   property imagelist;
   property imagenr;
   property imagenrdisabled;
   property imagedist;
   property imagedist1;
   property imagedist2;
   property colorglyph;
   property options;
   property focusrectdist;
   property onupdate;
   property onexecute;
   property onbeforeexecute;
   property onafterexecute;
   property onmouseevent;
   property onclientmouseevent;

   property imageoffset;
   property imageoffsetdisabled;
   property imageoffsetmouse;
   property imageoffsetclicked;
   property imagenums;
   property onsetvalue;
   property onpaintglyph;
   property group;
   property value;
   property valuedefault;
   property valuemin; 
   property valuemax;
   property valuedisabled;
 end;

 tstockglyphdatabutton = class(tcustomdatabutton)
  private
   fglyph: stockglyphty;
   procedure setglyph(const avalue: stockglyphty);
  public
   constructor create(aowner: tcomponent); override;
  published
   property action;
   
   property glyph: stockglyphty read fglyph write setglyph default stg_none;
   property imagenums;
   property optionswidget;
   property optionsskin;
   property valuefaces;
   property font;
   property caption;
   property textflags;
   property imagepos;
   property captiondist;
   property options;
   property imagedist;
   property imagedist1;
   property imagedist2;
   property focusrectdist;
   property onupdate;
   property onexecute;
   property onbeforeexecute;
   property onafterexecute;
   property onsetvalue;
   property onpaintglyph;
   property onmouseevent;
   property onclientmouseevent;
   property value;
   property valuedefault;
   property valuemin; 
   property valuemax;
   property valuedisabled;
 end; 
 
 tcustomdataicon = class(tcustomintegergraphdataedit)
 //if value = -1 then blank else
 // if value < 0 then imagenums[0..30] are painted if bit[0..30] is 1
 //  else image[value] is painted
  private
   fimagelist: timagelist;
   fimageoffset: integer;
   fimagenums: tintegerarrayprop;
   procedure setimagelist(const aValue: timagelist);
   procedure setimageoffset(const aValue: integer);
   procedure imagenumschanged(const sender: tarrayprop; const index: integer);
   procedure setimagenums(const avalue: tintegerarrayprop);
  protected
   procedure setnullvalue;
   procedure paintglyph(const canvas: tcanvas; const acolorglyph: colorty;
                const avalue; const arect: rectty); override;
   procedure objectevent(const sender: tobject;
                             const event: objecteventty); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property imagelist: timagelist read fimagelist write setimagelist;
   property imageoffset: integer read fimageoffset write setimageoffset default 0;
   property imagenums: tintegerarrayprop read fimagenums write setimagenums;
   property valuedefault default -1;
   property value default -1;
  published
   property visible;
   property enabled;
 end;
 
 tdataicon = class(tcustomdataicon)
  published
   property onsetvalue;
   property onpaintglyph;
   property value default -1;
   property valuedefault default -1;
   property valuemin; 
   property valuemax;
   property imagelist;
   property imageoffset;
   property imagenums;
 end;
 
implementation
uses
 SysUtils,msekeyboard,msebits,msereal,msedispwidgets,mseformatstr,mserichstring,
 mseactions,msestreaming,mseassistiveserver;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 tcustomframe1 = class(tcustomframe);
 tdatalist1 = class(tdatalist);
 twidgetcol1 = class(twidgetcol);
 twidget1 = class(twidget);
 tarrayprop1 = class(tarrayprop);
 tcustomwidgetgrid1 = class(tcustomwidgetgrid);
 twidgetdatacol1 = class(twidgetcol);

const
 valuevarname = 'value';

{ tgrapheditframe }

constructor tgrapheditframe.create(const aintf: icaptionframe);
begin
 inherited;
 options:= defaultgrapheditframeoptions;
 fstate:= fstate + [fs_drawfocusrect,fs_captionfocus,fs_captionhint,
                     fs_paintrectfocus];
 fi.levelo:= -2;
 captionpos:= cp_right;
 internalupdatestate;
end;
{
function tgrapheditframe.actualcolorclient(): colorty;
begin
 result:= fi.colorclient;
 if result = cl_default then begin
  result:= cl_transparent;
 end;
end;
}
{
function tgrapheditframe.getdefaultcolorclient: colorty;
begin
 result:= cl_transparent;
end;
}
{ ttogglegrapheditframe }

function ttogglegrapheditframe.actualcolorclient: colorty;
begin
 result:= fi.colorclient;
 if result = cl_default then begin
  result:= cl_foreground;
 end;
end;
{
function ttogglegrapheditframe.getdefaultcolorclient: colorty;
begin
 result:= cl_foreground;
end;
}
{ tsliderscrollbar }

constructor tsliderscrollbar.create(intf: iscrollbar; org: originty;
  ondimchanged: proceventty);
begin
 inherited;
 foptions:= defaultsliderscrollbaroptions;
 buttonlength:= defaultbuttonminlength;
// fface:= tface.create(iface(self));
end;

destructor tsliderscrollbar.destroy;
begin
 inherited;
end;

{
function tsliderscrollbar.getwidget: twidget;
begin
 result:= fintf.getwidget;
end;
}
{
function tsliderscrollbar.translatecolor(const acolor: colorty): colorty;
begin
 result:= fintf.translatecolor(acolor);
end;

procedure tsliderscrollbar.paint(const canvas: tcanvas;
                                          const acolor: colorty = cl_none);
begin
 if fface <> nil then begin
  fface.paint(canvas,fdrawinfo.scrollrect);
 end;
 inherited;
end;
}
{
procedure tsliderscrollbar.invalidate;
begin
 fintf.getwidget.invalidate;
end;
}
{
function tsliderscrollbar.getclientrect: rectty;
begin
 result:= fintf.getwidget.clientrect;
end;
}
{
procedure tsliderscrollbar.setlinkedvar(const source: tmsecomponent;
               var dest: tmsecomponent; const linkintf: iobjectlink = nil);
begin
 twidget1(fintf.getwidget).setlinkedvar(source,dest,linkintf);
end;
}
{
function tsliderscrollbar.getcomponentstate: tcomponentstate;
begin
 result:= fintf.getwidget.componentstate;
end;
}
{
procedure tsliderscrollbar.widgetregioninvalid;
begin
 twidget1(fintf.getwidget).widgetregioninvalid;
end;
}
{ tcustomrealgraphdataedit }

constructor tcustomrealgraphdataedit.create(aowner: tcomponent);
begin
 inherited;
 size:= makesize(defaultsliderwidth,defaultsliderheight);
end;

procedure tcustomrealgraphdataedit.setvalue(const avalue: realty);
begin
 if fvalue <> avalue then begin
  if not (des_isdb in fstate) and (avalue = emptyreal) then begin
   fvalue:= 0;
  end
  else begin
   fvalue:= avalue;
  end;
  valuechanged;
 end;
end;

function tcustomrealgraphdataedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridrealdatalist.create(sender);
end;

function tcustomrealgraphdataedit.getdatalistclass: datalistclassty;
begin
 result:= tgridrealdatalist;
end;

procedure tcustomrealgraphdataedit.internalcheckvalue(var avalue; var accept: boolean);
begin
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,realty(avalue),accept);
 end;
{$ifdef mse_with_ifi}
 ifisetvalue(avalue,accept);
{$endif} 
 if accept then begin
  value:= realty(avalue);
 end;
end;

procedure tcustomrealgraphdataedit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure tcustomrealgraphdataedit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomrealgraphdataedit.readstatvalue(const reader: tstatreader);
begin
 value:= reader.readreal(valuevarname,fvalue);
end;

procedure tcustomrealgraphdataedit.writestatvalue(const writer: tstatwriter);
begin
 writer.writereal(valuevarname,fvalue);
end;

procedure tcustomrealgraphdataedit.setdirection(const avalue: graphicdirectionty);
begin
 if fdirection <> avalue then begin
  if not (csreading in componentstate) then begin
   changedirection(avalue,fdirection);  
  end
  else begin
   fdirection:= avalue;
  end;
 end;
end;

function tcustomrealgraphdataedit.getgridvalue(const index: integer): realty;
begin
 internalgetgridvalue(index,result);
end;

procedure tcustomrealgraphdataedit.setgridvalue(const index: integer;
               const avalue: realty);
begin
 internalsetgridvalue(index,avalue);
end;

function tcustomrealgraphdataedit.getgridvalues: realarty;
begin
 result:= trealdatalist(checkgriddata).asarray;
end;

procedure tcustomrealgraphdataedit.setgridvalues(const avalue: realarty);
begin
 trealdatalist(checkgriddata).asarray:= avalue;
end;

procedure tcustomrealgraphdataedit.fillcol(const value: realty);
begin
 internalfillcol(value);
end;

procedure tcustomrealgraphdataedit.assigncol(const avalue: trealdatalist);
begin
 internalassigncol(avalue);
end;

function tcustomrealgraphdataedit.isnull: boolean;
begin
 result:= value = emptyreal;
end;

procedure tcustomrealgraphdataedit.setnullvalue;
begin
 value:= emptyreal;
end;

function tcustomrealgraphdataedit.checkvalue(
                                   const quiet: boolean = false): boolean;
begin
 result:= docheckvalue(fvalue,quiet);
end;

{$ifdef mse_with_ifi}
function tcustomrealgraphdataedit.getifilink: tifireallinkcomp;
begin
 result:= tifireallinkcomp(fifilink);
end;

procedure tcustomrealgraphdataedit.setifilink(const avalue: tifireallinkcomp);
begin
 inherited setifilink(avalue);
end;

{$endif}

function tcustomrealgraphdataedit.griddata: tgridrealdatalist;
begin
 result:= tgridrealdatalist(inherited griddata);
end;

procedure tcustomrealgraphdataedit.paintglyph(const canvas: tcanvas;
               const acolorglyph: colorty; const avalue; const arect: rectty);
var
 int1: integer;
 val1: real;
begin
 if canevent(tmethod(fonpaintglyph)) then begin
  if @avalue = nil then begin
   val1:= fvalue;
   int1:= gridrow;
  end
  else begin
   val1:= real(avalue);
   int1:= pcellinfoty(canvas.drawinfopo)^.cell.row;
  end;
  fonpaintglyph(self,canvas,val1,int1);
 end;
end;

procedure tcustomrealgraphdataedit.internalcreateframe;
begin
 tsliderframe.create(iscrollframe(self));
end;

procedure tcustomrealgraphdataedit.setvaluedata(const source);
begin
 value:= realty(source);
end;

procedure tcustomrealgraphdataedit.getvaluedata(out dest);
begin
 realty(dest):= value;
end;

{ tcustomslider }

constructor tcustomslider.create(aowner: tcomponent);
begin
 fscrollbar:= tsliderscrollbar.create(iscrollbar(self));
// fscrollbar.options:= [sbo_moveauto];
 inherited;
 optionswidget:= defaultslideroptionswidget;
 size:= makesize(defaultsliderwidth,defaultsliderheight);
end;

destructor tcustomslider.destroy;
begin
 fscrollbar.Free;
 inherited;
end;

procedure tcustomslider.paintglyph(const canvas: tcanvas;
               const acolorglyph: colorty; const avalue; const arect: rectty);
var
 rea1,rea2: realty;
 col1: colorty;
 bo1: boolean;
begin
 bo1:= false;
 col1:= cl_none;
 if @avalue = nil then begin
  rea1:= fvalue;
 end
 else begin
  rea1:= realty(avalue); //cell
  if (fgridintf <> nil) then begin
   with cellinfoty(canvas.drawinfopo^) do begin
    col1:= color;
    canvas.move(innerrect.pos);
   end;
  end
  else begin
   if fparentintf <> nil then begin
    canvas.move(arect.pos); //innerrext?
   end;
  end;
 end;
 if rea1 = emptyreal then begin
  rea1:= 0;
 end;
 beginpaint();
 rea2:= fscrollbar.value;
 if @avalue <> nil then begin //cell
  fscrollbar.value:= rea1;
  bo1:= fscrollbar.focused;
  fscrollbar.focused:= false;
 end
 else begin
  if not fscrollbar.buttonmoving then begin
   fscrollbar.value:= rea1;
   rea2:= rea1;
  end;
 end;
 fscrollbar.paint(canvas,col1);
 fscrollbar.value:= rea2;
 if @avalue <> nil then begin
  fscrollbar.focused:= bo1;
  if (fgridintf <> nil) then begin
   canvas.remove(cellinfoty(canvas.drawinfopo^).innerrect.pos);
  end
  else begin
    canvas.remove(arect.pos); //innerrext?
  end;
 end;
 endpaint();
 inherited;
end;

procedure tcustomslider.setdirection(const avalue: graphicdirectionty);
begin
 fscrollbar.direction:= avalue;
 inherited;
end;

procedure tcustomslider.clientrectchanged;
begin
 inherited;
 fscrollbar.dim:= innerclientrect;
end;

procedure tcustomslider.clientmouseevent(var info: mouseeventinfoty);
begin
 if not (es_processed in info.eventstate) and
               not (csdesigning in componentstate) and
                          not (oe_readonly in getoptionsedit) then begin
  fscrollbar.mouseevent(info);
 end;
 inherited;
end;

procedure tcustomslider.domousewheelevent(var info: mousewheeleventinfoty);
begin
 scrollbar.mousewheelevent(info);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tcustomslider.dokeydown(var info: keyeventinfoty);
begin
 if not (es_processed in info.eventstate) and 
                not (csdesigning in componentstate) and
                          not (oe_readonly in getoptionsedit) then begin
  fscrollbar.keydown(info);
 end;
 inherited;
end;

procedure tcustomslider.scrollevent(sender: tcustomscrollbar;
                                                      event: scrolleventty);
var
 rea1: realty;
begin
 case event of
  sbe_setvalue{valuechanged}: begin
   if fupdating = 0 then begin
    inc(fupdating);
    rea1:= sender.value;
    if not docheckvalue(rea1,false) then begin
     sender.value:= value;
    end
    else begin
     sender.value:= rea1;
    end;
    dec(fupdating);
   end;
  end;
 end;
end;

procedure tcustomslider.doenter;
begin
 fscrollbar.enter;
 inherited;
end;

procedure tcustomslider.doexit;
begin
 fscrollbar.exit;
 inherited;
end;

procedure tcustomslider.activechanged;
begin
 fscrollbar.activechanged();
 inherited;
end;

procedure tcustomslider.enabledchanged;
begin
 fscrollbar.disabled:= not enabled;
end;

procedure tcustomslider.setscrollbar(const avalue: tsliderscrollbar);
begin
 fscrollbar.assign(avalue);
end;

procedure tcustomslider.beginpaint();
begin
 inc(fupdating);
 inc(fnoinvalidate);
end;

procedure tcustomslider.endpaint();
begin
 dec(fupdating);
 dec(fnoinvalidate);
end;

procedure tcustomslider.dochange;
begin
 inc(fupdating);
 fscrollbar.value:= fvalue;
 dec(fupdating);
 inherited;
end;

procedure tcustomslider.objectchanged(const sender: tobject);
begin
 inherited;
 fscrollbar.checktemplate(sender);
end;

procedure tcustomslider.initgridwidget;
begin
 inherited;
 fscrollbar.options:= fscrollbar.options + 
                       [sbo_noarrowkeys,sbo_nopagekeys,sbo_noreflectedclick];
// color:= cl_parent;
 if fgridintf <> nil then begin
  with fgridintf.getcol do begin
   if self.color = cl_default then begin
    color:= cl_parent;
   end
   else begin
    color:= self.color;
   end;
   options:= options - [co_drawfocus];
  end;
 end;
end;

class function tcustomslider.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_slider;
end;

{ tgraphdataedit }

constructor tgraphdataedit.create(aowner: tcomponent);
begin
 foptionsedit:= defaultoptionsedit;
 foptionsedit1:= defaultoptionsedit1;
 inherited;
 fcolorglyph:= cl_default;
end;

procedure tgraphdataedit.internalcreateframe;
begin
 tgrapheditframe.create(iscrollframe(self));
end;

procedure tgraphdataedit.enabledchanged();
begin
 inherited;
 invalidate();
end;

procedure tgraphdataedit.setcolorglyph(const Value: colorty);
begin
 if fcolorglyph <> value then begin
  fcolorglyph := Value;
  invalidate;
 end;
end;

procedure tgraphdataedit.paint(const canvas: tcanvas);
begin
 if (fgridintf = nil) or 
                 not (twidgetcol1(fgridintf.getcol).checkautocolwidth) then begin
  inherited;
 end;
end;

procedure tgraphdataedit.dopaintforeground(const canvas: tcanvas);
var
 col1: colorty;
begin
 inherited;
 col1:= fcolorglyph;
 if col1 = cl_font then begin
  if (fgridintf <> nil) and (ffont = nil) then begin
   with fgridintf.getcol do begin
    col1:= rowfont(grid.row).color;
   end;
  end
  else begin
   col1:= getfont1.color;
  end;
 end;
 if (innerclientrect.cx > 0) and (innerclientrect.cy > 0) then begin
  paintglyph(canvas,col1,nil^,innerclientrect);
 end;
 if (fgridintf <> nil) and not (csdesigning in componentstate) then begin
  fgridintf.widgetpainted(canvas);
 end;
end;

function tgraphdataedit.needsfocuspaint: boolean;
begin
 result:= (fgridintf = nil) and inherited needsfocuspaint;
end;

procedure tgraphdataedit.dofontheightdelta(var delta: integer);
begin
 inherited;
 gridwidgetfontheightdelta(self,fgridintf,delta);
end;

procedure tgraphdataedit.sizechanged;
begin
 inherited;
 gridwidgetsized(self,fgridintf);
end;

procedure tgraphdataedit.dochange;
begin
 if not (ws_loadedproc in fwidgetstate) then begin
  if assistiveserver <> nil then begin
   assistiveserver.dochange(getiassistiveclient());
  end;
  if canevent(tmethod(fonchange)) then begin
   fonchange(self);
  end;
{$ifdef mse_with_ifi}
  if fifiserverintf <> nil then begin
   iifidataserver(fifiserverintf).valuechanged(iifidatalink(self));
  end;
{$endif}
 end;
 invalidate;
end;

procedure tgraphdataedit.setgridintf(const intf: iwidgetgrid);
begin
 fgridintf:= intf;
 if fgridintf <> nil then begin
  fdatalist:= fgridintf.getcol.datalist;
  if fdatalist <> nil then begin
   updatedatalist;
  end;
  fgriddatalink:= tcustomwidgetgrid1(fgridintf.getgrid).getgriddatalink;
 end
 else begin
  fdatalist:= nil;
  fgriddatalink:= nil;
 end;
 {$ifdef mse_with_ifi}
{
 if fgridintf <> nil then begin
  if (fifilink <> nil) and (fifilink.controller.datalist <> nil) then begin
   updateifigriddata(fifilink.controller.datalist);
  end;
 end;
}
{$endif}

end;

function tgraphdataedit.getcellframe: framety;
begin
 if fframe <> nil then begin
  result:= fframe.cellframe;
 end
 else begin
  result:= nullframe;
 end;
end;

function tgraphdataedit.needscellfocuspaint(): boolean;
begin
 result:= inherited needsfocuspaint();
end;

procedure tgraphdataedit.drawcell(const canvas: tcanvas);
var
 col1: colorty;
 rect1: rectty;
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  if datapo <> nil then begin
   col1:= fcolorglyph;
   if col1 = cl_font then begin
    col1:= font.color;
   end;
   if (fgridintf = nil) and (fparentintf <> nil) and 
                                  (oe1_nocellpaint in optionsedit1) then begin
    if (fwidgetrect.cx > 0) and (fwidgetrect.cy > 0) then begin
     paintbackground(canvas,widgetrect);
     rect1:= self.innerparentrect;
     if (rect1.cx > 0) and (rect1.cy > 0) then begin
      paintglyph(canvas,col1,datapo^,rect1);
     end;
     paintoverlay(canvas,widgetrect);
    end;
   end
   else begin
    if (innerrect.cx > 0) and (innerrect.cy > 0) then begin
     paintglyph(canvas,col1,datapo^,innerrect);
    end;
   end;
  end;
 end;
end;

procedure tgraphdataedit.updateautocellsize(const canvas: tcanvas);
begin
 //dummy;
end;

procedure tgraphdataedit.initgridwidget;
begin
 defaultinitgridwidget(self,fgridintf);
 if fgridintf <> nil then begin
  fgridintf.getcol.options:= fgridintf.getcol.options + [co_drawfocus];
 end;
end;

function tgraphdataedit.docheckvalue(var avalue; const quiet: boolean): boolean;
begin
 if fgridintf <> nil then begin
  fgridintf.edited();
 end;
 result:= true;
 internalcheckvalue(avalue,result);
 if result then begin
  fedited:= false;
  if fparentintf <> nil then begin
   fparentintf.childdataentered(igridwidget(self));
  end;
  if canevent(tmethod(fondataentered)) then begin
   fondataentered(self);
  end;
 {$ifdef mse_with_ifi}
  if fifiserverintf <> nil then begin
   fifiserverintf.dataentered(iifidatalink(self),gridrow);
  end;
 {$endif}
  if (oe1_sendchangeeventbycheckvalue in optionsedit1) then begin
   sendchangeevent();
  end;
  if canassistive() and not quiet then begin
   assistiveserver.dodataentered(iassistiveclientdata(getiassistiveclient()));
  end;
 end;
end;

procedure tgraphdataedit.dofocus;
begin
 if fparentintf <> nil then begin
  fparentintf.childfocused(igridwidget(self));
 end;
 inherited;
end;

{
function tgraphdataedit.edited: boolean;
begin
 result:= fedited;
end;
}
procedure tgraphdataedit.initeditfocus;
begin
 //dummy
end;

procedure tgraphdataedit.initnewwidget(const ascale: real);
begin
 if fgridintf <> nil then begin
  fgridintf.getcol.options:= 
                fgridintf.getcol.grid.datacols.options + [co_drawfocus];
                          //restore default options
 end;
 inherited;
end;

function tgraphdataedit.actualcolor: colorty;
begin
 if (fgridintf <> nil) and (fcolor = cl_default) then begin
  result:= fgridintf.getcol.rowcolor(fgridintf.getrow);
 end
 else begin
  result:= inherited actualcolor;
 end;
end;

procedure tgraphdataedit.initnewcomponent(const ascale: real);
begin
 inherited;
 internalcreateframe;
 fframe.scale(ascale);
end;

function tgraphdataedit.getstatvarname: msestring;
begin
 result:= fstatvarname;
end;

procedure tgraphdataedit.dostatread(const reader: tstatreader);
begin
 fvalueread:= false;
 if not (des_isdb in fstate) and (fgridintf = nil) and 
                        canstatvalue(foptionsedit1,reader) then begin
  fvalueread:= true;
  readstatvalue(reader);
 end;
 if canstatstate(foptionsedit1,reader) then begin
  readstatstate(reader);
 end;
 if canstatoptions(foptionsedit1,reader) then begin
  readstatoptions(reader);
 end;
end;

procedure tgraphdataedit.dostatwrite(const writer: tstatwriter);
begin
 if not (des_isdb in fstate) and (fgridintf = nil) and 
                                 canstatvalue(foptionsedit1,writer) then begin
  writestatvalue(writer);
 end;
 if canstatstate(foptionsedit1,writer) then begin
  writestatstate(writer);
 end;
 if canstatoptions(foptionsedit1,writer) then begin
  writestatoptions(writer);
 end;
end;

procedure tgraphdataedit.setstatfile(const Value: tstatfile);
begin
 setstatfilevar(istatfile(self),value,fstatfile);
end;

procedure tgraphdataedit.statreading;
begin
 //dummy
end;

procedure tgraphdataedit.statread;
begin
 if (oe1_checkvalueafterstatread in foptionsedit1) and fvalueread then begin
  checkvalue(true);
 end;
end;

procedure tgraphdataedit.setfirstclick(var ainfo: mouseeventinfoty);
begin
 //dummy
end;

function tgraphdataedit.getdefaultvalue: pointer;
begin
 result:= nil;
end;

function tgraphdataedit.getrowdatapo(const arow: integer): pointer;
begin
 result:= nil;
end;

function tgraphdataedit.getgridintf: iwidgetgrid;
begin
 result:= fgridintf;
end;

procedure tgraphdataedit.checkgrid;
begin
 if fgridintf = nil then begin
  raise exception.Create('No grid.');
 end;
end;

function tgraphdataedit.checkgriddata: tdatalist;
begin
 if fgridintf = nil then begin
  raise exception.Create('No grid.');
 end;
 result:= fdatalist;
 if result = nil then begin
  raise exception.Create('No datalist.');
 end;
end;

function tgraphdataedit.seteditfocus: boolean;
begin
 if not readonly then begin
  if fgridintf = nil then begin
   if canfocus then begin
    setfocus;
   end;
  end
  else begin
   with fgridintf.getcol do begin
    grid.col:= index;
    if grid.canfocus then begin
     if not focused then begin
      grid.setfocus;
     end;
    end; 
   end;
  end;
 end;
 result:= focused;
end;

function tgraphdataedit.griddata: tdatalist;
begin
 checkgrid;
 result:= fdatalist;
end;

function tgraphdataedit.widgetcol: twidgetcol;
begin
 if fgridintf = nil then begin
  result:= nil;
 end
 else begin
  result:= fgridintf.getcol;
 end;
end;

function tgraphdataedit.grid: tcustomwidgetgrid;
begin
 if fgridintf = nil then begin
  result:= nil;
 end
 else begin
  result:= fgridintf.getgrid;
 end;
end;

function tgraphdataedit.gridrow: integer;
begin
 if fgridintf = nil then begin
  result:= -1;
 end
 else begin
  result:= fgridintf.getcol.grid.row;
 end;
end;

function tgraphdataedit.gridrowhigh: int32;
begin
 if fgridintf = nil then begin
  result:= -1;
 end
 else begin
  result:= fgridintf.getcol.grid.rowhigh;
 end;
end;

function tgraphdataedit.griddatarowhigh: int32;
begin
 if fgridintf = nil then begin
  result:= -1;
 end
 else begin
  result:= fgridintf.getcol.grid.datarowhigh;
 end;
end;

function tgraphdataedit.gridcol: integer;
begin
 if fgridintf = nil then begin
  result:= -1;
 end
 else begin
  result:= fgridintf.getcol.index;
 end;
end;

procedure tgraphdataedit.gridtovalue(row: integer);
begin
 invalidate;
 //dochange;
end;

function tgraphdataedit.getnulltext: msestring;
begin
 result:= '';
end;

function tgraphdataedit.getassistivecelltext(const arow: int32): msestring;
begin
 result:= '';
end;

procedure tgraphdataedit.readstatoptions(const reader: tstatreader);
begin
 //dummy
end;

procedure tgraphdataedit.readstatstate(const reader: tstatreader);
begin
 //dummy
end;

procedure tgraphdataedit.readstatvalue(const reader: tstatreader);
begin
 //dummy
end;

procedure tgraphdataedit.writestatoptions(const writer: tstatwriter);
begin
 //dummy
end;

procedure tgraphdataedit.writestatstate(const writer: tstatwriter);
begin
 //dummy
end;

procedure tgraphdataedit.writestatvalue(const writer: tstatwriter);
begin
 //dummy
end;

function tgraphdataedit.geteditstate: dataeditstatesty;
begin
 result:= fstate;
end;

procedure tgraphdataedit.seteditstate(const avalue: dataeditstatesty);
begin
 fstate:= avalue;
end;
{
procedure tgraphdataedit.setisdb;
begin
 fisdb:= true;
end;
}
function tgraphdataedit.getoptionsedit: optionseditty;
begin
 result:= foptionsedit;
{$ifdef mse_with_ifi}
 if fifiserverintf <> nil then begin
  fifiserverintf.updateoptionsedit(result);
 end;
{$endif}
end;

procedure tgraphdataedit.updateoptions;
begin
 //dummy
end;

procedure tgraphdataedit.setoptionsedit(const avalue: optionseditty);
begin
 if foptionsedit <> avalue then begin
  transferoptionsedit(self,avalue,foptionsedit,foptionsedit1);
                           //move deprecated flags
  if fgridintf <> nil then begin
   fgridintf.updateeditoptions(foptionsedit,foptionsedit1);
  end;
  updateoptions;
 end;
end;

procedure tgraphdataedit.setoptionsedit1(const avalue: optionsedit1ty);
begin
 if foptionsedit1 <> avalue then begin
  foptionsedit1:= avalue;
  if fgridintf <> nil then begin
   fgridintf.updateeditoptions(foptionsedit,foptionsedit1);
  end;
  updateoptions;
 end;
end;

function tgraphdataedit.sortfunc(const l, r): integer;
begin
 result:= tdatalist1(twidgetcol1(fgridintf.getcol).fdata).compare(l,r);
end;

procedure tgraphdataedit.internalgetgridvalue(index: integer;
  out value);
begin
 checkgrid;
 fgridintf.getdata(index,value);
end;

procedure tgraphdataedit.internalsetgridvalue(index: integer;
                                                        const avalue);
begin
 checkgrid;
 fgridintf.setdata(index,avalue);
end;

procedure tgraphdataedit.docellevent(const ownedcol: boolean; var info: celleventinfoty);
begin
 //dummy
end;

procedure tgraphdataedit.valuechanged();
begin
 if not (csloading in componentstate) then begin
  if (fgridintf <> nil) and not (csdesigning in componentstate) then begin
   valuetogrid(fgridintf.getrow);
  end;
  if not (ws_loadedproc in fwidgetstate) then begin
   modified;
  end;
  dochange;
 end;
end;

procedure tgraphdataedit.formatchanged();
begin
 if not (csloading in componentstate) then begin
  if fgridintf <> nil then begin
   fgridintf.changed;
  end;
  invalidate();
  checkautosize();
 end;
end;

procedure tgraphdataedit.loaded();
begin
 inherited;
 include(fwidgetstate,ws_loadedproc);
 try
  valuechanged;
  formatchanged;
 finally
  exclude(fwidgetstate,ws_loadedproc);
 end;
end;

procedure tgraphdataedit.gridvaluechanged(const index: integer);
begin
 //dummy
end;

procedure tgraphdataedit.updatecoloptions(const aoptions: coloptionsty);
var
 opt1: optionseditty;
 opt2: optionsedit1ty;
begin
 opt1:= foptionsedit;
 opt2:= foptionsedit1;
 fgridintf.coloptionstoeditoptions(opt1,opt2);
 optionsedit:= opt1;
 optionsedit1:= opt2;
end;

procedure tgraphdataedit.updatecoloptions1(const aoptions: coloptions1ty);
begin
 //dummy
end;

procedure tgraphdataedit.statdataread;
begin
 //dummy
end;

procedure tgraphdataedit.griddatasourcechanged;
begin
 //dummy
end; 

procedure tgraphdataedit.updatereadonlystate;
begin
 //dummy
end;

procedure tgraphdataedit.internalfillcol(const value);
begin
 with tdatalist1(checkgriddata) do begin
  internalfill(count,value);
 end;
end;

procedure tgraphdataedit.internalassigncol(const value);
begin
 checkgrid;
 with fgridintf.getcol do begin
  datalist.Assign(tdatalist(value));
 end;
end;

procedure tgraphdataedit.setenabled(const avalue: boolean);
begin
 inherited;
 if (fgridintf <> nil) and not (csloading in componentstate){ and 
                                 not (des_noenablesync in fstate)} then begin
  fgridintf.getcol.enabled:= avalue;
 end;
end;

function tgraphdataedit.getreadonly: boolean;
begin
 result:= oe_readonly in foptionsedit;
end;

procedure tgraphdataedit.setreadonly(const avalue: boolean);
begin
 if avalue then begin
  optionsedit:= optionsedit + [oe_readonly];
 end
 else begin
  optionsedit:= optionsedit - [oe_readonly];
 end;  
end;

procedure tgraphdataedit.beforecelldragevent(var ainfo: draginfoty;
               const arow: integer; var handled: boolean);
begin
 //dummy
end;

procedure tgraphdataedit.aftercelldragevent(var ainfo: draginfoty;
               const arow: integer; var handled: boolean);
begin
 //dummy
end;

procedure tgraphdataedit.fontchanged;
begin
 inherited;
 if fcolorglyph = cl_font then begin
  invalidate;
 end;
end;

procedure tgraphdataedit.modified;
begin
 //dummy
end;

function tgraphdataedit.getcellcursor(const arow: integer;
             const acellzone: cellzonety; const apos: pointty): cursorshapety;
begin
 result:= actualcursor(nullpoint);
end;

procedure tgraphdataedit.updatecellzone(const arow: integer;
                                  const apos: pointty; var result: cellzonety);
begin
 //dummy
end;

procedure tgraphdataedit.datalistdestroyed;
begin
 fdatalist:= nil;
end;

{$ifdef mse_with_ifi}
function tgraphdataedit.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidatalink);
end;

function tgraphdataedit.getifilink: tifilinkcomp;
begin
 result:= fifilink;
end;

function tgraphdataedit.getifidatatype(): listdatatypety;
begin
 result:= getdatalistclass().datatype();
end;

procedure tgraphdataedit.setifilink(const avalue: tifilinkcomp);
begin
 mseificomp.setifilinkcomp(iifidatalink(self),avalue,tifilinkcomp(fifilink));
end;

procedure tgraphdataedit.ifisetvalue(var avalue; var accept: boolean);
begin
 if accept and (fifiserverintf <> nil) then begin
  iifidataserver(fifiserverintf).setvalue(
                         iifidatalink(self),avalue,accept,gridrow);
 end;
end;

procedure tgraphdataedit.getifivalue(var avalue);
begin
 //dummy
end;

procedure tgraphdataedit.setifivalue(const avalue);
begin
 //dummy
end;
{
function tgraphdataedit.ifigriddata: tdatalist;
begin
 result:= nil;
 if fgridintf <> nil then begin
  result:= fdatalist;
 end;
end;
}
procedure tgraphdataedit.updateifigriddata(const sender: tobject; 
                                                    const alist: tdatalist);
begin
 if fgridintf <> nil then begin
  fgridintf.updateifigriddata(alist);
 end;
end;

function tgraphdataedit.getgriddata: tdatalist;
begin
 result:= nil;
 if fgridintf <> nil then begin
  result:= fdatalist;
 end;
end;

function tgraphdataedit.getvalueprop: ppropinfo;
begin
  result:= getpropinfo(self,'value');
end;

function tgraphdataedit.getiassistiveclient(): iassistiveclient;
begin
 result:= iassistiveclientgridwidget(self);
end;

function tgraphdataedit.getifidatalinkintf(): iifidatalink;
begin
 result:= iifidatalink(self);
end;

function tgraphdataedit.getassistiveflags: assistiveflagsty;
begin
 result:= inherited getassistiveflags;
 result:= result + [asf_graphicedit];
 if readonly then begin
  include(result,asf_readonly);
 end;
 if fgridintf <> nil then begin
  include(result,asf_gridwidget);
 end;
end;

function tgraphdataedit.getassistivecolumncaption(): msestring;
begin
 result:= '';
 if fgridintf <> nil then begin
  result:= fgridintf.getcol.defaultcaption();
 end;
end;

function tgraphdataedit.getdefaultifilink: iificlient;
begin
 result:= iifidatalink(self);
end;
{$endif mse_with_ifi}

function tgraphdataedit.getedited: boolean;
begin
 result:= fedited;
end;

procedure tgraphdataedit.setedited(const avalue: boolean);
begin
 fedited:= avalue;
end;

procedure tgraphdataedit.updatedatalist;
begin
 //dummy
end;

function tgraphdataedit.getstatpriority: integer;
begin
 result:= fstatpriority;
end;

procedure tgraphdataedit.setparentgridwidget(const intf: igridwidget);
begin
 fparentintf:= intf;
end;

procedure tgraphdataedit.childdataentered(const sender: igridwidget);
begin
 //dummy
end;

procedure tgraphdataedit.childfocused(const sender: igridwidget);
begin
 //dummy
end;

{ ttogglegraphdataedit}

constructor ttogglegraphdataedit.create(aowner: tcomponent);
begin
 fclickedrow:= -1;
 foptions:= defaultbuttonoptions;
 inherited;
end;

procedure ttogglegraphdataedit.internalcreateframe;
begin
 ttogglegrapheditframe.create(iscrollframe(self));
end;

procedure ttogglegraphdataedit.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if (aso_returntogglevalue in assistiveoptions) and 
                       (shiftstate * keyshiftstatesmask = []) and
            (bo_executeonkey in foptions) and (isenterkey(self,key)) then begin
  include(eventstate,es_processed);
  togglevalue(oe_readonly in getoptionsedit,false);
  end;
 end;
 inherited;
end;

procedure ttogglegraphdataedit.dokeyup(var info: keyeventinfoty);
begin
 with info do begin
  if (key = key_space) and (shiftstate*keyshiftstatesmask = []) and 
                                     (bo_executeonkey in foptions) then begin
   include(eventstate,es_processed);
   togglevalue(oe_readonly in getoptionsedit,false);
  end;
 end;
 inherited;
end;

procedure ttogglegraphdataedit.doshortcut(var info: keyeventinfoty;
                                                      const sender: twidget);
begin
 if (bo_executeonshortcut in foptions) and checkfocusshortcut(info) then begin
  include(info.eventstate,es_processed);
  togglevalue(oe_readonly in getoptionsedit,false);
  if (bo_focusonshortcut in foptions) and canfocus then begin
   setfocus;
  end;
 end;
 if not (es_processed in info .eventstate) then begin
  inherited;
 end;
end;

procedure ttogglegraphdataedit.mouseevent(var info: mouseeventinfoty);
var
 bo1: boolean;
begin
 bo1:= not (csdesigning in componentstate) and 
          iswidgetclick(info,fcheckcaption) and (bo_executeonclick in foptions);
 inherited;
 if bo1 and not (des_disabled in fstate) then begin
         //twidgetgrid needs childmouseevent
  togglevalue(oe_readonly in getoptionsedit,false);
 end;
end;

procedure ttogglegraphdataedit.docellevent(const ownedcol: boolean;
               var info: celleventinfoty);
var
 clickedrowbefore: integer;
begin
 inherited;
 if (bo_resetcheckedonrowexit in foptions) and isrowchange(info) and 
           (info.newcell.row <> checkedrow) then begin
  checkedrow:= -1;
 end;
 if ownedcol and (info.eventkind in 
             [cek_buttonpress,cek_buttonrelease,cek_mouseleave]) then begin
  clickedrowbefore:= fclickedrow;
  case info.eventkind of
   cek_mouseleave: begin
    fclickedrow:= -1;
   end;
   cek_buttonpress: begin
    if (bo_executeonclick in foptions) and
       (info.mouseeventinfopo^.shiftstate*keyshiftstatesmask = []) and
       (info.mouseeventinfopo^.button = mb_left) and
           enabled and not (des_disabled in fstate) and not readonly then begin
     fclickedrow:= info.cell.row;
    end;
   end;
   cek_buttonrelease: begin
    if {not info.processed and} not focused and (fclickedrow >= 0) then begin
     togglegridvalue(fclickedrow);
     checkradiorow(fclickedrow);
    end;
    fclickedrow:= -1;
   end;
  end;
  if fclickedrow <> clickedrowbefore then begin
   fgridintf.getcol.grid.invalidatecell(info.cell);
  end;
 end;
end;

procedure ttogglegraphdataedit.statechanged;
begin
 if not enabled then begin
  fclickedrow:= -1;
 end;
 inherited;
end;

procedure ttogglegraphdataedit.setoptions(const avalue: buttonoptionsty);
begin
 foptions:= avalue;
end;

procedure ttogglegraphdataedit.resetradioitems();
var
 int1: int32;
 widget1: twidget;
begin
 if fparentwidget <> nil then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget1:= fparentwidget.widgets[int1];
   if (widget1 is self.classtype) and (widget1 <> self) and
        (ttogglegraphdataedit(widget1).fgroup = fgroup) then begin
    with ttogglegraphdataedit(widget1) do begin
     inc(fresetting);
     try
      douncheck();
     finally
      dec(fresetting);
     end;
    end;
   end;
  end;
 end;
end;

procedure ttogglegraphdataedit.checkradiorow(aindex: integer);
var
 datalist1: tdatalist;
 int1: integer;
begin
 if (fgridintf <> nil) and (bo_radioitemcol in foptions) then begin
  if aindex < 0 then begin
   aindex:= fgridintf.grid.row;
  end;
  datalist1:= fgridintf.getcol.datalist;
  int1:= datalist1.checkeditem;
  if gridvaluechecked(aindex) then begin
   if (int1 >= 0) and (int1 <> aindex) then begin
    resetgridvalue(int1);
   end;
   datalist1.checkeditem:= aindex;
  end
  else begin
   if (int1 >= 0) and (int1 = aindex) then begin
    datalist1.checkeditem:= -1;
   end;
  end;
 end;
end;

function ttogglegraphdataedit.internalcheckeditem(
               out single: boolean): ttogglegraphdataedit; //nil if none
var
 widget: twidget;
 int1,int2: integer;
begin
 result:= nil;
 int2:= 0;
 if fparentwidget <> nil then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget:= fparentwidget.widgets[int1];
   if (widget is self.classtype{tcustombooleaneditradio}) then begin
    with ttogglegraphdataedit(widget) do begin
     if (fgroup = self.fgroup) and ischecked() then begin
      inc(int2);
      if result <> nil then begin
       break;
      end;
      result:= ttogglegraphdataedit(widget);
     end;
    end;
   end;
  end;
 end
 else begin
  if ischecked() then begin
   result:= self;
  end;
 end;
 single:= int2 <= 1;
end;

procedure ttogglegraphdataedit.modified;
begin
 checkradiorow(-1);
 inherited;
end;

function ttogglegraphdataedit.getcheckedrow: integer;
begin
 result:= -1;
 if (fgridintf <> nil) and (bo_radioitemcol in foptions) then begin
  if fdatalist <> nil then begin
   result:= fdatalist.checkeditem;
  end;
 end;  
end;

procedure ttogglegraphdataedit.setcheckedrow(const avalue: integer);
begin
 if checkedrow <> avalue then begin
  if (fgridintf <> nil) and (bo_radioitemcol in foptions) then begin
   if fdatalist <> nil then begin
    if avalue < 0 then begin
     if fdatalist.checkeditem >= 0 then begin
      resetgridvalue(fdatalist.checkeditem);
      fdatalist.checkeditem:= -1;
     end;
    end    
    else begin
     checkgridvalue(avalue);
     checkradiorow(avalue);
    end;
   end;
  end; 
 end;
end;

function ttogglegraphdataedit.getcheckedtag: integer;
var
 item: ttogglegraphdataedit;
 bo1: boolean;
begin
 item:= internalcheckeditem(bo1);
 if item <> nil then begin
  result:= item.Tag;
 end
 else begin
  result:= -1;
 end;
end;

procedure ttogglegraphdataedit.setcheckedtag(const avalue: integer);
var
 widget: twidget;
 item: ttogglegraphdataedit;
 int1: integer;
 bo1: boolean;
begin
 if fparentwidget <> nil then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget:= fparentwidget.widgets[int1];
   if (widget is self.classtype) and
        (ttogglegraphdataedit(widget).fgroup = fgroup) and
         (widget.tag = avalue) then begin
    ttogglegraphdataedit(widget).docheck();
    exit;
   end;
  end;
  item:= internalcheckeditem(bo1);
  if item <> nil then begin
   item.douncheck();
  end;
 end;
end;

function ttogglegraphdataedit.navigrect: rectty;
var
 p1: captionposty;
begin
 result:= widgetsizerect;
 if (fframe <> nil) then begin
  p1:= tcaptionframe(fframe).captionpos;
  if p1 in rightcaptionpos then begin
   result.x:= paintpos.x;
  end;
  if p1 in bottomcaptionpos then begin
   result.y:= paintpos.y;
  end;
 end;
end;

{ tcustombooleanedit }

procedure tcustombooleanedit.internalcheckvalue(var avalue; var accept: boolean);
var
 bo1: boolean;
begin
 if canevent(tmethod(fonsetvalue)) then begin
  bo1:= longbool(avalue);
  fonsetvalue(self,bo1,accept);
  longbool(avalue):= bo1;
 end;
{$ifdef mse_with_ifi}
 ifisetvalue(avalue,accept);
{$endif}
 if accept then begin
  value:= longbool(avalue);
 end;
end;

procedure tcustombooleanedit.togglevalue(const areadonly: boolean;
                                                     const down: boolean);
var
 bo1: longbool;
begin
 if not areadonly then begin
  bo1:= not fvalue;
  fedited:= true;
  docheckvalue(bo1,false);
 end;
end;

procedure tcustombooleanedit.docheck();
begin
 value:= not valuedefault;
end;

procedure tcustombooleanedit.douncheck();
begin
 value:= valuedefault;
end;

function tcustombooleanedit.ischecked(): boolean;
begin
 result:= fvalue;
end;

procedure tcustombooleanedit.togglegridvalue(const index: integer);
begin
 gridvalue[index]:= not gridvalue[index];
end;

constructor tcustombooleanedit.create(aowner: tcomponent);
begin
 fcheckcaption:= true;
 inherited;
 size:= makesize(defaultboxsize,defaultboxsize);
end;

function tcustombooleanedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridintegerdatalist.create(sender);
end;

function tcustombooleanedit.getdatalistclass: datalistclassty;
begin
 result:= tgridintegerdatalist;
end;

function tcustombooleanedit.getglyph: stockglyphty;
begin
 result:= stg_checked;
end;

procedure tcustombooleanedit.paintglyph(const canvas: tcanvas; 
                               const acolorglyph: colorty; const avalue;
                               const arect: rectty);
var
 bo1: boolean;
 co1: colorty;
begin
 if @avalue = nil then begin
  bo1:= fvalue;
 end
 else begin
  bo1:= boolean(avalue);
 end;
 co1:= acolorglyph;
 if co1 = cl_default then begin
  co1:= cl_glyph;
 end;
 if (bo_coloractive in foptions) and active then begin
  canvas.fillrect(arect,cl_selectedtextbackground);
  co1:= cl_selectedtext;
 end;
 if bo1 xor (bo_reversed in foptions) then begin
  stockobjects.paintglyph(canvas,getglyph,arect,not isenabled,co1);
 end;
// inherited;
end;

procedure tcustombooleanedit.setvalue(const Value: boolean);
begin
 fvalue := Value;
 valuechanged;
end;

procedure tcustombooleanedit.readstatvalue(const reader: tstatreader);
begin
 value:= reader.readboolean(valuevarname,value);
end;

procedure tcustombooleanedit.writestatvalue(const writer: tstatwriter);
begin
 writer.writeboolean(valuevarname,value);
end;

function tcustombooleanedit.getdefaultvalue: pointer;
begin
 result:= @fvaluedefault;
end;

class function tcustombooleanedit.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_booleanedit;
end;

procedure tcustombooleanedit.setnullvalue;
begin
 value:= false;
end;

procedure tcustombooleanedit.gridtovalue(arow: integer);
var
 int1: integer;
begin
 int1:= 0;
 if fvalue then begin
  int1:= 1;
 end;
 fgridintf.getdata(arow,int1);
 fvalue:= int1 <> 0;
 inherited;
end;

procedure tcustombooleanedit.valuetogrid(arow: integer);
var
 int1: integer;
begin
 int1:= integer(longbool(fvalue));
 fgridintf.setdata(arow,int1);
end;

procedure tcustombooleanedit.fillcol(const avalue: longbool);
begin
 checkgrid;
 with tdatalist1(fgridintf.getcol.datalist) do begin
  tdatalist1(fgridintf.getcol.datalist).internalfill(count,avalue);
 end;
 fgridintf.getcol.changed;
end;

function tcustombooleanedit.checkvalue(const quiet: boolean = false): boolean;
begin
 result:= docheckvalue(fvalue,quiet);
end;

function tcustombooleanedit.getgridvalue(const index: integer): longbool;
begin
 internalgetgridvalue(index,result);
end;

procedure tcustombooleanedit.setgridvalue(const index: integer;
  const Value: longbool);
begin
 internalsetgridvalue(index,value);
end;

function tcustombooleanedit.getgridvalues: longboolarty;
begin
 result:= longboolarty(tintegerdatalist(fgridintf.getcol.datalist).asarray);
end;

procedure tcustombooleanedit.setgridvalues(const Value: longboolarty);
begin
 tintegerdatalist(fgridintf.getcol.datalist).asarray:= integerarty(value);
end;

function tcustombooleanedit.getgridbooleanvalues: booleanarty;
begin
 result:= tintegerdatalist(fgridintf.getcol.datalist).asbooleanarray;
end;

procedure tcustombooleanedit.setgridbooleanvalues(const Value: booleanarty);
begin
 tintegerdatalist(fgridintf.getcol.datalist).asbooleanarray:= value;
end;

function tcustombooleanedit.valuetag(const falsevalue: integer): integer;
begin
 if fvalue then begin
  result:= tag;
 end
 else begin
  result:= falsevalue;
 end;
end;

function tcustombooleanedit.gridvaluetag(const index: integer;
                       const falsevalue: integer): integer;
begin
 if getgridvalue(index) then begin
  result:= tag;
 end
 else begin
  result:= falsevalue;
 end;
end;

procedure tcustombooleanedit.updatetagvalue(const bitset: integer);
           //value -> true if bitset and tag <> 0
begin
 value:= bitset and tag <> 0;
end;

procedure tcustombooleanedit.gridupdatetagvalue(const index: integer; const bitset: integer);
begin
 setgridvalue(index,bitset and tag <> 0);
end;

function tcustombooleanedit.valuetagbit: longword;
                  //if value -> bits[tag] else -> 0
begin
 if fvalue then begin
  result:= bits[tag and $1f];
 end
 else begin
  result:= 0;
 end;
end;

function tcustombooleanedit.gridvaluetagbit(const index: integer): longword;
                  //if value -> bits[tag] else -> 0
begin
 if gridvalue[index] then begin
  result:= bits[tag and $1f];
 end
 else begin
  result:= 0;
 end;
end;

function tcustombooleanedit.getvaluebitmask: longword;
                  //ored valuetagbit of all edits in group
var
 ar1: booleaneditarty;
 int1: integer;
begin
 ar1:= groupmembers;
 result:= 0;
 for int1:= 0 to high(ar1) do begin
  result:= result or ar1[int1].valuetagbit;
 end;
end;

procedure tcustombooleanedit.setvaluebitmask(const avalue: longword);
var
 ar1: booleaneditarty;
 int1: integer;
begin
 ar1:= groupmembers;
 for int1:= 0 to high(ar1) do begin
  with ar1[int1] do begin
   value:= avalue and bits[tag and $1f] <> 0;
  end;
 end;
end;

function tcustombooleanedit.getgridvaluebitmask(const index: integer): longword;
                  //ored valuetagbit of all edits in group
var
 ar1: booleaneditarty;
 int1: integer;
begin
 ar1:= groupmembers;
 result:= 0;
 for int1:= 0 to high(ar1) do begin
  result:= result or ar1[int1].gridvaluetagbit(index);
 end;
end;

procedure tcustombooleanedit.setgridvaluebitmask(const index: integer; const avalue: longword);
var
 ar1: booleaneditarty;
 int1: integer;
begin
 ar1:= groupmembers;
 for int1:= 0 to high(ar1) do begin
  with ar1[int1] do begin
   gridvalue[index]:= avalue and bits[tag and $1f] <> 0;
  end;
 end;
end;

function tcustombooleanedit.getvalue: boolean;
begin
 result:= fvalue;
end;

function tcustombooleanedit.getvaluedefault: boolean;
begin
 result:= fvaluedefault;
end;

procedure tcustombooleanedit.setvaluedefault(const Value: boolean);
begin
 fvaluedefault:= value;
end;

function tcustombooleanedit.groupmembers: booleaneditarty;
var
 int1,int2: integer;
 widget1: twidget;
begin
 if fparentwidget = nil then begin
  setlength(result,1);
  result[0]:= self;
 end
 else begin
  setlength(result,fparentwidget.widgetcount); //max
  int2:= 0;
  for int1:= 0 to high(result) do begin
   widget1:= twidget1(fparentwidget).fwidgets[int1];
   if (widget1 is tcustombooleanedit) and 
      (tcustombooleanedit(widget1).fgroup = self.fgroup)  then begin
    result[int2]:= tcustombooleanedit(widget1);
    inc(int2);
   end;
  end;
  setlength(result,int2);
 end;
end;

function tcustombooleanedit.tagitem(const atag: integer): tcustombooleanedit; //nil if none
var
 int1: integer;
 widget1: twidget;
begin
 result:= nil;
 if fparentwidget <> nil then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget1:= twidget1(fparentwidget).fwidgets[int1];
   if (widget1 is tcustombooleanedit) and 
         (tcustombooleanedit(widget1).fgroup = self.fgroup) and
          (widget1.tag = atag) then begin
    result:= tbooleanedit(widget1);
    break;
   end;
  end;
 end;
end;

procedure tcustombooleanedit.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if not (es_processed in eventstate) then begin
   if ((key = key_0) or (key = key_1) or (key = key_period)) and
         (shiftstate = []) and (bo_executeonkey in foptions) then begin
    include(eventstate,es_processed);
    if ((key = key_1) xor value) or (key = key_period) then begin
     togglevalue(oe_readonly in getoptionsedit,false);
    end;
   end;
   if not (es_processed in eventstate) then begin
    inherited;
   end;
  end;
 end;
end;

function tcustombooleanedit.getassistivetext(): msestring;
begin
 if value then begin
  result:= stockobjects.captions[sc_on];
 end
 else begin
  result:= stockobjects.captions[sc_off];
 end;
end;

{$ifdef mse_with_ifi}
function tcustombooleanedit.getifilink: tifibooleanlinkcomp;
begin
 result:= tifibooleanlinkcomp(fifilink);
end;

procedure tcustombooleanedit.setifilink(const avalue: tifibooleanlinkcomp);
begin
 inherited setifilink(avalue);
end;

{$endif}

procedure tcustombooleanedit.resetgridvalue(const index: integer);
begin
 gridvalue[index]:= false;
end;

procedure tcustombooleanedit.checkgridvalue(const index: integer);
begin
 gridvalue[index]:= true;
end;

function tcustombooleanedit.gridvaluechecked(const aindex: integer): boolean;
begin
 result:= gridvalue[aindex];
end;

function tcustombooleanedit.griddata: tgridintegerdatalist;
begin
 result:= tgridintegerdatalist(inherited griddata);
end;

procedure tcustombooleanedit.setvaluedata(const source);
begin
 value:= boolean(source);
end;

procedure tcustombooleanedit.getvaluedata(out dest);
begin
 boolean(dest):= value;
end;

{ tcustombooleaneditradio }

function tcustombooleaneditradio.getglyph: stockglyphty;
begin
 result:= stg_checkedradio;
end;
{
procedure tcustombooleaneditradio.reset;
begin
 if value then begin
  inc(fresetting);
  try
   value:= false
  finally
   dec(fresetting);
  end;
 end;
end;
}
procedure tcustombooleaneditradio.setvalue(const avalue: boolean);
begin
 if avalue then begin
  resetradioitems();
 end;
 inherited;
end;

procedure tcustombooleaneditradio.setgridvalue(const aindex: integer;
                                                   const avalue: longbool);
var
 widget: twidget;
 int1: integer;
begin
 if avalue and (fparentwidget <> nil) then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget:= fparentwidget.widgets[int1];
   if (widget is tcustombooleaneditradio) and (widget <> self) and
        (tcustombooleaneditradio(widget).fgroup = fgroup) then begin
    tcustombooleaneditradio(widget).gridvalue[aindex]:= false;
   end;
  end;
 end;
 inherited;
end;

function tcustombooleaneditradio.checkeditem: tcustombooleaneditradio; 
                            //nil if none
var
 bo1: boolean;
begin
 result:= tcustombooleaneditradio(internalcheckeditem(bo1));
end;

procedure tcustombooleaneditradio.togglevalue(const areadonly: boolean;
                                         const down: boolean);
var
 bo1: boolean;
 bo2: longbool;
begin
 if not areadonly then begin
  internalcheckeditem(bo1);
  if (bo_cantoggle in foptions) or not fvalue or not bo1 then begin
   bo2:= not fvalue;
   docheckvalue(bo2,false);
  end;
 end;
end;

procedure tcustombooleaneditradio.togglegridvalue(const index: integer);
begin
 if not getgridvalue(index) then begin
  setgridvalue(index,true);
 end;
end;

{ tcustomintegergraphdataedit }

procedure tcustomintegergraphdataedit.internalcheckvalue(var avalue;
  var accept: boolean);
begin
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,integer(avalue),accept);
 end;
{$ifdef mse_with_ifi}
 ifisetvalue(avalue,accept);
{$endif} 
 if accept then begin
  value:= integer(avalue);
 end;
end;

procedure tcustomintegergraphdataedit.setvalue(const avalue: integer);
begin
 if (bo_radioitem in foptions) and (avalue <> fvaluedefault) then begin
  resetradioitems();
 end;
 fvalue := avalue;
 valuechanged;
end;

procedure tcustomintegergraphdataedit.readstatvalue(const reader: tstatreader);
begin
 value:= reader.readinteger(valuevarname,value);
end;

procedure tcustomintegergraphdataedit.writestatvalue(const writer: tstatwriter);
begin
 writer.writeinteger(valuevarname,value);
end;

function tcustomintegergraphdataedit.getdefaultvalue: pointer;
begin
 result:= @fvaluedefault;
end;

procedure tcustomintegergraphdataedit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomintegergraphdataedit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

function tcustomintegergraphdataedit.checkvalue(
                              const quiet: boolean = false): boolean;
begin
 result:= docheckvalue(fvalue,quiet);
end;

function tcustomintegergraphdataedit.doinc(var avalue: integer;
                                                const down: boolean): boolean;
begin
 result:= false;
 if (foptions * [bo_radioitem,bo_radioitemcol] = []) or 
         (bo_cantoggle in foptions) or (value = fvaluedefault) then begin
  if down then begin
   dec(avalue);
   if avalue < fvaluemin then begin
    avalue:= fvaluemax;
   end;
  end
  else begin
   inc(avalue);
   if avalue > fvaluemax then begin
    avalue:= fvaluemin;
   end;
  end;
  result:= true;
 end;
end;

procedure tcustomintegergraphdataedit.paintglyph(const canvas: tcanvas; 
                        const acolorglyph: colorty;
                        const avalue; const arect: rectty);
var
 int1,val1: integer;
begin
 if canevent(tmethod(fonpaintglyph)) then begin
  if @avalue = nil then begin
   val1:= fvalue;
   int1:= gridrow;
  end
  else begin
   val1:= integer(avalue);
   int1:= pcellinfoty(canvas.drawinfopo)^.cell.row;
  end;
  fonpaintglyph(self,canvas,val1,int1);
 end;
// inherited;
end;

procedure tcustomintegergraphdataedit.togglevalue(const areadonly: boolean;
                                                          const down: boolean);
var
 int1: integer;
begin
 if not areadonly and (fvaluemin <> fvaluemax) then begin
  int1:= fvalue;
  if doinc(int1,down) then begin
   docheckvalue(int1,false);
  end;
 end;
end;

function tcustomintegergraphdataedit.ischecked(): boolean;
begin
 result:= fvalue <> fvaluedefault;
end;

procedure tcustomintegergraphdataedit.docheck();
begin
 value:= valuedefault+1;
end;

procedure tcustomintegergraphdataedit.douncheck();
begin
 value:= valuedefault;
end;

procedure tcustomintegergraphdataedit.togglegridvalue(const index: integer);
var
 int1: integer;
begin
 if fvaluemin <> fvaluemax then begin
  int1:= gridvalue[index];
  if doinc(int1,false) then begin
   gridvalue[index]:= int1;
  end;
 end;
end;

procedure tcustomintegergraphdataedit.fillcol(const avalue: integer);
begin
 checkgrid;
 tgridintegerdatalist(fdatalist).fill(fdatalist.count,avalue);
end;

function tcustomintegergraphdataedit.createdatalist(
  const sender: twidgetcol): tdatalist;
begin
 fdatalist:= tgridintegerdatalist.create(sender);
 tgridintegerdatalist(fdatalist).notcheckedvalue:= fvaluedefault;
 result:= fdatalist;
end;

function tcustomintegergraphdataedit.getdatalistclass: datalistclassty;
begin
 result:= tgridintegerdatalist;
end;

function tcustomintegergraphdataedit.getgridvalue(const index: integer): integer;
begin
 internalgetgridvalue(index,result);
end;

procedure tcustomintegergraphdataedit.setgridvalue(const index, Value: integer);
begin
 internalsetgridvalue(index,value);
end;

function tcustomintegergraphdataedit.getgridvalues: integerarty;
begin
 checkgrid;
 result:= tgridintegerdatalist(fdatalist).asarray;
end;

procedure tcustomintegergraphdataedit.setgridvalues(const Value: integerarty);
begin
 checkgrid;
 tgridintegerdatalist(fdatalist).asarray:= value;
end;
{
procedure tcustomintegergraphdataedit.setgridintf(const intf: iwidgetgrid);
begin
 if intf <> nil then begin
  fdatalist:= tintegerdatalist(intf.getcol.datalist);
 end
 else begin
  fdatalist:= nil;
 end;
 inherited;
end;
}
procedure tcustomintegergraphdataedit.resetgridvalue(const index: integer);
begin
 gridvalue[index]:= valuedefault;
end;

procedure tcustomintegergraphdataedit.checkgridvalue(const index: integer);
var
 int1: integer;
begin
 int1:= fvaluedefault + 1;
 if int1 > fvaluemax then begin
  int1:= int1 -2;
  if int1 < fvaluemin then begin
   int1:= fvaluemin;
  end;
 end;
 gridvalue[index]:= int1;
end;

function tcustomintegergraphdataedit.gridvaluechecked(
                                      const aindex: integer): boolean;
begin
 result:= gridvalue[aindex] <> valuedefault;
end;

procedure tcustomintegergraphdataedit.datalistdestroyed;
begin
 fdatalist:= nil;
end;

{$ifdef mse_with_ifi}
function tcustomintegergraphdataedit.getifilink: tifiintegerlinkcomp;
begin
 result:= tifiintegerlinkcomp(fifilink);
end;

procedure tcustomintegergraphdataedit.setifilink(const avalue: tifiintegerlinkcomp);
begin
 inherited setifilink(avalue);
end;
{$endif}

procedure tcustomintegergraphdataedit.setvaluemin(const avalue: integer);
begin
 fvaluemin:= avalue;
 if fdatalist <> nil then begin
  with tgridintegerdatalist(fdatalist) do begin
   min:= avalue;
  end;
 end;
end;

procedure tcustomintegergraphdataedit.setvaluemax(const avalue: integer);
begin
 fvaluemax:= avalue;
 if fdatalist <> nil then begin
  with tgridintegerdatalist(fdatalist) do begin
   max:= avalue;
  end;
 end;
end;

procedure tcustomintegergraphdataedit.updatedatalist;
begin
 with tgridintegerdatalist(fdatalist) do begin
  min:= self.valuemin;
  max:= self.valuemax;
  notcheckedvalue:= self.valuedefault;
 end;
end;

procedure tcustomintegergraphdataedit.readmin(reader: treader);
begin
 valuemin:= reader.readinteger();
end;

procedure tcustomintegergraphdataedit.readmax(reader: treader);
begin
 valuemax:= reader.readinteger();
end;

procedure tcustomintegergraphdataedit.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('min',@readmin,nil,false);
 filer.defineproperty('max',@readmax,nil,false);
end;

function tcustomintegergraphdataedit.getdatalist: tintegerdatalist;
begin
 result:= tintegerdatalist(checkgriddata);
end;

function tcustomintegergraphdataedit.griddata: tgridintegerdatalist;
begin
 result:= tgridintegerdatalist(inherited griddata);
end;

procedure tcustomintegergraphdataedit.setvaluedata(const source);
begin
 value:= integer(source);
end;

procedure tcustomintegergraphdataedit.getvaluedata(out dest);
begin
 integer(dest):= value;
end;


{ tvaluefacearrayprop }

constructor tvaluefacearrayprop.create(const aowner: tcustomdatabutton);
begin
 fowner:= aowner;
 inherited create(nil);
end;

class function tvaluefacearrayprop.getitemclasstype: persistentclassty;
begin
 result:= tface;
end;

procedure tvaluefacearrayprop.createitem(const index: integer;
                                        var item: tpersistent);
begin
 item:= tface.create(iface(fowner));
end;

function tvaluefacearrayprop.getitems(const index: integer): tface;
begin
 result:= tface(inherited getitems(index));
end;

{ tvaluefontarrayprop }

constructor tvaluefontarrayprop.create(const aowner: tcustomdatabutton);
begin
 fowner:= aowner;
 inherited create(nil);
end;

class function tvaluefontarrayprop.getitemclasstype: persistentclassty;
begin
 result:= tfont;
end;

procedure tvaluefontarrayprop.createitem(const index: integer;
                                                      var item: tpersistent);
begin
 item:= tfont.create;
 item.assign(fowner.font);
 tfont(item).onchange:= @fontchange;
end;

procedure tvaluefontarrayprop.fontchange(const sender: tobject);
begin
 fowner.formatchanged;
end;

procedure tvaluefontarrayprop.setitems(const index: integer; const avalue: tfont);
begin
 checkindex(index);
 if fitems[index] <> nil then begin
  fitems[index].assign(avalue);
 end;
end;

function tvaluefontarrayprop.getitems(const index: integer): tfont;
begin
 result:= tfont(inherited getitems(index));
end;

{ tcustomdatabutton }

constructor tcustomdatabutton.create(aowner: tcomponent);
begin
 foptions:= defaultbuttonoptions;
 initactioninfo(factioninfo);
 fvaluedisabled:= -2;
 inherited;
 fimagenums:= tintegerarrayprop.create;
 fimagenr:= -1;
 fimagenrdisabled:= -2;
 fvalue:= -1;
 fvaluedefault:= -1;
 fvaluemin:= -1;
 fvaluemax:= 0;
 fvaluefaces:= tvaluefacearrayprop.create(self);
 fvaluecaptions:= tmsestringarrayprop.create;
 fvaluefonts:= tvaluefontarrayprop.create(self);
 optionswidget:= defaultoptionswidget - [ow_mousefocus];
 initshapeinfo(finfo);
 finfo.ca.imagepos:= ip_center;
 finfo.ca.dim:= innerclientrect;
 finfo.color:= cl_transparent;
 finfo.ca.colorglyph:= cl_black;
 finfo.state:= finfo.state + [shs_showfocusrect,shs_showdefaultrect];
 include(fwidgetstate1,ws1_nodesignframe);
 size:= makesize(defaultbuttonwidth,defaultbuttonheight);
end;

destructor tcustomdatabutton.destroy;
begin
 if bo_updateonidle in foptions then begin
  application.unregisteronidle({$ifdef FPC}@{$endif}doidle); 
 end;
 fvaluefaces.free;
 fvaluecaptions.free;
 fvaluefonts.free;
 fimagenums.free;
 inherited;
end;

procedure tcustomdatabutton.execute();
begin
 if not (shs_disabled in finfo.state) then begin
  internalexecute;
 end;
end;

class function tcustomdatabutton.classskininfo: skininfoty;
begin
 result:= inherited classskininfo;
 result.objectkind:= sok_databutton;
end;

function tcustomdatabutton.verticalfontheightdelta: boolean;
begin
 result:= tf_rotate90 in textflags;
end;

procedure tcustomdatabutton.synctofontheight;
begin
 inherited;
 if tf_rotate90 in textflags then begin
  bounds_cx:= font.glyphheight + innerclientframewidth.cx + 6;
 end
 else begin
  bounds_cy:= font.glyphheight + innerclientframewidth.cy + 6;
 end;
end;

procedure tcustomdatabutton.initnewcomponent(const ascale: real);
begin
 //dummy
end;

procedure tcustomdatabutton.clientrectchanged;
begin
 inherited;
 frameskinoptionstoshapestate(fframe,finfo);
 if (fframe = nil) and (fgridintf <> nil) then begin
  exclude(finfo.state,shs_showdefaultrect);
 end;
 if shs_flat in finfo.state then begin
  exclude(fwidgetstate1,ws1_nodesignframe);
 end
 else begin
  include(fwidgetstate1,ws1_nodesignframe);
 end;
 finfo.ca.dim:= clientrect;
 if (fframe <> nil) and not(shs_noinnerrect in finfo.state)  then begin
                                  //otherwise mouse rect
  deflaterect1(finfo.ca.dim,fframe.frameo);
 end;
 {
 if shs_noinnerrect in finfo.state then begin
  finfo.ca.dim:= clientrect;
 end
 else begin
  finfo.ca.dim:= innerclientrect;
 end;
 }
end;
{
function tcustomdatabutton.getframestateflags: framestateflagsty;
begin
 with finfo do begin
  result:= combineframestateflags(not isenabled,focused,
              not (bo_nodefaultframeactive in foptions) and 
                           (shs_default in finfo.state) or active,
              shs_mouse in state,shs_clicked in state);
 end;
end;
}
{
function tcustomdatabutton.getframeclicked: boolean;
begin
 result:= ss_clicked in finfo.state;
end;

function tcustomdatabutton.getframemouse: boolean;
begin
 result:= ss_mouse in finfo.state;
end;

function tcustomdatabutton.getframeactive: boolean;
begin
 result:= not (bo_nodefaultframeactive in foptions) and 
                           (ss_default in finfo.state) or active;
end;
}
procedure tcustomdatabutton.doexecute;
begin
 if (options * [bo_nocandefocus,bo_candefocuswindow] <> [bo_candefocuswindow]) or
      rootwidget.canparentclose then begin
  doactionexecute(self,factioninfo,false,
             (options * [bo_nocandefocus,bo_candefocuswindow] <> []));
 end;
// doactionexecute(self,factioninfo);
end;

procedure tcustomdatabutton.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (csdesigning in componentstate) {and 
        not (es_processed in info.eventstate)} then begin
  subpoint1(info.pos,paintpos);
  try
   updatemouseshapestate(finfo,info,self,fframe,nil,
                              bo_executeonclick in foptions);
  finally
   addpoint1(info.pos,paintpos);
  end;
 end;
end;

procedure tcustomdatabutton.dokeydown(var info: keyeventinfoty);
begin
 inherited;
 if (info.shiftstate = []) and (bo_executeonkey in foptions) and 
                                    not (des_disabled in fstate) then begin
  if (info.key = key_space) then begin
   include(finfo.state,shs_clicked);
   invalidaterect(finfo.ca.dim);
  end
  else begin
   if isenterkey(self,info.key) then begin
    include(info.eventstate,es_processed);
    togglevalue(oe_readonly in getoptionsedit,false);
   end;
  end;
 end;
end;

procedure tcustomdatabutton.dokeyup(var info: keyeventinfoty);
begin
 if (info.key = key_space) and (shs_clicked in finfo.state) then begin
  exclude(finfo.state,shs_clicked);
  invalidaterect(finfo.ca.dim);
 end;
 inherited;
end;

procedure tcustomdatabutton.doshortcut(var info: keyeventinfoty; const sender: twidget);
var
 bo1,bo2: boolean;
begin
 if not (es_processed in info.eventstate) and 
               not (csdesigning in componentstate) and 
                            not (shs_disabled in finfo.state) then begin
  if checkfocusshortcut(info) then begin
   setfocus;
  end;
  bo1:= checkactionshortcut(factioninfo,info);
  if not bo1 then begin
   if not (es_preview in info.eventstate) then begin
    bo2:= es_processed in info.eventstate;
    exclude(info.eventstate,es_processed);
    bo1:= (bo_executeonshortcut in options) and 
     msegui.checkshortcut(info,factioninfo.captiontext,
                                        bo_altshortcut in options) or
    (finfo.state * [shs_invisible,shs_disabled,shs_default] = [shs_default]) and
       (info.key = key_return) and
       ((info.shiftstate = []) or 
        (bo_executedefaultonenterkey in options) and 
        (info.shiftstate = [ss_second]));
    if bo1 then begin
     bo2:= true;
     togglevalue(oe_readonly in getoptionsedit,false);
 //    internalexecute;
    end;
    if bo2 then begin
     include(info.eventstate,es_processed);
    end;
   end;
  end
  else begin
   togglevalue(oe_readonly in getoptionsedit,false);
  end;
  if not (es_processed in info.eventstate) then begin
   inherited;
  end;
 end;
end;

procedure tcustomdatabutton.statechanged;
begin
 inherited;
 updatewidgetshapestate(finfo,self);
 if (fgridintf <> nil) and (fvaluedisabled <> -2) then begin
  checkdisabled();
 end;
end;

procedure tcustomdatabutton.setcolorglyph(const avalue: colorty);
begin
 setactioncolorglyph(iactionlink(self),avalue);
end;

function tcustomdatabutton.iscolorglyphstored: boolean;
begin
 result:= isactioncolorglyphstored(factioninfo);
end;

procedure tcustomdatabutton.setactualimagenr(const avalue: integer);
begin
 with finfo,ca do begin 
  if (avalue >= 0) and (avalue < fimagenums.count) then begin
   imagenr:= fimagenums[avalue];
  end
  else begin
   imagenr:= fimagenr;
  end;
  if shs_disabled in finfo.state then begin
   if fimagenrdisabled = -3 then begin
    if imagenr >= 0 then begin
     imagenrdisabled:= imagenr + fimageoffsetdisabled;
    end;
   end
   else begin
    imagenrdisabled:= fimagenrdisabled;
   end;
  end
  else begin
   if shs_clicked in state then begin
    inc(imagenr,fimageoffsetclicked);
   end
   else begin
    if shs_mouse in state then begin
     inc(imagenr,fimageoffsetmouse);
    end
   end;
   if imagenr >= 0 then begin
    inc(imagenr,fimageoffset);
   end;
  end;
 end;
end;

procedure tcustomdatabutton.paintglyph(const canvas: tcanvas;
                const acolorglyph: colorty; const avalue;
                const arect: rectty);
               
 function actualcaption(const aindex: integer): richstringty;
 begin
  if (aindex >= 0) and (aindex < fvaluecaptions.count) then begin
   result.text:= fvaluecaptions[aindex];
   result.format:= nil;
  end
  else begin
   result:= factioninfo.caption1;
  end;
 end;
 
 function actualface(const aindex: integer): tface;
 begin
  if (aindex >= 0) and (aindex < fvaluefaces.count) then begin
   result:= fvaluefaces[aindex];
  end
  else begin
   result:= nil;
  end;
 end;

 function actualfont(const aindex: integer): tfont;
 begin
  if (aindex >= 0) and (aindex < fvaluefonts.count) then begin
   result:= fvaluefonts[aindex];
  end
  else begin
   result:= font;
  end;
 end;
 
var
 statebefore: shapestatesty;
 dimbefore: rectty;
begin
 finfo.ca.colorglyph:= acolorglyph;
 finfo.imagenrdisabled:= fimagenrdisabled;
 if (@avalue <> nil) then begin
  finfo.ca.caption:= actualcaption(integer(avalue));
  finfo.face:= actualface(integer(avalue));
  finfo.ca.font:= actualfont(int32(avalue));
  statebefore:= finfo.state;
  dimbefore:= finfo.ca.dim;
  finfo.ca.dim:= arect;
  finfo.state:= finfo.state - [shs_focused,shs_clicked,shs_mouse];
  if not valueenabledstate(integer(avalue)) then begin
   include(finfo.state,shs_disabled);
  end
  else begin
   exclude(finfo.state,shs_disabled);
  end;
  with pcellinfoty(canvas.drawinfopo)^ do begin
   if (cds_ismousecell in drawstate) and (bo_executeonclick in foptions) and 
                 not(shs_disabled in finfo.state) and not readonly then begin
    include(finfo.state,shs_mouse);
   end;
   if cell.row = fclickedrow then begin
    include(finfo.state,shs_clicked);
   end;
  end;
  setactualimagenr(integer(avalue));
  drawbutton(canvas,finfo);
  finfo.state:= statebefore;
  finfo.ca.dim:= dimbefore;
 end
 else begin
  finfo.ca.caption:= actualcaption(fvalue);
  finfo.face:= actualface(fvalue);
  finfo.ca.font:= actualfont(fvalue);
  setactualimagenr(fvalue);
  drawbutton(canvas,finfo);
 end;
 inherited;
end;

procedure tcustomdatabutton.internalcreateframe;
begin
 tcaptionframe.create(iscrollframe(self));
end;

procedure tcustomdatabutton.initgridwidget;
begin
 inherited;
 if fgridintf <> nil then begin
  with fgridintf.getcol do begin
   if self.color = cl_default then begin
    color:= cl_parent;
   end
   else begin
    color:= self.color;
   end;
   options:= options - [co_drawfocus];
  end;
 end;
end;

procedure tcustomdatabutton.setvaluefaces(const avalue: tvaluefacearrayprop);
begin
 fvaluefaces.assign(avalue);
end;

procedure tcustomdatabutton.setvaluecaptions(const avalue: tmsestringarrayprop);
begin
 fvaluecaptions.assign(avalue);
end;

procedure tcustomdatabutton.setcaption(const avalue: captionty);
begin
 setactioncaption(iactionlink(self),avalue);
// formatchanged;
end;

procedure tcustomdatabutton.settextflags(const avalue: textflagsty);
begin
 if finfo.ca.textflags <> avalue then begin
  finfo.ca.textflags:= checktextflags(finfo.ca.textflags,avalue);
  invalidate;
  checkautosize();
 end;
end;

function tcustomdatabutton.iscaptionstored: boolean;
begin
 result:= isactioncaptionstored(factioninfo);
end;

procedure tcustomdatabutton.setcaptiondist(const avalue: integer);
begin
 if avalue <> finfo.ca.captiondist then begin
  finfo.ca.captiondist:= avalue;
  formatchanged();
//  checkautosize();
 end;
end;

procedure tcustomdatabutton.setimagepos(const avalue: imageposty);
begin
 if avalue <> finfo.ca.imagepos then begin
  finfo.ca.imagepos:= avalue;
  formatchanged;
//  checkautosize;
 end;
end;

function tcustomdatabutton.getimagelist: timagelist;
begin
 result:= timagelist(factioninfo.imagelist);
end;

procedure tcustomdatabutton.setimagelist(const avalue: timagelist);
begin
 setactionimagelist(iactionlink(self),avalue);
end;

function tcustomdatabutton.isimageliststored: Boolean;
begin
 result:= isactionimageliststored(factioninfo);
end;

procedure tcustomdatabutton.setimagenr(const avalue: imagenrty);
begin
 fimagenr:= avalue;
 setactionimagenr(iactionlink(self),avalue);
end;

function tcustomdatabutton.isimagenrstored: Boolean;
begin
 result:= isactionimagenrstored(factioninfo);
end;

procedure tcustomdatabutton.setimagenrdisabled(const avalue: imagenrty);
begin
 fimagenrdisabled:= avalue;
 setactionimagenrdisabled(iactionlink(self),avalue);
end;

function tcustomdatabutton.isimagenrdisabledstored: Boolean;
begin
 result:= isactionimagenrdisabledstored(factioninfo);
end;

procedure tcustomdatabutton.setnullvalue;
begin
 value:= -1;
end;

procedure tcustomdatabutton.setgridintf(const intf: iwidgetgrid);
begin
 inherited;
 exclude(finfo.state,shs_showdefaultrect);
end;

function tcustomdatabutton.checkfocusshortcut(var info: keyeventinfoty): boolean;
begin
 result:= inherited checkfocusshortcut(info) or 
         msegui.checkshortcut(info,factioninfo.captiontext,true);
end;

procedure tcustomdatabutton.togglevalue(const areadonly: boolean;
                                                     const down: boolean);
begin
 if not (des_disabled in fstate) then begin
  inherited;
  internalexecute;
 end;
end;

procedure tcustomdatabutton.togglegridvalue(const index: integer);
begin
 inherited;
 internalexecute;
end;

function tcustomdatabutton.checkeditem: tcustomdatabutton;
var
 bo1: boolean;
begin
 result:= tcustomdatabutton(internalcheckeditem(bo1));
end;

procedure tcustomdatabutton.setimageoffset(const avalue: integer);
begin
 if fimageoffset <> avalue then begin
  fimageoffset := aValue;
  formatchanged;
 end;
end;

procedure tcustomdatabutton.setimageoffsetdisabled(const avalue: integer);
begin
 if fimageoffsetdisabled <> avalue then begin
  fimageoffsetdisabled := avalue;
  formatchanged;
 end;
end;

procedure tcustomdatabutton.setimageoffsetmouse(const avalue: integer);
begin
 if fimageoffsetmouse <> avalue then begin
  fimageoffsetmouse := avalue;
  formatchanged;
 end;
end;

procedure tcustomdatabutton.setimageoffsetclicked(const avalue: integer);
begin
 if fimageoffsetclicked <> avalue then begin
  fimageoffsetclicked := avalue;
  formatchanged;
 end;
end;

procedure tcustomdatabutton.setshortcut(const avalue: shortcutty);
begin
 setactionshortcut(iactionlink(self),avalue);
end;

function tcustomdatabutton.isshortcutstored: boolean;
begin
 result:= isactionshortcutstored(factioninfo);
end;

function tcustomdatabutton.getshortcut: shortcutty;
begin
 result:= getsimpleshortcut(factioninfo);
end;

function tcustomdatabutton.getshortcut1: shortcutty;
begin
 result:= getsimpleshortcut1(factioninfo);
end;

procedure tcustomdatabutton.setshortcut1(const avalue: shortcutty);
begin
 setactionshortcut1(iactionlink(self),avalue);
end;

function tcustomdatabutton.isshortcut1stored: boolean;
begin
 result:= isactionshortcut1stored(factioninfo);
end;

procedure tcustomdatabutton.setonexecute(const avalue: notifyeventty);
begin
 setactiononexecute(iactionlink(self),avalue,csloading in componentstate);
end;

function tcustomdatabutton.isonexecutestored: boolean;
begin
 result:= isactiononexecutestored(factioninfo);
end;

procedure tcustomdatabutton.setonbeforeexecute(const avalue: accepteventty);
begin
 setactiononbeforeexecute(iactionlink(self),avalue,csloading in componentstate);
end;

function tcustomdatabutton.isonbeforeexecutestored: boolean;
begin
 result:= isactiononbeforeexecutestored(factioninfo);
end;

procedure tcustomdatabutton.setonafterexecute(const avalue: notifyeventty);
begin
 setactiononafterexecute(iactionlink(self),avalue,csloading in componentstate);
end;

function tcustomdatabutton.isonafterexecutestored: boolean;
begin
 result:= isactiononafterexecutestored(factioninfo);
end;

procedure tcustomdatabutton.setimagedist(const avalue: integer);
begin
 if avalue <> finfo.ca.imagedist then begin
  finfo.ca.imagedist:= avalue;
  formatchanged;
//  checkautosize;
 end;
end;

procedure tcustomdatabutton.setimagedist1(const avalue: integer);
begin
 if avalue <> finfo.ca.imagedist1 then begin
  finfo.ca.imagedist1:= avalue;
  formatchanged;
//  checkautosize;
 end;
end;

procedure tcustomdatabutton.setimagedist2(const avalue: integer);
begin
 if avalue <> finfo.ca.imagedist2 then begin
  finfo.ca.imagedist2:= avalue;
  formatchanged;
//  checkautosize;
 end;
end;

procedure tcustomdatabutton.setimagenums(const avalue: tintegerarrayprop);
begin
 fimagenums.assign(avalue);
end;

procedure tcustomdatabutton.setoptions(const avalue: buttonoptionsty);
var
 delta: buttonoptionsty;
begin
 if avalue <> foptions then begin
  delta:= buttonoptionsty(
        {$ifdef FPC}longword{$else}longword{$endif}(foptions) xor
        {$ifdef FPC}longword{$else}longword{$endif}(avalue));
  if bo_updateonidle in delta then begin
   if (bo_updateonidle in avalue) and 
                               not (csdesigning in componentstate) then begin
    application.registeronidle({$ifdef FPC}@{$endif}doidle); 
   end
   else begin
    application.unregisteronidle({$ifdef FPC}@{$endif}doidle); 
   end;
  end;
  foptions:= avalue;
  buttonoptionstoshapestate(foptions,finfo.state);
  invalidate;
  if bo_shortcutcaption in avalue then begin
   setactionoptions(iactionlink(self),factioninfo.options + [mao_shortcutcaption]);
  end
  else begin
   setactionoptions(iactionlink(self),factioninfo.options - [mao_shortcutcaption]);
  end;
 end;
end;
{
begin
 if foptions <> avalue then begin
  foptions:= avalue - [bo_shortcutcaption];
  buttonoptionstoshapestate(foptions,finfo.state);
  invalidate;
 end;
end;
}
function tcustomdatabutton.getactioninfopo: pactioninfoty;
begin
 result:= @factioninfo;
end;

function tcustomdatabutton.shortcutseparator: msechar;
begin
 result:= ' ';
end;

procedure tcustomdatabutton.calccaptiontext(var ainfo: actioninfoty);
begin
 mseactions.calccaptiontext(ainfo,shortcutseparator);
end;

procedure tcustomdatabutton.updatehotkeys();
begin
 inherited;
 calccaptiontext(factioninfo);
end;

procedure tcustomdatabutton.actionchanged;
begin
 finfo.color:= fcolor;
 actioninfotoshapeinfo(self,factioninfo,finfo,foptions);
 inherited setcolor(finfo.color); 
 finfo.color:= cl_transparent;
// if csdesigning in componentstate then begin
  exclude(finfo.state,shs_invisible);
// end;
 formatchanged();
// checkautosize;
end;

procedure tcustomdatabutton.setaction(const avalue: tcustomaction);
begin
 linktoaction(iactionlink(self),avalue,factioninfo);
end;

procedure tcustomdatabutton.setstate(const avalue: actionstatesty);
begin
 setactionstate(iactionlink(self),avalue);
 visible:= not (as_invisible in factioninfo.state);
 enabled:= not (as_disabled in factioninfo.state);
end;

procedure tcustomdatabutton.setenabled(const avalue: boolean);
begin
 if avalue then begin
  setactionstate(iactionlink(self),state - [as_disabled]);
 end
 else begin
  setactionstate(iactionlink(self),state + [as_disabled]);
 end;
 inherited;
end;

procedure tcustomdatabutton.setvisible(const avalue: boolean);
begin
 if avalue then begin
  setactionstate(iactionlink(self),state - [as_invisible]);
 end
 else begin
  setactionstate(iactionlink(self),state + [as_invisible]);
 end;
 inherited;
end;

function tcustomdatabutton.isstatestored: boolean;
begin
 result:= isactionstatestored(factioninfo);
end;

procedure tcustomdatabutton.readcaptionpos(reader: treader);
begin
 imagepos:= readcaptiontoimagepos(reader);
end;

procedure tcustomdatabutton.readshortcut(reader: treader);
begin
 shortcut:= translateshortcut(reader.readinteger);
end;

procedure tcustomdatabutton.readshortcut1(reader: treader);
begin
 shortcut1:= translateshortcut(reader.readinteger);
end;

procedure tcustomdatabutton.readsc(reader: treader);
begin
 shortcuts:= readshortcutarty(reader);
end;

procedure tcustomdatabutton.writesc(writer: twriter);
begin
 writeshortcutarty(writer,factioninfo.shortcut);
end;

procedure tcustomdatabutton.readsc1(reader: treader);
begin
 shortcuts1:= readshortcutarty(reader);
end;

procedure tcustomdatabutton.writesc1(writer: twriter);
begin
 writeshortcutarty(writer,factioninfo.shortcut1);
end;

procedure tcustomdatabutton.defineproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('captionpos',{$ifdef FPC}@{$endif}readcaptionpos,nil,false);
 filer.defineproperty('shortcut',{$ifdef FPC}@{$endif}readshortcut,nil,false);
 filer.defineproperty('shortcut1',{$ifdef FPC}@{$endif}readshortcut1,nil,false);
 filer.defineproperty('sc',{$ifdef FPC}@{$endif}readsc,
                           {$ifdef FPC}@{$endif}writesc,
       isactionshortcutstored(factioninfo) and
       ((filer.ancestor = nil) and (factioninfo.shortcut <> nil) or
       ((filer.ancestor <> nil) and 
         not issameshortcut(factioninfo.shortcut,
                  tcustombutton(filer.ancestor).shortcuts))));
 filer.defineproperty('sc1',{$ifdef FPC}@{$endif}readsc1,
                           {$ifdef FPC}@{$endif}writesc1,
       isactionshortcut1stored(factioninfo) and
       ((filer.ancestor = nil) and (factioninfo.shortcut1 <> nil) or
       ((filer.ancestor <> nil) and 
         not issameshortcut(factioninfo.shortcut,
                  tcustombutton(filer.ancestor).shortcuts))));
end;

procedure tcustomdatabutton.loaded;
begin
 inherited;
 actionendload(iactionlink(self));
end;

procedure tcustomdatabutton.docellevent(const ownedcol: boolean;
               var info: celleventinfoty);
begin
 inherited;
 if ownedcol and (info.eventkind in [cek_mouseenter,cek_mouseleave]) then begin
  fgridintf.getcol.grid.invalidatecell(info.cell);
 end;
end;

procedure tcustomdatabutton.setshortcuts(const avalue: shortcutarty);
begin
 setactionshortcuts(iactionlink(self),avalue);
end;

procedure tcustomdatabutton.setshortcuts1(const avalue: shortcutarty);
begin
 setactionshortcuts1(iactionlink(self),avalue);
end;

procedure tcustomdatabutton.internalexecute;
begin
 if bo_asyncexecute in foptions then begin
  asyncevent;
 end
 else begin
  doexecute;
 end;
end;

procedure tcustomdatabutton.doasyncevent(var atag: integer);
begin
 if atag = 0 then begin
  doexecute;
 end;
end;

procedure tcustomdatabutton.setcolor(const avalue: colorty);
begin
 if csloading in componentstate then begin
  inherited;      //no actionchanged
 end;
 setactioncolor(iactionlink(self),avalue);
end;

procedure tcustomdatabutton.objectchanged(const sender: tobject);
var
 i1: int32;
begin
 inherited;
 for i1:= 0 to high(fvaluefaces.fitems) do begin
  tcustomface(fvaluefaces.fitems[i1]).checktemplate(sender);
 end;
end;

function tcustomdatabutton.getassistiveflags(): assistiveflagsty;
begin
 result:= inherited getassistiveflags() + [asf_button];
end;

function tcustomdatabutton.getassistivecaption(): msestring;
begin
 result:= factioninfo.captiontext;
 if result = '' then begin
  result:= inherited getassistivecaption();
 end;
end;

procedure tcustomdatabutton.doupdate;
begin
 if factioninfo.action <> nil then begin
  factioninfo.action.doupdate;
 end;
 if canevent(tmethod(fonupdate)) then begin
  fonupdate(self);
 end;
end;

procedure tcustomdatabutton.doidle(var again: boolean);
begin
 doupdate;
end;

procedure tcustomdatabutton.domousewheelevent(var info: mousewheeleventinfoty);
begin
 if not (es_transientfor in info.eventstate) then begin
  inherited togglevalue(oe_readonly in getoptionsedit,info.wheel = mw_down);
 end
 else begin
  inherited;
 end;
end;

procedure tcustomdatabutton.setvaluedisabled(const avalue: integer);
begin
 if fvaluedisabled <> avalue then begin
  fvaluedisabled:= avalue;
  {
  if fvaluedisabled = -2 then begin
   exclude(fstate,des_noenablesync);
  end
  else begin
   include(fstate,des_noenablesync);
   checkdisabled();
  end;
  }
 end;
end;

procedure tcustomdatabutton.setvaluefonts(const avalue: tvaluefontarrayprop);
begin
 fvaluefonts.assign(avalue);
end;

function tcustomdatabutton.valueenabledstate(const avalue: integer): boolean;
begin
 result:= enabled;
 if (fvaluedisabled <> -2) then begin
  result:= avalue <> fvaluedisabled;
 end;
end;

procedure tcustomdatabutton.checkdisabled();
begin
 if (fgridintf = nil) then begin
                  //no check if inactive gridrow
  enabled:= valueenabledstate(fvalue);
 end
 else begin
  if valueenabledstate(fvalue) then begin
   exclude(finfo.state,shs_disabled);
   exclude(fstate,des_disabled);
  end
  else begin
   include(finfo.state,shs_disabled);
   include(fstate,des_disabled);
  end;
 end;
end;

procedure tcustomdatabutton.valuechanged;
begin
 checkdisabled();
 inherited;
end;

procedure tcustomdatabutton.gridtovalue(arow: integer);
begin
 inherited;
 checkdisabled();
end;

procedure tcustomdatabutton.initnewwidget(const ascale: real);
begin
 inherited;
 if fgridintf <> nil then begin
  fgridintf.getcol.options:= 
                fgridintf.getcol.grid.datacols.options - [co_drawfocus];
 end;
end;

{ tstockglyphdatabutton }

constructor tstockglyphdatabutton.create(aowner: tcomponent);
begin
 inherited;
 imagelist:= stockobjects.glyphs;
 glyph:= stg_none;
end;

procedure tstockglyphdatabutton.setglyph(const avalue: stockglyphty);
begin
 fglyph:= avalue;
 imagenr:= ord(avalue);
end;

{ tcustomdataicon }

constructor tcustomdataicon.create(aowner: tcomponent);
begin
 inherited;
 fvaluedefault:= -1;
 fvalue:= fvaluedefault;
 fimagenums:= tintegerarrayprop.create;
 fimagenums.onchange:= {$ifdef FPC}@{$endif}imagenumschanged;
end;

destructor tcustomdataicon.destroy;
begin
 fimagenums.free;
 inherited;
end;

procedure tcustomdataicon.setnullvalue;
begin
 value:= -1;
end;

procedure tcustomdataicon.objectevent(const sender: tobject;
  const event: objecteventty);
begin
 inherited;
 if (sender = fimagelist) and (event = oe_changed) then begin
  formatchanged;
 end;
end;

procedure tcustomdataicon.paintglyph(const canvas: tcanvas;
                       const acolorglyph: colorty; const avalue;
                       const arect: rectty);
var
 int1,int2: integer;
 po1: pintegeraty;
begin
 if (fimagelist <> nil) then begin
  if @avalue = nil then begin
   int1:= fvalue
  end
  else begin
   int1:= integer(avalue);
  end;
  if (int1 >= 0) then begin
   int1:= int1 + fimageoffset;
   if (int1 < fimagelist.count) and (int1 >= 0) then begin
    fimagelist.paint(canvas,int1,arect,[al_ycentered,al_xcentered]);
   end;
  end
  else begin
   if (int1 <> -1) and (longword(int1) <> $80000000) then begin
   {$warnings off}
    po1:= pintegeraty(tarrayprop1(fimagenums).getdatapo^);
   {$warnings on}
    for int2:= 0 to fimagenums.count-1 do begin
     if int1 and bits[int2] <> 0 then begin
      fimagelist.paint(canvas,po1^[int2],arect,[al_ycentered,al_xcentered]);
     end;
    end;
   end;
  end;
 end;
 inherited;
end;

procedure tcustomdataicon.setimagelist(const aValue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(fimagelist));
 formatchanged;
end;

procedure tcustomdataicon.setimageoffset(const aValue: integer);
begin
 if fimageoffset <> avalue then begin
  fimageoffset := aValue;
  formatchanged;
 end;
end;

procedure tcustomdataicon.setimagenums(const avalue: tintegerarrayprop);
begin
 fimagenums.assign(avalue);
end;

procedure tcustomdataicon.imagenumschanged(const sender: tarrayprop; const index: integer);
begin
 formatchanged;
end;


{ tpointeredit }

function tpointeredit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridpointerdatalist.create(sender);
end;

function tpointeredit.getdatalistclass: datalistclassty;
begin
 result:= tgridpointerdatalist;
end;

procedure tpointeredit.setvalue(const avalue: pointer);
begin
 fvalue:= avalue;
 valuechanged;
end;

function tpointeredit.getgridvalue(const index: integer): pointer;
begin
 internalgetgridvalue(index,result);
end;

procedure tpointeredit.setgridvalue(const index: integer; const avalue: pointer);
begin
 internalsetgridvalue(index,avalue);
end;

function tpointeredit.getgridvalues: pointerarty;
begin
 result:= tpointerdatalist(fgridintf.getcol.datalist).asarray;
end;

procedure tpointeredit.setgridvalues(const avalue: pointerarty);
begin
 tpointerdatalist(fgridintf.getcol.datalist).asarray:= avalue;
end;

procedure tpointeredit.initnewcomponent(const ascale: real);
begin
 //do nothing
end;

procedure tpointeredit.paintglyph(const canvas: tcanvas; 
               const acolorglyph: colorty; const avalue;
               const arect: rectty);
var
 po1: pointer;
 int1: integer;
begin
 if canevent(tmethod(fonpaintglyph)) then begin
  if @avalue = nil then begin
   po1:= fvalue;
   int1:= gridrow;
  end
  else begin
   po1:= pointer(avalue);
   int1:= pcellinfoty(canvas.drawinfopo)^.cell.row;
  end;
  fonpaintglyph(self,canvas,po1,int1);
 end;
// inherited;
end;

procedure tpointeredit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tpointeredit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

function tpointeredit.griddata: tgridpointerdatalist;
begin
 result:= tgridpointerdatalist(inherited griddata);
end;

procedure tpointeredit.setvaluedata(const source);
begin
 value:= pointer(source);
end;

procedure tpointeredit.getvaluedata(out dest);
begin
 pointer(dest):= value;
end;

{ tbarface }

constructor tbarface.create(const intf: iface);
begin
 inherited;
 with fade_color do begin
  count:= 1;
  items[0]:= defaultbarcolor;
 end;
end;

{ tbarframe }

constructor tbarframe.create(const aowner: tcustomprogressbar);
begin
 fowner:= aowner;
 fstate:= [fs_nowidget,fs_nosetinstance];
 inherited create(iscrollframe(aowner));
end;

{ tcustomprogressbar }

constructor tcustomprogressbar.create(aowner: tcomponent);
begin
 fbar_face:= tbarface.create(iface(self));
 fbar_frame:= tbarframe.create(self);
 fformat:= '0%';
 fvaluerange:= 100;
 ftextflags:= [tf_ycentered,tf_xcentered];
 inherited;
 optionswidget:= defaultoptionswidgetnofocus;
end;

destructor tcustomprogressbar.destroy;
begin
 inherited;
 fbar_face.free;
 fbar_frame.free;
end;

procedure tcustomprogressbar.setvalue(const avalue: realty);
begin
 if not (csloading in componentstate) then begin
  application.lock;
  try
   if avalue = 0.0 then begin
    fcancel:= false;
   end; 
   inherited;
  finally
   application.unlock;
  end;
 end
 else begin
  inherited;
 end;
end;

procedure tcustomprogressbar.setbar_face(const avalue: tbarface);
begin
 fbar_face.assign(avalue);
end;

procedure tcustomprogressbar.updatebarrect(const avalue: realty; const arect: rectty;
                              out facedest,framebardest,facebardest: rectty);
var
 int1,int2,int3: integer;
begin
 if avalue = emptyreal then begin
  facedest:= nullrect;
  framebardest:= nullrect;
  facebardest:= nullrect;
 end
 else begin
  with fbar_frame do begin
   facedest.x:= arect.x + fi.innerframe.left;  //origin = paintpos
   facedest.y:= arect.y + fi.innerframe.top;
   int2:= (finnerframe.left+finnerframe.right);
   int3:= (finnerframe.top+finnerframe.bottom);
   facedest.cx:= arect.cx - int2;
   facedest.cy:= arect.cy - int3;
  end;
//  facedest:= deflaterect(arect,fbar_frame.innerframe);
//  facedest.pos:= pointty(fbar_frame.fi.innerframe.topleft);
                    //origin = paintpos
  framebardest:= arect;
  if fdirection in [gd_right,gd_left] then begin
   int1:= round(avalue*facedest.cx) + int2;
   if fdirection = gd_left then begin
    inc(framebardest.x,framebardest.cx - int1);
   end;
   framebardest.cx:= int1;
  end
  else begin
   int1:= round(avalue*facedest.cy) + int3;
   if fdirection = gd_up then begin
    inc(framebardest.y,framebardest.cy - int1);
   end;
   framebardest.cy:= int1;
  end;
  facebardest:= deflaterect(framebardest,fbar_frame.innerframe);
  subpoint1(facebardest.pos,pointty(fbar_frame.fpaintframe.topleft));
                                 //origin = paintpos
 end;
end;

procedure tcustomprogressbar.updatebar;
begin
 updatebarrect(fvalue,innerclientrect,ffacerect,fframebarrect,ffacebarrect);
end;

procedure tcustomprogressbar.clientrectchanged;
begin
 inherited;
 updatebar;
end;

procedure tcustomprogressbar.dochange;
begin
 updatebar;
 inherited;
end;

procedure tcustomprogressbar.changedirection(const avalue: graphicdirectionty;
               var dest: graphicdirectionty);
begin
 fbar_face.fade_direction:= rotatedirection(fbar_face.fade_direction,avalue,dest);
 fbar_frame.changedirection(avalue,dest);
 inherited;
 updatebar;
end;

procedure tcustomprogressbar.paintglyph(const canvas: tcanvas;
                               const acolorglyph: colorty; const avalue;
                               const arect: rectty);
var
 po1,po2,po3: prectty;
 rect1,rect2,rect3: rectty;
 rea1: realty;
begin
 if @avalue = nil then begin
  po1:= @ffacerect;
  po2:= @fframebarrect;
  po3:= @ffacebarrect;
  rea1:= fvalue;
 end
 else begin
  po1:= @rect1;
  po2:= @rect2;
  po3:= @rect3;
  rea1:= realty(avalue);
  updatebarrect(realty(avalue),arect,rect1,rect2,rect3);  
 end;
 if not (rea1 = emptyreal) then begin
  canvas.save;
  fbar_frame.paintbackground(canvas,po2^,true,true); 
             //moves origin to paintrect and sets cliprect
  canvas.intersectcliprect(po3^);
  fbar_face.paint(canvas,po1^);
  canvas.restore;
  fbar_frame.paintoverlay(canvas,po2^);
  if fformat <> '' then begin
   drawtext(canvas,realtytostring(applyrange(rea1,fvaluerange,fvaluestart),
                                         fformat),arect,ftextflags,ffont);
  end;
 end;
 inherited;
end;

procedure tcustomprogressbar.internalcreateframe;
begin
 tdispframe.create(iscrollframe(self));
end;

procedure tcustomprogressbar.setvaluerange(const avalue: real);
begin
 fvaluerange:= avalue;
 formatchanged;
end;

procedure tcustomprogressbar.setvaluestart(const avalue: real);
begin
 fvaluestart:= avalue;
 formatchanged;
end;

procedure tcustomprogressbar.setformat(const avalue: msestring);
begin
 fformat:= avalue;
 formatchanged;
end;

procedure tcustomprogressbar.settextflags(const avalue: textflagsty);
begin
 ftextflags:= avalue;
 formatchanged;
end;

procedure tcustomprogressbar.setbar_frame(const avalue: tbarframe);
begin
 fbar_frame.assign(avalue);
end;

procedure tcustomprogressbar.doprogress(const sender: tobject; const avalue: real;
               var acancel: boolean);
begin
 application.lock;
 try
  value:= avalue;
  acancel:= acancel or cancel;
  if canevent(tmethod(fonprogress)) then begin
   fonprogress(sender,avalue,acancel);
  end;
  if (acancel or (avalue >= 1.0)) and canevent(tmethod(fonfinished)) then begin
   fonfinished(sender,avalue,acancel);
  end;
 finally
  application.unlock;
 end;
end;

procedure tcustomprogressbar.readformat(reader: treader);
begin
 fformat:= treader_readmsestring(reader);
// {$ifdef mse_unicodestring}
// fformat:= reader.readunicodestring;
// {$else}
// fformat:= reader.readwidestring;
// {$endif}
end;

procedure tcustomprogressbar.writeformat(writer: twriter);
begin
 twriter_writemsestring(writer,fformat);
// {$ifdef mse_unicodestring}
// writer.writeunicodestring(fformat);
// {$else}
// writer.writewidestring(fformat);
// {$endif}
end;

procedure tcustomprogressbar.readvaluescale(reader: treader);
begin
 valuerange:= valuescaletorange(reader);
end;

procedure tcustomprogressbar.defineproperties(filer: tfiler);
begin
 filer.defineproperty('format',{$ifdef FPC}@{$endif}readformat,
                                    {$ifdef FPC}@{$endif}writeformat,true);
 filer.defineproperty('valuescale',{$ifdef FPC}@{$endif}readvaluescale,nil,false);
end;

procedure tcustomprogressbar.gridtovalue(arow: integer);
begin
 inherited;
 updatebar();
end;

{ tsliderframe }

procedure tsliderframe.settemplateinfo(const ainfo: frameinfoty);
begin
 inherited;
 if not (frl1_colorglyph in flocalprops1) and 
                          (ainfo.ba.colorglyph <> cl_default) then begin
  tslider(fintf.getwidget).scrollbar.colorglyph:= ainfo.ba.colorglyph;
 end;
 if not (frl1_colorpattern in flocalprops1) and 
                          (ainfo.ba.colorpattern <> cl_default) then begin
  tslider(fintf.getwidget).scrollbar.colorpattern:= ainfo.ba.colorpattern;
 end;
end;

end.
