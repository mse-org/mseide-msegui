{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegraphedits;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 {$ifdef FPC}classes{$else}Classes{$endif},msegui,mseguiglob,msescrollbar,
 msegraphutils,msegraphics,mseevent,
 msewidgets,mseeditglob,msestockobjects,msestat,msestatfile,
 mseclasses,msesimplewidgets,
 msegrids,msewidgetgrid,msedatalist,msebitmap,msetypes,msestrings,msearrayprops,
 msedrawtext,mseshapes;

const
 defaultsliderwidth = 200;
 defaultsliderheight = 20;
 defaultboxsize = 13;
 defaultsliderscrollbaroptions = defaultscrollbaroptions + [sbo_valuekeys];
 
type
 tgrapheditframe = class(tcustomcaptionframe)
  public
   constructor create(const intf: iframe);
  published
   property options;
   property levelo default -2;
   property leveli;
   property framewidth;
   property colorframe;
   property colorframeactive;
   property colordkshadow;
   property colorshadow;
   property colorlight;
   property colorhighlight;
   property colordkwidth;
   property colorhlwidth;
   property framei_left;
   property framei_top;
   property framei_right;
   property framei_bottom;
   property colorclient default cl_foreground;
   property caption;
   property captionpos default cp_right;
   property captiondist;
   property captiondistouter;
   property captionoffset;
   property captionnoclip;
   property font;
   property localprops; //before template
   property template;
 end;

 tgraphdataedit = class(tpublishedwidget,igridwidget,istatfile)
  private
   fonchange: notifyeventty;
   fondataentered: notifyeventty;
   fcolorglyph: colorty;
   fstatvarname: msestring;
   fstatfile: tstatfile;
   foptionsedit: optionseditty;
   fedited: boolean;
   procedure setcolorglyph(const Value: colorty);
   procedure setstatfile(const Value: tstatfile);
   procedure setoptionsedit(const avalue: optionseditty);
   function getreadonly: boolean;
   procedure setreadonly(const avalue: boolean);
  protected
   fgridintf: iwidgetgrid;
   
   function getoptionsedit: optionseditty; virtual;
   procedure updateoptions; virtual;
   procedure loaded; override;
   procedure internalcreateframe; override;
   procedure setenabled(const avalue: boolean); override;

   function getgridintf: iwidgetgrid;
   procedure checkgrid;
   procedure internalfillcol(const value);
   procedure internalassigncol(const value);
   procedure internalgetgridvalue(const index: integer; out value);
   procedure internalsetgridvalue(const index: integer; const avalue);
   procedure dochange; virtual;
   function docheckvalue(var avalue): boolean; virtual;
   procedure valuechanged;
   procedure formatchanged;
   procedure dopaint(const canvas: tcanvas); override;
   function needsfocuspaint: boolean; override;
   procedure internalcheckvalue(var avalue; var accept: boolean); virtual; abstract;
   procedure paintglyph(const canvas: tcanvas; const avalue; const arect: rectty);
                 virtual; abstract;
   procedure dofontheightdelta(var delta: integer); override;
   
   procedure updatereadonlystate; virtual;
   //igridwidget
   procedure setfirstclick;
   function createdatalist(const sender: twidgetcol): tdatalist; virtual; abstract;
   function getdatatyp: datatypty; virtual; abstract;
   function getdefaultvalue: pointer; virtual;
   function getrowdatapo(const info: cellinfoty): pointer; virtual;
   procedure setgridintf(const intf: iwidgetgrid); virtual;
   function getcellframe: framety; virtual;
   procedure drawcell(const canvas: tcanvas);
   procedure valuetogrid(const row: integer); virtual; abstract;
   procedure gridtovalue(const row: integer); virtual;
   procedure docellevent(const ownedcol: boolean; var info: celleventinfoty); virtual;
   procedure sortfunc(const l,r; var result: integer); virtual;
   procedure gridvaluechanged(const index: integer); virtual;
   procedure updatecoloptions(var aoptions: coloptionsty);
   procedure statdataread; virtual;
   procedure griddatasourcechanged; virtual;

   //istatfile
   procedure dostatread(const reader: tstatreader);
   procedure dostatwrite(const writer: tstatwriter);
   procedure statreading;
   procedure statread;
   function getstatvarname: msestring;

   procedure readstatvalue(const reader: tstatreader); virtual;
   procedure writestatvalue(const writer: tstatwriter); virtual;
   procedure readstatstate(const reader: tstatreader); virtual;
   procedure writestatstate(const writer: tstatwriter); virtual;
   procedure readstatoptions(const reader: tstatreader); virtual;
   procedure writestatoptions(const writer: tstatwriter); virtual;

  public
   constructor create(aowner: tcomponent); override;
   procedure initnewcomponent(const ascale: real); override;
   procedure initgridwidget; virtual;

   function edited: boolean;
   procedure initfocus;
   function actualcolor: colorty; override;
   function col: twidgetcol;
   function row: integer;
   function griddata: tdatalist;

   function checkvalue: boolean; virtual; abstract;
   function seteditfocus: boolean;

   property objectlinker: tobjectlinker read getobjectlinker
                {$ifdef msehasimplements}implements istatfile{$endif};
//   property oncellevent: celleventty read foncellevent write foncellevent;
   property colorglyph: colorty read fcolorglyph write setcolorglyph
           default cl_glyph;
   property readonly: boolean read getreadonly write setreadonly;
  published
   property statfile: tstatfile read fstatfile write setstatfile;
   property statvarname: msestring read getstatvarname write fstatvarname;
   property optionsedit: optionseditty read getoptionsedit write setoptionsedit
                              default defaultoptionsedit;
   property onchange: notifyeventty read fonchange write fonchange;
   property ondataentered: notifyeventty read fondataentered write fondataentered;
//   property onmouseevent: mouseeventty read fonmouseevent write fonmouseevent;
//   property onkeydown: keyeventty read fonkeydown write fonkeydown;
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
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
   procedure paintglyph(const canvas: tcanvas; const avalue; const arect: rectty);
                 override;
//   procedure dopaint(const canvas: tcanvas); override;
  public
   procedure initnewcomponent(const ascale: real); override;
   property value: pointer read fvalue write setvalue default nil;
   property gridvalue[const index: integer]: pointer
        read getgridvalue write setgridvalue; default;
   property gridvalues: pointerarty read getgridvalues write setgridvalues;
  published
   property onpaintglyph: paintpointerglypheventty read fonpaintglyph write fonpaintglyph;
 end;
 
 tsliderscrollbar = class(tcustomscrollbar,iface)
  private
   fface: tface;
   procedure setface(const avalue: tface);
  protected
   //iface
   function getwidget: twidget;
   function translatecolor(const acolor: colorty): colorty;
  public
   constructor create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: objectprocty = nil); override;
   destructor destroy; override;
   procedure paint(const canvas: tcanvas); override;
  published
   property options default defaultsliderscrollbaroptions;
//   property width;
//   property indentstart;
//   property indentend;
   property stepsize;
   property pagesize;
   property buttonlength default defaultbuttonminlength;
   property buttonendlength;
   property buttonminlength;
   property color;
   property colorpattern;
   property colorglyph;
   property facebutton;
   property faceendbutton;
   property face: tface read fface write setface;
 end;

 trealgraphdataedit = class(tgraphdataedit)
  private
   fonsetvalue: setrealeventty;
   fdirection: graphicdirectionty;
   procedure setvalue(const avalue: realty);
   procedure setdirection(const avalue: graphicdirectionty);
   function getgridvalue(const index: integer): realty;
   procedure setgridvalue(const index: integer; const avalue: realty);
   function getgridvalues: realarty;
   procedure setgridvalues(const avalue: realarty);
  protected
   fvalue: realty;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
   procedure valuetogrid(const arow: integer); override;
   procedure gridtovalue(const arow: integer); override;
   procedure internalcheckvalue(var avalue; var accept: boolean); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure setnullvalue; virtual; //for dbedits
  public
   constructor create(aowner: tcomponent); override;
   procedure fillcol(const value: realty);
   procedure assigncol(const avalue: trealdatalist);
   function isnull: boolean;
   property gridvalue[const index: integer]: realty
        read getgridvalue write setgridvalue; default;
   property gridvalues: realarty read getgridvalues write setgridvalues;
  published
   property bounds_cx default defaultsliderwidth;
   property bounds_cy default defaultsliderheight;
   property value: realty read fvalue write setvalue;
   property onsetvalue: setrealeventty read fonsetvalue write fonsetvalue;
   property direction: graphicdirectionty read fdirection write setdirection default gd_right;
 end;
 
 tslider = class(trealgraphdataedit,iscrollbar)
  private
   fscrollbar: tsliderscrollbar;
   fupdating: boolean;
   procedure setscrollbar(const avalue: tsliderscrollbar);
  protected
   procedure clientrectchanged; override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure clientmouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure doenter; override;
   procedure doexit; override;
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty);

   procedure dochange; override;
   procedure paintglyph(const canvas: tcanvas; 
                  const avalue; const arect: rectty); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure changedirection(const avalue: graphicdirectionty;
                                            var dest: graphicdirectionty); override;
  published
   property scrollbar: tsliderscrollbar read fscrollbar write setscrollbar;
 end;

const
 defaultbarcolor = cl_ltblue;
 
type
 tbarface = class(tface)
  public
   constructor create(const intf: iface);
 end;

 tcustomprogressbar = class;
  
 tbarframe = class(tframe)
  private
   fowner: tcustomprogressbar;
  public
   constructor create(const aowner: tcustomprogressbar);
 end;

 tcustomprogressbar = class(trealgraphdataedit,iface)
  private
   fbar_face: tbarface;
   fbar_frame: tbarframe;
   ffacerect: rectty;
   fframebarrect: rectty;
   ffacebarrect: rectty;
   fvaluescale: real;
   fformat: string;
   ftextflags: textflagsty;
   fonfinished: progresseventty;
   fonprogress: progresseventty;
   fcancel: boolean;
   procedure setvalue(const avalue: realty);
   procedure setbar_face(const avalue: tbarface);
   procedure updatebarrect(const avalue: realty; const arect: rectty;
                    out facedest,framebardest,facebardest: rectty);
   procedure updatebar;
   procedure setvaluescale(const avalue: real);
   procedure setformat(const avalue: string);
   procedure settextflags(const avalue: textflagsty);
   procedure setbar_frame(const avalue: tbarframe);
  protected
   procedure clientrectchanged; override;
   procedure dochange; override;
   procedure paintglyph(const canvas: tcanvas; 
                  const avalue; const arect: rectty); override;
   procedure internalcreateframe; override;
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
          //threadsave, range 0 .. 1.0
  published
   property optionswidget default defaultoptionswidgetnofocus;
   property bar_face: tbarface read fbar_face write setbar_face;
   property bar_frame: tbarframe read fbar_frame write setbar_frame;
   property valuescale: real read fvaluescale write setvaluescale; //default 0.01
   property format: string read fformat write setformat;
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
 end;
  
 ttogglegraphdataedit = class(tgraphdataedit)
  private
   foptions: buttonoptionsty;
  protected
   fcheckcaption: boolean;
   procedure togglevalue; virtual; abstract;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure dokeyup(var info: keyeventinfoty); override;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property options: buttonoptionsty read foptions write foptions
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
   fgroup: integer;
   procedure setvalue(const Value: boolean); virtual;
   function getglyph: stockglyphty; virtual;
   function getgridvalue(const index: integer): longbool;
   procedure setgridvalue(const index: integer; const Value: longbool); virtual;
   function getgridvalues: longboolarty;
   procedure setgridvalues(const Value: longboolarty);
   function getvalue: boolean;
   function getvaluedefault: boolean;
   procedure setvaluedefault(const Value: boolean);
  protected
   procedure setnullvalue;
   function getdefaultvalue: pointer; override;
   procedure valuetogrid(const arow: integer); override;
   procedure gridtovalue(const arow: integer); override;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
   procedure togglevalue; override;
   procedure paintglyph(const canvas: tcanvas; const avalue; const arect: rectty);
                 override;
   procedure internalcheckvalue(var avalue; var accept: boolean); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   function getvaluebitmask: longword;
   procedure setvaluebitmask(const avalue: longword);
   function getgridvaluebitmask(const index: integer): longword;
   procedure setgridvaluebitmask(const index: integer; const avalue: longword);
  public
   constructor create(aowner: tcomponent); override;
   procedure fillcol(const avalue: longbool);
   function checkvalue: boolean; override;
   procedure togglegridvalue(const index: integer); virtual;
   
   property value: boolean read getvalue write setvalue default false;
   property valuedefault: boolean read getvaluedefault write setvaluedefault default false;
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
   property gridvaluebitmask[const index: integer]: longword read getgridvaluebitmask
                        write setgridvaluebitmask;
                  //ored valuetagbit of all edits in group

   function gridvaluetag(const index: integer; const falsevalue: integer): integer;
           //if value = true -> tag, falsevalue otherwise
   procedure updatetagvalue(const bitset: integer);
           //value -> true if bitset and tag <> 0
   procedure gridupdatetagvalue(const index: integer; const bitset: integer);
   property gridvalues: longboolarty read getgridvalues write setgridvalues;
   function groupmembers: booleaneditarty;
   function tagitem(const atag: integer): tcustombooleanedit; //nil if none

   property bounds_cx default defaultboxsize;
   property bounds_cy default defaultboxsize;
   property onsetvalue: setbooleaneventty read fonsetvalue write fonsetvalue;
   property group: integer read fgroup write fgroup default 0;
 end;

 tbooleanedit = class(tcustombooleanedit)
  published
   property bounds_cx  default defaultboxsize;
   property bounds_cy  default defaultboxsize;
   property onsetvalue;
   property value;
   property valuedefault;
   property group;
 end;
 
 tcustombooleaneditradio = class(tcustombooleanedit)
  private
   function getglyph: stockglyphty; override;
   procedure setvalue(const avalue: boolean); override;
   function getcheckedtag: integer;
   procedure setcheckedtag(const avalue: integer);
   procedure setgridvalue(const aindex: integer; const aValue: longbool); override;
   function internalcheckeditem(out single: boolean): tcustombooleaneditradio; //nil if none
  protected
   procedure togglevalue; override;
  public
   procedure togglegridvalue(const index: integer); override;
   function checkeditem: tcustombooleaneditradio; //nil if none
   property checkedtag: integer read getcheckedtag write setcheckedtag;
                             //-1 if none checked
 end;

 tbooleaneditradio = class(tcustombooleaneditradio)
  published
   property bounds_cx  default defaultboxsize;
   property bounds_cy  default defaultboxsize;
   property onsetvalue;
   property value;
   property valuedefault;
   property group;
 end;

 tcustomintegergraphdataedit = class(ttogglegraphdataedit)
  private
   fvalue: integer;
   fvaluedefault: integer;
   fonsetvalue: setintegereventty;
   fmin: integer;
   fmax: integer;
   fdatalist: tintegerdatalist;
   procedure setvalue(const Value: integer);
   function getgridvalue(const index: integer): integer;
   procedure setgridvalue(const index, Value: integer);
   function getgridvalues: integerarty;
   procedure setgridvalues(const Value: integerarty);
  protected
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatatyp: datatypty; override;
   function getdefaultvalue: pointer; override;
   procedure valuetogrid(const arow: integer); override;
   procedure gridtovalue(const arow: integer); override;
   procedure internalcheckvalue(var avalue; var accept: boolean); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
   procedure togglevalue; override;
   procedure doinc(var avalue: integer);
  public
   function checkvalue: boolean; override;
   procedure togglegridvalue(const index: integer);
   procedure fillcol(const avalue: integer);
   property gridvalue[const index: integer]: integer
        read getgridvalue write setgridvalue; default;
   property gridvalues: integerarty read getgridvalues write setgridvalues;
   property datalist: tintegerdatalist read fdatalist;
   property onsetvalue: setintegereventty read fonsetvalue write fonsetvalue;
   property value: integer read fvalue write setvalue default 0;
   property valuedefault: integer read fvaluedefault write fvaluedefault default 0;
   property min: integer read fmin write fmin default 0; //checked by togglevalue
   property max: integer read fmax write fmax default 0; //checked by togglevalue
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
   property items[const index: integer]: tface read getitems; default;
 end;
 
 tcustomdatabutton = class(tcustomintegergraphdataedit)
  private
   fonexecute: notifyeventty;
   fvaluefaces: tvaluefacearrayprop;
   fcaption: captionty;
   fimageoffset: integer;
   fimagenums: tintegerarrayprop;
   fimagenr: integer;
   procedure setcolorglyph(const avalue: colorty);
   procedure setvaluefaces(const avalue: tvaluefacearrayprop);
   procedure setcaption(const avalue: captionty);
   procedure setcaptionpos(const avalue: captionposty);
   procedure setimagelist(const avalue: timagelist);
   procedure setimagenr(const avalue: integer);
   procedure setimageoffset(const avalue: integer);
   procedure setimagenums(const avalue: tintegerarrayprop);
  protected
   finfo: shapeinfoty;
   procedure setnullvalue;
   procedure doexecute; virtual;
   procedure togglevalue; override;
   procedure statechanged; override;
   procedure mouseevent(var info: mouseeventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure dokeyup(var info: keyeventinfoty); override;
   procedure clientrectchanged; override;
   procedure paintglyph(const canvas: tcanvas; const avalue;
                    const arect: rectty); override;
   procedure internalcreateframe; override;
   procedure setgridintf(const intf: iwidgetgrid); override;
   function checkfocusshortcut(var info: keyeventinfoty): boolean; override;
   function actualimagenr(const avalue: integer): integer;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure synctofontheight; override;
   procedure initgridwidget; override;
   procedure initnewcomponent(const ascale: real); override;
   property optionswidget default defaultoptionswidget - [ow_mousefocus];
   property valuefaces: tvaluefacearrayprop read fvaluefaces write setvaluefaces;
   property font: twidgetfont read getfont write setfont stored isfontstored;
   property caption: captionty read fcaption write setcaption;
   property captionpos: captionposty read finfo.captionpos write setcaptionpos
                              default cp_center;
   property imagelist: timagelist read finfo.imagelist write setimagelist;
   property imagenr: integer read fimagenr 
                                         write setimagenr default -1;
   property imageoffset: integer read fimageoffset write setimageoffset default 0;
   property imagenums: tintegerarrayprop read fimagenums write setimagenums;

   property options;
   property onexecute: notifyeventty read fonexecute write fonexecute;
   property onsetvalue;
   property value default -1;
   property valuedefault default -1;
   property min default -1; 
   property max default 0;
 end;

 tdatabutton = class(tcustomdatabutton)
  published
   property optionswidget;
   property valuefaces;
   property font;
   property caption;
   property captionpos;
   property imagelist;
   property imagenr;
   property imageoffset;
   property imagenums;
   property options;
   property onexecute;
   property onsetvalue;
   property value;
   property valuedefault;
   property min; 
   property max;
 end;

 tstockglyphdatabutton = class(tcustomdatabutton)
  private
   fglyph: stockglyphty;
   procedure setglyph(const avalue: stockglyphty);
  public
   constructor create(aowner: tcomponent); override;
  published
   property glyph: stockglyphty read fglyph write setglyph default stg_none;
   property imagenums;
   property optionswidget;
   property valuefaces;
   property font;
   property caption;
   property captionpos;
   property options;
   property onexecute;
   property onsetvalue;
   property value;
   property valuedefault;
   property min; 
   property max;
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
   procedure paintglyph(const canvas: tcanvas; const avalue;
           const arect: rectty); override;
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
 end;
 
 tdataicon = class(tcustomdataicon)
  published
   property onsetvalue;
   property value default -1;
   property valuedefault default -1;
   property min; 
   property max;
   property imagelist;
   property imageoffset;
   property imagenums;
 end;
 
implementation
uses
 SysUtils,msekeyboard,msebits,msereal,msedispwidgets,mseformatstr,mserichstring;

type
 tcustomframe1 = class(tcustomframe);
 tdatalist1 = class(tdatalist);
 twidgetcol1 = class(twidgetcol);
 twidget1 = class(twidget);
 tarrayprop1 = class(tarrayprop);

const
 valuevarname = 'value';

{ tgrapheditframe }

constructor tgrapheditframe.create(const intf: iframe);
begin
 inherited;
 fstate:= fstate + [fs_drawfocusrect,fs_captionfocus,fs_captionhint,
                     fs_paintrectfocus];
 fi.colorclient:= cl_foreground;
 fi.levelo:= -2;
 captionpos:= cp_right;
 internalupdatestate;
end;

{ tsliderscrollbar }

constructor tsliderscrollbar.create(intf: iscrollbar; org: originty;
  ondimchanged: objectprocty);
begin
 inherited;
 foptions:= defaultsliderscrollbaroptions;
 buttonlength:= defaultbuttonminlength;
 fface:= tface.create(iface(self));
end;

destructor tsliderscrollbar.destroy;
begin
 inherited;
 fface.Free;
end;

procedure tsliderscrollbar.setface(const avalue: tface);
begin
 fface.assign(avalue);
end;

function tsliderscrollbar.getwidget: twidget;
begin
 result:= fintf.getwidget;
end;

function tsliderscrollbar.translatecolor(const acolor: colorty): colorty;
begin
 result:= fintf.translatecolor(acolor);
end;

procedure tsliderscrollbar.paint(const canvas: tcanvas);
begin
 fface.paint(canvas,fdrawinfo.scrollrect);
 inherited;
end;

{ trealgraphdataedit }

constructor trealgraphdataedit.create(aowner: tcomponent);
begin
 inherited;
 size:= makesize(defaultsliderwidth,defaultsliderheight);
end;

procedure trealgraphdataedit.setvalue(const avalue: realty);
begin
 if fvalue <> avalue then begin
  if isemptyreal(avalue) then begin
   fvalue:= 0;
  end
  else begin
   fvalue:= avalue;
  end;
  valuechanged;
 end;
end;

function trealgraphdataedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= trealdatalist.create;
end;

function trealgraphdataedit.getdatatyp: datatypty;
begin
 result:= dl_real;
end;

procedure trealgraphdataedit.internalcheckvalue(var avalue; var accept: boolean);
begin
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,realty(avalue),accept);
 end;
 if accept then begin
  value:= realty(avalue);
 end;
end;

procedure trealgraphdataedit.valuetogrid(const arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

procedure trealgraphdataedit.gridtovalue(const arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure trealgraphdataedit.readstatvalue(const reader: tstatreader);
begin
 value:= reader.readreal(valuevarname,fvalue);
end;

procedure trealgraphdataedit.writestatvalue(const writer: tstatwriter);
begin
 writer.writereal(valuevarname,fvalue);
end;

procedure trealgraphdataedit.setdirection(const avalue: graphicdirectionty);
begin
 if fdirection <> avalue then begin
  changedirection(avalue,fdirection);
 end;
end;

function trealgraphdataedit.getgridvalue(const index: integer): realty;
begin
 internalgetgridvalue(index,result);
end;

procedure trealgraphdataedit.setgridvalue(const index: integer;
               const avalue: realty);
begin
 internalsetgridvalue(index,avalue);
end;

function trealgraphdataedit.getgridvalues: realarty;
begin
 result:= trealdatalist(fgridintf.getcol.datalist).asarray;
end;

procedure trealgraphdataedit.setgridvalues(const avalue: realarty);
begin
 trealdatalist(fgridintf.getcol.datalist).asarray:= avalue;
end;

procedure trealgraphdataedit.fillcol(const value: realty);
begin
 internalfillcol(value);
end;

procedure trealgraphdataedit.assigncol(const avalue: trealdatalist);
begin
 internalassigncol(avalue);
end;

function trealgraphdataedit.isnull: boolean;
begin
 result:= isemptyreal(value);
end;

procedure trealgraphdataedit.setnullvalue;
begin
 value:= emptyreal;
end;

{ tslider }

constructor tslider.create(aowner: tcomponent);
begin
 fscrollbar:= tsliderscrollbar.create(iscrollbar(self));
// fscrollbar.options:= [sbo_moveauto];
 inherited;
 size:= makesize(defaultsliderwidth,defaultsliderheight);
end;

destructor tslider.destroy;
begin
 fscrollbar.Free;
 inherited;
end;

procedure tslider.paintglyph(const canvas: tcanvas; const avalue;
                                   const arect: rectty);
begin
 //dummy
end;

procedure tslider.changedirection(const avalue: graphicdirectionty;
                                            var dest: graphicdirectionty);
begin
 fscrollbar.direction:= avalue;
 inherited;
end;

procedure tslider.clientrectchanged;
begin
 inherited;
 fscrollbar.dim:= innerclientrect;
end;

procedure tslider.dopaint(const acanvas: tcanvas);
begin
 inherited;
 fscrollbar.paint(acanvas);
end;

procedure tslider.clientmouseevent(var info: mouseeventinfoty);
begin
 if not (es_processed in info.eventstate) and not (csdesigning in componentstate) and
        not (oe_readonly in getoptionsedit) then begin
  fscrollbar.mouseevent(info);
 end;
 inherited;
end;

procedure tslider.dokeydown(var info: keyeventinfoty);
begin
 if not (es_processed in info.eventstate) and not (csdesigning in componentstate) and
    not (oe_readonly in getoptionsedit) then begin
  fscrollbar.keydown(info);
 end;
 inherited;
end;

procedure tslider.scrollevent(sender: tcustomscrollbar; event: scrolleventty);
var
 rea1: realty;
begin
 case event of
  sbe_valuechanged: begin
   if not fupdating then begin
    fupdating:= true;
    rea1:= sender.value;
    if not docheckvalue(rea1) then begin
     sender.value:= value;
    end
    else begin
     sender.value:= rea1;
    end;
    fupdating:= false;
   end;
  end;
 end;
end;

procedure tslider.doenter;
begin
 fscrollbar.enter;
 inherited;
end;

procedure tslider.doexit;
begin
 fscrollbar.exit;
 inherited;
end;

procedure tslider.setscrollbar(const avalue: tsliderscrollbar);
begin
 fscrollbar.assign(avalue);
end;

procedure tslider.dochange;
begin
 fscrollbar.value:= fvalue;
 inherited;
end;

{ tgraphdataedit }

constructor tgraphdataedit.create(aowner: tcomponent);
begin
 foptionsedit:= defaultoptionsedit;
 inherited;
 fcolorglyph:= cl_glyph;
end;

procedure tgraphdataedit.internalcreateframe;
begin
 tgrapheditframe.create(iframe(self));
end;

procedure tgraphdataedit.setcolorglyph(const Value: colorty);
begin
 if fcolorglyph <> value then begin
  fcolorglyph := Value;
  invalidate;
 end;
end;

procedure tgraphdataedit.dopaint(const canvas: tcanvas);
begin
 inherited;
 {$ifdef FPC} {$checkpointer off} {$endif}
 paintglyph(canvas,nil^,innerclientrect);
 {$ifdef FPC} {$checkpointer default} {$endif}
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

procedure tgraphdataedit.dochange;
begin
 if not (ws_loadedproc in fwidgetstate) and 
                   canevent(tmethod(fonchange)) then begin
  fonchange(self);
 end;
 invalidate;
end;

procedure tgraphdataedit.setgridintf(const intf: iwidgetgrid);
begin
 fgridintf:= intf;
end;

function tgraphdataedit.getcellframe: framety;
begin
 result:= getinnerstframe;
end;

procedure tgraphdataedit.drawcell(const canvas: tcanvas);
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  if datapo <> nil then begin
   paintglyph(canvas,datapo^,innerrect);
  end;
 end;
end;
{
procedure tgraphdataedit.updatecellzone(const pos: pointty; var result: cellzonety);
begin
 //dummy
end;
}
procedure tgraphdataedit.initgridwidget;
begin
 if fframe <> nil then begin
  with fframe do begin
   leveli:= 0;
   levelo:= 0;
   colorclient:= cl_transparent;
  end;
 end;
 fgridintf.getcol.options:= fgridintf.getcol.options + [co_drawfocus];
 optionswidget:= optionswidget - [ow_autoscale];
end;

function tgraphdataedit.docheckvalue(var avalue): boolean;
begin
 result:= true;
 internalcheckvalue(avalue,result);
 if result then begin
  fedited:= false;
  if canevent(tmethod(fondataentered)) then begin
   fondataentered(self);
  end;
 end;
end;

function tgraphdataedit.edited: boolean;
begin
 result:= fedited;
end;

procedure tgraphdataedit.initfocus;
begin
 //dummy
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
 if fgridintf = nil then begin
  if oe_savevalue in foptionsedit then begin
   readstatvalue(reader);
  end;
 end;
 if oe_savestate in foptionsedit then begin
  readstatstate(reader);
 end;
 if oe_saveoptions in foptionsedit then begin
  readstatoptions(reader);
 end;
end;

procedure tgraphdataedit.dostatwrite(const writer: tstatwriter);
begin
 if fgridintf = nil then begin
  if oe_savevalue in foptionsedit then begin
   writestatvalue(writer);
  end;
 end;
 if oe_savestate in foptionsedit then begin
  writestatstate(writer);
 end;
 if oe_saveoptions in foptionsedit then begin
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
 if oe_checkvaluepaststatread in foptionsedit then begin
  checkvalue;
 end;
end;

procedure tgraphdataedit.setfirstclick;
begin
 //dummy
end;

function tgraphdataedit.getdefaultvalue: pointer;
begin
 result:= nil;
end;

function tgraphdataedit.getrowdatapo(const info: cellinfoty): pointer;
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
 result:= fgridintf.getcol.datalist;
end;

function tgraphdataedit.col: twidgetcol;
begin
 if fgridintf = nil then begin
  result:= nil;
 end
 else begin
  result:= fgridintf.getcol;
 end;
end;

function tgraphdataedit.row: integer;
begin
 if fgridintf = nil then begin
  result:= -1;
 end
 else begin
  result:= fgridintf.getcol.grid.row;
 end;
end;

procedure tgraphdataedit.gridtovalue(const row: integer);
begin
 dochange;
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

function tgraphdataedit.getoptionsedit: optionseditty;
begin
 result := foptionsedit;
end;

procedure tgraphdataedit.updateoptions;
begin
 //dummy
end;

procedure tgraphdataedit.setoptionsedit(const avalue: optionseditty);
begin
 if foptionsedit <> avalue then begin
  foptionsedit:= avalue;
  if fgridintf <> nil then begin
   fgridintf.updateeditoptions(foptionsedit);
  end;
  updateoptions;
 end;
end;

procedure tgraphdataedit.sortfunc(const l, r; var result: integer);
begin
 tdatalist1(twidgetcol1(fgridintf.getcol).fdata).compare(l,r,result);
end;

procedure tgraphdataedit.internalgetgridvalue(const index: integer;
  out value);
begin
 checkgrid;
 fgridintf.getdata(index,value);
end;

procedure tgraphdataedit.internalsetgridvalue(const index: integer;
                                                        const avalue);
begin
 checkgrid;
 fgridintf.setdata(index,avalue);
end;
{
procedure tgraphdataedit.clientmouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (es_processed in info.eventstate) and canevent(tmethod(fonmouseevent)) then begin
  fonmouseevent(self,info);
 end;
end;
}
{
procedure tgraphdataedit.dokeydown(var info: keyeventinfoty);
begin
 if not (es_processed in info.eventstate) and canevent(tmethod(fonkeydown)) then begin
  fonkeydown(self,info);
 end;
 inherited;
end;
}
{
function tgraphdataedit.gridvalueempty(const row: integer): boolean;
begin
 result:= fgridintf.empty(row);
end;
}
procedure tgraphdataedit.docellevent(const ownedcol: boolean; var info: celleventinfoty);
begin
 //dummy
 {
 if ownedcol and canevent(tmethod(foncellevent)) then begin
  foncellevent(self,info);
 end;
 }
end;

procedure tgraphdataedit.valuechanged;
begin
 if not (csloading in componentstate) then begin
  if (fgridintf <> nil) and not (csdesigning in componentstate) then begin
   valuetogrid(fgridintf.getrow);
  end;
  dochange;
 end;
end;

procedure tgraphdataedit.formatchanged;
begin
 if not (csloading in componentstate) then begin
  if fgridintf <> nil then begin
   fgridintf.changed;
  end;
  invalidate;
 end;
end;

procedure tgraphdataedit.loaded;
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

procedure tgraphdataedit.updatecoloptions(var aoptions: coloptionsty);
begin
 coloptionstoeditoptions(aoptions,foptionsedit);
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
 checkgrid;
 with tdatalist1(fgridintf.getcol.datalist) do begin
  tdatalist1(fgridintf.getcol.datalist).internalfill(count,value);
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
 if (fgridintf <> nil) and not (csloading in componentstate) then begin
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

{ ttogglegraphdataedit}

constructor ttogglegraphdataedit.create(aowner: tcomponent);
begin
 foptions:= defaultbuttonoptions;
 inherited;
end;

procedure ttogglegraphdataedit.dokeyup(var info: keyeventinfoty);
begin
 with info do begin
  if not (oe_readonly in getoptionsedit) and (key = key_space) and
        (shiftstate = []) and (bo_executeonkey in foptions) then begin
   include(eventstate,es_processed);
   togglevalue;
  end;
 end;
 inherited;
end;

procedure ttogglegraphdataedit.doshortcut(var info: keyeventinfoty; const sender: twidget);
begin
 if not (oe_readonly in getoptionsedit) and (bo_executeonshortcut in foptions)
               and checkfocusshortcut(info) then begin
  include(info.eventstate,es_processed);
  togglevalue;
  if (bo_focusonshortcut in foptions) and canfocus then begin
   setfocus;
  end;
 end;
 if not (es_processed in info .eventstate) then begin
  inherited;
 end;
end;

procedure ttogglegraphdataedit.mouseevent(var info: mouseeventinfoty);
begin
 if not (oe_readonly in getoptionsedit) and not (csdesigning in componentstate) and
         iswidgetclick(info,fcheckcaption) and (bo_executeonclick in foptions) then begin
//  include(info.eventstate,es_processed); 
         //twidgetgrid needs childmouseevent
  togglevalue;
 end;
 inherited;
end;

{ tcustombooleanedit }

procedure tcustombooleanedit.internalcheckvalue(var avalue; var accept: boolean);
begin
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,boolean(avalue),accept);
 end;
 if accept then begin
  value:= boolean(avalue);
 end;
end;

procedure tcustombooleanedit.togglevalue;
var
 bo1: boolean;
begin
 bo1:= not fvalue;
 fedited:= true;
 docheckvalue(bo1);
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

function tcustombooleanedit.getdatatyp: datatypty;
begin
 result:= dl_integer;
end;

function tcustombooleanedit.getglyph: stockglyphty;
begin
 result:= stg_checked;
end;

procedure tcustombooleanedit.paintglyph(const canvas: tcanvas; const avalue;
                               const arect: rectty);
var
 bo1: boolean;
begin
 if @avalue = nil then begin
  bo1:= fvalue;
 end
 else begin
  bo1:= boolean(avalue);
 end;
 if bo1 then begin
   stockobjects.paintglyph(canvas,getglyph,arect,not isenabled,fcolorglyph);
 end;
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

procedure tcustombooleanedit.setnullvalue;
begin
 value:= false;
end;

procedure tcustombooleanedit.gridtovalue(const arow: integer);
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

procedure tcustombooleanedit.valuetogrid(const arow: integer);
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

function tcustombooleanedit.checkvalue: boolean;
begin
 result:= docheckvalue(fvalue);
end;

procedure tcustombooleanedit.togglegridvalue(const index: integer);
begin
 gridvalue[index]:= not gridvalue[index];
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

{ tcustombooleaneditradio }

function tcustombooleaneditradio.getglyph: stockglyphty;
begin
 result:= stg_checkedradio;
end;

procedure tcustombooleaneditradio.setvalue(const avalue: boolean);
var
 widget: twidget;
 int1: integer;
begin
 if avalue and (fparentwidget <> nil) then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget:= fparentwidget.widgets[int1];
   if (widget is tcustombooleaneditradio) and (widget <> self) and
        (tcustombooleaneditradio(widget).fgroup = fgroup) then begin
    tcustombooleaneditradio(widget).value:= false;
   end;
  end;
 end;
 inherited;
end;

procedure tcustombooleaneditradio.setgridvalue(const aindex: integer; const aValue: longbool);
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

function tcustombooleaneditradio.internalcheckeditem(
               out single: boolean): tcustombooleaneditradio; //nil if none
var
 widget: twidget;
 int1,int2: integer;
begin
 result:= nil;
 int2:= 0;
 if fparentwidget <> nil then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget:= fparentwidget.widgets[int1];
   if (widget is tcustombooleaneditradio) and
        (tcustombooleaneditradio(widget).fgroup = fgroup) and
         tcustombooleaneditradio(widget).value then begin
    inc(int2);
    if result <> nil then begin
     break;
    end;
    result:= tcustombooleaneditradio(widget);
   end;
  end;
 end
 else begin
  if fvalue then begin
   result:= self;
  end;
 end;
 single:= int2 <= 1;
end;

function tcustombooleaneditradio.checkeditem: tcustombooleaneditradio; 
                            //nil if none
var
 bo1: boolean;
begin
 result:= internalcheckeditem(bo1);
end;

procedure tcustombooleaneditradio.togglevalue;
var
 bo1: boolean;
begin
 internalcheckeditem(bo1);
 if not fvalue or not bo1 then begin
  bo1:= not fvalue;
  docheckvalue(bo1);
 end;
end;

procedure tcustombooleaneditradio.togglegridvalue(const index: integer);
begin
 if not getgridvalue(index) then begin
  setgridvalue(index,true);
 end;
end;

function tcustombooleaneditradio.getcheckedtag: integer;
var
 item: tcustombooleaneditradio;
begin
 item:= checkeditem;
 if item <> nil then begin
  result:= item.Tag;
 end
 else begin
  result:= -1;
 end;
end;

procedure tcustombooleaneditradio.setcheckedtag(const avalue: integer);
var
 widget: twidget;
 item: tcustombooleaneditradio;
 int1: integer;
begin
 if fparentwidget <> nil then begin
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget:= fparentwidget.widgets[int1];
   if (widget is tcustombooleaneditradio) and
        (tcustombooleaneditradio(widget).fgroup = fgroup) and
         (widget.tag = avalue) then begin
    tcustombooleaneditradio(widget).value:= true;
    exit;
   end;
  end;
  item:= checkeditem;
  if item <> nil then begin
   item.value:= false;
  end;
 end;
end;

{ tcustomintegergraphdataedit }

procedure tcustomintegergraphdataedit.internalcheckvalue(var avalue;
  var accept: boolean);
begin
 if canevent(tmethod(fonsetvalue)) then begin
  fonsetvalue(self,integer(avalue),accept);
 end;
 if accept then begin
  value:= integer(avalue);
 end;
end;

procedure tcustomintegergraphdataedit.setvalue(const Value: integer);
begin
 fvalue := Value;
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

procedure tcustomintegergraphdataedit.gridtovalue(const arow: integer);
begin
 fgridintf.getdata(arow,fvalue);
 inherited;
end;

procedure tcustomintegergraphdataedit.valuetogrid(const arow: integer);
begin
 fgridintf.setdata(arow,fvalue);
end;

function tcustomintegergraphdataedit.checkvalue: boolean;
begin
 result:= docheckvalue(fvalue);
end;

procedure tcustomintegergraphdataedit.doinc(var avalue: integer);
begin
 inc(avalue);
 if avalue > fmax then begin
  avalue:= fmin;
 end;
end;

procedure tcustomintegergraphdataedit.togglevalue;
begin
 doinc(fvalue);
 checkvalue;
end;

procedure tcustomintegergraphdataedit.togglegridvalue(const index: integer);
var
 int1: integer;
begin
 int1:= gridvalue[index];
 doinc(int1);
 gridvalue[index]:= int1;
end;

procedure tcustomintegergraphdataedit.fillcol(const avalue: integer);
begin
 checkgrid;
 fdatalist.fill(fdatalist.count,avalue);
end;

function tcustomintegergraphdataedit.createdatalist(
  const sender: twidgetcol): tdatalist;
begin
 fdatalist:= tgridintegerdatalist.create(sender);
 result:= fdatalist;
end;

function tcustomintegergraphdataedit.getdatatyp: datatypty;
begin
 result:= dl_integer;
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
 result:= tintegerdatalist(fgridintf.getcol.datalist).asarray;
end;

procedure tcustomintegergraphdataedit.setgridvalues(const Value: integerarty);
begin
 tintegerdatalist(fgridintf.getcol.datalist).asarray:= value;
end;

{ tvaluefacearrayprop }

constructor tvaluefacearrayprop.create(const aowner: tcustomdatabutton);
begin
 fowner:= aowner;
 inherited create(nil);
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

{ tcustomdatabutton }

constructor tcustomdatabutton.create(aowner: tcomponent);
begin
 foptions:= defaultbuttonoptions;
 inherited;
 fimagenums:= tintegerarrayprop.create;
 fimagenr:= -1;
 fvalue:= -1;
 fvaluedefault:= -1;
 fmin:= -1;
 fmax:= 0;
 fvaluefaces:= tvaluefacearrayprop.create(self);
 optionswidget:= defaultoptionswidget - [ow_mousefocus];
 finfo.dim:= innerclientrect;
 finfo.color:= cl_transparent;
 finfo.colorglyph:= cl_black;
 finfo.state:= finfo.state + [ss_showfocusrect,ss_showdefaultrect];
 include(fwidgetstate1,ws1_nodesignframe);
 size:= makesize(defaultbuttonwidth,defaultbuttonheight);
end;

destructor tcustomdatabutton.destroy;
begin
 fvaluefaces.free;
 fimagenums.free;
 inherited;
end;

procedure tcustomdatabutton.synctofontheight;
begin
 inherited;
 bounds_cy:= font.glyphheight + innerclientframewidth.cy + 6;
end;

procedure tcustomdatabutton.initnewcomponent(const ascale: real);
begin
 //dummy
end;

procedure tcustomdatabutton.clientrectchanged;
begin
 inherited;
 finfo.dim:= innerclientrect;
end;

procedure tcustomdatabutton.doexecute;
begin
 if canevent(tmethod(fonexecute)) then begin
  fonexecute(self);
 end;
end;

procedure tcustomdatabutton.mouseevent(var info: mouseeventinfoty);
begin
 inherited;
 if not (csdesigning in componentstate) {and 
        not (es_processed in info.eventstate)} then begin
  subpoint1(info.pos,paintpos);
  try
   updatemouseshapestate(finfo,info,self,nil,bo_executeonclick in foptions);
  finally
   addpoint1(info.pos,paintpos);
  end;
 end;
end;

procedure tcustomdatabutton.dokeydown(var info: keyeventinfoty);
begin
 inherited;
 if (info.shiftstate = []) and (bo_executeonkey in foptions) then begin
  if (info.key = key_space) then begin
   include(finfo.state,ss_clicked);
   invalidaterect(finfo.dim);
  end
  else begin
   if info.key = key_return then begin
    include(info.eventstate,es_processed);
    togglevalue;
   end;
  end;
 end;
end;

procedure tcustomdatabutton.dokeyup(var info: keyeventinfoty);
begin
 if (info.key = key_space) and (ss_clicked in finfo.state) then begin
  exclude(finfo.state,ss_clicked);
  invalidaterect(finfo.dim);
 end;
 inherited;
end;

procedure tcustomdatabutton.statechanged;
begin
 inherited;
 updatewidgetshapestate(finfo,self);
end;

procedure tcustomdatabutton.setcolorglyph(const avalue: colorty);
begin
 if finfo.colorglyph <> avalue then begin
  finfo.colorglyph := avalue;
  formatchanged;
 end;
end;

function tcustomdatabutton.actualimagenr(const avalue: integer): integer;
begin
 if (avalue >= 0) and (avalue < fimagenums.count) then begin
  result:= fimagenums[avalue];
 end
 else begin
  result:= fimagenr;
 end;
 inc(result,fimageoffset);
end;

procedure tcustomdatabutton.paintglyph(const canvas: tcanvas; const avalue;
               const arect: rectty);
               
 function actualface(const aindex: integer): tface;
 begin
  if (aindex >= 0) and (aindex < fvaluefaces.count) then begin
   result:= fvaluefaces[aindex];
  end
  else begin
   result:= nil;
  end;
 end;
 
var
 statebefore: shapestatesty;
 dimbefore: rectty;
begin
 finfo.colorglyph:= fcolorglyph;
 if (@avalue <> nil) then begin
  finfo.face:= actualface(integer(avalue));
  statebefore:= finfo.state;
  dimbefore:= finfo.dim;
  finfo.dim:= arect;
  finfo.state:= finfo.state - [ss_focused,ss_clicked,ss_mouse];
  if pcellinfoty(canvas.drawinfopo)^.ismousecell then begin
   include(finfo.state,ss_mouse);
  end;
  finfo.imagenr:= actualimagenr(integer(avalue));
  drawbutton(canvas,finfo);
  finfo.state:= statebefore;
  finfo.dim:= dimbefore;
 end
 else begin
  finfo.face:= actualface(fvalue);
  finfo.imagenr:= actualimagenr(fvalue);
  drawbutton(canvas,finfo);
 end;
end;

procedure tcustomdatabutton.internalcreateframe;
begin
 tcaptionframe.create(iframe(self));
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

procedure tcustomdatabutton.setcaption(const avalue: captionty);
begin
 fcaption:= avalue;
 captiontorichstring(fcaption,finfo.caption);
 formatchanged;
end;

procedure tcustomdatabutton.setcaptionpos(const avalue: captionposty);
begin
 if avalue <> finfo.captionpos then begin
  finfo.captionpos:= avalue;
  formatchanged;
 end;
end;

procedure tcustomdatabutton.setimagelist(const avalue: timagelist);
begin
 setlinkedvar(avalue,tmsecomponent(finfo.imagelist));
 formatchanged;
end;

procedure tcustomdatabutton.setimagenr(const avalue: integer);
begin
 if avalue <> fimagenr then begin
  fimagenr:= avalue;
  formatchanged;
 end;
end;

procedure tcustomdatabutton.setnullvalue;
begin
 value:= -1;
end;

procedure tcustomdatabutton.setgridintf(const intf: iwidgetgrid);
begin
 inherited;
 exclude(finfo.state,ss_showdefaultrect);
end;

function tcustomdatabutton.checkfocusshortcut(var info: keyeventinfoty): boolean;
begin
 result:= inherited checkfocusshortcut(info) or 
         mserichstring.checkshortcut(info,finfo.caption,true);
end;

procedure tcustomdatabutton.togglevalue;
begin
 inherited;
// if window.candefocus and isenabled then begin
 doexecute;
// end;
end;

procedure tcustomdatabutton.setimageoffset(const avalue: integer);
begin
 if fimageoffset <> avalue then begin
  fimageoffset := aValue;
  formatchanged;
 end;
end;

procedure tcustomdatabutton.setimagenums(const avalue: tintegerarrayprop);
begin
 fimagenums.assign(avalue);
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

procedure tcustomdataicon.paintglyph(const canvas: tcanvas; const avalue;
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
   if (int1 <> -1) and (cardinal(int1) <> $80000000) then begin
    po1:= pintegeraty(tarrayprop1(fimagenums).getdatapo^);
    for int2:= 0 to fimagenums.count-1 do begin
     if int1 and bits[int2] <> 0 then begin
      fimagelist.paint(canvas,po1^[int2],arect,[al_ycentered,al_xcentered]);
     end;
    end;
   end;
  end;
 end;
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

function tpointeredit.getdatatyp: datatypty;
begin
 result:= dl_none;
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
{
procedure tpointeredit.dopaint(const canvas: tcanvas);
begin
 //dummy
end;
}
procedure tpointeredit.initnewcomponent(const ascale: real);
begin
 //do nothing
end;

procedure tpointeredit.paintglyph(const canvas: tcanvas; const avalue;
               const arect: rectty);
var
 po1: pointer;
 int1: integer;
begin
 if canevent(tmethod(fonpaintglyph)) then begin
  if @avalue = nil then begin
   po1:= fvalue;
   int1:= row;
  end
  else begin
   po1:= pointer(avalue);
   int1:= pcellinfoty(canvas.drawinfopo)^.cell.row;
  end;
  fonpaintglyph(self,canvas,po1,int1);
 end;
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
 inherited create(iframe(aowner));
end;

{ tcustomprogressbar }

constructor tcustomprogressbar.create(aowner: tcomponent);
begin
 fbar_face:= tbarface.create(iface(self));
 fbar_frame:= tbarframe.create(self);
 fformat:= '0%';
 fvaluescale:= 0.01;
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
 if isemptyreal(avalue) then begin
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

procedure tcustomprogressbar.paintglyph(const canvas: tcanvas; const avalue;
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
 if not isemptyreal(rea1) then begin
  canvas.save;
  fbar_frame.paint(canvas,po2^); //moves origin to paintrect and sets cliprect
  canvas.intersectcliprect(po3^);
  fbar_face.paint(canvas,po1^);
  canvas.restore;
  if fformat <> '' then begin
   if fvaluescale <> 0 then begin
    rea1:= rea1/fvaluescale;
   end;
   drawtext(canvas,realtytostr(rea1,fformat),arect,ftextflags,ffont);
  end;
 end;
end;

procedure tcustomprogressbar.internalcreateframe;
begin
 tdispframe.create(self);
end;

procedure tcustomprogressbar.setvaluescale(const avalue: real);
begin
 fvaluescale:= avalue;
 formatchanged;
end;

procedure tcustomprogressbar.setformat(const avalue: string);
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

end.
