{ MSEgui Copyright (c) 1999-2018 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

unit msedbedit;
{$ifdef FPC}
 {$mode objfpc}{$h+}{$interfaces corba}
{$endif}
//{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
//{$endif}

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
 mdb,classes,mclasses,mseguiglob,mseclasses,msegui,msetoolbar,
 mseeditglob,
 mseglob,msewidgetgrid,msearrayutils,msedatalist,mseinterfaces,
 msetypes,msegrids,msegraphics,mseevent,msekeyboard,mseassistiveclient,
 msegraphedits,msestrings,msegraphutils,mselist,msedropdownlist,
 msescrollbar,msedataedits,msewidgets,msearrayprops,msedb,mselookupbuffer,
 msedialog,mseinplaceedit,msemenus,mseedit,msestat,msegridsglob,typinfo
 {$ifdef mse_with_ifi},mseifiglob,mseificompglob,mseificomp{$endif};

type
                          //0       1         2         3          4
 dbnavigbuttonty = (dbnb_first,dbnb_prior,dbnb_next,dbnb_last,dbnb_insert,
 //             5             6            7
           dbnb_delete,dbnb_copyrecord,dbnb_edit,
 //             8          9          10
           dbnb_post,dbnb_cancel,dbnb_refresh,
 //            11           12             13              14   
           dbnb_filter,dbnb_filtermin,dbnb_filtermax,dbnb_filterclear,
 //          15             16
           dbnb_filteronoff,dbnb_find,
 //            17           18
           dbnb_autoedit,dbnb_dialog);

 dbnavigbuttonsty = set of dbnavigbuttonty;

const
 defaultdbscrollbaroptions =
    (defaultthumbtrackscrollbaroptions - [sbo_showauto])+
             [sbo_show,sbo_thumbtrack];

 defaultvisibledbnavigbuttons =
          [dbnb_first,dbnb_prior,dbnb_next,dbnb_last,dbnb_insert,
           dbnb_delete,dbnb_edit,dbnb_post,dbnb_cancel,dbnb_refresh];
 filterdbnavigbuttons = [dbnb_filter,dbnb_filtermin,dbnb_filtermax,
                         dbnb_filterclear,dbnb_find,dbnb_filteronoff];
 defaultdbnavigatorheight = 24;
 defaultdbnavigatorwidth = (ord(dbnb_refresh))*defaultdbnavigatorheight;

 defaultindicatorcoloptions = [fco_mousefocus];

 maxautodisplaywidth = 20;

type
 dbnavigatoroptionty = (dno_confirmdelete,dno_confirmcopy,
                        dno_append,dno_nomultiinsert,dno_shortcuthint,
                        dno_norefreshrecno,
                        dno_dialogifinactive,dno_nodialogifempty,
                        dno_nodialogifnoeditmode,dno_nodialogifreadonly,
                        dno_nonavig, //disable navigation buttons
                        dno_noinsert,dno_nodelete,dno_noedit, //disable buttons
                        dno_customdialogupdate,
                        dno_postbeforedialog,dno_postoncanclose,
                        dno_candefocuswindow);
 dbnavigatoroptionsty = set of dbnavigatoroptionty;
 optioneditdbty = (oed_autoedit,oed_noautoedit,oed_readonly,oed_noreadonly,
                   oed_autopost,
                   oed_nullcheckifunmodified,
                   oed_syncedittonavigator,oed_focusoninsert,
                   oed_nofilteredit,oed_nofilterminedit,
                   oed_nofiltermaxedit,oed_nofindedit,
                   oed_nonullset, //use TField.DefaultExpression for textedit
                   oed_nullset,  //don't use TField.DefaultExpression for
                                  //empty edit value
                   oed_limitcharlen);
 optionseditdbty = set of optioneditdbty;

 griddatalinkoptionty = (gdo_propscrollbar,gdo_thumbtrack,
           gdo_checkbrowsemodeonexit,gdo_selectautopost);
 griddatalinkoptionsty = set of griddatalinkoptionty;

const
 defaultgriddatalinkoptions = [gdo_propscrollbar,gdo_thumbtrack,
                                                    gdo_selectautopost];
 defaulteditwidgetdatalinkoptions = [{oed_syncedittonavigator}];
 defaultdbnavigatoroptions = [dno_confirmdelete,dno_confirmcopy,{dno_append,}
                                                             dno_shortcuthint];
 designdbnavigbuttons = [dbnb_first,dbnb_prior,dbnb_next,dbnb_last];
 editnavigbuttons = [dbnb_insert,dbnb_delete,dbnb_edit];

 defaultdbdropdownoptions = [deo_selectonly,deo_autodropdown,deo_keydropdown];
 defaultdropdowndatalinkoptions = [gdo_propscrollbar,gdo_thumbtrack];

 defaulteddropdownoptions = [deo_selectonly,deo_autodropdown,deo_keydropdown];

type
 updaterowdataeventty = procedure(const sender: tcustomgrid;
                        const arow: integer; const adataset: tdataset)of object;

 optiondbty = (odb_copyitems,odb_opendataset,odb_closedataset,odb_directdata);
 optionsdbty = set of optiondbty;

 idbnaviglink = interface(inullinterface)
  procedure setactivebuttons(const abuttons: dbnavigbuttonsty;
               const afiltered: boolean);
  procedure setcheckedbuttons(const abuttons: dbnavigbuttonsty;
                                                 const achecked: boolean);
  function getwidget: twidget;
  function getnavigoptions: dbnavigatoroptionsty;
  procedure dodialogexecute;
  procedure updatereadonly(const force: boolean = false);
 end;

 navigdatalinkstatety = (nds_prior,nds_next,nds_datasetscrolled);
 navigdatalinkstatesty = set of navigdatalinkstatety;
 
 tnavigdatalink = class(tmsedatalink)
  private
  protected
   fintf: idbnaviglink;
   fstate: navigdatalinkstatesty;
   procedure updatebuttonstate;
   procedure activechanged; override;
   procedure datasetchanged; override;
   procedure editingchanged; override;
   procedure recordchanged(Field: TField); override;
   procedure disabledstatechange; override;
   procedure datasetscrolled(distance: integer) override;
   function canassistive(out aintf: iassistiveclient): boolean;
  public
   constructor create(const intf: idbnaviglink);
   procedure execbutton(const abutton: dbnavigbuttonty);
 end;

 tdbnavigbutton = class(tcustomstockglyphtoolbutton)
  private
   procedure readtag(reader: treader);
  protected
   procedure defineproperties(filer: tfiler); override;
  published
   property imagelist;
   property imagenr;
   property imagenrdisabled;
   property colorglyph;
   property color;
   property imagecheckedoffset;
   property hint;
   property action;
   property state;
   property shortcut;
   property shortcut1;
//   property tag;
   property options;
   property group;
//   property onexecute;
//   property onbeforeexecute;
 end;

 tdbnavigbuttons = class(tstockglyphtoolbuttons)
  protected
   class function getbuttonclass: toolbuttonclassty; override;
 end;
  
 tdbnavigator = class(tcustomtoolbar,idbnaviglink)
  private
   fdatalink: tnavigdatalink;
   fvisiblebuttons: dbnavigbuttonsty;
   fshortcuts: array[dbnavigbuttonty] of shortcutty;
   foptions: dbnavigatoroptionsty;
   fondialogexecute: notifyeventty;
   fonreadonlychange: booleanchangedeventty;
   fcanautoeditbefore: boolean;
   function getdatasource: tdatasource;
   procedure setdatasource(const Value: tdatasource);
   procedure setvisiblebuttons(const avalue: dbnavigbuttonsty);
   function getcolorglyph: colorty;
   procedure setcolorglyph(const avalue: colorty);
   procedure setoptions(const avalue: dbnavigatoroptionsty);
   function getbuttonface: tface;
   procedure setbuttonface(const avalue: tface);
   function gettoolbutton: tdbnavigbutton;
   procedure settoolbutton(const avalue: tdbnavigbutton);
   function getautoedit: boolean;
   procedure setautoedit(const avalue: boolean);
   function getbuttonwidth: integer;
   procedure setbuttonwidth(const avalue: integer);
   function getbuttonheight: integer;
   procedure setbuttonheight(const avalue: integer);
//   function getnonavig: boolean;
//   procedure setnonavig(const avalue: boolean);
  protected
   procedure inithints;
   procedure doexecute(const sender: tobject);
   procedure loaded; override;
   procedure internalshortcut(var info: keyeventinfoty; const sender: twidget);
   procedure doshortcut(var info: keyeventinfoty;
                                              const sender: twidget); override;
   procedure doasyncevent(var atag: integer); override;
   procedure dostatread(const reader: tstatreader); override;
   procedure dostatwrite(const writer: tstatwriter); override;
   
    //idbnaviglink
   procedure setactivebuttons(const abuttons: dbnavigbuttonsty;
                             const afiltered: boolean);
   procedure setcheckedbuttons(const abuttons: dbnavigbuttonsty;
                                                  const achecked: boolean);
   function getnavigoptions: dbnavigatoroptionsty;
   procedure dodialogexecute;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override; 
   function canclose(const newfocus: twidget = nil): boolean; override;
   procedure edit();
   function canautoedit(): boolean;
   procedure updatereadonly(const force: boolean = false);
                                        //call onreadonlychange
//   property nonavig: boolean read getnonavig write setnonavig;
  published
   property statfile;
   property datasource: tdatasource read getdatasource write setdatasource;
   property visiblebuttons: dbnavigbuttonsty read fvisiblebuttons 
                 write setvisiblebuttons default defaultvisibledbnavigbuttons;
   property colorglyph: colorty read getcolorglyph write setcolorglyph
                                                             default cl_default;
   property buttonface: tface read getbuttonface write setbuttonface;
   property buttonwidth: integer read getbuttonwidth write setbuttonwidth
                                                                     default 0;
   property buttonheight: integer read getbuttonheight write setbuttonheight
                                                                     default 0;
   property bounds_cx default defaultdbnavigatorwidth;
   property bounds_cy default defaultdbnavigatorheight;
   property shortcut_first: shortcutty read fshortcuts[dbnb_first] 
                  write fshortcuts[dbnb_first] default key_modctrl + ord(key_pageup);
   property shortcut_prior: shortcutty read fshortcuts[dbnb_prior] 
                  write fshortcuts[dbnb_prior] default ord(key_pageup);
   property shortcut_next: shortcutty read fshortcuts[dbnb_next] 
                  write fshortcuts[dbnb_next] default ord(key_pagedown);
   property shortcut_last: shortcutty read fshortcuts[dbnb_last] 
                  write fshortcuts[dbnb_last] default key_modctrl + ord(key_pagedown);
   property shortcut_insert: shortcutty read fshortcuts[dbnb_insert] 
                  write fshortcuts[dbnb_insert] default ord(key_none);
   property shortcut_delete: shortcutty read fshortcuts[dbnb_delete] 
                  write fshortcuts[dbnb_delete] default ord(key_none);
   property shortcut_copyrecord: shortcutty read fshortcuts[dbnb_copyrecord] 
                  write fshortcuts[dbnb_copyrecord] default ord(key_none);
   property shortcut_edit: shortcutty read fshortcuts[dbnb_edit]
                  write fshortcuts[dbnb_edit] default ord(key_f2);
   property shortcut_post: shortcutty read fshortcuts[dbnb_post] 
                  write fshortcuts[dbnb_post] default ord(key_f2);
   property shortcut_cancel: shortcutty read fshortcuts[dbnb_cancel] 
                  write fshortcuts[dbnb_cancel] default ord(key_none);
   property shortcut_refresh: shortcutty read fshortcuts[dbnb_refresh]
                  write fshortcuts[dbnb_refresh] default ord(key_none);
   property shortcut_filter: shortcutty read fshortcuts[dbnb_filter]
                  write fshortcuts[dbnb_filter] default ord(key_none);
   property shortcut_filtermin: shortcutty read fshortcuts[dbnb_filtermax]
                  write fshortcuts[dbnb_filtermin] default ord(key_none);
   property shortcut_filtermax: shortcutty read fshortcuts[dbnb_filtermax]
                  write fshortcuts[dbnb_filtermax] default ord(key_none);
   property shortcut_filteronoff: shortcutty read fshortcuts[dbnb_filteronoff]
                  write fshortcuts[dbnb_filteronoff] default ord(key_none);
   property shortcut_find: shortcutty read fshortcuts[dbnb_find]
                  write fshortcuts[dbnb_find] default ord(key_none);
   property shortcut_autoedit: shortcutty read fshortcuts[dbnb_autoedit]
                  write fshortcuts[dbnb_autoedit] default ord(key_none);
//   property shortcut_dialog: shortcutty read fshortcuts[dbnb_dialog]
//                  write fshortcuts[dbnb_dialog] default ord(key_f3);
              //use dialogbutton property!
   property options: dbnavigatoroptionsty read foptions write setoptions 
                  default defaultdbnavigatoroptions;
   property autoedit: boolean read getautoedit write setautoedit default false;
//   property dialoghint: msestring read getdialoghint write setdialoghint;
//   
   property dialogbutton: tdbnavigbutton read gettoolbutton write settoolbutton;
   property ondialogexecute: notifyeventty read fondialogexecute 
                           write fondialogexecute;
   property onreadonlychange: booleanchangedeventty read fonreadonlychange 
                                                      write fonreadonlychange;
 end;
 
 tcustomeditwidgetdatalink = class;
 
 idbeditfieldlink = interface(inullinterface)[miid_idbeditfieldlink]
  function getwidget: twidget;
  function getenabled: boolean;
  procedure setenabled(const avalue: boolean);
  function getgridintf: iwidgetgrid;
  function getgriddatasource: tdatasource;
  function getedited: boolean;
  function seteditfocus: boolean;
  procedure initeditfocus;
  function checkvalue(const quiet: boolean = false): boolean;
  procedure valuetofield;
  procedure fieldtovalue;
  procedure setnullvalue;
  function getoptionsedit: optionseditty;
  procedure updatereadonlystate;
  procedure getfieldtypes(var afieldtypes: fieldtypesty); //[] = all
  function geteditstate: dataeditstatesty;
  procedure seteditstate(const avalue: dataeditstatesty);
//  procedure setisdb;
  procedure setmaxlength(const avalue: integer);
  function getfieldlink: tcustomeditwidgetdatalink;
   //iificlient
  procedure setifiserverintf(const aintf: iifiserver);
 end;

 tgriddatalink = class;
 
// editwidgetdatalinkstatety = (ewds_editing,ewds_modified,ewds_filterediting,
//                              ewds_filtereditdisabled);
// editwidgetdatalinkstatesty = set of editwidgetdatalinkstatety;
 
 tcustomeditwidgetdatalink = class(tfielddatalink,idbeditinfo,iobjectlink)
  private
//   fstate: editwidgetdatalinkstatesty;
   frecordchange: integer;
   fbeginedit: integer;
   fmaxlength: integer;
   fposting: integer;
   fonbeginedit: notifyeventty;
   fonendedit: notifyeventty;
   fondataentered: notifyeventty;
   fnavigator: tdbnavigator;
   function canmodify: boolean;
   procedure setediting(avalue: boolean);
   function getasnullmsestring: msestring;
   procedure setasnullmsestring(const avalue: msestring);
   procedure readdatasource(reader: treader);
   procedure readdatafield(reader: treader);
   procedure readoptionsdb(reader: treader);
   function getownerwidget: twidget;
   procedure setnavigator(const avalue: tdbnavigator);
   procedure setoptions(const avalue: optionseditdbty);
  protected   
   fintf: idbeditfieldlink;
   foptions: optionseditdbty;
   fobjectlinker: tobjectlinker;
   function datasourcereadonly(): boolean override;
   function getobjectlinker: tobjectlinker;
   function getdatasource1: tdatasource;
   procedure dataevent(event: tdataevent; info: ptrint); override;
   procedure activechanged; override;
   procedure editingchanged; override;
   procedure focuscontrol(afield: tfieldref); override;
   procedure updatedata; override;
   procedure disabledstatechange; override;
   procedure fieldchanged; override;
   procedure bindingchanged;
   procedure objectevent(const sender: tobject; const event: objecteventty); virtual;
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
               ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const sender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
    //idbeditinfo
   function getdataset(const aindex: integer): tdataset;
   procedure getfieldtypes(out apropertynames: stringarty; 
                                     out afieldtypes: fieldtypesarty); virtual;
    //iifiserver
   procedure updateoptionsedit(var avalue: optionseditty); override;
   procedure valuechanged(const sender: iifidatalink); override;
  public
   constructor create(const intf: idbeditfieldlink);
   destructor destroy; override;
   procedure fixupproperties(filer: tfiler); //read moved properties
   procedure recordchanged(afield: tfield); override;
   procedure datasetscrolled(distance: integer) override;
   procedure nullcheckneeded(var avalue: boolean);
   procedure setwidgetdatasource(const avalue: tdatasource);
   procedure griddatasourcechanged;
   function edit: Boolean;
   procedure modified;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget);

//   procedure datachanged;
//   procedure updateoptionsedit(var aoptions: optionseditty);
   function cuttext(const atext: msestring; out maxlength: integer): boolean; 
             //true if text too long
   property options: optionseditdbty read foptions write setoptions 
                         default defaulteditwidgetdatalinkoptions;
   property asnullmsestring: msestring read getasnullmsestring 
                                              write setasnullmsestring;
                   //uses nulltext
   property navigator: tdbnavigator read fnavigator write setnavigator;
   property onbeginedit: notifyeventty read fonbeginedit write fonbeginedit;
   property onendedit: notifyeventty read fonendedit write fonendedit;
   property ondataentered: notifyeventty read fondataentered 
                                     write fondataentered;
   property owner: twidget read getownerwidget;
 end;

 teditwidgetdatalink = class(tcustomeditwidgetdatalink)
  private
  published
   property datasource: tdatasource read getdatasource1 
                                         write setwidgetdatasource;
   property navigator;
   property fieldname;
   property options;
   property onbeginedit;
   property onendedit;
   property ondataentered;
 end;

 tlookupeditdatalink = class(teditwidgetdatalink)
  private
   ffieldnametext: string;
   ffieldtext: tfield;
   procedure setfieldnametext(const avalue: string);
  protected
   fowner: tcustomdataedit;
   fdatatype: lookupdatatypety;
   procedure updatefields; override;
   function getsortfield: tfield; override;
   property fieldtext: tfield read ffieldtext;
   procedure getfieldtypes(out apropertynames: stringarty; 
                                     out afieldtypes: fieldtypesarty); override;
  public
   constructor create(const aowner: tcustomdataedit;
                      const adatatype: lookupdatatypety;
                      const intf: idbeditfieldlink);
   function msedisplaytext(const aformat: msestring = '';
                          const aedit: boolean = false): msestring; override;
  published
   property fieldnametext: string read ffieldnametext write setfieldnametext;
 end;
 
 tstringeditwidgetdatalink = class(teditwidgetdatalink)
  published
   property nullsymbol;
 end;

 tstringlookupeditdatalink = class(tlookupeditdatalink)
  published
   property nullsymbol;
 end;
  
 tdbstringedit = class(tcustomstringedit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: tstringeditwidgetdatalink;
   procedure setdatalink(const adatalink: tstringeditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
//   procedure editnotification(var info: editnotificationinfoty); override;
   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;

   function getrowdatapo(const arow: integer): pointer; override;
   function getnulltext: msestring; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tstringeditwidgetdatalink read fdatalink write setdatalink;
   property passwordchar;
   property maxlength;
   property onsetvalue;
 end;

 
{
 tdbdialogstringedit = class(tcustomdialogstringedit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: tstringeditwidgetdatalink;
   procedure setdatalink(const avalue: tstringeditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;

   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   function getoptionsedit: optionseditty; override;
   procedure dochange; override;

   function getrowdatapo(const info: cellinfoty): pointer; override;
   function getnulltext: msestring; override;

  //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
  //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tstringeditwidgetdatalink read fdatalink write setdatalink;
   property passwordchar;
   property maxlength;
   property onsetvalue;
   property onexecute;
 end;
}
 idbifidropdownlistdatalink = interface(iifidropdownlistdatalink)
 end;
 
 tcustomdbdropdownlistedit = class(tcustomdropdownlistedit,idbeditfieldlink,
                                      ireccontrol,idbifidropdownlistdatalink)
  private
   fdatalink: tstringeditwidgetdatalink;
   fdropdownifilink: tifidropdownlistlinkcomp;
   fdropdownifiserverintf: iifiserver;
   procedure setdatalink(const avalue: tstringeditwidgetdatalink);
   function getdropdownifilink: tifidropdownlistlinkcomp;
   procedure setdropdownifilink(const avalue: tifidropdownlistlinkcomp);
   procedure dropdownsetifiserverintf(const aintf: iifiserver);
   procedure idbifidropdownlistdatalink.setifiserverintf = 
                                           dropdownsetifiserverintf;
   procedure dropdownifisetvalue(var avalue; var accept: boolean);
   procedure idbifidropdownlistdatalink.ifisetvalue = dropdownifisetvalue;
  protected   
   procedure defineproperties(filer: tfiler); override;

   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   function getrowdatapo(const arow: integer): pointer; override;
   function getnulltext: msestring; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property datalink: tstringeditwidgetdatalink read fdatalink write setdatalink;
   property dropdownifilink: tifidropdownlistlinkcomp read getdropdownifilink 
                               write setdropdownifilink;  //for dropdownlist
 end;

 idbdropdownlist = interface(idropdownlist)
  procedure recordselected(const arecordnum: integer; const akey: keyty);
                     //-2 = empty row, -1 = none
 end;
 
 ilbdropdownlist = interface(idropdownlist)
  procedure recordselected(const arecordnum: integer; const akey: keyty);
                     //-2 = empty row, -1 = none
  function getlbkeydatakind: lbdatakindty;                     
 end;
 
 tdbdropdownlistedit = class(tcustomdbdropdownlistedit)
  published
   property datalink;
   property dropdown;
   property dropdownifilink;
   property onsetvalue;
   property onbeforedropdown;
   property onafterclosedropdown;
 end;
 
 tcustomdbdropdownlistcontroller = class;
// tdbdropdownlistcontroller = class;
 tdropdownlistcontrollerdb = class;
 tcustomlbdropdownlistcontroller = class;
 tdropdownlistcontrollerlb = class;
 
 tdbdropdownlisteditdb = class(tdbdropdownlistedit,idbdropdownlist)
  private
   function getdropdown: tdropdownlistcontrollerdb;
   procedure setdropdown(const avalue: tdropdownlistcontrollerdb);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure recordselected(const arecordnum: integer; const akey: keyty);
  published
   property dropdown: tdropdownlistcontrollerdb read getdropdown 
                                                        write setdropdown;
 end;
 
 tdbdropdownlisteditlb = class(tdbdropdownlistedit,ilbdropdownlist)
  private
   function getdropdown: tdropdownlistcontrollerlb;
   procedure setdropdown(const avalue: tdropdownlistcontrollerlb);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure recordselected(const arecordnum: integer; const akey: keyty);
  //ilbdropdownlist
   function getlbkeydatakind: lbdatakindty;
  published
   property dropdown: tdropdownlistcontrollerlb read getdropdown
                                                       write setdropdown;
 end;
 
 tdropdownlisteditdb = class(tdropdownlistedit,idbdropdownlist)
  private
   function getdropdown: tdropdownlistcontrollerdb;
   procedure setdropdown(const avalue: tdropdownlistcontrollerdb);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure recordselected(const arecordnum: integer; const akey: keyty);
  published
   property dropdown: tdropdownlistcontrollerdb read getdropdown write setdropdown;
 end;
 
 tdropdownlisteditlb = class(tdropdownlistedit,ilbdropdownlist)
  private
   function getdropdown: tdropdownlistcontrollerlb;
   procedure setdropdown(const avalue: tdropdownlistcontrollerlb);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure recordselected(const arecordnum: integer; const akey: keyty);
    //ilbdropdownlist
   function getlbkeydatakind: lbdatakindty;                     
  published
   property dropdown: tdropdownlistcontrollerlb read getdropdown
                                                       write setdropdown;
 end;
 
 tdbkeystringedit = class(tcustomkeystringedit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: tstringlookupeditdatalink;
   procedure setdatalink(const avalue: tstringlookupeditdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   function getrowdatapo(const arow: integer): pointer; override;
   function getnulltext: msestring; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tstringlookupeditdatalink read fdatalink
                                                          write setdatalink;
   property dropdown;
   property valuedefault;
   property onsetvalue;
   property onbeforedropdown;
   property onafterclosedropdown;
   property oninit;
 end;

 tdbmemoedit = class(tcustommemoedit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: tstringeditwidgetdatalink;
   procedure setdatalink(const avalue: tstringeditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;

   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   function getrowdatapo(const arow: integer): pointer; override;
   function getnulltext: msestring; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tstringeditwidgetdatalink read fdatalink write setdatalink;
   property onsetvalue;
   property frame;
 end;

 tdbintegeredit = class(tcustomintegeredit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   procedure setdatalink(const avalue: teditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;

   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   function internaldatatotext(const data): msestring; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
//   procedure setnullvalue; override;
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property isnull: boolean read fisnull;
  published
   property datalink: teditwidgetdatalink read fdatalink write setdatalink;
   property base;
   property bitcount;
   property valuemin;
   property valuemax;
   property onsetvalue;
 end;

 tdbbooleanedit = class(tcustombooleanedit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   procedure setdatalink(const avalue: teditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function checkvalue(const quiet: boolean = false): boolean; reintroduce;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   procedure setmaxlength(const avalue: integer);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;                          
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: teditwidgetdatalink read fdatalink write setdatalink;
   property onsetvalue;
   property bounds_cx  default defaultboxsize;
   property bounds_cy  default defaultboxsize;
   property group;
 end;

 tdbdataicon = class(tcustomdataicon,idbeditfieldlink,ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   procedure setdatalink(const avalue: teditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function checkvalue(const quiet: boolean = false): boolean; reintroduce;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
//   function getoptionsedit: optionseditty; override;
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   procedure setmaxlength(const avalue: integer);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: teditwidgetdatalink read fdatalink write setdatalink; 
   property onsetvalue;
   property onpaintglyph;
   property valuemin; 
   property valuemax;
   property imagelist;
   property imageoffset;
   property imagenums;
 end;

 tdbdatabutton = class(tcustomdatabutton,idbeditfieldlink,ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   procedure setdatalink(const avalue: teditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function checkvalue(const quiet: boolean = false): boolean; reintroduce;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   procedure setmaxlength(const avalue: integer);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: teditwidgetdatalink read fdatalink write setdatalink;
   property optionswidget;
   property optionsskin;
   property valuefaces;
   property valuecaptions;
   property valuefonts;
   property font;
   property action;
   property caption;
   property imagepos;
   property shortcut;
   property shortcut1;
   property textflags;
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
   property valuedefault;
   property valuemin; 
   property valuemax;
   property valuedisabled;
 end;

 tdbbooleaneditradio = class(tcustombooleaneditradio,idbeditfieldlink,ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   procedure setdatalink(const avalue: teditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function checkvalue(const quiet: boolean = false): boolean; reintroduce;
   function docheckvalue(var avalue; const quiet: boolean): boolean; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   procedure setmaxlength(const avalue: integer);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: teditwidgetdatalink read fdatalink write setdatalink;
   property onsetvalue;
   property bounds_cx  default defaultboxsize;
   property bounds_cy  default defaultboxsize;
   property group;
 end;

 tdbrealedit = class(tcustomrealedit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   procedure setdatalink(const avalue: teditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: teditwidgetdatalink read fdatalink write setdatalink;
   property valuemin {stored false};
   property valuemax {stored false};
   property formatedit;
   property formatdisp;
   property valuerange;
   property valuestart;
   property onsetvalue;
   property onsetintvalue;
 end;

 tdbrealspinedit = class(tcustomrealspinedit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   procedure setdatalink(const avalue: teditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: teditwidgetdatalink read fdatalink write setdatalink;
   property valuemin {stored false};
   property valuemax {stored false};
   property formatedit;
   property formatdisp;
   property valuerange;
   property valuestart;
   property onsetvalue;
   property onsetintvalue;
   property step;
 end;

 tdbslider = class(tcustomslider,idbeditfieldlink,ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   fvaluerange: real;
   fvaluestart: real;
   procedure setdatalink(const avalue: teditwidgetdatalink);
   procedure readvaluescale(reader: treader);
  protected   
   procedure defineproperties(filer: tfiler); override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   procedure setmaxlength(const avalue: integer);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function checkvalue(const quiet: boolean = false): boolean; reintroduce;
  published
   property valuerange: real read fvaluerange write fvaluerange;
   property valuestart: real read fvaluestart write fvaluestart;
   property datalink: teditwidgetdatalink read fdatalink write setdatalink;
   property scrollbar;
   property onsetvalue;
   property direction;
   property onpaintglyph;
 end;

 tdbprogressbar = class(tcustomprogressbar,idbeditfieldlink,ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   procedure setdatalink(const avalue: teditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   function getrowdatapo(const arow: integer): pointer; override;
   procedure griddatasourcechanged; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function checkvalue(const quiet: boolean = false): boolean; reintroduce;
   procedure setmaxlength(const avalue: integer);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: teditwidgetdatalink read fdatalink write setdatalink;
   property onpaintglyph;
 end;
 
 tdbdatetimeedit = class(tcustomdatetimeedit,idbeditfieldlink,ireccontrol)
  private
   fdatalink: teditwidgetdatalink;
   procedure setdatalink(const avalue: teditwidgetdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield;
   procedure fieldtovalue;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: teditwidgetdatalink read fdatalink write setdatalink;
   property valuemin {stored false};
   property valuemax {stored false};
   property formatedit;
   property formatdisp;
   property kind;
   property options;
   property onsetvalue;
 end;

 tcustomdbenumedit = class(tcustomenumedit,idbeditfieldlink,ireccontrol,
                                                 idbifidropdownlistdatalink)
  private
   fdatalink: tlookupeditdatalink;
   fdropdownifilink: tifienumlinkcomp;
   fdropdownifiserverintf: iifiserver;
   procedure setdatalink(const avalue: tlookupeditdatalink);
   function getdropdownifilink: tifienumlinkcomp;
   procedure setdropdownifilink(const avalue: tifienumlinkcomp);
   procedure dropdownsetifiserverintf(const aintf: iifiserver);
   procedure idbifidropdownlistdatalink.setifiserverintf = 
                                           dropdownsetifiserverintf;
   procedure dropdownifisetvalue(var avalue; var accept: boolean);
   procedure idbifidropdownlistdatalink.ifisetvalue = dropdownifisetvalue;
  protected   
   procedure defineproperties(filer: tfiler); override;
   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield; virtual;
   procedure fieldtovalue; virtual;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   property datalink: tlookupeditdatalink read fdatalink write setdatalink;
   property dropdownifilink: tifienumlinkcomp read getdropdownifilink 
                                 write setdropdownifilink;  //for dropdownlist
 end;
 
 tdbenumedit = class(tcustomdbenumedit)
  published
   property valueoffset; //before value
   property datalink;
   property dropdown;
   property dropdownifilink;
   property valuedefault;
   property valueempty;
   property base;
   property bitcount;
   property valuemin;
   property valuemax;
   property onsetvalue;
   property onbeforedropdown;
   property onafterclosedropdown;
   property oninit;
 end;

 tdbbooleantextedit = class(tcustomdbenumedit)
  private
   ftext_false: msestring;
   ftext_true: msestring;
   function getvalue: boolean;
   procedure setvalue(const avalue: boolean);
   procedure settext_false(const avalue: msestring);
   procedure settext_true(const avalue: msestring);
   procedure booltextchanged;
  protected
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield; override;
   procedure fieldtovalue; override;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
  public
   constructor create(aowner: tcomponent); override;
   property value: boolean read getvalue write setvalue;
  published
   property text_false: msestring read ftext_false write settext_false;
   property text_true: msestring read ftext_true write settext_true;
   property datalink;
   property valuedefault;
   property onsetvalue;
 end;

 tnolistdropdowncol = class(tdropdowncol)
 end;

 tnolistdropdowncols = class(tdropdowncols)
 end;

 tdbdropdowncol = class(tnolistdropdowncol,idbeditinfo)
  private
   fdatafield: string;
   procedure setdatafield(const avalue: string);
  protected
    //idbeditinfo
   function getdataset(const aindex: integer): tdataset;
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
  published
   property datafield: string read fdatafield write setdatafield;
 end;
 
 tdbdropdowncols = class(tnolistdropdowncols)
  private
   function getitems(const index: integer): tdbdropdowncol;
  protected
   function getcolclass: dropdowncolclassty; override;
  public
   property items[const index: integer]: tdbdropdowncol read getitems; default;
 end;

 tdropdownlistdatalink = class;

 dropdowndatalinkstatety = (ddlnks_lookupvalid);
 dropdowndatalinkstatesty = set of dropdowndatalinkstatety;
 
 tdropdowndatalink = class(tmsedatalink)
  private
   fowner: tcustomdbdropdownlistcontroller;
   fvaluefield: tfield;
   fvaluefieldname: string;
   ftextfield: tfield;
   procedure setvaluefield(value: tfield);
   procedure setvaluefieldname(const value: string);
   procedure settextfield(value: tfield);
   procedure updatefields;
   procedure updatelookupvalue;
   function getvalueasmsestring: msestring;
   function getvalueasinteger: integer;
   function getvalueaslargeint: int64;
   function gettextasmsestring: msestring;
  protected
   fdataintf: idbdata;
   fkeyindex: integer;
   ftextindex: integer;
   flookuptext: msestring;
   flastintegerkey: integer;
   flastint64key: int64;
   flaststringkey: msestring;
   fstate: dropdowndatalinkstatesty;
   procedure layoutchanged; override;
   procedure activechanged; override;
   procedure editingchanged; override;
  public
   constructor create(const aowner: tcustomdbdropdownlistcontroller);
   function getlookuptext(const key: integer): msestring; overload;
   function getlookuptext(const key: int64): msestring; overload;
   function getlookuptext(const key: msestring): msestring; overload;
   property valuefieldName: string read fvaluefieldname write setvaluefieldname;
   property valuefield: tfield read fvaluefield;
   property valueasmsestring: msestring read getvalueasmsestring;
   property valueasinteger: integer read getvalueasinteger;
   property valueaslargeint: int64 read getvalueaslargeint;
   property textfield: tfield read ftextfield;
   property textasmsestring: msestring read gettextasmsestring;
 end;

 tdbdropdownstringcol = class(tdropdownstringcol)
  private
   fdatalink: tfielddatalink;
  protected
   function getrowtext(const arow: integer): msestring; override;
  public
   constructor create(const agrid: tcustomgrid; 
                                  const aowner: tgridarrayprop); override;
   destructor destroy; override;
 end;

 igriddatalink = interface(inullinterface)[miid_iggriddatalink]
  function getdbindicatorcol: integer;
  procedure setnavigator(const avalue: tdbnavigator);
  function getdatalink(): tgriddatalink;
 end;

 gridrowinfoty = record
  row: integer;
 end;
  
 griddatalinkstatety = (gdls_hasrowstatefield,gdls_booleanmerged,
                        gdls_booleanselected); 
 griddatalinkstatesty = set of griddatalinkstatety; 

 tgriddatalink = class(tfieldsdatalink,ievent,idbeditinfo,iobjectlink)
  private
   fintf: igriddatalink;
   fgrid: tcustomgrid;
   factiverecordbefore: integer;
   ffirstrecordshift: integer;
   fzebraoffset: integer;
   ffirstrecordbefore: integer;
   fdatasetstatebefore: tdatasetstate;
   fdummystringbuffer: ansistring;
   fansistringbuffer: ansistring;
   fstringbuffer: msestring;
   fintegerbuffer: integer;
   fint64buffer: int64;
   frealtybuffer: realty;
   fgridinvalidated: boolean;
   fstate: griddatalinkstatesty;
   foptions: griddatalinkoptionsty;
   fonupdaterowdata: updaterowdataeventty;
   fnullchecking: integer;
   fdatasetchangedlock: integer;
   fobjectlinker: tobjectlinker;
//   fcolordatalink: tfielddatalink;
//   ffontdatalink: tfielddatalink;
   frowexited: integer;
   feditingbefore: boolean;
   fautoinserting: boolean;
   finserting: boolean;
   finsertingbefore: boolean;
   fonbeginedit: notifyeventty;
   fonendedit: notifyeventty;
   ffield_state: tfield;
   ffieldname_state: string;
   ffield_color: tfield;
   ffieldname_color: string;
   ffield_font: tfield;
   ffieldname_font: string;
   ffield_readonly: tfield;
   ffieldname_readonly: string;
   ffield_merged: tfield;
   ffieldname_merged: string;
   ffield_selected: tfield;
   ffieldname_selected: string;
   fnavigator: tdbnavigator;
   fdescend: boolean;
   fsortdatalink: tfielddatalink;
   fmovebydistance: int32;
   procedure checkzebraoffset;
   procedure checkscroll;
   procedure checkscrollbar; virtual;
   procedure doupdaterowdata(const row: integer);
   procedure beginnullchecking;
   procedure endnullchecking;
   procedure setfieldname_state(const avalue: string);
   procedure forcecalcrange;
   function getobjectlinker: tobjectlinker;
   function updateoptionsgrid(const avalue: optionsgridty): optionsgridty;
   function updatesortfield(const avalue: tfielddatalink;
                                const adescend: boolean): boolean;
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
               ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil); virtual;
   procedure objevent(const sender: iobjectlink; const event: objecteventty); virtual;
   function getinstance: tobject;
    //ievent
   procedure receiveevent(const event: tobjectevent);
    //idbeditinfo
   function getdataset(const aindex: integer): tdataset;
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
   function getdatasource1: tdatasource;
   procedure settadasource1(const avalue: tdatasource);
   procedure setfield_state(const avalue: tfield);
   procedure setfield_color(const avalue: tfield);
   procedure setfield_font(const avalue: tfield);
   procedure setfield_readonly(const avalue: tfield);
   procedure setfield_merged(const avalue: tfield);
   procedure setfield_selected(const avalue: tfield);
   procedure readdatafield(reader: treader);
   procedure setfieldname_merged(const avalue: string);
   procedure setfieldname_selected(const avalue: string);
   procedure setfieldname_color(const avalue: string);
   procedure setfieldname_font(const avalue: string);
   procedure setfieldname_readonly(const avalue: string);
   procedure setnavigator(const avalue: tdbnavigator);
  protected
   function canautoinsert: boolean;
   procedure checkdelayedautoinsert;
   function checkvalue: boolean;
   procedure updatelayout;
   procedure updaterowcount;
   function begingridrow(const arow: integer;
                                   out ainfo: gridrowinfoty): boolean;
                 //false if row invalid
   procedure endgridrow(const ainfo: gridrowinfoty);
   function getfirstrecord: integer; virtual;
   procedure checkactiverecord; virtual;
   function  getrecordcount: integer; override;
   procedure datasetscrolled(distance: integer); override;
   procedure fieldchanged; override;
   procedure activechanged; override;
   procedure editingchanged; override;
   procedure recordchanged(afield: tfield); override;
   procedure datasetchanged; override;
   procedure updatedata; override;
   procedure updatefields; override;
   procedure focuscell(var cell: gridcoordty); virtual;
   procedure cellevent(var info: celleventinfoty); virtual;
   procedure invalidateindicator;
   function scrollevent(sender: tcustomscrollbar;
                             event: scrolleventty): boolean; virtual;
             //true if processed
   procedure doinsertrow;
   procedure doappendrow;
   procedure dodeleterow;
   procedure rowdown;
   procedure lastrow;
   procedure firstrow;
   function getzebrastart: integer;
   procedure gridinvalidate;
   function arecord: integer;
   function hasdata: boolean;
   procedure readdatasource(reader: treader);
   procedure fixupproperties(filer: tfiler); //read moved properties
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(const aowner: tcustomgrid; const aintf: igriddatalink);
   destructor destroy; override;
   property firstrecord: integer read getfirstrecord;
   function getdummystringbuffer: pansistring;
   function getrowfieldisnull(const afield: tfield; const row: integer): boolean;
   function getansistringbuffer(const afield: tfield; const row: integer): pointer;
   function getstringbuffer(const afield: tfield; const row: integer): pointer;
   function getdisplaystringbuffer(const afield: tfield; const row: integer{;
                                       const aedit: boolean}): pointer;
   function getbooleanbuffer(const afield: tfield; const row: integer): pointer;
   function getintegerbuffer(const afield: tfield; const row: integer): pointer;
   function getint64buffer(const afield: tfield; const row: integer): pointer;
   function getrealtybuffer(const afield: tfield; const row: integer): pointer;
   function getdatetimebuffer(const afield: tfield; const row: integer): pointer;
   function canclose(const newfocus: twidget): boolean;
   procedure painted;
   procedure loaded;
   procedure doshortcut(var info: keyeventinfoty; const sender: twidget);
   procedure setselected(const cell: gridcoordty;
                                       const avalue: boolean);
   procedure beforefocuscell(const cell: gridcoordty;
                             const selectaction: focuscellactionty);
   function domoveby(const distance: integer): integer; virtual;
   function moveby(distance: integer): integer; override;
   function rowtorecnozerobased(const row: integer): integer;
   function isfirstrow: boolean;
   function islastrow: boolean;
   property owner: tcustomgrid read fgrid;
   property field_state: tfield read ffield_state;
   property field_color: tfield read ffield_color;
   property field_font: tfield read ffield_font;
   property field_readonly: tfield read ffield_readonly;
   property field_merged: tfield read ffield_merged;
   property field_selected: tfield read ffield_selected;
  published
   property options: griddatalinkoptionsty read foptions write foptions 
                   default defaultgriddatalinkoptions;
   property onupdaterowdata: updaterowdataeventty read fonupdaterowdata 
                                write fonupdaterowdata;
   property datasource: tdatasource read getdatasource1 write settadasource1;
   property fieldname_state: string read ffieldname_state 
                                       write setfieldname_state;
             //integer field, selects grid rowcolor (field value and $7f),
             //readonlystate (field value and $80) and
             //grid rowfont ((fieldvalue shr 8) and $7f). 
             // $xx7f = default color, $7fxx = default font.
   property fieldname_color: string read ffieldname_color 
                                       write setfieldname_color;
   property fieldname_font: string read ffieldname_font
                                       write setfieldname_font;
   property fieldname_readonly: string read ffieldname_readonly 
                                       write setfieldname_readonly;
   property fieldname_merged: string read ffieldname_merged 
                                       write setfieldname_merged;
   property fieldname_selected: string read ffieldname_selected
                                       write setfieldname_selected;
   property navigator: tdbnavigator read fnavigator write setnavigator;
   property onbeginedit: notifyeventty read fonbeginedit write fonbeginedit;
   property onendedit: notifyeventty read fonendedit write fonendedit;
 end;

 rowpositionty = (ropo_nearest,ropo_centeredif,ropo_bottom,
                                          ropo_centered,ropo_top);
 tdropdownlistdatalink = class(tgriddatalink)
  private
   fdataintf: idbdata;
   fkeyindex: integer;
   ftextindex: integer;
   ffirstrecord: integer;
   fcurrentrecord: integer;
   fmaxrowcount: integer;
   procedure setcurrentrecord(const avalue: integer;
                                    const arowpos: rowpositionty);
   procedure updatedatawindow(const arowpos: rowpositionty);
  protected
   function getasmsestring(const afield: tfield): msestring;
   function getasinteger(const afield: tfield): integer;
   function getaslargeint(const afield: tfield): int64;

   procedure cellevent(var info: celleventinfoty); override;
   function getrecordcount: integer; override; 
           //workaround FPC bug 19290
//   function  GetBufferCount: Integer; override;
   procedure SetBufferCount(Value: Integer); override;
   function getfirstrecord: integer; override;
   procedure updatefocustext;
   procedure recordchanged(afield: tfield); override;
   function  GetActiveRecord: Integer; override;
   procedure SetActiveRecord(Value: Integer); override;
   procedure checkscrollbar; override;
   function scrollevent(sender: tcustomscrollbar;
                             event: scrolleventty): boolean; override;
             //true if processed
   procedure focuscell(var cell: gridcoordty); override;
   property currentrecord: integer read fcurrentrecord{ write setcurrentrecord};
  public
   constructor create(const aowner: tcustomgrid; const aintf: igriddatalink;
                  const adatalink: tdropdowndatalink);
   function domoveby(const distance: integer): integer; override;
 end;
 
 tdbdropdownlist = class(tdropdownlist,igriddatalink)
  private
   fdatalink: tdropdownlistdatalink;
    //igriddatalink
   function getdbindicatorcol: integer;
   procedure setnavigator(const avalue: tdbnavigator);
   function getdatalink(): tgriddatalink;
  protected
   function getassistiveflags(): assistiveflagsty override;
   procedure internalcreateframe; override;
   procedure createdatacol(const index: integer; out item: tdatacol); override;
   procedure initcols(const acols: tdropdowncols); override;
   procedure docellevent(var info: celleventinfoty); override;
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty); override;
   procedure setactiveitem(const aitemindex: integer); override;
   function locate(const filter: msestring): boolean; override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure dohide; override;

  public
   constructor create(const acontroller: tcustomdbdropdownlistcontroller;
                             acols: tdropdowncols);
   destructor destroy; override;
   procedure rowup(const action: focuscellactionty = fca_focusin;
                                       const nowrap: boolean = false) override;
   procedure rowdown(const action: focuscellactionty = fca_focusin;
                                       const nowrap: boolean = false) override;
   procedure pageup(const action: focuscellactionty = fca_focusin); override;
   procedure pagedown(const action: focuscellactionty = fca_focusin); override;
   procedure wheelup(const action: focuscellactionty = fca_focusin); override;
   procedure wheeldown(const action: focuscellactionty = fca_focusin);  override;
 end;

// dbdropdownliststatety = (ddls_isstringkey);
// dbdropdownliststatesty = set of dbdropdownliststatety;

 tcustomdbdropdownlistcontroller = class(
                                 tcustomdropdownlistcontroller,idbeditinfo)
  private
   fdatalink: tdropdowndatalink;
//   fisstringkey: boolean;
   foptionsdatalink: griddatalinkoptionsty;
   foptionsdb: optionsdbty;
   fbookmarks: stringarty;
   function getdatasource: tdatasource; overload;
   procedure setdatasource(const avalue: tdatasource);
   procedure setkeyfield(const avalue: string);
   function getkeyfield: string;
   function getcols: tdbdropdowncols;
   procedure setcols(const avalue: tdbdropdowncols);
   procedure setoptionsdb(const avalue: optionsdbty);
  protected
//   fstate: dbdropdownliststatesty;
   procedure valuecolchanged; override;
   function getbuttonframeclass: dropdownbuttonframeclassty; override;
   function getdropdowncolsclass: dropdowncolsclassty; override;
   function  createdropdownlist: tdropdownlist; override;
   function candropdown: boolean; override;
   procedure itemselected(const index: integer; const akey: keyty); override;
   procedure doafterclosedropdown; override;
   
   function getasmsestring(const afield: tfield; const utf8: boolean): msestring;
   function getasinteger(const afield: tfield): integer;
   function getaslargeint(const afield: tfield): int64;
   
    //idbeditinfo
   function getdataset(const aindex: integer): tdataset;
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty);
  public
   constructor create(const intf: idbdropdownlist; const aisstringkey: boolean);
   destructor destroy; override;
   procedure dropdown; override;
   property datalink: tdropdowndatalink read fdatalink;
   property datasource: tdatasource read getdatasource write setdatasource;
   property keyfield: string read getkeyfield write setkeyfield;
   property options default defaultdbdropdownoptions;
   property optionsdatalink: griddatalinkoptionsty read foptionsdatalink 
           write foptionsdatalink default defaultdropdowndatalinkoptions;
   property optionsdb: optionsdbty read foptionsdb write setoptionsdb default [];
   
   property cols: tdbdropdowncols read getcols write setcols;
  end;

 tdbdropdownlistcontroller = class(tcustomdbdropdownlistcontroller)
  published
   property datasource;
   property keyfield;
   property options;
   property optionsdatalink;
   property optionsdb;   
   property cols;
   property dropdownrowcount;
   property delay;
   property valuecol;
   property width;
   property datarowlinewidth;
   property datarowlinecolor;
   property buttonlength;
   property buttonminlength;
   property buttonendlength;
 end;
 
 tdropdownlistcontrollerdb = class(tcustomdbdropdownlistcontroller)
  published
   property datasource;
//   property keyfield;
   property options;
   property optionsdatalink;
   property optionsdb;   
   property cols;
   property dropdownrowcount;
   property delay;
   property valuecol;
   property width;
   property datarowlinewidth;
   property datarowlinecolor;
   property buttonlength;
   property buttonminlength;
   property buttonendlength;
 end;
 
 tdbenumeditdb = class(tdbenumedit,idbdropdownlist,ireccontrol)
  private
   function getdropdown: tdbdropdownlistcontroller;
   procedure setdropdown(const avalue: tdbdropdownlistcontroller);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure recordselected(const arecordnum: integer; const akey: keyty);
   function internaldatatotext(const data): msestring; override;
  published
   property dropdown: tdbdropdownlistcontroller read getdropdown write setdropdown;
 end;
 
 tenumeditdb = class(tenumedit,idbdropdownlist)
  private
   function getdropdown: tdbdropdownlistcontroller;
   procedure setdropdown(const avalue: tdbdropdownlistcontroller);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure recordselected(const arecordnum: integer; const akey: keyty);
   function internaldatatotext(const data): msestring; override;
  published
   property dropdown: tdbdropdownlistcontroller read getdropdown write setdropdown;
 end;
 
 tdbkeystringeditdb = class(tdbkeystringedit,idbdropdownlist,ireccontrol)
  private
//   fkeyvalue: msestring;
   function getdropdown: tdbdropdownlistcontroller;
   procedure setdropdown(const avalue: tdbdropdownlistcontroller);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure recordselected(const arecordnum: integer; const akey: keyty);
   function internaldatatotext(const data): msestring; override;
  published
   property dropdown: tdbdropdownlistcontroller read getdropdown write setdropdown;
 end;
 
 tkeystringeditdb = class(tkeystringedit,idbdropdownlist)
  private
   function getdropdown: tdbdropdownlistcontroller;
   procedure setdropdown(const avalue: tdbdropdownlistcontroller);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure recordselected(const arecordnum: integer; const akey: keyty);
   function internaldatatotext(const data): msestring; override;
  published
   property dropdown: tdbdropdownlistcontroller read getdropdown write setdropdown;
 end;

 tdbwidgetindicatorcol = class(twidgetfixcol)
  private
   fcolorindicator: colorty;
   procedure setcolorindicator(const avalue: colorty);
  protected
   procedure drawcell(const canvas: tcanvas); override;
  public
   constructor create(const agrid: tcustomgrid;
                       const aowner: tgridarrayprop); override;
  published
   property colorindicator: colorty read fcolorindicator 
                   write setcolorindicator default cl_glyph;
   property options default defaultindicatorcoloptions;
 end;

 tdbwidgetfixcols = class(twidgetfixcols)
  private
   fdbindicatorcol: integer;
   fdatalink: tgriddatalink;
   procedure setdbindicatorcol(const Value: integer);
   function getdbindicatorcol: integer;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure setcount1(acount: integer; doinit: boolean); override;
  public
   constructor create(const aowner: tcustomwidgetgrid;
                       const adatalink: tgriddatalink);
  published
   property dbindicatorcol: integer read getdbindicatorcol 
                    write setdbindicatorcol default -1;
 end;

 tdbscrollbar = class(tthumbtrackscrollbar)
  protected
   procedure setoptions(const avalue: scrollbaroptionsty); override;
  public
   constructor create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: proceventty = nil); override;
  published
   property options default defaultdbscrollbaroptions;
   property buttonlength default -1;
 end;
 
 tdbgridframe = class(tgridframe)
  protected
   procedure scrollpostoclientpos(var aclientrect: rectty); override;
   function getscrollbarclass(vert: boolean): framescrollbarclassty; override;
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty); override;
  public
   constructor create(const aintf: iscrollframe; const owner: twidget;
                             const autoscrollintf: iautoscrollframe);
 end;

 tdbwidgetcol = class(twidgetcol)
  protected
   fdatalink: tfielddatalink;

   procedure dobeforedrawcell(const acanvas: tcanvas; 
                          var processed: boolean); override;
   procedure doafterdrawcell(const acanvas: tcanvas); override;
   procedure setwidget(const awidget: twidget); override;
  public
   property datalink: tfielddatalink read fdatalink;
 end;
 
 tdbwidgetcols = class(twidgetcols)
  private
   function getcols(const index: integer): tdbwidgetcol;
  protected
  public
   class function getitemclasstype: persistentclassty; override;
   property cols[const index: integer]: tdbwidgetcol read getcols; default;
 end;

 tcustomdbwidgetgrid = class(tcustomwidgetgrid,igriddatalink)
  private
   fdatalink: tgriddatalink;
//   function getdatasource: tdatasource;
//   procedure setdatasource(const Value: tdatasource);
   function getdatalink: tgriddatalink;
   procedure setdatalink(const avalue: tgriddatalink);
   function getfixcols: tdbwidgetfixcols;
   procedure setfixcols(const avalue: tdbwidgetfixcols);
   function getdatacols: tdbwidgetcols;
   procedure setdatacols(const avalue: tdbwidgetcols);
  protected
   function getassistiveflags(): assistiveflagsty override;
   function createdatacols: tdatacols; override;
   procedure createdatacol(const index: integer; out item: tdatacol); override;
   function canautoappend: boolean; override;
   function getgriddatalink: pointer; override;
   procedure setoptionsgrid(const avalue: optionsgridty); override;
   function getfieldlink(const acol: integer): tcustomeditwidgetdatalink;
   function updatesortcol(const avalue: integer): integer; override;
   procedure internalcreateframe; override;
   function createfixcols: tfixcols; override;
   procedure dolayoutchanged; override;
   procedure docellevent(var info: celleventinfoty); override;
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty); override;
   function getzebrastart: integer; override;
   function getnumoffset: integer; override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure dohide; override;
   procedure loaded; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;

   procedure setselected(const cell: gridcoordty;
                                       const avalue: boolean); override;
   procedure doinsertrow(const sender: tobject); override;
   procedure doappendrow(const sender: tobject); override;
   procedure dodeleterow(const sender: tobject); override;
   procedure beforefocuscell(const cell: gridcoordty;
                             const selectaction: focuscellactionty); override;
   function caninsertrow: boolean; override;
   function canappendrow: boolean; override;
   function candeleterow: boolean; override;
   function isfirstrow: boolean; override;
   function islastrow: boolean; override;
   procedure defineproperties(filer: tfiler); override;
//   procedure doenter; override;
//   procedure doexit; override;
    //igriddatalink
   function getdbindicatorcol: integer;
   procedure setnavigator(const avalue: tdbnavigator);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function focuscell(cell: gridcoordty;
           selectaction: focuscellactionty = fca_focusin;
         const selectmode: selectcellmodety = scm_cell;
         const ashowcell: cellpositionty = cep_nearest): boolean; override;
                                 //true if ok
   function canclose(const newfocus: twidget): boolean; override;
   procedure rowup(const action: focuscellactionty = fca_focusin;
                                       const nowrap: boolean = false); override;
   procedure rowdown(const action: focuscellactionty = fca_focusin;
                                       const nowrap: boolean = false); override;
   procedure pageup(const action: focuscellactionty = fca_focusin); override;
   procedure pagedown(const action: focuscellactionty = fca_focusin); override;
   procedure wheelup(const action: focuscellactionty = fca_focusin); override;
   procedure wheeldown(const action: focuscellactionty = fca_focusin);  override;
   procedure lastrow(const action: focuscellactionty = fca_focusin); override;
   procedure firstrow(const action: focuscellactionty = fca_focusin); override;
//   property datasource: tdatasource read getdatasource write setdatasource;
   property datalink: tgriddatalink read fdatalink write setdatalink;
   property zebra_step default 0;
   property fixcols: tdbwidgetfixcols read getfixcols write setfixcols;
   property datacols: tdbwidgetcols read getdatacols write setdatacols;
 end;

 tdbwidgetgrid = class(tcustomdbwidgetgrid)
  published
//   property datasource;
   property optionsgrid;
   property optionsgrid1;
   property fixcols;
   property fixrows;
//   property font;
   property fontempty;
   property gridframecolor;
//   property gridframewidth;
   property rowcolors;
   property rowfonts;
   property zebra_color;
   property zebra_start;
   property zebra_height;
   property zebra_step;
   property datacols;
   property datalink;

   property datarowlinewidth;
   property datarowlinecolorfix;
   property datarowlinecolor;
   property datarowheight;
   property datarowheightmin;
   property datarowheightmax;

   property statfile;
   property statvarname;
   property statpriority;

   property oncopyselection;
   property onpasteselection;
   property onbeforeupdatelayout;
   property onlayoutchanged;
   property oncolmoving;
   property oncolmoved;
   property onrowcountchanged;
   property onrowdatachanged;
   property onrowsdatachanged;
//   property onrowsmoving;
//   property onrowsmoved;
//   property onrowsinserting;
//   property onrowsinserted;
//   property onrowsdeleting;
//   property onrowsdeleted;
   property oncellevent;
   property onsortchanged;
   property drag;
 end;

 tstringcoldatalink = class(tcustomeditwidgetdatalink)
  private
//   fowner: tcustomstringcol;
  protected
   procedure updatedata; override;
   procedure layoutchanged; override;
 end;

 tdbstringcol = class(tcustomstringcol,idbeditfieldlink,
                                          idbeditinfo,iificlient,iifidatalink)
  private
   fdatalink: tstringcoldatalink;
   fmaxlength: integer;
   fifiserverintf: iifiserver;
   function getdatafield: string;
   procedure setdatafield(const avalue: string);
    //iifidatalink
   procedure setifiserverintf(const aintf: iifiserver);
   function getdefaultifilink: iificlient; virtual;
   function getifilinkkind: ptypeinfo;
   function getifidatatype(): listdatatypety virtual;
   procedure updateifigriddata(const sender: tobject; const alist: tdatalist);
   function getgriddata: tdatalist;
   function getvalueprop: ppropinfo;
   procedure getifivalue(var avalue); //for pointer property without RTTI
   procedure setifivalue(const avalue); //for pointer property without RTTI

    //idbeditinfo
   procedure getfieldtypes(out propertynames: stringarty;
                          out fieldtypes: fieldtypesarty); overload;
   function getdataset(const aindex: integer): tdataset;
   function getoptionsdb: optionseditdbty;
   procedure setoptionsdb(const avalue: optionseditdbty);
   function getnullsymbol: msestring;
   procedure setnullsymbol(const avalue: msestring);
  protected
   function getoptionsedit: optionseditty; override;
   function getitems(aindex: integer): msestring; override;
   procedure setitems(aindex: integer; const Value: msestring); override;
   procedure modified; override;
   procedure dobeforedrawcell(const acanvas: tcanvas; 
                          var processed: boolean); override;
   procedure doafterdrawcell(const acanvas: tcanvas); override;
   function getrowtext(const arow: integer): msestring; override;
   function createdatalist: tdatalist; override;
//   procedure docellevent(var info: celleventinfoty); override;
   procedure docellfocuschanged(enter: boolean;
               const cellbefore: gridcoordty; var newcell: gridcoordty;
               const selectaction: focuscellactionty); override;
    //idbeditfieldlink
   procedure getfieldtypes(var afieldtypes: fieldtypesty); overload;
   function getgriddatasource: tdatasource; virtual;
   function getgridintf: iwidgetgrid;
   function getwidget: twidget;
   function seteditfocus: boolean;
   function getedited: boolean;
   procedure initeditfocus;
   function checkvalue(const quiet: boolean = false): boolean;
   procedure valuetofield;
   procedure fieldtovalue;
   procedure setnullvalue;
   procedure updatereadonlystate;
   procedure setmaxlength(const avalue: integer);
   function getfieldlink: tcustomeditwidgetdatalink;
  public
   constructor create(const agrid: tcustomgrid; 
                         const aowner: tgridarrayprop); override;
   destructor destroy; override;
   property datalink: tstringcoldatalink read fdatalink;
  published
   property datafield: string read getdatafield write setdatafield;
   property optionsdb: optionseditdbty read getoptionsdb write setoptionsdb default [];
   property nullsymbol: msestring read getnullsymbol write setnullsymbol;
   property focusrectdist;
   property textflags;
   property textflagsactive;
   property optionsedit1; //before optionsedit!
   property optionsedit;
   property passwordchar;
   property font;
   property colorselect;
   property fontselect;
   property onsetvalue;
   property ondataentered;
   property oncopytoclipboard;
   property onpastefromclipboard;
   property ondrawcell;
  end;

 tdbstringcols = class(tstringcols)
  private
   foptionsdb: optionseditdbty;
   function getcols(const index: integer): tdbstringcol;
   procedure setoptionsdb(const avalue: optionseditdbty);
  protected
   function getcolclass: stringcolclassty; override;
   procedure datasourcechanged; override;
  public
   class function getitemclasstype: persistentclassty; override;
   property cols[const index: integer]: tdbstringcol read getcols; default; //last!
  published
   property optionsdb: optionseditdbty read foptionsdb write setoptionsdb default [];
 end;
 
 tdbstringindicatorcol = class(tfixcol)
  private
   fcolorindicator: colorty;
   procedure setcolorindicator(const avalue: colorty);
  protected
   procedure drawcell(const canvas: tcanvas); override;
  public
   constructor create(const agrid: tcustomgrid;
                       const aowner: tgridarrayprop); override;
  published
   property colorindicator: colorty read fcolorindicator 
                write setcolorindicator default cl_glyph;
   property options default defaultindicatorcoloptions;
 end;

 tdbstringfixcols = class(tfixcols)
  private
   fdbindicatorcol: integer;
   fdatalink: tgriddatalink;
   procedure setdbindicatorcol(const Value: integer);
   function getdbindicatorcol: integer;
  protected
   procedure createitem(const index: integer; var item: tpersistent); override;
   procedure setcount1(acount: integer; doinit: boolean); override;
  public
   constructor create(const aowner: tcustomgrid;
                       const adatalink: tgriddatalink);
  published
   property dbindicatorcol: integer read getdbindicatorcol
                                 write setdbindicatorcol default -1;
 end;

 dbstringgridoptionty = (dsgo_autofields);
 dbstringgridoptionsty = set of dbstringgridoptionty;

 tstringgriddatalink =  class(tgriddatalink)
  protected
   procedure activechanged; override;
 end;

 tcustomdbstringgrid = class(tcustomstringgrid,iwidgetgrid,igriddatalink)
  private
   fdatalink: tstringgriddatalink;
   foptions: dbstringgridoptionsty;
   ffieldnamedisplayfixrow: integer;
//   function getdatasource: tdatasource;
//   procedure setdatasource(const Value: tdatasource);
   function getdatacols: tdbstringcols;
   procedure setdatacols(const avalue: tdbstringcols);

    //iwidgetgrid (dummy)
   function getbrushorigin: pointty;
   function getcol: twidgetcol;
   procedure getdata(var index: integer; var dest);
   procedure setdata(var index: integer; const source;
                                       const noinvalidate: boolean = false);
   procedure datachange(const arow: integer);
   function getrow: integer;
   procedure setrow(arow: integer);
   procedure changed();
   procedure edited();
   function empty(index: integer): boolean;
   procedure updateeditoptions(var aoptions: optionseditty;
                                    const aoptions1: optionsedit1ty);
   procedure showrect(const arect: rectty; const aframe: tcustomframe);
   procedure widgetpainted(const canvas: tcanvas);
   function nullcheckneeded(const newfocus: twidget): boolean;
   function nonullcheck: boolean;
   function getgrid: tcustomwidgetgrid;
   function getdatapo(const arow: integer): pointer;
   function getrowdatapo: pointer;
  {$ifdef mse_with_ifi}
   procedure updateifigriddata(const alist: tdatalist);
  {$endif}   
   procedure setoptions(const avalue: dbstringgridoptionsty);
   procedure checkautofields;
   procedure setfieldnamedisplayfixrow(const avalue: integer);
   function getdatalink: tgriddatalink; //igriddatalink
   procedure setdatalink(const avalue: tstringgriddatalink);
   function getfixcols: tdbstringfixcols;
   procedure setfixcols(const avalue: tdbstringfixcols);
  protected
   function getassistiveflags(): assistiveflagsty override;
   function canautoappend: boolean; override;
   procedure setupeditor(const acell: gridcoordty; const focusin: boolean); override;
//   procedure doenter; override;
//   procedure doexit; override;
    //igriddatalink
   function getdbindicatorcol: integer;
   procedure setnavigator(const avalue: tdbnavigator);

   procedure setselected(const cell: gridcoordty;
                                       const avalue: boolean); override;
   procedure updatelayout; override;
//   procedure editnotification(var info: editnotificationinfoty); override;
   procedure setoptionsgrid(const avalue: optionsgridty); override;
   function getfieldlink(const acol: integer): tfielddatalink;
   function updatesortcol(const avalue: integer): integer; override;
   procedure doasyncevent(var atag: integer); override;
   procedure internalcreateframe; override;
//   function getoptionsedit: optionseditty; override;
   function createfixcols: tfixcols; override;
   function createdatacols: tdatacols; override;
//   procedure initcellinfo(var info: cellinfoty); override;
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty); override;
   function getzebrastart: integer; override;
   function getnumoffset: integer; override;
   procedure checkcellvalue(var accept: boolean); override;
   procedure dopaint(const acanvas: tcanvas); override;
   procedure dohide; override;
   procedure loaded; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
   function cangridcopy: boolean;

   function caninsertrow: boolean; override;
   function canappendrow: boolean; override;
   function candeleterow: boolean; override;

   procedure doinsertrow(const sender: tobject); override;
   procedure doappendrow(const sender: tobject); override;
   procedure dodeleterow(const sender: tobject); override;
   procedure beforefocuscell(const cell: gridcoordty;
                             const selectaction: focuscellactionty); override;
   procedure coloptionstoeditoptions(var dest: optionseditty; 
                                                  var dest1: optionsedit1ty);
   function isfirstrow: boolean; override;
   function islastrow: boolean; override;
   procedure defineproperties(filer: tfiler); override;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function focuscell(cell: gridcoordty;
           selectaction: focuscellactionty = fca_focusin;
         const selectmode: selectcellmodety = scm_cell;
         const ashowcell: cellpositionty = cep_nearest): boolean; override;
                                 //true if ok
   procedure docellevent(var info: celleventinfoty); override;
   function canclose(const newfocus: twidget): boolean; override;
   procedure rowup(const action: focuscellactionty = fca_focusin;
                                       const nowrap: boolean = false); override;
   procedure rowdown(const action: focuscellactionty = fca_focusin;
                                       const nowrap: boolean = false); override;
   procedure pageup(const action: focuscellactionty = fca_focusin); override;
   procedure pagedown(const action: focuscellactionty = fca_focusin); override;
   procedure wheelup(const action: focuscellactionty = fca_focusin); override;
   procedure wheeldown(const action: focuscellactionty = fca_focusin); override;
   procedure lastrow(const action: focuscellactionty = fca_focusin); override;
   procedure firstrow(const action: focuscellactionty = fca_focusin); override;
//   property datasource: tdatasource read getdatasource write setdatasource;
   property datacols: tdbstringcols read getdatacols write setdatacols;
   property datalink: tstringgriddatalink read fdatalink write setdatalink;
   property options: dbstringgridoptionsty read foptions 
                           write setoptions default [];
   property fieldnamedisplayfixrow: integer read ffieldnamedisplayfixrow write
                    setfieldnamedisplayfixrow default -1; 
                    //negative rowindex, 0-> none
   property zebra_step default 0;
   property fixcols: tdbstringfixcols read getfixcols write setfixcols;
 end;
 
 tdbstringgrid = class(tcustomdbstringgrid)
  published
//   property datasource;
   property options;
   property fieldnamedisplayfixrow;
   
   property optionsgrid;
   property optionsgrid1;
   property datacols;
   property datalink;
   property fixcols;
   property fixrows;
   property gridframecolor;
//   property gridframewidth;
   property rowcolors;
   property rowfonts;
   property zebra_color;
   property zebra_start;
   property zebra_height;
   property zebra_step;

   property datarowlinewidth;
   property datarowlinecolorfix;
   property datarowlinecolor;
   property datarowheight;
   property datarowheightmin;
   property datarowheightmax;
   property caretwidth;

   property statfile;
   property statvarname;
   property statpriority;

   property oncopyselection;
   property onpasteselection;
   property onbeforeupdatelayout;
   property onlayoutchanged;
   property oncolmoving;
   property oncolmoved;
   property onrowcountchanged;
   property onrowdatachanged;
   property onrowsdatachanged;
//   property onrowsmoving;
//   property onrowsmoved;
//   property onrowsinserting;
//   property onrowsinserted;
//   property onrowsdeleting;
//   property onrowsdeleted;
   property oncellevent;
   property onsortchanged;
   property drag;
 end;

 tlbdropdownlistcontroller = class;

 tlbdropdownstringcol = class(tdropdownstringcol)
  private
   flookupbuffer: tcustomlookupbuffer;
   ffieldno: integer;
   fsortfieldno: integer;
   funsorted: boolean;
  protected
   function getrowtext(const arow: integer): msestring; override;
  public
 end;

 tcopydropdownlist = class(tdropdownlist)
  private
  protected
   function locate(const filter: msestring): boolean; override;
 end;
 
 eddstatety = (edds_filtered,edds_bof,edds_eof);
 eddstatesty = set of eddstatety;

 texterndatadropdownlistcontroller = class;
  
 texterndatadropdownlist = class(tdropdownlist)
  private
   ffirstrecord: integer;
   frecnums: integerarty;
   feddstate: eddstatesty;
   function getactiverecord: integer;
   procedure setactiverecord(const avalue: integer);
  protected
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure findprev(var recno: integer);
   procedure findnext(var recno: integer); virtual; abstract;
   function getrecno(const aindex: integer): integer;
   procedure dorowcountchanged(const countbefore,newcount: integer); override;
   procedure internalcreateframe; override;
   procedure createdatacol(const index: integer; out item: tdatacol); override;
   procedure docellevent(var info: celleventinfoty); override;
   procedure scrollevent(sender: tcustomscrollbar; event: scrolleventty); override;
   procedure dbscrolled(distance: integer);
   procedure moveby(distance: integer);
   procedure filterchanged;
   procedure resyncfilter;
   property activerecord: integer read getactiverecord write setactiverecord;
  public
   constructor create(const acontroller: texterndatadropdownlistcontroller;
                             acols: tdropdowncols);
   procedure rowup(const action: focuscellactionty = fca_focusin;
                                       const nowrap: boolean = false); override;
   procedure rowdown(const action: focuscellactionty = fca_focusin;
                                       const nowrap: boolean = false); override;
   procedure pageup(const action: focuscellactionty = fca_focusin); override;
   procedure pagedown(const action: focuscellactionty = fca_focusin); override;
   procedure wheelup(const action: focuscellactionty = fca_focusin); override;
   procedure wheeldown(const action: focuscellactionty = fca_focusin);  override;
 end;

 tlbdropdownlist = class(texterndatadropdownlist)
  private
  protected
   procedure initcols(const acols: tdropdowncols); override;
   function locate(const filter: msestring): boolean; override;
   procedure findnext(var recno: integer); override;
  public
   constructor create(const acontroller: tcustomlbdropdownlistcontroller;
                             acols: tdropdowncols);
 end;
      
 tlbdropdowncol = class(tdropdowncol,ilookupbufferfieldinfo)
  private
   ffieldno: lookupbufferfieldnoty;
   procedure setfieldno(const avalue: lookupbufferfieldnoty);
  protected
    //ilookupbufferfieldinfo
   function getlbdatakind(const apropname: string): lbdatakindty;
   function getlookupbuffer: tcustomlookupbuffer;
  published
   property fieldno: lookupbufferfieldnoty read ffieldno write setfieldno
                                                         default 0;
                    //colindex in lookupbuffer
 end;
 
 tlbdropdowncols = class(tnolistdropdowncols)
  private
   function getitems(const index: integer): tlbdropdowncol;
  protected
   function getcolclass: dropdowncolclassty; override;
  public
   property items[const index: integer]: tlbdropdowncol read getitems; default;
 end;

 optionlbty = (olb_copyitems,olb_unsorted);
 optionslbty = set of optionlbty;
                                   
 texterndatadropdownlistcontroller = class(tcustomdropdownlistcontroller)
  private
   fedrecnums: integerarty;
  protected
   procedure dofilter(var recno: integer; var accept: boolean); virtual; abstract;
   procedure valuecolchanged; override;
   function getbuttonframeclass: dropdownbuttonframeclassty; override;
   function getdropdowncolsclass: dropdowncolsclassty; override;
  public
   constructor create(const intf: ilbdropdownlist);
   procedure dropdown; override;
   property options default defaulteddropdownoptions;
 end;

 tcustomlbdropdownlistcontroller = class(texterndatadropdownlistcontroller,
                                        ilookupbufferfieldinfo)
  private
   fsortfieldno: integer;
   flookupbuffer: tcustomlookupbuffer;
   fkeyfieldno: lookupbufferfieldnoty;
   fonfilter: lbfiltereventty;
   foptionslb: optionslbty;
   fonbeforefilter: dataediteventty;
   function getcols: tlbdropdowncols;
   procedure setcols(const avalue: tlbdropdowncols);
   procedure setlookupbuffer(const avalue: tcustomlookupbuffer);
  protected
   procedure dofilter(var recno: integer; var accept: boolean); override;
   function reloadlist: integer; override;
   function createdropdownlist: tdropdownlist; override;
   function candropdown: boolean; override;
   procedure itemselected(const index: integer; const akey: keyty); override;
   procedure objectevent(const sender: tobject; const event: objecteventty); override;
   function getremoterowcount: integer; override;
  //ilookupbufferfieldinfo
   function getlbdatakind(const apropname: string): lbdatakindty;
   function getlookupbuffer: tcustomlookupbuffer;
  public
   property optionslb: optionslbty read foptionslb write foptionslb default [];
   property cols: tlbdropdowncols read getcols write setcols;
   property lookupbuffer: tcustomlookupbuffer read flookupbuffer write setlookupbuffer;
   property keyfieldno: lookupbufferfieldnoty read fkeyfieldno write fkeyfieldno default 0;
   property onfilter: lbfiltereventty read fonfilter write fonfilter;
   property onbeforefilter: dataediteventty read fonbeforefilter 
                                                        write fonbeforefilter;
 end;
 
 tlbdropdownlistcontroller = class(tcustomlbdropdownlistcontroller)
  published
   property lookupbuffer;
   property keyfieldno;
   property optionslb;
   property options;
   property cols;
   property onbeforefilter;
   property onfilter;
   property dropdownrowcount;
   property delay;
   property valuecol;
   property width;
   property datarowlinewidth;
   property datarowlinecolor;
   property buttonlength;
   property buttonminlength;
   property buttonendlength;
 end;
 
 tdropdownlistcontrollerlb = class(tcustomlbdropdownlistcontroller)
  published
   property lookupbuffer;
//   property keyfieldno;
   property optionslb;
   property options;
   property cols;
   property onbeforefilter;
   property onfilter;
   property dropdownrowcount;
   property delay;
   property valuecol;
   property width;
   property datarowlinewidth;
   property datarowlinecolor;
   property buttonlength;
   property buttonminlength;
   property buttonendlength;
 end;
 
 tdbenumeditlb = class(tdbenumedit,ilbdropdownlist)
  private
   function getdropdown: tlbdropdownlistcontroller;
   procedure setdropdown(const avalue: tlbdropdownlistcontroller);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   function internaldatatotext(const data): msestring; override;
          //ilbdropdownlist
   procedure recordselected(const arecordnum: integer; const akey: keyty);
   function getlbkeydatakind: lbdatakindty;                     
  published
   property dropdown: tlbdropdownlistcontroller read getdropdown write setdropdown;
 end;

 tenumeditlb = class(tenumedit,ilbdropdownlist)
  private
   function getdropdown: tlbdropdownlistcontroller;
   procedure setdropdown(const avalue: tlbdropdownlistcontroller);
  {$ifdef mse_with_ifi}
   function getifilink: tifiintegerlinkcomp;
   procedure setifilink1(const avalue: tifiintegerlinkcomp);
  {$endif}
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   function internaldatatotext(const data): msestring; override;
  //ilbdropdownlist
   procedure recordselected(const arecordnum: integer; const akey: keyty);
   function getlbkeydatakind: lbdatakindty;                     
  public
  published
   property dropdown: tlbdropdownlistcontroller read getdropdown write setdropdown;
{$ifdef mse_with_ifi}
   property ifilink: tifiintegerlinkcomp read getifilink write setifilink1;
{$endif}
 end;

 tcustomenum64edit = class(tcustomdropdownlistedit)
  private
   fonsetvalue1: setint64eventty;
   function getgridvalue(const index: integer): int64;
   procedure setgridvalue(const index: integer; aValue: int64);
   function getgridvalues: int64arty;
   procedure setgridvalues(const avalue: int64arty);
   procedure setvalue(const avalue: int64);
  {$ifdef mse_with_ifi}
   function getifilink: tifiint64linkcomp;
   procedure setifilink1(const avalue: tifiint64linkcomp);
  {$endif}
  protected
   fvalue1: int64;
   fvaluedefault1: int64;
   
   function getdefaultvalue: pointer; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   procedure texttodata(const atext: msestring; var data); override;
   procedure setnullvalue; override; //for dbedits
   procedure valuetogrid(arow: integer); override;
   procedure gridtovalue(arow: integer); override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;

   function createdatalist(const sender: twidgetcol): tdatalist; override;
   function getdatalistclass: datalistclassty; override;

  {$ifdef mse_with_ifi}
   function getifidatalinkintf: iifidatalink; override;
    //iifidatalink
   function getifilinkkind: ptypeinfo; override;
  {$endif}
  public
   constructor create(aowner: tcomponent); override;
   property gridvalue[const index: integer]: int64
        read getgridvalue write setgridvalue; default;
   property gridvalues: int64arty read getgridvalues write setgridvalues;
   property value: int64 read fvalue1 write setvalue default -1;
{$ifdef mse_with_ifi}
   property ifilink: tifiint64linkcomp read getifilink write setifilink1;
{$endif}
   property valuedefault: int64 read fvaluedefault1 write fvaluedefault1 default -1;
   property onsetvalue: setint64eventty read fonsetvalue1 write fonsetvalue1;
 end;

 tcustomenum64editlb = class(tcustomenum64edit,ilbdropdownlist)
  private
   function getdropdown: tlbdropdownlistcontroller;
   procedure setdropdown(const avalue: tlbdropdownlistcontroller);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   function internaldatatotext(const data): msestring; override;
  //ilbdropdownlist
   procedure recordselected(const arecordnum: integer; const akey: keyty);
   function getlbkeydatakind: lbdatakindty;                     
  public
   property dropdown: tlbdropdownlistcontroller read getdropdown write setdropdown;
 end;

 tenum64editlb = class(tcustomenum64editlb)
  published
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
   property dropdown;
   property value;
   property valuedefault;
   property onsetvalue;
 end;
 
 tdbenum64editlb = class(tcustomenum64editlb,idbeditfieldlink,ireccontrol)
  private
   fdatalink: tlookupeditdatalink;
   procedure setdatalink(const avalue: tlookupeditdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;

   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;

   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield; virtual;
   procedure fieldtovalue; virtual;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tlookupeditdatalink read fdatalink write setdatalink;
   property dropdown;
   property onsetvalue;
 end;
 
 tcustomenum64editdb = class(tcustomenum64edit,idbdropdownlist)
  private
   function getdropdown: tdbdropdownlistcontroller;
   procedure setdropdown(const avalue: tdbdropdownlistcontroller);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   function internaldatatotext(const data): msestring; override;
    //ilbdropdownlist
   procedure recordselected(const arecordnum: integer; const akey: keyty);
  public
   property dropdown: tdbdropdownlistcontroller read getdropdown write setdropdown;
 end;

 tenum64editdb = class(tcustomenum64editdb)
  published
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
   property dropdown;
   property value;
   property valuedefault;
   property onsetvalue;
 end;
 
 tdbenum64editdb = class(tcustomenum64editdb,idbeditfieldlink,ireccontrol)
  private
   fdatalink: tlookupeditdatalink;
   procedure setdatalink(const avalue: tlookupeditdatalink);
  protected   
   procedure defineproperties(filer: tfiler); override;
   function nullcheckneeded(const newfocus: twidget): boolean; override;
   procedure griddatasourcechanged; override;
   function getgriddatasource: tdatasource;
   function createdatalist(const sender: twidgetcol): tdatalist; override;
   procedure modified; override;
   procedure doshortcut(var info: keyeventinfoty; 
                                      const sender: twidget); override;
//   function getoptionsedit: optionseditty; override;
//   procedure dochange; override;
//   procedure doenter; override;
//   procedure doexit; override;
   function getrowdatapo(const arow: integer): pointer; override;
    //idbeditfieldlink
   procedure valuetofield; virtual;
   procedure fieldtovalue; virtual;
   procedure getfieldtypes(var afieldtypes: fieldtypesty);
   function getfieldlink: tcustomeditwidgetdatalink;
    //ireccontrol
   procedure recchanged;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property datalink: tlookupeditdatalink read fdatalink write setdatalink;
   property dropdown;
   property onsetvalue;
 end;
 
 tdbkeystringeditlb = class(tdbkeystringedit,ilbdropdownlist)
  private
   function getdropdown: tlbdropdownlistcontroller;
   procedure setdropdown(const avalue: tlbdropdownlistcontroller);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   function internaldatatotext(const data): msestring; override;
  //ilbdropdownlist
   procedure recordselected(const arecordnum: integer; const akey: keyty);
   function getlbkeydatakind: lbdatakindty;                     
  published
   property dropdown: tlbdropdownlistcontroller read getdropdown write setdropdown;
 end;
 
 tkeystringeditlb = class(tkeystringedit,ilbdropdownlist)
  private
   function getdropdown: tlbdropdownlistcontroller;
   procedure setdropdown(const avalue: tlbdropdownlistcontroller);
  protected
   function createdropdowncontroller: tcustomdropdowncontroller; override;
   function internaldatatotext(const data): msestring; override;
    //ilbdropdownlist
   procedure recordselected(const arecordnum: integer; const akey: keyty);
   function getlbkeydatakind: lbdatakindty;                     
  published
   property dropdown: tlbdropdownlistcontroller read getdropdown write setdropdown;
 end;

function encoderowstate(const color: integer = -1; const font: integer = -1;
                            const readonly: boolean = false): integer;
                            
implementation
uses
 msestockobjects,
 mseshapes,msereal,msebits,
 mseassistiveserver,
 mseactions,mseact,rtlconsts,msedrawtext,sysutils,msedbdispwidgets;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

type
 tcomponent1 = class(tcomponent);
 twidget1 = class(twidget);
 tcustomgrid1 = class(tcustomgrid);
 tcustomdataedit1 = class(tcustomdataedit);
 tdatacols1 = class(tdatacols);
 tdropdowncols1 = class(tdropdowncols);
 tdataedit1 = class(tdataedit);
 tdataset1 = class(tdataset);
 tdatasource1 = class(tdatasource);
 ttoolbuttons1 = class(ttoolbuttons);
 tcustomstringgrid1 = class(tcustomstringgrid);
 treader1 = class(treader);
 tcols1 = class(tcols);

 hasactiveeditinfoty = record
  field: tfield;
  hasedit: boolean;
 end;
 phasactiveeditinfoty = ^hasactiveeditinfoty;
 
function encoderowstate(const color: integer = -1; const font: integer = -1;
                            const readonly: boolean = false): integer;
begin
 result:= (color and $7f) or ((font and $7f) shl 8);
 if readonly then begin
  result:= result or $80;
 end;
end;

procedure drawindicatorcell(const canvas: tcanvas; const datalink: tgriddatalink;
                             const acolor: colorty);
var
 glyph: stockglyphty;
begin
 with cellinfoty(canvas.drawinfopo^) do begin
  with datalink do begin
   case dataset.state of
    dsbrowse: glyph:= stg_dbindbrowse;
    dsedit: glyph:= stg_dbindedit;
    dsinsert: glyph:= stg_dbindinsert;
    else
    //{$warnings off}
    // glyph:= stockglyphty(-1);
     glyph:= stockglyphty(stg_nil);
    // {$warnings on}
   end;
  // if ord(glyph) >= 0 then begin
   if ord(glyph) < ord(stg_nil) then begin
    stockobjects.glyphs.paint(canvas,ord(glyph),innerrect,
           [al_xcentered,al_ycentered],acolor);
   end;
  end;
 end;
end;

function confirmdeleterecord: boolean;
begin
 with stockobjects do begin
  result:= askok(captions[sc_Delete_record_question],captions[sc_confirmation]);
 end;
end;

function confirmcopyrecord: boolean;
begin
 with stockobjects do begin
  result:= askok(captions[sc_Copy_record_question],captions[sc_confirmation])
  end;
end;

{ tnavigdatalink }

constructor tnavigdatalink.Create(const intf: idbnaviglink);
begin
 fintf:= intf;
 inherited create;
 visualcontrol:= true;
 fintf.setactivebuttons([],false);
end;

procedure tnavigdatalink.updatebuttonstate;
var
 bu1: dbnavigbuttonsty;
 bo1: boolean;
 options1: dbnavigatoroptionsty;
begin
 options1:= fintf.getnavigoptions;
 bu1:= [dbnb_autoedit];
 if dno_dialogifinactive in options1 then begin
  bu1:= bu1+[dbnb_dialog];
 end;
 bo1:= false;
 if active then begin
  bu1:= bu1+[dbnb_first,dbnb_prior,dbnb_next,dbnb_last]+
                 filterdbnavigbuttons+[dbnb_dialog];
  if bof then begin
   bu1:= bu1 - [dbnb_first,dbnb_prior];
  end;
  if eof then begin
   bu1:= bu1 - [dbnb_next,dbnb_last];
  end;
  if (dno_dialogifinactive in options1) and bof and eof then begin
   bu1:= bu1 - [dbnb_dialog];
  end;
  if (dno_nodialogifnoeditmode in options1) and 
         not (datasource.state in dseditmodes) then begin
   bu1:= bu1 - [dbnb_dialog];
  end;
  if (dno_nodialogifreadonly in options1) and not canupdate then begin
   bu1:= bu1 - [dbnb_dialog];
  end;
  case datasource.state of
   dsfilter: begin
    case filtereditkind of
     fek_filter: bu1:= [dbnb_filter];
     fek_filtermin: bu1:= [dbnb_filtermin];
     fek_filtermax: bu1:= [dbnb_filtermax];
     fek_find: bu1:= [dbnb_find];
    end;
    fintf.setcheckedbuttons(bu1,true);
    bu1:= bu1+[dbnb_filterclear];
   end;
   dsedit,dsinsert: begin
    bu1:= bu1 + [dbnb_post,dbnb_cancel,dbnb_refresh,dbnb_insert,dbnb_delete];
    if (datasource.state = dsinsert) and 
                          (dno_nomultiinsert in options1) then begin
     exclude(bu1,dbnb_insert);
    end;
   end;
   else begin
    fintf.setcheckedbuttons(
                  [dbnb_filter,dbnb_filtermin,dbnb_filtermax,dbnb_find],false);
    bu1:= bu1 + [dbnb_refresh,dbnb_insert,dbnb_delete,dbnb_edit,
                 dbnb_filteronoff,dbnb_copyrecord];
   end;
  end;
//  if (fdscontroller <> nil) and fdscontroller.noedit then begin
//   bu1:= bu1 - editnavigbuttons;
//  end;
  if not canupdate then begin
   bu1:= bu1 - [dbnb_edit,dbnb_autoedit];
  end;
  if dno_append in options1 then begin
   if not canappend then begin
    bu1:= bu1 - [dbnb_insert,dbnb_copyrecord];
   end;
  end
  else begin
   if not caninsert then begin
    bu1:= bu1 - [dbnb_insert,dbnb_copyrecord];
   end;
  end;
  if not candelete then begin
   exclude(bu1,dbnb_delete);
  end;
  if bof and eof then begin
   bu1:= bu1 - [dbnb_delete,dbnb_copyrecord];
  end;
//  if not datasource.dataset.canmodify then begin
//   bu1:= bu1 - [dbnb_edit,dbnb_delete,dbnb_insert,dbnb_copyrecord];
//  end;
  if csdesigning in dataset.componentstate then begin
   bu1:= bu1 * designdbnavigbuttons;
  end;
  bo1:= datasource.dataset.filtered;
 end;
 if dno_nonavig in options1 then begin
  bu1:= bu1 - ([dbnb_first,dbnb_prior,dbnb_next,dbnb_last,
                dbnb_insert,dbnb_delete,dbnb_filteronoff,dbnb_copyrecord]+
                filterdbnavigbuttons);
 end;
 if dno_nodelete in options1 then begin
  bu1:= bu1 - [dbnb_delete];
 end;
 if dno_noinsert in options1 then begin
  bu1:= bu1 - [dbnb_insert];
 end;
 if dno_noedit in options1 then begin
  bu1:= bu1 - [dbnb_edit];
 end;
 fintf.setactivebuttons(bu1,bo1);
end;
 
procedure tnavigdatalink.activechanged;
var
 intf1: igetdscontroller;
begin
 fdscontroller:= nil;
 if active then begin
  if getcorbainterface(dataset,typeinfo(igetdscontroller),intf1) then begin
   fdscontroller:= intf1.getcontroller;
  end;
 end;
 inherited;
 updatebuttonstate;
end;

procedure tnavigdatalink.datasetchanged;
begin
 inherited;
 updatebuttonstate;
end;

procedure tnavigdatalink.editingchanged;
begin
 inherited;
 updatebuttonstate();
 fintf.updatereadonly();
 with twidget1(fintf.getwidget) do begin
  if fobjectlinker <> nil then begin
   fobjectlinker.sendevent(oe_changed);
  end;
 end;
end;

procedure tnavigdatalink.recordchanged(field: tfield);
begin
 inherited;
 updatebuttonstate;
end;

procedure tnavigdatalink.execbutton(const abutton: dbnavigbuttonty);
var
 widget1: twidget;
 options1: dbnavigatoroptionsty;
 intf1: iassistiveclient;
begin
 if (datasource <> nil) and (datasource.State <> dsinactive) then begin
  widget1:= fintf.getwidget;
  options1:= fintf.getnavigoptions;
  if not (abutton in [dbnb_cancel,dbnb_delete,dbnb_autoedit]) then begin
   if dno_candefocuswindow in options1 then begin
    if not widget1.rootwidget.canparentclose then begin
     exit;
    end;
   end
   else begin
    if (widget1.parentwidget <> nil) and
            not widget1.parentwidget.canparentclose then begin
     exit;
    end;
   end;
  end;
  with datasource.dataset do begin
   // Warning: Case statement does not handle all possible cases
   case abutton of
    dbnb_first: first;
    dbnb_prior: begin
     include(fstate,nds_prior);
     exclude(fstate,nds_datasetscrolled);
     try
      self.moveby(-1);
      if not (nds_datasetscrolled in fstate) and canassistive(intf1) then begin
       assistiveserver.dodatasetevent(intf1,adek_bof,dataset);
      end;
     finally
      exclude(fstate,nds_prior);
     end;
    end;
    dbnb_next: begin
     include(fstate,nds_next);
     try
      self.moveby(1);
     finally
      exclude(fstate,nds_next);
     end;
    end;
    dbnb_last: last;
    dbnb_insert: begin
     if dno_append in options1 then begin
      append;
     end
     else begin
      insert;
     end;
    end;
    dbnb_delete: begin
     if not (dno_confirmdelete in options1) or confirmdeleterecord then begin
      delete;
     end;
    end;
    dbnb_edit: edit;
    dbnb_post: post;
    dbnb_cancel: cancel;
    dbnb_refresh: begin
     if dscontroller <> nil then begin
      dscontroller.refresh(not (dno_norefreshrecno in options1));
     end
     else begin
      refresh;
     end;
    end;
    dbnb_filteronoff: filtered:= not filtered;
    dbnb_dialog: begin
     if (dno_postbeforedialog in options1) and (state in dseditmodes) then begin
      post;
     end;
     fintf.dodialogexecute;
    end;
    dbnb_autoedit: begin
     with twidget1(widget1) do begin
      if fobjectlinker <> nil then begin
       fobjectlinker.sendevent(oe_changed);
      end;
     end;
     fintf.updatereadonly();
    end;
    dbnb_copyrecord: begin
     if (dscontroller <> nil) and
      not (dno_confirmcopy in options1) or confirmcopyrecord then begin
      dscontroller.copyrecord(dno_append in options1);
     end;
    end;
    else { cannot occur? }
     Raise Exception.Create ('Unhandled case value, ordinal #'+ IntToStr (ord (abutton))) AT
           get_caller_addr (get_frame), get_caller_frame (get_frame);
   end;
   if fdscontroller <> nil then begin
    if state = dsfilter then begin
     case abutton of
      dbnb_filterclear: fdscontroller.clearfilter();
      else begin
       fdscontroller.endfilteredit;
      end;
     end;
    end
    else begin
     case abutton of
      dbnb_filter: fdscontroller.beginfilteredit(fek_filter);
      dbnb_filtermin: fdscontroller.beginfilteredit(fek_filtermin);
      dbnb_filtermax: fdscontroller.beginfilteredit(fek_filtermax);
      dbnb_filterclear: fdscontroller.clearfilter();
      dbnb_find: fdscontroller.beginfilteredit(fek_find);
     end;
    end;
   end;
  end;
 end;
end;

procedure tnavigdatalink.disabledstatechange;
begin
 updatebuttonstate;
end;

function tnavigdatalink.canassistive(out aintf: iassistiveclient): boolean;
var
 wi1: twidget1;
begin
 result:= false;
 aintf:= nil;
 if (assistiveserver <> nil) and active then begin
  wi1:= twidget1(fintf.getwidget());
  result:= wi1.window.active;
  if result then begin 
   aintf:= wi1.getiassistiveclient();
  end;
 end;
end;

procedure tnavigdatalink.datasetscrolled(distance: integer);
var
 k1: assistivedbeventkindty;
 intf1: iassistiveclient;
begin
 include(fstate,nds_datasetscrolled);
 inherited;
 if (distance = 0) and canassistive(intf1) then begin
  k1:= adek_none;
  if nds_prior in fstate then begin
   k1:= adek_bof;
  end;
  if nds_next in fstate then begin
   k1:= adek_eof;
  end;
  if k1 <> adek_none then begin
   assistiveserver.dodatasetevent(intf1,k1,dataset);
  end;
 end;
end;

{ tdbnavigator }
const
 dbnavigimages: array[dbnavigbuttonty] of stockglyphty =
  //dbnb_first,dbnb_prior,dbnb_next,dbnb_last,dbnb_insert,
  (stg_dbfirst,stg_dbprior,stg_dbnext,stg_dblast,stg_dbinsert,
  
// dbnb_delete,dbnb_copyrecord,dbnb_edit,
   stg_dbdelete,stg_doublesquare,stg_dbedit,
// dbnb_post,dbnb_cancel,dbnb_refresh,
   stg_dbpost,stg_dbcancel,stg_dbrefresh,
// dbnb_filter,dbnb_filtermin,dbnb_filtermax,dbnb_filterclear,dbnb_filteronoff,
   stg_dbfilter,stg_dbfiltermin,stg_dbfiltermax,stg_dbfilterclear,stg_dbfilteron,
// dbnb_find,
   stg_dbfind,
// dbnb_autoedit,dbnb_dialog
   stg_triabig,stg_ellipsesmall
);

 dbnavighints: array[dbnavigbuttonty] of stockcaptionty =
  //dbnb_first,dbnb_prior,dbnb_next,dbnb_last,dbnb_insert,
  (sc_first,sc_prior,sc_next,sc_last,sc_append,
  
// dbnb_delete,dbnb_copyrecord,dbnb_edit,
   sc_delete,sc_copy,sc_edit,
// dbnb_post,dbnb_cancel,dbnb_refresh,
   sc_post,sc_cancel,sc_refresh,
// dbnb_filter,dbnb_filtermin,       dbnb_filtermax,    dbnb_filterclear,
   sc_edit_filter,sc_edit_filter_min,sc_edit_filter_max,sc_reset_filter,
// dbnb_filteronoff,dbnb_find,
   sc_filter_on,sc_search,
// dbnb_autoedit,dbnb_dialog
   sc_auto_edit,sc_dialog
);
  
{ tdbnavigbuttons }

class function tdbnavigbuttons.getbuttonclass: toolbuttonclassty;
begin
 result:= tdbnavigbutton;
end;

constructor tdbnavigator.create(aowner: tcomponent);
var
 int1: integer;
begin
 if flayout.buttons = nil then begin
  flayout.buttons:= tdbnavigbuttons.create(self);
 end;
 foptions:= defaultdbnavigatoroptions;
 fshortcuts[dbnb_first]:= key_modctrl + ord(key_pageup);
 fshortcuts[dbnb_prior]:= ord(key_pageup);
 fshortcuts[dbnb_next]:= ord(key_pagedown);
 fshortcuts[dbnb_last]:= key_modctrl + ord(key_pagedown);
 fshortcuts[dbnb_edit]:= ord(key_f2);
 fshortcuts[dbnb_post]:= ord(key_f2);
// fshortcuts[dbnb_dialog]:= ord(key_f3);
 inherited;
 fwidgetstate1:= fwidgetstate1 + [ws1_designactive,ws1_nodisabledclick];
 size:= makesize(defaultdbnavigatorwidth,defaultdbnavigatorheight);
 include(ttoolbuttons1(buttons).fbuttonstate,tbs_nocandefocus);
 buttons.count:= ord(high(dbnavigbuttonty))+1;
 for int1:= 0 to ord(high(dbnavigbuttonty)) do begin
  with buttons[int1] do begin
   imagelist:= stockobjects.glyphs;
   imagenr:= ord(dbnavigimages[dbnavigbuttonty(int1)]);
   tag:= int1;
   onexecute:= {$ifdef FPC}@{$endif}doexecute;
  end;
 end;
 with buttons[ord(dbnb_autoedit)] do begin
  options:= options + [mao_checkbox];
 end;
 with buttons[ord(dbnb_filter)] do begin
  options:= options + [mao_checkbox];
 end;
 with buttons[ord(dbnb_filtermin)] do begin
  options:= options + [mao_checkbox];
 end;
 with buttons[ord(dbnb_filtermax)] do begin
  options:= options + [mao_checkbox];
 end;
 with buttons[ord(dbnb_find)] do begin
  options:= options + [mao_checkbox];
 end;
 with buttons[ord(dbnb_filteronoff)] do begin
  options:= options + [mao_checkbox];
 end;
  
 fdatalink:= tnavigdatalink.Create(idbnaviglink(self));
 visiblebuttons:= defaultvisibledbnavigbuttons;
end;

destructor tdbnavigator.destroy;
begin
// fdatalink.Free;
 inherited;
 fdatalink.Free;
end;

procedure tdbnavigator.inithints;
var
 int1: integer;
 sc1: int32;
begin
 for int1:= 0 to ord(high(dbnavigbuttonty)) do begin
  with buttons[int1] do begin
////   hint:= stockobjects.captions[stockcaptionty(int1+ord(sc_first))];
   hint:= stockobjects.captions[dbnavighints[dbnavigbuttonty(int1)]];
   if (dno_shortcuthint in foptions) then begin
    if dbnavigbuttonty(int1) = dbnb_dialog then begin
     sc1:= shortcut;
    end
    else begin
     sc1:= fshortcuts[dbnavigbuttonty(int1)];
    end;
    if sc1 <> 0 then begin
     hint:= hint + ' (' + encodeshortcutname(sc1)+')';
    end;
   end;
  end;
 end;
 with buttons[ord(dbnb_insert)] do begin
  if dno_append in self.options then begin
   hint:= stockobjects.captions[sc_append];
  end
  else begin
   hint:= stockobjects.captions[sc_insert];
  end;
  
  if (dno_shortcuthint in foptions) and 
            (fshortcuts[dbnb_insert] <> 0) then begin
   hint:= hint + ' (' + 
                 encodeshortcutname(fshortcuts[dbnb_insert])+')';
  end;
 end;
end;

procedure tdbnavigator.doasyncevent(var atag: integer);
begin
 if atag = 0 then begin
  application.mouseparkevent;
 end
 else begin
  inherited;
 end;
end;

procedure tdbnavigator.setactivebuttons(const abuttons: dbnavigbuttonsty;
                                        const afiltered: boolean);
var
 bu1: dbnavigbuttonty;
begin
 beginupdate;
 try
  with buttons[ord(dbnb_filteronoff)] do begin
   checked:= afiltered;
  {
   if afiltered then begin
    imagenr:= ord(stg_dbfilteroff);
    hint:= stockobjects.captions[sc_filter_off];
   end
   else begin
    imagenr:= ord(stg_dbfilteron);
    hint:= stockobjects.captions[sc_filter_on];
   end;
   if (dno_shortcuthint in foptions) and 
             (fshortcuts[dbnb_filteronoff] <> 0) then begin
    hint:= hint + ' (' + 
                  encodeshortcutname(fshortcuts[dbnb_filteronoff])+')';
   end;
  }
  end;
  for bu1:= low(dbnavigbuttonty) to high(dbnavigbuttonty) do begin
   if (bu1 <> dbnb_dialog) or not (dno_customdialogupdate in foptions) then begin
    with buttons[ord(bu1)] do begin
     if bu1 in abuttons then begin
      state:= state - [as_disabled];
     end
     else begin
      state:= state + [as_disabled];
     end;
    end;
   end;
  end;
  dialogbutton.doupdate;
 finally
  endupdate;
 end;
 if application.mousewidget = self then begin
  asyncevent(0);
 end;
end;

procedure tdbnavigator.setcheckedbuttons(const abuttons: dbnavigbuttonsty;
               const achecked: boolean);
var
 bu1: dbnavigbuttonty;
begin
 beginupdate;
 try
  for bu1:= low(dbnavigbuttonty) to high(dbnavigbuttonty) do begin
   if bu1 in abuttons then begin
    with buttons[ord(bu1)] do begin
     if achecked then begin
      state:= state + [as_checked];
     end
     else begin
      state:= state - [as_checked];
     end;
    end;
   end;
  end;
  dialogbutton.doupdate;
 finally
  endupdate;
 end;
end;

function tdbnavigator.getdatasource: tdatasource;
begin
 result:= fdatalink.DataSource;
end;

procedure tdbnavigator.setvisiblebuttons(const avalue: dbnavigbuttonsty);
var
 bu1: dbnavigbuttonty;
begin
 if fvisiblebuttons <> avalue then begin
  beginupdate;
  for bu1:= low(dbnavigbuttonty) to high(dbnavigbuttonty) do begin
   buttons[ord(bu1)].visible:= bu1 in avalue;
  end;
  fvisiblebuttons:= avalue;
  endupdate;
 end; 
end;

function tdbnavigator.getcolorglyph: colorty;
begin
 result:= buttons.colorglyph;
end;

procedure tdbnavigator.setcolorglyph(const avalue: colorty);
begin
 buttons.colorglyph:= avalue;
end;

function tdbnavigator.getbuttonface: tface;
begin
 result:= buttons.face;
end;

procedure tdbnavigator.setbuttonface(const avalue: tface);
begin
 buttons.face:= avalue;
end;

procedure tdbnavigator.loaded;
begin
 inherited;
 colorglyph:= colorglyph;
 inithints;
 updatereadonly(true);
end;

procedure tdbnavigator.internalshortcut(var info: keyeventinfoty;
                                                    const sender: twidget);
var
 bu1: dbnavigbuttonty;
begin
 if not (csdesigning in componentstate) then begin
  for bu1:= low(dbnavigbuttonty) to dbnb_autoedit do begin
   if checkshortcutcode(fshortcuts[bu1],info) then begin
    if buttons[ord(bu1)].enabled or 
         (assistiveserver <> nil) and (bu1 in [dbnb_prior,dbnb_next]) then begin
     fdatalink.execbutton(bu1);
     include(info.eventstate,es_processed);
     break;
    end;
   end;
  end;
 end;
end;

procedure tdbnavigator.doshortcut(var info: keyeventinfoty;
                                                  const sender: twidget);
begin
 internalshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin;
  inherited;
 end;
end;

procedure tdbnavigator.setdatasource(const Value: tdatasource);
begin
 fdatalink.DataSource:= value;
end;

procedure tdbnavigator.doexecute(const sender: tobject);
begin
 with ttoolbutton(sender) do begin
  fdatalink.execbutton(dbnavigbuttonty(tag));
  if action <> nil then begin
   action.execute();
  end;
 end;
end;

function tdbnavigator.getnavigoptions: dbnavigatoroptionsty;
begin
 result:= foptions;
end;

procedure tdbnavigator.setoptions(const avalue: dbnavigatoroptionsty);
var
 diff: dbnavigatoroptionsty;
begin
 diff:= avalue >< foptions;
 if diff <> [] then begin
  foptions:= avalue;
  if not (csloading in componentstate) then begin
   inithints;
   if dno_nonavig in diff then begin
    fdatalink.updatebuttonstate()
   end;
  end;
 end;
end;

procedure tdbnavigator.dodialogexecute();
begin
 if canevent(tmethod(fondialogexecute)) then begin
  fondialogexecute(self);
 end;
end;

procedure tdbnavigator.updatereadonly(const force: boolean = false);
var
 b1: boolean;
begin
 b1:= canautoedit;
 if (b1 <> fcanautoeditbefore) or force then begin
  fcanautoeditbefore:= b1;
  if canevent(tmethod(fonreadonlychange)) then begin
   fonreadonlychange(self,not b1);
  end;
 end;
end;

function tdbnavigator.gettoolbutton: tdbnavigbutton;
begin
 result:= tdbnavigbutton(buttons[ord(dbnb_dialog)]);
end;

procedure tdbnavigator.settoolbutton(const avalue: tdbnavigbutton);
begin
 buttons[ord(dbnb_dialog)]:= avalue;
end;

function tdbnavigator.getautoedit: boolean;
begin
 result:= buttons[ord(dbnb_autoedit)].checked;
end;

procedure tdbnavigator.setautoedit(const avalue: boolean);
begin
 if buttons[ord(dbnb_autoedit)].checked <>  avalue then begin
  buttons[ord(dbnb_autoedit)].checked:= avalue;
  updatereadonly();
  if fobjectlinker <> nil then begin
   fobjectlinker.sendevent(oe_changed);
  end;
 end;
end;

procedure tdbnavigator.dostatread(const reader: tstatreader);
begin
 autoedit:= reader.readboolean('autoedit',autoedit);
end;

procedure tdbnavigator.dostatwrite(const writer: tstatwriter);
begin
 writer.writeboolean('autoedit',autoedit);
end;

procedure tdbnavigator.edit;
var
 int1: integer;
begin
 if fdatalink.active and (fdatalink.dataset.state = dsbrowse) then begin
  int1:= -1;
  if buttons[ord(dbnb_edit)].enabled then begin
   int1:= ord(dbnb_edit);
  end
  else begin
   if buttons[ord(dbnb_insert)].enabled then begin
    int1:= ord(dbnb_insert);
   end
  end;
  if int1 >= 0 then begin
   fdatalink.execbutton(dbnavigbuttonty(int1));
  end;
 end;
end;

function tdbnavigator.canautoedit(): boolean;
begin
 result:= autoedit or fdatalink.active and 
                             (fdatalink.dataset.state in [dsedit,dsinsert])
end;

function tdbnavigator.canclose(const newfocus: twidget = nil): boolean;
begin
 if (dno_postoncanclose in foptions) and fdatalink.active and 
                                               (newfocus = nil) then begin
  fdatalink.dataset.checkbrowsemode;
 end;
 result:= inherited canclose(newfocus);
end;

function tdbnavigator.getbuttonwidth: integer;
begin
 result:= flayout.buttons.width;
end;

procedure tdbnavigator.setbuttonwidth(const avalue: integer);
begin
 flayout.buttons.width:= avalue;
end;

function tdbnavigator.getbuttonheight: integer;
begin
 result:= flayout.buttons.height;
end;

procedure tdbnavigator.setbuttonheight(const avalue: integer);
begin
 flayout.buttons.height:= avalue;
end;
{
function tdbnavigator.getnonavig: boolean;
begin
 result:= dno_nonavig in foptions;
end;

procedure tdbnavigator.setnonavig(const avalue: boolean);
begin
 if avalue then begin
  options:= options + [dno_nonavig];
 end
 else begin
  options:= options - [dno_nonavig];
 end;
end;
}
{ tcustomeditwidgetdatalink }

constructor tcustomeditwidgetdatalink.create(const intf: idbeditfieldlink);
//var
// intf1: iificlient;
begin
 foptions:= defaulteditwidgetdatalinkoptions;
 fintf:= intf;
 fintf.setifiserverintf(iifidataserver(self));
// if getcorbainterface(intf.getwidget,typeinfo(iificlient),intf1) then begin
//  intf1.setifiserverintf(iifiserver(self));
// end;
 inherited Create;
 visualcontrol:= true;
 fintf.seteditstate(fintf.geteditstate+[des_isdb]);
// fintf.setisdb;
end;

destructor tcustomeditwidgetdatalink.destroy;
begin
 inherited;
 freeandnil(fobjectlinker);
end;

procedure tcustomeditwidgetdatalink.readdatasource(reader: treader);
begin
 treader1(reader).readpropvalue(self,
          getpropinfo(typeinfo(teditwidgetdatalink),'datasource'));
end;

procedure tcustomeditwidgetdatalink.readdatafield(reader: treader);
begin
 fieldname:= reader.readstring;
end;

procedure tcustomeditwidgetdatalink.readoptionsdb(reader: treader);
begin
 treader1(reader).readpropvalue(self,
          getpropinfo(typeinfo(teditwidgetdatalink),'options'));
end;

procedure tcustomeditwidgetdatalink.fixupproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('datasource',{$ifdef FPC}@{$endif}readdatasource,nil,false);
 filer.defineproperty('datafield',{$ifdef FPC}@{$endif}readdatafield,nil,false);
 filer.defineproperty('optionsdb',{$ifdef FPC}@{$endif}readoptionsdb,nil,false);
               //move values to datalink
end;

function tcustomeditwidgetdatalink.getasnullmsestring: msestring;
begin
 if field.isnull then begin
  result:= nullsymbol;
 end
 else begin
  result:= asmsestring;
 end;
end;

procedure tcustomeditwidgetdatalink.setasnullmsestring(const avalue: msestring);
begin
 if avalue = nullsymbol then begin
  if oed_nonullset in foptions then begin   
   asmsestring:= msedefaultexpression;
  end
  else begin
   field.clear;
  end;
 end
 else begin
  asmsestring:= avalue;
 end;
end;

procedure tcustomeditwidgetdatalink.setediting(avalue: boolean);
begin
 if (fds_editing in fstate) <> avalue then begin
  if avalue then begin
   include(fstate,fds_editing);
  end
  else begin
   exclude(fstate,fds_editing);
  end;
  exclude(fstate,fds_modified);
 end;
end;

function tcustomeditwidgetdatalink.edit: Boolean;
begin
 if canmodify then begin
  if (dataset.state = dsbrowse) and 
       ((oed_autoedit in foptions) or
         (fnavigator <> nil) and fnavigator.canautoedit()
       ) then begin
   dataset.edit;
  end
  else begin
   inherited edit;
  end;
 end;
 result:= fds_editing in fstate;
end;

function tcustomeditwidgetdatalink.canmodify: Boolean;
begin
 result:= (field <> nil) and 
           ((fds_filterediting in fstate) or 
              canupdate and not field.readonly);
end;

procedure tcustomeditwidgetdatalink.modified;
begin
 if not editing and (frecordchange = 0) and 
                not (fds_filterediting in fstate) then begin
  inc(fbeginedit);
  try
   edit;
  finally
   dec(fbeginedit);
  end;
 end;
 include(fstate,fds_modified);
end;

procedure tcustomeditwidgetdatalink.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 if (info.eventstate * [es_preview,es_processed] = []) and 
                     (fnavigator <> nil) and fnavigator.showing and
                                               fnavigator.isenabled then begin
  fnavigator.internalshortcut(info,sender);
 end;
end;

procedure tcustomeditwidgetdatalink.updateoptionsedit(var avalue: optionseditty);
var
 state1: tcomponentstate;
begin
 state1:= fintf.getwidget.ComponentState;
 if state1 * [cswriting,csdesigning] = [] then begin
  if not (fds_filterediting in fstate) and 
         (not canmodify or 
           not editing and 
            not (canmodify and
                    not (oed_noautoedit in foptions) and
                    ((oed_autoedit in foptions) or
                     (datasource <> nil) and datasource.AutoEdit or 
                     (fnavigator <> nil) and fnavigator.canautoedit
                    )
                )
          ) then begin
   include(avalue,oe_readonly);
  end;
  if (field <> nil) and field.required then begin
   include(avalue,oe_notnull);
  end;
 end;
end;

procedure tcustomeditwidgetdatalink.editingchanged;
var
 widget1: twidget;
begin
 inherited;
 widget1:= fintf.getwidget;
 if not editing and assigned(fonendedit) and 
         widget1.canevent(tmethod(fonendedit)) then begin
  fonendedit(self);
 end;
 setediting(inherited editing and canmodify);
 fintf.updatereadonlystate;
 if editing then begin
  if (fnavigator <> nil) and (oed_syncedittonavigator in foptions) and
                                           (dataset.state = dsedit) then begin
   fnavigator.edit();
  end;
  if (oed_focusoninsert in foptions) and (dataset.state = dsinsert) then begin 
   fintf.seteditfocus();
  end;
  if assigned(fonbeginedit) and 
         fintf.getwidget.canevent(tmethod(fonbeginedit)) then begin
   fonbeginedit(self);
  end;
 end;
end;

procedure tcustomeditwidgetdatalink.dataevent(event: tdataevent; info: ptrint);
var
 bo1: boolean;
 bo2: boolean;
begin
 bo1:= fds_filterediting in fstate;
 case ord(event) of
  ord(deupdatestate): begin
   if (dataset <> nil) and (dataset.state = dsfilter) then begin
    include(fstate,fds_filterediting);
   end
   else begin
    exclude(fstate,fds_filterediting);
   end;
  end;
  ord(de_hasactiveedit): begin
   with phasactiveeditinfoty(info)^ do begin
    hasedit:= hasedit or (field = self.field) and
                  fintf.getwidget.window.active;
   end;
  end;
 end;
 inherited;
 if bo1 <> (fds_filterediting in fstate) then begin
  if bo1 then begin
   if fds_filtereditdisabled in fstate then begin
    exclude(fstate,fds_filtereditdisabled);
    fintf.setenabled(true);
   end;
  end
  else begin
   case filtereditkind of 
    fek_filtermin: bo2:= oed_nofilterminedit in foptions;
    fek_filtermax: bo2:= oed_nofiltermaxedit in foptions;
    fek_find: bo2:= oed_nofindedit in foptions;
    else bo2:= oed_nofilteredit in foptions; //fek_filter
   end;
   if bo2 then begin
    include(fstate,fds_filtereditdisabled);
    fintf.setenabled(false);
   end;
  end;
  fintf.updatereadonlystate;
 end;
end;

procedure tcustomeditwidgetdatalink.bindingchanged;
begin
 if active and (field <> nil) and isstringfield{
                    (field.datatype in [ftstring,ftfixedchar])} then begin
  if ismsestring then begin
   fmaxlength:= tmsestringfield(field).characterlength;
  end
  else begin
   fmaxlength:= field.size;
  end;
  if fmaxlength < 0 then begin
   fmaxlength:= 0;
  end;
 end
 else begin
  fmaxlength:= 0;
 end;

 if oed_limitcharlen in foptions then begin
  if fmaxlength = 0 then begin
   fintf.setmaxlength(-1);
  end
  else begin
   fintf.setmaxlength(fmaxlength);
  end;
 end;
end;

procedure tcustomeditwidgetdatalink.activechanged;
begin
 if not active then begin
  fstate:= fstate - [fds_filterediting,fds_filtereditdisabled];
 end;
 fintf.updatereadonlystate;
 try
  inherited;
 except
  on e: exception do begin
   e.message:= fintf.getwidget.name + ': ' + e.message;
   raise
  end;
 end;
 bindingchanged;
end;

procedure tcustomeditwidgetdatalink.disabledstatechange;
begin
 inherited;
 fintf.updatereadonlystate;
end;

function tcustomeditwidgetdatalink.getdataset(const aindex: integer): tdataset;
begin
 result:= dataset;
end;

procedure tcustomeditwidgetdatalink.getfieldtypes(out apropertynames: stringarty; 
                                     out afieldtypes: fieldtypesarty);
begin
 apropertynames:= nil;
 setlength(afieldtypes,1);
 fintf.getfieldtypes(afieldtypes[0]);
 if afieldtypes[0] = [] then begin
  afieldtypes:= nil;
 end;
end;

procedure tcustomeditwidgetdatalink.focuscontrol(afield: tfieldref);
begin
 if (afield^ = field) and (field <> nil) then begin
  if fintf.seteditfocus then begin
   afield^:= nil;
  end;
 end;
end;

procedure tcustomeditwidgetdatalink.recordchanged(afield: tfield);
var
 wi1: twidget;
 intf1: iassistiveclientdata;
begin
 if (afield = nil) or (afield = field) then begin
  if (fbeginedit = 0) and (frecordchange = 0) then begin
   inc(frecordchange);
   try
    if (field <> nil) and active and 
      not (dataset.eof and dataset.bof and 
              not (dataset.state in [dsinsert,dsfilter])) then begin
     if field.isnull then begin
      fintf.setnullvalue;
     end
     else begin 
      fintf.fieldtovalue;
     end;
    end
    else begin
     fintf.setnullvalue;
    end;
    wi1:= fintf.getwidget;
    if wi1.focused then begin
     fintf.initeditfocus;
    end;
    if (assistiveserver <> nil) and wi1.active and 
        wi1.getcorbainterface(typeinfo(iassistiveclientdata),intf1) then begin
     assistiveserver.dodbvaluechanged(intf1);
    end;
   finally
    dec(frecordchange);
   end;
  end;
  exclude(fstate,fds_modified);
 end;
end;

procedure tcustomeditwidgetdatalink.datasetscrolled(distance: integer);
begin
 if distance <> 0 then begin
  inherited;
 end;
end;

procedure tcustomeditwidgetdatalink.updatedata;
var
 stat1: dataeditstatesty;
begin
 inc(fcanclosing);
 stat1:= fintf.geteditstate;
 if not (des_dbnullcheck in stat1) then begin
  fintf.seteditstate(stat1+[des_dbnullcheck]);
 end;
 try
  with fintf.getwidget do begin
   if canclose(nil) then begin
    exclude(fstate,fds_modified);
   end
   else begin
    activate;
    raise eabort.create('');
   end;
  end;
  if not (oed_nullset in foptions) and (field <> nil) then begin
   if ismsestring then begin
    with tmsestringfield(field) do begin
     if (defaultexpression <> '') and isnull and 
          (dataset.modified or 
            (fdscontroller <> nil) and fdscontroller.posting) then begin
      asmsestring:= self.msedefaultexpression;
     end;
    end;
   end
   else begin
    with field do begin
     if (defaultexpression <> '') and isnull and 
          (dataset.modified or 
            (fdscontroller <> nil) and fdscontroller.posting) then begin
      asstring:= defaultexpression;
     end;
    end;
   end;
  end;
  inherited;
 finally
  dec(fcanclosing);
  if not (des_dbnullcheck in stat1) then begin
   fintf.seteditstate(fintf.geteditstate-[des_dbnullcheck]);
  end;
 end;
end;

function tcustomeditwidgetdatalink.getdatasource1: tdatasource;
begin
 result:= inherited datasource;
end;

procedure tcustomeditwidgetdatalink.setwidgetdatasource(const avalue: tdatasource);
begin
 if not ((csloading in fintf.getwidget.componentstate) and datasourcefixed or 
                  (fintf.getgridintf <> nil)) then begin
  inherited datasource:= avalue;
 end;
end;

procedure tcustomeditwidgetdatalink.griddatasourcechanged;
var
 datasource1: tdatasource;
begin
 datasource1:= fintf.getgriddatasource;
 if datasource <> datasource1 then begin
  datasource:= datasource1;
 end;
end;

procedure tcustomeditwidgetdatalink.nullcheckneeded(var avalue: boolean);
 function findactivedatalink: boolean;
 var
  info1: hasactiveeditinfoty;
 begin
  with info1 do begin
   hasedit:= false;
   field:= self.field;
   tdataset1(dataset).dataevent(tdataevent(de_hasactiveedit),ptruint(@info1));
   result:= hasedit;
  end;
 end; //findactivedatalink
 
begin
 avalue:= active and 
          (
           (avalue or fintf.getedited and (oed_autopost in foptions) or
            (fcanclosing > 0)
           ) and 
           ((dataset.state in [dsinsert,dsedit]) and
            (dataset.modified or 
             avalue and (oed_nullcheckifunmodified in foptions) or
             (dataset.state <> dsinsert) or 
             (fdscontroller <> nil) and fdscontroller.posting
            )
           )
          );
 avalue:= avalue and (fintf.getwidget.window.active or not findactivedatalink);
end;

function tcustomeditwidgetdatalink.cuttext(const atext: msestring;
               out maxlength: integer): boolean;
begin
 maxlength:= fmaxlength;
 result:= (maxlength > 0) and (length(atext) > maxlength);
end;

function tcustomeditwidgetdatalink.getownerwidget: twidget;
begin
 result:= fintf.getwidget;
end;

procedure tcustomeditwidgetdatalink.setnavigator(const avalue: tdbnavigator);
begin
 getobjectlinker.setlinkedvar(iobjectlink(self),tmsecomponent(avalue),
                  tmsecomponent(fnavigator));
end;

function tcustomeditwidgetdatalink.getobjectlinker: tobjectlinker;
begin
 createobjectlinker(self,{$ifdef FPC}@{$endif}objectevent,fobjectlinker);
 result:= fobjectlinker;
end;

procedure tcustomeditwidgetdatalink.link(const source: iobjectlink;
               const dest: iobjectlink; valuepo: pointer = nil;
               ainterfacetype: pointer = nil; once: boolean = false);
begin
 getobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tcustomeditwidgetdatalink.unlink(const source: iobjectlink;
               const dest: iobjectlink; valuepo: pointer = nil);
begin
 getobjectlinker.unlink(source,dest,valuepo);
end;

procedure tcustomeditwidgetdatalink.objevent(const sender: iobjectlink;
               const event: objecteventty);
begin
 getobjectlinker.objevent(sender,event);
end;

function tcustomeditwidgetdatalink.getinstance: tobject;
begin
 result:= self;
end;

procedure tcustomeditwidgetdatalink.objectevent(const sender: tobject;
               const event: objecteventty);
begin
 if (sender = fnavigator) and (event = oe_changed) then begin
  fintf.updatereadonlystate;
 end;
end;

procedure tcustomeditwidgetdatalink.fieldchanged;
begin
 bindingchanged;
 inherited;
end;

procedure tcustomeditwidgetdatalink.setoptions(const avalue: optionseditdbty);
begin
 foptions:= optionseditdbty(
                setsinglebit(card32(avalue),
                    card32(foptions),[card32([oed_autoedit,oed_noautoedit]),
                                       card32([oed_readonly,oed_noreadonly])]));
end;

function tcustomeditwidgetdatalink.datasourcereadonly(): boolean;
begin
 result:= inherited datasourcereadonly();
 if oed_readonly in foptions then begin
  result:= true;
 end;
 if oed_noreadonly in foptions then begin
  result:= false;
 end;
end;

procedure tcustomeditwidgetdatalink.valuechanged(const sender: iifidatalink);
var
 widget1: twidget;
 bo1,bo2: boolean;
begin
 if (frecordchange = 0) and (fposting = 0) then begin
  widget1:= fintf.getwidget;
  if not (ws_loadedproc in widget1.widgetstate) and (field <> nil) and 
               not ((oe_checkmrcancel in fintf.getoptionsedit) and
             (widget1.window.modalresult = mr_cancel)) then begin
   if fds_filterediting in fstate then begin
    fintf.valuetofield;
   end
   else begin
    if editing then begin
     fintf.valuetofield;
     if assigned(fondataentered) and 
            fintf.getwidget.canevent(tmethod(fondataentered)) then begin
      fondataentered(self);
     end;
     if (oed_autopost in foptions) and active then begin
      widget1:= widget1.parentwidget;
      try
       inc(fposting);
       if (widget1 <> nil) then begin
        if widget1.parentwidget is tcustomgrid then begin
         with tcustomgrid1(widget1.parentwidget) do begin
          bo1:= fnonullcheck > 0;
          if bo1 then begin
           dec(fnonullcheck);   //remove colchangelock
          end;
         end;
        end
        else begin
         bo1:= false;
        end;
        try
         bo2:= widget1.canparentclose;
        finally
         if bo1 then begin
          inc(tcustomgrid1(widget1.parentwidget).fnonullcheck);
         end;
        end;
       end;
       if bo2 then begin
        dataset.post;
       end;
      finally
       dec(fposting);
      end;
     end;
    end;
   end;
  end;
 end;
end;
{
procedure tcustomeditwidgetdatalink.statechanged(const sender: iificlient;
               const astate: ifiwidgetstatesty);
begin
end;

procedure tcustomeditwidgetdatalink.setvalue(const sender: iificlient;
               var avalue; var accept: boolean; const arow: integer);
begin
end;

procedure tcustomeditwidgetdatalink.sendmodalresult(const sender: iificlient;
               const amodalresult: modalresultty);
begin
end;

procedure tcustomeditwidgetdatalink.dataentered(const sender: iificlient;
                                                          const arow: integer);
begin
end;
}

{ tdbstringedit }

constructor tdbstringedit.create(aowner: tcomponent);
begin
 fdatalink:= tstringeditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbstringedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbstringedit.modified;
begin
 fdatalink.modified;
 inherited;
end;

procedure tdbstringedit.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
function tdbstringedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
procedure tdbstringedit.valuetofield;
begin
 fdatalink.asnullmsestring:= value;
end;

procedure tdbstringedit.fieldtovalue;
begin
 value:= fdatalink.asnullmsestring;
end;

function tdbstringedit.getnulltext: msestring;
begin
 result:= fdatalink.nullsymbol;
end;

function tdbstringedit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getstringbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdbstringedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbstringedit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbstringedit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbstringedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= textfields;
end;

function tdbstringedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tdbstringedit.setdatalink(const adatalink: tstringeditwidgetdatalink);
begin
 fdatalink.assign(adatalink);
end;

procedure tdbstringedit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

 { repaced by oed_limitcharlen

procedure tdbstringedit.editnotification(var info: editnotificationinfoty);
var
 int1: integer;
begin
 inherited;
 if info.action = ea_textedited then begin
  if fdatalink.cuttext(text,int1) then begin
   text:= copy(text,1,int1);
  end;
 end;
end;
 }

procedure tdbstringedit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbstringedit.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;

procedure tdbstringedit.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbstringedit.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
function tdbstringedit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;

{
constructor tdbdialogstringedit.create(aowner: tcomponent);
begin
 fdatalink:= tstringeditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbdialogstringedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbdialogstringedit.modified;
begin
 fdatalink.Modified;
 inherited;
end;

function tdbdialogstringedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;

procedure tdbdialogstringedit.valuetofield;
begin
 if value = '' then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.asmsestring:= value;
 end;
end;

procedure tdbdialogstringedit.fieldtovalue;
begin
 value:= fdatalink.asmsestring;
end;

function tdbdialogstringedit.getrowdatapo(const info: cellinfoty): pointer;
begin
 with info do begin
  if griddatalink <> nil then begin
   result:= tgriddatalink(griddatalink).getstringbuffer(fdatalink.field,cell.row);
  end
  else begin
   result:= nil;
  end;
 end;
end;

function tdbdialogstringedit.getnulltext: msestring;
begin
 result:= fdatalink.nullsymbol;
end;

function tdbdialogstringedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbdialogstringedit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbdialogstringedit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbdialogstringedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= textfields;
end;

function tdbdialogstringedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tdbdialogstringedit.setdatalink(const avalue: tstringeditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbdialogstringedit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbdialogstringedit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

procedure tdbdialogstringedit.dochange;
begin
 fdatalink.dataentered;
 inherited;
end;
}

{ tcustomdbdropdownlistedit }

constructor tcustomdbdropdownlistedit.create(aowner: tcomponent);
begin
 fdatalink:= tstringeditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tcustomdbdropdownlistedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tcustomdbdropdownlistedit.modified;
begin
 fdatalink.Modified;
 inherited;
end;

procedure tcustomdbdropdownlistedit.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
function tcustomdbdropdownlistedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
procedure tcustomdbdropdownlistedit.valuetofield;
begin
 if value = '' then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.asmsestring:= value;
 end;
end;

procedure tcustomdbdropdownlistedit.fieldtovalue;
begin
 value:= fdatalink.asmsestring;
end;

function tcustomdbdropdownlistedit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getstringbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tcustomdbdropdownlistedit.getnulltext: msestring;
begin
 result:= fdatalink.nullsymbol;
end;

function tcustomdbdropdownlistedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tcustomdbdropdownlistedit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tcustomdbdropdownlistedit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tcustomdbdropdownlistedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= textfields;
end;

function tcustomdbdropdownlistedit.nullcheckneeded(
                                       const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tcustomdbdropdownlistedit.setdatalink(
                                       const avalue: tstringeditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tcustomdbdropdownlistedit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tcustomdbdropdownlistedit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tcustomdbdropdownlistedit.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
function tcustomdbdropdownlistedit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;

function tcustomdbdropdownlistedit.getdropdownifilink: tifidropdownlistlinkcomp;
begin
 result:= fdropdownifilink;
end;

procedure tcustomdbdropdownlistedit.setdropdownifilink(
                               const avalue: tifidropdownlistlinkcomp);
begin
 mseificomp.setifilinkcomp(idbifidropdownlistdatalink(self),avalue,
                                      tifilinkcomp(fdropdownifilink));
end;

procedure tcustomdbdropdownlistedit.dropdownsetifiserverintf(
                                               const aintf: iifiserver);
begin
 fdropdownifiserverintf:= aintf;
end;

procedure tcustomdbdropdownlistedit.dropdownifisetvalue(var avalue;
               var accept: boolean);
begin
 //dummy
end;
{
procedure tcustomdbdropdownlistedit.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tcustomdbdropdownlistedit.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbkeystringedit }

constructor tdbkeystringedit.create(aowner: tcomponent);
begin
 fdatalink:= tstringlookupeditdatalink.Create(self,ldt_string,
                                                    idbeditfieldlink(self));
 inherited;
end;

destructor tdbkeystringedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbkeystringedit.modified;
begin
 fdatalink.modified;
 inherited;
end;
{
function tdbkeystringedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
// frame.readonly:= oe_readonly in result;
end;
}
procedure tdbkeystringedit.valuetofield;
begin
 if value = '' then begin
  fdatalink.field.clear;
  if fdatalink.fieldtext <> nil then begin
   fdatalink.fieldtext.clear;
  end;
 end
 else begin
  fdatalink.asmsestring:= value;
  setasmsestring(text,fdatalink.fieldtext,fdatalink.utf8)
 end;
end;

procedure tdbkeystringedit.fieldtovalue;
begin
 value:= fdatalink.asmsestring;
end;

function tdbkeystringedit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getstringbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdbkeystringedit.getnulltext: msestring;
begin
 result:= fdatalink.nullsymbol;
end;

function tdbkeystringedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbkeystringedit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbkeystringedit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbkeystringedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= textfields;
end;

function tdbkeystringedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tdbkeystringedit.setdatalink(const avalue: tstringlookupeditdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbkeystringedit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbkeystringedit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbkeystringedit.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
function tdbkeystringedit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbkeystringedit.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbkeystringedit.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbmemoedit }

constructor tdbmemoedit.create(aowner: tcomponent);
begin
 fdatalink:= tstringeditwidgetdatalink.create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbmemoedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbmemoedit.modified;
begin
 fdatalink.modified;
 inherited;
end;

procedure tdbmemoedit.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
function tdbmemoedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
procedure tdbmemoedit.valuetofield;
begin
 if value = '' then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.asmsestring:= value;
 end;
end;

procedure tdbmemoedit.fieldtovalue;
begin
 value:= fdatalink.asmsestring;
end;

function tdbmemoedit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getstringbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdbmemoedit.getnulltext: msestring;
begin
 result:= fdatalink.nullsymbol;
end;

function tdbmemoedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbmemoedit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbmemoedit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbmemoedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= memofields;
end;

function tdbmemoedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tdbmemoedit.setdatalink(const avalue: tstringeditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbmemoedit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbmemoedit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbmemoedit.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
function tdbmemoedit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbmemoedit.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbmemoedit.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbintegeredit }

constructor tdbintegeredit.create(aowner: tcomponent);
begin
 fisnull:= true;
 fdatalink:= teditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbintegeredit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbintegeredit.modified;
begin
 fdatalink.modified;
 inherited;
end;

procedure tdbintegeredit.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
function tdbintegeredit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
{
procedure tdbintegeredit.setnullvalue;
begin
 inherited;
 fisnull:= true;
end;
}
function tdbintegeredit.internaldatatotext(const data): msestring;
begin
 if (@data = nil) and fisnull then begin
  result:= '';
 end
 else begin
  result:= inherited internaldatatotext(data);
 end;
end;

procedure tdbintegeredit.texttovalue(var accept: boolean; const quiet: boolean);
begin
 fisnull:= text = '';
 inherited;
end;

procedure tdbintegeredit.valuetofield;
begin
 if fisnull then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.field.asinteger:= value;
 end;
end;

procedure tdbintegeredit.fieldtovalue;
begin
 fisnull:= false;
 value:= fdatalink.field.asinteger;
end;

function tdbintegeredit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getintegerbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

procedure tdbintegeredit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbintegeredit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

function tdbintegeredit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbintegeredit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

function tdbintegeredit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tdbintegeredit.setdatalink(const avalue: teditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbintegeredit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbintegeredit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbintegeredit.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
function tdbintegeredit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbintegeredit.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbintegeredit.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbbooleanedit }

constructor tdbbooleanedit.create(aowner: tcomponent);
begin
 fdatalink:= teditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbbooleanedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbbooleanedit.checkvalue(const quiet: boolean = false): boolean;
begin
 result:= false;
 //dummy
end;
{
function tdbbooleanedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
procedure tdbbooleanedit.valuetofield;
begin
 fdatalink.field.asboolean:= value;
end;

procedure tdbbooleanedit.fieldtovalue;
begin
 value:= fdatalink.field.asboolean;
end;

function tdbbooleanedit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getbooleanbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdbbooleanedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbbooleanedit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbbooleanedit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbbooleanedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= booleanfields;
end;

procedure tdbbooleanedit.setdatalink(const avalue: teditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbbooleanedit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbbooleanedit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbbooleanedit.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
procedure tdbbooleanedit.modified;
begin
 fdatalink.modified;
 inherited;
end;

procedure tdbbooleanedit.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tdbbooleanedit.setmaxlength(const avalue: integer);
begin
 //dummy
end;

function tdbbooleanedit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbbooleanedit.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbbooleanedit.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbdataicon }

constructor tdbdataicon.create(aowner: tcomponent);
begin
 fdatalink:= teditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbdataicon.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbdataicon.checkvalue(const quiet: boolean = false): boolean;
begin
 result:= false;
 //dummy
end;
{
function tdbdataicon.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
procedure tdbdataicon.valuetofield;
begin
 if value = -1 then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.field.asinteger:= value;
 end;
end;

procedure tdbdataicon.fieldtovalue;
begin
 value:= fdatalink.field.asinteger;
end;

function tdbdataicon.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getintegerbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdbdataicon.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbdataicon.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbdataicon.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbdataicon.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

procedure tdbdataicon.setdatalink(const avalue: teditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbdataicon.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbdataicon.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbdataicon.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
procedure tdbdataicon.modified;
begin
 fdatalink.modified;
 inherited;
end;

procedure tdbdataicon.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tdbdataicon.setmaxlength(const avalue: integer);
begin
 //dummy
end;

function tdbdataicon.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbdataicon.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbdataicon.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbdatabutton }

constructor tdbdatabutton.create(aowner: tcomponent);
begin
 fdatalink:= teditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbdatabutton.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbdatabutton.checkvalue(const quiet: boolean = false): boolean;
begin
 result:= false;
 //dummy
end;
{
function tdbdatabutton.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
procedure tdbdatabutton.valuetofield;
begin
 if value = -1 then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.field.asinteger:= value;
 end;
end;

procedure tdbdatabutton.fieldtovalue;
begin
 value:= fdatalink.field.asinteger;
end;

function tdbdatabutton.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getintegerbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdbdatabutton.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbdatabutton.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbdatabutton.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbdatabutton.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

procedure tdbdatabutton.setdatalink(const avalue: teditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbdatabutton.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbdatabutton.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbdatabutton.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
procedure tdbdatabutton.modified;
begin
 if fresetting = 0 then begin
  fdatalink.modified;
 end;
 inherited;
end;

procedure tdbdatabutton.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tdbdatabutton.setmaxlength(const avalue: integer);
begin
 //dummy
end;

function tdbdatabutton.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbdatabutton.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbdatabutton.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbbooleaneditradio }

constructor tdbbooleaneditradio.create(aowner: tcomponent);
begin
 fdatalink:= teditwidgetdatalink.create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbbooleaneditradio.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbbooleaneditradio.checkvalue(const quiet: boolean = false): boolean;
begin
 result:= true;//dummy
end;

function tdbbooleaneditradio.docheckvalue(var avalue; 
                                               const quiet: boolean): boolean;
var
 widget: twidget;
 int1: integer;
 bo1: boolean;
begin
 if boolean(avalue) and (fparentwidget <> nil) then begin
  bo1:= false;
  for int1:= 0 to fparentwidget.widgetcount - 1 do begin
   widget:= fparentwidget.widgets[int1];
   if (widget is tdbbooleaneditradio) and (widget <> self) and
        (tcustombooleaneditradio(widget).group = group) then begin
    tdbbooleaneditradio(widget).docheckvalue(bo1,quiet);
   end;
  end;
 end;
 result:= inherited docheckvalue(avalue,quiet);
end;
{
procedure tdbbooleaneditradio.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
procedure tdbbooleaneditradio.modified;
begin
 if fresetting = 0 then begin
  fdatalink.modified;
 end;
 inherited;
end;

procedure tdbbooleaneditradio.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
function tdbbooleaneditradio.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
procedure tdbbooleaneditradio.valuetofield;
begin
 fdatalink.field.asboolean:= value;
end;

procedure tdbbooleaneditradio.fieldtovalue;
begin
 value:= fdatalink.field.asboolean;
end;

function tdbbooleaneditradio.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getbooleanbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdbbooleaneditradio.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbbooleaneditradio.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbbooleaneditradio.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbbooleaneditradio.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= booleanfields;
end;

procedure tdbbooleaneditradio.setdatalink(const avalue: teditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbbooleaneditradio.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbbooleaneditradio.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

procedure tdbbooleaneditradio.setmaxlength(const avalue: integer);
begin
 //dummy
end;

function tdbbooleaneditradio.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbbooleaneditradio.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbbooleaneditradio.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbrealedit }

constructor tdbrealedit.create(aowner: tcomponent);
begin
 fdatalink:= teditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbrealedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbrealedit.modified;
begin
 fdatalink.Modified;
 inherited;
end;

procedure tdbrealedit.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
function tdbrealedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
procedure tdbrealedit.valuetofield;
begin
 if value = emptyreal then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.field.asfloat:= value;
 end;
end;

procedure tdbrealedit.fieldtovalue;
begin
 if fdatalink.field.isnull then begin
  value:= emptyreal;
 end
 else begin
  value:= fdatalink.field.asfloat;
 end;
end;

function tdbrealedit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getrealtybuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdbrealedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbrealedit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbrealedit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbrealedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= realfields + integerfields;
end;

function tdbrealedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tdbrealedit.setdatalink(const avalue: teditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbrealedit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbrealedit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbrealedit.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
function tdbrealedit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbrealedit.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbrealedit.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbrealspinedit }

constructor tdbrealspinedit.create(aowner: tcomponent);
begin
 fdatalink:= teditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbrealspinedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbrealspinedit.modified;
begin
 fdatalink.Modified;
 inherited;
end;

procedure tdbrealspinedit.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
function tdbrealspinedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
procedure tdbrealspinedit.valuetofield;
begin
 if value = emptyreal then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.field.asfloat:= value;
 end;
end;

procedure tdbrealspinedit.fieldtovalue;
begin
 if fdatalink.field.isnull then begin
  value:= emptyreal;
 end
 else begin
  value:= fdatalink.field.asfloat;
 end;
end;

function tdbrealspinedit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getrealtybuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdbrealspinedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbrealspinedit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbrealspinedit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbrealspinedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= realfields + integerfields;
end;

function tdbrealspinedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tdbrealspinedit.setdatalink(const avalue: teditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbrealspinedit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbrealspinedit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbrealspinedit.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
function tdbrealspinedit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbrealspinedit.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbrealspinedit.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbslider }

constructor tdbslider.create(aowner: tcomponent);
begin
// fisdb:= true;
 fvaluerange:= 1;
 fdatalink:= teditwidgetdatalink.create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbslider.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbslider.checkvalue(const quiet: boolean = false): boolean;
begin
 result:= false;
 //dummy
end;
{
function tdbslider.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
procedure tdbslider.valuetofield;
begin
 if value = emptyreal then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.field.asfloat:= applyrange(value,valuerange,valuestart);
 end;
end;

procedure tdbslider.fieldtovalue;
begin
 if fdatalink.field.isnull then begin
  value:= emptyreal;
 end
 else begin
  value:= reapplyrange(fdatalink.field.asfloat,valuerange,valuestart);
 end;
end;

function tdbslider.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getrealtybuffer(fdatalink.field,arow);
  if result <> nil then begin
   preal(result)^:= reapplyrange(preal(result)^,valuerange,valuestart);
  end;
 end
 else begin
  result:= nil;
 end;
end;

function tdbslider.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbslider.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbslider.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbslider.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= realfields + integerfields;
end;

procedure tdbslider.setdatalink(const avalue: teditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbslider.readvaluescale(reader: treader);
begin
 valuerange:= valuescaletorange(reader);
end;

procedure tdbslider.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
 filer.defineproperty('valuescale',{$ifdef FPC}@{$endif}readvaluescale,nil,false);
end;

procedure tdbslider.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbslider.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
procedure tdbslider.modified;
begin
 fdatalink.modified;
 inherited;
end;

procedure tdbslider.doshortcut(var info: keyeventinfoty; const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

procedure tdbslider.setmaxlength(const avalue: integer);
begin
 //dummy
end;

function tdbslider.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbslider.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbslider.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbprogressbar }

constructor tdbprogressbar.create(aowner: tcomponent);
begin
// fisdb:= true;
 fdatalink:= teditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbprogressbar.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbprogressbar.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getrealtybuffer(fdatalink.field,arow);
  if result <> nil then begin
   preal(result)^:= reapplyrange(preal(result)^,valuerange,valuestart);
  end;
 end
 else begin
  result:= nil;
 end;
end;

procedure tdbprogressbar.valuetofield;
//var
// rea1: real;
begin
 if value = emptyreal then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.field.asfloat:= applyrange(value,valuerange,valuestart);
 end;
end;

procedure tdbprogressbar.fieldtovalue;
begin
 if fdatalink.field.isnull then begin
  value:= emptyreal;
 end
 else begin
  value:= reapplyrange(fdatalink.field.asfloat,valuerange,valuestart);
 end;
end;

procedure tdbprogressbar.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= realfields + integerfields;
end;

procedure tdbprogressbar.recchanged;
begin
 fdatalink.recordchanged(nil);
end;

function tdbprogressbar.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

function tdbprogressbar.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

function tdbprogressbar.checkvalue(const quiet: boolean = false): boolean;
begin
 result:= false; //dummy
end;

procedure tdbprogressbar.setdatalink(const avalue: teditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbprogressbar.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbprogressbar.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

procedure tdbprogressbar.setmaxlength(const avalue: integer);
begin
 //dummy
end;

function tdbprogressbar.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;

{ tdbdatetimeedit }

constructor tdbdatetimeedit.create(aowner: tcomponent);
begin
 fdatalink:= teditwidgetdatalink.Create(idbeditfieldlink(self));
 inherited;
end;

destructor tdbdatetimeedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbdatetimeedit.modified;
begin
 fdatalink.modified;
 inherited;
end;
{
function tdbdatetimeedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
end;
}
procedure tdbdatetimeedit.valuetofield;
begin
 if value = emptydatetime then begin
  fdatalink.field.clear;
 end
 else begin
  fdatalink.field.asdatetime:= value;
 end;
end;

procedure tdbdatetimeedit.fieldtovalue;
var
 da1: tdatetime;
begin
 if fdatalink.field.isnull then begin
  value:= 0;
 end
 else begin
  da1:= fdatalink.field.asdatetime;
  value:= da1;
 end;
end;
 
function tdbdatetimeedit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getdatetimebuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tdbdatetimeedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbdatetimeedit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbdatetimeedit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbdatetimeedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= datetimefields;
end;

function tdbdatetimeedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tdbdatetimeedit.setdatalink(const avalue: teditwidgetdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbdatetimeedit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tdbdatetimeedit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbdatetimeedit.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
function tdbdatetimeedit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbdatetimeedit.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbdatetimeedit.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}

{ tcustomdbenumedit }

constructor tcustomdbenumedit.create(aowner: tcomponent);
begin
 fdatalink:= tlookupeditdatalink.create(self,ldt_int32,idbeditfieldlink(self));
 inherited;
end;

destructor tcustomdbenumedit.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tcustomdbenumedit.modified;
begin
 fdatalink.modified;
 inherited;
end;

procedure tcustomdbenumedit.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
function tcustomdbenumedit.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
// frame.readonly:= oe_readonly in result;
end;
}
procedure tcustomdbenumedit.valuetofield;
begin
 if value = fvalueempty then begin
  fdatalink.field.clear;
  if fdatalink.fieldtext <> nil then begin
   fdatalink.fieldtext.clear;
  end;
 end
 else begin
  fdatalink.field.asinteger:= value;
  setasmsestring(text,fdatalink.fieldtext,fdatalink.utf8)
 end;
end;

procedure tcustomdbenumedit.fieldtovalue;
begin
 if fdatalink.field.isnull then begin
  value:= fvaluedefault1;
 end
 else begin
  value:= fdatalink.field.asinteger;
 end;
end;

function tcustomdbenumedit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).
                   getintegerbuffer(fdatalink.field,arow);
 end
 else begin
  result:= nil;
 end;
end;

function tcustomdbenumedit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tcustomdbenumedit.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tcustomdbenumedit.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tcustomdbenumedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

function tcustomdbenumedit.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tcustomdbenumedit.setdatalink(const avalue: tlookupeditdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tcustomdbenumedit.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tcustomdbenumedit.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tcustomdbenumedit.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
function tcustomdbenumedit.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;

function tcustomdbenumedit.getdropdownifilink: tifienumlinkcomp;
begin
 result:= fdropdownifilink;
end;

procedure tcustomdbenumedit.setdropdownifilink(const avalue: tifienumlinkcomp);
begin
 mseificomp.setifilinkcomp(idbifidropdownlistdatalink(self),avalue,
                                            tifilinkcomp(fdropdownifilink));
end;

procedure tcustomdbenumedit.dropdownsetifiserverintf(const aintf: iifiserver);
begin
 fdropdownifiserverintf:= aintf;
end;

procedure tcustomdbenumedit.dropdownifisetvalue(var avalue;
               var accept: boolean);
begin
 //dummy
end;
{
procedure tcustomdbenumedit.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tcustomdbenumedit.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbbooleantextedit }

constructor tdbbooleantextedit.create(aowner: tcomponent);
begin
 ftext_false:= 'F';
 ftext_true:= 'T';
 inherited;
 booltextchanged;
end;

procedure tdbbooleantextedit.booltextchanged;
begin
 with tenumdropdowncontroller(fdropdown) do begin
  cols.count:= 1;
  cols[0].count:= 2;
  cols[0][0]:= ftext_false;
  cols[0][1]:= ftext_true;
 end;
 formatchanged;
end;

procedure tdbbooleantextedit.settext_false(const avalue: msestring);
begin
 ftext_false:= avalue;
 booltextchanged;
end;

procedure tdbbooleantextedit.settext_true(const avalue: msestring);
begin
 ftext_true:= avalue;
 booltextchanged;
end;

procedure tdbbooleantextedit.valuetofield;
begin
 case inherited value of
  -1: fdatalink.field.clear;
  0: fdatalink.field.asboolean:= false;
  else fdatalink.field.asboolean:= true;
 end;
end;

procedure tdbbooleantextedit.fieldtovalue;
begin
 if fdatalink.field.isnull then begin
  inherited value:= -1;
 end
 else begin
  value:= fdatalink.field.asboolean;
 end;
end;

procedure tdbbooleantextedit.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= booleanfields;
end;

function tdbbooleantextedit.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).getbooleanbuffer(fdatalink.field,arow);
  if result = nil then begin
   result:= @fvaluedefault;
  end;
 end
 else begin
  result:= @fvaluedefault;
 end;
end;

function tdbbooleantextedit.getvalue: boolean;
begin
 result:= inherited value >= 0;
end;

procedure tdbbooleantextedit.setvalue(const avalue: boolean);
begin
 if avalue then begin
  inherited value:= 1;
 end
 else begin
  inherited value:= 0;
 end;
end;

{ tdbdropdowncol }

procedure tdbdropdowncol.setdatafield(const avalue: string);
begin
 if fdatafield <> avalue then begin
  fdatafield:= avalue;
  tcustomdbdropdownlistcontroller(fowner).fdatalink.updatefields;
 end;
end;

function tdbdropdowncol.getdataset(const aindex: integer): tdataset;
begin
 if fowner is tcustomdbdropdownlistcontroller then begin
  result:= tcustomdbdropdownlistcontroller(fowner).fdatalink.dataset;
 end
 else begin
  result:= nil;
 end;
end;

procedure tdbdropdowncol.getfieldtypes(out propertynames: stringarty; 
                  out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= textfields;
end;

{ tdbdropdowncols }

function tdbdropdowncols.getitems(const index: integer): tdbdropdowncol;
begin
 result:= tdbdropdowncol(inherited getitems(index));
end;

function tdbdropdowncols.getcolclass: dropdowncolclassty;
begin
 result:= tdbdropdowncol;
end;

{ tdropdowndatalink }

constructor tdropdowndatalink.create(
        const aowner: tcustomdbdropdownlistcontroller);
begin
 flastintegerkey:= -1;
 fowner:= aowner;
end;

procedure tdropdowndatalink.setvaluefieldname(const value: string);
begin
 if fvaluefieldname <> value then begin
  fvaluefieldname :=  value;
  updatefields;
 end;
end;

procedure tdropdowndatalink.setvaluefield(value: tfield);
begin
 if fvaluefield <> value then begin
  fvaluefield:= value;
  EditingChanged;
  RecordChanged(nil);
 end;
end;

procedure tdropdowndatalink.settextfield(value: tfield);
begin
 if ftextfield <> value then begin
  ftextfield:= value;
 end;
end;

procedure tdropdowndatalink.updatefields;

 procedure doerror(const afield: tfield);
 begin
  if afield <> nil then begin
   raise exception.create(dataset.name+
             ': No matching local index for "'+afield.fieldname+'".');
  end;
 end; //doerror

begin
 if Active and (fvaluefieldname <> '') then begin
  setvaluefield(datasource.dataset.fieldbyname(fvaluefieldname));
 end
 else begin
  setvaluefield(nil);
 end;
 with fowner do begin
  if active and (valuecol >= 0) and (valuecol < cols.count) and
            (tdbdropdowncol(cols[valuecol]).datafield <> '') then begin
   settextfield(datasource.dataset.fieldbyname(
             tdbdropdowncol(cols[valuecol]).datafield));
  end
  else begin
   settextfield(nil);
  end;
 end;
 fdataintf:= nil;
 fkeyindex:= -1;
 ftextindex:= -1;
 if active then begin
  if odb_directdata in fowner.foptionsdb then begin
   if getcorbainterface(dataset,typeinfo(idbdata),fdataintf) then begin
    if fvaluefield <> nil then begin
     fkeyindex:= fdataintf.getindex(fvaluefield);
    end;
    if ftextfield <> nil then begin
     ftextindex:= fdataintf.gettextindex(ftextfield,
              not (deo_casesensitive in fowner.foptions));
    end;
   end;
   if fkeyindex < 0 then begin
    doerror(fvaluefield);
   end;
   if ftextindex < 0 then begin
    doerror(ftextfield);
   end;
  end;
 end;
end;

procedure tdropdowndatalink.updatelookupvalue;
begin
 exclude(fstate,ddlnks_lookupvalid);
 with tdataedit1(fowner.fintf.getwidget) do begin
  if fgridintf <> nil then begin
   fgridintf.getcol.changed;
  end
  else begin
   valuetotext;
  end;
 end;
end;

procedure tdropdowndatalink.activechanged;
begin
 flastintegerkey:= -1;
 updatefields;
 inherited;
 updatelookupvalue;
 fowner.updatereadonlystate;
end;

procedure tdropdowndatalink.editingchanged;
begin
 inherited;
 if not editing then begin
  updatelookupvalue;
 end;
end;

procedure tdropdowndatalink.LayoutChanged;
begin
 updatefields;
 inherited;
end;

function tdropdowndatalink.getlookuptext(const key: integer): msestring;
var
 str1: string;
begin
 if flastintegerkey <> key then begin
  exclude(fstate,ddlnks_lookupvalid);
 end;
 if ddlnks_lookupvalid in fstate then begin
  result:= flookuptext;
 end
 else begin
  result:= '';
  if active and (fdscontroller <> nil) and 
         (fvaluefield <> nil) and (ftextfield <> nil) then begin
   flastintegerkey:= key;
   if fkeyindex >= 0 then begin
    result:= fdataintf.lookuptext(fkeyindex,key,false,
                                   tmsestringfield(ftextfield));
   end
   else begin
    dataset.disablecontrols;
    try
     str1:= dataset.bookmark;
     if fdscontroller.locate([fvaluefield],[key],[],[]) = loc_ok then begin
      result:= getasmsestring(ftextfield,utf8);
     end;
     dataset.bookmark:= str1;
    finally
     dataset.enablecontrols;
    end;
   end;
   include(fstate,ddlnks_lookupvalid);
  end;
  flookuptext:= result;
 end;
end;

function tdropdowndatalink.getlookuptext(const key: int64): msestring;
var
 str1: string;
begin
 if flastint64key <> key then begin
  exclude(fstate,ddlnks_lookupvalid);
 end;
 if ddlnks_lookupvalid in fstate then begin
  result:= flookuptext;
 end
 else begin
  result:= '';
  if active and (fdscontroller <> nil) and 
         (fvaluefield <> nil) and (ftextfield <> nil) then begin
   flastint64key:= key;
   if fkeyindex >= 0 then begin
    result:= fdataintf.lookuptext(fkeyindex,key,false,
                                   tmsestringfield(ftextfield));
   end
   else begin
    dataset.disablecontrols;
    try
     str1:= dataset.bookmark;
     if fdscontroller.locate([fvaluefield],[key],[],[]) = loc_ok then begin
      result:= getasmsestring(ftextfield,utf8);
     end;
     dataset.bookmark:= str1;
    finally
     dataset.enablecontrols;
    end;
   end;
   include(fstate,ddlnks_lookupvalid);
  end;
  flookuptext:= result;
 end;
end;

function tdropdowndatalink.getlookuptext(const key: msestring): msestring;
var
 str1: string;
begin
 if flaststringkey <> key then begin
  exclude(fstate,ddlnks_lookupvalid);
 end;
 if ddlnks_lookupvalid in fstate then begin
  result:= flookuptext;
 end
 else begin
  result:= '';
  if active and (fdscontroller <> nil) and 
         (fvaluefield <> nil) and (ftextfield <> nil) then begin
   flaststringkey:= key;
   if fkeyindex >= 0 then begin
    result:= fdataintf.lookuptext(fkeyindex,key,false,
                                   tmsestringfield(ftextfield));
   end
   else begin
    dataset.disablecontrols;
    try
     str1:= dataset.bookmark;
     if fdscontroller.locate([fvaluefield],[key],[],[]) = loc_ok then begin
      result:= getasmsestring(ftextfield,utf8);
     end;
     dataset.bookmark:= str1;
    finally
     dataset.enablecontrols;
    end;
   end;
   include(fstate,ddlnks_lookupvalid);
  end;
  flookuptext:= result;
 end;
end;

function tdropdowndatalink.getvalueasmsestring: msestring;
begin
 result:= '';
 if active and (fvaluefield <> nil) then begin
  result:= getasmsestring(fvaluefield,utf8);
 end;
end;

function tdropdowndatalink.getvalueasinteger: integer;
begin
 result:= 0;
 if active and (fvaluefield <> nil) then begin
  result:= fvaluefield.asinteger;
 end;
end;

function tdropdowndatalink.getvalueaslargeint: int64;
begin
 result:= 0;
 if active and (fvaluefield <> nil) then begin
  result:= fvaluefield.aslargeint;
 end;
end;

function tdropdowndatalink.gettextasmsestring: msestring;
begin
 result:= '';
 if active and (ftextfield <> nil) then begin
//  with fgridlink do begin
//   if fdataintf <> nil then begin
//    result:= fdataintf.getrowtext(ftextindex,fcurrentrecord,ftextfield);
//   end
//   else begin
    result:= getasmsestring(ftextfield,utf8);
//   end;
//  end;
 end;
end;

{ tdbdropdownstringcol }

constructor tdbdropdownstringcol.create(const agrid: tcustomgrid; 
                             const aowner: tgridarrayprop);
begin
 fdatalink:= tfielddatalink.create;
 inherited;
end;

destructor tdbdropdownstringcol.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbdropdownstringcol.getrowtext(const arow: integer): msestring;
var
 int1: integer;
begin
 if fdatalink.active and (fdatalink.field <> nil) then begin
  with tdbdropdownlist(fcellinfo.grid).fdatalink do begin
   if fdataintf <> nil then begin
    result:= fdataintf.getrowtext(ftextindex,arow+ffirstrecord,fdatalink.field);
   end
   else begin
    int1:= activerecord;
    activerecord:= arow;
    result:= fdatalink.asmsestring;
    activerecord:= int1;
   end;
  end;
 end
 else begin
  result:= '';
 end;
end;

{ tdropdownlistdatalink }

constructor tdropdownlistdatalink.create(const aowner: tcustomgrid;
               const aintf: igriddatalink; const adatalink: tdropdowndatalink);
begin
 with adatalink do begin
  self.fdataintf:= fdataintf;
  self.ftextindex:= ftextindex;
  self.fkeyindex:= fkeyindex;
 end;
 inherited create(aowner,aintf);
end;

procedure tdropdownlistdatalink.updatefocustext;
begin
 with tdbdropdownlist(fgrid) do begin
  if isdatacell(ffocusedcell) then begin
   feditor.text:= tdbdropdownstringcol(datacols[ffocusedcell.col]).
               getrowtext(ffocusedcell.row);
  end;
 end;
end;

procedure tdropdownlistdatalink.recordchanged(afield: tfield);
begin
 inherited;
 updatefocustext;
end;

function tdropdownlistdatalink.GetActiveRecord: Integer;
begin
 if fdataintf = nil then begin
  result:= inherited getactiverecord;
 end
 else begin
  result:= fcurrentrecord-ffirstrecord;
 end;
end;

procedure tdropdownlistdatalink.SetActiveRecord(Value: Integer);
begin
 if fdataintf = nil then begin
  inherited;
 end;
end;

function tdropdownlistdatalink.domoveby(const distance: integer): integer;
var
 int1: integer;
begin
 if fdataintf = nil then begin
  result:= inherited domoveby(distance);
 end
 else begin
  int1:= fcurrentrecord;
  setcurrentrecord(fcurrentrecord+distance,ropo_nearest);
  result:= fcurrentrecord-int1;
 end;
end;

procedure tdropdownlistdatalink.checkscrollbar;
var
 rea1: real;
 int1: integer;
begin
 if fdataintf = nil then begin
  inherited;
 end
 else begin
  int1:= dataset.recordcount-1;
  if int1 <= fgrid.rowcount then begin
   rea1:= 1;
  end
  else begin
   rea1:= fgrid.rowcount/(int1+1+fgrid.rowcount);
  end;
  fgrid.frame.sbvert.pagesize:= rea1;
  if int1 > 0 then begin
   rea1:= fcurrentrecord/int1;
  end
  else begin
   rea1:= 0;
  end;
  fgrid.frame.sbvert.value:= rea1;
 end;
end;

function tdropdownlistdatalink.scrollevent(sender: tcustomscrollbar;
               event: scrolleventty): boolean;
//var
// int1: integer;
begin
 if (fdataintf = nil) or (sender.tag <> 1) or 
             not (event in [sbe_thumbtrack,sbe_thumbposition]) then begin
  result:= inherited scrollevent(sender,event);
 end
 else begin
  result:= false;
  if (event <> sbe_thumbtrack) or (gdo_thumbtrack in foptions) then begin
   if self.active then begin
    setcurrentrecord(round(
                 fgrid.frame.sbvert.value * dataset.recordcount),ropo_nearest);      
    result:= true;
   end;
  end;
 end;
end;

procedure tdropdownlistdatalink.focuscell(var cell: gridcoordty);
begin
 if fdataintf = nil then begin
  inherited;
 end
 else begin
  if (cell.row >= 0) and (cell.row <> fgrid.row) then begin
   moveby(cell.row-fgrid.row);
  end;   
 end;
end;

procedure tdropdownlistdatalink.setcurrentrecord(const avalue: integer;
                           const arowpos: rowpositionty);
var
 int1,int2: integer;
begin
 if active then begin
  if avalue <> fcurrentrecord then begin
   int2:= fcurrentrecord;
   fcurrentrecord:= avalue;
   if fcurrentrecord < 0 then begin
    fcurrentrecord:= 0;
    if int2 = 0 then begin
     include(tcustomgrid1(fgrid).fstate1,gs1_scrolllimit);
    end;
   end;
   int1:= dataset.recordcount;
   if fcurrentrecord >= dataset.recordcount then begin
    fcurrentrecord:= int1 - 1;
    if int2 = fcurrentrecord then begin
     include(tcustomgrid1(fgrid).fstate1,gs1_scrolllimit);
    end;
   end;
   updatedatawindow(arowpos);
  end;
  recordchanged(nil);
 end;
end;

procedure tdropdownlistdatalink.updatedatawindow(const arowpos: rowpositionty);
var
 int1,int2: integer;
begin
 int1:= recordcount;
 case arowpos of
  ropo_top: begin
   ffirstrecord:= fcurrentrecord;
  end;
  ropo_bottom: begin
   ffirstrecord:= fcurrentrecord-int1+1;
  end;
  ropo_centered,ropo_centeredif: begin
   if (arowpos = ropo_centered) or 
           (fcurrentrecord < ffirstrecord) or 
           (fcurrentrecord >= ffirstrecord + int1) then begin
    ffirstrecord:= fcurrentrecord - int1 div 2;
   end;
  end;
 end;
 int2:= dataset.recordcount;
 if ffirstrecord + int1 > int2 then begin
  ffirstrecord:= int2 - int1;
 end;
 if ffirstrecord < 0 then begin
  ffirstrecord:= 0;
 end;
 if fcurrentrecord >= ffirstrecord+fmaxrowcount then begin
  ffirstrecord:= fcurrentrecord - fmaxrowcount + 1;
 end;
 if fcurrentrecord < ffirstrecord then begin
  ffirstrecord:= fcurrentrecord;
 end;
end;
{
function tdropdownlistdatalink.GetBufferCount: Integer;
begin
 if (fdataintf = nil) or (fmaxrowcount <= 0) then begin
  result:= inherited getbuffercount;
 end
 else begin
  result:= fmaxrowcount;
 end;   
end;
}
procedure tdropdownlistdatalink.SetBufferCount(Value: Integer);
begin
 if fdataintf = nil then begin
  inherited;
 end
 else begin
  fmaxrowcount:= value;
 end;   
end;

function tdropdownlistdatalink.getfirstrecord: integer;
begin
 if fdataintf = nil then begin
  result:= inherited getfirstrecord;
 end
 else begin
  result:= ffirstrecord;
 end;
end;

function tdropdownlistdatalink.getrecordcount: integer;
begin
 if fdataintf = nil then begin
  result:= inherited getrecordcount;
 end
 else begin
  result:= dataset.recordcount;
  if result > fmaxrowcount then begin
   result:= fmaxrowcount;
  end;
 end;
end;

function tdropdownlistdatalink.getasmsestring(const afield: tfield): msestring;
begin
 if fdataintf = nil then begin
  result:= msedb.getasmsestring(afield,utf8);
 end
 else begin
  result:= fdataintf.getrowtext(ftextindex,fcurrentrecord,afield);
 end;
end;

function tdropdownlistdatalink.getasinteger(const afield: tfield): integer;
begin
 if fdataintf = nil then begin
  result:= afield.asinteger;
 end
 else begin
  result:= fdataintf.getrowinteger(ftextindex,fcurrentrecord,afield);
 end;
end;

function tdropdownlistdatalink.getaslargeint(const afield: tfield): int64;
begin
 if fdataintf = nil then begin
  result:= afield.aslargeint;
 end
 else begin
  result:= fdataintf.getrowlargeint(ftextindex,fcurrentrecord,afield);
 end;
end;

procedure tdropdownlistdatalink.cellevent(var info: celleventinfoty);
var
 int1: integer;
begin
 int1:= info.newcell.row-activerecord;
 inherited;
 with info do begin
  if (eventkind = cek_enter) and active and (int1 = 0) and
          (newcell.col >= 0) then begin
   updatefocustext;
  end;
 end;
end;

{ tdbdropdownlist }

constructor tdbdropdownlist.create(
      const acontroller: tcustomdbdropdownlistcontroller; acols: tdropdowncols);
var
 int1: integer;
begin
 fdatalink:= tdropdownlistdatalink.create(self,igriddatalink(self),
                                                    acontroller.fdatalink);
 inherited create(acontroller,acols,nil);
 include(fstate,gs_isdb);
 fzebra_step:= 0;
 fdatalink.datasource:= acontroller.datasource;
 fdatalink.buffercount:= acontroller.dropdownrowcount;
 int1:= fdatalink.recordcount;
 if int1 < 0 then begin
  int1:= 0;
 end;
 rowcount:= int1;
end;

destructor tdbdropdownlist.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbdropdownlist.pagedown(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(rowcount-1);
end;

procedure tdbdropdownlist.pageup(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(-rowcount+1);
end;

procedure tdbdropdownlist.wheeldown(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(wheelheight);
end;

procedure tdbdropdownlist.wheelup(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(-wheelheight);
end;

procedure tdbdropdownlist.rowdown(const action: focuscellactionty = fca_focusin;
                                       const nowrap: boolean = false);
begin
 fdatalink.MoveBy(1);
end;

procedure tdbdropdownlist.rowup(const action: focuscellactionty = fca_focusin;
                                       const nowrap: boolean = false);
begin
 fdatalink.MoveBy(-1);
end;

procedure tdbdropdownlist.internalcreateframe;
begin
 tdbgridframe.create(iscrollframe(self),self,iautoscrollframe(self));
end;

procedure tdbdropdownlist.createdatacol(const index: integer;
                                                     out item: tdatacol);
begin
 item:= tdbdropdownstringcol.create(self,fdatacols);
end;

procedure tdbdropdownlist.initcols(const acols: tdropdowncols);
var
 int1: integer;
 dbstrcol1: tdbdropdownstringcol;
 datasource1: tdatasource;
begin
 inherited;
 datasource1:= tcustomdbdropdownlistcontroller(fcontroller).datasource;
 for int1:= 0 to fdatacols.count - 1 do begin
  dbstrcol1:= tdbdropdownstringcol(fdatacols[int1]);
  with tdbdropdowncol(acols[int1]) do begin
   dbstrcol1.fdatalink.datasource:= datasource1;
   dbstrcol1.fdatalink.fieldname:= datafield;
  end;
 end;
end;

procedure tdbdropdownlist.docellevent(var info: celleventinfoty);
begin
 inherited;
 fdatalink.cellevent(info);
end;

procedure tdbdropdownlist.scrollevent(sender: tcustomscrollbar;
                                                     event: scrolleventty);
begin
 if not fdatalink.scrollevent(sender,event) then begin
  inherited;
 end;
end;

function tdbdropdownlist.locate(const filter: msestring): boolean;
var
 row1: integer;
begin
 result:= false;
 if (datacols.count > 0) then begin
  with tdbdropdownstringcol(datacols[0]).fdatalink do begin
   if (dscontroller <> nil) and (field <> nil) then begin
    with tcustomdbdropdownlistcontroller(fcontroller).fdatalink do begin
     if ftextindex >= 0 then begin
      result:= fdataintf.findtext(ftextindex,filter,row1);
      if result then begin
       fdatalink.setcurrentrecord(row1,ropo_top);
      end;
     end
     else begin
      result:= dscontroller.locate([field],[filter],[],
                                     [[lko_caseinsensitive]]) = loc_ok;
      if not result then begin
       result:= dscontroller.locate([field],[filter],[],
                          [[lko_caseinsensitive,lko_partialkey]]) = loc_ok;
      end;
      if result then begin
       dataset.resync([rmcenter]);
      end;
     end;
    end;
   end;
  end;
 end;
 if not result then begin
  focuscell(makegridcoord(ffocusedcell.col,-1));
 end;
end;

procedure tdbdropdownlist.dopaint(const acanvas: tcanvas);
begin
 inherited;
 fdatalink.painted;
end;

procedure tdbdropdownlist.dohide;
begin
 fdatalink.painted;
 inherited;
end;

function tdbdropdownlist.getdbindicatorcol: integer;
begin
 result:= 0; //none
end;

procedure tdbdropdownlist.setnavigator(const avalue: tdbnavigator);
begin
 //dummy
end;

function tdbdropdownlist.getdatalink(): tgriddatalink;
begin
 result:= fdatalink;
end;

function tdbdropdownlist.getassistiveflags(): assistiveflagsty;
begin
 result:= inherited getassistiveflags() + [asf_db];
end;

procedure tdbdropdownlist.setactiveitem(const aitemindex: integer);
begin
 inherited;
 fdatalink.recordchanged(nil);
end;

{ tcustomdbdropdownlistcontroller }

constructor tcustomdbdropdownlistcontroller.create(const intf: idbdropdownlist;
                      const aisstringkey: boolean);
begin
 if aisstringkey then begin
  include(fstate,dcs_isstringkey);
 end;
// fisstringkey:= aisstringkey;
 foptionsdatalink:= defaultdropdowndatalinkoptions;
 fdatalink:= tdropdowndatalink.create(self);
 inherited create(intf);
 options:= defaultdbdropdownoptions;
end;

destructor tcustomdbdropdownlistcontroller.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tcustomdbdropdownlistcontroller.dropdown;
begin
 tdropdowncols1(fcols).fitemindex:= -1;
 inherited; 
end;

function tcustomdbdropdownlistcontroller.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tcustomdbdropdownlistcontroller.setdatasource(const avalue: tdatasource);
begin
 fdatalink.datasource:= avalue;
end;

procedure tcustomdbdropdownlistcontroller.setkeyfield(const avalue: string);
begin
 fdatalink.valuefieldname:= avalue;
end;

function tcustomdbdropdownlistcontroller.getkeyfield: string;
begin
 result:= fdatalink.valuefieldname;
end;

function tcustomdbdropdownlistcontroller.getcols: tdbdropdowncols;
begin
 result:= tdbdropdowncols(fcols);
end;

procedure tcustomdbdropdownlistcontroller.setcols(const avalue: tdbdropdowncols);
begin
 fcols.assign(avalue);
end;

function tcustomdbdropdownlistcontroller.getbuttonframeclass():
                                              dropdownbuttonframeclassty;
begin
 result:= tdropdownmultibuttonframe;
end;

procedure tcustomdbdropdownlistcontroller.valuecolchanged;
begin
 inherited;
 fdatalink.updatefields;
end;

function tcustomdbdropdownlistcontroller.getdropdowncolsclass: dropdowncolsclassty;
begin
 result:= tdbdropdowncols;
end;

function tcustomdbdropdownlistcontroller.createdropdownlist: tdropdownlist;
type
 pmsestringaarty = array of pmsestringaty;
var
 int1,int2: integer;
 datas: tdataset;
 ar1: fieldarty;
 ar2: pmsestringaarty;
 bm: string;
begin
 datas:= fdatalink.dataset;
 if (datas <> nil) and (odb_closedataset in foptionsdb) then begin
  datas.active:= true;
 end;
 if odb_copyitems in foptionsdb then begin
  fcols.clear;
  datas:= fdatalink.dataset;
  if (datas <> nil) and datas.active then begin
   setlength(ar1,fcols.count);
   setlength(ar2,fcols.count);
   for int1:= 0 to high(ar1) do begin
    setlength(fbookmarks,datas.recordcount);
    with cols[int1] do begin
     count:= length(fbookmarks);     //max
     ar2[int1]:= datapo;
     ar1[int1]:= datas.fieldbyname(datafield);
    end;
   end;
   datas.disablecontrols;
   try
    bm:= datas.bookmark;
    try
     int2:= 0;
     datas.first;
     while not datas.eof do begin
      fbookmarks[int2]:= datas.bookmark;
      for int1:= 0 to high(ar1) do begin
       ar2[int1]^[int2]:= msedb.getasmsestring(ar1[int1],fdatalink.utf8);
      end; 
      inc(int2);
      datas.next;
     end;
     for int1:= 0 to cols.count-1 do begin
      cols[int1].count:= int2;
     end;
     setlength(fbookmarks,int2);
    finally
     datas.bookmark:= bm;
    end;   
   finally
    datas.enablecontrols;
   end;
  end;
  result:= tdropdownlist.create(self,fcols,nil);
 end
 else begin
  result:= tdbdropdownlist.create(self,fcols);
  with tdbdropdownlist(result) do begin
   fdatalink.options:= foptionsdatalink;
   if gdo_propscrollbar in fdatalink.options then begin
    with frame.sbvert do begin
     pagesize:= 1;
    end;
   end;
  end;
 end;
end;

function tcustomdbdropdownlistcontroller.candropdown: boolean;
begin
 result:= inherited candropdown and 
           (fdatalink.active or 
           (odb_opendataset in foptionsdb) and (fdatalink.dataset <> nil));
end;

procedure tcustomdbdropdownlistcontroller.doafterclosedropdown;
begin
 inherited;
 if (odb_closedataset in foptionsdb) and fdatalink.active then begin
  fdatalink.dataset.active:= false;
 end;
end;

procedure tcustomdbdropdownlistcontroller.itemselected(const index: integer;
                                                          const akey: keyty);
begin
 if index < 0 then begin
  if index = -2 then begin
   tdropdowncols1(fcols).fitemindex:= fintf.getvalueempty;
  end;
 end
 else begin
  if odb_copyitems in foptionsdb then begin
   fdatalink.dataset.bookmark:= fbookmarks[index];
  end;
  tdropdowncols1(fcols).fitemindex:= index;
 end;
 if odb_copyitems in foptionsdb then begin
  cols.clear;
  fbookmarks:= nil;
 end;
 idbdropdownlist(fintf).recordselected(index,akey);
end;

procedure tcustomdbdropdownlistcontroller.getfieldtypes(out propertynames: stringarty; 
                    out fieldtypes: fieldtypesarty);
begin
 setlength(propertynames,1);
 propertynames[0]:= 'keyfield';
 setlength(fieldtypes,1);
 if dcs_isstringkey in fstate then begin
  fieldtypes[0]:= textfields;
 end
 else begin
  fieldtypes[0]:= integerfields;
 end; 
end;

function tcustomdbdropdownlistcontroller.getdataset(const aindex: integer): tdataset;
begin
 result:= fdatalink.dataset;
end;

procedure tcustomdbdropdownlistcontroller.setoptionsdb(const avalue: optionsdbty);
//var
// optionsbefore: optionsdbty;
begin
 if avalue <> foptionsdb then begin
  foptionsdb:= avalue;
  updatereadonlystate;
 end; 
end;

function tcustomdbdropdownlistcontroller.getasmsestring(const afield: tfield;
               const utf8: boolean): msestring;
begin
 if afield = nil then begin
  result:= '';
 end
 else begin
  if (fdropdownlist is tdbdropdownlist) then begin
   result:= tdbdropdownlist(fdropdownlist).fdatalink.getasmsestring(afield);
  end
  else begin
   result:= msedb.getasmsestring(afield,utf8);
  end;
 end;
end;

function tcustomdbdropdownlistcontroller.getasinteger(const afield: tfield): integer;
begin
 if afield = nil then begin
  result:= 0;
 end
 else begin
  if (fdropdownlist is tdbdropdownlist) then begin
   result:= tdbdropdownlist(fdropdownlist).fdatalink.getasinteger(afield);
  end
  else begin
   result:= afield.asinteger;
  end;
 end;
end;

function tcustomdbdropdownlistcontroller.getaslargeint(const afield: tfield): int64;
begin
 if afield = nil then begin
  result:= 0;
 end
 else begin
  if (fdropdownlist is tdbdropdownlist) then begin
   result:= tdbdropdownlist(fdropdownlist).fdatalink.getaslargeint(afield);
  end
  else begin
   result:= afield.aslargeint;
  end;
 end;
end;

{ tdbenumeditdb }

function tdbenumeditdb.getdropdown: tdbdropdownlistcontroller;
begin
{$warnings off}
 result:= tdbdropdownlistcontroller(inherited dropdown);
{$warnings on}
end;

procedure tdbenumeditdb.setdropdown(const avalue: tdbdropdownlistcontroller);
begin
 inherited dropdown.assign(avalue);
end;

function tdbenumeditdb.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tdbdropdownlistcontroller.create(idbdropdownlist(self),false);
end;

procedure tdbenumeditdb.recordselected(const arecordnum: integer;
                                                          const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tdbdropdownlistcontroller(fdropdown) do begin
//   text:= getasmsestring(fdatalink.textfield,fdatalink.utf8);
//   tdropdowncols1(fcols).fitemindex:= fdatalink.valuefield.asinteger
   text:= getasmsestring(fdatalink.textfield,fdatalink.utf8);
   tdropdowncols1(fcols).fitemindex:= getasinteger(fdatalink.valuefield);
  end; 
  bo1:= checkvalue;
 end
 else begin
  if arecordnum = -2 then begin
   bo1:= checkvalue; 
  end
  else begin
   feditor.undo;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tdbenumeditdb.internaldatatotext(const data): msestring;
var
 int1: integer;
begin
 if @data = nil then begin
  int1:= value;  
 end
 else begin
  int1:= integer(data);
 end;
 result:= tdbdropdownlistcontroller(fdropdown).fdatalink.getlookuptext(int1);
end;

{ tdbdropdownlisteditdb }

function tdbdropdownlisteditdb.getdropdown: tdropdownlistcontrollerdb;
begin
{$warnings off}
 result:= tdropdownlistcontrollerdb(inherited dropdown);
{$warnings on}
end;

procedure tdbdropdownlisteditdb.setdropdown(const avalue: tdropdownlistcontrollerdb);
begin
 inherited dropdown.assign(avalue);
end;

function tdbdropdownlisteditdb.createdropdowncontroller: 
                                                    tcustomdropdowncontroller;
begin
 result:= tdropdownlistcontrollerdb.create(idbdropdownlist(self),false);
end;

procedure tdbdropdownlisteditdb.recordselected(const arecordnum: integer;
                                                            const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tdropdownlistcontrollerdb(fdropdown) do begin
   setdropdowntext(getasmsestring(fdatalink.textfield,fdatalink.utf8),true,
                                              false,akey);
  end; 
  exit;
 end
 else begin
  if arecordnum = -2 then begin
   bo1:= checkvalue; 
  end
  else begin
   if deo_selectonly in dropdown.options then begin
    feditor.undo;
   end;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

{ tdropdownlisteditdb }

function tdropdownlisteditdb.getdropdown: tdropdownlistcontrollerdb;
begin
{$warnings off}
 result:= tdropdownlistcontrollerdb(inherited dropdown);
{$warnings on}
end;

procedure tdropdownlisteditdb.setdropdown(const avalue: tdropdownlistcontrollerdb);
begin
 inherited dropdown.assign(avalue);
end;

function tdropdownlisteditdb.createdropdowncontroller: 
                                                    tcustomdropdowncontroller;
begin
 result:= tdropdownlistcontrollerdb.create(idbdropdownlist(self),false);
end;

procedure tdropdownlisteditdb.recordselected(const arecordnum: integer;
                                                            const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tdropdownlistcontrollerdb(fdropdown) do begin
   setdropdowntext(getasmsestring(fdatalink.textfield,fdatalink.utf8),true,
                                              false,akey);
  end; 
  exit;
 end
 else begin
  if arecordnum = -2 then begin
   bo1:= checkvalue; 
  end
  else begin
   if deo_selectonly in dropdown.options then begin
    feditor.undo;
   end;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

{ tdbdropdownlisteditlb }

function tdbdropdownlisteditlb.getdropdown: tdropdownlistcontrollerlb;
begin
{$warnings off}
 result:= tdropdownlistcontrollerlb(inherited dropdown);
{$warnings on}
end;

procedure tdbdropdownlisteditlb.setdropdown(
                                   const avalue: tdropdownlistcontrollerlb);
begin
 inherited dropdown.assign(avalue);
end;

function tdbdropdownlisteditlb.createdropdowncontroller: 
                                                    tcustomdropdowncontroller;
begin
 result:= tdropdownlistcontrollerlb.create(ilbdropdownlist(self));
end;

procedure tdbdropdownlisteditlb.recordselected(const arecordnum: integer;
                                                            const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tdropdownlistcontrollerlb(fdropdown) do begin
   setdropdowntext(flookupbuffer.textvaluephys(cols[0].ffieldno,arecordnum),
                                              true,false,akey);
  end; 
  exit;
 end
 else begin
  if arecordnum = -2 then begin
   bo1:= checkvalue; 
  end
  else begin
   if deo_selectonly in dropdown.options then begin
    feditor.undo;
   end;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tdbdropdownlisteditlb.getlbkeydatakind: lbdatakindty;
begin
 result:= lbdk_none;
end;

{ tdropdownlisteditlb }

function tdropdownlisteditlb.getdropdown: tdropdownlistcontrollerlb;
begin
{$warnings off}
 result:= tdropdownlistcontrollerlb(inherited dropdown);
{$warnings on}
end;

procedure tdropdownlisteditlb.setdropdown(
                                   const avalue: tdropdownlistcontrollerlb);
begin
 inherited dropdown.assign(avalue);
end;

function tdropdownlisteditlb.createdropdowncontroller: 
                                                    tcustomdropdowncontroller;
begin
 result:= tdropdownlistcontrollerlb.create(ilbdropdownlist(self));
end;

procedure tdropdownlisteditlb.recordselected(const arecordnum: integer;
                                                            const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tdropdownlistcontrollerlb(fdropdown) do begin
   setdropdowntext(flookupbuffer.textvaluephys(cols[0].ffieldno,arecordnum),
                                              true,false,akey);
  end; 
  exit;
 end
 else begin
  if arecordnum = -2 then begin
   bo1:= checkvalue; 
  end
  else begin
   if deo_selectonly in dropdown.options then begin
    feditor.undo;
   end;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tdropdownlisteditlb.getlbkeydatakind: lbdatakindty;
begin
 result:= lbdk_none;
end;

{ tenumeditdb }

function tenumeditdb.getdropdown: tdbdropdownlistcontroller;
begin
{$warnings off}
 result:= tdbdropdownlistcontroller(inherited dropdown);
{$warnings on}
end;

procedure tenumeditdb.setdropdown(const avalue: tdbdropdownlistcontroller);
begin
 inherited dropdown.assign(avalue);
end;

function tenumeditdb.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tdbdropdownlistcontroller.create(idbdropdownlist(self),false);
end;

procedure tenumeditdb.recordselected(const arecordnum: integer; const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tdbdropdownlistcontroller(fdropdown) do begin
   text:= getasmsestring(fdatalink.textfield,fdatalink.utf8);
   tdropdowncols1(fcols).fitemindex:= getasinteger(fdatalink.valuefield);
  end; 
  bo1:= checkvalue;
 end
 else begin
  if arecordnum = -2 then begin
   bo1:= checkvalue; 
  end
  else begin
   feditor.undo;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tenumeditdb.internaldatatotext(const data): msestring;
var
 int1: integer;
begin
 if @data = nil then begin
  int1:= value;  
 end
 else begin
  int1:= integer(data);
 end;
 result:= tdbdropdownlistcontroller(fdropdown).fdatalink.getlookuptext(int1);
end;

{ tdbkeystringeditdb }

function tdbkeystringeditdb.getdropdown: tdbdropdownlistcontroller;
begin
{$warnings off}
 result:= tdbdropdownlistcontroller(inherited dropdown);
{$warnings on}
end;

procedure tdbkeystringeditdb.setdropdown(const avalue: tdbdropdownlistcontroller);
begin
 inherited dropdown.assign(avalue);
end;

function tdbkeystringeditdb.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tdbdropdownlistcontroller.create(idbdropdownlist(self),true);
end;

procedure tdbkeystringeditdb.recordselected(const arecordnum: integer;
                                                            const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tdbdropdownlistcontroller(fdropdown) do begin
   text:= getasmsestring(fdatalink.textfield,fdatalink.utf8);
   tdropdowncols1(fcols).fkeyvalue:= getasmsestring(fdatalink.valuefield,
                                                         fdatalink.utf8);
  end; 
  bo1:= checkvalue;
 end
 else begin
  if arecordnum = -2 then begin
   bo1:= checkvalue; 
  end
  else begin
   feditor.undo;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tdbkeystringeditdb.internaldatatotext(const data): msestring;
var
 mstr1: msestring;
begin
 if @data = nil then begin
  mstr1:= value;  
 end
 else begin
  mstr1:= msestring(data);
 end;
 result:= tdbdropdownlistcontroller(fdropdown).fdatalink.getlookuptext(mstr1);
end;

{ tkeystringeditdb }

function tkeystringeditdb.getdropdown: tdbdropdownlistcontroller;
begin
{$warnings off}
 result:= tdbdropdownlistcontroller(inherited dropdown);
{$warnings on}
end;

procedure tkeystringeditdb.setdropdown(const avalue: tdbdropdownlistcontroller);
begin
 inherited dropdown.assign(avalue);
end;

function tkeystringeditdb.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tdbdropdownlistcontroller.create(idbdropdownlist(self),true);
end;

procedure tkeystringeditdb.recordselected(const arecordnum: integer;
                                                    const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tdbdropdownlistcontroller(fdropdown) do begin
   text:= getasmsestring(fdatalink.textfield,fdatalink.utf8);
   tdropdowncols1(fcols).fkeyvalue:= getasmsestring(fdatalink.valuefield,
                                                      fdatalink.utf8);
  end; 
  bo1:= checkvalue;
 end
 else begin
  if arecordnum = -2 then begin
   bo1:= checkvalue; 
  end
  else begin
   feditor.undo;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tkeystringeditdb.internaldatatotext(const data): msestring;
var
 mstr1: msestring;
begin
 if @data = nil then begin
  mstr1:= value;  
 end
 else begin
  mstr1:= msestring(data);
 end;
 result:= tdbdropdownlistcontroller(fdropdown).fdatalink.getlookuptext(mstr1);
end;

{ tgriddatalink }

constructor tgriddatalink.create(const aowner: tcustomgrid;
                                            const aintf: igriddatalink);
begin
 fintf:= aintf;
 fgrid:= aowner;
 include(tcustomgrid1(fgrid).fstate,gs_isdb);
 iificlient(aowner).setifiserverintf(iifidataserver(self));
 inherited create;
 options:= defaultgriddatalinkoptions;
// visualcontrol:= true; 
end;

destructor tgriddatalink.destroy;
begin
 inc(fdatasetchangedlock);
 inherited;
 fobjectlinker.free;
end;

procedure tgriddatalink.setfieldname_state(const avalue: string);
begin
 if ffieldname_state <> avalue then begin
  ffieldname_state:= avalue;
  updatefields;
 end;
end;

procedure tgriddatalink.setfieldname_color(const avalue: string);
begin
 if ffieldname_color <> avalue then begin
  ffieldname_color:= avalue;
  updatefields;
 end;
end;

procedure tgriddatalink.setfieldname_font(const avalue: string);
begin
 if ffieldname_font <> avalue then begin
  ffieldname_font:= avalue;
  updatefields;
 end;
end;

procedure tgriddatalink.setfieldname_readonly(const avalue: string);
begin
 if ffieldname_readonly <> avalue then begin
  ffieldname_readonly:= avalue;
  updatefields;
 end;
end;

procedure tgriddatalink.setfieldname_merged(const avalue: string);
begin
 if ffieldname_merged <> avalue then begin
  ffieldname_merged:= avalue;
  updatefields;
 end;
end;

procedure tgriddatalink.setfieldname_selected(const avalue: string);
begin
 if ffieldname_selected <> avalue then begin
  ffieldname_selected:= avalue;
  updatefields;
 end;
end;

function tgriddatalink.getfirstrecord: integer;
begin
 result:= inherited firstrecord;
end;

procedure tgriddatalink.doupdaterowdata(const row: integer);

 procedure fieldtorowstate(const arow: integer);
 var
  int1: integer;
  longword1: longword;
 begin
  if field_state <> nil then begin
   if field_state.isnull then begin
    fgrid.rowcolorstate[arow]:= -1;
    fgrid.rowfontstate[arow]:= -1;
    fgrid.rowreadonlystate[arow]:= false;
   end
   else begin
    int1:= field_state.asinteger;
    fgrid.rowcolorstate[arow]:= rowstatenumty(int1 and $7f);
    fgrid.rowreadonlystate[arow]:= rowstatenumty(int1 and $80) <> 0;
    fgrid.rowfontstate[arow]:= rowstatenumty((int1 shr 8) and $7f);
   end;
  end;
  if (field_color <> nil) then begin
   if field_color.isnull then begin
    fgrid.rowcolorstate[arow]:= -1;
   end
   else begin
    fgrid.rowcolorstate[arow]:= field_color.asinteger;
   end;
  end;
  if (field_font <> nil) then begin
   if field_font.isnull then begin
    fgrid.rowfontstate[arow]:= -1;
   end
   else begin
    fgrid.rowfontstate[arow]:= field_font.asinteger;
   end;
  end;
  if (field_readonly <> nil) then begin
   fgrid.rowreadonlystate[arow]:= field_readonly.asboolean;
  end;
  if field_merged <> nil then begin
   if gdls_booleanmerged in fstate then begin
    if field_merged.asboolean then begin
     longword1:= mergedcolall;
    end
    else begin
     longword1:= 0;
    end;
   end
   else begin
    longword1:= longword(field_merged.asinteger);
   end;
   with tdatacols1(fgrid.datacols) do begin
    if rowstate.merged[arow] <> longword1 then begin
     rowstate.merged[arow]:= longword1;
     mergechanged(arow);
    end;
   end;
  end;
  if field_selected <> nil then begin
   if gdls_booleanselected in fstate then begin
    if field_selected.asboolean then begin
     longword1:= wholerowselectedmask;
    end
    else begin
     longword1:= 0;
    end;
   end
   else begin
    longword1:= longword(field_selected.asinteger);
   end;
   with tdatacols1(fgrid.datacols) do begin
    if rowstate.selected[arow] <> longword1 then begin
     rowstate.selected[arow]:= longword1;
     fgrid.invalidaterow(arow);
    end;
   end;
  end;
 end;
 
var
 int1,int2: integer;
 dataset1: tdataset;
 buffercount1: int32;
begin
 if (fgrid.componentstate * [csloading,csdesigning,csdestroying] = []) and 
                 (row < fgrid.rowcount) then begin
  dataset1:= dataset;
  if dataset1 <> nil then begin
   buffercount1:= buffercount;
   if gdls_hasrowstatefield in fstate then begin
    if row >= 0 then begin
     if row < buffercount1 then begin
      fieldtorowstate(row);
     end;
    end
    else begin
     int2:= activerecord;
     try
      for int1:= 0 to fgrid.rowhigh do begin
       if int1 >= buffercount1 then begin
        break; //buffer invalid
       end;
       activerecord:= int1;
       fieldtorowstate(int1);
      end;
     finally
      activerecord:= int2;
     end;
    end;
   end;
   if assigned(fonupdaterowdata) then begin
    if row >= 0 then begin
     fonupdaterowdata(fgrid,row,dataset1);
    end
    else begin
     int2:= activerecord;
     try
      for int1:= 0 to fgrid.rowhigh do begin
       if int1 >= buffercount1 then begin
        break; //buffer invalid
       end;
       activerecord:= int1;
       fonupdaterowdata(fgrid,int1,dataset1);
      end;
     finally
      activerecord:= int2;
     end;
    end;
   end;   
   tdatacols1(fgrid.datacols).invalidatemaxsize(-1);
  end;
 end;
 if row < 0 then begin
  fgridinvalidated:= false; //grid possibly invisible -> no painted call
 end;
end;

function tgriddatalink.hasdata: boolean;
begin
 result:= active and datasource.enabled and (recordcount > 0);
end;

procedure tgriddatalink.readdatasource(reader: treader);
begin
 treader1(reader).readpropvalue(self,
          getpropinfo(typeinfo(tgriddatalink),'datasource'));
end;

procedure tgriddatalink.fixupproperties(filer: tfiler);
begin
 inherited;
 filer.defineproperty('datasource',{$ifdef FPC}@{$endif}readdatasource,nil,false);
               //move values to datalink
end;

procedure tgriddatalink.readdatafield(reader: treader);
begin
 fieldname_state:= reader.readstring;
end;

procedure tgriddatalink.defineproperties(filer: tfiler);
begin
 filer.defineproperty('datafield',{$ifdef FPC}@{$endif}readdatafield,nil,false);
end;

function tgriddatalink.getrowfieldisnull(const afield: tfield; 
                             const row: integer): boolean;
var
 rowinfo: gridrowinfoty;
begin
 result:= true;
 if (afield <> nil) and hasdata and begingridrow(row,rowinfo) then begin
  result:= afield.isnull;
  endgridrow(rowinfo);
 end;
end;

function tgriddatalink.getansistringbuffer(const afield: tfield;
                                                  const row: integer): pointer;
var
 rowinfo: gridrowinfoty;
begin
 result:= nil;
 if (afield <> nil) and hasdata and begingridrow(row,rowinfo) then begin
  if not afield.isnull then begin
   result:= @fansistringbuffer;
   fansistringbuffer:= afield.asstring;
  end;
  endgridrow(rowinfo);
 end;
end;

function tgriddatalink.getstringbuffer(const afield: tfield;
                      const row: integer): pointer;
var
 rowinfo: gridrowinfoty;
begin
 result:= nil;
 if (afield <> nil) and hasdata and begingridrow(row,rowinfo) then begin
  if not afield.isnull then begin
   result:= @fstringbuffer;
   if afield is tmsestringfield then begin
    fstringbuffer:= tmsestringfield(afield).asmsestring;
   end
   else begin
    if utf8 and (afield.datatype in textfields) then begin
     fstringbuffer:= utf8tostringansi(afield.asstring);
    end
    else begin
     fstringbuffer:= msestring(afield.asstring);
    end;
   end;
  end;
  endgridrow(rowinfo);
 end;
end;

function tgriddatalink.getdisplaystringbuffer(const afield: tfield;
                      const row: integer): pointer;
var
 rowinfo: gridrowinfoty;
begin
 result:= nil;
 if (afield <> nil) and hasdata and begingridrow(row,rowinfo) then begin
  if not afield.isnull then begin
   result:= @fstringbuffer;
   if afield is tmsestringfield then begin
    fstringbuffer:= tmsestringfield(afield).asmsestring;
   end
   else begin
    if afield is tmsememofield then begin
     fstringbuffer:= tmsememofield(afield).asmsestring;
    end
    else begin
     if utf8 and (afield.datatype in textfields) then begin
      fstringbuffer:= utf8tostringansi(afield.displaytext);
     end
     else begin
      fstringbuffer:= msestring(afield.displaytext);
     end;
    end;
   end;
  end;
  endgridrow(rowinfo);
 end;
end;

function tgriddatalink.getbooleanbuffer(const afield: tfield; 
                                             const row: integer): pointer;
var
 rowinfo: gridrowinfoty;
begin
 result:= nil;
 if (afield <> nil) and hasdata and begingridrow(row,rowinfo) then begin
  if not afield.isnull then begin
   result:= @fintegerbuffer;
   fintegerbuffer:= integer(afield.asboolean);
  end;
  endgridrow(rowinfo);
 end;
end;

function tgriddatalink.getintegerbuffer(const afield: tfield;
                     const row: integer): pointer;
var
 rowinfo: gridrowinfoty;
begin
 result:= nil;
 if (afield <> nil) and hasdata and begingridrow(row,rowinfo) then begin
  if not afield.isnull then begin
   result:= @fintegerbuffer;
   fintegerbuffer:= afield.asinteger;
  end;
  endgridrow(rowinfo);
 end;
end;

function tgriddatalink.getint64buffer(const afield: tfield;
                     const row: integer): pointer;
var
 rowinfo: gridrowinfoty;
begin
 result:= nil;
 if (afield <> nil) and hasdata and begingridrow(row,rowinfo) then begin
  if not afield.isnull then begin
   result:= @fint64buffer;
   fint64buffer:= afield.aslargeint;
  end;
  endgridrow(rowinfo);
 end;
end;

function tgriddatalink.getrealtybuffer(const afield: tfield; 
                                             const row: integer): pointer;
var
 rowinfo: gridrowinfoty;
begin
 result:= nil;
 if (afield <> nil) and hasdata and begingridrow(row,rowinfo) then begin
  if not afield.isnull then begin
   result:= @frealtybuffer;
   frealtybuffer:= afield.asfloat;
  end;
  endgridrow(rowinfo);
 end;
end;

function tgriddatalink.getdatetimebuffer(const afield: tfield;
                                              const row: integer): pointer;
var
 rowinfo: gridrowinfoty;
begin
 result:= nil;
 if (afield <> nil) and hasdata and begingridrow(row,rowinfo) then begin
  if not afield.isnull then begin
   result:= @frealtybuffer;
   frealtybuffer:= afield.asdatetime;
  end;
  endgridrow(rowinfo);
 end;
end;

procedure tgriddatalink.updatelayout;
var
// ar1: integerarty;
 int1: integer;
begin
 with tcustomgrid1(fgrid) do begin
  int1:= fgrid.rowsperpage + 1;
  if int1 = 0 then begin
   int1:= 1;
  end;
  BufferCount:= int1;
  if self.active then begin
   forcecalcrange;
   checkscroll;
  end;
  int1:= fgrid.rowcount;
  self.updaterowcount;
  if int1 <> fgrid.rowcount then begin
   tcustomgrid1(fgrid).updatelayout; //again
   exit;
  end;
 end;
 checkscrollbar;
 checkactiverecord; //show cell
end;

procedure tgriddatalink.updaterowcount;
var
 int1: integer;
begin
 if not (csdestroying in fgrid.componentstate) then begin
  if active then begin
   int1:= recordcount;
  end
  else begin
   int1:= 0;
  end;
  if fgrid.rowcount <> int1 then begin
   gridinvalidate;
   fgrid.rowcount:= int1;
  end;
 end;
end;

procedure tgriddatalink.datasetchanged;
//var
// state1: tdatasetstate;
begin
 if (fdatasetchangedlock = 0) and not (csdestroying in fgrid.componentstate) then begin
  finserting:= (dataset <> nil) and (dataset.state = dsinsert);
  if recordcount > fgrid.rowcount then begin
   updaterowcount;  //for append
  end;
  inherited;
  gridinvalidate;
  if finserting and not finsertingbefore and (fgrid.datacols.newrowcol >= 0) then begin
   fgrid.col:= fgrid.datacols.newrowcol;
  end;
  finsertingbefore:= finserting;
  checkdelayedautoinsert;
 end;
end;

procedure tgriddatalink.datasetscrolled(distance: integer);
begin
 if (fmovebydistance < 0) and bof or (fmovebydistance > 0) and eof then begin
  include(tcustomgrid1(fgrid).fstate1,gs1_scrolllimit);
 end;
 fmovebydistance:= 0;
 ffirstrecordbefore:= firstrecord - distance;
 recordchanged(nil);
end;

procedure tgriddatalink.forcecalcrange;
begin
 if active then begin
  inc(fdatasetchangedlock);
  try
   dataevent(dedatasetchange,0); //force tdatalink.calcrange
  finally
   dec(fdatasetchangedlock);
  end;
 end;
end;

procedure tgriddatalink.activechanged;
begin
 inherited;
 if not active then begin
  fzebraoffset:= 0;
  factiverecordbefore:= 0;
  ffirstrecordbefore:= 0;
  fdatasetstatebefore:= dsinactive;
  fdscontroller:= nil;
  inherited firstrecord:= 0;
 end
 else begin
  if (fsortdatalink <> nil) and (fdscontroller <> nil) then begin
   fdscontroller.updatesortfield(fsortdatalink,fdescend);
  end;
 end;
 updaterowcount;
 checkscroll;
 gridinvalidate;
 checkscrollbar;
 if active then begin
  forcecalcrange;
  if (fgrid.rowcount > 0) then begin
   if (fgrid.col < 0) and (fgrid.entered) then begin
    fgrid.focuscell(makegridcoord(fgrid.col,activerecord),fca_entergrid);
   end
   else begin
    fgrid.focuscell(makegridcoord(fgrid.col,activerecord));
   end;
  end;
  factiverecordbefore:= activerecord;
  checkdelayedautoinsert;
 end;
end;

procedure tgriddatalink.checkzebraoffset;
begin
 if active and (gs_needszebraoffset in tcustomgrid1(fgrid).fstate) then begin
  fzebraoffset:= -(arecord - activerecord);
 end
 else begin
  fzebraoffset:= 0;
 end;
end;
 
procedure tgriddatalink.checkscroll;
var
 rect1,rect2: rectty;
 distance: integer;
// rowbefore: integer;
 int1: integer;
 
begin
 checkzebraoffset;
 distance:= firstrecord - ffirstrecordbefore;
 ffirstrecordbefore:= firstrecord;
 with tcustomgrid1(fgrid) do begin
//  rowbefore:= row;
  if distance <> 0 then begin
   inc(frowexited);
   row:= invalidaxis;
  end;
  if (abs(distance) >= rowcount) then begin
   gridinvalidate;
  end
  else begin
   if (distance <> 0) then begin
    if not fgridinvalidated then begin
     rect1:= fdatarecty;
     if (og_rowheight in foptionsgrid) then begin
      invalidaterect(rect1,org_client); //scrolling not possible
     end
     else begin
      int1:= -distance*ystep;
      rect2:= rect1;
      if int1 < 0 then begin
       dec(rect2.y,int1);
       inc(rect2.cy,int1);
      end
      else begin
       dec(rect2.cy,int1);
      end;
      if (rect2.cy > 0) and testintersectrect(rect2,updaterect) then begin
       ffirstrecordshift:= distance;
       inc(fzebraoffset,distance);       
       try
        update; //draw old position
       finally
        dec(fzebraoffset,distance);       
        ffirstrecordshift:= 0;
       end;
      end;
      dec(factiverecordbefore,distance);
      scrollrect(makepoint(0,int1),rect1,true);
     end;
    {
     if (og_rowheight in foptionsgrid) or testintersectrect(rect1,updaterect) then begin
      invalidaterect(rect1,org_client); //scrolling not possible
     end
     else begin
      dec(factiverecordbefore,distance);
      scrollrect(makepoint(0,-distance*ystep),rect1,true);
     end;
    }
    end;
    inc(fnoinvalidate);
    try
     doupdaterowdata(-1);
    finally
     dec(fnoinvalidate);
    end;
    if (gs_needsrowheight in fstate) then begin
     fdatacols.rowstate.change(-1);
    end;
   end;
  end;
  if (activerecord < rowcount) and 
                 not (csdestroying in componentstate) then begin
   inc(fnocheckvalue);
   try
    row:= activerecord;
   finally
    dec(fnocheckvalue);
   end;
  end;
 end;
end;

procedure tgriddatalink.checkactiverecord;
var
 int1: integer;
begin
 int1:= activerecord;
 if (int1 < fgrid.rowcount) and active and  
               (tcustomgrid1(fgrid).fcellvaluechecking = 0) then begin
  with tcustomgrid1(fgrid) do begin
   inc(fnocheckvalue);
   try
    row:= int1; //else empty dataset
    showcell(makegridcoord(invalidaxis,fgrid.row),cep_nearest,true);
   finally
    dec(fnocheckvalue);
   end;
  end;
 end;
end;

procedure tgriddatalink.recordchanged(afield: tfield);
var
 int1: integer;
 i2: int32;
// b1: boolean;
begin
 int1:= frowexited;
 with tcustomgrid1(fgrid) do begin
  i2:= row;
  if fcellvaluechecking = 0 then begin
//   b1:= gs1_nocellassistive in fstate1;
//   try
//    include(fstate1,gs1_nocellassistive);
    checkscroll();
//   finally
//    if not b1 then begin
//     exclude(fstate1,gs1_nocellassistive);
//    end;
//   end;
  end;
  fgrid.invalidaterow(activerecord);
  tcustomgrid1(fgrid).beginnonullcheck;
  tcustomgrid1(fgrid).beginnocheckvalue;
  try
//   b1:= gs1_nocellassistive in fstate1;
//   if row <> i2 then begin
//    include(fstate1,gs1_nocellassistive);
//   end;
   if (row = i2) and (afield = nil) and (frowexited = int1) and 
                                      (feditingbefore = editing) then begin
    fgrid.row:= invalidaxis;
   end;
   checkactiverecord;
  finally
//   if not b1 then begin
//    exclude(fstate1,gs1_nocellassistive);
//   end;
   tcustomgrid1(fgrid).endnonullcheck;
   tcustomgrid1(fgrid).endnocheckvalue;
   feditingbefore:= editing;
  end;
  fgrid.invalidaterow(factiverecordbefore);
  factiverecordbefore:= activerecord;
  if afield = nil then begin
   updaterowcount;
   checkscrollbar;
  end;
 end;
 doupdaterowdata(activerecord);
end;

function tgriddatalink.arecord: integer;
begin
 if fdscontroller <> nil then begin
  result:= fdscontroller.recnozerobased;
 end
 else begin
  result:= dataset.recno;
 end;
end;

function tgriddatalink.rowtorecnozerobased(const row: integer): integer;
begin
 if active then begin
  result:= recnozerobased + row - activerecord;
 end
 else begin
  result:= -1;
 end;
end;

function tgriddatalink.isfirstrow: boolean;
begin
 result:= not active or bof;
end;

function tgriddatalink.islastrow: boolean;
begin
 result:= not active or eof;
end;

procedure tgriddatalink.checkscrollbar;
var
 rea1: real;
 int1: integer;
begin 
 rea1:= 0.5;
 if active then begin
  int1:= dataset.recordcount - 1;
  if bof then begin
   rea1:= 0;
  end
  else begin
   if eof then begin
    rea1:= 1;
   end
   else begin
    if (gdo_propscrollbar in foptions) and (int1 > 0) then begin
     rea1:= arecord / int1;
    end;
   end;
  end;
  if int1 < 0 then begin
   int1:= 0
  end;
  fgrid.frame.sbvert.pagesize:= fgrid.rowcount / (int1+1+fgrid.rowcount);
 end
 else begin
  fgrid.frame.sbvert.pagesize:= 1;
 end;
 fgrid.frame.sbvert.value:= rea1;
end;

procedure tgriddatalink.cellevent(var info: celleventinfoty);
var
 int1: integer;
begin
 with info do begin
  if (eventkind = cek_enter) and active then begin
   int1:= newcell.row-activerecord;
   if int1 <> 0 then begin
    moveby(int1);
   end;
  end;
 end;
end;

procedure tgriddatalink.invalidateindicator;
var
 int1,int2: integer;
begin
 int1:= fintf.getdbindicatorcol;
 int2:= activerecord;
 if (int1 < 0) and (int2 >= 0) then begin
  fgrid.invalidatecell(makegridcoord(int1,int2));
 end;
end;

function tgriddatalink.scrollevent(sender: tcustomscrollbar;
                          event: scrolleventty): boolean;
             //true if processed
var
 int1,int2: integer;
begin
 result:= true;
 if sender.tag = 1 then begin
  with fgrid do begin
   case event of
    sbe_stepup: rowdown(fca_focusin);
    sbe_stepdown: rowup(fca_focusin);
    sbe_pageup: pagedown(fca_focusin);
    sbe_pagedown: pageup(fca_focusin);
    sbe_wheelup: wheeldown(fca_focusin);
    sbe_wheeldown: wheelup(fca_focusin);
    {sbe_thumbtrack,}sbe_valuechanged: begin
    end;
    sbe_thumbtrack,sbe_thumbposition: begin
     if (event <> sbe_thumbtrack) or (gdo_thumbtrack in foptions) then begin
      if self.active then begin
       if (sender.value = 0) then begin
        if not dataset.bof then begin
         dataset.first;
        end;
       end
       else begin
        if sender.value >= 1.0 then begin
         if not dataset.eof then begin
          dataset.last
         end;
        end
        else begin
         if (not dataset.filtered or (dscontroller <> nil)) and 
                                     (gdo_propscrollbar in foptions) then begin
          int1:= dataset.recordcount;
          if int1 >= 0 then begin
           int2:= round(int1 * sender.value)+1;
                    //are recnos allways 1-based?
           if (int2 >= int1) then begin
            if not dataset.eof then begin
             dataset.last;
            end;
           end
           else begin
            if dscontroller = nil then begin
             dataset.recno:= int2;
            end
            else begin
             dscontroller.findrecno(int2); //use cached recno
//             dscontroller.recno:= int2; //use cached recno
            end;
           end;
          end;
         end
         else begin
          if event <> sbe_thumbtrack then begin
           if sender.value < 0.5 then begin
            moveby(-fgrid.rowhigh);
           end
           else begin
            moveby(fgrid.rowhigh);
           end;
           sender.value:= 0.5;
          end;
         end;
        end;
       end;
      end
      else begin
       if event <> sbe_thumbtrack then begin
        sender.value:= 0.5;
       end;
      end;
     end
    end;
    else result:= false;
   end;
  end;
 end
 else begin
  result:= false;
 end;
end;

procedure tgriddatalink.doinsertrow;
begin
 if checkvalue and caninsert then begin
  dataset.insert;
  with fgrid,datacols do begin
   if newrowcol >= 0 then begin
    focuscell(makegridcoord(newrowcol,row));
   end;
  end;
 end;
end;

procedure tgriddatalink.doappendrow;
begin
 if checkvalue and canappend then begin
  if not eof then begin
   moveby(1);
  end;
  if not eof then begin
   dataset.insert;
  end
  else begin
   dataset.append;
  end;
  with fgrid,datacols do begin
   if newrowcol >= 0 then begin
    focuscell(makegridcoord(newrowcol,row));
   end;
  end;
 end;
end;

procedure tgriddatalink.dodeleterow;
begin
 if candelete and confirmdeleterecord then begin
  dataset.delete;
 end;
end;

procedure tgriddatalink.rowdown;
begin
 if checkvalue then begin
  moveby(1);
  if (og_autoappend in tcustomgrid1(fgrid).foptionsgrid) and canappend and eof and
                         (datasource.autoedit or 
                           (navigator <> nil) and navigator.autoedit) then begin
   dataset.append;
   with fgrid,datacols do begin
    if newrowcol >= 0 then begin
     focuscell(makegridcoord(newrowcol,row));
    end;
   end;
  end;
 end;
end;

procedure tgriddatalink.lastrow;
begin
 if active and checkvalue then begin
  dataset.last;
 end;
end;

procedure tgriddatalink.firstrow;
begin
 if active and checkvalue then begin
  dataset.first;
 end;
end;

function tgriddatalink.getzebrastart: integer;
begin
 result:= tcustomgrid1(fgrid).fzebra_start + fzebraoffset;
end;

procedure tgriddatalink.gridinvalidate;
begin
 if not fgridinvalidated then begin
  fgrid.invalidate;
  fgridinvalidated:= true;
  application.postevent(tobjectevent.create(ek_dbupdaterowdata,ievent(self)));
 end;
end;

procedure tgriddatalink.painted;
begin
 fgridinvalidated:= false;
end;

procedure tgriddatalink.loaded;
begin
 doupdaterowdata(-1);
 with tcustomgrid1(fgrid) do begin
  if fdatacols.sortcol >= 0 then begin
   optionsgrid:= optionsgrid + [og_sorted];
  end;
 end;
end;

procedure tgriddatalink.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 if (info.eventstate * [es_preview,es_processed] = []) and 
                     (fnavigator <> nil) and fnavigator.showing and
                                               fnavigator.isenabled then begin
  fnavigator.internalshortcut(info,sender);
 end;
end;

function tgriddatalink.checkvalue: boolean;
begin
 if editing then begin
  result:= fgrid.canparentclose;
 end
 else begin
  result:= true;
 end;
end;

procedure tgriddatalink.beginnullchecking;
begin
 inc(fnullchecking);
 tcustomgrid1(fgrid).beginnullchecking;
end;

procedure tgriddatalink.endnullchecking;
begin
 tcustomgrid1(fgrid).endnullchecking;
 dec(fnullchecking);
end;

function tgriddatalink.domoveby(const distance: integer): integer;
begin
 result:= 0;
 if active and (dataset.state <> dsfilter) then begin
  fmovebydistance:= distance;
  result:= inherited moveby(distance);
 end;
end;

function tgriddatalink.moveby(distance: integer): integer;
begin
 invalidateindicator; //grid can be defocused
 result:= 0;
 if fnullchecking = 0 then begin
  beginnullchecking;
  try
   if checkvalue then begin
    result:= domoveby(distance);
   end
   else begin
    tcustomgrid1(fgrid).beginnonullcheck;
    try
     checkactiverecord;
    finally
     tcustomgrid1(fgrid).endnonullcheck;
    end;
   end;
  finally
   endnullchecking;
  end;
 end;
end;

function tgriddatalink.getobjectlinker: tobjectlinker;
begin
 if fobjectlinker = nil then begin
  createobjectlinker(ievent(self),nil,fobjectlinker);
 end;
 result:= fobjectlinker;
end;

procedure tgriddatalink.link(const source,dest: iobjectlink; valuepo: pointer = nil;
                            ainterfacetype: pointer = nil; once: boolean = false);
begin
 getobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tgriddatalink.unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
begin
 getobjectlinker.unlink(source,dest,valuepo);
end;

procedure tgriddatalink.objevent(const sender: iobjectlink;
                 const event: objecteventty);
begin
 getobjectlinker.objevent(sender,event);
end;

function tgriddatalink.getinstance: tobject;
begin
 result:= self;
end;

procedure tgriddatalink.receiveevent(const event: tobjectevent);
begin
 case event.kind of
  ek_dbedit: begin
   edit;
  end;
  ek_dbupdaterowdata: begin
   doupdaterowdata(-1);
  end;
  ek_dbinsert: begin
   if fautoinserting then begin
    try
     if canautoinsert then begin
      dataset.insert;
     end;
    finally
     fautoinserting:= false;
    end;
   end;
  end;
 end;
end;

procedure tgriddatalink.updatedata;
begin
 beginnullchecking;
 tcustomgrid1(fgrid).beginnonullcheck;
 try 
  if checkvalue then begin
   if (og_appendempty in fgrid.optionsgrid) and 
                     (dataset.state = dsinsert) then begin
    tdataset1(dataset).setmodified(true); //FPC fixes_2_6 compatibility
                 //force append empty row
//    dataset.modified:= true; //force append empty row
   end;
   inherited;
  end
  else begin
   abort;
  end;
 finally
  tcustomgrid1(fgrid).endnonullcheck;
  endnullchecking;
 end;
end;

function tgriddatalink.getdataset(const aindex: integer): tdataset;
begin
 result:= dataset;
end;

procedure tgriddatalink.getfieldtypes(out propertynames: stringarty;
               out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= integerfields;
end;

function tgriddatalink.canautoinsert: boolean;
begin
// result:= fgrid.focused and active and (recordcount = 0) and 
 result:= fgrid.entered and active and (recordcount = 0) and 
                 (og_autofirstrow in fgrid.optionsgrid) and 
                 (datasource.autoedit or 
                  (navigator <> nil) and navigator.autoedit);
end;

procedure tgriddatalink.checkdelayedautoinsert;
begin
 if canautoinsert and not fautoinserting then begin
  fautoinserting:= true;
  application.postevent(tobjectevent.create(ek_dbinsert,ievent(self)));
 end;
end;

procedure tgriddatalink.beforefocuscell(const cell: gridcoordty;
                             const selectaction: focuscellactionty);
begin
 if (selectaction = fca_entergrid) and canautoinsert and 
                                        not fautoinserting then begin
  fautoinserting:= true;
  try
   dataset.insert;
   fgrid.focuscell(fgrid.focusedcell,selectaction); 
                              //focus col if necessary
  finally
   fautoinserting:= false;
  end;
 end;
end;

function tgriddatalink.getdummystringbuffer: pansistring;
begin
 fdummystringbuffer:= '';
 result:= @fdummystringbuffer;
end;

function tgriddatalink.canclose(const newfocus: twidget): boolean;
begin
 result:= not (gdo_checkbrowsemodeonexit in foptions) or 
           (fgrid.widgetstate * [ws_entered,ws_exiting] = [])  or
           fgrid.checkdescendent(newfocus) or inherited canclose;
end;

procedure tgriddatalink.focuscell(var cell: gridcoordty);
var
 int1,int2,int3,int4: integer;
 ds1: tdataset;
begin
 if (cell.row >= 0) and (cell.row <> fgrid.row) then begin
  ds1:= dataset;
  if (ds1 <> nil) then begin
   int1:= rowtorecnozerobased(cell.row);
   if not (finserting and not finsertingbefore) then begin
    int3:= recnozerobased;
    if (ds1.state <> dsfilter) and not fautoinserting and 
                        (tcustomgrid1(fgrid).fnocheckvalue = 0) then begin
     ds1.checkbrowsemode;
    end;
    int4:= recnozerobased;
    if (int1 < int3) and (int1 >= int4) then begin
     inc(int1);
    end
    else begin
     if (int1 > int3) and (int1 <= int4) then begin
      dec(int1);
     end;
    end;
   end;
   int2:= ds1.recordcount;
   if (int1 >= 0) and (int1 < int2) and (ds1.state <> dsfilter) then begin
    invalidateindicator; //grid can be defocused
    int1:= int1-recnozerobased;
    if int1 <> 0 then begin
     dataset.moveby(int1);
    end;
   end;
   cell.row:= activerecord;
  end;   
 end;
end;

procedure tgriddatalink.editingchanged;
begin
 updaterowcount; //for insert
 invalidateindicator;
 inherited;
 if editing and fgrid.canevent(tmethod(fonbeginedit)) then begin
  fonbeginedit(self);
 end;
 if not editing and fgrid.canevent(tmethod(fonendedit)) then begin
  fonendedit(self);
 end;
end;

function tgriddatalink.getdatasource1: tdatasource;
begin
 result:= inherited datasource;
end;

procedure tgriddatalink.settadasource1(const avalue: tdatasource);
begin
 inherited datasource:= avalue;
 tdatacols1(fgrid.datacols).datasourcechanged;
end;

procedure tgriddatalink.updatefields;
begin
 if active then begin
  if (ffieldname_state <> '') then begin
   setfield_state(datasource.dataset.fieldbyname(ffieldname_state));
  end
  else begin
   setfield_state(nil);
  end;
  if (ffieldname_color <> '') then begin
   setfield_color(datasource.dataset.fieldbyname(ffieldname_color));
  end
  else begin
   setfield_color(nil);
  end;
  if (ffieldname_font <> '') then begin
   setfield_font(datasource.dataset.fieldbyname(ffieldname_font));
  end
  else begin
   setfield_font(nil);
  end;
  if (ffieldname_readonly <> '') then begin
   setfield_readonly(datasource.dataset.fieldbyname(ffieldname_readonly));
  end
  else begin
   setfield_readonly(nil);
  end;
  if (ffieldname_merged <> '') then begin
   setfield_merged(datasource.dataset.fieldbyname(ffieldname_merged));
  end
  else begin
   setfield_merged(nil);
  end;
  if (ffieldname_selected <> '') then begin
   setfield_selected(datasource.dataset.fieldbyname(ffieldname_selected));
  end
  else begin
   setfield_selected(nil);
  end;
 end
 else begin
  setfield_state(nil);
  setfield_color(nil);
  setfield_font(nil);
  setfield_readonly(nil);
  setfield_merged(nil);
  setfield_selected(nil);
 end;
end;

procedure tgriddatalink.setfield_state(const avalue: tfield);
begin
 if ffield_state <> avalue then begin
  ffield_state:= avalue;
  fieldchanged;
 end;
end;

procedure tgriddatalink.setfield_color(const avalue: tfield);
begin
 if ffield_color <> avalue then begin
  ffield_color:= avalue;
  fieldchanged;
 end;
end;

procedure tgriddatalink.setfield_font(const avalue: tfield);
begin
 if ffield_font <> avalue then begin
  ffield_font:= avalue;
  fieldchanged;
 end;
end;

procedure tgriddatalink.setfield_readonly(const avalue: tfield);
begin
 if ffield_readonly <> avalue then begin
  ffield_readonly:= avalue;
  fieldchanged;
 end;
end;

procedure tgriddatalink.setfield_merged(const avalue: tfield);
begin
 if ffield_merged <> avalue then begin
  ffield_merged:= avalue;
  if avalue is tbooleanfield then begin
   include(fstate,gdls_booleanmerged);
  end
  else begin
   exclude(fstate,gdls_booleanmerged);
  end;
  fieldchanged;
 end;
end;

procedure tgriddatalink.setfield_selected(const avalue: tfield);
begin
 if ffield_selected <> avalue then begin
  ffield_selected:= avalue;
  if avalue is tbooleanfield then begin
   include(fstate,gdls_booleanselected);
  end
  else begin
   exclude(fstate,gdls_booleanselected);
  end;
  fieldchanged;
 end;
end;

procedure tgriddatalink.fieldchanged;
begin
 if (ffield_state <> nil) or (ffield_color <> nil) or (ffield_font <> nil) or
     (ffield_readonly <> nil) or (ffield_merged <> nil) or 
     (ffield_selected <> nil) then begin
  include(fstate,gdls_hasrowstatefield);
 end
 else begin
  exclude(fstate,gdls_hasrowstatefield);
 end;
 inherited;
end;

procedure tgriddatalink.setselected(const cell: gridcoordty;
               const avalue: boolean);
var
 bo1: boolean;
begin
 if (ffield_selected <> nil) and (cell.row >= 0) and 
                (cell.row = activerecord) then begin
  bo1:= editing;
  dataset.edit;
  if gdls_booleanselected in fstate then begin
   ffield_selected.asboolean:= avalue;
  end
  else begin
   if cell.col < 0 then begin
    if avalue then begin
     ffield_selected.asinteger:= integer(wholerowselectedmask);
    end
    else begin
     ffield_selected.asinteger:= 0;
    end;
   end
   else begin
    if cell.col <= selectedcolmax then begin
     if avalue then begin
      ffield_selected.asinteger:= ffield_selected.asinteger or bits[cell.col];
     end
     else begin
      ffield_selected.asinteger:= ffield_selected.asinteger and 
                                                      not bits[cell.col];
     end;
    end;
   end;
  end;
  if not bo1 and (gdo_selectautopost in foptions) then begin
   dataset.post;
  end;
 end;
end;

function tgriddatalink.updateoptionsgrid(
                                 const avalue: optionsgridty): optionsgridty;
begin
 result:= avalue - [og_sorted];
 with tcustomgrid1(fgrid) do begin
  if og_sorted in avalue then begin
   if not (gs1_dbsorted in fstate1) then begin
    include(fstate1,gs1_dbsorted);
    invalidate;
   end
  end
  else begin
   if gs1_dbsorted in fstate1 then begin
    exclude(fstate1,gs1_dbsorted);
    updatesortfield(nil,false);
    invalidate;
   end;
  end;
 end;
end;

function tgriddatalink.updatesortfield(const avalue: tfielddatalink;
                              const adescend: boolean): boolean;
begin
 fdescend:= adescend;
 fsortdatalink:= avalue;
 result:= true;
 if active then begin
  result:= false;
  if fdscontroller <> nil then begin
   result:= fdscontroller.updatesortfield(avalue,adescend);
  end;
 end;
end;

function tgriddatalink.begingridrow(const arow: integer;
                                       out ainfo: gridrowinfoty): boolean;
var
 int1: integer;
begin
 int1:= arow - ffirstrecordshift;
 result:= (int1 >= 0) and (int1 < recordcount);
 ainfo.row:= activerecord;
 if result then begin
  ainfo.row:= activerecord;
  {
  if ainfo.row <> fgrid.row then begin 
      //probably changed by tdatalink.destroy -> dataset.recalcbuflistsize
   result:= false;
   checkzebraoffset;
   checkactiverecord;
   fgrid.invalidaterow(invalidaxis);
   exit;
  end;
  }
  if (fdscontroller <> nil) and (datasource.state <> dsfilter) then begin
   fdscontroller.begindisplaydata;
  end;
  activerecord:= int1;
 end;
end;

procedure tgriddatalink.endgridrow(const ainfo: gridrowinfoty);
begin
 if (fdscontroller <> nil) and (datasource.state <> dsfilter) then begin
  fdscontroller.enddisplaydata;
 end;
 activerecord:= ainfo.row;
end;

procedure tgriddatalink.setnavigator(const avalue: tdbnavigator);
begin
 if fnavigator <> avalue then begin
  getobjectlinker.setlinkedvar(iobjectlink(self),tmsecomponent(avalue),
                  tmsecomponent(fnavigator));
  fintf.setnavigator(avalue);
 end;
end;

function tgriddatalink.getrecordcount: integer;
begin
 result:= 1;
 if dataset.state <> dsfilter then begin
  result:= inherited getrecordcount;
 end;
end;


{ tdbwidgetindicatorcol }

constructor tdbwidgetindicatorcol.create(const agrid: tcustomgrid;
                                            const aowner: tgridarrayprop);
begin
 fcolorindicator:= cl_glyph;
 inherited;
 options:= defaultindicatorcoloptions;
 width:= 15;
end;

procedure tdbwidgetindicatorcol.drawcell(const canvas: tcanvas);
begin
 with cellinfoty(canvas.drawinfopo^),tdbwidgetfixcols(prop) do begin
  if fdatalink.active and (cell.row = fdatalink.activerecord) then begin
   include(drawstate,cds_notext);
   inherited;
   drawindicatorcell(canvas,fdatalink,fcolorindicator);
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tdbwidgetindicatorcol.setcolorindicator(const avalue: colorty);
begin
 if fcolorindicator <> avalue then begin
  fcolorindicator:= avalue;
  changed;
 end;
end;

{ tdbwidgetfixcols }

constructor tdbwidgetfixcols.create(const aowner: tcustomwidgetgrid; 
                       const adatalink: tgriddatalink);
begin
 fdatalink:= adatalink;
 inherited create(aowner);
end;

procedure tdbwidgetfixcols.createitem(const index: integer; var item: tpersistent);
begin
 if index = fdbindicatorcol then begin
  item:= tdbwidgetindicatorcol.create(fgrid,self);
 end
 else begin
  inherited;
 end;
end;

procedure tdbwidgetfixcols.setcount1(acount: integer; doinit: boolean);
begin
 if (acount <= 0) and not (csdestroying in fgrid.componentstate) then begin
  acount:= 1;
 end;
 if fdbindicatorcol >= acount then begin
  fdbindicatorcol:= acount - 1;
 end;
 inherited;
end;

procedure tdbwidgetfixcols.setdbindicatorcol(const Value: integer);
var
 int1,int2: integer;
begin
 int1:= -1 - value;
 if int1 < 0 then begin
  int1:= 0;
 end;
 if int1 >= count then begin
  int1:= count-1;
 end;
 int2:= fdbindicatorcol;
 if int1 <> int2 then begin
  move(int2,int1);
  fdbindicatorcol := int1;
 end;
end;

function tdbwidgetfixcols.getdbindicatorcol: integer;
begin
 result:= -1-fdbindicatorcol;
end;

{ tdbscrollbar }

constructor tdbscrollbar.create(intf: iscrollbar; org: originty = org_client;
              ondimchanged: proceventty = nil);
begin
 inherited;
 foptions:= defaultdbscrollbaroptions;
 buttonlength:= -1;
end;

procedure tdbscrollbar.setoptions(const avalue: scrollbaroptionsty);
begin
 inherited setoptions(avalue + [sbo_thumbtrack]);
end;

{ tdbgridframe }

constructor tdbgridframe.create(const aintf: iscrollframe; const owner: twidget;
               const autoscrollintf: iautoscrollframe);
begin
 inherited;
 include(fstate,fs_sbvertfix);
end;

function tdbgridframe.getscrollbarclass(vert: boolean): framescrollbarclassty;
begin
 if vert then begin
  result:= tdbscrollbar;
 end
 else begin
  result:= inherited getscrollbarclass(vert);
 end;
end;

procedure tdbgridframe.scrollevent(sender: tcustomscrollbar; event: scrolleventty);
begin
 if sender.tag = 1 then begin
  fintf1.scrollevent(sender,event);
 end
 else begin
  inherited;
 end;
end;

procedure tdbgridframe.scrollpostoclientpos(var aclientrect: rectty);
begin
 with aclientrect do begin
  x:= - round(fhorz.value * (cx-fpaintrect.cx));
  y:= tcustomgrid1(fowner).fscrollrect.y;
 end;
end;

{ tcustomdbwidgetgrid }

constructor tcustomdbwidgetgrid.create(aowner: tcomponent);
begin
 fdatalink:= tgriddatalink.create(self,igriddatalink(self));
 inherited;
 fzebra_step:= 0;
 ffixcols.count:= 1;
end;

destructor tcustomdbwidgetgrid.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tcustomdbwidgetgrid.getdatalink: tgriddatalink;
begin
 result:= fdatalink;
end;

procedure tcustomdbwidgetgrid.setoptionsgrid(const avalue: optionsgridty);
begin
 inherited setoptionsgrid(fdatalink.updateoptionsgrid(avalue));
end;

procedure tcustomdbwidgetgrid.internalcreateframe;
begin
 tdbgridframe.create(iscrollframe(self),self,iautoscrollframe(self));
end;

function tcustomdbwidgetgrid.createfixcols: tfixcols;
begin
 result:= tdbwidgetfixcols.create(self,fdatalink);
end;
{
function tcustomdbwidgetgrid.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tcustomdbwidgetgrid.setdatasource(const Value: tdatasource);
begin
 fdatalink.datasource:= value;
 datacols.datasourcechanged;
end;
}
procedure tcustomdbwidgetgrid.dolayoutchanged;
begin
 inherited;
 fdatalink.updatelayout;
end;
{
procedure tcustomdbwidgetgrid.initcellinfo(var info: cellinfoty);
begin
 inherited;
 info.griddatalink:= fdatalink;
end;
}
procedure tcustomdbwidgetgrid.docellevent(var info: celleventinfoty);
begin
 inherited;
 fdatalink.cellevent(info);
end;

procedure tcustomdbwidgetgrid.scrollevent(sender: tcustomscrollbar; event: scrolleventty);
begin
 if not fdatalink.scrollevent(sender,event) then begin
  inherited;
 end;
end;

function tcustomdbwidgetgrid.getzebrastart: integer;
begin
 result:= fdatalink.getzebrastart;
end;

function tcustomdbwidgetgrid.getnumoffset: integer;
begin
 result:= -fdatalink.fzebraoffset;
end;

procedure tcustomdbwidgetgrid.dopaint(const acanvas: tcanvas);
begin
 inherited;
 fdatalink.painted;
end;

procedure tcustomdbwidgetgrid.dohide;
begin
 fdatalink.painted;
 inherited;
end;

procedure tcustomdbwidgetgrid.pagedown(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(rowcount-1);
end;

procedure tcustomdbwidgetgrid.pageup(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(-rowcount+1);
end;

procedure tcustomdbwidgetgrid.wheeldown(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(wheelheight);
end;

procedure tcustomdbwidgetgrid.wheelup(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(-wheelheight);
end;

procedure tcustomdbwidgetgrid.rowdown(
  const action: focuscellactionty = fca_focusin; const nowrap: boolean = false);
begin
 fdatalink.rowdown;
end;

procedure tcustomdbwidgetgrid.rowup(
  const action: focuscellactionty = fca_focusin;const nowrap: boolean = false);
begin
 fdatalink.MoveBy(-1);
end;

procedure tcustomdbwidgetgrid.lastrow(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.lastrow;
end;

procedure tcustomdbwidgetgrid.firstrow(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.firstrow;
end;

procedure tcustomdbwidgetgrid.dodeleterow(const sender: tobject);
begin
 fdatalink.dodeleterow;
end;

procedure tcustomdbwidgetgrid.doinsertrow(const sender: tobject);
begin
 fdatalink.doinsertrow;
end;

procedure tcustomdbwidgetgrid.doappendrow(const sender: tobject);
begin
 fdatalink.doappendrow;
end;


procedure tcustomdbwidgetgrid.setdatalink(const avalue: tgriddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tcustomdbwidgetgrid.loaded;
begin
 inherited;
 fdatalink.loaded;
end;

procedure tcustomdbwidgetgrid.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

function tcustomdbwidgetgrid.getgriddatalink: pointer;
begin
 result:= fdatalink;
end;

procedure tcustomdbwidgetgrid.beforefocuscell(const cell: gridcoordty;
                             const selectaction: focuscellactionty);
begin
 fdatalink.beforefocuscell(cell,selectaction);
end;

function tcustomdbwidgetgrid.canclose(const newfocus: twidget): boolean;
begin
 result:= inherited canclose(newfocus) and fdatalink.canclose(newfocus);
end;

function tcustomdbwidgetgrid.focuscell(cell: gridcoordty;
               selectaction: focuscellactionty = fca_focusin;
               const selectmode: selectcellmodety = scm_cell;
               const ashowcell: cellpositionty = cep_nearest): boolean;
begin
 fdatalink.focuscell(cell);
 result:= inherited focuscell(cell,selectaction,selectmode,ashowcell);
end;

function tcustomdbwidgetgrid.isfirstrow: boolean;
begin
 result:= fdatalink.isfirstrow;
end;

function tcustomdbwidgetgrid.islastrow: boolean;
begin
 result:= fdatalink.islastrow;
end;

procedure tcustomdbwidgetgrid.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

function tcustomdbwidgetgrid.getdbindicatorcol: integer;
begin
 result:= fixcols.dbindicatorcol;
end;

function tcustomdbwidgetgrid.getfixcols: tdbwidgetfixcols;
begin
 result:= tdbwidgetfixcols(inherited fixcols);
end;

procedure tcustomdbwidgetgrid.setfixcols(const avalue: tdbwidgetfixcols);
begin
 inherited
end;

procedure tcustomdbwidgetgrid.setselected(const cell: gridcoordty;
               const avalue: boolean);
begin
 fdatalink.setselected(cell,avalue);
end;

function tcustomdbwidgetgrid.updatesortcol(const avalue: integer): integer;
begin
 result:= inherited updatesortcol(avalue);
 if not fdatalink.updatesortfield(getfieldlink(avalue),
                                   getsortdescend(avalue)) then begin
  result:= -1;
 end;
end;

function tcustomdbwidgetgrid.getfieldlink(
                         const acol: integer): tcustomeditwidgetdatalink;
var
 widget1: twidget;
 intf1: idbeditfieldlink;
begin
 result:= nil;
 if (acol >= 0) and (acol < fdatacols.count) then begin
  widget1:= twidgetcol(tdatacols1(fdatacols).fitems[acol]).editwidget;
  if (widget1 <> nil) and 
      widget1.getcorbainterface(typeinfo(idbeditfieldlink),intf1) then begin
   result:= intf1.getfieldlink;
  end;
 end;
end;

function tcustomdbwidgetgrid.canautoappend: boolean;
begin
 result:= inherited canautoappend and fdatalink.canautoinsert;
end;

procedure tcustomdbwidgetgrid.setnavigator(const avalue: tdbnavigator);
var
 int1: integer;
 fieldlink1: tcustomeditwidgetdatalink;
begin
 if not (csloading in componentstate) then begin
  for int1:= 0 to fdatacols.count - 1 do begin
   fieldlink1:= getfieldlink(int1);
   if fieldlink1 <> nil then begin
    fieldlink1.navigator:= avalue;
   end;
  end;
 end;
end;

function tcustomdbwidgetgrid.createdatacols: tdatacols;
begin
 result:= tdbwidgetcols.create(self);
end;

function tcustomdbwidgetgrid.caninsertrow: boolean;
begin
 result:= inherited caninsertrow and fdatalink.caninsert;
end;

function tcustomdbwidgetgrid.canappendrow: boolean;
begin
 result:= inherited canappendrow and fdatalink.canappend;
end;

function tcustomdbwidgetgrid.candeleterow: boolean;
begin
 result:= inherited candeleterow and fdatalink.candelete;
end;

procedure tcustomdbwidgetgrid.createdatacol(const index: integer;
               out item: tdatacol);
begin
 item:= tdbwidgetcol.create(self,fdatacols);
end;

function tcustomdbwidgetgrid.getdatacols: tdbwidgetcols;
begin
 result:= tdbwidgetcols(fdatacols);
end;

procedure tcustomdbwidgetgrid.setdatacols(const avalue: tdbwidgetcols);
begin
 inherited;
end;

function tcustomdbwidgetgrid.getassistiveflags(): assistiveflagsty;
begin
 result:= inherited getassistiveflags() + [asf_db];
end;
{
procedure tcustomdbwidgetgrid.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tcustomdbwidgetgrid.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tstringcoldatalink }

procedure tstringcoldatalink.layoutchanged;
begin
 inherited;
 tcustomdbstringgrid(fintf.getwidget).checkautofields;
end;

procedure tstringcoldatalink.updatedata;
var
 grid1: tcustomdbstringgrid;
begin
 grid1:=  tcustomdbstringgrid(fintf.getwidget);
 inc(grid1.fdatalink.fcanclosing);
 try
  inherited;
 finally
  dec(grid1.fdatalink.fcanclosing);
 end;
end;

{ tdbstringcol }

constructor tdbstringcol.create(const agrid: tcustomgrid; 
                         const aowner: tgridarrayprop);
begin
 fdatalink:= tstringcoldatalink.create(idbeditfieldlink(self));
 fdatalink.options:= tdbstringcols(aowner).foptionsdb;
 fdatalink.navigator:= tcustomdbstringgrid(agrid).datalink.navigator;
 inherited;
 fdatalink.griddatasourcechanged;
end;

destructor tdbstringcol.destroy;
begin
 inherited;
 fdatalink.free;
end;

function tdbstringcol.getdatafield: string;
begin
 result:= fdatalink.fieldname;
end;

procedure tdbstringcol.setdatafield(const avalue: string);
begin
 fdatalink.fieldname:= avalue;
end;

procedure tdbstringcol.modified;
begin
 inherited;
 fdatalink.modified;
end;

function tdbstringcol.getrowtext(const arow: integer): msestring;
var
 po1: pmsestring;
begin
 po1:= pmsestring(
    tcustomdbstringgrid(fcellinfo.grid).fdatalink.getdisplaystringbuffer(
                                                       fdatalink.field,arow));
 if po1 = nil then begin
  result:= fdatalink.nullsymbol;
 end
 else begin
  result:= po1^;
 end;
end;

function tdbstringcol.getitems(aindex: integer): msestring;
begin
// if aindex = fgrid.row then begin
//  result:= inherited getitems(aindex);
// end
// else begin
  result:= getrowtext(aindex);
// end;
end;

procedure tdbstringcol.setitems(aindex: integer; const Value: msestring);
begin
 //dummy
end;

function tdbstringcol.getgriddatasource: tdatasource;
begin
 result:= tcustomdbstringgrid(fcellinfo.grid).datalink.datasource;
end;

function tdbstringcol.getgridintf: iwidgetgrid;
begin
 result:= iwidgetgrid(tcustomdbstringgrid(fcellinfo.grid));
end;

function tdbstringcol.getwidget: twidget;
begin
 result:= fcellinfo.grid;
end;

function tdbstringcol.seteditfocus: boolean;
begin
 if not readonly then begin
  grid.col:= index;
  if not grid.focused then begin
   if grid.canfocus then begin
    grid.setfocus;
   end;
  end;
 end;
 result:= grid.entered and (grid.col = index);
end;

function tdbstringcol.getedited: boolean;
begin
 result:= fds_modified in fdatalink.fstate;
end;

procedure tdbstringcol.initeditfocus;
begin
 with tcustomstringgrid1(fcellinfo.grid) do begin
  if (ffocusedcell.col = index) and (ffocusedcell.row >= 0) then begin
   feditor.dofocus;
  end;
 end;
end;

procedure tdbstringcol.updatereadonlystate;
begin
 if (fcellinfo.grid.col = self.index) and (fcellinfo.grid.row >= 0) then begin
  tcustomstringgrid1(fcellinfo.grid).feditor.updatecaret;
 end;
end;

function tdbstringcol.checkvalue(const quiet: boolean = false): boolean;
begin
 result:= true;
 tcustomdbstringgrid(fcellinfo.grid).checkcellvalue(result);
end;

procedure tdbstringcol.valuetofield;
//var
// int1: integer;
// mstr1: msestring;
begin
 with tcustomdbstringgrid(fcellinfo.grid) do begin
  if col = index then begin
   self.fdatalink.asnullmsestring:= feditor.text;
  end;
 end;
// int1:= tcustomdbstringgrid(fgrid).fdatalink.activerecord;
// if (int1 >= 0) and (int1 < fgrid.rowcount) then begin
//  fdatalink.asnullmsestring:= items[int1];
// end;
end;

procedure tdbstringcol.fieldtovalue;
//var
// int1: integer;
begin
 with tcustomdbstringgrid(fcellinfo.grid) do begin
  if col = index then begin
   feditor.text:= self.fdatalink.msedisplaytext('',true);
  end
  else begin
   self.invalidatecell(fdatalink.activerecord);
  end;
 end;
 datachange(fdatalink.activerecord);
// int1:= tcustomdbstringgrid(fgrid).fdatalink.activerecord;
// if (int1 >= 0) and (int1 < fgrid.rowcount) then begin
//  items[int1]:= fdatalink.msedisplaytext('',true);
// end;
end;

procedure tdbstringcol.setnullvalue;
//var
// int1: integer;
begin
 with tcustomdbstringgrid(fcellinfo.grid) do begin
  if col = index then begin
   feditor.text:= self.fdatalink.nullsymbol;
  end
  else begin
   self.invalidatecell(fdatalink.activerecord);
  end;
 end;
// int1:= tcustomdbstringgrid(fgrid).fdatalink.activerecord;
// if (int1 >= 0) and (int1 < fgrid.rowcount) then begin
//  items[int1]:= fdatalink.nullsymbol;
// end;
end;

procedure tdbstringcol.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= stringfields;
end;

procedure tdbstringcol.getfieldtypes(out propertynames: stringarty; 
                                     out fieldtypes: fieldtypesarty);
begin
 propertynames:= nil;
 setlength(fieldtypes,1);
 fieldtypes[0]:= stringfields;
end;

function tdbstringcol.getdataset(const aindex: integer): tdataset;
begin
 result:= tcustomdbstringgrid(fcellinfo.grid).datalink.dataset;
end;

function tdbstringcol.getoptionsdb: optionseditdbty;
begin
 result:= fdatalink.options;
end;

procedure tdbstringcol.setoptionsdb(const avalue: optionseditdbty);
begin
 fdatalink.options:= avalue;
end;

function tdbstringcol.getnullsymbol: msestring;
begin
 result:= fdatalink.nullsymbol;
end;

procedure tdbstringcol.setnullsymbol(const avalue: msestring);
begin
 fdatalink.nullsymbol:= avalue;
end;

function tdbstringcol.createdatalist: tdatalist;
begin
 result:= nil;
end;

procedure tdbstringcol.setmaxlength(const avalue: integer);
begin
 fmaxlength:= avalue;
end;

function tdbstringcol.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;

procedure tdbstringcol.setifiserverintf(const aintf: iifiserver);
begin
 fifiserverintf:= aintf; 
end;

procedure tdbstringcol.docellfocuschanged(enter: boolean;
               const cellbefore: gridcoordty; var newcell: gridcoordty;
               const selectaction: focuscellactionty);
var
 state1: ifiwidgetstatesty;
 int1: integer;
begin
 int1:= tcustomgrid1(fcellinfo.grid).ffocuscount;
 inherited;
 if int1 = tcustomgrid1(fcellinfo.grid).ffocuscount then begin
  state1:= [];
  if enter then begin
   include(state1,iws_focused);
  end;
  if visible then begin
   include(state1,iws_visible);
  end;
  if fcellinfo.grid.active then begin
   include(state1,iws_active);
  end;
  fdatalink.statechanged(iificlient(self),state1);
 end;
end;

procedure tdbstringcol.dobeforedrawcell(const acanvas: tcanvas;
               var processed: boolean);
var
 info: gridrowinfoty;
begin
 tcustomdbstringgrid(grid).fdatalink.begingridrow(
                                   fcellinfo.cell.row,info);
 try
  inherited;
 finally
  tcustomdbstringgrid(grid).fdatalink.endgridrow(info);
 end;
end;

procedure tdbstringcol.doafterdrawcell(const acanvas: tcanvas);
var
 info: gridrowinfoty;
begin
 tcustomdbstringgrid(grid).fdatalink.begingridrow(
                                   fcellinfo.cell.row,info);
 try
  inherited;
 finally
  tcustomdbstringgrid(grid).fdatalink.endgridrow(info);
 end;
end;

function tdbstringcol.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 if fifiserverintf <> nil then begin
  fifiserverintf.updateoptionsedit(result);
 end;
end;

function tdbstringcol.getdefaultifilink: iificlient;
begin
 result:= iificlient(self);
end;

function tdbstringcol.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidatalink);
end;

function tdbstringcol.getifidatatype(): listdatatypety;
begin
 result:= dl_msestring;
end;

procedure tdbstringcol.updateifigriddata(const sender: tobject;
               const alist: tdatalist);
begin
 //dummy
end;

function tdbstringcol.getgriddata: tdatalist;
begin
 result:= nil;
end;

function tdbstringcol.getvalueprop: ppropinfo;
begin
 result:= nil;
end;

procedure tdbstringcol.getifivalue(var avalue);
begin
 //dummy
end;

procedure tdbstringcol.setifivalue(const avalue);
begin
 //dummy
end;

{
procedure tdbstringcol.docellevent(var info: celleventinfoty);
begin
 with info do begin
  if cellbefore.col <> newcell.col then begin
   if (info.eventkind = cek_enter) and (newcell.col = index) then begin
    fdatalink.doenter(self);
   end
   else begin
    if (info.eventkind = cek_exit) and (cellbefore.col = index) then begin
     fdatalink.doexit(self);
    end;
   end;
  end;  
 end;
 inherited;
end;
}
{ tdropdowndbstringcol }

{ tdbstringcols }

class function tdbstringcols.getitemclasstype: persistentclassty;
begin
 result:= tdbstringcol;
end;

function tdbstringcols.getcols(const index: integer): tdbstringcol;
begin
 result:= tdbstringcol(items[index]);
end;

function tdbstringcols.getcolclass: stringcolclassty;
begin
 result:= tdbstringcol;
end;

procedure tdbstringcols.datasourcechanged;
var
 int1: integer;
begin
 for int1:= 0 to count - 1 do begin
  cols[int1].fdatalink.griddatasourcechanged;
 end;
end;

procedure tdbstringcols.setoptionsdb(const avalue: optionseditdbty);
var
 int1: integer;
 mask: {$ifdef FPC}longword{$else}word{$endif};
begin
 if foptionsdb <> avalue then begin
  mask:= {$ifdef FPC}longword{$else}word{$endif}(avalue) xor
  {$ifdef FPC}longword{$else}word{$endif}(foptionsdb);
  foptionsdb := avalue;
  if not (csloading in fgrid.componentstate) then begin
   for int1:= 0 to count - 1 do begin
    tdbstringcol(items[int1]).optionsdb:= optionseditdbty(
        replacebits({$ifdef FPC}longword{$else}word{$endif}(avalue),
  {$ifdef FPC}longword{$else}word{$endif}(tdbstringcol(items[int1]).optionsdb),
                             mask));
   end;
  end;
 end;
end;

{ tdbstringindicatorcol }

constructor tdbstringindicatorcol.create(const agrid: tcustomgrid;
                                            const aowner: tgridarrayprop);
begin
 fcolorindicator:= cl_glyph;
 inherited;
 options:= defaultindicatorcoloptions;
 width:= 15;
end;

procedure tdbstringindicatorcol.drawcell(const canvas: tcanvas);
begin
 with cellinfoty(canvas.drawinfopo^),tdbstringfixcols(prop) do begin
  if fdatalink.active and (cell.row = fdatalink.activerecord) then begin
   include(drawstate,cds_notext);
   inherited;
   drawindicatorcell(canvas,fdatalink,fcolorindicator);
  end
  else begin
   inherited;
  end;
 end;
end;

procedure tdbstringindicatorcol.setcolorindicator(const avalue: colorty);
begin
 if fcolorindicator <> avalue then begin
  fcolorindicator:= avalue;
  changed;
 end;
end;

{ tdbstringfixcols }

constructor tdbstringfixcols.create(const aowner: tcustomgrid; 
                       const adatalink: tgriddatalink);
begin
 fdatalink:= adatalink;
 inherited create(aowner);
end;

procedure tdbstringfixcols.createitem(const index: integer; var item: tpersistent);
begin
 if index = fdbindicatorcol then begin
  item:= tdbstringindicatorcol.create(fgrid,self);
 end
 else begin
  inherited;
 end;
end;

procedure tdbstringfixcols.setcount1(acount: integer; doinit: boolean);
begin
 if (acount <= 0) and not (csdestroying in fgrid.componentstate) then begin
  acount:= 1;
 end;
 if fdbindicatorcol >= acount then begin
  fdbindicatorcol:= acount - 1;
 end;
 inherited;
end;

procedure tdbstringfixcols.setdbindicatorcol(const Value: integer);
var
 int1,int2: integer;
begin
 int1:= -1 - value;
 if int1 < 0 then begin
  int1:= 0;
 end;
 if int1 >= count then begin
  int1:= count-1;
 end;
 int2:= fdbindicatorcol;
 if int1 <> int2 then begin
  move(int2,int1);
  fdbindicatorcol := int1;
 end;
end;

function tdbstringfixcols.getdbindicatorcol: integer;
begin
 result:= -1-fdbindicatorcol;
end;

{ tstringgriddatalink }

procedure tstringgriddatalink.activechanged;
begin
 if active then begin
  tcustomdbstringgrid(fgrid).checkautofields;
 end;
 inherited;
end;

{ tcustomdbstringgrid }

constructor tcustomdbstringgrid.create(aowner: tcomponent);
begin
 ffieldnamedisplayfixrow:= -1;
 fdatalink:= tstringgriddatalink.create(self,igriddatalink(self));
 inherited;
 fzebra_step:= 0;
 ffixcols.count:= 1;
end;

destructor tcustomdbstringgrid.destroy;
begin
 inherited;
 fdatalink.free;
end;

//iwidgetgrid (dummy)

function tcustomdbstringgrid.getbrushorigin: pointty;
begin
 result:= nullpoint;
end;

function tcustomdbstringgrid.getcol: twidgetcol;
begin
 result:= nil;
end;

procedure tcustomdbstringgrid.getdata(var index: integer; var dest);
begin
 //dummy
end;

procedure tcustomdbstringgrid.setdata(var index: integer; const source;
                  const noinvalidate: boolean = false);
begin
 //dummy
end;

procedure tcustomdbstringgrid.datachange(const arow: integer);
begin
 //dummy
end;

function tcustomdbstringgrid.getrow: integer;
begin
 result:= ffocusedcell.row;
end;

procedure tcustomdbstringgrid.setrow(arow: integer);
begin
 row:= arow;
end;

procedure tcustomdbstringgrid.changed;
begin
 //dummy
end;

procedure tcustomdbstringgrid.edited();
begin
 //dummy
end;

function tcustomdbstringgrid.empty(index: integer): boolean;
begin
 result:= false;
end;

procedure tcustomdbstringgrid.updateeditoptions(var aoptions: optionseditty;
                                              const aoptions1: optionsedit1ty);
begin
 //dummy
end;

procedure tcustomdbstringgrid.showrect(const arect: rectty;
                           const aframe: tcustomframe);
begin
 //dummy
end;

procedure tcustomdbstringgrid.widgetpainted(const canvas: tcanvas);
begin
 //dummy
end;

function tcustomdbstringgrid.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= fnonullcheck = 0;
end;

function tcustomdbstringgrid.nonullcheck: boolean;
begin
 result:= fnonullcheck > 0;
end;

procedure tcustomdbstringgrid.internalcreateframe;
begin
 tdbgridframe.create(iscrollframe(self),self,iautoscrollframe(self));
end;
{
function tcustomdbstringgrid.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 if ffocusedcell.col >= 0 then begin
  datacols[ffocusedcell.col].fdatalink.updateoptionsedit(result);
 end;
end;
}
function tcustomdbstringgrid.createfixcols: tfixcols;
begin
 result:= tdbstringfixcols.create(self,fdatalink);
end;

function tcustomdbstringgrid.createdatacols: tdatacols;
begin
 result:= tdbstringcols.create(self);
end;
{
function tcustomdbstringgrid.getdatasource: tdatasource;
begin
 result:= fdatalink.datasource;
end;

procedure tcustomdbstringgrid.setdatasource(const Value: tdatasource);
begin
 fdatalink.datasource:= value;
 datacols.datasourcechanged;
end;
}
function tcustomdbstringgrid.getdatacols: tdbstringcols;
begin
 result:= tdbstringcols(fdatacols);
end;

procedure tcustomdbstringgrid.setdatacols(const avalue: tdbstringcols);
begin
 fdatacols.assign(avalue);
end;

procedure tcustomdbstringgrid.updatelayout;
begin
 inherited;
 fdatalink.updatelayout;
end;
{
procedure tcustomdbstringgrid.initcellinfo(var info: cellinfoty);
begin
 inherited;
 info.griddatalink:= fdatalink;
end;
}
procedure tcustomdbstringgrid.docellevent(var info: celleventinfoty);
begin
 inherited;
 fdatalink.cellevent(info);
end;

procedure tcustomdbstringgrid.scrollevent(sender: tcustomscrollbar; event: scrolleventty);
begin
 if not fdatalink.scrollevent(sender,event) then begin
  inherited;
 end;
end;

function tcustomdbstringgrid.getzebrastart: integer;
begin
 result:= fdatalink.getzebrastart;
end;

function tcustomdbstringgrid.getnumoffset: integer;
begin
 result:= -fdatalink.fzebraoffset;
end;

procedure tcustomdbstringgrid.checkcellvalue(var accept: boolean);
var
 co1: tdbstringcol;
begin
 inherited;
 if accept and (ffocusedcell.col >= 0) then begin
  co1:= datacols[ffocusedcell.col];
  with co1 do begin;
   if (fds_modified in fdatalink.fstate) and self.fdatalink.active then begin
//    fdatalink.datachanged;
    fdatalink.valuechanged(iifidatalink(co1));
   end;
  end;
 end;
end;

function tcustomdbstringgrid.canclose(const newfocus: twidget): boolean;
begin
 result:= true;
 checkcellvalue(result);
 result:= result and fdatalink.canclose(newfocus);
end;

procedure tcustomdbstringgrid.dopaint(const acanvas: tcanvas);
begin
 inherited;
 fdatalink.painted;
end;

procedure tcustomdbstringgrid.dohide;
begin
 fdatalink.painted;
 inherited;
end;

procedure tcustomdbstringgrid.pagedown(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(rowcount-1);
end;

procedure tcustomdbstringgrid.pageup(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(-rowcount+1);
end;

procedure tcustomdbstringgrid.wheeldown(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(wheelheight);
end;

procedure tcustomdbstringgrid.wheelup(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.MoveBy(-wheelheight);
end;

procedure tcustomdbstringgrid.rowdown(
  const action: focuscellactionty = fca_focusin; const nowrap: boolean = false);
begin
 fdatalink.rowdown;
end;

procedure tcustomdbstringgrid.rowup(
  const action: focuscellactionty = fca_focusin; const nowrap: boolean = false);
begin
 fdatalink.MoveBy(-1);
end;

procedure tcustomdbstringgrid.lastrow(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.lastrow;
end;

procedure tcustomdbstringgrid.firstrow(const action: focuscellactionty = fca_focusin);
begin
 fdatalink.firstrow;
end;

procedure tcustomdbstringgrid.dodeleterow(const sender: tobject);
begin
 fdatalink.dodeleterow;
end;

procedure tcustomdbstringgrid.doinsertrow(const sender: tobject);
begin
 fdatalink.doinsertrow;
end;

procedure tcustomdbstringgrid.doappendrow(const sender: tobject);
begin
 fdatalink.doappendrow;
end;

procedure tcustomdbstringgrid.setoptions(const avalue: dbstringgridoptionsty);
begin
 if foptions <> avalue then begin
  foptions:= avalue;
  checkautofields;
 end;
end;

procedure tcustomdbstringgrid.setfieldnamedisplayfixrow(const avalue: integer);
begin
 if avalue <> ffieldnamedisplayfixrow then begin
  ffieldnamedisplayfixrow:= avalue;
  if ffieldnamedisplayfixrow > 0 then begin
   ffieldnamedisplayfixrow:= 0;
  end;
  checkautofields;
 end;
end;

function tcustomdbstringgrid.getdatalink: tgriddatalink;
begin
 result:= fdatalink;
end;

procedure tcustomdbstringgrid.setoptionsgrid(const avalue: optionsgridty);
begin
 inherited setoptionsgrid(fdatalink.updateoptionsgrid(avalue));
end;

procedure tcustomdbstringgrid.doasyncevent(var atag: integer);
var
 int1,int2: integer;
 field1: tfield;
 charwi: integer;
 focusedcellbefore: gridcoordty;
begin
 if tag = 0 then begin
  beginupdate;
  try
   focusedcellbefore:= focusedcell;
   datacols.count:= 0;
   charwi:= getcanvas.getstringwidth('o');
   if fdatalink.dataset <> nil then begin
    for int1:= 0 to fdatalink.dataset.fields.count - 1 do begin
     field1:= fdatalink.dataset.fields[int1];
     with field1 do begin
      if (datatype in stringfields) and visible then begin
       datacols.count:= datacols.count + 1;
       with datacols[datacols.count-1] do begin
        if readonly then begin
         options:= options + [co_readonly];
        end;
        datafield:= fieldname;
        int2:= displaywidth;
        if (int2 = 0) or (int2 > maxautodisplaywidth) then begin
         int2:= maxautodisplaywidth;
        end;
        width:= charwi * int2;
        textflags:= textflags - [tf_xcentered,tf_right];
        case alignment of
         tacenter: begin
          textflags:= textflags + [tf_xcentered];
         end;
         tarightjustify: begin
          textflags:= textflags + [tf_right];
         end;
        end;
        if (ffieldnamedisplayfixrow < 0) and 
                      (-ffieldnamedisplayfixrow <= ffixrows.count) then begin
         with ffixrows[ffieldnamedisplayfixrow] do begin
          captions.count:= datacols.count;
          captions[datacols.count-1].caption:= msestring(displaylabel);
         end;
        end;
       end;
      end;
     end;
    end;
   end;
   focuscell(focusedcellbefore);
  finally
   endupdate;
  end;
 end;
end;

procedure tcustomdbstringgrid.checkautofields;
var
 int1: integer;
begin           
 if dsgo_autofields in foptions then begin
  for int1:= 0 to datacols.count - 1 do begin
   datacols[int1].datafield:= '';
  end;
  asyncevent(0); //datalinks can not be destroyed
 end;
end;

procedure tcustomdbstringgrid.setdatalink(const avalue: tstringgriddatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tcustomdbstringgrid.loaded;
begin
 inherited;
 fdatalink.loaded;
end;

procedure tcustomdbstringgrid.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;

function tcustomdbstringgrid.cangridcopy: boolean;
begin
 result:= fdatacols.hasselection;
end;

function tcustomdbstringgrid.getgrid: tcustomwidgetgrid;
begin
 result:= nil;
end;

function tcustomdbstringgrid.getdatapo(const arow: integer): pointer;
begin
 result:= nil;
end;

function tcustomdbstringgrid.getrowdatapo: pointer;
begin
 result:= nil;
end;
{$ifdef mse_with_ifi}
procedure tcustomdbstringgrid.updateifigriddata(const alist: tdatalist);
begin
 //dummy
end;
{$endif}

procedure tcustomdbstringgrid.beforefocuscell(const cell: gridcoordty;
                             const selectaction: focuscellactionty);
begin
 fdatalink.beforefocuscell(cell,selectaction);
end;

{ replaced by oed_limitcharlen
procedure tcustomdbstringgrid.editnotification(var info: editnotificationinfoty);
var
 int1: integer;
begin
 inherited;
 if isdatacell(ffocusedcell) and (info.action = ea_textedited) and
   datacols[ffocusedcell.col].fdatalink.cuttext(feditor.text,int1) then begin
  feditor.text:= copy(feditor.text,1,int1);
 end;
end;
}
function tcustomdbstringgrid.focuscell(cell: gridcoordty;
               selectaction: focuscellactionty = fca_focusin;
               const selectmode: selectcellmodety = scm_cell;
               const ashowcell: cellpositionty = cep_nearest): boolean;
begin
 fdatalink.focuscell(cell);
 result:= inherited focuscell(cell,selectaction,selectmode,ashowcell);
end;

function tcustomdbstringgrid.getfixcols: tdbstringfixcols;
begin
 result:= tdbstringfixcols(inherited fixcols);
end;

procedure tcustomdbstringgrid.setfixcols(const avalue: tdbstringfixcols);
begin
 inherited;
end;

function tcustomdbstringgrid.getassistiveflags(): assistiveflagsty;
begin
 result:= inherited getassistiveflags() + [asf_db];
end;

function tcustomdbstringgrid.getdbindicatorcol: integer;
begin
 result:= fixcols.dbindicatorcol;
end;

procedure tcustomdbstringgrid.coloptionstoeditoptions(var dest: optionseditty;
                                                    var dest1: optionsedit1ty);
begin
 //dummy
end;

function tcustomdbstringgrid.isfirstrow: boolean;
begin
 result:= fdatalink.isfirstrow;
end;

function tcustomdbstringgrid.islastrow: boolean;
begin
 result:= fdatalink.islastrow;
end;

procedure tcustomdbstringgrid.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

procedure tcustomdbstringgrid.setselected(const cell: gridcoordty;
               const avalue: boolean);
begin
 fdatalink.setselected(cell,avalue);
end;

procedure tcustomdbstringgrid.setupeditor(const acell: gridcoordty;
               const focusin: boolean);
begin
 if acell.col >= 0 then begin
  with tdbstringcol(tdatacols1(fdatacols).fitems[acell.col]) do begin
   if (fmaxlength = 0){or not (oed_limitcharlen in fdatalink.foptions)} then begin
    feditor.maxlength:= -1;
   end
   else begin
    feditor.maxlength:= fmaxlength;
   end;
  end;
 end;
 inherited;
end;

function tcustomdbstringgrid.updatesortcol(const avalue: integer): integer;
begin
 result:= inherited updatesortcol(avalue);
 if not fdatalink.updatesortfield(getfieldlink(avalue),getsortdescend(avalue)) then begin
  result:= -1;
 end;
end;

function tcustomdbstringgrid.getfieldlink(const acol: integer): tfielddatalink;
begin
 if (acol < 0) or (acol >= fdatacols.count) then begin
  result:= nil;
 end
 else begin
  result:= tdbstringcol(tdbstringcols(fdatacols).fitems[acol]).fdatalink;
 end;
end;

function tcustomdbstringgrid.canautoappend: boolean;
begin
 result:= inherited canautoappend and fdatalink.canautoinsert;
end;

procedure tcustomdbstringgrid.setnavigator(const avalue: tdbnavigator);
var
 int1: integer;
begin
 for int1:= 0 to fdatacols.count - 1 do begin
  tdbstringcol(tdbstringcols(fdatacols).fitems[int1]).fdatalink.navigator:= avalue;
 end;
end;

function tcustomdbstringgrid.caninsertrow: boolean;
begin
 result:= inherited caninsertrow and fdatalink.caninsert;
end;

function tcustomdbstringgrid.canappendrow: boolean;
begin
 result:= inherited canappendrow and fdatalink.canappend;
end;

function tcustomdbstringgrid.candeleterow: boolean;
begin
 result:= inherited candeleterow and fdatalink.candelete;
end;
{
procedure tcustomdbstringgrid.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tcustomdbstringgrid.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tlbdropdowncol }

procedure tlbdropdowncol.setfieldno(const avalue: lookupbufferfieldnoty);
begin
 if avalue <> ffieldno then begin
  ffieldno:= avalue;
 end;
end;

function tlbdropdowncol.getlbdatakind(const apropname: string): lbdatakindty;
begin
 result:= lbdk_text;
end;

function tlbdropdowncol.getlookupbuffer: tcustomlookupbuffer;
begin
 result:= tcustomlbdropdownlistcontroller(fowner).lookupbuffer;
end;

{ tlbdropdowncols }

function tlbdropdowncols.getitems(const index: integer): tlbdropdowncol;
begin
 result:= tlbdropdowncol(inherited getitems(index));
end;

function tlbdropdowncols.getcolclass: dropdowncolclassty;
begin
 result:= tlbdropdowncol;
end;

{ texterndatadropdownlistcontroller }

constructor texterndatadropdownlistcontroller.create(const intf: ilbdropdownlist);
begin
 inherited create(intf);
 options:= defaulteddropdownoptions;
end;

procedure texterndatadropdownlistcontroller.valuecolchanged;
begin
 //dummy
end;

function texterndatadropdownlistcontroller.getbuttonframeclass:
                                                 dropdownbuttonframeclassty;
begin
 result:= tdropdownmultibuttonframe;
end;

function texterndatadropdownlistcontroller.getdropdowncolsclass:
                                                       dropdowncolsclassty;
begin
 result:= tlbdropdowncols;
end;


procedure texterndatadropdownlistcontroller.dropdown;
begin
 tdropdowncols1(fcols).fitemindex:= -1;
 inherited; 
end;

{ tdbenumeditlb }

function tdbenumeditlb.getdropdown: tlbdropdownlistcontroller;
begin
 result:= tlbdropdownlistcontroller(fdropdown);
end;

procedure tdbenumeditlb.setdropdown(const avalue: tlbdropdownlistcontroller);
begin
 fdropdown.assign(avalue);
end;

function tdbenumeditlb.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tlbdropdownlistcontroller.create(ilbdropdownlist(self));
end;

procedure tdbenumeditlb.recordselected(const arecordnum: integer; const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tlbdropdownlistcontroller(fdropdown) do begin
   text:= flookupbuffer.textvaluephys(cols[0].ffieldno,arecordnum);
   tdropdowncols1(fcols).fitemindex:= 
            flookupbuffer.integervaluephys(fkeyfieldno,arecordnum);
  end; 
  bo1:= checkvalue;
 end
 else begin
  if arecordnum = -2 then begin
   bo1:= checkvalue; 
  end
  else begin
   feditor.undo;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tdbenumeditlb.internaldatatotext(const data): msestring;
var
 int1,int2,int3,int4: integer;
begin
 if @data = nil then begin
  int1:= value;  
 end
 else begin
  int1:= integer(data);
 end;
 with tlbdropdownlistcontroller(fdropdown) do begin
  int3:= cols[valuecol].ffieldno;
  int4:= fkeyfieldno;
 end;
 with dropdown do begin
  if (flookupbuffer <> nil) and (int3 < flookupbuffer.fieldcounttext) and
           (int4 < flookupbuffer.fieldcountinteger) and
           flookupbuffer.find(int4,int1,int2) then begin
   result:= flookupbuffer.textvaluephys(int3,
                 flookupbuffer.integerindex(int4,int2));
  end
  else begin
   result:= '';
  end;
 end;
end;

function tdbenumeditlb.getlbkeydatakind: lbdatakindty;
begin
 result:= lbdk_integer;
end;

{ tenumeditlb }

function tenumeditlb.getdropdown: tlbdropdownlistcontroller;
begin
 result:= tlbdropdownlistcontroller(fdropdown);
end;

procedure tenumeditlb.setdropdown(const avalue: tlbdropdownlistcontroller);
begin
 fdropdown.assign(avalue);
end;

function tenumeditlb.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tlbdropdownlistcontroller.create(ilbdropdownlist(self));
end;

procedure tenumeditlb.recordselected(const arecordnum: integer; const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tlbdropdownlistcontroller(fdropdown) do begin
   text:= flookupbuffer.textvaluephys(cols[0].ffieldno,arecordnum);
   tdropdowncols1(fcols).fitemindex:= 
            flookupbuffer.integervaluephys(fkeyfieldno,arecordnum);
  end; 
  bo1:= checkvalue;
 end
 else begin
  if arecordnum = -2 then begin //empty row selected
   bo1:= checkvalue; 
  end
  else begin
   feditor.undo;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tenumeditlb.internaldatatotext(const data): msestring;
var
 int1,int2,int3,int4: integer;
begin
 if @data = nil then begin
  int1:= value;  
 end
 else begin
  int1:= integer(data);
 end;
 with tlbdropdownlistcontroller(fdropdown) do begin
  int3:= cols[valuecol].ffieldno;
  int4:= fkeyfieldno;
 end;
 with dropdown do begin
  if (flookupbuffer <> nil) and (int3 < flookupbuffer.fieldcounttext) and
           (int4 < flookupbuffer.fieldcountinteger) and
           flookupbuffer.find(int4,int1,int2) then begin
   result:= flookupbuffer.textvaluephys(int3,
                 flookupbuffer.integerindex(int4,int2));
  end
  else begin
   result:= '';
  end;
 end;
end;

function tenumeditlb.getlbkeydatakind: lbdatakindty;
begin
 result:= lbdk_integer;
end;

{$ifdef mse_with_ifi}
function tenumeditlb.getifilink: tifiintegerlinkcomp;
begin
 result:= tifiintegerlinkcomp(fifilink);
end;

procedure tenumeditlb.setifilink1(const avalue: tifiintegerlinkcomp);
begin
 setifilink0(avalue);
end;
{$endif mse_with_ifi}

{ tcustomenum64edit }

constructor tcustomenum64edit.create(aowner: tcomponent);
begin
 fvalue1:= -1;
 fvaluedefault1:= -1;
 inherited;
end;

function tcustomenum64edit.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= tgridenum64datalist.create(sender);
end;

function tcustomenum64edit.getdatalistclass: datalistclassty;
begin
 result:= tgridenum64datalist;
end;

function tcustomenum64edit.getgridvalue(const index: integer): int64;
begin
 internalgetgridvalue(index,result);
end;

procedure tcustomenum64edit.setgridvalue(const index: integer; aValue: int64);
begin
 internalsetgridvalue(index,avalue);
end;

function tcustomenum64edit.getgridvalues: int64arty;
begin
 result:= tint64datalist(fgridintf.getcol.datalist).asarray;
end;

procedure tcustomenum64edit.setgridvalues(const avalue: int64arty);
begin
 tint64datalist(fgridintf.getcol.datalist).asarray:= avalue;
end;

procedure tcustomenum64edit.setvalue(const avalue: int64);
begin
{$warnings off}
 tdropdowncols1(tlbdropdownlistcontroller(fdropdown).cols).fkeyvalue64:= 
                         avalue;
{$warnings on}
 fvalue1:= avalue;
 valuechanged;
end;

function tcustomenum64edit.getdefaultvalue: pointer;
begin
 result:= @fvaluedefault1;
end;

procedure tcustomenum64edit.texttovalue(var accept: boolean; const quiet: boolean);
var
 lint1: int64;
begin
 if (tdropdownlistcontroller(fdropdown).itemindex < 0) and 
                                           (trim(text) = '') then begin
  lint1:= valuedefault;
 end
 else begin
{$warnings off}
  lint1:= tdropdowncols1(tlbdropdownlistcontroller(fdropdown).cols).fkeyvalue64;
{$warnings on}
 end;
   //no checktext call
 if accept then begin
  if not quiet then begin
   if canevent(tmethod(fonsetvalue1)) then begin
    fonsetvalue1(self,lint1,accept);
   end;
{$ifdef mse_with_ifi}
   ifisetvalue(lint1,accept);
{$endif}  
  end;
  if accept then begin
   value:= lint1;
  end;
 end;
end;

procedure tcustomenum64edit.texttodata(const atext: msestring; var data);
begin
 //not supported
end;

procedure tcustomenum64edit.valuetogrid(arow: integer);
begin
 fgridintf.setdata(arow,fvalue1);
end;

procedure tcustomenum64edit.gridtovalue(arow: integer);
begin
 fgridintf.getdata(arow,fvalue1);
 valuetotext;
end;

procedure tcustomenum64edit.readstatvalue(const reader: tstatreader);
begin
 if fgridintf <> nil then begin
  fgridintf.getcol.dostatread(reader);
 end
 else begin
  value:= reader.readint64(valuevarname,value);
 end;
end;

procedure tcustomenum64edit.writestatvalue(const writer: tstatwriter);
begin
 writer.writeint64(valuevarname,value);
end;

{$ifdef mse_with_ifi}
function tcustomenum64edit.getifilink: tifiint64linkcomp;
begin
 result:= tifiint64linkcomp(fifilink);
end;

procedure tcustomenum64edit.setifilink1(const avalue: tifiint64linkcomp);
begin
 setifilink0(avalue);
end;

function tcustomenum64edit.getifidatalinkintf: iifidatalink;
begin
 result:= iifidatalink(self); 
end;

function tcustomenum64edit.getifilinkkind: ptypeinfo;
begin
 result:= typeinfo(iifidatalink);
end;

{$endif mse_with_ifi}

procedure tcustomenum64edit.setnullvalue;
begin
 dropdown.itemindex:= -1;
 nullvalueset();
end;
 { tcustomenum64editlb }
 
function tcustomenum64editlb.getdropdown: tlbdropdownlistcontroller;
begin
 result:= tlbdropdownlistcontroller(fdropdown);
end;

procedure tcustomenum64editlb.setdropdown(const avalue: tlbdropdownlistcontroller);
begin
 fdropdown.assign(avalue);
end;

function tcustomenum64editlb.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tlbdropdownlistcontroller.create(ilbdropdownlist(self));
end;

procedure tcustomenum64editlb.recordselected(const arecordnum: integer; const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tlbdropdownlistcontroller(fdropdown) do begin
   text:= flookupbuffer.textvaluephys(cols[0].ffieldno,arecordnum);
   tdropdowncols1(fcols).fkeyvalue64:= 
            flookupbuffer.int64valuephys(fkeyfieldno,arecordnum);
  end; 
  bo1:= checkvalue;
 end
 else begin
  if arecordnum = -2 then begin //empty row selected
   bo1:= checkvalue; 
  end
  else begin
   feditor.undo;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tcustomenum64editlb.internaldatatotext(const data): msestring;
var
 lint1: int64;
 int2,int3,int4: integer;
begin
 if @data = nil then begin
  lint1:= value;  
 end
 else begin
  lint1:= int64(data);
 end;
 with tlbdropdownlistcontroller(fdropdown) do begin
  int3:= cols[valuecol].ffieldno;
  int4:= fkeyfieldno;
  if (flookupbuffer <> nil) and (int3 < flookupbuffer.fieldcounttext) and
           (int4 < flookupbuffer.fieldcountint64) and
           flookupbuffer.find(int4,lint1,int2) then begin
   result:= flookupbuffer.textvaluephys(int3,
                 flookupbuffer.int64index(int4,int2));
  end
  else begin
   result:= '';
  end;
 end;
end;

function tcustomenum64editlb.getlbkeydatakind: lbdatakindty;
begin
 result:= lbdk_int64;
end;

 { tcustomenum64editdb }
 
function tcustomenum64editdb.getdropdown: tdbdropdownlistcontroller;
begin
 result:= tdbdropdownlistcontroller(fdropdown);
end;

procedure tcustomenum64editdb.setdropdown(const avalue: tdbdropdownlistcontroller);
begin
 fdropdown.assign(avalue);
end;

function tcustomenum64editdb.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tdbdropdownlistcontroller.create(idbdropdownlist(self),false);
end;

procedure tcustomenum64editdb.recordselected(
                   const arecordnum: integer; const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tdbdropdownlistcontroller(fdropdown) do begin
   text:= getasmsestring(fdatalink.textfield,fdatalink.utf8);
   tdropdowncols1(fcols).fkeyvalue64:= getaslargeint(fdatalink.valuefield)
  end; 
  bo1:= checkvalue;
 end
 else begin
  if arecordnum = -2 then begin
   text:= '';
   bo1:= checkvalue; 
  end
  else begin
   feditor.undo;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tcustomenum64editdb.internaldatatotext(const data): msestring;
var
 lint1: int64;
begin
 if @data = nil then begin
  lint1:= value;  
 end
 else begin
  lint1:= int64(data);
 end;
 result:= tdbdropdownlistcontroller(fdropdown).fdatalink.getlookuptext(lint1);
end;

{ tdbenum64editlb }

constructor tdbenum64editlb.create(aowner: tcomponent);
begin
 fdatalink:= tlookupeditdatalink.create(self,ldt_int64,idbeditfieldlink(self));
 inherited;
end;

destructor tdbenum64editlb.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbenum64editlb.modified;
begin
 fdatalink.modified;
 inherited;
end;

procedure tdbenum64editlb.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
function tdbenum64editlb.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
// frame.readonly:= oe_readonly in result;
end;
}
procedure tdbenum64editlb.valuetofield;
begin
 if value = -1 then begin
  fdatalink.field.clear;
  if fdatalink.fieldtext <> nil then begin
   fdatalink.fieldtext.clear;
  end;
 end
 else begin
  fdatalink.field.aslargeint:= value;
  setasmsestring(text,fdatalink.fieldtext,fdatalink.utf8)
 end;
end;

procedure tdbenum64editlb.fieldtovalue;
begin
 if fdatalink.field.isnull then begin
  value:= fvaluedefault1;
 end
 else begin
  value:= fdatalink.field.aslargeint;
 end;
end;

function tdbenum64editlb.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).
                   getint64buffer(fdatalink.field,arow);
  if result = nil then begin
   result:= @fvaluedefault;
  end;
 end
 else begin
  result:= @fvaluedefault;
 end;
end;

function tdbenum64editlb.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbenum64editlb.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbenum64editlb.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbenum64editlb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

procedure tdbenum64editlb.setdatalink(const avalue: tlookupeditdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbenum64editlb.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

function tdbenum64editlb.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tdbenum64editlb.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbenum64editlb.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
function tdbenum64editlb.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbenum64editlb.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbenum64editlb.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbenum64editdb }

constructor tdbenum64editdb.create(aowner: tcomponent);
begin
 fdatalink:= tlookupeditdatalink.create(self,ldt_int64,idbeditfieldlink(self));
 inherited;
end;

destructor tdbenum64editdb.destroy;
begin
 inherited;
 fdatalink.free;
end;

procedure tdbenum64editdb.modified;
begin
 fdatalink.modified;
 inherited;
end;

procedure tdbenum64editdb.doshortcut(var info: keyeventinfoty;
               const sender: twidget);
begin
 fdatalink.doshortcut(info,sender);
 if not (es_processed in info.eventstate) then begin
  inherited;
 end;
end;
{
function tdbenum64editdb.getoptionsedit: optionseditty;
begin
 result:= inherited getoptionsedit;
 fdatalink.updateoptionsedit(result);
// frame.readonly:= oe_readonly in result;
end;
}
procedure tdbenum64editdb.valuetofield;
begin
 if value = -1 then begin
  fdatalink.field.clear;
  if fdatalink.fieldtext <> nil then begin
   fdatalink.fieldtext.clear;
  end;
 end
 else begin
  fdatalink.field.aslargeint:= value;
  setasmsestring(text,fdatalink.fieldtext,fdatalink.utf8)
 end;
end;

procedure tdbenum64editdb.fieldtovalue;
begin
 if fdatalink.field.isnull then begin
  value:= fvaluedefault1;
 end
 else begin
  value:= fdatalink.field.aslargeint;
 end;
end;

function tdbenum64editdb.getrowdatapo(const arow: integer): pointer;
begin
 if fgriddatalink <> nil then begin
  result:= tgriddatalink(fgriddatalink).
                   getint64buffer(fdatalink.field,arow);
  if result = nil then begin
   result:= @fvaluedefault;
  end;
 end
 else begin
  result:= @fvaluedefault;
 end;
end;

function tdbenum64editdb.createdatalist(const sender: twidgetcol): tdatalist;
begin
 result:= nil;
end;

procedure tdbenum64editdb.griddatasourcechanged;
begin
 fdatalink.griddatasourcechanged;
end;

function tdbenum64editdb.getgriddatasource: tdatasource;
begin
 result:= tcustomdbwidgetgrid(fgridintf.getcol.grid).datalink.datasource;
end;

procedure tdbenum64editdb.getfieldtypes(var afieldtypes: fieldtypesty);
begin
 afieldtypes:= integerfields;
end;

procedure tdbenum64editdb.setdatalink(const avalue: tlookupeditdatalink);
begin
 fdatalink.assign(avalue);
end;

procedure tdbenum64editdb.defineproperties(filer: tfiler);
begin
 inherited;
 fdatalink.fixupproperties(filer);  //move values to datalink
end;

function tdbenum64editdb.nullcheckneeded(const newfocus: twidget): boolean;
begin
 result:= inherited nullcheckneeded(newfocus);
 fdatalink.nullcheckneeded(result);
end;

procedure tdbenum64editdb.recchanged;
begin
 fdatalink.recordchanged(nil);
end;
{
procedure tdbenum64editdb.dochange;
begin
 fdatalink.datachanged;
 inherited;
end;
}
function tdbenum64editdb.getfieldlink: tcustomeditwidgetdatalink;
begin
 result:= fdatalink;
end;
{
procedure tdbenum64editdb.doenter;
begin
 fdatalink.doenter(self);
 inherited;
end;

procedure tdbenum64editdb.doexit;
begin
 fdatalink.doexit(self);
 inherited;
end;
}
{ tdbkeystringeditlb }

function tdbkeystringeditlb.getdropdown: tlbdropdownlistcontroller;
begin
 result:= tlbdropdownlistcontroller(fdropdown);
end;

procedure tdbkeystringeditlb.setdropdown(const avalue: tlbdropdownlistcontroller);
begin
 fdropdown.assign(avalue);
end;

function tdbkeystringeditlb.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tlbdropdownlistcontroller.create(ilbdropdownlist(self));
end;

procedure tdbkeystringeditlb.recordselected(const arecordnum: integer;
                                   const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tlbdropdownlistcontroller(fdropdown) do begin
   text:= flookupbuffer.textvaluephys(cols[0].ffieldno,arecordnum);
   tdropdowncols1(fcols).fitemindex:= arecordnum;
   tdropdowncols1(fcols).fkeyvalue:= 
                           flookupbuffer.textvaluephys(fkeyfieldno,arecordnum);
  end; 
  bo1:= checkvalue;
 end
 else begin
  if arecordnum = -2 then begin
   bo1:= checkvalue; 
  end
  else begin
   feditor.undo;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tdbkeystringeditlb.internaldatatotext(const data): msestring;
var
 mstr1: msestring;
 int2,int3,int4: integer;
begin
 if @data = nil then begin
  mstr1:= value;  
 end
 else begin
  mstr1:= msestring(data);
 end;
 with tlbdropdownlistcontroller(fdropdown) do begin
  int3:= cols[valuecol].ffieldno;
  int4:= fkeyfieldno;
 end;
 with dropdown do begin
  if (flookupbuffer <> nil) and (int3 < flookupbuffer.fieldcounttext) and
           (int4 < flookupbuffer.fieldcounttext) and
           flookupbuffer.find(int4,mstr1,int2,false) then begin
   result:= flookupbuffer.textvaluephys(int3,
                 flookupbuffer.textindex(int4,int2,false));
  end
  else begin
   result:= '';
  end;
 end;
end;

function tdbkeystringeditlb.getlbkeydatakind: lbdatakindty;
begin
 result:= lbdk_text;
end;

{ tkeystringeditlb }

function tkeystringeditlb.getdropdown: tlbdropdownlistcontroller;
begin
 result:= tlbdropdownlistcontroller(fdropdown);
end;

procedure tkeystringeditlb.setdropdown(const avalue: tlbdropdownlistcontroller);
begin
 fdropdown.assign(avalue);
end;

function tkeystringeditlb.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tlbdropdownlistcontroller.create(ilbdropdownlist(self));
end;

procedure tkeystringeditlb.recordselected(const arecordnum: integer; 
                       const akey: keyty);
var
 bo1: boolean;
begin
 bo1:= false;
 if arecordnum >= 0 then begin
  with tlbdropdownlistcontroller(fdropdown) do begin
   text:= flookupbuffer.textvaluephys(cols[0].ffieldno,arecordnum);
   tdropdowncols1(fcols).fitemindex:= arecordnum;
   tdropdowncols1(fcols).fkeyvalue:= 
            flookupbuffer.textvaluephys(fkeyfieldno,arecordnum);
  end; 
  bo1:= checkvalue;
 end
 else begin
  if arecordnum = -2 then begin
   bo1:= checkvalue; 
  end
  else begin
   feditor.undo;
  end;
 end;
 if bo1 and (akey = key_tab) then begin
  window.postkeyevent(akey);
 end;
end;

function tkeystringeditlb.internaldatatotext(const data): msestring;
var
 mstr1: msestring;
 int2,int3,int4: integer;
begin
 if @data = nil then begin
  mstr1:= value;  
 end
 else begin
  mstr1:= msestring(data);
 end;
 with tlbdropdownlistcontroller(fdropdown) do begin
  int3:= cols[valuecol].ffieldno;
  int4:= fkeyfieldno;
 end;
 with dropdown do begin
  if (flookupbuffer <> nil) and (int3 < flookupbuffer.fieldcounttext) and
           (int4 < flookupbuffer.fieldcounttext) and
           flookupbuffer.find(int4,mstr1,int2,false) then begin
   result:= flookupbuffer.textvaluephys(int3,
                 flookupbuffer.textindex(int4,int2,false));
  end
  else begin
   result:= '';
  end;
 end;
end;

function tkeystringeditlb.getlbkeydatakind: lbdatakindty;
begin
 result:= lbdk_text;
end;

{ tcopydropdownlist }

function tcopydropdownlist.locate(const filter: msestring): boolean;
var
 int1: integer;
 po1: pointer;
 co1: gridcoordty;
begin
 po1:= cols[0].datalist.datapo; //workaround internal error 200304235 in 2.0.2
 result:= findarrayvalue(filter,po1,sizeof(msestring),rowcount,
                                                  @compareimsestring,int1);
 if not result then begin
  result:= (int1 < rowcount) and (msecomparetextlen(filter,cols[0][int1]) = 0);
 end;
 if not result then begin
  inc(int1);
  result:= (int1 < rowcount) and (msecomparetextlen(filter,cols[0][int1]) = 0);
 end;
 if result then begin
  co1:= makegridcoord(ffocusedcell.col,int1);
  showcell(co1,cep_top);
  focuscell(makegridcoord(ffocusedcell.col,int1));
 end
 else begin
  focuscell(makegridcoord(ffocusedcell.col,-1));
 end;
end;

{ tlbdropdownstringcol }

function tlbdropdownstringcol.getrowtext(const arow: integer): msestring;
var
 int1: integer;
begin
 int1:= tlbdropdownlist(fcellinfo.grid).getrecno(arow);
 if int1 >= 0 then begin
  if funsorted then begin
   result:= flookupbuffer.textvaluephys(ffieldno,int1);
  end
  else begin
   result:= flookupbuffer.textvaluephys(ffieldno,
          flookupbuffer.textindex(fsortfieldno,int1,true));
  end;
 end
 else begin
  result:= '';
 end; 
end;

{ texterndatadropdownlist }

constructor texterndatadropdownlist.create(
     const acontroller: texterndatadropdownlistcontroller; acols: tdropdowncols);
var
 int1: integer;
begin
 inherited create(acontroller,acols,nil);
 include(fstate,gs_isdb);
 int1:= acontroller.dropdownrowcount;
 if (edds_filtered in feddstate) then begin
  resyncfilter;
 end
 else begin
  if int1 > acontroller.getremoterowcount then begin
   int1:= acontroller.getremoterowcount;
   frame.sbvert.options:= frame.sbvert.options-[sbo_show];
  end;
  rowcount:= int1;
 end;
 if rowcount > 0 then begin
  row:= 0;
 end;
 with frame.sbvert do begin
  buttonlength:= 0;
  if acontroller.getremoterowcount > 0 then begin
   pagesize:= rowcount / acontroller.getremoterowcount;
  end;
 end;
end;

procedure texterndatadropdownlist.resyncfilter;
var
 int1,int2,int3: integer;
begin
 int1:= fcontroller.dropdownrowcount;
 rowcount:= int1; //init frecnums;
 int3:= -1;
 for int2:= 0 to rowcount - 1 do begin
  findnext(int3);
  if int3 < 0 then begin
   int1:= int2;
   break;
  end;
  frecnums[int2]:= int3;
 end;
 ffirstrecord:= frecnums[0];
 if int3 < 0 then begin
  frame.sbvert.options:= frame.sbvert.options-[sbo_show];
  rowcount:= int1;
 end
 else begin
  frame.sbvert.options:= frame.sbvert.options+[sbo_show];
 end;
end;

procedure texterndatadropdownlist.filterchanged;
begin
 if (edds_filtered in feddstate) then begin
  resyncfilter;
 end;
end;
 
procedure texterndatadropdownlist.dbscrolled(distance: integer);
var
 rect1: rectty;
// int1: integer;
begin
 if abs(distance) >= rowcount then begin
  invalidate;
 end
 else begin
  if distance <> 0 then begin
   rect1:= fdatarecty;
   rect1.cy:= rowcount*ystep;
   scrollrect(makepoint(0,-distance*ystep),rect1,true);
  end;
 end;
end;

procedure texterndatadropdownlist.moveby(distance: integer);
var
 int1,int2,int3,int4,int5,int6: integer;
 rowbefore: integer;
 rea1: real;
 ar1: integerarty;
begin
 if rowcount = 0 then begin
  exit;
 end;
 rowbefore:= row;
 int1:= row + distance;
 if int1 < 0 then begin
  if (edds_filtered in feddstate) then begin
   setlength(ar1,rowcount);
   int4:= 0;
   for int3:= -int1-1 downto 0 do begin
    int2:= ffirstrecord;
    findprev(ffirstrecord);
    if ffirstrecord < 0 then begin
     ffirstrecord:= int2;
     break;
    end;
    if int3 <= high(ar1) then begin
     ar1[int3]:= ffirstrecord;
    end;
    dec(int4);
   end;
   if int4 <> int1 then begin
    include(feddstate,edds_bof);
    int2:= ffirstrecord;
    frecnums[0]:= int2;
    for int3:= 1 to rowhigh do begin
     findnext(int2);
     if int2 < 0 then begin
      for int6:= int3 to high(frecnums) do begin
       frecnums[int6]:= -1;
      end;
      break;
     end;
     frecnums[int3]:= int2;
    end; 
   end
   else begin
    exclude(feddstate,edds_bof);
    if int4 <= - rowcount then begin
     frecnums:= ar1;
    end
    else begin
     move(frecnums[0],frecnums[-int4],(length(frecnums)+int4)*sizeof(integer));
     move(ar1[int1-int4],frecnums[0],-int4*sizeof(integer));
    end;
   end;
   int1:= int4;
  end
  else begin
   ffirstrecord:= ffirstrecord + int1;
   if ffirstrecord < 0 then begin
    int1:= int1 - ffirstrecord;
    ffirstrecord:= 0;
   end;
  end;
  dbscrolled(int1);
  dec(rowbefore,int1);
  row:= 0;
 end
 else begin
  if int1 >= rowcount then begin
   int1:= int1 - rowcount + 1;
   if (edds_filtered in feddstate) then begin
    setlength(ar1,rowcount);
    int5:= frecnums[rowcount-1];
    int4:= 0;
    for int3:= 0 to int1-1 do begin
     int2:= int5;
     findnext(int5);
     if int5 < 0 then begin
      int5:= int2;
      break;
     end;
     inc(int4);
     int6:= int1 - int4;
     if int6 <= high(ar1) then begin
      ar1[high(ar1)-int6]:= int5;
     end;
    end;
    if int4 <> int1 then begin
     include(feddstate,edds_eof);
     frecnums[rowhigh]:= int5;
     for int3:= rowhigh - 1 downto 0 do begin
      findprev(int5);
      if int5 < 0 then begin
       for int6:= int3 downto 0 do begin
        frecnums[int6]:= -1;
       end;
       break;
      end;
      frecnums[int3]:= int5;
     end;
    end
    else begin
     exclude(feddstate,edds_eof);
     if int4 >= rowcount then begin
      frecnums:= ar1;
     end
     else begin
      move(frecnums[int4],frecnums[0],(rowcount-int4)*sizeof(integer));
      move(ar1[rowcount-int1],frecnums[rowcount-int4],int4*sizeof(integer));
     end;
    end;
    ffirstrecord:= frecnums[0];
    int1:= int4;
   end
   else begin
    ffirstrecord:= ffirstrecord + int1;
    int2:= ffirstrecord + rowcount - 
             texterndatadropdownlistcontroller(fcontroller).getremoterowcount;
    if int2 > 0 then begin
     int1:= int1 - int2;
     ffirstrecord:= ffirstrecord - int2;
    end;
   end;
   dbscrolled(int1);
   dec(rowbefore,int1);
   row:= rowcount - 1;
  end
  else begin
   row:= row + distance;
  end;
 end;
 invalidaterow(rowbefore);
 invalidaterow(row);
 if (col >= 0) and (row >= 0) then begin
  feditor.text:= tlbdropdownstringcol(fdatacols[col]).getrowtext(row);
 end
 else begin
  feditor.text:= '';
 end;
 int1:= texterndatadropdownlistcontroller(fcontroller).getremoterowcount - 1;
 if int1 <= 0 then begin
  rea1:= 0.5;
 end
 else begin
  if (edds_filtered in feddstate) then begin
   if edds_eof in feddstate then begin
    rea1:= 1;
   end
   else begin
    if edds_bof in feddstate then begin
     rea1:= 0;
    end
    else begin
     rea1:= 0.5;
    end;
   end;
  end
  else begin
   rea1:= activerecord / int1;
  end;
 end;
 frame.sbvert.value:= rea1;
end;

procedure texterndatadropdownlist.pagedown(const action: focuscellactionty = fca_focusin);
begin
 moveby(rowcount-1);
end;

procedure texterndatadropdownlist.pageup(const action: focuscellactionty = fca_focusin);
begin
 moveby(-rowcount+1);
end;

procedure texterndatadropdownlist.wheeldown(const action: focuscellactionty = fca_focusin);
begin
 MoveBy(wheelheight);
end;

procedure texterndatadropdownlist.wheelup(const action: focuscellactionty = fca_focusin);
begin
 MoveBy(-wheelheight);
end;

procedure texterndatadropdownlist.rowdown(
  const action: focuscellactionty = fca_focusin; const nowrap: boolean = false);
begin
 moveby(1);
end;

procedure texterndatadropdownlist.rowup(
  const action: focuscellactionty = fca_focusin; const nowrap: boolean = false);
begin
 moveby(-1);
end;

function texterndatadropdownlist.getactiverecord: integer;
begin
 if (edds_filtered in feddstate) then begin
  result:= frecnums[row];
 end
 else begin
  result:= ffirstrecord + row;
 end;
end;

procedure texterndatadropdownlist.setactiverecord(const avalue: integer);
var
 int1,int2,int3: integer;
begin
 if rowcount > 0 then begin
  if (edds_filtered in feddstate) then begin
   if ffirstrecord >= 0 then begin
    for int1:= 0 to high(frecnums) do begin
     if frecnums[int1] = avalue then begin
      if int1 > 0 then begin
       exclude(feddstate,edds_bof);
      end; 
      if int1 < rowhigh then begin
       exclude(feddstate,edds_eof);
      end; 
      moveby(int1-row);
      exit;
     end;
    end;
   end;
   ffirstrecord:= avalue;
   int2:= avalue;
   frecnums[0]:= int2;
   for int1:= 1 to rowhigh do begin
    findnext(int2);
    if int2 < 0 then begin
     move(frecnums[0],frecnums[rowcount-int1],int1*sizeof(integer));
     int2:= avalue;
     for int3:= rowhigh - int1 downto 0 do begin
      findprev(int2);
      frecnums[int3]:= int2;
     end;
     ffirstrecord:= frecnums[0];
     invalidate;
     moveby((rowcount - int1)-row);
     exit;
    end;
    frecnums[int1]:= int2
   end;
   invalidate;
   moveby(-row);
  end
  else begin
   if ffirstrecord < 0 then begin
    ffirstrecord:= avalue;   
    int1:= texterndatadropdownlistcontroller(fcontroller).getremoterowcount;
    if ffirstrecord + rowcount > int1 then begin
     ffirstrecord:= int1 - rowcount;
    end;
    moveby(avalue-ffirstrecord-row);
    invalidate;
   end
   else begin
    moveby(avalue-activerecord);
   end;
  end;
 end;
end;

procedure texterndatadropdownlist.internalcreateframe;
begin
 tdbgridframe.create(iscrollframe(self),self,iautoscrollframe(self));
end;

procedure texterndatadropdownlist.createdatacol(const index: integer;
                                                      out item: tdatacol);
begin
 item:= tlbdropdownstringcol.create(self,fdatacols);
end;

procedure texterndatadropdownlist.docellevent(var info: celleventinfoty);
begin
 inherited;
 with info do begin
  if (eventkind = cek_enter) and active then begin
   if (edds_filtered in feddstate) then begin
    activerecord:= frecnums[newcell.row];
   end
   else begin
    activerecord:= ffirstrecord + newcell.row;
   end;
  end;
 end;
end;

procedure texterndatadropdownlist.scrollevent(sender: tcustomscrollbar; event: scrolleventty);
var
 int1: integer;
 bo1: boolean;
begin
 bo1:= true;
 if sender.tag = 1 then begin
  case event of
   sbe_stepup: rowdown(fca_focusin);
   sbe_stepdown: rowup(fca_focusin);
   sbe_pageup: pagedown(fca_focusin);
   sbe_pagedown: pageup(fca_focusin);
   sbe_wheelup: wheeldown(fca_focusin);
   sbe_wheeldown: wheelup(fca_focusin);
   sbe_valuechanged: begin end;
   sbe_thumbtrack,sbe_thumbposition: begin
    int1:= texterndatadropdownlistcontroller(fcontroller).getremoterowcount - 1;
    if int1 >= 0 then begin
     if (edds_filtered in feddstate) then begin
      if event <> sbe_thumbtrack then begin
       if sender.value <= 0 then begin
        moveby(minint);
       end
       else begin
        if sender. value >= 1 then begin
         moveby(maxint);
        end
        else begin
         if sender.value < 0.5 then begin
          moveby(-rowhigh);
         end
         else begin
          moveby(rowhigh);
         end;
        end;
       end;
      end;
     end
     else begin 
      activerecord:= round(int1 * sender.value);
     end;
    end
    else begin
     sender.value:= 0.5;
    end;
   end;
   else begin
    bo1:= false;
   end;
  end;
 end
 else begin
  bo1:= false;
 end;
 if not bo1 then begin
  inherited;
 end;
end;

procedure texterndatadropdownlist.dorowcountchanged(const countbefore: integer;
                                      const newcount: integer);
var
 int1: integer;
begin
 inherited;
 setlength(frecnums,newcount);
 for int1:= countbefore to newcount - 1 do begin
  frecnums[int1]:= -1;
 end;
end;

procedure texterndatadropdownlist.findprev(var recno: integer);
var
 bo1: boolean;
begin
 with texterndatadropdownlistcontroller(fcontroller) do begin
  repeat
   dec(recno);
   if recno < 0 then begin
    recno:= -1;
    break;
   end;
   bo1:= true;
   dofilter(recno,bo1);
  until bo1;
 end;
end;

function texterndatadropdownlist.getrecno(const aindex: integer): integer;
//var
// int1{,int2}: integer;
begin
 if (edds_filtered in feddstate) then begin
  result:= frecnums[aindex];
 end
 else begin
  result:= ffirstrecord + aindex;
 end;
end;

procedure texterndatadropdownlist.dokeydown(var info: keyeventinfoty);
begin
 with info do begin
  if shiftstate = [ss_ctrl] then begin
   include(info.eventstate,es_processed);
   case key of
    key_pageup: begin
     moveby(-bigint);
    end;
    key_pagedown: begin
     moveby(bigint);
    end
    else begin
     exclude(eventstate,es_processed);
    end;
   end;
  end;
  if not (es_processed in eventstate) then begin
   inherited;
  end;
 end;
end;

{ tlbdropdownlist }

constructor tlbdropdownlist.create(
     const acontroller: tcustomlbdropdownlistcontroller; acols: tdropdowncols);
begin
 if assigned(acontroller.fonfilter) then begin
  include(feddstate,edds_filtered);
 end;
 inherited create(acontroller,acols);
end;

procedure tlbdropdownlist.initcols(const acols: tdropdowncols);
var
 int1: integer;
 lookupbuffer1: tcustomlookupbuffer;
begin
 inherited;
 with tcustomlbdropdownlistcontroller(fcontroller) do begin
  lookupbuffer1:= lookupbuffer;
  fsortfieldno:= cols[0].ffieldno;
 end;
 for int1:= 0 to fdatacols.count - 1 do begin
  with tlbdropdownstringcol(fdatacols[int1]) do begin
   flookupbuffer:= lookupbuffer1;
   fsortfieldno:= tcustomlbdropdownlistcontroller(fcontroller).fsortfieldno;
   ffieldno:= tlbdropdowncol(acols[int1]).ffieldno;
   funsorted:= olb_unsorted in 
                           tlbdropdownlistcontroller(fcontroller).foptionslb;
  end;
 end;
end;

function tlbdropdownlist.locate(const filter: msestring): boolean;
var
 int1: integer;
begin
 int1:= 0;
 result:= false;
 if (datacols.count > 0) then begin
  with tlbdropdownstringcol(datacols[0]) do begin
   result:= flookupbuffer.find(ffieldno,filter,int1,true,
              tcustomlbdropdownlistcontroller(fcontroller).fonfilter);
   if not result then begin
    result:= (int1 < flookupbuffer.count) and 
            (msepartialcomparetext(filter,
             flookupbuffer.textvaluelog(ffieldno,int1,true)) = 0);
   end;
   if funsorted then begin
    int1:= flookupbuffer.textindex(ffieldno,int1,true); //get phys recno
   end;
  end;
 end;
 if not result then begin
  focuscell(makegridcoord(ffocusedcell.col,-1));
 end
 else begin
  ffirstrecord:= -1;
  activerecord:= int1;
 end;
end;

procedure tlbdropdownlist.findnext(var recno: integer);
var
 bo1: boolean;
begin
 with tcustomlbdropdownlistcontroller(fcontroller) do begin
  repeat
   inc(recno);
   if recno >= flookupbuffer.count then begin
    recno:= -1;
    break;
   end;
   bo1:= true;
   dofilter(recno,bo1);
  until bo1;
 end;
end;

{ tcustomlbdropdownlistcontroller }

function tcustomlbdropdownlistcontroller.getcols: tlbdropdowncols;
begin
 result:= tlbdropdowncols(fcols);
end;

procedure tcustomlbdropdownlistcontroller.setcols(const avalue: tlbdropdowncols);
begin
 fcols.assign(avalue);
end;

procedure tcustomlbdropdownlistcontroller.dofilter(var recno: integer;
               var accept: boolean);
begin
 fonfilter(flookupbuffer,flookupbuffer.textindex(fsortfieldno,recno,true),accept);
end;

function tcustomlbdropdownlistcontroller.reloadlist: integer;
var
 int1,int2,int3,int4: integer;
 sortfieldno: integer;
 bo1: boolean;
 po1: pmsestringaty;
 ar1: msestringarty;
begin
 result:= 0;
 if assigned(fonbeforefilter) then begin
  fonbeforefilter(tcustomdataedit(fintf.getwidget));
 end;
 if olb_copyitems in foptionslb then begin
  flookupbuffer.checkbuffer; //possibly load buffer
  sortfieldno:= cols[0].fieldno;
  setlength(fedrecnums,flookupbuffer.count);
  if assigned(fonfilter) then begin
   int3:= 0;
   for int1:= 0 to high(fedrecnums) do begin
    if olb_unsorted in foptionslb then begin
     int4:= int1;
    end
    else begin
     int4:= flookupbuffer.textindex(sortfieldno,int1,true);
    end;
    bo1:= true;
    fonfilter(flookupbuffer,int4,bo1);
    if bo1 then begin
     fedrecnums[int3]:= int4;
     inc(int3);
    end;
   end;
   setlength(fedrecnums,int3);
  end
  else begin
   if olb_unsorted in foptionslb then begin
    setlength(fedrecnums,flookupbuffer.count);
    for int1:= 0 to high(fedrecnums) do begin
     fedrecnums[int1]:= int1;
    end;
   end
   else begin
    fedrecnums:= flookupbuffer.textindexar(sortfieldno,true);
   end;
  end;
  for int1:= 0 to fcols.count - 1 do begin
   with cols[int1] do begin
    count:= length(fedrecnums);
    int2:= fieldno;
    po1:= datapo;
    ar1:= flookupbuffer.textar(int2);
    for int3:= 0 to high(fedrecnums) do begin
     po1^[int3]:= ar1[fedrecnums[int3]];
    end;
   end;
  end;
 end
 else begin
  tlbdropdownlist(fdropdownlist).filterchanged;
 end;
end;

function  tcustomlbdropdownlistcontroller.createdropdownlist: tdropdownlist;
begin
 if olb_copyitems in foptionslb then begin
  reloadlist;
  if olb_unsorted in foptionslb then begin
   result:= tdropdownlist.create(self,fcols,nil); //normal locate
  end
  else begin
   result:= tcopydropdownlist.create(self,fcols,nil);
  end;
 end
 else begin
  result:= tlbdropdownlist.create(self,fcols);
 end;
end;

function tcustomlbdropdownlistcontroller.candropdown: boolean;
begin
 result:= (flookupbuffer <> nil) and (flookupbuffer.count > 0) and
                 (fcols.count > 0) and inherited candropdown;
end;

procedure tcustomlbdropdownlistcontroller.itemselected(const index: integer;
                             const akey: keyty);
var
 int1: integer;
begin
 int1:= index;
 if index < 0 then begin
  if index = -2 then begin
   tdropdowncols1(fcols).fitemindex:= fintf.getvalueempty;
  end;
 end
 else begin
  if olb_copyitems in foptionslb then begin
   int1:= fedrecnums[int1];
   cols.clear;
   fedrecnums:= nil;
  end
  else begin
   int1:= tlbdropdownlist(fdropdownlist).getrecno(index);
   if not (olb_unsorted in foptionslb) then begin
    int1:= flookupbuffer.textindex(cols[0].fieldno,int1,true)
   end;
  end;
  tdropdowncols1(fcols).fitemindex:= int1;
 end;
 ilbdropdownlist(fintf).recordselected(int1,akey);
 if olb_copyitems in foptionslb then begin
  cols.clear;
  fedrecnums:= nil;
 end;
// ilbdropdownlist(fintf).recordselected(int1,akey);
end;

function tcustomlbdropdownlistcontroller.getremoterowcount: integer;
begin
 result:= flookupbuffer.count;
end;

procedure tcustomlbdropdownlistcontroller.setlookupbuffer(
                   const avalue: tcustomlookupbuffer);
begin
 setlinkedvar(avalue,tmsecomponent(flookupbuffer));
end;

procedure tcustomlbdropdownlistcontroller.objectevent(const sender: tobject;
             const event: objecteventty);
begin
 inherited;
 if (event in [oe_changed,oe_connect]) and (sender = flookupbuffer) 
           and not (csloading in flookupbuffer.componentstate) then begin
  with tdataedit1(fintf.getwidget) do begin
   if fgridintf <> nil then begin
    fgridintf.getcol.changed;
  {$ifdef FPC} {$checkpointer off} {$endif}
    feditor.text:= datatotext(nil^);
  {$ifdef FPC} {$checkpointer default} {$endif}
   end
   else begin
 {$ifdef FPC} {$checkpointer off} {$endif}
    feditor.text:= datatotext(nil^);
 {$ifdef FPC} {$checkpointer default} {$endif}
   end;
  end;
  updatereadonlystate;
 end;
end;

function tcustomlbdropdownlistcontroller.getlbdatakind(const apropname: string): lbdatakindty;
begin
 result:= ilbdropdownlist(fintf).getlbkeydatakind;
end;

function tcustomlbdropdownlistcontroller.getlookupbuffer: tcustomlookupbuffer;
begin
 result:= flookupbuffer;
end;

{ tlookupeditdatalink }

constructor tlookupeditdatalink.create(const aowner: tcustomdataedit;
              const adatatype: lookupdatatypety; const intf: idbeditfieldlink);
begin
 inherited create(intf);
 fowner:= aowner;
 fdatatype:= adatatype; 
end;

function tlookupeditdatalink.msedisplaytext(const aformat: msestring = '';
               const aedit: boolean = false): msestring;
var
 i1: int32;
 li1: int64;
 s1: msestring;
begin
 if fowner <> nil then begin
  result:= '';
  if (field <> nil) and not field.isnull then begin
   case fdatatype of
    ldt_int32: begin
     i1:= field.asinteger;
     result:= tcustomdataedit1(fowner).internaldatatotext(i1);
    end;
    ldt_int64: begin
     li1:= field.aslargeint;
     result:= tcustomdataedit1(fowner).internaldatatotext(li1);
    end;
    ldt_string: begin
     s1:= field.asunicodestring;
     result:= tcustomdataedit1(fowner).internaldatatotext(s1);
    end;
   end;
  end;
 end
 else begin
  result:= inherited msedisplaytext(aformat,aedit);
 end;
end;

procedure tlookupeditdatalink.setfieldnametext(const avalue: string);
begin
 if ffieldnametext <> avalue then begin
  ffieldnametext :=  avalue;
  updatefields;
 end;
end;

procedure tlookupeditdatalink.updatefields;
begin
 if active and (ffieldnametext <> '') then begin
  ffieldtext:= datasource.dataset.fieldbyname(ffieldnametext);
 end
 else begin
  ffieldtext:= nil;
 end;
 inherited;
end;

procedure tlookupeditdatalink.getfieldtypes(out apropertynames: stringarty;
               out afieldtypes: fieldtypesarty);
begin
 inherited;
 setlength(apropertynames,2);
 apropertynames[0]:= 'fieldname';
 apropertynames[1]:= 'fieldnametext';
 setlength(afieldtypes,2);
 afieldtypes[1]:= textfields;
end;

function tlookupeditdatalink.getsortfield: tfield;
begin
 if ffieldtext = nil then begin
  updatefields;
 end;
 result:= ffieldtext;
 if result = nil then begin
  result:= inherited getsortfield;
 end;
end;

{ tdbnavigbutton }

procedure tdbnavigbutton.readtag(reader: treader);
begin
 reader.readinteger; //dummy
end;

procedure tdbnavigbutton.defineproperties(filer: tfiler);
begin
 inherited;              //backward compatibility
 filer.defineproperty('tag',{$ifdef FPC}@{$endif}readtag,nil,false);
end;

{ tdbwidgetcols }

class function tdbwidgetcols.getitemclasstype: persistentclassty;
begin
 result:= tdbwidgetcol;
end;

function tdbwidgetcols.getcols(const index: integer): tdbwidgetcol;
begin
 result:= tdbwidgetcol(items[index]);
end;

{ tdbwidgetcol }

procedure tdbwidgetcol.setwidget(const awidget: twidget);
var
 intf1: idbeditfieldlink;
 intf2: idbdispfieldlink;
begin
 inherited;
 if (awidget <> nil) then begin 
  if awidget.getcorbainterface(typeinfo(idbeditfieldlink),intf1) then begin
   fdatalink:= intf1.getfieldlink();
   if fdatalink <> nil then begin
    tcustomeditwidgetdatalink(fdatalink).navigator:= 
                            tdbwidgetgrid(fcellinfo.grid).fdatalink.navigator;
   end;
  end
  else begin
   if awidget.getcorbainterface(typeinfo(idbdispfieldlink),intf2) then begin
    fdatalink:= intf2.getfieldlink();
   end;
  end;
 end
 else begin
  fdatalink:= nil;
 end;
end;

procedure tdbwidgetcol.dobeforedrawcell(const acanvas: tcanvas;
               var processed: boolean);
var
 info: gridrowinfoty;
begin
 tcustomdbwidgetgrid(grid).fdatalink.begingridrow(
                                   fcellinfo.cell.row,info);
 try
  inherited;
 finally
  tcustomdbwidgetgrid(grid).fdatalink.endgridrow(info);
 end;
end;

procedure tdbwidgetcol.doafterdrawcell(const acanvas: tcanvas);
var
 info: gridrowinfoty;
begin
 tcustomdbwidgetgrid(grid).fdatalink.begingridrow(
                                   fcellinfo.cell.row,info);
 try
  inherited;
 finally
  tcustomdbwidgetgrid(grid).fdatalink.endgridrow(info);
 end;
end;

end.
