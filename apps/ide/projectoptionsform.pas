{ MSEide Copyright (c) 1999-2009 by Martin Schreiber
   
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
unit projectoptionsform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msefiledialog,msegui,msestat,msestatfile,msetabs,msesimplewidgets,
 msetypes,msestrings,msedataedits,msetextedit,msegraphedits,msewidgetgrid,
 msegrids,msesplitter,msesysenv,msegdbutils,msedispwidgets,msesys,mseclasses,
 msegraphutils,mseevent,msetabsglob,msedatalist,msegraphics,msedropdownlist,
 mseformatstr,mseinplaceedit,msedatanodes,mselistbrowser,msebitmap,
 msecolordialog,msedrawtext,msewidgets,msepointer,mseguiglob,msepipestream,
 msemenus,sysutils,mseglob,mseedit,db,msedialog,
 msescrollbar;

const
 defaultsourceprintfont = 'Courier';
 defaulttitleprintfont = 'Helvetica';
 defaultprintfontsize = 35.2778; //10 point
 maxdefaultmake = $40-1;
 
type
 findinfoty = record
  text: msestring;
  options: searchoptionsty;
  selectedonly: boolean;
  history: msestringarty;
 end;
 
 replaceinfoty = record
  find: findinfoty;
  replacetext: msestring;
  prompt: boolean;
 end; 
 
 sigsetinfoty = record
  num: integer;
  numto: integer;
  flags: sigflagsty;
 end;
 sigsetinfoarty = array of sigsetinfoty;

 projecttextty = record
  mainfile: filenamety;
  targetfile: filenamety;
  messageoutputfile: filenamety;
  makecommand: filenamety;
  makedir: filenamety;
  debugcommand: filenamety;
  debugoptions: msestring;
  debugtarget: filenamety;
  runcommand: filenamety;
  remoteconnection: msestring;
  uploadcommand: filenamety;
  gdbprocessor: msestring;
  gdbservercommand: filenamety;
  beforeload: filenamety;
  afterload: filenamety;
  beforerun: filenamety;
  sourcedirs: msestringarty;
  defines: msestringarty;
  unitdirs: msestringarty;
  unitpref: msestring;
  incpref: msestring;
  libpref: msestring;
  objpref: msestring;
  targpref: msestring;
  
  makeoptions: msestringarty;
  sourcefilemasks: msestringarty;
  syntaxdeffiles: msestringarty;
  filemasknames: msestringarty;
  filemasks: msestringarty;

  toolmenus: msestringarty;
  toolfiles: msestringarty;
  toolparams: msestringarty;
    
  fontnames: msestringarty;
  newprojectfiles: filenamearty;
  newprojectfilesdest: filenamearty;
  newprogramfile: filenamety;
  newunitfile: filenamety;
//  newtextfile: filenamety;
  newmainfosource: filenamety;
  newmainfoform: filenamety;
  newsimplefosource: filenamety;
  newsimplefoform: filenamety;
  newdockingfosource: filenamety;
  newdockingfoform: filenamety;
  newdatamodsource: filenamety;
  newdatamodform: filenamety;
  newsubfosource: filenamety;
  newsubfoform: filenamety;
  newreportsource: filenamety;
  newreportform: filenamety;
  newinheritedsource: filenamety;
  newinheritedform: filenamety;
  newpascsource: filenamety;
  newpascform: filenamety;
 end;

 projectoptionsty = record
  modified: boolean;
  savechecked: boolean;
  ignoreexceptionclasses: stringarty;
  t: projecttextty;
  texp: projecttextty;
  projectfilename: filenamety;
  projectdir: filenamety;
  fontalias: msestringarty;
  fontheights: integerarty;
  fontwidths: integerarty;
  fontoptions: msestringarty;
  fontxscales: realarty;
  
  copymessages: boolean;
  closemessages: boolean;
  checkmethods: boolean;

  showgrid: boolean;
  snaptogrid: boolean;
  moveonfirstclick: boolean;
  gridsizex: integer;
  gridsizey: integer;
  autoindent: boolean;
  blockindent: integer;
  rightmarginon: boolean;
  rightmarginchars: integer;
  scrollheight: integer;
  tabstops: integer;
  spacetabs: boolean;
  editfontname: string;
  editfontheight: integer;
  editfontwidth: integer;
  editfontextraspace: integer;
  editfontantialiased: boolean;
  editmarkbrackets: boolean;
  backupfilecount: integer;
  encoding: integer;

  defineson: longboolarty;
  exceptclassnames: msestringarty;
  exceptignore: longboolarty;
  
  modulenames: msestringarty;
  moduletypes: msestringarty;
  modulefilenames: filenamearty;

  defaultmake: integer;
  makeoptionson: integerarty;
  unitdirson: integerarty;

  macroon: integerarty;
  macronames,macrovalues: msestringarty;
  macrogroup: integer;
  groupcomments: msestringarty;

  breakpointpaths: msestringarty;
  breakpointlines: integerarty;
  breakpointaddress: integerarty;
  addressbreakpoints: longboolarty;
  breakpointons: longboolarty;
  breakpointignore: integerarty;
  breakpointconditions: msestringarty;

  stoponexception: boolean;
  valuehints: boolean;
  activateonbreak: boolean;
  showconsole: boolean;
  externalconsole: boolean;
  sigsettings: sigsetinfoarty;
  gdbdownload: boolean;
  downloadalways: boolean;
  startupbkpt: integer;
  startupbkpton: boolean;
  gdbsimulator: boolean;
  gdbserverwait: real;
  
  usercolors: colorarty;
  usercolorcomment: msestringarty;

  //programparameters
  progparameters: string;
  propgparamhistory: msestringarty;
  progworkingdirectory: filenamety;
  envvarons: longboolarty;
  envvarnames: msestringarty;
  envvarvalues: msestringarty;
  
  //editor
  findreplaceinfo: replaceinfoty;
  
  //templates
  expandprojectfilemacros: longboolarty;
  loadprojectfile: longboolarty;
  
  //tools
  toolsave: longboolarty;
  toolhide: longboolarty;
  toolparse: longboolarty;
 end;

 tprojectoptionsfo = class(tmseform)
   statfile1: tstatfile;
   tlayouter9: tlayouter;
   tlayouter8: tlayouter;
   cancel: tbutton;
   ok: tbutton;
   tabwidget: ttabwidget;
   editorpage: ttabpage;
   tgroupbox1: tgroupbox;
   showgrid: tbooleanedit;
   snaptogrid: tbooleanedit;
   gridsizex: tintegeredit;
   tintegeredit2: tintegeredit;
   gridsizey: tintegeredit;
   moveonfirstclick: tbooleanedit;
   debuggerpage: ttabpage;
   debugcommand: tfilenameedit;
   debugoptions: tstringedit;
   ttabwidget1: ttabwidget;
   ttabpage6: ttabpage;
   sourcedirgrid: twidgetgrid;
   sourcedirs: tfilenameedit;
   ttabpage9: ttabpage;
   twidgetgrid2: twidgetgrid;
   defon: tbooleanedit;
   def: tstringedit;
   ttabpage7: ttabpage;
   signalgrid: twidgetgrid;
   sigstop: tbooleanedit;
   sighandle: tbooleanedit;
   signum: tintegeredit;
   signumto: tintegeredit;
   signame: tselector;
   ttabpage8: ttabpage;
   exceptionsgrid: twidgetgrid;
   exceptignore: tbooleanedit;
   exceptclassnames: tstringedit;
   ttabpage16: ttabpage;
   remoteconnection: tstringedit;
   tlayouter3: tlayouter;
   gdbprocessor: tdropdownlistedit;
   gdbsimulator: tbooleanedit;
   gdbdownload: tbooleanedit;
   tlayouter4: tlayouter;
   gdbbeforeload: tfilenameedit;
   tsplitter7: tsplitter;
   gdbafterload: tfilenameedit;
   tlayouter5: tlayouter;
   gdbbeforerun: tfilenameedit;
   tsplitter8: tsplitter;
   tlayouter1: tlayouter;
   externalconsole: tbooleanedit;
   showconsole: tbooleanedit;
   stoponexception: tbooleanedit;
   activateonbreak: tbooleanedit;
   makepage: ttabpage;
   tspacer2: tspacer;
   defaultmake: tenumedit;
   mainfile: tfilenameedit;
   targetfile: tfilenameedit;
   makecommand: tfilenameedit;
   showcommandline: tbutton;
   messageoutputfile: tfilenameedit;
   copymessages: tbooleanedit;
   closemessages: tbooleanedit;
   checkmethods: tbooleanedit;
   makegroupbox: ttabwidget;
   ttabpage12: ttabpage;
   makeoptionsgrid: twidgetgrid;
   makeon: tbooleanedit;
   buildon: tbooleanedit;
   make1on: tbooleanedit;
   make2on: tbooleanedit;
   make3on: tbooleanedit;
   make4on: tbooleanedit;
   makeoptions: tstringedit;
   ttabpage11: ttabpage;
   unitdirgrid: twidgetgrid;
   dmakeon: tbooleanedit;
   dbuildon: tbooleanedit;
   dmake1on: tbooleanedit;
   dmake2on: tbooleanedit;
   dmake3on: tbooleanedit;
   dmake4on: tbooleanedit;
   duniton: tbooleanedit;
   dincludeon: tbooleanedit;
   dlibon: tbooleanedit;
   dobjon: tbooleanedit;
   unitdirs: tfilenameedit;
   unitpref: tstringedit;
   incpref: tstringedit;
   libpref: tstringedit;
   objpref: tstringedit;
   tspacer1: tspacer;
   targpref: tstringedit;
   makedir: tfilenameedit;
   tsplitter1: tsplitter;
   tsplitter2: tsplitter;
   tsplitter3: tsplitter;
   tsplitter4: tsplitter;
   tsplitter5: tsplitter;
   ttabpage1: ttabpage;
   macrogrid: twidgetgrid;
   e0: tbooleanedit;
   e1: tbooleanedit;
   e2: tbooleanedit;
   e3: tbooleanedit;
   e4: tbooleanedit;
   e5: tbooleanedit;
   macronames: tstringedit;
   macrovalues: tstringedit;
   selectactivegroupgrid: twidgetgrid;
   activemacroselect: tbooleaneditradio;
   groupcomment: tstringedit;
   macrosplitter: tsplitter;
   fontaliaspage: ttabpage;
   fontaliasgrid: twidgetgrid;
   fontalias: tstringedit;
   fontname: tstringedit;
   fontheight: tintegeredit;
   ttabpage10: ttabpage;
   tlayouter7: tlayouter;
   tbutton1: tbutton;
   colgrid: twidgetgrid;
   coldi: tpointeredit;
   usercolors: tcoloredit;
   usercolorcomment: tstringedit;
   ttabpage2: ttabpage;
   newfile: ttabwidget;
   ttabpage3: ttabpage;
   twidgetgrid1: twidgetgrid;
   loadprojectfile: tbooleanedit;
   expandprojectfilemacros: tbooleanedit;
   newprojectfiles: tfilenameedit;
   newprojectfilesdest: tstringedit;
   ttabpage4: ttabpage;
   newprogf: tfilenameedit;
   newunitf: tfilenameedit;
   ttabpage5: ttabpage;
   ttabpage15: ttabpage;
   twidgetgrid3: twidgetgrid;
   toolsave: tbooleanedit;
   toolparse: tbooleanedit;
   toolhide: tbooleanedit;
   toolmenu: tstringedit;
   toolfile: tfilenameedit;
   toolparam: tstringedit;
   tlayouter13: tlayouter;
   dispgrid: twidgetgrid;
   fontdisp: ttextedit;
   tlayouter12: tlayouter;
   editmarkbrackets: tbooleanedit;
   editfontantialiased: tbooleanedit;
   editfontextraspace: tintegeredit;
   editfontwidth: tintegeredit;
   editfontheight: tintegeredit;
   editfontname: tstringedit;
   tlayouter11: tlayouter;
   encoding: tenumedit;
   scrollheight: tintegeredit;
   rightmarginchars: tintegeredit;
   rightmarginon: tbooleanedit;
   tlayouter10: tlayouter;
   backupfilecount: tintegeredit;
   spacetabs: tbooleanedit;
   tabstops: tintegeredit;
   blockindent: tintegeredit;
   autoindent: tbooleanedit;
   ttabwidget2: ttabwidget;
   ttabpage13: ttabpage;
   tspacer3: tspacer;
   filefiltergrid: tstringgrid;
   ttabpage14: ttabpage;
   grid: tstringgrid;
   tlayouter14: tlayouter;
   uploadcommand: tfilenameedit;
   gdbservercommand: tfilenameedit;
   gdbserverwait: trealedit;
   downloadalways: tbooleanedit;
   startupbkpt: tintegeredit;
   startupbkpton: tbooleanedit;
   valuehints: tbooleanedit;
   debugtarget: tfilenameedit;
   runcommand: tfilenameedit;
   tsplitter6: tsplitter;
   fontwidth: tintegeredit;
   fontoptions: tstringedit;
   fontxscale: trealedit;
   twidgetgrid4: twidgetgrid;
   newformname: tstringedit;
   newformsourcefile: tfilenameedit;
   newformformfile: tfilenameedit;
   procedure acttiveselectondataentered(const sender: TObject);
   procedure colonshowhint(const sender: tdatacol; const arow: Integer; 
                      var info: hintinfoty);
   procedure hintexpandedmacros(const sender: TObject; var info: hintinfoty);
   procedure selectactiveonrowsmoved(const sender: tcustomgrid; 
                const fromindex: Integer; const toindex: Integer;
                const acount: Integer);
   procedure expandfilename(const sender: TObject; var avalue: mseString; 
                var accept: Boolean);
   procedure showcommandlineonexecute(const sender: TObject);
   procedure signameonsetvalue(const sender: TObject; var avalue: integer;
                var accept: Boolean);
   procedure signumonsetvalue(const sender: TObject; var avalue: integer;
                var accept: Boolean);
   procedure signumtoonsetvalue(const sender: TObject; var avalue: Integer;
                var accept: Boolean);
   procedure fontondataentered(const sender: TObject);
   procedure makepageonchildscaled(const sender: TObject);
   procedure debuggeronchildscaled(const sender: TObject);
   procedure macronchildscaled(const sender: TObject);
   procedure formtemplateonchildscaled(const sender: TObject);
   procedure encodingsetvalue(const sender: TObject; var avalue: integer;
                   var accept: Boolean);
   procedure createexe(const sender: TObject);
   procedure drawcol(const sender: tpointeredit; const acanvas: tcanvas;
                   const avalue: Pointer; const arow: Integer);
   procedure colsetvalue(const sender: TObject; var avalue: colorty;
                   var accept: Boolean);
   procedure copycolorcode(const sender: TObject);
   procedure downloadchange(const sender: TObject);
   procedure processorchange(const sender: TObject);
   procedure copymessagechanged(const sender: TObject);
   {
   procedure befla(const sender: tlayouter);
   procedure afterla(const sender: tlayouter);
   procedure bef1(const sender: tlayouter);
   procedure aft1(const sender: tlayouter);
   }
   procedure runcommandchange(const sender: TObject);
  private
   procedure activegroupchanged;
 end;

function readprojectoptions(const filename: filenamety): boolean;
         //true if ok
procedure saveprojectoptions(filename: filenamety = '');
procedure initprojectoptions;
function editprojectoptions: boolean;
    //true if not aborted
function getprojectmacros: macroinfoarty;
procedure expandprojectmacros;
function expandprmacros(const atext: msestring): msestring;
procedure expandprmacros1(var atext: msestring);
function projecttemplatedir: filenamety;
function projectfiledialog(var aname: filenamety; save: boolean): modalresultty;
procedure projectoptionsmodified;
function checkprojectloadabort: boolean; //true on load abort

function getsigname(const anum: integer): string;
procedure projectoptionstofont(const afont: tfont);
function objpath(const aname: filenamety): filenamety;
function gettargetfile: filenamety;

var
 projectoptions: projectoptionsty;
 projecthistory: filenamearty;

implementation
uses
 projectoptionsform_mfm,breakpointsform,sourceform,mseact,msereal,
 objectinspector,msebits,msefileutils,msedesignintf,guitemplates,
 watchform,stackform,main,projecttreeform,findinfileform,
 selecteditpageform,programparametersform,sourceupdate,
 msedesigner,panelform,watchpointsform,commandlineform,msestream,
 componentpaletteform,mserichstring,msesettings,formdesigner,
 msestringlisteditor,msetexteditor,msepropertyeditors,mseshapes,mseactions,
 componentstore,cpuform
 {$ifdef FPC}{$ifndef mse_withoutdb},msedbfieldeditor{$endif}{$endif};

type

 signalinfoty = record
  num: integer;
  flags: sigflagsty;
  name: string;
  comment: string;
 end;

const
 findinfiledialogstatname =  'findinfiledialogfo.sta';
 finddialogstatname =        'finddialogfo.sta';
 replacedialogstatname =     'replacedialogfo.sta';
 optionsstatname =           'optionsfo.sta';
 settaborderstatname =       'settaborderfo.sta';
 setcreateorderstatname =    'setcreateorderfo.sta';
 programparametersstatname = 'programparametersfo.sta';
 settingsstatname =          'settingsfo.sta';
 printerstatname =           'printer.sta';
 imageselectorstatname =     'imageselector.sta';
 fadeeditorstatname =        'fadeeditor.sta';
 siginfocount = 30;
 siginfos: array[0..siginfocount-1] of signalinfoty = (
  (num:  1; flags: [sfl_stop]; name: 'SIGHUP'; comment: 'Hangup'),
  (num:  2; flags: [sfl_stop,sfl_internal,sfl_handle]; name: 'SIGINT'; comment: 'Interrupt'),
  (num:  3; flags: [sfl_stop]; name: 'SIGQUIT'; comment: 'Quit'),
  (num:  4; flags: [sfl_stop]; name: 'SIGILL'; comment: 'Illegal instruction'),
  (num:  5; flags: [sfl_stop,sfl_internal,sfl_handle]; name: 'SIGTRAP'; comment: 'Trace trap'),
  (num:  6; flags: [sfl_stop]; name: 'SIGABRT'; comment: 'Abort'),
  (num:  7; flags: [sfl_stop]; name: 'SIGBUS'; comment: 'BUS error'),
  (num:  8; flags: [sfl_stop]; name: 'SIGFPE'; comment: 'Floating-point exception'),
  (num:  9; flags: [sfl_stop]; name: 'SIGKILL'; comment: 'Kill, unblockable'),
  (num: 10; flags: [sfl_stop]; name: 'SIGUSR1'; comment: 'User-defined signal 1'),
  (num: 11; flags: [sfl_stop]; name: 'SIGSEGV'; comment: 'Segmentation violation'),
  (num: 12; flags: [sfl_stop]; name: 'SIGUSR2'; comment: 'User-defined signal 2'),
  (num: 13; flags: [sfl_stop]; name: 'SIGPIPE'; comment: 'Broken pipe'),
  (num: 14; flags: [sfl_internal]; name: 'SIGALRM'; comment: 'Alarm clock'),
  (num: 15; flags: [sfl_stop]; name: 'SIGTERM'; comment: 'Termination'),
  (num: 16; flags: [sfl_stop]; name: 'SIGSTKFLT'; comment: 'Stack fault'),
  (num: 17; flags: [{sfl_stop}]; name: 'SIGCHLD'; comment: 'Child status has changed'),
  (num: 18; flags: [sfl_stop]; name: 'SIGCONT'; comment: 'Continue'),
  (num: 19; flags: [sfl_stop]; name: 'SIGSTOP'; comment: 'Stop, unblockable'),
  (num: 20; flags: [sfl_stop]; name: 'SIGTSTP'; comment: 'Keyboard stop'),
  (num: 21; flags: [sfl_stop]; name: 'SIGTTIN'; comment: 'Background read from tty'),
  (num: 22; flags: [sfl_stop]; name: 'SIGTTOU'; comment: 'Background write to tty'),
  (num: 23; flags: [sfl_stop]; name: 'SIGURG'; comment: 'Urgent condition on socket'),
  (num: 24; flags: [sfl_stop]; name: 'SIGXCPU'; comment: 'CPU limit exceeded'),
  (num: 25; flags: [sfl_stop]; name: 'SIGXFSZ'; comment: 'File size limit exceeded'),
  (num: 26; flags: [sfl_stop]; name: 'SIGTALRM'; comment: 'Virtual alarm clock'),
  (num: 27; flags: [sfl_stop]; name: 'SIGPROF'; comment: 'Profiling alarm clock'),
  (num: 28; flags: [sfl_stop]; name: 'SIGWINCH'; comment: 'Window size change'),
  (num: 29; flags: [sfl_stop]; name: 'SIGIO'; comment: 'I/O now possible'),
  (num: 30; flags: [sfl_stop]; name: 'SIGPWR'; comment: 'Power failure restart')
  );

function getsigname(const anum: integer): string;
var
 int1: integer;
begin
 result:= '';
 for int1:= 0 to high(siginfos) do begin
  if siginfos[int1].num = anum then begin
   result:= siginfos[int1].name;
   break;
  end;
 end;
 if result = '' then begin
  result:= 'SIG'+inttostr(anum);
 end;
end;

function objpath(const aname: filenamety): filenamety;
begin
 result:= '';
 if aname <> '' then begin
  result:= filepath(projectoptions.texp.makedir,aname);
 end;
end;

function getprojectmacros: macroinfoarty;
begin
 setlength(result,2);
 with projectoptions do begin
  with result[0] do begin
   name:= 'PROJECTNAME';
   value:= removefileext(filename(projectfilename))
  end;
  with result[1] do begin
   name:= 'PROJECTDIR';
   value:= tosysfilepath(getcurrentdir)+pathdelim;
  end;
 end;
end;

function gettargetfile: filenamety;
begin
 with projectoptions.texp do begin
  if trim(debugtarget) <> '' then begin
   result:= objpath(debugtarget);
  end
  else begin
   result:= objpath(targetfile);
  end;
 end;
end;

procedure projectoptionstofont(const afont: tfont);
begin
 with projectoptions,afont do begin
  name:= editfontname;
  height:= editfontheight;
  width:= editfontwidth;
  extraspace:= editfontextraspace;
  if editfontantialiased then begin
   options:= options + [foo_antialiased];
  end
  else begin
   options:= options + [foo_nonantialiased];
  end;
 end;
end;

function checkprojectloadabort: boolean;
begin
 result:= false;
 if exceptobject is exception then begin
  if showmessage(exception(exceptobject).Message,'ERROR',[mr_ok,mr_cancel]) <> 
                               mr_ok then begin
   result:= true;
//   raise exception.Create(exception(exceptobject).Message);
  end;
 end
 else begin
  raise exception.create('Invalid exception');
 end;
end;

function projectfiledialog(var aname: filenamety; save: boolean): modalresultty;
begin
 aname:= projectoptions.projectfilename;
 if save then begin
  result:= filedialog(aname,[fdo_save,fdo_checkexist],'Save Project',
          ['Project files','All files'],['*.prj','*'],'prj',
          nil,nil,nil,[fa_all],[fa_hidden],@projecthistory);
 end
 else begin
  result:= filedialog(aname,[fdo_checkexist],'Open Project',
          ['Project files','All files'],['*.prj','*'],'prj',
          nil,nil,nil,[fa_all],[fa_hidden],@projecthistory);
 end;
end;

function getmacros: tmacrolist;
var
 ar1: macroinfoarty;
 int1,int2: integer;
 mask: integer;
 
begin
 with projectoptions do begin
  result:= tmacrolist.create([mao_caseinsensitive]);
  result.add(getsettingsmacros);
  result.add(getcommandlinemacros);
  result.add(getprojectmacros);
  mask:= bits[macrogroup];
  setlength(macrovalues,length(macronames));
  setlength(ar1,length(macronames)); //max
  int2:= 0;
  for int1:= 0 to high(ar1) do begin
   if macroon[int1] and mask <> 0 then begin
    ar1[int2].name:= macronames[int1];
    ar1[int2].value:= macrovalues[int1];
    inc(int2);
   end;
  end;
  setlength(ar1,int2);
  result.add(ar1);
 end;
end;

procedure expandprmacros1(var atext: msestring);
var
 li: tmacrolist;
begin
 li:= getmacros;
 li.expandmacros(atext);
 li.Free;
end;

function projecttemplatedir: filenamety;
begin
 result:= expandprmacros('${TEMPLATEDIR}');
// result:= expandmacros(settings.macros[sma_templatedir],getsettingsmacros);
end;

function expandprmacros(const atext: msestring): msestring;
begin
 result:= atext;
 expandprmacros1(result);
end;

procedure expandprojectmacros;
var
 li: tmacrolist;
 int1,int2: integer;
 bo1: boolean;
 item1: tmenuitem;
begin
 li:= getmacros;
 with projectoptions do begin
  texp:= t;
  with texp do begin
   li.expandmacros(mainfile);
   li.expandmacros(targetfile);
   li.expandmacros(messageoutputfile);
   li.expandmacros(makecommand);
   li.expandmacros(makedir);
   li.expandmacros(debugcommand);
   li.expandmacros(debugoptions);
   li.expandmacros(debugtarget);
   li.expandmacros(runcommand);
   li.expandmacros(remoteconnection);
   li.expandmacros(uploadcommand);
   li.expandmacros(gdbservercommand);
   li.expandmacros(beforeload);
   li.expandmacros(afterload);
   li.expandmacros(beforerun);
   li.expandmacros(gdbprocessor);
   li.expandmacros(sourcedirs);
   li.expandmacros(defines);
   li.expandmacros(unitdirs);
   li.expandmacros(unitpref);
   li.expandmacros(incpref);
   li.expandmacros(libpref);
   li.expandmacros(objpref);
   li.expandmacros(targpref);
   li.expandmacros(makeoptions);
   li.expandmacros(sourcefilemasks);
   li.expandmacros(syntaxdeffiles);
   li.expandmacros(filemasknames);
   li.expandmacros(filemasks);
   li.expandmacros(toolmenus);
   li.expandmacros(toolfiles);
   li.expandmacros(toolparams);
   li.expandmacros(fontnames);
   li.expandmacros(newprojectfiles);
   li.expandmacros(newprojectfilesdest);
   li.expandmacros(newprogramfile);
   li.expandmacros(newunitfile);
//   li.expandmacros(newtextfile);
   li.expandmacros(newmainfosource);
   li.expandmacros(newmainfoform);
   li.expandmacros(newsimplefosource);
   li.expandmacros(newsimplefoform);
   li.expandmacros(newdockingfosource);
   li.expandmacros(newdockingfoform);
   li.expandmacros(newdatamodsource);
   li.expandmacros(newdatamodform);
   li.expandmacros(newsubfosource);
   li.expandmacros(newsubfoform);
   li.expandmacros(newreportsource);
   li.expandmacros(newreportform);
   li.expandmacros(newinheritedsource);
   li.expandmacros(newinheritedform);
   li.expandmacros(newpascsource);
   li.expandmacros(newpascform);
   clearfontalias;
   int2:= high(fontalias);
   if int2 > high(fontnames) then begin
    int2:= high(fontnames);
   end;
   if int2 > high(fontheights) then begin
    int2:= high(fontheights);
   end;
   if int2 > high(fontwidths) then begin
    int2:= high(fontwidths);
   end;
   if int2 > high(fontoptions) then begin
    int2:= high(fontoptions);
   end;
   if int2 > high(fontxscales) then begin
    int2:= high(fontxscales);
   end;
   for int1:= 0 to int2 do begin
    registerfontalias(fontalias[int1],fontnames[int1],fam_overwrite,
               fontheights[int1],fontwidths[int1],
               fontoptioncharstooptions(fontoptions[int1]),
               fontxscales[int1]);
   end;
   if sourceupdater <> nil then begin
    sourceupdater.maxlinelength:= rightmarginchars;
   end;
   for int1:= 0 to sourcefo.count - 1 do begin
    sourcefo.items[int1].updatestatvalues;
   end;
   fontaliasnames:= fontalias;
   with sourcefo.syntaxpainter do begin
    bo1:= not cmparray(defdefs.asarraya,texp.sourcefilemasks) or
       not cmparray(defdefs.asarrayb,texp.syntaxdeffiles);
    defdefs.asarraya:= texp.sourcefilemasks;
    defdefs.asarrayb:= texp.syntaxdeffiles;
    if bo1 then begin
     for int1:= 0 to sourcefo.count - 1 do begin
      sourcefo.items[int1].edit.setsyntaxdef(sourcefo.items[int1].edit.filename);
     end;
    end;
   end;
   with mainfo.openfile.controller.filterlist do begin
    asarraya:= filemasknames;
    asarrayb:= filemasks;
   end;
   with mainfo.mainmenu1.menu.submenu do begin
    item1:= itembyname('tools');
    if toolmenus <> nil then begin
     if item1 = nil then begin
      item1:= tmenuitem.create;
      item1.name:= 'tools';
      item1.caption:= 'T&ools';
      insert(itemindexbyname('settings'),item1);
     end;
     with item1.submenu do begin
      clear;
      for int1:= 0 to high(toolmenus) do begin
       if (int1 > high(toolfiles)) or (int1 > high(toolparams)) then begin
        break;
       end;
       insert(bigint,[toolmenus[int1]],[[mao_asyncexecute]],
                               [],[{$ifdef FPC}@{$endif}mainfo.runtool]);
      end;
     end;
    end
    else begin
     if item1 <> nil then begin
      delete(item1.index);
     end;
    end;
   end;
  end;
  ignoreexceptionclasses:= nil;
  for int1:= 0 to high(exceptignore) do begin
   if int1 > high(exceptclassnames) then begin
    break;
   end;
   if exceptignore[int1] then begin
    additem(ignoreexceptionclasses,exceptclassnames[int1]);
   end;
  end;
  for int1:= 0 to usercolorcount - 1 do begin
   if int1 > high(usercolors) then begin
    break;
   end;
   setcolormapvalue(cl_user + cardinal(int1),usercolors[int1]);
  end;
 end;
 li.free;
 mainfo.updatesigsettings;
end;

function defaultsigsettings: sigsetinfoarty;
var
 int1,int2: integer;
begin
 setlength(result,siginfocount);
 int2:= 0;
 for int1:= 0 to siginfocount - 1 do begin
  with result[int2] do begin
   if not (sfl_internal in siginfos[int1].flags) then begin
    num:= siginfos[int1].num;
    numto:= num;
    flags:= siginfos[int1].flags;
    inc(int2);
   end;
  end;
 end;
 setlength(result,int2);
end;

procedure initprojectoptions;
const 
 alloptionson = 1+2+4+8+16+32;
 unitson = 1+2+4+8+16+32+$10000;
 allon = unitson+$20000+$40000;
var
 int1: integer;
begin
 finalize(projectoptions);
 fillchar(projectoptions,sizeof(projectoptions),0);
 with projectoptions,t do begin
  deletememorystatstream(findinfiledialogstatname);
  deletememorystatstream(finddialogstatname);
  deletememorystatstream(replacedialogstatname);
  deletememorystatstream(optionsstatname);
  deletememorystatstream(settaborderstatname);
  deletememorystatstream(setcreateorderstatname);
  deletememorystatstream(programparametersstatname);
  deletememorystatstream(printerstatname);
  deletememorystatstream(imageselectorstatname);
  deletememorystatstream(stringlisteditorstatname);
  deletememorystatstream(texteditorstatname);
  deletememorystatstream(colordialogstatname);
  deletememorystatstream(bmpfiledialogstatname);
  deletememorystatstream(fadeeditorstatname);
  {$ifdef FPC}{$ifndef mse_withoutdb}
  deletememorystatstream(dbfieldeditorstatname);
  {$endif}{$endif}
  modified:= false;
  savechecked:= false;
  sigsettings:= defaultsigsettings;
  exceptclassnames:= nil;
  exceptignore:= nil;
  additem(exceptclassnames,'EconvertError');
  additem(exceptignore,false);
  ignoreexceptionclasses:= nil;

  makeoptions:= nil;
  additem(makeoptions,'-l -Mobjfpc -Sh');
  additem(makeoptions,'-gl');
  additem(makeoptions,'-B');
  additem(makeoptions,'-OG2p3 -XX -CX -Xs');
  setlength(makeoptionson,length(makeoptions));
  for int1:= 0 to high(makeoptionson) do begin
   makeoptionson[int1]:= alloptionson;
  end;
  makeoptionson[1]:= alloptionson and not bits[5]; 
                     //all but make 4
  makeoptionson[2]:= bits[1] or bits[5]; //build + make 4
  makeoptionson[3]:= bits[5]; //make 4
  unitdirson:= nil;
  macroon:= nil;
  macronames:= nil;
  macrovalues:= nil;
  copymessages:= false;
  closemessages:= true;
  checkmethods:= true;
  showgrid:= true;
  snaptogrid:= true;
  moveonfirstclick:= true;
  gridsizex:= defaultgridsizex;
  gridsizey:= defaultgridsizey;
  findreplaceinfo.find.options:= [so_caseinsensitive];
  autoindent:= true;
  blockindent:= 1;
  rightmarginon:= true;
  rightmarginchars:= 80;
  scrollheight:= 0;
  tabstops:= 4;
  spacetabs:= false;
  editfontname:= 'mseide_source';
  editfontheight:= 0;
  editfontwidth:= 0;
  editfontextraspace:= 0;
  editfontantialiased:= true;
  editmarkbrackets:= true;
  backupfilecount:= 2;
  encoding:= 0;
  valuehints:= true;
  activateonbreak:= true;
  showconsole:= false;
  externalconsole:= false;
  mainfile:= '';
  targetfile:= '';
  messageoutputfile:= '';
  defaultmake:= 1; //make
  sourcedirs:= nil;
  additem(sourcedirs,'./');
  additem(sourcedirs,'${MSELIBDIR}*/');
  additem(sourcedirs,'${MSELIBDIR}kernel/$TARGET/');
  sourcedirs:= reversearray(sourcedirs);
  defines:= nil;
  defineson:= nil;
  unitdirs:= nil;
  additem(unitdirs,'${MSELIBDIR}*/');
  additem(unitdirs,'${MSELIBDIR}kernel/');
  additem(unitdirs,'${MSELIBDIR}kernel/$TARGET/');
  setlength(unitdirson,length(unitdirs));
  for int1:= 0 to high(unitdirson) do begin
   unitdirson[int1]:= unitson;
  end;
  unitdirson[1]:= unitson + $20000; //kernel include
  unitdirs:= reversearray(unitdirs);
  unitdirson:= reversearray(unitdirson);
  unitpref:= '-Fu';
  incpref:= '-Fi';
  libpref:= '-Fl';
  objpref:= '-Fo';
  targpref:= '-o';
  makecommand:= '${COMPILER}';
  makedir:= '';
  debugcommand:= '${DEBUGGER}';
  debugoptions:= '';
  debugtarget:= '';
  runcommand:= '';
  remoteconnection:= '';
  uploadcommand:= '';
  gdbdownload:= false;
  downloadalways:= false;
  startupbkpt:= 0;
  startupbkpton:= false;
  gdbsimulator:= false;
  gdbprocessor:= 'i386';
  gdbservercommand:= '';
  gdbserverwait:= 0;
  beforeload:= '';
  afterload:= '';
  beforerun:= '';
  sourcefilemasks:= nil;
  syntaxdeffiles:= nil;
  filemasknames:= nil;
  filemasks:= nil;
  toolsave:= nil;
  toolhide:= nil;
  toolparse:= nil;
  toolmenus:= nil;
  toolfiles:= nil;
  toolparams:= nil;
  fontalias:= nil;
  fontnames:= nil;
  fontheights:= nil;
  fontwidths:= nil;
  fontoptions:= nil;
  fontxscales:= nil;
  usercolors:= nil;
  usercolorcomment:= nil;
  additem(sourcefilemasks,'"*.pas" "*.dpr" "*.pp" "*.inc"');
  additem(syntaxdeffiles,'${SYNTAXDEFDIR}pascal.sdef');
  additem(sourcefilemasks,'"*.c" "*.cc" "*.h"');
  additem(syntaxdeffiles,'${SYNTAXDEFDIR}cpp.sdef');
  additem(sourcefilemasks,'"*.mfm"');
  additem(syntaxdeffiles,'${SYNTAXDEFDIR}objecttext.sdef');

  additem(filemasknames,'Source');
  additem(filemasks,'"*.pp" "*.pas" "*.inc" "*.dpr"');
  additem(filemasknames,'Forms');
  additem(filemasks,'*.mfm');
  additem(filemasknames,'All Files');
  additem(filemasks,'*');
  
  newprojectfiles:= nil;
//  additem(newprojectfiles,'${TEMPLATEDIR}project1.pas');
//  additem(newprojectfiles,'${TEMPLATEDIR}main.pas');
//  additem(newprojectfiles,'${TEMPLATEDIR}main_mfm.pas');
  newprojectfilesdest:= nil;
  expandprojectfilemacros:= nil;
  loadprojectfile:= nil;
  newprogramfile:= '${TEMPLATEDIR}default/program.pas';
  newunitfile:= '${TEMPLATEDIR}default/unit.pas';
//  newtextfile:= '';
  newmainfosource:= '${TEMPLATEDIR}default/mainform.pas';
  newmainfoform:= '${TEMPLATEDIR}default/mainform.mfm';
  newsimplefosource:= '${TEMPLATEDIR}default/simpleform.pas';
  newsimplefoform:= '${TEMPLATEDIR}default/simpleform.mfm';
  newdockingfosource:= '${TEMPLATEDIR}default/dockingform.pas';
  newdockingfoform:= '${TEMPLATEDIR}default/dockingform.mfm';
  newdatamodsource:= '${TEMPLATEDIR}default/datamodule.pas';
  newdatamodform:= '${TEMPLATEDIR}default/datamodule.mfm';
  newsubfosource:= '${TEMPLATEDIR}default/subform.pas';
  newsubfoform:= '${TEMPLATEDIR}default/subform.mfm';
  newreportsource:= '${TEMPLATEDIR}default/report.pas';
  newreportform:= '${TEMPLATEDIR}default/report.mfm';
  newinheritedsource:= '${TEMPLATEDIR}default/inheritedform.pas';
  newinheritedform:= '${TEMPLATEDIR}default/inheritedform.mfm';
  newpascsource:= '${TEMPLATEDIR}default/pascform.pas';
  newpascform:= '${TEMPLATEDIR}default/pascform.mfm';
 end;
 expandprojectmacros;
end;

procedure projectoptionsmodified;
begin
 projectoptions.modified:= true;
 projectoptions.savechecked:= false;
end;

procedure setsignalinfocount(const count: integer);
begin
 if count = 0 then begin
  projectoptions.sigsettings:= defaultsigsettings;
 end
 else begin
  setlength(projectoptions.sigsettings,count);
 end;
end;

procedure storesignalinforec(const index: integer;
          const avalue: msestring);
var
 stop,handle: boolean;
begin
 with projectoptions.sigsettings[index] do begin
  decoderecord(avalue,[@num,@numto,@stop,@handle],'iibb');
  updatebit({$ifdef FPC}longword{$else}byte{$endif}(flags),ord(sfl_stop),stop);
  updatebit({$ifdef FPC}longword{$else}byte{$endif}(flags),ord(sfl_handle),handle);
 end;
end;

function getsignalinforec(const index: integer): msestring;
var
 stop,handle: boolean;
begin
 with projectoptions.sigsettings[index] do begin
  stop:= sfl_stop in flags;
  handle:= sfl_handle in flags;
  result:= encoderecord([num,numto,stop,handle]);
 end;
end;

procedure updateprojectoptions(const statfiler: tstatfiler;
                  const afilename: filenamety);
var
 int1,int2,int3: integer;
begin
 with statfiler,projectoptions,t do begin
  if iswriter then begin
   projectdir:= msefileutils.getcurrentdir;
   with mainfo,mainmenu1.menu.itembyname('view') do begin
    int3:= formmenuitemstart;
    int2:= count - int3;
    setlength(modulenames,int2);
    setlength(moduletypes,int2);
    setlength(modulefilenames,int2);
    for int1:= 0 to high(modulenames) do begin
     with pmoduleinfoty(submenu[int1+int3].tag)^ do begin
      modulenames[int1]:= struppercase(instance.name);
      moduletypes[int1]:= struppercase(string(moduleclassname));
      modulefilenames[int1]:= filename;
     end;
    end;
   end;
  end;
  registeredcomponents.updatestat(statfiler);
  setsection('projectoptions');
  updatevalue('projectdir',projectdir);
  updatevalue('projectfilename',projectfilename);
  projectfilename:= afilename;
  updatememorystatstream('findinfiledialog',findinfiledialogstatname);
  updatememorystatstream('finddialog',finddialogstatname);
  updatememorystatstream('replacedialog',replacedialogstatname);
  updatememorystatstream('options',optionsstatname);
  updatememorystatstream('settaborder',settaborderstatname);
  updatememorystatstream('setcreateorder',setcreateorderstatname);
  updatememorystatstream('programparameters',programparametersstatname);
  updatememorystatstream('settings',settingsstatname);
  updatememorystatstream('printer',printerstatname);
  updatememorystatstream('imageselector',imageselectorstatname);
  updatememorystatstream('fadeeditor',fadeeditorstatname);
  updatememorystatstream('stringlisteditor',stringlisteditorstatname);
  updatememorystatstream('texteditor',texteditorstatname);
  updatememorystatstream('colordialog',colordialogstatname);
  updatememorystatstream('bmpfiledialog',bmpfiledialogstatname);
{$ifdef FPC}{$ifndef mse_withoutdb}
  updatememorystatstream('dbfieldeditor',dbfieldeditorstatname);
{$endif}{$endif}
  if iswriter then begin
   with tstatwriter(statfiler) do begin
    writerecordarray('sigsettings',length(sigsettings),
                     {$ifdef FPC}@{$endif}getsignalinforec);
    writeinteger('gridsizex',gridsizex);
    writeinteger('gridsizey',gridsizey);
   end;
  end
  else begin
   with tstatreader(statfiler) do begin
    readrecordarray('sigsettings',{$ifdef FPC}@{$endif}setsignalinfocount,
             {$ifdef FPC}@{$endif}storesignalinforec);
    gridsizex:= readinteger('gridsizex',gridsizex,1,1000);
    gridsizey:= readinteger('gridsizey',gridsizey,1,1000);
   end;
  end;
  updatevalue('exceptclassnames',exceptclassnames);
  updatevalue('exceptignore',exceptignore);
  updatevalue('modulenames',modulenames);
  updatevalue('moduletypes',moduletypes);
  updatevalue('modulefiles',modulefilenames);
  updatevalue('mainfile',mainfile);
  updatevalue('targetfile',targetfile);
  updatevalue('messageoutputfile',messageoutputfile);
  updatevalue('copymessages',copymessages);
  updatevalue('closemessages',closemessages);
  updatevalue('checkmethods',checkmethods);
  updatevalue('makecommand',makecommand);
  updatevalue('makedir',makedir);
  updatevalue('debugcommand',debugcommand);
  updatevalue('debugoptions',debugoptions);
  updatevalue('debugtarget',debugtarget);
  updatevalue('runcommand',runcommand);
  updatevalue('remoteconnection',remoteconnection);
  updatevalue('uploadcommand',uploadcommand);
  updatevalue('gdbdownload',gdbdownload);
  updatevalue('downloadalways',downloadalways);
  updatevalue('startupbkpt',startupbkpt);
  updatevalue('startupbkpton',startupbkpton);
  updatevalue('gdbsimulator',gdbsimulator);
  updatevalue('gdbprocessor',gdbprocessor);
  updatevalue('gdbservercommand',gdbservercommand);
  updatevalue('gdbserverwait',gdbserverwait);
  updatevalue('beforeload',beforeload);
  updatevalue('afterload',afterload);
  updatevalue('beforerun',beforerun);
  updatevalue('defaultmake',defaultmake,1,maxdefaultmake+1);
  updatevalue('makeoptions',makeoptions);
  updatevalue('makeoptionson',makeoptionson);
  updatevalue('macroon',macroon);
  updatevalue('macronames',macronames);
  updatevalue('macrovalues',macrovalues);
  updatevalue('macrogroup',macrogroup,0,5);
  updatevalue('groupcomments',groupcomments);
  updatevalue('sourcedirs',sourcedirs);
  updatevalue('defines',defines);
  updatevalue('defineson',defineson);
  updatevalue('unitdirs',unitdirs);
  updatevalue('unitdirson',unitdirson);
  updatevalue('unitpref',unitpref);
  updatevalue('incpref',incpref);
  updatevalue('libpref',libpref);
  updatevalue('objpref',objpref);
  updatevalue('targpref',targpref);
  updatevalue('sourcefilemasks',sourcefilemasks);
  updatevalue('syntaxdeffiles',syntaxdeffiles);
  updatevalue('filemasknames',filemasknames);
  updatevalue('filemasks',filemasks);
  updatevalue('toolsave',toolsave);
  updatevalue('toolhide',toolhide);
  updatevalue('toolparse',toolparse);
  updatevalue('toolmenus',toolmenus);
  updatevalue('toolfiles',toolfiles);
  updatevalue('toolparams',toolparams);
  updatevalue('fontalias',fontalias);
  updatevalue('fontnames',fontnames);
  updatevalue('fontheights',fontheights);
  updatevalue('fontwidths',fontwidths);
  updatevalue('fontoptions',fontoptions);
  updatevalue('fontxscales',fontxscales);
  updatevalue('usercolors',integerarty(usercolors));
  updatevalue('usercolorcomment',usercolorcomment);
  updatevalue('showgrid',showgrid);
  updatevalue('snaptogrid',snaptogrid);
  updatevalue('moveonfirstclick',moveonfirstclick);
  updatevalue('autoindent',autoindent);
  updatevalue('blockindent',blockindent);
  updatevalue('rightmarginon',rightmarginon);
  updatevalue('rightmarginchars',rightmarginchars);
  updatevalue('scrollheight',scrollheight);
  updatevalue('tabstops',tabstops);
  updatevalue('spacetabs',spacetabs);
  updatevalue('editfontname',editfontname);
  updatevalue('editfontheight',editfontheight);
  updatevalue('editfontwidth',editfontwidth);
  updatevalue('editfontextraspace',editfontextraspace);
  updatevalue('editfontantialiased',editfontantialiased);
  updatevalue('editmarkbrackets',editmarkbrackets);
  updatevalue('backupfilecount',backupfilecount,0,10);
  updatevalue('encoding',encoding,0,1);
  
  updatevalue('newprojectfiles',newprojectfiles);
  updatevalue('newprojectfilesdest',newprojectfilesdest);
  updatevalue('expandprojectfilemacros',expandprojectfilemacros);
  updatevalue('loadprojectfile',loadprojectfile);
  
  updatevalue('newprogramfile',newprogramfile);
  updatevalue('newunitfile',newunitfile);
  updatevalue('newmainfosource',newmainfosource);
  updatevalue('newmainfoform',newmainfoform);
  updatevalue('newsimplefosource',newsimplefosource);
  updatevalue('newsimplefoform',newsimplefoform);
  updatevalue('newdockingfosource',newdockingfosource);
  updatevalue('newdockingfoform',newdockingfoform);
  updatevalue('newdatamodsource',newdatamodsource);
  updatevalue('newdatamodform',newdatamodform);
  updatevalue('newsubfosource',newsubfosource);
  updatevalue('newsubfoform',newsubfoform);
  updatevalue('newreportsource',newreportsource);
  updatevalue('newreportform',newreportform);
  updatevalue('newinheritedsource',newinheritedsource);
  updatevalue('newinheritedform',newinheritedform);
  updatevalue('newpascsource',newpascsource);
  updatevalue('newpascform',newpascform);
  
  if not iswriter then begin
   if guitemplatesmo.sysenv.getintegervalue(int1,ord(env_vargroup),1,6) then begin
    macrogroup:= int1-1;
   end;
   expandprojectmacros;
  end;
  updatevalue('stoponexception',stoponexception);
  updatevalue('valuehints',valuehints);
  updatevalue('activateonbreak',activateonbreak);
  updatevalue('showconsole',showconsole);
  updatevalue('externalconsole',externalconsole);
  breakpointsfo.updatestat(statfiler);
  panelform.updatestat(statfiler);
  projecttree.updatestat(statfiler);
  componentstorefo.updatestat(statfiler);

  setsection('layout');
  mainfo.projectstatfile.updatestat('windowlayout',statfiler);
  sourcefo.updatestat(statfiler);
  setsection('components');
  selecteditpageform.updatestat(statfiler);
  programparametersform.updatestat(statfiler);
  projectoptionstofont(textpropertyfont);
  modified:= false;
  savechecked:= false;
 end;
end;

procedure projectoptionstoform(fo: tprojectoptionsfo);
var
 int1,int2: integer;
begin
 fo.usercolors.gridvalues:= integerarty(projectoptions.usercolors);
 fo.usercolorcomment.gridvalues:= projectoptions.usercolorcomment;
 fo.colgrid.rowcount:= usercolorcount;
 fo.colgrid.fixcols[-1].captions.count:= usercolorcount;
 with fo,projectoptions do begin
  for int1:= 0 to colgrid.rowhigh do begin
   colgrid.fixcols[-1].captions[int1]:= colortostring(cl_user+cardinal(int1));
  end;
 end;
 with fo.signame do begin
  setlength(enums,siginfocount);
  int2:= 0;
  for int1:= 0 to siginfocount - 1 do begin
   with siginfos[int1] do begin
    if not (sfl_internal in flags) then begin
     enums[int2]:= num;
     dropdownitems.addrow([name,comment]);
     dropdown.cols.addrow([comment+ ' ('+name+')']);
     inc(int2);
    end;
   end;
  end;
  setlength(enums,int2);
 end;
 with projectoptions,t do begin
  fo.signalgrid.rowcount:= length(sigsettings);
  for int1:= 0 to high(sigsettings) do begin
   with sigsettings[int1] do begin
    fo.signum[int1]:= num;
    fo.signumto[int1]:= numto;
    if num = numto then begin
     fo.signame[int1]:= num;
    end
    else begin
     fo.signame[int1]:= -1;
    end;
    fo.sigstop[int1]:= sfl_stop in flags;
    fo.sighandle[int1]:= sfl_handle in flags;
   end;
  end;
  fo.exceptignore.gridvalues:= exceptignore;
  fo.exceptclassnames.gridvalues:= exceptclassnames;
  fo.mainfile.value:= mainfile;
  fo.targetfile.value:= targetfile;
  fo.messageoutputfile.value:= messageoutputfile;
  fo.copymessages.value:= copymessages;
  fo.closemessages.value:= closemessages;
  fo.checkmethods.value:= checkmethods;
  fo.showgrid.value:= showgrid;
  fo.snaptogrid.value:= snaptogrid;
  fo.moveonfirstclick.value:= moveonfirstclick;
  fo.gridsizex.value:= gridsizex;
  fo.gridsizey.value:= gridsizey;
  fo.autoindent.value:= autoindent;
  fo.blockindent.value:= blockindent;
  fo.tabstops.value:= tabstops;
  fo.spacetabs.value:= spacetabs;
  fo.rightmarginon.value:= rightmarginon;
  fo.rightmarginchars.value:= rightmarginchars;
  fo.scrollheight.value:= scrollheight;
  fo.editfontname.value:= editfontname;
  fo.editfontheight.value:= editfontheight;
  fo.editfontwidth.value:= editfontwidth;
  fo.editfontextraspace.value:= editfontextraspace;
  fo.editfontantialiased.value:= editfontantialiased;
  fo.editmarkbrackets.value:= editmarkbrackets;
  fo.backupfilecount.value:= backupfilecount;
  fo.encoding.value:= encoding;
  fo.fontalias.gridvalues:= fontalias;
  fo.fontname.gridvalues:= fontnames;
  fo.fontheight.gridvalues:= fontheights;
  fo.fontwidth.gridvalues:= fontwidths;
  fo.fontoptions.gridvalues:= fontoptions;
  fo.fontxscale.gridvalues:= fontxscales;
  fo.fontondataentered(nil);

  fo.newprojectfiles.gridvalues:= newprojectfiles;
  fo.newprojectfilesdest.gridvalues:= newprojectfilesdest;
  fo.expandprojectfilemacros.gridvalues:= expandprojectfilemacros;
  fo.loadprojectfile.gridvalues:= loadprojectfile;
  
  fo.newprogf.value:= newprogramfile;
  fo.newunitf.value:= newunitfile;
//  fo.newtextf.value:= newtextfile;
  fo.newformsourcefile.gridvalue[0]:= newmainfosource;
  fo.newformformfile.gridvalue[0]:= newmainfoform;
  fo.newformsourcefile.gridvalue[1]:= newsimplefosource;
  fo.newformformfile.gridvalue[1]:= newsimplefoform;
  fo.newformsourcefile.gridvalue[2]:= newdockingfosource;
  fo.newformformfile.gridvalue[2]:= newdockingfoform;
  fo.newformsourcefile.gridvalue[3]:= newdatamodsource;
  fo.newformformfile.gridvalue[3]:= newdatamodform;
  fo.newformsourcefile.gridvalue[4]:= newsubfosource;
  fo.newformformfile.gridvalue[4]:= newsubfoform;
  fo.newformsourcefile.gridvalue[5]:= newreportsource;
  fo.newformformfile.gridvalue[5]:= newreportform;
  fo.newformsourcefile.gridvalue[6]:= newinheritedsource;
  fo.newformformfile.gridvalue[6]:= newinheritedform;
  fo.newformsourcefile.gridvalue[7]:= newpascsource;
  fo.newformformfile.gridvalue[7]:= newpascform;

  fo.makecommand.value:= makecommand;
  fo.makedir.value:= makedir;
  fo.debugcommand.value:= debugcommand;
  fo.debugoptions.value:= debugoptions;
  fo.debugtarget.value:= debugtarget;
  fo.runcommand.value:= runcommand;
  fo.remoteconnection.value:= remoteconnection;
  fo.uploadcommand.value:= uploadcommand;
  fo.gdbdownload.value:= gdbdownload;
  fo.downloadalways.value:= downloadalways;
  fo.startupbkpt.value:= startupbkpt;
  fo.startupbkpton.value:= startupbkpton;
  fo.gdbsimulator.value:= gdbsimulator;
  fo.gdbprocessor.value:= gdbprocessor;
  fo.gdbservercommand.value:= gdbservercommand;
  fo.gdbserverwait.value:= gdbserverwait;
  fo.gdbbeforeload.value:= beforeload;
  fo.gdbafterload.value:= afterload;
  fo.gdbbeforerun.value:= beforerun;
  fo.defaultmake.value:= lowestbit(defaultmake);
  fo.makeoptions.gridvalues:= makeoptions;
  for int1:= 0 to fo.makeoptionsgrid.rowhigh do begin
   if int1 > high(makeoptionson) then begin
    break;
   end;
   fo.makeon.gridupdatetagvalue(int1,makeoptionson[int1]);
   fo.buildon.gridupdatetagvalue(int1,makeoptionson[int1]);
   fo.make1on.gridupdatetagvalue(int1,makeoptionson[int1]);
   fo.make2on.gridupdatetagvalue(int1,makeoptionson[int1]);
   fo.make3on.gridupdatetagvalue(int1,makeoptionson[int1]);
   fo.make4on.gridupdatetagvalue(int1,makeoptionson[int1]);
  end;
  fo.unitdirs.gridvalues:= reversearray(unitdirs);
  int2:= high(unitdirs);
  for int1:= 0 to int2 do begin
   if int1 > high(unitdirson) then begin
    break;
   end;
   fo.dmakeon.gridupdatetagvalue(int2,unitdirson[int1]);
   fo.dbuildon.gridupdatetagvalue(int2,unitdirson[int1]);
   fo.dmake1on.gridupdatetagvalue(int2,unitdirson[int1]);
   fo.dmake2on.gridupdatetagvalue(int2,unitdirson[int1]);
   fo.dmake3on.gridupdatetagvalue(int2,unitdirson[int1]);
   fo.dmake4on.gridupdatetagvalue(int2,unitdirson[int1]);
   fo.duniton.gridupdatetagvalue(int2,unitdirson[int1]);
   fo.dincludeon.gridupdatetagvalue(int2,unitdirson[int1]);
   fo.dlibon.gridupdatetagvalue(int2,unitdirson[int1]);
   fo.dobjon.gridupdatetagvalue(int2,unitdirson[int1]);
   dec(int2);
  end;
  fo.unitpref.value:= unitpref;
  fo.incpref.value:= incpref;
  fo.libpref.value:= libpref;
  fo.objpref.value:= objpref;
  fo.targpref.value:= targpref;
  fo.activemacroselect[macrogroup]:= true;
  fo.activegroupchanged;
  fo.macronames.gridvalues:= macronames;
  fo.macrovalues.gridvalues:= macrovalues;
  setlength(groupcomments,6);
  fo.groupcomment.gridvalues:= groupcomments;

  for int1:= 0 to fo.macrogrid.rowhigh do begin
   if int1 > high(macroon) then begin
    break;
   end;
   fo.e0.gridupdatetagvalue(int1,macroon[int1]);
   fo.e1.gridupdatetagvalue(int1,macroon[int1]);
   fo.e2.gridupdatetagvalue(int1,macroon[int1]);
   fo.e3.gridupdatetagvalue(int1,macroon[int1]);
   fo.e4.gridupdatetagvalue(int1,macroon[int1]);
   fo.e5.gridupdatetagvalue(int1,macroon[int1]);
  end;

  fo.sourcedirs.gridvalues:= reversearray(sourcedirs);
  fo.grid[0].datalist.asarray:= syntaxdeffiles;
  fo.grid[1].datalist.asarray:= sourcefilemasks;
  fo.filefiltergrid[0].datalist.asarray:= filemasknames;
  fo.filefiltergrid[1].datalist.asarray:= filemasks;
  fo.toolsave.gridvalues:= toolsave;
  fo.toolhide.gridvalues:= toolhide;
  fo.toolparse.gridvalues:= toolparse;
  fo.toolmenu.gridvalues:= toolmenus;
  fo.toolfile.gridvalues:= toolfiles;
  fo.toolparam.gridvalues:= toolparams;
  fo.def.gridvalues:= defines;
  fo.defon.gridvalues:= defineson;
  fo.stoponexception.value:= stoponexception;
  fo.valuehints.value:= valuehints;
  fo.activateonbreak.value:= activateonbreak;
  fo.showconsole.value:= showconsole;
  fo.externalconsole.value:= externalconsole;
 end;
end;

procedure storemacros(fo: tprojectoptionsfo);
var
 int1: integer;
begin
 with projectoptions,t do begin
//  macrogroup:= fo.activeenv.value;
  macronames:= fo.macronames.gridvalues;
  macrovalues:= fo.macrovalues.gridvalues;
  setlength(macroon,fo.macrogrid.rowcount);
  for int1:= 0 to high(macroon) do begin
   macroon[int1]:= fo.e0.gridvaluetag(int1,0) or fo.e1.gridvaluetag(int1,0) or
                    fo.e2.gridvaluetag(int1,0) or fo.e3.gridvaluetag(int1,0) or
                    fo.e4.gridvaluetag(int1,0) or fo.e5.gridvaluetag(int1,0);
  end;
  groupcomments:= fo.groupcomment.gridvalues;
 end;
end;

procedure formtoprojectoptions(fo: tprojectoptionsfo);
var
 int1: integer;
begin
 with projectoptions,t do begin
  setlength(sigsettings,fo.signalgrid.rowcount);
  for int1:= 0 to high(sigsettings) do begin
   with sigsettings[int1] do begin
    num:= fo.signum[int1];
    numto:= fo.signumto[int1];
    updatebit({$ifdef FPC}longword{$else}byte{$endif}(flags),ord(sfl_stop),
                                fo.sigstop[int1]);
    updatebit({$ifdef FPC}longword{$else}byte{$endif}(flags),ord(sfl_handle),
                                fo.sighandle[int1]);
   end;
  end;
  exceptignore:= fo.exceptignore.gridvalues;
  exceptclassnames:= fo.exceptclassnames.gridvalues;
  
  mainfile:= fo.mainfile.value;
  targetfile:= fo.targetfile.value;
  messageoutputfile:= fo.messageoutputfile.value;

  copymessages:= fo.copymessages.value;
  closemessages:= fo.closemessages.value;
  checkmethods:= fo.checkmethods.value;
  showgrid:= fo.showgrid.value;
  snaptogrid:= fo.snaptogrid.value;
  moveonfirstclick:= fo.moveonfirstclick.value;
  gridsizex:= fo.gridsizex.value;
  gridsizey:= fo.gridsizey.value;
  
  autoindent:= fo.autoindent.value;
  blockindent:= fo.blockindent.value;
  tabstops:= fo.tabstops.value;
  spacetabs:= fo.spacetabs.value;
  rightmarginon:= fo.rightmarginon.value;
  rightmarginchars:= fo.rightmarginchars.value;
  scrollheight:= fo.scrollheight.value;
  editfontname:= fo.editfontname.value;
  editfontheight:= fo.editfontheight.value;
  editfontwidth:= fo.editfontwidth.value;
  editfontextraspace:= fo.editfontextraspace.value;
  editfontantialiased:= fo.editfontantialiased.value;
  editmarkbrackets:= fo.editmarkbrackets.value;
  backupfilecount:= fo.backupfilecount.value;
  encoding:= fo.encoding.value;
  fontalias:= fo.fontalias.gridvalues;
  fontnames:= fo.fontname.gridvalues;
  fontheights:= fo.fontheight.gridvalues;
  fontwidths:= fo.fontwidth.gridvalues;
  fontoptions:= fo.fontoptions.gridvalues;
  fontxscales:= fo.fontxscale.gridvalues;
  for int1:= high(fontxscales) downto 0 do begin
   if isemptyreal(fontxscales[int1]) then begin
    fontxscales[int1]:= 1.0;
   end;   
  end;
  usercolors:= colorarty(fo.usercolors.gridvalues);
  usercolorcomment:= fo.usercolorcomment.gridvalues;

  newprojectfiles:= fo.newprojectfiles.gridvalues;
  newprojectfilesdest:= fo.newprojectfilesdest.gridvalues;
  expandprojectfilemacros:= fo.expandprojectfilemacros.gridvalues;
  loadprojectfile:= fo.loadprojectfile.gridvalues;
  newprogramfile:= fo.newprogf.value;
  newunitfile:= fo.newunitf.value;
//  newtextfile:= fo.newtextf.value;
  newmainfosource:= fo.newformsourcefile.gridvalue[0];
  newmainfoform:= fo.newformformfile.gridvalue[0];
  newsimplefosource:= fo.newformsourcefile.gridvalue[1];
  newsimplefoform:= fo.newformformfile.gridvalue[1];
  newdockingfosource:= fo.newformsourcefile.gridvalue[2];
  newdockingfoform:= fo.newformformfile.gridvalue[2];
  newdatamodsource:= fo.newformsourcefile.gridvalue[3];
  newdatamodform:= fo.newformformfile.gridvalue[3];
  newsubfosource:= fo.newformsourcefile.gridvalue[4];
  newsubfoform:= fo.newformformfile.gridvalue[4];
  newreportsource:= fo.newformsourcefile.gridvalue[5];
  newreportform:= fo.newformformfile.gridvalue[5];
  newinheritedsource:= fo.newformsourcefile.gridvalue[6];
  newinheritedform:= fo.newformformfile.gridvalue[6];
  newpascsource:= fo.newformsourcefile.gridvalue[7];
  newpascform:= fo.newformformfile.gridvalue[7];
  
  makecommand:= fo.makecommand.value;
  makedir:= fo.makedir.value;
  debugcommand:= fo.debugcommand.value;
  debugoptions:= fo.debugoptions.value;
  debugtarget:= fo.debugtarget.value;
  runcommand:= fo.runcommand.value;
  remoteconnection:= fo.remoteconnection.value;
  uploadcommand:= fo.uploadcommand.value;
  gdbdownload:= fo.gdbdownload.value;
  downloadalways:= fo.downloadalways.value;
  startupbkpt:= fo.startupbkpt.value;
  startupbkpton:= fo.startupbkpton.value;
  gdbsimulator:= fo.gdbsimulator.value;
  gdbprocessor:= fo.gdbprocessor.value;
  gdbservercommand:= fo.gdbservercommand.value;
  gdbserverwait:= fo.gdbserverwait.value;
  beforeload:= fo.gdbbeforeload.value;
  afterload:= fo.gdbafterload.value;
  beforerun:= fo.gdbbeforerun.value;
  defaultmake:= 1 shl fo.defaultmake.value;
  makeoptions:= fo.makeoptions.gridvalues;
  setlength(makeoptionson,fo.makeoptionsgrid.rowcount);
  for int1:= 0 to high(makeoptionson) do begin
   makeoptionson[int1]:=
      fo.makeon.gridvaluetag(int1,0) or fo.buildon.gridvaluetag(int1,0) or
      fo.make1on.gridvaluetag(int1,0) or fo.make2on.gridvaluetag(int1,0) or
      fo.make3on.gridvaluetag(int1,0) or fo.make4on.gridvaluetag(int1,0);
  end;
  unitdirs:= reversearray(fo.unitdirs.gridvalues);
  setlength(unitdirson,length(unitdirs));
  for int1:= 0 to high(unitdirson) do begin
   unitdirson[high(unitdirson)-int1]:=
      fo.dmakeon.gridvaluetag(int1,0) or fo.dbuildon.gridvaluetag(int1,0) or
      fo.dmake1on.gridvaluetag(int1,0) or fo.dmake2on.gridvaluetag(int1,0) or
      fo.dmake3on.gridvaluetag(int1,0) or fo.dmake4on.gridvaluetag(int1,0) or
      fo.duniton.gridvaluetag(int1,0) or fo.dincludeon.gridvaluetag(int1,0) or
      fo.dlibon.gridvaluetag(int1,0) or fo.dobjon.gridvaluetag(int1,0);
  end;
  unitpref:= fo.unitpref.value;
  incpref:= fo.incpref.value;
  libpref:= fo.libpref.value;
  objpref:= fo.objpref.value;
  targpref:= fo.targpref.value;
  storemacros(fo);
  sourcedirs:= reversearray(fo.sourcedirs.gridvalues);
  defines:= fo.def.gridvalues;
  defineson:= fo.defon.gridvalues;
  syntaxdeffiles:= fo.grid[0].datalist.asarray;
  sourcefilemasks:= fo.grid[1].datalist.asarray;
  filemasknames:= fo.filefiltergrid[0].datalist.asarray;
  filemasks:= fo.filefiltergrid[1].datalist.asarray;
  toolsave:= fo.toolsave.gridvalues;
  toolhide:= fo.toolhide.gridvalues;
  toolparse:= fo.toolparse.gridvalues;
  toolmenus:= fo.toolmenu.gridvalues;
  toolfiles:= fo.toolfile.gridvalues;
  toolparams:= fo.toolparam.gridvalues;  
  stoponexception:= fo.stoponexception.value;
  valuehints:= fo.valuehints.value;
  activateonbreak:= fo.activateonbreak.value;
  showconsole:= fo.showconsole.value;
  externalconsole:= fo.externalconsole.value;
 end;
 expandprojectmacros;
end;

procedure projectoptionschanged;
var
 int1: integer;
begin
 sourceupdater.unitchanged;
 for int1:= 0 to designer.modules.count - 1 do begin
  tdesignwindow(designer.modules[int1]^.designform.window).updateprojectoptions;
 end;
 createcpufo;
end;

function readprojectoptions(const filename: filenamety): boolean;
var
 statreader: tstatreader;
begin
 result:= false;
 try
  statreader:= tstatreader.create(filename,ce_utf8n);
  try
   application.beginwait;
   updateprojectoptions(statreader,filename);
//   projectoptions.projectfilename:= filename;
  finally
   statreader.free;
   application.endwait;
   projectoptionschanged;
  end;
  result:= true;
 except
  on e: exception do begin
   showerror('Can not read project "'+filename+'".'+lineend+e.message,'ERROR');
  end;
 end;
end;

procedure saveprojectoptions(filename: filenamety = '');
var
 statwriter: tstatwriter;
begin
 if filename = '' then begin
  filename:= projectoptions.projectfilename;
 end;
 statwriter:= tstatwriter.create(filename,ce_utf8n);
 try
  updateprojectoptions(statwriter,filename);
//  projectoptions.projectfilename:= filename;
 finally
  statwriter.free;
 end;
end;

function editprojectoptions: boolean;
var
 fo: tprojectoptionsfo;
begin
 fo:= tprojectoptionsfo.create(nil);
// fo.debuggerpage.enabled:= not mainfo.gdb.running;
 projectoptionstoform(fo);
 try
  result:= fo.show(true,nil) = mr_ok;
  if result then begin
   with mainfo.gdb do begin
    if not started then begin
     closegdb;
    end;
   end;
   fo.window.nofocus; //remove empty grid lines
   formtoprojectoptions(fo);
   projectoptionsmodified;
   projectoptionschanged;
  end;
 finally
  fo.Free;
 end;
end;

procedure tprojectoptionsfo.activegroupchanged;
var
 int1,int2: integer;
begin
 int2:= 0;
 for int1:= 0 to selectactivegroupgrid.rowcount-1 do begin
  if activemacroselect[int1] then begin
   int2:= int1;
   break;
  end;
 end;
 for int1:= 0 to 5 do begin
  if int1 = int2 then begin
   macrogrid.datacols[int1].color:= cl_infobackground;
  end
  else begin
   macrogrid.datacols[int1].color:= cl_default;
  end;
 end;
 projectoptions.macrogroup:= int2;
end;

procedure tprojectoptionsfo.acttiveselectondataentered(const sender: TObject);
var
 int1: integer;
begin
 for int1:= 0 to selectactivegroupgrid.rowcount-1 do begin
  activemacroselect[int1]:= false;
 end;
 tbooleaneditradio(sender).value:= true;
 activegroupchanged;
 projectoptions.macrogroup:= selectactivegroupgrid.row;
end;

procedure tprojectoptionsfo.colonshowhint(const sender: tdatacol; 
                const arow: Integer; var info: hintinfoty);
begin
 storemacros(self);
 if sender is twidgetcol then begin
  info.caption:= tcustomstringedit(twidgetcol(sender).editwidget).gridvalue[arow];
 end
 else begin
  info.caption:= tstringcol(sender)[arow];
 end;
 expandprmacros1(info.caption);
 include(info.flags,hfl_show); //show empty caption
end;

procedure tprojectoptionsfo.hintexpandedmacros(const sender: TObject;
                           var info: hintinfoty);
begin
 storemacros(self);
 info.caption:= tcustomedit(sender).text;
 expandprmacros1(info.caption);
 include(info.flags,hfl_show); //show empty caption
end;

procedure tprojectoptionsfo.selectactiveonrowsmoved(const sender: tcustomgrid;
       const fromindex: Integer; const toindex: Integer; const acount: Integer);
begin
 activegroupchanged;
end;

procedure tprojectoptionsfo.expandfilename(const sender: TObject;
                     var avalue: mseString; var accept: Boolean);
begin
 expandprmacros1(avalue);
end;

procedure tprojectoptionsfo.showcommandlineonexecute(const sender: TObject);
var
 info1: projectoptionsty;
begin
 info1:= projectoptions;
 formtoprojectoptions(self);
 commandlineform.showcommandline;
 projectoptions:= info1;
end;

procedure tprojectoptionsfo.signameonsetvalue(const sender: TObject; var avalue: LongInt; var accept: Boolean);
begin
 signum.value:= avalue;
 signumto.value:= avalue;
end;

procedure tprojectoptionsfo.signumonsetvalue(const sender: TObject; var avalue: LongInt; var accept: Boolean);
begin
 signame.value:= avalue;
 signumto.value:= avalue;
end;

procedure tprojectoptionsfo.signumtoonsetvalue(const sender: TObject; var avalue: Integer; var accept: Boolean);
begin
 if avalue <= signum.value then begin
  signum.value:= avalue;
  signame.value:= avalue;
 end
 else begin
  signame.value:= -1;
 end;
end;

procedure tprojectoptionsfo.fontondataentered(const sender: TObject);
const
 teststring = 'ABCDEFGabcdefgy0123WWWiii ';
var
 format1: formatinfoarty;
begin
 with fontdisp.font do begin
  name:= editfontname.value;
  height:= editfontheight.value;
  width:= editfontwidth.value;
  extraspace:= editfontextraspace.value;
  if editfontantialiased.value then begin
   options:= options + [foo_antialiased];
  end
  else begin
   options:= options + [foo_nonantialiased];
  end;
  dispgrid.datarowheight:= lineheight;
  fontdisp[0]:= teststring+teststring+teststring+teststring;
  format1:= nil;
  updatefontstyle(format1,length(teststring),length(teststring),fs_bold,true);
  updatefontstyle(format1,2*length(teststring),2*length(teststring),fs_italic,true);
  updatefontstyle(format1,3*length(teststring),length(teststring),fs_bold,true);
  fontdisp.richformats[0]:= format1;
  fontdisp[1]:= 
    'Ascent: '+inttostr(ascent)+' Descent: '+inttostr(descent)+
    ' Linespacing: '+inttostr(lineheight);
 end;
end;

procedure tprojectoptionsfo.makepageonchildscaled(const sender: TObject);
var
 int1: integer;
begin
 placeyorder(0,[0,0,0,15],[mainfile,makecommand,messageoutputfile,
                    defaultmake,makegroupbox],0);
 aligny(wam_center,[mainfile,targetfile,targpref]);
 aligny(wam_center,[makecommand,makedir]);
 aligny(wam_center,[messageoutputfile,copymessages]);
 placexorder(defaultmake.bounds_x,[10-defaultmake.frame.outerframe.right,10],
             [defaultmake,showcommandline,checkmethods]);
 int1:= aligny(wam_center,[defaultmake,showcommandline]);
 with checkmethods do begin
  bounds_y:= int1 - bounds_cy - 2;
 end;
 with closemessages do begin
  pos:= makepoint(checkmethods.bounds_x,int1);
 end;
end;

procedure tprojectoptionsfo.debuggeronchildscaled(const sender: TObject);
begin
 placeyorder(0,[0,0,10],[debugcommand,debugoptions,debugtarget,tlayouter1]);
 aligny(wam_center,[debugtarget,runcommand]);
end;

procedure tprojectoptionsfo.macronchildscaled(const sender: TObject);
var
 int1: integer;
begin
 int1:= macrosplitter.bounds_y;
 placeyorder(0,[0],[selectactivegroupgrid,macrosplitter,macrogrid],0);
 macrosplitter.move(makepoint(0,int1-macrosplitter.bounds_y));
end;


procedure tprojectoptionsfo.formtemplateonchildscaled(const sender: TObject);
begin
{
 placeyorder(0,[0],[mainfosource,mainfoform,simplefosource,simplefoform,
       dockingfosource,dockingfoform,datamodsource,datamodform,
       subfosource,subfoform,reportsource,reportform,
       inheritedsource,inheritedform]);
}
end;

procedure tprojectoptionsfo.encodingsetvalue(const sender: TObject;
               var avalue: LongInt; var accept: Boolean);
var
 mstr1: msestring;
begin
 mstr1:= encoding.dropdown.valuelist[avalue];
 accept:= askyesno('Wrong encoding can damage your source files.'+lineend+
             'Do you wish to set encoding to '+mstr1+'?','*** WARNING ***');
end;

procedure tprojectoptionsfo.createexe(const sender: TObject);
begin
 {$ifdef mswindows}
 externalconsole.visible:= true;
 {$endif}
end;

procedure tprojectoptionsfo.drawcol(const sender: tpointeredit;
               const acanvas: tcanvas; const avalue: Pointer;
               const arow: Integer);
begin
 with pcellinfoty(acanvas.drawinfopo)^ do begin
  acanvas.fillrect(innerrect,usercolors[arow]);
 end;
end;

procedure tprojectoptionsfo.colsetvalue(const sender: TObject;
               var avalue: colorty; var accept: Boolean);
begin
 colgrid.invalidaterow(colgrid.row);
end;

procedure tprojectoptionsfo.copycolorcode(const sender: TObject);
var
 str1: msestring;
 int1: integer;
begin
 str1:= '';
 for int1:= 0 to colgrid.rowhigh do begin
  if usercolors[int1] <> 0 then begin
   str1:= str1 + ' setcolormapvalue('+colortostring(cl_user+cardinal(int1))+','+
               colortostring(usercolors[int1])+');';
   if usercolorcomment[int1] <> '' then begin
    str1:= str1 + ' //'+usercolorcomment[int1];
   end;
   str1:= str1+lineend;
  end;
 end;
 copytoclipboard(str1);
end;

procedure tprojectoptionsfo.downloadchange(const sender: TObject);
begin
 uploadcommand.enabled:= not gdbdownload.value and not gdbsimulator.value;
 gdbbeforeload.enabled:= gdbdownload.value and not gdbsimulator.value;
 gdbafterload.enabled:= gdbdownload.value and not gdbsimulator.value;
 gdbservercommand.enabled:= not gdbsimulator.value;
 gdbserverwait.enabled:= not gdbsimulator.value;
 remoteconnection.enabled:= not gdbsimulator.value;
 gdbdownload.enabled:= not gdbsimulator.value;
 downloadalways.enabled:= not gdbsimulator.value;
 startupbkpt.enabled:= startupbkpton.value;
end;

procedure tprojectoptionsfo.processorchange(const sender: TObject);
begin
 mainfo.gdb.processorname:= gdbprocessor.value;
 if not (mainfo.gdb.processor in simulatorprocessors) then begin
  gdbsimulator.value:= false;
  gdbsimulator.enabled:= false;
 end
 else begin
  gdbsimulator.enabled:= true;
 end;
end;

procedure tprojectoptionsfo.copymessagechanged(const sender: TObject);
begin
 messageoutputfile.enabled:= copymessages.value;
end;

procedure tprojectoptionsfo.runcommandchange(const sender: TObject);
begin
 debugtarget.enabled:= runcommand.value = '';
end;

{
procedure tprojectoptionsfo.befla(const sender: tlayouter);
begin
 writeln('before '+sender.widgets[0].name+':',sender.widgets[0].bounds_x,' '+
         sender.widgets[1].name+':',sender.widgets[1].bounds_x);
end;

procedure tprojectoptionsfo.afterla(const sender: tlayouter);
begin
 writeln('after '+sender.widgets[0].name+':',sender.widgets[0].bounds_x,' '+
         sender.widgets[1].name+':',sender.widgets[1].bounds_x);
end;

procedure tprojectoptionsfo.bef1(const sender: tlayouter);
begin
 writeln('before1 '+sender.widgets[0].name+':',sender.widgets[0].bounds_y,' '+
         sender.widgets[1].name+':',sender.widgets[1].bounds_y);
end;

procedure tprojectoptionsfo.aft1(const sender: tlayouter);
begin
 writeln('after1 '+sender.widgets[0].name+':',sender.widgets[0].bounds_y,' '+
         sender.widgets[1].name+':',sender.widgets[1].bounds_y);
end;
}
end.
