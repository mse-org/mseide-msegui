{ MSEide Copyright (c) 1999-2010 by Martin Schreiber

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

{$ifdef FPC}
 {$ifndef mse_no_ifi}
  {$define mse_with_ifi}
 {$endif}
 {$mode objfpc}{$h+}
{$endif}

interface

uses
 mseforms,msesimplewidgets,mseguiglob,msegui,msegdbutils,mseactions,
 msedispwidgets,msedataedits,msestat,msestatfile,msemenus,msebitmap,msetoolbar,
 msegrids,msefiledialog,msetypes,sourcepage,msetabs,msedesignintf,msedesigner,
 classes,mseclasses,msegraphutils,typinfo,msedock,sysutils,msesysenv,msestrings,
 msepostscriptprinter,msegraphics,mseglob,mseprocmonitorcomp,msesys;
const
 versiontext = '2.5 unstable';
{$ifdef linux}
 {$ifdef CPU64}
  hosttext = 'x86_64-linux';
 {$else}
  hosttext = 'i386-linux';
 {$endif}
{$else}
 hosttext = 'i386-win32';
{$endif}
 idecaption = 'MSEide';

type
 filekindty = (fk_none,fk_source,fk_unit);
 messagetextkindty = (mtk_info,mtk_running,mtk_finished,mtk_error,mtk_signal);

 startcommandty = (sc_none,sc_step,sc_continue);
// formkindty = (fok_main,fok_simple,fok_dock,fok_data,fok_subform,
//               fok_report,fok_script,fok_inherited);

 tmainfo = class(tmseform,idesignnotification)
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
   procedure newfileonexecute(const sender: tobject);
//   procedure newprogramonexecute(const sender: TObject);
//   procedure newunitonexecute(const sender: TObject);
   procedure newformonexecute(const sender: TObject);
//   procedure newtextfileonexecute(const sender: TObject);

   procedure mainfooncreate(const sender: tobject);
   procedure mainfoondestroy(const sender: tobject);
//   procedure mainfoonclosequery(const sender: tcustommseform; var modalresult: modalresultty);
   procedure mainstatfileonupdatestat(const sender: tobject; const filer: tstatfiler);
   procedure mainfoonterminate(var terminate: Boolean);
   procedure mainonloaded(const sender: TObject);
   procedure mainonactivewindowchanged(const oldwindow: twindow;
                      const newwindow: twindow);
   procedure mainonwindowdestroyed(const awindow: twindow);

   procedure mainmenuonupdate(const sender: tcustommenu);
   procedure onscale(const sender: TObject);
   procedure parametersonexecute(const sender: TObject);
   procedure buildactonexecute(const sender: TObject);
   procedure projectoptionsonexecute(const sender: tobject);
   procedure openprojectonexecute(const sender: tobject);
   procedure projectsaveonexecute(const sender: TObject);
   procedure saveprojectasonexecute(const sender: tobject);
   procedure newprojectonexecute(const sender: TObject);
   procedure closeprojectactonexecute(const sender: TObject);
   procedure exitonexecute(const sender: tobject);
   procedure newpanelonexecute(const sender: TObject);

   procedure viewassembleronexecute(const sender: TObject);
   procedure viewcpuonexecute(const sender: TObject);
   procedure viewmessagesonexecute(const sender: TObject);
   procedure viewsourceonexecute(const sender: tobject);
   procedure viewprojectonexecute(const sender: tobject);
   procedure viewbreakpointsonexecute(const sender: tobject);
   procedure viewwatchesonexecute(const sender: tobject);
   procedure viewstackonexecute(const sender: tobject);
   procedure viewobjectinspectoronexecute(const sender: TObject);
   procedure toggleobjectinspectoronexecute(const sender: tobject);
   procedure viewcomponentpaletteonexecute(const sender: TObject);
   procedure viewcomponentstoreonexecute(const sender: TObject);
   procedure viewdebuggertoolbaronexecute(const sender: TObject);
   procedure viewwatchpointsonexecute(const sender: TObject);
   procedure viewprojectsourceonexecute(const sender: TObject);
   procedure viewthreadsonexecute(const sender: TObject);
   procedure viewconsoleonexecute(const sender: TObject);
   procedure viewfindresults(const sender: TObject);
   procedure aboutonexecute(const sender: TObject);
   procedure configureexecute(const sender: TObject);
   
   //debugger
   procedure startgdbonexecute(const sender: tobject);
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
  private
   fstartcommand: startcommandty;
   fnoremakecheck: boolean;
   fcurrent: boolean;
   flastform: tcustommseform;
   flastdesignform: tcustommseform;
   fexecstamp: integer;
   fprojectname: filenamety;
   fcheckmodulelevel: integer;
   fcheckmodulerecursion: boolean;
   fuploadprocid: integer;
   fuploadexitcode: integer;
   fgdbserverprocid: integer;
   fgdbserverexitcode: integer;
   fgdbservertimeout: longword;
   ftargetfilemodified: boolean;
   frunningprocess: prochandlety;
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
   procedure resetdebugdisp; //called before running debbuggee
   procedure createprogramfile(const aname: filenamety);
   function copynewfile(const aname,newname: filenamety;
                            const autoincrement: boolean;
                            const canoverwrite: boolean;
                            const macronames: array of msestring;
                            const macrovalues: array of msestring): boolean;
                            //true if ok
//   procedure createform(const aname: filenamety; const kind: formkindty);
   procedure createform(const aname: filenamety; const namebase: string;
                        const ancestor: string);
   procedure removemodulemenuitem(const amodule: pmoduleinfoty);
   procedure uploadexe(const sender: tguiapplication; var again: boolean);
   procedure uploadcancel(const sender: tobject);
   procedure gdbserverexe(const sender: tguiapplication; var again: boolean);
   procedure gdbservercancel(const sender: tobject);
   procedure updatetargetenvironment;
   function needsdownload: boolean;
   function candebug: boolean; //run command empty or process attached
  public
   factivedesignmodule: pmoduleinfoty;
   fprojectloaded: boolean;
   errorformfilename: filenamety;
   constructor create(aowner: tcomponent); override;

   function checkgdberror(aresult: gdbresultty): boolean;
   function startgdbconnection(const attach: boolean): boolean;
   function loadexec(isattach: boolean; const force: boolean): boolean; //true if ok
   procedure setstattext(const atext: msestring; const akind: messagetextkindty = mtk_info);
   procedure refreshstopinfo(const stopinfo: stopinfoty);
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
//   procedure makefinished(const exitcode: integer);
   procedure sourcechanged(const sender: tsourcepage);
   function opensource(const filekind: filekindty; const addtoproject: boolean;
                        const aactivate: boolean = true): boolean;
            //true if filedialog not canceled
   function openformfile(const filename: filenamety; 
                const ashow,aactivate,showsource,createmenu: boolean): pmoduleinfoty;
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
   procedure sourceformactivated;
   procedure stackframechanged(const frameno: integer);
   procedure refreshframe;
   procedure toggleformunit;
   property lastform: tcustommseform read flastform;
   property execstamp: integer read fexecstamp;
 end;

var
 mainfo: tmainfo;

procedure handleerror(const e: exception; const text: string);

implementation
uses
 mseparser,msesysintf,memoryform,
 regwidgets,regeditwidgets,regkernel,regdialogs,regprinter,
 {$ifdef FPC}{$ifndef mse_withoutdb}regdb,regreport,{$endif}{$endif}
{$ifdef mse_with_ifi}
 regifi,{$ifdef mse_with_ifirem}regifirem,{$endif}
{$endif}
 {$ifdef mse_with_zeoslib}regzeoslib,{$endif}
 {$ifdef mse_with_pascalscript}regpascalscript,{$endif}
 regdesignutils,regsysutils,regserialcomm,regexperimental,
{$ifdef morecomponents}
{$include regcomponents.inc}
{$endif}
 main_mfm,sourceform,watchform,breakpointsform,stackform,
 guitemplates,projectoptionsform,make,msewidgets,msepropertyeditors,
 skeletons,msedatamodules,mseact,
 mseformdatatools,mseshapes,msefileutils,projecttreeform,mseeditglob,
 findinfileform,formdesigner,sourceupdate,actionsmodule,programparametersform,
 objectinspector,msesysutils,msestream,cpuform,disassform,
 panelform,watchpointsform,threadsform,targetconsole,
 debuggerform,componentpaletteform,componentstore,
 messageform,msesettings,mseintegerenter
 {$ifdef linux} ,mselibc {$endif},
 mseprocutils
 {$ifdef mse_dumpunitgroups},dumpunitgroups{$endif};

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
 inherited create(aowner);
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

procedure tmainfo.dofindmodulebyname(const amodule: pmoduleinfoty; const aname: string;
                    var action: modalresultty);
var
 wstr2: msestring;

 function dofind(const modulenames: msestringarty; const modulefilenames: filenamearty): boolean;
 var
  int1: integer;
  wstr1: msestring;
  po1: pmoduleinfoty;
 begin
  result:= false;
  for int1:= 0 to high(modulenames) do begin
   if modulenames[int1] = wstr2 then begin
    if int1 <= high(modulefilenames) then begin
     if findfile(modulefilenames[int1],projectoptions.texp.sourcedirs,wstr1) or
            findfile(filename(modulefilenames[int1]),
            projectoptions.texp.sourcedirs,wstr1) then begin
      try
       po1:= openformfile(wstr1,false,false,false,false);
       result:= (po1 <> nil) and (struppercase(po1^.instancevarname) = wstr2);
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

begin
 wstr2:= struppercase(aname);
 int1:= findchar(wstr2,'.');
 if int1 > 0 then begin
  setlength(wstr2,int1-1); //main name only
 end;
 with projectoptions do begin
  bo1:= dofind(modulenames,modulefilenames);
 end;
 if not bo1 then begin
  with projecttree.units do begin
   bo1:= dofind(modulenames,modulefilenames);
  end;
 end;
 if bo1 then begin
  action:= mr_ok;
 end
 else begin
  action:= showmessage('Unresolved references in '+amodule^.moduleclassname+' to ' +
                aname + '.'+lineend+
                       ' Do you wish to search the formfile?','WARNING',
                       [mr_ok,mr_cancel],mr_ok);
  case action of
   mr_ok: begin
    wstr2:= '';
    action:= filedialog(wstr2,[fdo_checkexist],'Formfile for '+ aname,
                 ['Formfiles'],['*.mfm'],'',nil,nil,nil,[fa_all],[fa_hidden]);
                 //defaultvalues don't work on kylix
    if action = mr_ok then begin
     openformfile(wstr2,false,false,true,true);
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
   if findfile(fname,texp.sourcedirs,wstr1) or
          findfile(fname,texp.sourcedirs,wstr1) then begin
    try
     po1:= openformfile(wstr1,false,false,false,false);
    except
     on e: eabort do begin
      raise;
     end
     else begin
      po1:= nil;
     end;
    end;
   end;
  end;
 end;
 
var
 ar1: msestringarty;
 
begin
 ar1:= nil; //compilerwarning
 if fcheckmodulelevel >= 16 then begin
  showmessage('Recursive form hierarchy for "'+atypename+'"','ERROR');
  sysutils.abort;
 end;
 inc(fcheckmodulelevel);
 try
  with projectoptions do begin
   po1:= nil;
   wstr2:= struppercase(atypename);
   for int1:= 0 to high(moduletypes) do begin
    if moduletypes[int1] = wstr2 then begin
     if int1 <= high(modulefilenames) then begin
      checkmodule(modulefilenames[int1]);
     end;
     break;
    end;
   end;
  end;
  if po1 = nil then begin
   ar1:= projecttree.units.moduleclassnames;
   for int1:= 0 to high(ar1) do begin
    if ar1[int1] = wstr2 then begin
     checkmodule(projecttree.units.modulefilenames[int1]);
     break;
    end;
   end;
  end;
  if (po1 = nil) or 
             (stringicomp(po1^.moduleclassname,atypename) <> 0) then begin
   if showmessage('Classtype '+atypename+' not found.'+lineend+
                         ' Do you wish to search the formfile?','WARNING',
                         [mr_yes,mr_cancel]) = mr_yes then begin
    wstr2:= '';
    if filedialog(wstr2,[fdo_checkexist],'Formfile for '+ atypename,
                   ['Formfiles'],['*.mfm']) = mr_ok then begin
     openformfile(wstr2,false,false,false,false);
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
  designer.showformdesigner(pmoduleinfoty(tagpointer));
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
 componentpalettefo.componentpalette.buttons.resetradioitems(0);
end;

procedure tmainfo.moduleactivated(const adesigner: idesigner; const amodule: tmsecomponent);
begin
 factivedesignmodule:= designer.actmodulepo;
 flastdesignform:= factivedesignmodule^.designform;
end;

procedure tmainfo.moduledeactivated(const adesigner: idesigner; const amodule: tmsecomponent);
begin
// factivedesignmodule:= nil;
end;

procedure tmainfo.sourceformactivated;
begin
 factivedesignmodule:= nil;
end;

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
    with projectoptions,texp do begin
     if modified and not savechecked then begin
      result:= showmessage('Project '+fprojectname+' is modified. Save?','Confirmation',
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

procedure tmainfo.updatemodifiedforms;
var
 int1: integer;
begin
 with mainmenu1.menu.itembyname('view') do begin
  for int1:= itembyname('formmenuitemstart').index+1 to count - 1 do begin
   with items[int1] do begin
    with pmoduleinfoty(tagpointer)^ do begin
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
  objectinspectorfo.window.stackunder(factivedesignmodule^.designform.window);
 end;
end;

//debugger

procedure tmainfo.expronsetvalue(const sender: tobject;
  var avalue: msestring; var accept: boolean);
var
 expres: string;
begin
 gdb.evaluateexpression(avalue,expres);
 exprdisp.value:= expres;
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
     po1^.designform.activate(true);
     page1:= nil;
    end
    else begin
     page1:= sourcefo.findsourcepage(str1);
     if page1 = nil then begin //mfm not loaded in editor
      po1:= designer.loadformfile(str1);      
      if po1 <> nil then begin
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
    raise exception.create('Unable to open file "'+str1+'".');
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

procedure tmainfo.refreshstopinfo(const stopinfo: stopinfoty);
begin
 with stopinfo do begin
  case reason of
   sr_signal_received: begin
    setstattext(messagetext,mtk_signal);
   end;
   sr_error: begin
    setstattext(messagetext,mtk_error);
   end; 
   sr_exception: begin
   end; 
   else begin
    setstattext(messagetext,mtk_finished);
   end;
  end;
  watchfo.refresh;
  breakpointsfo.refresh;
  stackfo.refresh;
  threadsfo.refresh;
  cpufo.refresh;
  disassfo.refresh(addr);
  if (reason = sr_exception) then begin
   setstattext(messagetext+' '+stackfo.infotext(1),mtk_signal);
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
  if projectoptions.activateonbreak then begin
   if flastform <> nil then begin
    flastform.activate;
   end
   else begin
    sourcefo.activate;
   end;
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
       setstattext(stopinfo.messagetext,mtk_finished);
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
   setstattext('*** Running ***',mtk_running);   
  end;
  gek_error,gek_writeerror: begin
   setstattext('GDB: '+stopinfo.messagetext,mtk_error);
  end;
  gek_targetoutput: begin
   targetconsolefo.addtext(values[0].value);
  end;
  gek_download: begin
   with stopinfo do begin
    if sectionsize > 0 then begin
     setstattext('Downloading '+section+' '+
         inttostr(round(sectionsent/sectionsize*100))+'%',mtk_running);
    end;
   end;
  end;
  gek_done: begin
   if sender.downloading then begin
    downloaded;
    setstattext('Downloaded '+formatfloat('0.00,',stopinfo.totalsent/1024)+'kB',
                     mtk_finished);      
    sender.abort;
   end;
  end;
 end;
end;

procedure tmainfo.gdbserverexe(const sender: tguiapplication; var again: boolean);
begin
 sys_schedyield;
 if timeout(fgdbservertimeout) and 
     getprocessexitcode(fgdbserverprocid,fgdbserverexitcode,100000) then begin
  sender.terminatewait;
 end
 else begin
  sender.idlesleep(100000);
  again:= true;
 end;
end;

procedure tmainfo.gdbservercancel(const sender: tobject);
begin
 killprocess(fgdbserverprocid);
end;

function tmainfo.startgdbconnection(const attach: boolean): boolean;
var
 mstr1: msestring;
begin
 result:= false;
 with projectoptions,texp do begin
  if attach then begin
   mstr1:= gdbservercommandattach;
  end
  else begin
   mstr1:= gdbservercommand;
  end;
  if mstr1 <> '' then begin
   fgdbserverprocid:= execmse1(mstr1);
   if fgdbserverprocid <> invalidprochandle then begin
    fgdbservertimeout:= timestep(round(1000000*gdbserverwait));
    if application.waitdialog(nil,'Start gdb server command "'+
                           mstr1+'" running.','Start gdb Server',
              {$ifdef FPC}@{$endif}gdbservercancel,nil,
              {$ifdef FPC}@{$endif}gdbserverexe) then begin
     if fgdbserverexitcode <> 0 then begin
      setstattext('gdb server start error '+inttostr(fgdbserverexitcode)+'.',
                mtk_error);
      exit;
     end;
    end
    else begin
     setstattext('gdb server start canceled.',mtk_error);
     exit;
    end;                
   end
   else begin
    setstattext('Can not run start gdb command.',mtk_error);
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
  setstattext('GDB: ' + gdb.geterrormessage(aresult),mtk_error);
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
  gdb.stoponexception:= projectoptions.stoponexception;
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
 {$ifdef mswindows}
 gdb.newconsole:= projectoptions.externalconsole;
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
 result:= ftargetfilemodified or projectoptions.downloadalways;
end;

function tmainfo.candebug: boolean; //run command empty or process attached
begin
 result:= (projectoptions.texp.runcommand = '') or gdb.started;
end;

procedure tmainfo.downloaded;
begin
 ftargetfilemodified:= false;
end;

procedure tmainfo.updatetargetenvironment;
       //todo: implement for run without gdb
var
 int1: integer;
begin
 with projectoptions,texp do begin
  gdb.progparameters:= progparameters;
  gdb.workingdirectory:= progworkingdirectory;
  gdb.clearenvvars;
  for int1:= 0 to high(envvarons) do begin
   if (int1 > high(envvarnames)) or 
                    (int1 > high(envvarnames)) then begin
    break;
   end;
   if envvarons[int1] then begin
    gdb.setenvvar(envvarnames[int1],envvarvalues[int1]);
   end;
  end;
 end;
end;

function tmainfo.loadexec(isattach: boolean; const force: boolean): boolean;
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
  if not gdb.execloaded or force then begin
   if not gdb.active then begin
    startgdbonexecute(nil);
   end;
   str1:= gettargetfile;
   with projectoptions,texp do begin
//    if debugtarget <> '' then begin
//     str1:= debugtarget;
//    end
//    else begin
//     str1:= makedir+targetfile;
//    end; 
    if not gdbdownload and not gdbsimulator and (uploadcommand <> '') and 
                   (needsdownload or force) then begin
     dodownload;
     if application.waitdialog(nil,'Uploadcommand "'+uploadcommand+'" running.',
         'Uploading',{$ifdef FPC}@{$endif}uploadcancel,nil,
         {$ifdef FPC}@{$endif}uploadexe) then begin
      if downloadresult <> 0 then begin
       setstattext('Download ***ERROR*** ' + inttostr(downloadresult)+'.',mtk_error);
       exit;
      end
      else begin
       setstattext('Download finished.',mtk_finished);
       downloaded;
       if projectoptions.closemessages then begin
        messagefo.hide;
       end;
      end;
     end
     else begin
      setstattext('Download canceled.',mtk_error);
      exit;
     end;                
(*                   
     fuploadprocid:= execmse1(uploadcommand);
     if fuploadprocid <> invalidprochandle then begin
      if application.waitdialog(nil,'Uploadcommand "'+uploadcommand+'" running.',
          'Uploading',{$ifdef FPC}@{$endif}uploadcancel,nil,
          {$ifdef FPC}@{$endif}uploadexe) then begin
      end
      else begin
       setstattext('Upload canceled.',mtk_error);
       exit;
      end;                
     end
     else begin
      setstattext('Can not run upload command.',mtk_error);
     end;
*)
    end
   end;
   if checkgdberror(gdb.fileexec(str1)) then begin
    inc(fexecstamp);
    breakpointsfo.updatebreakpoints;
   end;
   checkbluedots;
  end;
 end;
 result:= gdb.execloaded or gdb.attached;
 if result then begin
  updatetargetenvironment;
  watchpointsfo.clear;
  targetconsolefo.clear;
  if projectoptions.showconsole then begin
   targetconsolefo.activate;
  end;
  if force and projectoptions.gdbdownload then begin
   if startgdbconnection(false) then begin
    gdb.download(false);
   end;
  end;
 end;
end;

procedure tmainfo.unloadexec;
begin
 if gdb.active then begin
  gdb.fileexec('');   //unload exec
 end;
 setstattext('');
 checkbluedots;
end;

procedure tmainfo.startgdbonexecute(const sender: tobject);
begin
 with projectoptions,texp do begin
  gdb.remoteconnection:= remoteconnection;
  gdb.gdbdownload:= gdbdownload;
  gdb.simulator:= gdbsimulator;
  gdb.processorname:= gdbprocessor;
  gdb.beforeload:= beforeload;  
  gdb.beforerun:= beforerun;
  gdb.afterload:= afterload;
  gdb.startupbkpt:= startupbkpt;
  gdb.startupbkpton:= startupbkpton;
  gdb.startgdb(tosysfilepath(quotefilename(debugcommand))+ ' ' + debugoptions);
 end;
 updatesigsettings;
 cleardebugdisp;
 checkbluedots;
end;

procedure tmainfo.symboltypeonsetvalue(const sender: tobject;
  var avalue: msestring; var accept: boolean);
var
 expres: string;
begin
 gdb.symboltype(avalue,expres);
 symboltypedisp.value:= expres;
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

procedure tmainfo.viewprojectonexecute(const sender: tobject);
begin
 projecttreefo.activate;
end;

procedure tmainfo.mainmenuonupdate(const sender: tcustommenu);
var
 bo1: boolean;
begin
 with projectoptions,texp,actionsmo do begin
  detachtarget.enabled:= gdb.execloaded;
  download.enabled:= not gdb.started and not gdb.downloading and 
               ((uploadcommand <> '') or gdbdownload);
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
  saveall.enabled:= sourcefo.modified or designer.modified or projectoptions.modified;
  actionsmo.toggleformunit.enabled:= (flastform <> nil) or
                                            (designer.modules.count > 0);
  if (sourcefo.activepage <> nil) and sourcefo.activepage.activeentered then begin
   print.enabled:= true;
   with sourcefo.activepage do begin
    actionsmo.save.enabled:= modified;
    undo.enabled:= edit.canundo;
    redo.enabled:= edit.canredo;
    copy.enabled:= edit.hasselection;
    cut.enabled:= edit.hasselection;
    paste.enabled:= edit.canpaste;
    delete.enabled:= edit.hasselection;
    indent.enabled:= true;
    unindent.enabled:= true;
    line.enabled:= grid.rowcount > 0;
    togglebkpt.enabled:= line.enabled;
    togglebkptenable.enabled:= togglebkpt.enabled;
    find.enabled:= true;
    replace.enabled:= true;
    actionsmo.repeatfind.enabled:= find.enabled and 
           (projectoptions.findreplaceinfo.find.text <> '');
   end;
  end
  else begin
   print.enabled:= false;
   save.enabled:= false;
   undo.enabled:= false;
   redo.enabled:= false;
   copy.enabled:= false;
   cut.enabled:= false;
   paste.enabled:= false;
   delete.enabled:= false;
   indent.enabled:= false;
   unindent.enabled:= false;
   line.enabled:= false;
   togglebkpt.enabled:= false;
   togglebkptenable.enabled:= false;
   find.enabled:= false;
   actionsmo.repeatfind.enabled:= false;
   replace.enabled:= false;
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
  mainmenu1.menu.itembyname('project').itembyname('close').enabled:= fprojectloaded;
 end;
end;

function tmainfo.formmenuitemstart: integer;
begin
 result:= mainmenu1.menu.itembyname('view').itembyname(
               'formmenuitemstart').index + 1;
end;

function tmainfo.openformfile(const filename: filenamety;
       const ashow,aactivate,showsource,createmenu: boolean): pmoduleinfoty;
var
 item1: tmenuitem;
 wstr1,wstr2: filenamety;
 bo1: boolean;
 int1: integer;
begin
 result:= designer.modules.findmodule(filename);
 if result = nil then begin
  wstr2:= msefileutils.filename(filename);
  if findfile(filename) then begin
   wstr1:= filename;
  end
  else begin
   wstr1:= searchfile(wstr2,projectoptions.texp.sourcedirs);
   if wstr1 = '' then begin
    wstr1:= filename; //to raise exception
   end
   else begin
    wstr1:= wstr1 + wstr2;
   end;
  end;
  try
   result:= designer.loadformfile(wstr1);
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
   with mainmenu1.menu.itembyname('view') do begin
    bo1:= false;
    for int1:= formmenuitemstart to submenu.count-1 do begin
     if submenu[int1].tagpointer = result then begin
      bo1:= true;
      break;
     end;
    end;
    if not bo1 then begin
     item1:= tmenuitem.create;
     with item1 do begin
      caption:= msefileutils.filename(result^.filename);
      onexecute:= {$ifdef FPC}@{$endif}doshowform;
      tagpointer:= result;
      options:= options + [mao_asyncexecute];
     end;
     bo1:= false;
     for int1:= formmenuitemstart to submenu.count-1 do begin
      if submenu[int1].caption > item1.caption then begin
       submenu.insert(int1,item1);
       bo1:= true;
       break;
      end;
     end;
     if not bo1 then begin
      submenu.insert(bigint,item1);
     end;
    end;
   end;
  end;
  if ashow then begin
   result^.designform.show;
   if aactivate then begin
    result^.designform.activate;
   end;
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
    openformfile(str1,true,false,false,true);
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

function tmainfo.opensource(const filekind: filekindty; const addtoproject: boolean;
                              const aactivate: boolean = true): boolean;

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
  with openfile.controller do begin
   for int1:= 0 to high(filenames) do begin
    if checkfileext(filenames[int1],[formfileext]) then begin
     page:= sourcefo.findsourcepage(filenames[int1]);
     if page = nil then begin
      po1:= openformfile(filenames[int1],true,false,false,true);
     end;
    end
    else begin
     page:= sourcefo.openfile(filenames[int1]);
     if addtoproject then begin
      unitnode:= projecttree.units.addfile(filenames[int1]);
     end;
     str1:= designer.sourcenametoformname(filenames[int1]);
     if findfile(str1) then begin
      po1:= openformfile(str1,true,false,false,true);
      if addtoproject then begin
       unitnode.setformfile(str1);
      end;
     end;
    end;
   end;
  end;
  if aactivate then begin
   if page <> nil then begin
    page.activate;
   end
   else begin
    if po1 <> nil then begin
     po1^.designform.activate;
    end;
   end;
  end;
 end;
end;

procedure tmainfo.mainonactivewindowchanged(const oldwindow: twindow; 
                       const newwindow: twindow);
begin
 if (newwindow <> nil) {and (newwindow <> self.window)} and
    not (newwindow.transientfor <> nil) and (newwindow.owner is tcustommseform) then begin
  flastform:= tcustommseform(newwindow.owner);
  if sourcefo.checkancestor(flastform) then begin
   flastdesignform:= flastform;
  end
  else begin
   if (designer.actmodulepo <> nil) and
                 (designer.actmodulepo^.designform = flastform) then begin
    factivedesignmodule:= designer.actmodulepo;
    flastdesignform:= flastform;
   end;
  end;
 end;
end;

procedure tmainfo.mainonwindowdestroyed(const awindow: twindow);
begin
 if awindow.owner = flastform then begin
  flastform:= nil;
 end;
 if awindow.owner = flastdesignform then begin
  flastdesignform:= nil;
 end;
end;

procedure tmainfo.viewcomponentpaletteonexecute(const sender: TObject);
begin
 componentpalettefo.window.bringtofront;
 componentpalettefo.show;
end;

procedure tmainfo.viewcomponentstoreonexecute(const sender: TObject);
begin
 componentstorefo.activate;
end;

procedure tmainfo.viewdebuggertoolbaronexecute(const sender: TObject);
begin
 debuggerfo.window.bringtofront;
 debuggerfo.show;
end;

procedure tmainfo.mainonloaded(const sender: tobject);
var
 wstr1: msestring;
begin
 try
  wstr1:= filepath(statdirname);
  if not finddir(wstr1) then begin
   createdir(wstr1);
  end;
  {$ifdef mswindows}
  mainstatfile.filename:= 'mseidewi.sta';
  {$endif}
  {$ifdef linux}
  mainstatfile.filename:= 'mseideli.sta';
  {$endif}
  mainstatfile.readstat;
  expandprojectmacros;
  onscale(nil);
 finally
  mainfo.activate;
 end;
 {$ifdef mse_dumpunitgroups}
 dumpunitgr;
 {$endif}
end;

function getmodulename(const aname,suffix: string): string;
var
 int1: integer;
begin
 int1:= length(aname) - length(suffix);
 if (int1 >= 0) and (strcomp(pchar(aname)+int1,pchar(suffix)) = 0) then begin
  result:= copy(aname,1,int1) + copy(suffix,1,2);
 end
 else begin
  result:= aname+copy(suffix,1,2);
 end;
end;

procedure tmainfo.createform(const aname: filenamety; const namebase: string;
                        const ancestor: string);
//procedure tmainfo.createform(const aname: filenamety; const kind: integer{formkindty});

var
 stream1: ttextstream;
 str1,str2,str3: string;
// ancestor: string;
 po1: pmoduleinfoty;
begin
  str2:= removefileext(filename(aname));
  str3:= str2;
  str2:= getmodulename(str2,namebase);
{
  case kind of
   fok_dock: begin
    ancestor:= 'tdockform';
    str2:= getmodulename(str2,'form');
   end;
   fok_data: begin
    ancestor:= 'tmsedatamodule';
    str2:= getmodulename(str2,'module');
   end;
   fok_subform: begin
    ancestor:= 'tsubform';
    str2:= getmodulename(str2,'subform');
   end;
   else begin
    ancestor:= 'tmseform';
    str2:= getmodulename(str2,'form');
   end;
  end;
}
  stream1:= ttextstream.create(aname,fm_create);
  try
   formskeleton(stream1,filename(str3),str2,ancestor);
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
  po1:= openformfile(str1,true,false,true,true);
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
  programskeleton(stream1,removefileext(filename(aname)));
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
  showmessage('File "'+aname+'" not found.','WARNING');
 end
 else begin
  path2:= filepath(newname);
  if not canoverwrite and fileexists(path2) then begin
   if not autoincrement then begin
    showerror('File "'+newname+'" exists.');
    exit;
   end
   else begin
    splitfilepath(filepath(aname),dir,base,ext);
    base:= base + dir;
    int1:= 1;
    repeat
     path2:= base+inttostr(int1)+ext;
     inc(int1);
    until not findfile(path2);
   end;
  end;
  splitfilepath(path2,dir,base,ext);
  macrolist:= tmacrolist.create([mao_curlybraceonly]);
  try
   macrolist.add(['%FILEPATH%','%FILENAME%','%FILENAMEBASE%'],[path2,base+ext,base]);
   macrolist.add(macronames,macrovalues);
   instream:= ttextstream.create(path1);
   try
    text:= instream.readmsestrings;
    macrolist.expandmacros(text);
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
 with projectoptions.texp do begin
  if newfisources[int1] = '' then begin
   sourcefo.newpage;
  end
  else begin
   if filedialog(str1,[fdo_save,fdo_checkexist],'New '+newfinames[int1],[newfinames[int1]],
          [newfifilters[int1]],newfiexts[int1]) = mr_ok then begin
    copynewfile(newfisources[int1],str1,false,true,
             ['%PROGRAMNAME%','%UNITNAME%'],['${%FILENAMEBASE%}','${%FILENAMEBASE%}']);
    sourcefo.openfile(str1,true);
   end;
  end;
 end;
end;

(*
procedure tmainfo.newprogramonexecute(const sender: TObject);
var
 str1: filenamety;
begin
 str1:= '';
 if filedialog(str1,[fdo_save,fdo_checkexist],'New program',['Pascal Files'],
         ['"*.pas" "*.pp"'],'pas') = mr_ok then begin
  if projectoptions.texp.newprogramfile = '' then begin
   createprogramfile(str1);
  end
  else begin
   copynewfile(projectoptions.texp.newprogramfile,str1,false,true,
            ['%PROGRAMNAME%'],['${%FILENAMEBASE%}']);
  end;
  sourcefo.openfile(str1,true);
 end;
end;

procedure tmainfo.newtextfileonexecute(const sender: TObject);
begin
 sourcefo.newpage;
end;

procedure tmainfo.newunitonexecute(const sender: TObject);
var
 str1: filenamety;
 stream1: ttextstream;
begin
 str1:= '';
 if filedialog(str1,[fdo_save,fdo_checkexist],'New unit',['Pascal Files'],
         ['"*.pas" "*.pp"'],'pas') = mr_ok then begin
  if projectoptions.texp.newunitfile = '' then begin
   stream1:= ttextstream.create(str1,fm_create);
   try
    unitskeleton(stream1,removefileext(filename(str1)));
   finally
    stream1.Free;
   end;
   sourcefo.showsourceline(str1,0,0,true);
  end
  else begin
   copynewfile(projectoptions.texp.newunitfile,str1,false,true,
            ['%UNITNAME%'],['${%FILENAMEBASE%}']);
  end;
  sourcefo.openfile(str1,true);
 end;
end;
*)
procedure tmainfo.newformonexecute(const sender: TObject);
var
 str1,str2,str3,str4,str5: filenamety;
 dir,base,ext: filenamety;
 po1: pmoduleinfoty;
 ancestorclass,ancestorunit: string;
 
begin
// if formkindty(tmenuitem(sender).tag) = fok_inherited then begin
 if projectoptions.newinheritedforms[tmenuitem(sender).tag] then begin
  po1:= selectinheritedmodule(nil,'Select ancestor');
  if po1 = nil then begin
   exit;
  end;
  ancestorclass:= po1^.moduleclassname;
  ancestorunit:= filenamebase(po1^.filename);
 end
 else begin
  ancestorclass:= '';
  ancestorunit:= '';
  po1:= nil;
 end;
 str1:= '';
 if filedialog(str1,[fdo_save,fdo_checkexist],'New form',['Pascal Files'],
         ['"*.pas" "*.pp"'],'pas') = mr_ok then begin
  with projectoptions.texp do begin
   str4:= newfonamebases[tmenuitem(sender).tag];
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
   str4:= getmodulename(base,str4);
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
    openformfile(str5,true,false,false,true);
    po1:= designer.modules.findmodule(str5);
    if po1 <> nil then begin
     po1^.modified:= true; //initial create of ..._mfm.pas
    end;
   end;
  end
  else begin
//   createform(str1,formkindty(tmenuitem(sender).tag));
   createform(str1,'form','tmseform'); //default
  end;
 end;
end;

procedure tmainfo.removemodulemenuitem(const amodule: pmoduleinfoty);
var
 int1: integer;
begin
 with mainmenu1.menu.itembyname('view') do begin
  for int1:= itembyname('formmenuitemstart').index+1 to count - 1 do begin
   if items[int1].tagpointer = amodule then begin
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
begin
 if amodule <> nil then begin
  if nocheckclose or designer.checkcanclose(amodule,str1) then begin
   result:= designer.closemodule(amodule,achecksave);
  end
  else begin
//   showerror('Form '+ amodule^.filename +
//       ' can not be closed, it is used by '+str1+'.');
//   result:= false;
   amodule^.designform.hide;
   result:= true;
   removemodulemenuitem(amodule);
  end;
  if result then begin
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

procedure tmainfo.projectoptionsonexecute(const sender: tobject);
begin
 editprojectoptions;
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
var
 modres: modalresultty;
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
  caption:= idecaption+' (<new>)';
 end
 else begin
  caption:= idecaption+' ('+filename(aname)+')';
  msefileutils.setcurrentdir(filedir(aname));
//  openfile.controller.lastdir:= msefileutils.getcurrentdir;
  openfile.controller.filename:= '';
 end;
end;

function tmainfo.openproject(const aname: filenamety;
                               const ascopy: boolean = false): boolean;

 procedure closepro;
 begin
  sourceupdater.clear;
  initprojectoptions;
  projectoptions.projectfilename:= '';
  setprojectname('');
  projecttreefo.clear;
  watchfo.clear(true);
  breakpointsfo.clear;
  watchpointsfo.clear(true);
  cleardebugdisp;
 end;
 
var
 namebefore: msestring;
 projectfilebefore: msestring;
 projectdirbefore: msestring;
 
begin
 gdb.abort;
 result:= false;
 projectfilebefore:= projectoptions.projectfilename;
 projectdirbefore:= projectoptions.projectdir;
 namebefore:= fprojectname;
 if (checksave <> mr_cancel) and closeall(true) then begin
  closepro;
  if aname <> '' then begin
   try
    setcurrentdir(removelastpathsection(aname));
   except
    application.handleexception(nil,'Can not load Project "'+aname+'": ');
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
 int1: integer;
 curdir,source,dest: filenamety;
 macrolist: tmacrolist;
 copiedfiles: filenamearty;
 bo1: boolean;
  
begin
 mstr2:= projecttemplatedir; //use macros of actual project
 if openproject('') then begin
  gdb.closegdb;
  cleardebugdisp;
  sourcechanged(nil);
  mstr1:= '';
  if not fromprogram then begin
   if not empty then begin
    aname:= mstr2 + 'default.prj';
    if filedialog(aname,[fdo_checkexist],'Select project template',
             ['Project files','All files'],['*.prj','*'],'prj') = mr_ok then begin
     readprojectoptions(aname);
    end;
   end;
   aname:= '';
  end
  else begin
   aname:= '';
   if filedialog(aname,[fdo_checkexist],'Select program file',
            ['Program files','All files'],['"*.pas" "*.pp"','*'],'pas') = mr_ok then begin
    setcurrentdir(filedir(aname));
    with projectoptions do begin
     with t do begin
      mainfile:= filename(aname);
      aname:= removefileext(mainfile);
      targetfile:= aname+'${EXEEXT}'
     end;
     expandprojectmacros;
    end;
    aname:= aname + '.prj';
   end;
  end;
  if filedialog(aname,[fdo_save,fdo_checkexist],'New Project',
           ['Project files','All files'],['*.prj','*'],'prj') = mr_ok then begin
   curdir:= filedir(aname);
   setcurrentdir(curdir);
   if not fromprogram then begin
    mstr1:= removefileext(filename(aname));
    with projectoptions do begin
     projectfilename:= aname;
     projectdir:= curdir;
     expandprojectmacros;
     with texp do begin  
      setlength(copiedfiles,length(newprojectfiles));
      macrolist:= tmacrolist.create([mao_curlybraceonly]);
      try
       macrolist.add(['%PROJECTNAME%','%PROJECTDIR%'],[mstr1,curdir]);
       if runscript(scriptbeforecopy,true,false) then begin
        for int1:= 0 to high(newprojectfiles) do begin
         source:= filepath(newprojectfiles[int1]);
         if int1 <= high(newprojectfilesdest) then begin
          dest:= newprojectfilesdest[int1];
         end
         else begin
          dest:= '';
         end;
         if dest <> '' then begin
          macrolist.expandmacros(dest);
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
         copiedfiles[int1]:= dest;
         if newprojectfiles[int1] <> '' then begin
          if (int1 <= high(expandprojectfilemacros)) and 
                             expandprojectfilemacros[int1] then begin
           copynewfile(source,dest,false,false,['%PROJECTNAME%','%PROJECTDIR%'],
                                       [mstr1,curdir]);
          end
          else begin
           try
            if not copyfile(source,dest,false) then begin
             showerror('File "'+dest+'" exists.');
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
     for int1:= 0 to high(copiedfiles) do begin
      if int1 > high(loadprojectfile) then begin
       break;
      end;
      if loadprojectfile[int1] then begin
       if checkfileext(copiedfiles[int1],[formfileext])then begin
        openformfile(copiedfiles[int1],true,false,false,true);
       end
       else begin
        sourcefo.openfile(copiedfiles[int1],bo1);
        bo1:= false;
       end;
      end;
     end;
    end;
   end
   else begin
    saveproject(aname);
    sourcefo.openfile(projectoptions.texp.mainfile,true);
   end;
  end
  else begin
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

procedure tmainfo.openprojectonexecute(const sender: tobject);
var
 str1: filenamety;
begin
 if projectfiledialog(str1,false) = mr_ok then begin
  openproject(str1);
 end;
end;

procedure tmainfo.openprojectcopyexecute(const sender: TObject);
var
 str1: filenamety;
begin
 if projectfiledialog(str1,false) = mr_ok then begin
  openproject(str1,true);
 end;
end;

procedure tmainfo.closeprojectactonexecute(const sender: TObject);
begin
 if openproject('') then begin
  caption:= idecaption;
  fprojectloaded:= false;
 end;
end;

procedure tmainfo.projectsaveonexecute(const sender: TObject);
begin
 if projectoptions.projectfilename = '' then begin
  saveprojectasonexecute(sender);
 end
 else begin
  saveproject(projectoptions.projectfilename);
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
 ar1: msestringarty;
 int1: integer;
begin
 ar1:= nil; //compiler warning
 updatesettings(filer);

 mstr1:= projectoptions.projectfilename;
 filer.updatevalue('projectname',mstr1);
 filer.updatevalue('projecthistory',projecthistory);
 if not filer.iswriter then begin
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
 if projectoptions.texp.runcommand = '' then begin
  if startgdbconnection(false) then begin
   gdb.gdbdownload:= projectoptions.gdbdownload and 
                         (needsdownload or projectoptions.downloadalways);
   checkgdberror(gdb.run);
  end;
 end
 else begin
  with projectoptions,texp do begin
   mstr1:= runcommand;
   if progparameters <> '' then begin
    mstr1:= mstr1 + ' ' + progparameters;
   end;
   if progworkingdirectory <> '' then begin
    pwdbefore:= getcurrentdir;
    setcurrentdir(progworkingdirectory);
   end;
   frunningprocess:= targetconsolefo.terminal.execprog(mstr1);   
   if frunningprocess = invalidprochandle then begin
    setstattext('Can not start Process',mtk_error);
    exit;
   end;
   runprocmon.listentoprocess(frunningprocess);
   try
   finally
    if progworkingdirectory <> '' then begin
     setcurrentdir(pwdbefore);
    end;
   end;
  end;
  setstattext('Process '+inttostr(frunningprocess)+' running.',mtk_running);
 end;
end;

procedure tmainfo.runprocdied(const sender: TObject;
                          const prochandle: prochandlety;
               const execresult: Integer; const data: Pointer);
begin
 if prochandle = frunningprocess then begin
  frunningprocess:= invalidprochandle;
  if execresult <> 0 then begin
   setstattext('Process terminated '+inttostr(execresult)+'.',
                                    mtk_error);
  end
  else begin
   setstattext('Process terminated normally.',mtk_finished);
  end;
 end;
end;

function tmainfo.runtarget: boolean;
                   //true if run possible
begin
 result:= true;
 if not gdb.attached then begin
  if projectoptions.texp.runcommand = '' then begin
   if not gdb.started then begin
    if loadexec(false,false) then begin
     result:= false;
     dorun;
    end;
   end;
  end
  else begin
   result:= false;
   dorun;
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
  startgdbonexecute(nil);
 end;
 if not gdb.attached then begin
  if (not gdb.started or not fnoremakecheck) and not fcurrent then begin
   if (projectoptions.defaultmake <= maxdefaultmake) and 
    (not gdb.started or askyesno('Source has changed, do you wish to remake project?')) then begin
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
  setstattext('Make ***ERROR*** '+inttostr(exitcode)+'.',mtk_error);
  showfirsterror;
 end
 else begin
  setstattext('Make OK.',mtk_finished);
  fcurrent:= true;
  fnoremakecheck:= false;
  messagefo.messages.lastrow;
  if projectoptions.closemessages then begin
   messagefo.hide;
  end;
  if fstartcommand <> sc_none then begin
   runtarget;
//   if loadexec(false,false) then begin
//    dorun;
//   end;
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
end;

procedure tmainfo.exitonexecute(const sender: tobject);
begin
 window.close;
end;

procedure tmainfo.moduledestroyed(const adesigner: idesigner;
  const amodule: tmsecomponent);
begin
 removemodulemenuitem(designer.modules.findmodulebyinstance(amodule));
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

procedure tmainfo.viewprojectsourceonexecute(const sender: TObject);
begin
 sourcefo.openfile(projectoptions.texp.mainfile,true);
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
 showmessage('MSEgui version: '+mseguiversiontext+c_linefeed+
             'MSEide version: '+versiontext+c_linefeed+
             'Host: '+ hosttext,'About MSEide');
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
 str1: ansistring;
 mstr1: msestring;
 macrolist: tmacrolist;
 gridcoord1: gridcoordty;
 cursourcefile,curmodulefile,
 cursselection,cursword,cursdefinition: msestring;
 curcomponentclass,curproperty: msestring;
 spos1: sourceposty;
 ar1: componentarty;
 propit: tpropertyitem;
 
begin
 with tmenuitem(sender),projectoptions,texp do begin
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
       curcomponentclass:= uppercase(unitname+'.'+ar1[0].classname);
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
     macrolist.add(['CURSOURCEFILE','CURMODULEFILE',
                    'CURSSELECTION','CURSWORD','CURSDEFINITION',
                    'CURCOMPONENTCLASS','CURPROPERTY'],
                    [cursourcefile,curmodulefile,
                     cursselection,cursword,cursdefinition,
                     curcomponentclass,curproperty]);
     macrolist.expandmacros(mstr1);
     macrolist.free;
     str1:= str1 + ' ' + mstr1;
    end;
   end;
   execmse(str1,not((index > high(toolhide)) or toolhide[index]),true);
  end;
 end;
end;

procedure tmainfo.statbefread(const sender: TObject);
begin
 createcpufo;
end;

end.
