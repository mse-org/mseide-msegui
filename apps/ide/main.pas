{ MSEide Copyright (c) 1999-2017 by Martin Schreiber
 
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
unit main;
{$ifdef linux}{$define unix}{$endif}
{$ifdef FPC}
 {$mode objfpc}{$h+}{$goto on}
{$endif}
{$ifndef mse_no_ifi}
 {$define mse_with_ifi}
{$endif}
{$ifdef mse_no_ifi}
 {$define mse_no_db}
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
 mseforms,msesimplewidgets,mseguiglob,msegui,msegdbutils,mseactions,
 msedispwidgets,msedataedits,msestat,msestatfile,msemenus,msebitmap,msetoolbar,
 msegrids,msefiledialog,msetypes,sourcepage,msetabs,msedesignintf,msedesigner,
 classes,mclasses,mseclasses,msegraphutils,typinfo,msedock,sysutils,msesysenv,
 msemacros,msestrings,msepostscriptprinter,msegraphics,mseglob,msestream,
 mseprocmonitorcomp,msesystypes,mserttistat,msedatanodes,mseedit,mseifiglob,
 mselistbrowser,projecttreeform,msepipestream,msestringcontainer,msesys,
 msewidgets;
const
 versiontext = '4.6.3';
 idecaption = 'MSEide';
 statname = 'mseide';

type
 stringconsts = (
  unresreferences,    //0 Unresolved references in
  str_to,             //1 to
  wishsearch,         //2 Do you wish to search the formfile?
  warning,            //3 WARNING
  formfile,           //4 Formfile for
  formfiles,          //5 Formfiles
  recursive,          //6 Recursive form hierarchy for "
  error,              //7 ERROR
  str_classtype,      //8 Classtype
  notfound,           //9 not found.
  project,            //10 Project
  ismodified,         //11 is modified. Save?
  confirmation,       //12 Confirmation
  unableopen,         //13 Unable to open file "
  running,            //14 *** Running ***
  str_downloading,        //15 Downloading
  str_downloaded,         //16 Downloaded
  startgdbservercommand, //17 Start gdb server command "
  running2,           //18 " running.
  startgdbserver,     //19 Start gdb Server
  gdbserverstarterror,//20 gdb server start error
  gdbservercanceled,  //21 gdb server start canceled.
  cannotrunstartgdb,  //22 Can not run start gdb command.
  str_uploadcommand,  //23 Uploadcommand "
  downloaderror,      //24 Download ***ERROR***
  downloadfinished,   //25 Download finished.
  downloadcanceled,   //26 Download canceled.
  str_file,           //27 File "
  notfound2,          //28 " not found.
  exists,             //29 " exists.
  str_new,            //30 New
  selectancestor,     //31 Select ancestor
  newform,            //32 New form
  pascalfiles,        //33 Pascal Files
  new2,               //34 new
  cannotloadproj,     //35 Can not load Project "
  selecttemplate,     //36 Select project template
  projectfiles,       //37 Project files
  str_allfiles,       //38 All files
  selectprogramfile,  //39 Select program file
  pascalprogfiles,    //40 Pascal program files
  cfiles,             //41 C program files
  str_newproject,     //42 New Project
  cannotstartprocess, //43 Can not start process
  process,            //44 Process
  running3,           //45 running.
  processterminated,  //46 Process terminated
  proctermnormally,   //47 Process terminated normally.
  makeerror,          //48 Make ***ERROR***
  makeok,             //49 Make OK.
  str_sourcechanged,  //50 Source has changed, do you wish to remake project?
  str_loadwindowlayout,   //51 Load Window Layout
  dockingarea         //52 Docking Area
 );

 filekindty = (fk_none,fk_source,fk_unit);
 messagetextkindty = (mtk_info,mtk_running,mtk_finished,mtk_error,mtk_signal);

 startcommandty = (sc_none,sc_step,sc_continue);
// formkindty = (fok_main,fok_simple,fok_dock,fok_data,fok_subform,
//               fok_report,fok_script,fok_inherited);

 tmainfo = class(tdockform,idesignnotification)
   gdb: tgdbmi;
   filedisp: tstringdisp;
   linedisp: tintegerdisp;
   projectstatfile: tstatfile;
   reasondisp: tintegerdisp;
   expr: tstringedit;
   exprdisp: tstringdisp;
   symboltype: tstringedit;
   symboltypedisp: tstringdisp;
   mainstatfile: tstatfile;
   mainmenu1: tmainmenu;
   statdisp: tstringdisp;
   errordisp: tstringdisp;
   basedock: tdockpanel;

   openfile: tfiledialog;

   dummyimagelist: timagelist;
   vievmenuicons: timagelist;

   viewmenu: tframecomp;
   runprocmon: tprocessmonitor;
   statoptions: trttistat;
   projectfiledia: tfiledialog;
   targetpipe: tpipereadercomp;
   c: tstringcontainer;
   openform: tfiledialog;
   formbg: tbitmapcomp;
   procedure newfileonexecute(const sender: tobject);
   procedure newformonexecute(const sender: TObject);

   procedure mainfooncreate(const sender: tobject);
   procedure mainfoondestroy(const sender: tobject);
   procedure mainstatfileonupdatestat(const sender: tobject; const filer: tstatfiler);
   procedure mainfoonterminate(var terminate: Boolean);
   procedure mainonloaded(const sender: TObject);

   procedure mainmenuonupdate(const sender: tcustommenu);
   procedure onscale(const sender: TObject);
   procedure parametersonexecute(const sender: TObject);
   procedure buildactonexecute(const sender: TObject);
   procedure saveprojectasonexecute(const sender: tobject);
   procedure newprojectonexecute(const sender: TObject);
   procedure closeprojectactonexecute(const sender: TObject);
   procedure exitonexecute(const sender: tobject);
   procedure newpanelonexecute(const sender: TObject);

   procedure viewassembleronexecute(const sender: TObject);
   procedure viewcpuonexecute(const sender: TObject);
   procedure viewmessagesonexecute(const sender: TObject);
   procedure viewsourceonexecute(const sender: tobject);
   procedure viewbreakpointsonexecute(const sender: tobject);
   procedure viewwatchesonexecute(const sender: tobject);
   procedure viewstackonexecute(const sender: tobject);
   procedure viewobjectinspectoronexecute(const sender: TObject);
   procedure toggleobjectinspectoronexecute(const sender: tobject);
   procedure viewcomponentpaletteonexecute(const sender: TObject);
   procedure viewcomponentstoreonexecute(const sender: TObject);
   procedure viewdebuggertoolbaronexecute(const sender: TObject);
   procedure viewwatchpointsonexecute(const sender: TObject);
   procedure viewthreadsonexecute(const sender: TObject);
   procedure viewconsoleonexecute(const sender: TObject);
   procedure viewfindresults(const sender: TObject);
   procedure aboutonexecute(const sender: TObject);
   procedure configureexecute(const sender: TObject);
   
    //debugger
   procedure restartgdbonexecute(const sender: tobject);
   procedure runexec(const sender: tobject);
   procedure gdbonevent(const sender: tgdbmi; var eventkind: gdbeventkindty;
                       const values: resultinfoarty; const stopinfo: stopinfoty);
   procedure expronsetvalue(const sender: tobject; var avalue: msestring;
                           var accept: boolean);
   procedure symboltypeonsetvalue(const sender: tobject; var avalue: msestring;
                           var accept: boolean);
   procedure openprojectcopyexecute(const sender: TObject);
   procedure saveprojectcopyexecute(const sender: TObject);
   procedure newprojectfromprogramexe(const sender: TObject);
   procedure newemptyprojectexe(const sender: TObject);
   procedure viewmemoryonexecute(const sender: TObject);
   procedure runprocdied(const sender: TObject; const prochandle: prochandlety;
                   const execresult: Integer; const data: Pointer);
   procedure statbefread(const sender: TObject);
   procedure viewsymbolsonexecute(const sender: TObject);
   procedure loadwindowlayoutexe(const sender: TObject);
   procedure getstatobjs(const sender: TObject; var aobjects: objectinfoarty);
   procedure targetpipeinput(const sender: tpipereader);
   procedure mainstatbeforewriteexe(const sender: TObject);
   procedure statafterread(const sender: TObject);
   procedure basedockpaintexe(const sender: twidget; const acanvas: tcanvas);
  private
   fstartcommand: startcommandty;
   fnoremakecheck: boolean;
   fcurrent: boolean;
   flastform: tcustommseform;
   flastdesignform: tcustommseform;
   fexecstamp: integer;
   fprojectname: filenamety;
   fcheckmodulelevel: integer;
   fgdbserverprocid: integer;
   fgdbserverexitcode: integer;
   fgdbservertimeout: longword;
   ftargetfilemodified: boolean;
   frunningprocess: prochandlety;
   flayoutloading: boolean;
   fstopinfo: stopinfoty;
   fgdbdownloaded: boolean;
   procedure dorun;
   function runtarget: boolean; //true if run possible
   procedure newproject(const fromprogram,empty: boolean);
   procedure doshowform(const sender: tobject);
   procedure setprojectname(aname: filenamety); 
            //not const because of not refcounted widestrings
   procedure dofindmodulebyname(const amodule: pmoduleinfoty; const aname: string;
                         var action: modalresultty);
   procedure dofindmodulebytype(const atypename: string);

    //idesignnotification
   procedure ItemDeleted(const ADesigner: IDesigner;
                   const amodule: tmsecomponent; const AItem: tcomponent);
   procedure ItemInserted(const ADesigner: IDesigner;
                   const amodule: tmsecomponent; const AItem: tcomponent);
   procedure ItemsModified(const ADesigner: IDesigner; const AItem: tobject);
   procedure componentnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const aitem: tcomponent;
                     const newname: string);
   procedure moduleclassnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
   procedure instancevarnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
   procedure SelectionChanged(const ADesigner: IDesigner;
                     const ASelection: IDesignerSelections);
   procedure moduleactivated(const adesigner: idesigner; const amodule: tmsecomponent);
   procedure moduledeactivated(const adesigner: idesigner; const amodule: tmsecomponent);
   procedure moduledestroyed(const adesigner: idesigner; const amodule: tmsecomponent);
   procedure methodcreated(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const aname: string; const atype: ptypeinfo);
   procedure methodnamechanged(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const newname,oldname: string; const atypeinfo: ptypeinfo);
   procedure showobjecttext(const adesigner: idesigner;
                    const afilename: filenamety; const backupcreated: boolean);
   procedure closeobjecttext(const adesigner: idesigner;
                    const afilename: filenamety; var cancel: boolean);
   procedure beforefilesave(const adesigner: idesigner;
                                    const afilename: filenamety);
   procedure beforemake(const adesigner: idesigner; const maketag: integer;
                         var abort: boolean);
   procedure aftermake(const adesigner: idesigner; const exitcode: integer);

   function checksave: modalresultty;
   procedure unloadexec;
   procedure cleardebugdisp;
   procedure resetdebugdisp; //called before running debuggee
   procedure createprogramfile(const aname: filenamety);
   function copynewfile(const aname,newname: filenamety;
                            const autoincrement: boolean;
                            const canoverwrite: boolean;
                            const macronames: array of msestring;
                            const macrovalues: array of msestring): boolean;
                            //true if ok
   procedure createform(const aname: filenamety; const namebase: string;
                        const formsuffix: string;
                        const ancestor: string);
   procedure removemodulemenuitem(const amodule: pmoduleinfoty);
   procedure uploadexe(const sender: tguiapplication; var again: boolean);
   procedure uploadcancel(const sender: tobject);
   procedure gdbserverexe(const sender: tguiapplication; var again: boolean);
   function terminategdbserver(const force: boolean): boolean;
   procedure gdbservercancel(const sender: tobject);
   procedure updatetargetenvironment;
   function needsdownload: boolean;
   function candebug: boolean; //run command empty or process attached
   procedure startconsole();
  public
   factivedesignmodule: pmoduleinfoty;
   fprojectloaded: boolean;
   errorformfilename: filenamety;
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;

   procedure designformactivated(const sender: tcustommseform);
   procedure startgdb(const killserver: boolean);
   function checkgdberror(aresult: gdbresultty): boolean;
   function startgdbconnection(const attach: boolean): boolean;
   function loadexec(isattach: boolean;
                       const forcedownload: boolean): boolean; //true if ok
   procedure setstattext(const atext: msestring; const akind: messagetextkindty = mtk_info);
   procedure refreshstopinfo(const astopinfo: stopinfoty);
   procedure updatemodifiedforms;
   function checkremake(startcommand: startcommandty): boolean;
                         //true if running possible
   procedure resetstartcommand;
   procedure killtarget;
   procedure domake(atag: integer);
   procedure targetfilemodified;
   function checksavecancel(const aresult: modalresultty): modalresultty;
   function closeall(const nosave: boolean): boolean; //false in cancel
   function closemodule(const amodule: pmoduleinfoty;
                          const achecksave: boolean;
                           nocheckclose: boolean = false): boolean;
   function openproject(const aname: filenamety;
                             const ascopy: boolean = false): boolean;
   procedure saveproject(aname: filenamety; const ascopy: boolean = false);
   procedure savewindowlayout(const astream: ttextstream);
   procedure savewindowlayout(const awriter: tstatwriter);
   procedure loadwindowlayout(const astream: ttextstream);
   procedure loadwindowlayout(const areader: tstatreader);

   procedure sourcechanged(const sender: tsourcepage);
   function opensource(const filekind: filekindty; const addtoproject: boolean;
                        const aactivate: boolean = true;
                        const currentnode: tprojectnode = nil): boolean;
            //true if filedialog not canceled
   function openformfile(const filename: filenamety; 
                const ashow,aactivate,showsource,createmenu,
                                skipexisting: boolean): pmoduleinfoty;
   procedure createmodulemenuitem(const amodule: pmoduleinfoty);   
   function formmenuitemstart: integer;
   procedure loadformbysource(const sourcefilename: filenamety);
   procedure loadsourcebyform(const formfilename: filenamety; 
                                 const aactivate: boolean = false);
   procedure checkbluedots;
   procedure updatesigsettings;
   procedure runtool(const sender: tobject);

   procedure downloaded;
   procedure programfinished;
   procedure showfirsterror;
   procedure stackframechanged(const frameno: integer);
   procedure refreshframe;
   procedure toggleformunit;
   property projectname: filenamety read fprojectname;
   property lastform: tcustommseform read flastform;
   property execstamp: integer read fexecstamp;
   property stopinfo: stopinfoty read fstopinfo;
 end;

var
 mainfo: tmainfo;

procedure handleerror(const e: exception; const text: string);
implementation
uses
 regwidgets,regeditwidgets,regdialogs,regkernel,regprinter,msearrayutils,
 toolhandlermodule,
{$ifndef mse_no_math}
 regmath,regmm,
{$endif}
{$ifndef mse_no_db}
 regdb,regreport,
{$endif}
{$ifdef mse_with_ifi}
 regifi,{$ifndef mse_no_ifirem}regifirem,{$endif}
{$endif}
{$ifdef mse_with_pascalscript}
 regpascalscript,
{$endif}
{$ifdef mse_with_zeoslib}
 regzeoslib,
{$endif}
 regdesignutils,regsysutils,regcrypto,regserialcomm,regexperimental,
{$ifndef mse_no_deprecated}
 regdeprecated,
{$endif}
 {$ifdef morecomponents}
  {$include regcomponents.inc}
 {$endif}

 mseparser,msesysintf,memoryform,msedrawtext,mseformatstr,
 main_mfm,sourceform,watchform,breakpointsform,stackform,
 guitemplates,projectoptionsform,make,msepropertyeditors,
 skeletons,msedatamodules,mseact,
 mseformdatatools,mseshapes,msefileutils,mseeditglob,
 findinfileform,formdesigner,sourceupdate,actionsmodule,programparametersform,
 objectinspector,msesysutils,cpuform,disassform,
 panelform,watchpointsform,threadsform,targetconsole,
 debuggerform,componentpaletteform,componentstore,
 messageform,msesettings,mseintegerenter,symbolform
 {$ifdef unix},mselibc {$endif}, //SIGRT*
 mseprocutils
 {$ifdef mse_dumpunitgroups},dumpunitgroups{$endif};

{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
 
procedure handleerror(const e: exception; const text: string);
begin
 if text <> '' then begin
  writestderr(text+' '+e.message,true);
 end
 else begin
  writestderr(e.message,true);
 end;
end;

{ tmainfo }

constructor tmainfo.create(aowner: tcomponent);
begin
 frunningprocess:= invalidprochandle;
 fgdbserverprocid:= invalidprochandle;
 inherited create(aowner);
end;

destructor tmainfo.destroy;
begin
 terminategdbserver(true);
 inherited;
end;

//common

procedure tmainfo.mainfooncreate(const sender: tobject);
begin
 designer.ongetmodulenamefile:= {$ifdef FPC}@{$endif}dofindmodulebyname;
 designer.ongetmoduletypefile:= {$ifdef FPC}@{$endif}dofindmodulebytype;

 designer.objformat:= of_fp;
 componentpalettefo.updatecomponentpalette(true);
 designnotifications.Registernotification(idesignnotification(self));
 watchfo.gdb:= gdb;
 breakpointsfo.gdb:= gdb;
 watchpointsfo.gdb:= gdb;
 stackfo.gdb:= gdb;
 threadsfo.gdb:= gdb;
 disassfo.gdb:= gdb; 
 initprojectoptions;
 sourceupdate.init(designer);
{$ifndef mse_with_pascalscript}
 mainmenu1.menu.deleteitembynames(['file','new','form','pascform']);
{$endif}
end;

procedure tmainfo.mainfoondestroy(const sender: tobject);
begin
 designnotifications.unRegisternotification(idesignnotification(self));
 abortmake;
 abortdownload;
 sourceupdate.deinit(designer);
end;

procedure tmainfo.dofindmodulebyname(const amodule: pmoduleinfoty;
                        const aname: string; var action: modalresultty);
var
 wstr2: msestring;

 function dofind(const modulenames: array of msestring;
                           const modulefilenames: array of filenamety): boolean;
 var
  int1: integer;
  wstr1: msestring;
  po1: pmoduleinfoty;
 begin
  result:= false;
  for int1:= 0 to high(modulenames) do begin
   if modulenames[int1] = wstr2 then begin
    if int1 <= high(modulefilenames) then begin
     wstr1:= modulefilenames[int1];
     if relocatepath(projectoptions.projectdir,'',wstr1,[pro_preferenew]) or
            findfile(modulefilenames[int1],
                           projectoptions.d.texp.sourcedirs,wstr1) or
            findfile(filename(modulefilenames[int1]),
                            projectoptions.d.texp.sourcedirs,wstr1) then begin
      try
       po1:= openformfile(wstr1,false,false,false,false,false);
       result:= (po1 <> nil) and 
                      (msestring(struppercase(po1^.instancevarname)) = wstr2);
      except
       application.handleexception;
       result:= false;
      end;
     end;
    end;
    break;
   end;
  end;
 end;

var
 bo1: boolean;
 int1: integer;
 mstr1: filenamety;

begin
 wstr2:= msestring(struppercase(aname));
 int1:= findchar(wstr2,'.');
 if int1 > 0 then begin
  setlength(wstr2,int1-1); //main name only
 end;
 with projectoptions do begin
  bo1:= dofind(s.modulenames,s.modulefiles);
 end;
 if not bo1 and 
           projecttree.units.findformbyname(ansistring(wstr2),mstr1) then begin
  bo1:= dofind([wstr2],[mstr1]);
 end;
 if bo1 then begin
  action:= mr_ok;
 end
 else begin
  action:= showmessage(c[ord(unresreferences)]+' '+
            msestring(amodule^.moduleclassname)+' '+
                        c[ord(str_to)]+' ' +
                msestring(aname) + '.'+lineend+
                       ' '+c[ord(wishsearch)],c[ord(warning)],
                       [mr_ok,mr_cancel],mr_ok);
  case action of
   mr_ok: begin
    wstr2:= '';
//    openform.controller.filename:= '';
//    openform.controller.captionopen:= c[ord(formfile)]+' '+ aname;
    if openform.controller.execute(wstr2,fdk_open,
                            c[ord(formfile)]+' '+ msestring(aname)) then begin
//    action:= filedialog(wstr2,[fdo_checkexist],c[ord(formfile)]+' '+ aname,
//                 [c[ord(formfiles)]],['*.mfm'],'',nil,nil,nil,[fa_all],[fa_hidden]);
//                 //defaultvalues don't work on kylix
//    if action = mr_ok then begin
//     openformfile(openform.controller.filename,false,false,true,true,false);
     openformfile(wstr2,false,false,true,true,false);
    end;
   end;
  end;
 end;
end;

procedure tmainfo.dofindmodulebytype(const atypename: string);
var
 wstr2: msestring;
 int1: integer;
 po1: pmoduleinfoty;
 
 procedure checkmodule(fname: filenamety);
 var
  wstr1: filenamety;
 begin
  with projectoptions do begin
   if findfile(fname,d.texp.sourcedirs,wstr1) or
          findfile(fname,d.texp.sourcedirs,wstr1) then begin
    try
     po1:= openformfile(wstr1,false,false,false,false,false);
    except
     on e: eabort do begin
      raise;
     end
     else begin
      po1:= nil;
      application.handleexception;
     end;
    end;
   end;
  end;
 end;
 
var
// ar1: msestringarty;
 mstr1: filenamety;
  
begin
// ar1:= nil; //compilerwarning
 if fcheckmodulelevel >= 16 then begin
  showmessage(c[ord(recursive)]+msestring(atypename)+'"',c[ord(error)]);
  sysutils.abort;
 end;
 inc(fcheckmodulelevel);
 try
  with projectoptions do begin
   po1:= nil;
   wstr2:= msestring(struppercase(atypename));
   for int1:= 0 to high(s.moduletypes) do begin
    if s.moduletypes[int1] = wstr2 then begin
     if int1 <= high(s.modulefiles) then begin
      checkmodule(s.modulefiles[int1]);
     end;
     break;
    end;
   end;
  end;
  if po1 = nil then begin
   if projecttree.units.findformbyclass(ansistring(wstr2),mstr1) then begin
    checkmodule(mstr1);
   end;
  {
   ar1:= projecttree.units.moduleclassnames;
   for int1:= 0 to high(ar1) do begin
    if ar1[int1] = wstr2 then begin
     checkmodule(projecttree.units.modulefilenames[int1]);
     break;
    end;
   end;
   }
  end;
  if (po1 = nil) or 
             (stringicomp(po1^.moduleclassname,atypename) <> 0) then begin
   if showmessage(c[ord(str_classtype)]+' '+msestring(atypename)+
                         ' '+c[ord(notfound)]+lineend+
                         ' '+c[ord(wishsearch)],c[ord(warning)],
                         [mr_yes,mr_cancel]) = mr_yes then begin
    wstr2:= '';
//    if filedialog(wstr2,[fdo_checkexist],c[ord(formfile)]+' '+ 
//               msestring(atypename),
//                   [c[ord(formfiles)]],['*.mfm']) = mr_ok then begin
    if openform.controller.execute(wstr2,fdk_open,c[ord(formfile)]+' '+ 
                       msestring(atypename),[fdo_checkexist]) then begin
     openformfile(wstr2,false,false,false,false,false);
    end;
   end;
  end;
 finally
  dec(fcheckmodulelevel);
 end;
end;

//editor
//formdesigner


procedure Tmainfo.doshowform(const sender: tobject);
begin
 with tmenuitem(sender) do begin
  designer.showformdesigner(pmoduleinfoty(tagpo));
 end;
end;

procedure tmainfo.toggleobjectinspectoronexecute(const sender: tobject);
begin
 if (flastform = objectinspectorfo) then begin
  if flastdesignform <> nil then begin
   flastdesignform.activate(true);
  end;
 end
 else begin
  objectinspectorfo.activate(true);
 end;
end;

procedure tmainfo.viewobjectinspectoronexecute(const sender: TObject);
begin
  objectinspectorfo.activate(true);
end;

 //idesignnotification

procedure Tmainfo.ItemDeleted(const ADesigner: IDesigner;
               const amodule: tmsecomponent; const AItem: tcomponent);
begin

end;

procedure Tmainfo.ItemInserted(const ADesigner: IDesigner;
               const amodule: tmsecomponent; const AItem: tcomponent);
begin
 componentpalettefo.resetselected;
end;

procedure tmainfo.moduleactivated(const adesigner: idesigner; const amodule: tmsecomponent);
begin
 factivedesignmodule:= designer.actmodulepo;
 setlinkedvar(factivedesignmodule^.designform,tmsecomponent(flastdesignform));
end;

procedure tmainfo.moduledeactivated(const adesigner: idesigner; const amodule: tmsecomponent);
begin
// factivedesignmodule:= nil;
end;
{
procedure tmainfo.sourceformactivated;
begin
 factivedesignmodule:= nil;
end;
}
function tmainfo.checksave: modalresultty;
var
 str1: filenamety;
begin
 result:= sourcefo.saveall(false);
 if result <> mr_cancel then begin
  result:= designer.saveall(result = mr_all,true);
  if result <> mr_cancel then begin
   result:= componentstorefo.saveall(false);
   if result <> mr_cancel then begin
    with projectoptions,s,texp do begin
     if modified and not savechecked then begin
      result:= showmessage(c[ord(project)]+' '+fprojectname+' '+
         c[ord(ismodified)],c[ord(confirmation)],
                     [mr_yes,mr_no,mr_cancel],mr_yes);
      if result = mr_yes then begin
       if projectfilename = '' then begin
        result:= projectfiledialog(str1,true);
        if result <> mr_ok then begin
         result:= mr_cancel;
        end;
       end
       else begin
        str1:= projectfilename;
       end;
       if result <> mr_cancel then begin
        saveproject(str1);
       end;
      end
      else begin
       if result <> mr_no then begin
        result:= mr_cancel;
       end;
      end;
      savechecked:= true;
     end
     else begin
      saveproject(projectfilename);
     end;
    end;
   end;
  end;
 end;
  
 checksavecancel(result);
end;

procedure tmainfo.updatemodifiedforms();
var
 int1: integer;
begin
 with mainmenu1.menu.itembyname('view') do begin
  for int1:= itembyname('formmenuitemstart').index+1 to count - 1 do begin
   with items[int1] do begin
    with pmoduleinfoty(tagpo)^ do begin
     if modified then begin
      caption:= '*'+msefileutils.filename(filename);
     end
     else begin
      caption:= msefileutils.filename(filename);
     end;
     if (designform is tformdesignerfo) and designform.visible then begin
      tformdesignerfo(designform).updatecaption;
     end;
    end;
   end;
  end;
 end;
end;

procedure Tmainfo.ItemsModified(const ADesigner: IDesigner; const AItem: tobject);
begin
 updatemodifiedforms;
 sourcechanged(nil);
end;

procedure tmainfo.componentnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const aitem: tcomponent;
                     const newname: string);
begin
 //dummy
end;

procedure tmainfo.moduleclassnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
begin
 //dummy
end;

procedure tmainfo.instancevarnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
begin
end;

procedure Tmainfo.SelectionChanged(const ADesigner: IDesigner;
  const ASelection: IDesignerSelections);
begin
 if (aselection.Count > 0) and (factivedesignmodule <> nil) then begin
//  objectinspectorfo.bringtofront;
  objectinspectorfo.show;
  if not objectinspectorfo.active then begin
   objectinspectorfo.window.stackunder(factivedesignmodule^.designform.window);
  end;
 end;
end;

//debugger

procedure tmainfo.expronsetvalue(const sender: tobject;
  var avalue: msestring; var accept: boolean);
var
 expres: string;
begin
 gdb.evaluateexpression(ansistring(avalue),expres);
 exprdisp.value:= msestring(expres);
end;

procedure tmainfo.refreshframe;
var
 pc: qword;
begin
 cpufo.refresh;
 if gdb.getpc(pc) = gdb_ok then begin
  disassfo.refresh(pc);
 end
 else begin
  disassfo.clear;
 end;
 watchfo.refresh;
end;

procedure tmainfo.stackframechanged(const frameno: integer);
begin
 if gdb.cancommand then begin
  gdb.selectstackframe(frameno);
  refreshframe;
 end;
end;

procedure tmainfo.toggleformunit;
var
 po1: pmoduleinfoty;
 page1: tsourcepage;
 str1,str2: filenamety;
begin
 if sourcefo.checkancestor(flastform) then begin
  page1:= sourcefo.activepage;
  if (page1 <> nil) then begin
   str2:= fileext(page1.filepath);
   if str2 = pasfileext then begin
    str1:= replacefileext(page1.filepath,formfileext);
    po1:= designer.modules.findmodule(str1);
    if po1 <> nil then begin
     createmodulemenuitem(po1);
     po1^.designform.activate(true);
     page1:= nil;
    end
    else begin
     page1:= sourcefo.findsourcepage(str1);
     if page1 = nil then begin //mfm not loaded in editor
      po1:= designer.loadformfile(str1,false);      
      if po1 <> nil then begin
       createmodulemenuitem(po1);
       po1^.designform.activate(true);
      end;
     end;
    end;
   end
   else begin
    if str2 = formfileext then begin
     page1:= sourcefo.findsourcepage(
                 replacefileext(page1.filepath,pasfileext));
    end;
   end;
   if page1 <> nil then begin
    page1.activate;
   end;
  end;
 end
 else begin
  po1:= designer.actmodulepo;
  if po1 <> nil then begin
   str1:= replacefileext(po1^.filename,pasfileext);
   if sourcefo.openfile(str1,true) = nil then begin
    raise exception.create(ansistring(c[ord(unableopen)]+str1+'".'));
   end;
  end
  else begin
   if designer.modules.count > 0 then begin
    designer.modules[0]^.designform.activate(true);
   end;
  end;
 end;
end;

procedure tmainfo.setstattext(const atext: msestring; 
                   const akind: messagetextkindty = mtk_info);
begin
 with statdisp do begin
  value:= removelinebreaks(atext);
  case akind of
   mtk_finished: color:= cl_ltgreen;
   mtk_error: color:= cl_ltyellow;
   mtk_signal: color:= cl_ltred;
   else color:= cl_parent;
  end;
  case akind of
   mtk_running: font.color:= cl_red;
   else font.color:= cl_black;
  end;
 end;
end;

procedure tmainfo.cleardebugdisp;
begin
 resetdebugdisp;
 stackfo.clear;
 threadsfo.clear;
 disassfo.clear;
end;

procedure tmainfo.resetdebugdisp;
begin
 setstattext('',mtk_info);
 if sourcefo.gdbpage <> nil then begin
  sourcefo.gdbpage.hidehint;
 end;
 sourcefo.resetactiverow;
 disassfo.resetactiverow;
end;

procedure tmainfo.programfinished;
begin
 sourcefo.resetactiverow;
 watchpointsfo.clear;
 disassfo.clear;
 watchfo.clear;
 stackfo.clear;
 threadsfo.clear;
end;

procedure tmainfo.refreshstopinfo(const astopinfo: stopinfoty);
begin
 fstopinfo:= astopinfo;
 with astopinfo do begin
  case reason of
   sr_signal_received: begin
    setstattext(msestring(messagetext),mtk_signal);
   end;
   sr_error: begin
    setstattext(msestring(messagetext),mtk_error);
   end; 
   sr_exception: begin
   end; 
   else begin
    setstattext(msestring(messagetext),mtk_finished);
   end;
  end;
  watchfo.refresh;
  breakpointsfo.refresh;
  stackfo.refresh;
  threadsfo.refresh;
  threadsfo.stopinfo:= astopinfo;
  cpufo.refresh;
  disassfo.refresh(addr);
  if (reason = sr_exception) then begin
   setstattext(msestring(messagetext)+' '+stackfo.infotext(1),mtk_signal);
   if not stackfo.showsource(1) then begin
    sourcefo.locate(stopinfo);
   end;
  end
  else begin
   sourcefo.locate(stopinfo);
  end;
  if reason in [sr_exited,sr_exited_normally,sr_detached] then begin
   programfinished;
  end;
  if projectoptions.d.activateonbreak then begin
   application.activate();
  {
   if application.activewindow <> nil then begin
    application.activewindow.activate;
   end
   else begin
    if flastform <> nil then begin
     flastform.activate();
    end
    else begin
     sourcefo.activate();
    end;
   end;
  }
  end;
  if projectoptions.d.raiseonbreak then begin
   application.packwindowzorder();
  end;
 end;
end;

procedure tmainfo.gdbonevent(const sender: tgdbmi;
             var eventkind: gdbeventkindty; const values: resultinfoarty;
                   const stopinfo: stopinfoty);
begin
 cpufo.stoptime.value:= gdb.stoptime;
 case eventkind of
  gek_stopped: begin
   with stopinfo do begin
    if (reason = sr_startup) and
                      (fstartcommand = sc_continue) then begin
     gdb.continue;
    end
    else begin
     if breakpointsfo.checkbreakpointcontinue(stopinfo) then begin
      gdb.continue;
     end
     else begin
      if reason = sr_detached then begin
       cleardebugdisp;
       setstattext(msestring(stopinfo.messagetext),mtk_finished);
       programfinished;
      end
      else begin
       gdb.debugbegin;
       refreshstopinfo(stopinfo);
      end;
     end;
    end;
   end;
   fstartcommand:= sc_none;
  end;
  gek_running: begin
   resetdebugdisp;
   setstattext(c[ord(running)],mtk_running);   
  end;
  gek_error,gek_writeerror,gek_gdbdied: begin
   setstattext('GDB: '+msestring(stopinfo.messagetext),mtk_error);
  end;
  gek_targetoutput: begin
   targetconsolefo.addtext(values[0].value);
  end;
  gek_download: begin
   with stopinfo do begin
    if sectionsize > 0 then begin
     setstattext(c[ord(str_downloading)]+' '+msestring(section)+' '+
         inttostrmse(round(sectionsent/sectionsize*100))+'%',mtk_running);
    end;
   end;
  end;
  gek_done: begin
   if sender.downloaded then begin
    downloaded;
    setstattext(c[ord(str_downloaded)]+' '+formatfloatmse(
                        stopinfo.totalsent/1024,'0.00,')+'kB',mtk_finished);      
//    sender.abort;
   end;
  end;
  gek_loaded: begin
   symbolfo.updatesymbols;
  end;
 end;
end;

procedure tmainfo.gdbserverexe(const sender: tguiapplication; 
                                                    var again: boolean);
begin
 sys_schedyield;
 if timeout(fgdbservertimeout) and 
 ((getprocessexitcode(fgdbserverprocid,fgdbserverexitcode,100000) = pee_ok) or
      projectoptions.d.nogdbserverexit) then begin
  sender.terminatewait;
 end
 else begin
  sender.idlesleep(100000);
  again:= true;
 end;
end;

function tmainfo.terminategdbserver(const force: boolean): boolean;
var
 int1: integer;
begin
 result:= false;
 if (fgdbserverprocid <> invalidprochandle) and 
        (not projectoptions.d.gdbserverstartonce or force) then begin
  result:= true;
  try
   if (getprocessexitcode(fgdbserverprocid,int1) <> pee_ok) then begin
    killprocesstree(fgdbserverprocid);
   end;
  except
  end;
  fgdbserverprocid:= invalidprochandle;
 end;
end;

procedure tmainfo.gdbservercancel(const sender: tobject);
begin
 terminategdbserver(true);
end;

procedure tmainfo.targetpipeinput(const sender: tpipereader);
begin
 messagefo.messages[0].readpipe(sender);
end;

function tmainfo.startgdbconnection(const attach: boolean): boolean;
var
 mstr1: msestring;
begin
 result:= false;
 with projectoptions,d.texp do begin
  if attach then begin
   mstr1:= gdbservercommandattach;
  end
  else begin
   mstr1:= gdbservercommand;
  end;
  if mstr1 <> '' then begin
   if terminategdbserver(false) then begin
//    sleep(1000);
   end;
   if d.gdbserverstartonce and gdb.tryconnect then begin
    result:= true;
    exit;
   end;
   if d.gdbservertty then begin
    fgdbserverprocid:= execmse2(syscommandline(mstr1),nil,
                  targetpipe.pipereader,targetpipe.pipereader,-1,[exo_tty]);
   end
   else begin
    fgdbserverprocid:= execmse2(syscommandline(mstr1),nil,
                  nil,nil,-1,[]);
   end;
   if fgdbserverprocid <> invalidprochandle then begin
    fgdbservertimeout:= timestep(round(1000000*d.gdbserverwait));
    if application.waitdialog(nil,c[ord(startgdbservercommand)]+
                           mstr1+c[ord(running2)],c[ord(startgdbserver)],
              {$ifdef FPC}@{$endif}gdbservercancel,nil,
              {$ifdef FPC}@{$endif}gdbserverexe) then begin
     if (fgdbserverexitcode <> 0) and 
                     not (projectoptions.d.nogdbserverexit and 
                               (fgdbserverexitcode = -1)) then begin
      setstattext(c[ord(gdbserverstarterror)]+' '+
                            inttostrmse(fgdbserverexitcode)+'.',mtk_error);
      exit;
     end;
    end
    else begin
     setstattext(c[ord(gdbservercanceled)],mtk_error);
     exit;
    end;                
   end
   else begin
    setstattext(c[ord(cannotrunstartgdb)],mtk_error);
    exit;
   end;
  end;
 end;
 result:= true;
end;

function tmainfo.checkgdberror(aresult: gdbresultty): boolean;
begin
 result:= aresult = gdb_ok;
 if not result then begin
  setstattext(msestring('GDB: ' + gdb.geterrormessage(aresult)),mtk_error);
 end;
end;

procedure tmainfo.checkbluedots;
begin
 if (sourcefo <> nil) and (sourcefo.activepage <> nil) then begin
  if (gdb.execloaded or gdb.attached) and actionsmo.bluedotsonact.checked then begin
   sourcefo.activepage.updatedebuglines;
  end
  else begin
   sourcefo.activepage.cleardebuglines;
  end;
 end;
end;

procedure tmainfo.updatesigsettings;
var
 int1,int2: integer;
 str1: string;
 bo1: boolean;
begin
 if gdb.active then begin
  bo1:= gdb.running;
  if bo1 then begin
   gdb.interrupttarget;
  end;
  gdb.ignoreexceptionclasses:= projectoptions.ignoreexceptionclasses;
  gdb.stoponexception:= projectoptions.d.stoponexception;
  str1:= '';
  {$ifndef mswindows}
  for int1:= sigrtmin to sigrtmax do begin
   str1:= str1 + 'SIG' + inttostr(int1) + ' ';
  end;
  {$endif}
  if (gdb.handle(str1,[]) = gdb_ok) then begin
   for int1:= 0 to high(projectoptions.sigsettings) do begin
    with projectoptions.sigsettings[int1] do begin
     if num > 0 then begin
      for int2:= num to numto do begin
       gdb.handle(getsigname(int2),flags);
      end;
     end;
    end;
   end;
  end;
  if bo1 then begin
   gdb.restarttarget;
  end;
 end;
 gdb.newconsole:= projectoptions.d.externalconsole;
 {$ifdef mswindows}
// gdb.newconsole:= projectoptions.d.externalconsole;
 {$else}
 gdb.settty:= projectoptions.d.settty;
 gdb.xtermcommand:= projectoptions.d.texp.xtermcommand;
 {$endif}
end;

procedure tmainfo.uploadexe(const sender: tguiapplication; var again: boolean);
begin
 if not downloading then begin
  sender.terminatewait;
 end
 else begin
  sender.idlesleep(100000);
  again:= true;
 end; 
end;

procedure tmainfo.uploadcancel(const sender: tobject);
begin
 abortdownload;
// killprocess(fuploadprocid);
end;

function tmainfo.needsdownload: boolean;
begin
 result:= ftargetfilemodified or projectoptions.d.downloadalways;
end;

function tmainfo.candebug: boolean; //run command empty or process attached
begin
 result:= (projectoptions.d.texp.runcommand = '') or gdb.started;
end;

procedure tmainfo.downloaded;
begin
 ftargetfilemodified:= false;
 if fgdbdownloaded then begin
  fgdbdownloaded:= false;
  if projectoptions.d.restartgdbbeforeload then begin
   mainfo.startgdb(false);
  end;
 end;
end;

procedure tmainfo.updatetargetenvironment;
       //todo: implement for run without gdb
var
 int1: integer;
begin
 with projectoptions,d.texp do begin
  gdb.progparameters:= ansistring(progparameters);
  gdb.workingdirectory:= progworkingdirectory;
  gdb.clearenvvars;
  for int1:= 0 to high(envvarons) do begin
   if (int1 > high(envvarnames)) or 
                    (int1 > high(envvarnames)) then begin
    break;
   end;
   if envvarons[int1] then begin
    gdb.setenvvar(ansistring(envvarnames[int1]),ansistring(envvarvalues[int1]));
   end
   else begin
    gdb.unsetenvvar(ansistring(envvarnames[int1]));
   end;
  end;
 end;
end;

procedure tmainfo.startconsole();
begin
 targetconsolefo.clear;
 if projectoptions.d.showconsole then begin
  targetconsolefo.activate;
 end;
end;

function tmainfo.loadexec(isattach: boolean; 
                         const forcedownload: boolean): boolean;
var
 str1: filenamety;
begin
 setstattext('');
 result:= false;
 if isattach then begin
  inc(fexecstamp);
  breakpointsfo.updatebreakpoints;
  checkbluedots;
 end
 else begin
  if not gdb.execloaded or forcedownload then begin
   with projectoptions,d.texp do begin
    if d.restartgdbbeforeload or not gdb.active then begin
     startgdb(false);
    end;
    str1:= gettargetfile;
    if not d.gdbdownload and not d.gdbsimulator and (uploadcommand <> '') and 
                   (needsdownload or forcedownload) then begin
     dodownload;
     if application.waitdialog(nil,c[ord(str_uploadcommand)]+uploadcommand+
                                     c[ord(running2)],
         c[ord(str_downloading)],{$ifdef FPC}@{$endif}uploadcancel,nil,
         {$ifdef FPC}@{$endif}uploadexe) then begin
      if downloadresult <> 0 then begin
       setstattext(c[ord(downloaderror)]+' '+
                                inttostrmse(downloadresult)+'.',mtk_error);
       exit;
      end
      else begin
       setstattext(c[ord(downloadfinished)],mtk_finished);
       downloaded;
       if projectoptions.s.closemessages then begin
        messagefo.hide;
       end;
      end;
     end
     else begin
      setstattext(c[ord(downloadcanceled)],mtk_error);
      exit;
     end;                
    end
   end;
   mainfo.setstattext(actionsmo.c[ord(ac_loading)]+'.',mtk_running);
   application.processmessages();
   application.beginwait();
   if checkgdberror(gdb.fileexec(str1,forcedownload)) then begin
    inc(fexecstamp);
    breakpointsfo.updatebreakpoints;
    mainfo.setstattext('',mtk_info);
   end;
   application.endwait();
   checkbluedots;
  end;
 end;
 result:= gdb.execloaded or gdb.attached;
 if result then begin
  updatetargetenvironment;
  watchpointsfo.clear;
  startconsole();
  if forcedownload and projectoptions.d.gdbdownload then begin
   if startgdbconnection(false) then begin
    if checkgdberror(gdb.download(false)) then begin
     fgdbdownloaded:= true;
    end;
   end;
  end;
 end;
end;

procedure tmainfo.unloadexec;
begin
 if gdb.active then begin
  gdb.fileexec('');   //unload exec
 end;
 resetdebugdisp;
 checkbluedots;
end;

procedure tmainfo.startgdb(const killserver: boolean);
begin
 terminategdbserver(killserver);
 with projectoptions,d.texp do begin
  if d.gdbloadtimeout = emptyreal then begin
   gdb.loadtimeoutus:= 0;
  end
  else begin
   gdb.loadtimeoutus:= round(d.gdbloadtimeout*1000000);
  end;
  gdb.remoteconnection:= remoteconnection;
  gdb.gdbdownload:= d.gdbdownload;
  gdb.simulator:= d.gdbsimulator;
  gdb.processorname:= ansistring(gdbprocessor);
  gdb.guiintf:= not d.nodebugbeginend;
  gdb.beforeconnect:= beforeconnect;  
  gdb.afterconnect:= afterconnect;
  gdb.beforeload:= beforeload;  
  gdb.afterload:= afterload;
  gdb.beforerun:= beforerun;
  gdb.startupbkpt:= d.startupbkpt;
  gdb.startupbkpton:= d.startupbkpton;
  gdb.startgdb(quotefilename(debugcommand)+ ' ' + debugoptions);
 end;
 updatesigsettings;
 cleardebugdisp;
 checkbluedots;
end;

procedure tmainfo.restartgdbonexecute(const sender: tobject);
begin
 startgdb(true);
end;

procedure tmainfo.symboltypeonsetvalue(const sender: tobject;
  var avalue: msestring; var accept: boolean);
var
 expres: string;
begin
 gdb.symboltype(ansistring(avalue),expres);
 symboltypedisp.value:= msestring(expres);
end;

procedure tmainfo.viewbreakpointsonexecute(const sender: tobject);
begin
 breakpointsfo.activate;
end;

procedure tmainfo.viewwatchesonexecute(const sender: tobject);
begin
 watchfo.activate;
end;

procedure tmainfo.viewstackonexecute(const sender: tobject);
begin
 stackfo.activate;
end;

procedure tmainfo.onscale(const sender: TObject);
begin
 basedock.bounds_y:= statdisp.bottom + 1;
 basedock.bounds_cy:= container.paintrect.cy - basedock.bounds_y;
end;

procedure tmainfo.parametersonexecute(const sender: TObject);
begin
 editprogramparameters;
end;

procedure tmainfo.viewassembleronexecute(const sender: TObject);
begin
 disassfo.activate;
end;

procedure tmainfo.viewmemoryonexecute(const sender: TObject);
begin
 memoryfo.activate;
end;

procedure tmainfo.viewcpuonexecute(const sender: TObject);
begin
 cpufo.activate;
end;

procedure tmainfo.viewmessagesonexecute(const sender: TObject);
begin
 messagefo.activate;
end;

procedure tmainfo.viewsourceonexecute(const sender: tobject);
begin
 sourcefo.activate;
end;

procedure tmainfo.mainmenuonupdate(const sender: tcustommenu);
var
 bo1: boolean;
begin
 with projectoptions,d.texp,actionsmo do begin
  detachtarget.enabled:= gdb.execloaded or gdb.attached;
  download.enabled:= not gdb.started and not gdb.downloading and 
               ((uploadcommand <> '') or d.gdbdownload);
  attachprocess.enabled:= not (gdb.execloaded or gdb.attached);
  attachtarget.enabled:= attachprocess.enabled;
  run.enabled:= not gdb.running and not gdb.downloading;
  bo1:= candebug;
  step.enabled:= not gdb.running and not gdb.downloading and bo1;
  stepi.enabled:= not gdb.running and not gdb.downloading and bo1;
  next.enabled:= not gdb.running and not gdb.downloading and bo1;
  nexti.enabled:= not gdb.running and not gdb.downloading and bo1;
  finish.enabled:= not gdb.running and gdb.started and bo1;
  continue.enabled:= not gdb.running and not gdb.downloading and 
                      (bo1 or (frunningprocess = invalidprochandle));
  interrupt.enabled:= gdb.running and not gdb.downloading and bo1;
  reset.enabled:= (gdb.started or gdb.attached or gdb.downloading) or
                    not bo1 and (frunningprocess <> invalidprochandle);
  makeact.enabled:= not making;
  buildact.enabled:= not making;
  make1act.enabled:= not making;
  make2act.enabled:= not making;
  make3act.enabled:= not making;
  make4act.enabled:= not making;
  abortmakeact.enabled:= making;
  saveall.enabled:= sourcefo.modified or designer.modified or
                                                  projectoptions.modified;
  actionsmo.toggleformunit.enabled:= (flastform <> nil) or
                                            (designer.modules.count > 0);
  if (sourcefo.activepage <> nil) and 
                                sourcefo.activepage.activeentered then begin
   setbm0.enabled:= true;
   setbm1.enabled:= true;
   setbm2.enabled:= true;
   setbm3.enabled:= true;
   setbm4.enabled:= true;
   setbm5.enabled:= true;
   setbm6.enabled:= true;
   setbm7.enabled:= true;
   setbm8.enabled:= true;
   setbm8.enabled:= true;
   setbm9.enabled:= true;
   setbmnone.enabled:= true;
   findbm0.enabled:= true;
   findbm1.enabled:= true;
   findbm2.enabled:= true;
   findbm3.enabled:= true;
   findbm4.enabled:= true;
   findbm5.enabled:= true;
   findbm6.enabled:= true;
   findbm7.enabled:= true;
   findbm8.enabled:= true;
   findbm9.enabled:= true;
   print.enabled:= true;
   with sourcefo.activepage do begin
    actionsmo.save.enabled:= modified;
    undo.enabled:= edit.canundo;
    redo.enabled:= edit.canredo;
    copy.enabled:= edit.hasselection;
    copylatexact.enabled:= edit.hasselection;
    cut.enabled:= edit.hasselection;
    paste.enabled:= edit.canpaste;
    delete.enabled:= edit.hasselection;
    indent.enabled:= true;
    unindent.enabled:= true;
    line.enabled:= grid.rowcount > 0;
    togglebkpt.enabled:= line.enabled;
    togglebkptenable.enabled:= togglebkpt.enabled;
//    find.enabled:= true;
    replace.enabled:= true;
    copyword.enabled:= true;
//    actionsmo.repeatfind.enabled:= find.enabled and 
//           (projectoptions.findreplaceinfo.find.text <> '');
   end;
  end
  else begin
   setbm0.enabled:= false;
   setbm1.enabled:= false;
   setbm2.enabled:= false;
   setbm3.enabled:= false;
   setbm4.enabled:= false;
   setbm5.enabled:= false;
   setbm6.enabled:= false;
   setbm7.enabled:= false;
   setbm8.enabled:= false;
   setbm8.enabled:= false;
   setbm9.enabled:= false;
   setbmnone.enabled:= false;
   findbm0.enabled:= false;
   findbm1.enabled:= false;
   findbm2.enabled:= false;
   findbm3.enabled:= false;
   findbm4.enabled:= false;
   findbm5.enabled:= false;
   findbm6.enabled:= false;
   findbm7.enabled:= false;
   findbm8.enabled:= false;
   findbm9.enabled:= false;

   print.enabled:= false;
   save.enabled:= false;
   undo.enabled:= false;
   redo.enabled:= false;
   copy.enabled:= false;
   copylatexact.enabled:= false;
   cut.enabled:= false;
   paste.enabled:= false;
   delete.enabled:= false;
   indent.enabled:= false;
   unindent.enabled:= false;
   line.enabled:= false;
   togglebkpt.enabled:= false;
   togglebkptenable.enabled:= false;
//   find.enabled:= false;
//   actionsmo.repeatfind.enabled:= false;
   replace.enabled:= false;
   copyword.enabled:= false;
  end;
  if (factivedesignmodule <> nil) then begin
   save.enabled:= factivedesignmodule^.modified;
   close.enabled:= true;
  end
  else begin
   close.enabled:= sourcefo.count > 0;
  end;
  closeall.enabled:= (sourcefo.count > 0) or (designer.modules.count > 0);
  saveas.enabled:= (factivedesignmodule <> nil) or (sourcefo.activepage <> nil);
  mainmenu1.menu.itembyname('project').itembyname('close').enabled:= 
                                                               fprojectloaded;
 end;
end;

function tmainfo.formmenuitemstart: integer;
begin
 result:= mainmenu1.menu.itembyname('view').itembyname(
               'formmenuitemstart').index + 1;
end;

procedure tmainfo.createmodulemenuitem(const amodule: pmoduleinfoty);
var
 int1: integer;
 item1: tmenuitem;
begin
 with mainmenu1.menu.itembyname('view') do begin
  for int1:= formmenuitemstart to submenu.count-1 do begin
   if submenu[int1].tagpo = amodule then begin
    exit;
   end;
  end;
  amodule^.hasmenuitem:= true;
  item1:= tmenuitem.create;
  with item1 do begin
   if amodule^.modified then begin
    caption:= '*'+msefileutils.filename(amodule^.filename);
   end
   else begin
    caption:= msefileutils.filename(amodule^.filename);
   end;
   onexecute:= {$ifdef FPC}@{$endif}doshowform;
   tagpo:= amodule;
   options:= options + [mao_asyncexecute];
  end;
  for int1:= formmenuitemstart to submenu.count-1 do begin
   if submenu[int1].caption > item1.caption then begin
    submenu.insert(int1,item1);
    exit;
   end;
  end;
  submenu.insert(bigint,item1);
 end;
end;

function tmainfo.openformfile(const filename: filenamety;
       const ashow,aactivate,showsource,createmenu,
                              skipexisting: boolean): pmoduleinfoty;
var
// item1: tmenuitem;
 wstr1,wstr2: filenamety;
// bo1: boolean;
// int1: integer;
begin
 result:= designer.modules.findmodule(filename);
 if result = nil then begin
  wstr2:= msefileutils.filename(filename);
  if findfile(filename) then begin
   wstr1:= filename;
  end
  else begin
   wstr1:= searchfile(wstr2,projectoptions.d.texp.sourcedirs);
   if wstr1 = '' then begin
    wstr1:= filename; //to raise exception
   end
   else begin
    wstr1:= wstr1 + wstr2;
   end;
  end;
  try
   result:= designer.loadformfile(wstr1,skipexisting);
   if result <> nil then begin
    result^.filetag:= sourcefo.newfiletag;
    sourcefo.filechangenotifyer.addnotification(wstr1,result^.filetag);
   end;
  except
   showobjecttext(nil,wstr1,false);
   errorformfilename:= wstr1;
   raise;
  end;
  if result <> nil then begin
   if showsource then begin
    loadsourcebyform(wstr1);
   end;
  end;
 end;
 if result <> nil then begin
  if createmenu then begin
   createmodulemenuitem(result);
  end;
  if ashow then begin
   result^.designform.show;
   if aactivate then begin
    result^.designform.activate;
   end;
  end;
  if result^.modified then begin
   sourcechanged(nil);
  end;
 end;
end;

procedure tmainfo.loadformbysource(const sourcefilename: filenamety);
var
 str1: filenamety;
 activebefore: pmoduleinfoty;
begin
 if fileext(sourcefilename) = pasfileext then begin
  str1:= replacefileext(sourcefilename,formfileext);
  if findfile(str1) then begin
   activebefore:= factivedesignmodule;
   try
    openformfile(str1,true,false,false,true,true);
   finally
    factivedesignmodule:= activebefore;
   end;
  end;
 end;
end;

procedure tmainfo.loadsourcebyform(const formfilename: filenamety;
                                     const aactivate: boolean = false);
begin
 sourcefo.openfile(replacefileext(formfilename,pasfileext),aactivate);
end;

function tmainfo.opensource(const filekind: filekindty;
               const addtoproject: boolean; const aactivate: boolean = true;
                               const currentnode: tprojectnode = nil): boolean;

var
 unitnode: tunitnode;

var
 int1: integer;
 page: tsourcepage;
 str1: filenamety;
 po1: pmoduleinfoty;
 
begin //opensourceactonexecute
 result:= openfile.execute = mr_ok;
 if result then begin
  page:= nil;
  po1:= nil;
  unitnode:= nil; //compilerwarning
  designer.beginskipall;
  try
   with openfile.controller do begin
    for int1:= 0 to high(filenames) do begin
     if checkfileext(filenames[int1],[formfileext]) then begin
      page:= sourcefo.findsourcepage(filenames[int1]);
      if page = nil then begin
       po1:= openformfile(filenames[int1],true,false,false,true,false);
      end;
     end
     else begin
      page:= sourcefo.openfile(filenames[int1]);
      if addtoproject then begin
       unitnode:= projecttree.units.addfile(currentnode,filenames[int1]);
      end;
      str1:= designer.sourcenametoformname(filenames[int1]);
      if findfile(str1) then begin
       po1:= openformfile(str1,true,false,false,true,false);
       if addtoproject then begin
        unitnode.setformfile(str1);
       end;
      end;
     end;
    end;
   end;
  finally
   designer.endskipall;
  end;
  if aactivate then begin
   if page <> nil then begin
    page.activate(true,true);
   end
   else begin
    if po1 <> nil then begin
     po1^.designform.activate(true,true);
    end;
   end;
  end;
 end;
end;

procedure tmainfo.designformactivated(const sender: tcustommseform);
begin
 setlinkedvar(sender,tmsecomponent(flastform));
 if sourcefo = flastform then begin
  factivedesignmodule:= nil;
  setlinkedvar(sender,tmsecomponent(flastdesignform));
 end
 else begin
  if (designer.actmodulepo <> nil) and
                (designer.actmodulepo^.designform = flastform) then begin
   factivedesignmodule:= designer.actmodulepo;
   setlinkedvar(sender,tmsecomponent(flastdesignform));
  end;
 end;
end;

procedure tmainfo.viewcomponentpaletteonexecute(const sender: TObject);
begin
 componentpalettefo.show;
 componentpalettefo.window.bringtofront;
end;

procedure tmainfo.viewcomponentstoreonexecute(const sender: TObject);
begin
 componentstorefo.activate;
end;

procedure tmainfo.viewdebuggertoolbaronexecute(const sender: TObject);
begin
 debuggerfo.show;
 debuggerfo.window.bringtofront;
end;

procedure tmainfo.mainonloaded(const sender: tobject);
var
 wstr1: msestring;
label
 endlab;
begin
 try
  if guitemplatesmo.sysenv.defined[ord(env_globstatfile)] then begin
   wstr1:= guitemplatesmo.sysenv.value[ord(env_globstatfile)];
   if wstr1 <> '' then begin
    mainstatfile.filename:= wstr1;
    goto endlab;
   end;
  end;
  wstr1:= filepath(statdirname);
  if not finddir(wstr1) then begin
   createdir(wstr1);
  end;
  {$ifdef mswindows}
  mainstatfile.filename:= statname+'wi.sta';
  {$endif}
  {$ifdef linux}
  mainstatfile.filename:= statname+'li.sta';
  {$endif}
  {$ifdef openbsd}
  mainstatfile.filename:= statname+'obsd.sta';
  {$endif}
  {$ifdef bsd}
  mainstatfile.filename:= statname+'bsd.sta';
  {$endif}
endlab:
  mainstatfile.readstat;
  expandprojectmacros;
  onscale(nil);
 finally
  if not application.terminated then begin
   mainfo.activate;
  end;
 end;
 {$ifdef mse_dumpunitgroups}
 dumpunitgr;
 {$endif}
end;

function getmodulename(const aname,suffix,formsuffix: msestring): msestring;
var
 int1: integer;
begin
 int1:= length(aname) - length(suffix);
 if (int1 >= 0) and 
            (msestringcomp(copy(aname,int1+1,bigint),suffix) = 0) then begin
  result:= copy(aname,1,int1) + formsuffix;
 end
 else begin
  result:= aname + formsuffix;
 end;
end;

procedure tmainfo.createform(const aname: filenamety; const namebase: string;
                            const formsuffix: string; const ancestor: string);
var
 stream1: ttextstream;
 str1,str2,str3: msestring;
 po1: pmoduleinfoty;
begin
  str3:= removefileext(filename(aname));
  str2:= msestring(getmodulename(str3,msestring(namebase),
                                             msestring(formsuffix)));
  stream1:= ttextstream.create(aname,fm_create);
  try
   formskeleton(stream1,ansistring(filename(str3)),ansistring(str2),ancestor);
  finally
   stream1.Free;
  end;
  sourcefo.showsourceline(aname,0,0,true);
  str1:= replacefileext(aname,formfileext);
  closemodule(designer.modules.findmodule(str1),false);
  stream1:= ttextstream.create(str1,fm_create);
  try
   with stream1 do begin
    writeln('object '+str2+': t'+str2);
    writeln('  moduleclassname = '''+ancestor+'''');
    writeln('end');
   end;
  finally
   stream1.Free;
  end;
  po1:= openformfile(str1,true,false,true,true,false);
{
  if kind = fok_main then begin
   with tmseform(po1^.instance) do begin
    options:= options + [fo_main,fo_terminateonclose];
    optionswindow:= optionswindow + [wo_groupleader];
   end;
  end;
}
  po1^.modified:= true; //initial create of ..._mfm.pas
end;

procedure tmainfo.createprogramfile(const aname: filenamety);
var
 stream1: ttextstream;
begin
 stream1:= ttextstream.create(aname,fm_create);
 try
  programskeleton(stream1,ansistring(removefileext(filename(aname))));
 finally
  stream1.Free;
 end;
 sourcefo.showsourceline(aname,0,0,true);
end;

function tmainfo.copynewfile(const aname,newname: filenamety;
                const autoincrement: boolean; 
                const canoverwrite: boolean;
                const macronames: array of msestring; 
                const macrovalues: array of msestring): boolean;
                 //true if ok
var
 int1: integer;
 dir,base,ext: filenamety;
 path1,path2: filenamety;
 macrolist: tmacrolist;
 instream,outstream: ttextstream;
 text: msestringarty;
 
begin
 result:= false;
 path1:= searchfile(aname);
 if path1 = '' then begin
  showmessage(c[ord(str_file)]+aname+c[ord(notfound2)],c[ord(warning)]);
 end
 else begin
  path2:= filepath(newname);
  if not canoverwrite and findfile(path2) then begin
   if not autoincrement then begin
    showerror(c[ord(str_file)]+newname+c[ord(exists)]);
    exit;
   end
   else begin
    splitfilepath(filepath(aname),dir,base,ext);
    base:= base + dir;
    int1:= 1;
    repeat
     path2:= base+inttostrmse(int1)+ext;
     inc(int1);
    until not findfile(path2);
   end;
  end;
  splitfilepath(path2,dir,base,ext);
  macrolist:= tmacrolist.create([mao_curlybraceonly]);
  try
   macrolist.add(['%FILEPATH%','%FILENAME%','%FILENAMEBASE%'],
                                                   [path2,base+ext,base],[]);
   macrolist.add(macronames,macrovalues,[]);
   instream:= ttextstream.create(path1);
   try
    text:= instream.readmsestrings;
    macrolist.expandmacros1(text);
    outstream:= ttextstream.create(path2,fm_create);
    try
     outstream.writemsestrings(text);
    finally
     outstream.free;
    end;
   finally
    instream.free;
   end;
  finally
   macrolist.free;
  end;
  result:= true;
 end;
end;

procedure tmainfo.newfileonexecute(const sender: TObject);
var
 str1: filenamety;
 int1: integer;
begin
 str1:= '';
 int1:= tmenuitem(sender).tag;
 with projectoptions.p.texp do begin
  if newfisources[int1] = '' then begin
   sourcefo.newpage;
  end
  else begin
   if filedialog(str1,[fdo_save,fdo_checkexist],c[ord(str_new)]+' '+
          newfinames[int1],[newfinames[int1]],
          [newfifilters[int1]],newfiexts[int1]) = mr_ok then begin
    copynewfile(newfisources[int1],str1,false,true,
             ['%PROGRAMNAME%','%UNITNAME%'],['${%FILENAMEBASE%}',
             '${%FILENAMEBASE%}']);
    sourcefo.openfile(str1,true);
   end;
  end;
 end;
end;

procedure tmainfo.newformonexecute(const sender: TObject);
var
 str1,str2,str3,str4,str5,str6: filenamety;
 dir,base,ext: filenamety;
 po1: pmoduleinfoty;
 ancestorclass,ancestorunit: msestring;
 
begin
// if formkindty(tmenuitem(sender).tag) = fok_inherited then begin
 if projectoptions.p.newinheritedforms[tmenuitem(sender).tag] then begin
  po1:= selectinheritedmodule(nil,c[ord(selectancestor)]);
  if po1 = nil then begin
   exit;
  end;
  ancestorclass:= msestring(po1^.moduleclassname);
  ancestorunit:= filenamebase(po1^.filename);
 end
 else begin
  ancestorclass:= '';
  ancestorunit:= '';
  po1:= nil;
 end;
 str1:= '';
 if filedialog(str1,[fdo_save,fdo_checkexist],c[ord(newform)],
                                             [c[ord(pascalfiles)]],
                              ['"*.pas" "*.pp" "*.mla"'],'pas') = mr_ok then begin
  with projectoptions.p.texp do begin
   str4:= newfonamebases[tmenuitem(sender).tag];
   str6:= newfoformsuffixes[tmenuitem(sender).tag];
   str2:= newfosources[tmenuitem(sender).tag];
   str3:= newfoforms[tmenuitem(sender).tag];
  end;
  if (str2 <> '') or (str3 <> '') then begin
   if str2 <> '' then begin
    str2:= filepath(str2); //sourcesource
   end;
   if str3 <> '' then begin
    str3:= filepath(str3); //formsource
   end;
   splitfilepath(str1,dir,base,ext);
   str4:= getmodulename(base,str4,str6);
   str5:= replacefileext(str1,'mfm');
   if str2 <> '' then begin
    copynewfile(str2,str1,false,true,
             ['%UNITNAME%','%FORMNAME%','%ANCESTORUNIT%','%ANCESTORCLASS%'],
            ['${%FILENAMEBASE%}',str4,ancestorunit,ancestorclass]); //source 
   end;
   if str3 <> '' then begin
    copynewfile(str3,str5,false,true,
            ['%UNITNAME%','%FORMNAME%','%ANCESTORUNIT%','%ANCESTORCLASS%'],
            ['${%FILENAMEBASE%}',str4,ancestorunit,ancestorclass]); //form
   end;
   if str2 <> '' then begin
    sourcefo.openfile(str1,true);
   end;
   if (str3 <> '') then begin
    openformfile(str5,true,false,false,true,false);
    po1:= designer.modules.findmodule(str5);
    if po1 <> nil then begin
     po1^.modified:= true; //initial create of ..._mfm.pas
    end;
   end;
  end
  else begin
//   createform(str1,formkindty(tmenuitem(sender).tag));
   createform(str1,'form','tmseform','fo'); //default
  end;
 end;
end;

procedure tmainfo.removemodulemenuitem(const amodule: pmoduleinfoty);
var
 int1: integer;
begin
 with mainmenu1.menu.itembyname('view') do begin
  for int1:= itembyname('formmenuitemstart').index+1 to count - 1 do begin
   if items[int1].tagpo = amodule then begin
    submenu.delete(int1);
    break;
   end;
  end;
 end;
end;

function tmainfo.closemodule(const amodule: pmoduleinfoty; 
                            const achecksave: boolean; 
                            nocheckclose: boolean = false): boolean;
var
 str1: string;
 mstr1: filenamety;
begin
 if amodule <> nil then begin
  mstr1:= amodule^.filename;
  if nocheckclose or designer.checkcanclose(amodule,str1) then begin
   result:= designer.closemodule(amodule,achecksave);
  end
  else begin
   amodule^.designform.hide;
   result:= true;
   removemodulemenuitem(amodule);
   amodule^.hasmenuitem:= false;
  end;
  if result then begin
   sourcefo.filechangenotifyer.removenotification(mstr1);
   if factivedesignmodule = amodule then begin
    factivedesignmodule:= nil;
   end;
  end;
 end
 else begin
  result:= true;
 end;
end;

function tmainfo.checksavecancel(const aresult: modalresultty): modalresultty;
begin
 if aresult = mr_cancel then begin
  projectoptions.savechecked:= false;
  sourcefo.savecanceled;
  designer.savecanceled;
 end;
 result:= aresult;
end;

function tmainfo.closeall(const nosave: boolean): boolean;
begin
 result:= nosave or (checksavecancel(sourcefo.saveall(false)) <> mr_cancel);
 if result then begin
  result:= nosave or 
         (checksavecancel(designer.saveall(false,true)) <> mr_cancel);
  if result then begin
   sourcefo.closeall(true);
   while designer.modules.count > 0 do begin
    closemodule(designer.modules.itempo[designer.modules.count-1],not nosave,true);
   end;
  end;
 end;
end;

procedure tmainfo.buildactonexecute(const sender: TObject);
begin
 domake(2);
end;

procedure tmainfo.showfirsterror;
var
 int1: integer;
 apage: tsourcepage;
begin
 with messagefo do begin
  for int1:= 0 to messages.rowcount - 1 do begin
   if locateerrormessage(messages[0][int1],apage,el_error) then begin
    messages.focuscell(makegridcoord(0,int1));
    setstattext(messages[0][int1],mtk_error);
    break;
   end;
  end;
 end;
end;
{
procedure tmainfo.mainfoonclosequery(const sender: tcustommseform; 
            var modalresult: modalresultty);
begin
 if checksave = mr_cancel then begin
  modalresult:= mr_none;
 end
 else begin
  sourcefo.filechangenotifyer.clear;
  mainstatfile.writestat;
 end;
end;
}
procedure tmainfo.mainfoonterminate(var terminate: Boolean);
//var
// modres: modalresultty;
begin
 if checksave = mr_cancel then begin
  terminate:= false;
 end
 else begin
  sourcefo.filechangenotifyer.clear;
  mainstatfile.writestat;
 end;
 {
  modres:= mr_windowclosed;
  mainfoonclosequery(nil,modres);
  if modres <> mr_windowclosed then begin
   terminate:= false;
  end;
 end;
 }
end;

procedure tmainfo.setprojectname(aname: filenamety);
begin
 fprojectname:= aname;
 if aname = '' then begin
  caption:= idecaption+' (<'+c[ord(new2)]+'>)';
 end
 else begin
  caption:= idecaption+' ('+filename(aname)+')';
  setcurrentdirmse(filedir(aname));
  openfile.controller.filename:= '';
 end;
 dragdock.layoutchanged; //refresh possible dockpanel caption
end;

function tmainfo.openproject(const aname: filenamety;
                               const ascopy: boolean = false): boolean;

 procedure closepro;
 begin
  gdb.abort;
  sourceupdater.clear;
  initprojectoptions;
  projectoptions.projectfilename:= '';
  setprojectname('');
  projecttreefo.clear;
  watchfo.clear(true);
  breakpointsfo.clear;
  watchpointsfo.clear(true);
  cleardebugdisp;
  designer.savecanceled(); //reset saveall flag
 end;
 
var
 namebefore: msestring;
 projectfilebefore: msestring;
 projectdirbefore: msestring;
 
begin
 gdb.abort;
 terminategdbserver(true);
 result:= false;
 projectfilebefore:= projectoptions.projectfilename;
 projectdirbefore:= projectoptions.projectdir;
 namebefore:= fprojectname;
 if (checksave <> mr_cancel) and closeall(true) then begin
  closepro;
  if aname <> '' then begin
   try
    setcurrentdirmse(removelastpathsection(aname));
   except
    application.handleexception(nil,c[ord(cannotloadproj)]+aname+'": ');
    exit;
   end;
   if not readprojectoptions(aname) then begin
    closepro;
   end
   else begin
    fcurrent:= false;
    gdb.closegdb;
    cleardebugdisp;
    if not ascopy then begin
     setprojectname(aname);
    end
    else begin
     projectoptions.projectfilename:= projectfilebefore;
     projectoptions.projectdir:= projectdirbefore;
     expandprojectmacros;
     setprojectname(namebefore);
    end;
   end;
  end;
  result:= true;
  fprojectloaded:= true;
 end;
end;

procedure tmainfo.saveproject(aname: filenamety;
                                   const ascopy: boolean = false);
begin
 if aname <> '' then begin
  try
   saveprojectoptions(aname);
   if not ascopy then begin
    setprojectname(aname);
    expandprojectmacros;
   end;
  except
   application.handleexception(nil);
  end;
 end;
end;

procedure tmainfo.newproject(const fromprogram,empty: boolean);
var
 aname: filenamety;
 mstr1,mstr2: msestring;
 i1: integer;
 curdir,source,dest: filenamety;
 macrolist: tmacrolist;
 copiedfiles: filenamearty;
 bo1: boolean;
label
 endlab;  
begin
 mstr2:= projecttemplatedir; //use macros of current project
 if fromprogram then begin
  if (checksave() = mr_cancel) or not closeall(false) then begin
   exit;
  end;
  setprojectname('');
 end;
 if fromprogram or openproject('') then begin
  gdb.closegdb;
  cleardebugdisp;
  sourcechanged(nil);
  mstr1:= '';
  if not fromprogram then begin
   if not empty then begin
    aname:= mstr2 + 'default.prj';
    if filedialog(aname,[fdo_checkexist],c[ord(selecttemplate)],
             [c[ord(projectfiles)],c[ord(str_allfiles)]],
                            ['*.prj','*'],'prj') = mr_ok then begin
     readprojectoptions(aname);
    end;
   end;
   aname:= '';
  end
  else begin
   aname:= '';
   if filedialog(aname,[fdo_checkexist],c[ord(selectprogramfile)],
            [c[ord(pascalprogfiles)],c[ord(cfiles)],c[ord(str_allfiles)]],
            ['"*.pas" "*.pp" "*.mla" "*.dpr" "*.lpr"','"*.c" "*.cc" "*.cpp"','*'],
            'pas') = mr_ok then begin
    setcurrentdirmse(filedir(aname));
    with projectoptions do begin
     with k.t do begin
      mainfile:= filename(aname);
      aname:= removefileext(mainfile);
      targetfile:= aname+'${EXEEXT}'
     end;
     expandprojectmacros;
    end;
    aname:= aname + '.prj';
   end
   else begin
    goto endlab;
   end;
  end;
  if filedialog(aname,[fdo_save,fdo_checkexist],c[ord(str_newproject)],
              [c[ord(projectfiles)],c[ord(str_allfiles)]],
                                     ['*.prj','*'],'prj') = mr_ok then begin
   curdir:= filedir(aname);
   setcurrentdirmse(curdir);
   insertitem(projecthistory,0,aname);
   i1:= 1;
   while i1 <= high(projecthistory) do begin
    if projecthistory[i1] = aname then begin
     deleteitem(projecthistory,i1);
    end;
    inc(i1);
   end;
   if high(projecthistory) >= 
             projectfiledia.controller.historymaxcount then begin
    setlength(projecthistory,projectfiledia.controller.historymaxcount);
   end;
   if not fromprogram then begin
    mstr1:= removefileext(filename(aname));
    with projectoptions,s do begin
     projectfilename:= aname;
     projectdir:= curdir;
     expandprojectmacros;
     with p.texp do begin  
      setlength(copiedfiles,length(newprojectfiles));
      macrolist:= tmacrolist.create([mao_curlybraceonly]);
      try
       macrolist.add(['%PROJECTNAME%','%PROJECTDIR%'],[mstr1,curdir],[]);
       if runscript(scriptbeforecopy,true,false) then begin
        for i1:= 0 to high(newprojectfiles) do begin
         source:= filepath(newprojectfiles[i1]);
         if i1 <= high(newprojectfilesdest) then begin
          dest:= newprojectfilesdest[i1];
         end
         else begin
          dest:= '';
         end;
         if dest <> '' then begin
          macrolist.expandmacros1(dest);
          if source = '' then begin
           createdirpath(dest);
          end
          else begin
           createdirpath(filedir(dest));
          end;
         end
         else begin
          dest:= filename(source);
         end;
         copiedfiles[i1]:= dest;
         if newprojectfiles[i1] <> '' then begin
          if (i1 <= high(p.expandprojectfilemacros)) and 
                             p.expandprojectfilemacros[i1] then begin
           copynewfile(source,dest,false,false,['%PROJECTNAME%','%PROJECTDIR%'],
                                       [mstr1,curdir]);
          end
          else begin
           try
            if not copyfile(source,dest,false) then begin
             showerror(c[ord(str_file)]+dest+c[ord(exists)]);
            end;
           except
            application.handleexception(nil);
           end;
          end;
         end;
        end;
        runscript(scriptaftercopy,false,false);
       end;
      finally
       macrolist.free;
      end;
     end;
     saveproject(aname);
     bo1:= true;
     for i1:= 0 to high(copiedfiles) do begin
      if i1 > high(p.loadprojectfile) then begin
       break;
      end;
      if p.loadprojectfile[i1] then begin
       if checkfileext(copiedfiles[i1],[formfileext])then begin
        openformfile(copiedfiles[i1],true,false,false,true,false);
       end
       else begin
        sourcefo.openfile(copiedfiles[i1],bo1);
        bo1:= false;
       end;
      end;
     end;
    end;
   end
   else begin
    saveproject(aname);
    sourcefo.openfile(projectoptions.k.texp.mainfile,true);
   end;
  end
  else begin
endlab:
   projectoptions.projectfilename:= '';
   projectoptions.modified:= true;
  end;
 end;
end;

procedure tmainfo.newprojectonexecute(const sender: tobject);
begin
 newproject(false,false);
end;

procedure tmainfo.newprojectfromprogramexe(const sender: TObject);
begin
 newproject(true,false);
end;

procedure tmainfo.newemptyprojectexe(const sender: TObject);
begin
 newproject(false,true);
end;

procedure tmainfo.openprojectcopyexecute(const sender: TObject);
var
 str1: filenamety;
begin
 if projectfiledialog(str1,false) = mr_ok then begin
  openproject(str1,true);
 end;
end;

procedure tmainfo.saveprojectasonexecute(const sender: tobject);
var
 str1: filenamety;
begin
 if projectfiledialog(str1,true) = mr_ok then begin
  saveproject(str1);
 end;
end;

procedure tmainfo.saveprojectcopyexecute(const sender: TObject);
var
 str1: filenamety;
begin
 if projectfiledialog(str1,true) = mr_ok then begin
  saveproject(str1,true);
 end;
end;

procedure tmainfo.mainstatfileonupdatestat(const sender: tobject;
                   const filer: tstatfiler);
var
 mstr1: filenamety;
 mstr2: msestring;
 ar1: msestringarty;
 int1,i2: integer;
 ar2: macroinfoarty;
 ma1: settingsmacroty;
 bo1: boolean;
begin
 ar1:= nil; //compiler warning
 updatesettings(filer);

 mstr1:= projectoptions.projectfilename;
 filer.updatevalue('projectname',mstr1);
 filer.updatevalue('projecthistory',projecthistory);
 filer.updatevalue('windowlayoutfile',windowlayoutfile);
 filer.updatevalue('windowlayouthistory',windowlayouthistory);
 
 if not filer.iswriter then begin
  if guitemplatesmo.sysenv.defined[ord(env_storeglobalmacros)] then begin
   ar2:= guitemplatesmo.sysenv.getcommandlinemacros(ord(env_macrodef));
   with settings.macros do begin
    for int1:= 0 to high(ar2) do begin
     mstr2:= ar2[int1].name;
     bo1:= false;
     for ma1:= low(settingsmacroty) to high(settingsmacroty) do begin
      if msecomparetext(mstr2,settingsmacronames[ma1]) = 0 then begin
       macros[ma1]:= ar2[int1].value;
       bo1:= true;
       break;
      end;
     end;
     if not bo1 then begin
      bo1:= false;
      for i2:= 0 to high(globmacronames) do begin
       if msecomparetext(mstr2,globmacronames[i2]) = 0 then begin
        bo1:= true;
        if high(globmacrovalues) < i2 then begin
         setlength(globmacrovalues,i2+1);
        end;
        globmacronames[i2]:= ar2[int1].name;
        globmacrovalues[i2]:= ar2[int1].value;
       end;
      end;
      if not bo1 then begin
       additem(globmacronames,ar2[int1].name);
       if high(globmacrovalues) < high(globmacronames) then begin
        setlength(globmacrovalues,high(globmacronames)+1);
       end;
       globmacrovalues[high(globmacronames)]:= ar2[int1].value;
      end;
     end;
    end;
   end;
   application.terminated:= true;
   projectoptions.projectfilename:= mstr1;
   mainstatfile.writestat();
   exit();
  end;
  if guitemplatesmo.sysenv.defined[ord(env_filename)] then begin
   ar1:= guitemplatesmo.sysenv.values[ord(env_filename)];
   if (high(ar1) = 0) and (fileext(ar1[0]) = 'prj') then begin
    mstr1:= filepath(ar1[0]);
   end
   else begin
    if high(ar1) >= 0 then begin
     for int1:= 0 to high(ar1) do begin
      sourcefo.openfile(ar1[int1],int1 = 0);
     end;
    end;
    exit;
   end;
  end;
 end;
 if not filer.iswriter and (mstr1 <> '') and 
           not guitemplatesmo.sysenv.defined[ord(env_np)] then begin
  openproject(mstr1);
 end;
end;

procedure tmainfo.targetfilemodified;
begin
 ftargetfilemodified:= true;
end;

procedure tmainfo.domake(atag: integer);
begin
 unloadexec;
 if designer.beforemake and 
         (checksavecancel(sourcefo.saveall(true)) <> mr_cancel) and
         (checksavecancel(designer.saveall(true,true)) <> mr_cancel) then begin
  updatemodifiedforms;
  ftargetfilemodified:= false;
  make.domake(atag);
 end;
end;

procedure tmainfo.dorun;
var
 mstr1: msestring;
 pwdbefore: msestring;
begin
 if projectoptions.d.texp.runcommand = '' then begin
  if not projectoptions.d.gdbsimulator then begin
   if startgdbconnection(false) then begin
    gdb.gdbdownload:= projectoptions.d.gdbdownload and needsdownload;
    checkgdberror(gdb.run);
   end;
  end
  else begin
   checkgdberror(gdb.run);
  end;
 end
 else begin
  with projectoptions,d.texp do begin
   mstr1:= runcommand;
   if progparameters <> '' then begin
    mstr1:= mstr1 + ' ' + progparameters;
   end;
   if progworkingdirectory <> '' then begin
    pwdbefore:= setcurrentdirmse(progworkingdirectory);
   end;
   try
    if projectoptions.d.externalconsole then begin
     frunningprocess:= execmse4(mstr1,[exo_newconsole]);
    end
    else begin
     startconsole();
     frunningprocess:= targetconsolefo.terminal.execprog(mstr1);
    end;
    if frunningprocess = invalidprochandle then begin
     setstattext(c[ord(cannotstartprocess)],mtk_error);
     exit;
    end;
    runprocmon.listentoprocess(frunningprocess);
   finally
    if progworkingdirectory <> '' then begin
     setcurrentdirmse(pwdbefore);
    end;
   end;
  end;
  setstattext('*** '+c[ord(process)]+' '+inttostrmse(frunningprocess)+' '+
                     c[ord(running3)]+' ***',mtk_running);
 end;
end;

procedure tmainfo.runprocdied(const sender: TObject;
                          const prochandle: prochandlety;
               const execresult: Integer; const data: Pointer);
begin
 if prochandle = frunningprocess then begin
  frunningprocess:= invalidprochandle;
  if execresult <> 0 then begin
   setstattext(c[ord(processterminated)]+' '+inttostrmse(execresult){+'.'},
                                    mtk_finished);
  end
  else begin
   setstattext(c[ord(proctermnormally)],mtk_finished);
  end;
 end;
end;

function tmainfo.runtarget: boolean;
                   //true if run possible
begin
 result:= true;
 if not gdb.attached then begin
  if (projectoptions.d.texp.runcommand = '') and 
         (projectoptions.d.t.debugcommand <> '') then begin
   if not gdb.started then begin
    if loadexec(false,false) then begin
     result:= false;
     dorun;
    end;
   end;
  end
  else begin
   result:= false;
   if (projectoptions.d.texp.runcommand <> '') then begin
    dorun;
   end;
  end;
 end;
end;

function tmainfo.checkremake(startcommand: startcommandty): boolean;
                         //true if running possible
begin
 if not objectinspectorfo.canclose(nil) then begin
  result:= false;
  exit;
 end;
 result:= true;
 fstartcommand:= startcommand;
 if not gdb.active then begin
  startgdb(false);
 end;
 if not gdb.attached then begin
  if (not gdb.started or not fnoremakecheck) and not fcurrent then begin
   if (projectoptions.defaultmake <= maxdefaultmake) and 
      (not gdb.started or askconfirmation(c[ord(str_sourcechanged)])) then begin
    result:= false;
    watchpointsfo.clear;
    domake(projectoptions.defaultmake);
   end;
   fnoremakecheck:= true;
  end;
  if result then begin
   result:= runtarget;
  end;
 end
 else begin
  if not gdb.started then begin
   result:= false;
   dorun;
  end;
 end;
end;

procedure tmainfo.runexec(const sender: tobject);
begin
 if checkremake(sc_continue) then begin
  dorun;
 end;
end;

procedure tmainfo.aftermake(const adesigner: idesigner;
                               const exitcode: integer);
begin
 if exitcode <> 0 then begin
  setstattext(c[ord(makeerror)]+' '+inttostrmse(exitcode)+'.',mtk_error);
  showfirsterror;
 end
 else begin
  setstattext(c[ord(makeok)],mtk_finished);
  fcurrent:= true;
  fnoremakecheck:= false;
  messagefo.messages.lastrow;
  if projectoptions.s.closemessages then begin
   messagefo.hide;
  end;
  if fstartcommand <> sc_none then begin
   runtarget;
  end;
 end;
end;

procedure Tmainfo.resetstartcommand;
begin
 fstartcommand:= sc_none;
end;

procedure tmainfo.killtarget;
begin
 if frunningprocess <> invalidprochandle then begin
  killprocess(frunningprocess);
  frunningprocess:= invalidprochandle;
 end;
end;

procedure tmainfo.sourcechanged(const sender: tsourcepage);
begin
 fnoremakecheck:= false;
 fcurrent:= false;
 if sender = nil then begin
  updatemodifiedforms;
 end;
end;

procedure tmainfo.exitonexecute(const sender: tobject);
begin
 window.close;
end;

procedure tmainfo.moduledestroyed(const adesigner: idesigner;
                                                 const amodule: tmsecomponent);
var
 po1: pmoduleinfoty;
begin
 po1:= designer.modules.findmodulebyinstance(amodule);
 removemodulemenuitem(po1);
 if po1 = factivedesignmodule then begin
  factivedesignmodule:= nil;
 end;
end;

procedure tmainfo.methodcreated(const adesigner: idesigner;
  const amodule: tmsecomponent; const aname: string;
  const atype: ptypeinfo);
begin
 //dummy
end;

procedure tmainfo.methodnamechanged(const adesigner: idesigner;
  const amodule: tmsecomponent; const newname, oldname: string; const atypeinfo: ptypeinfo);
begin
 //dummy
end;

procedure tmainfo.showobjecttext(const adesigner: idesigner;
                 const afilename: filenamety; const backupcreated: boolean);
var
 page: tsourcepage;
begin
 page:= sourcefo.openfile(afilename,true);
 if page <> nil then begin
  page.ismoduletext:= true;
  if backupcreated then begin
   page.setbackupcreated;
  end;
 end;
end;

procedure tmainfo.closeobjecttext(const adesigner: idesigner; 
                           const afilename: filenamety; var cancel: boolean);
begin
 cancel:= not sourcefo.closepage(afilename);
end;

procedure tmainfo.newpanelonexecute(const sender: TObject);
begin
 newpanel.activate;
end;

procedure tmainfo.viewwatchpointsonexecute(const sender: TObject);
begin
 watchpointsfo.activate;
end;

procedure tmainfo.viewsymbolsonexecute(const sender: TObject);
begin
 symbolfo.activate;
end;

procedure tmainfo.viewthreadsonexecute(const sender: TObject);
begin
 threadsfo.activate;
end;

procedure tmainfo.viewconsoleonexecute(const sender: TObject);
begin
 targetconsolefo.activate;
end;

procedure tmainfo.viewfindresults(const sender: TObject);
begin
 findinfilefo.activate;
end;

procedure tmainfo.aboutonexecute(const sender: TObject);
begin
 showmessage('MSEide version: '+versiontext+c_linefeed+
             'MSEgui version: '+mseguiversiontext+c_linefeed+
             'Host: '+ platformtext+ c_linefeed+
             c_linefeed+
             copyrighttext+c_linefeed+
             'by Martin Schreiber'
             ,actionsmo.c[ord(ac_about)]+' MSEide');
end;

procedure tmainfo.configureexecute(const sender: TObject);
begin
 configureide;
end;

procedure tmainfo.beforemake(const adesigner: idesigner;
               const maketag: integer; var abort: boolean);
begin
 //dummy
end;


procedure tmainfo.beforefilesave(const adesigner: idesigner;
               const afilename: filenamety);
begin
 //dummy
end;

procedure tmainfo.runtool(const sender: tobject);
var
 str1: msestring;
 mstr1: msestring;
 macrolist: tmacrolist;
// gridcoord1: gridcoordty;
 cursourcefile,curmodulefile,
 cursselection,cursword,cursdefinition: msestring;
 curcomponentclass,curproperty: msestring;
 spos1: sourceposty;
 ar1: componentarty;
 propit: tpropertyitem;
 opt1: execoptionsty; 
begin
 with tmenuitem(sender),projectoptions,t,texp do begin
  str1:= tosysfilepath(toolfiles[index]);
  if str1 <> '' then begin
   if (index <= high(toolfiles)) and (toolparams[index] <> '') then begin
    if (index <= high(toolsave)) and toolsave[index] then begin
     actionsmo.saveallactonexecute(nil);
    end;
    if sourcefo.activepage <> nil then begin
     with sourcefo.activepage do begin
      cursourcefile:= tosysfilepath(sourcefo.currentfilename);
      cursselection:= sourcefo.currentselection;//edit.selectedtext;
      cursword:= sourcefo.currentwordatcursor;//getpascalvarname(edit,edit.editpos,gridcoord1);
      if (index <= high(toolparse)) and toolparse[index] then begin
       spos1.pos:= edit.editpos;
       spos1.filename:= designer.designfiles.find(edit.filename);
       application.beginwait;
       try
        findlinkdest(edit,spos1,cursdefinition);
       finally
        application.endwait;
       end;
      end;
     end
    end
    else begin
     cursourcefile:= '';
     cursselection:= '';
     cursword:= '';
     cursdefinition:= '';
    end;
    curcomponentclass:= '';
    curproperty:= '';
    if factivedesignmodule <> nil then begin
     curmodulefile:= tosysfilepath(factivedesignmodule^.filename);
     ar1:= designer.selectedcomponents;
     if high(ar1) = 0 then begin
      with gettypedata(ar1[0].classinfo)^ do begin
       curcomponentclass:= msestring(uppercase(unitname+'.'+ar1[0].classname));
      end;
      propit:= tpropertyitem(objectinspectorfo.props.item);
      if propit <> nil then begin
       curproperty:= curcomponentclass+'.' + uppercase(propit.rootpath);
      end;
     end;
    end
    else begin
     curmodulefile:= '';
    end;
    mstr1:= toolparams[index];
    if mstr1 <> '' then begin
     macrolist:= tmacrolist.create([mao_caseinsensitive]);
     macrolist.add(getprojectmacros);     
     macrolist.add(['CURSOURCEFILE','CURMODULEFILE',
                    'CURSSELECTION','CURSWORD','CURSDEFINITION',
                    'CURCOMPONENTCLASS','CURPROPERTY'],
                    [cursourcefile,curmodulefile,
                     cursselection,cursword,cursdefinition,
                     curcomponentclass,curproperty],[]);
     macrolist.expandmacros1(mstr1);
     macrolist.free;
     str1:= str1 + ' ' + mstr1;
    end;
   end;
   opt1:= [exo_nostdhandle];
   if not((index > high(toolhide)) or toolhide[index]) then begin
    include(opt1,exo_inactive);
   end;
   if (index <= high(toolmessages)) and toolmessages[index] then begin
    ttoolhandlermo.create(self,str1,opt1);
   end
   else begin
    execmse(str1,opt1{not((index > high(toolhide)) or toolhide[index]),true});
   end;
  end;
 end;
end;

procedure tmainfo.statbefread(const sender: TObject);
begin
 createcpufo;
end;

procedure tmainfo.getstatobjs(const sender: TObject;
               var aobjects: objectinfoarty);
begin
 with projectoptions do begin
{
  if not (sg_options in disabled) then begin
   addobjectinfoitem(aobjects,o);
  end;
}
  if not (sg_editor in disabled) then begin
   addobjectinfoitem(aobjects,e);
  end;
  if not (sg_debugger in disabled) then begin
   addobjectinfoitem(aobjects,d);
  end;
  if not (sg_make in disabled) then begin
   addobjectinfoitem(aobjects,k);
  end;
  if not (sg_macros in disabled) then begin
   addobjectinfoitem(aobjects,m);
  end;
  if not (sg_fontalias in disabled) then begin
   addobjectinfoitem(aobjects,a);
  end;
  if not (sg_usercolors in disabled) then begin
   addobjectinfoitem(aobjects,u);
  end;
  if not (sg_formatmacros in disabled) then begin
   addobjectinfoitem(aobjects,f);
  end;
  if not (sg_templates in disabled) then begin
   addobjectinfoitem(aobjects,p);
  end;
  if not (sg_tools in disabled) then begin
   addobjectinfoitem(aobjects,t);
  end;
  if not (sg_storage in disabled) then begin
   addobjectinfoitem(aobjects,r);
  end;
  if not (sg_state in disabled) then begin
   addobjectinfoitem(aobjects,s);
  end;
 end;
end;

procedure tmainfo.savewindowlayout(const awriter: tstatwriter);
var
 opt1: statfileoptionsty;
begin
 opt1:= projectstatfile.options;
 projectstatfile.options:= mainfo.projectstatfile.options + 
                                        [sfo_nodata,sfo_nooptions];
 awriter.setsection('breakpoints');
 beginpanelplacement();
 try
  panelform.updatestat(awriter);
  awriter.setsection('layout');
  projectstatfile.updatestat('windowlayout',awriter);
 finally
  endpanelplacement();
  mainfo.projectstatfile.options:= opt1;
 end;
end;

procedure tmainfo.savewindowlayout(const astream: ttextstream);
var
 statwriter: tstatwriter;
begin
 statwriter:= tstatwriter.create(astream,ce_utf8);
 try
  savewindowlayout(statwriter);
 finally
  statwriter.free;
 end;
end;

procedure tmainfo.loadwindowlayout(const areader: tstatreader);
begin
 beginpanelplacement();
 try
  areader.setsection('breakpoints');
  panelform.updatestat(areader);
  areader.setsection('layout');
  projectstatfile.options:= projectstatfile.options + 
                                          [sfo_nodata,sfo_nooptions];
  flayoutloading:= true;
  projectstatfile.readstat('windowlayout',areader);
 finally
  flayoutloading:= false;
  projectstatfile.options:= projectstatfile.options -
                                          [sfo_nodata,sfo_nooptions];
  endpanelplacement();
 end;
end;

procedure tmainfo.loadwindowlayout(const astream: ttextstream);
var
 statreader: tstatreader;
begin
 statreader:= tstatreader.create(astream,ce_utf8);
 try
  loadwindowlayout(statreader);
 finally
  statreader.free;
 end;
end;

procedure tmainfo.loadwindowlayoutexe(const sender: TObject);
var
 str1: ttextstream;
begin
 if filedialog(windowlayoutfile,[fdo_checkexist],c[ord(str_loadwindowlayout)],
          [c[ord(projectfiles)],c[ord(str_allfiles)]],['*.prj','*'],'prj',
          nil,nil,nil,[fa_all],[fa_hidden],
                        @windowlayouthistory) = mr_ok then begin
 str1:= ttextstream.create(windowlayoutfile);
 try
  loadwindowlayout(str1);
 finally
  str1.destroy();
 end;
 end;
end;

procedure tmainfo.closeprojectactonexecute(const sender: TObject);
begin
 if mainfo.openproject('') then begin
  caption:= idecaption;
  fprojectloaded:= false;
 end;
end;

procedure tmainfo.mainstatbeforewriteexe(const sender: TObject);
begin
 disassfo.resetshortcuts();
end;

procedure tmainfo.statafterread(const sender: TObject);
begin
 actionsmo.forcezorderact.checked:= projectoptions.s.forcezorder;
end;

procedure tmainfo.basedockpaintexe(const sender: twidget;
               const acanvas: tcanvas);
begin
 paintdockingareacaption(acanvas,sender,mainfo.c[ord(dockingarea)]);
end;

end.
