{ MSEide Copyright (c) 1999-2014 by Martin Schreiber
   
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
unit actionsmodule;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 classes,mseclasses,mseact,mseactions,msebitmap,msestrings,msegui,
 msedatamodules,mseglob,msestat,mseifiglob,msegraphics,msegraphutils,mseguiglob,
 msemenus,msesimplewidgets,msewidgets,projecttreeform,msestringcontainer,
 targetconsole,mseificomp,mseificompglob,mclasses;
 
type
 stringconsts = (
  ac_configuremseide, //0 Configure MSEide
  ac_processid,       //1 Process ID
  ac_attachtoprocess, //2 Attach to process
  ac_unknownmodclass, //3 Unknown moduleclass for "
  ac_inheritedcomp,   //4 Inherited component "
  ac_cannotdel,       //5 " can not be deleted.
  ac_error,           //6 ERROR
  ac_makeaborted,     //7 Make aborted.
  ac_downloadaborted, //8 Download aborted.
  ac_runerrorwith,    //9 Runerror with "
  ac_errortimeout,    //10 Error: Timeout.
  ac_making,          //11 Making.
  ac_makenotrunning,  //12 Make not running.
  ac_downloading,     //13 Downloading.
  ac_downloadnotrunning, //14 Download not running.
  ac_running,         //15 " running.
  ac_script,         //16 Script
  ac_recursiveforminheritance, //17 Recursive form inheritance of "
  ac_component,      //18 Component "
  ac_exists,         //19 " exists.
  ac_ancestorfor,    //20 Ancestor for "
  ac_notfound,       //21 " not found.
  ac_module,         //22 Module "
  ac_invalidname,    //23 Invalid name "
  ac_invalidmethodname, //24 Invalid methodname
  ac_modulenotfound, //25 Module not found
  ac_methodnotfound, //26 Method not found
  ac_publishedmeth,  //27 Published (managed) method
  ac_doesnotexist,   //28 does not exist.
  ac_wishdelete,     //29 Do you wish to delete the event?
  ac_warning,        //30 WARNING
  ac_method,         //31 Method
  ac_differentparams,   //32 has different parameters.
  ac_amodule,        //33 A module "
  ac_isopen,         //34 " is already open.
  ac_unresolvedref,   //35 Unresolved reference(s) to
  ac_modules,        //36 Module(s):
  ac_cannotreadform, //37 Can not read formfile "
  ac_invalidcompname,//38 Invalid component name.
  ac_invalidexception, //39 Invalid exception
  ac_tools,           //40 T&ools
  ac_forms,           //41 Forms
  ac_source,          //42 Source
  ac_allfiles,        //43 All Files
  ac_program,         //44 Program
  ac_unit,            //45 Unit
  ac_textfile,        //46 Textfile
  ac_mainform,        //47 Mainform
  ac_simpleform,      //48 Simple Form
  ac_dockingform,     //49 Docking Form
  ac_datamodule,      //50 Datamodule
  ac_subform,         //51 Subform
  ac_scrollboxform,   //52 Scrollboxform
  ac_tabform,         //53 Tabform
  ac_dockpanel,       //54 Dockpanel
  ac_report,          //55 Report
  ac_scriptform,      //56 Scriptform
  ac_inheritedform,   //57 Inherited Form
  ac_replacesettings, //58 Do you want to replace the settings by
  ac_file,            //59 File "
  ac_wantoverwrite,   //60 Do you want to overwrite?
  ac_sr_unknown,      //61 Unknown
  ac_sr_error,        //62 Error
  ac_sr_startup,      //63 Startup
  ac_sr_exception,    //64 Exception
  ac_sr_gdbdied,      //65 GDB died
  ac_sr_breakpoint_hit,           //66 Breakpoint hit
  ac_sr_watchpointtrigger,        //67 Watchpoint triggered
  ac_sr_readwatchpointtrigger,    //68 Read Watchpoint triggered
  ac_sr_accesswatchpointtrigger,  //69 Access Watchpoint triggered
  ac_sr_end_stepping_range,       //70 End stepping range
  ac_sr_function_finished,        //71 Function finished
  ac_sr_exited_normally,          //72 Exited normally
  ac_sr_exited,                   //73 Exited
  ac_sr_detached,                 //74 Detached
  ac_sr_signal_received,          //75 Signal received
  ac_stoperror,                   //76 Stop error
  ac_cannotreadproject,           //77 Can not read project
  ac_about,                       //78 About
  ac_objectinspector,             //79 Object Inspector
  ac_storecomponent,              //80 Store Component
  ac_attachingprocess,            //81 Attaching Process
  ac_loading                      //82 Loading
 );

type
 tactionsmo = class(tmsedatamodule)
   buttonicons: timagelist;

   opensource: taction;
   saveall: taction;
   saveas: taction;
   save: taction;
   close: taction;
   closeall: taction;

   reset: taction;
   interrupt: taction;
   next: taction;
   step: taction;
   finish: taction;
   continue: taction;
//   run: taction;

   line: taction;
   find: taction;
   repeatfind: taction;
   findinfile: taction;

   indent: taction;
   nexti: taction;
   stepi: taction;
   bluedotsonact: taction;
   replace: taction;
   print: taction;
   detachtarget: taction;
   attachprocess: taction;
   lowercase: taction;
   uppercase: taction;
   toggleformunit: taction;
   unindent: taction;
   undo: taction;
   redo: taction;
   cut: taction;
   copy: taction;
   paste: taction;
   delete: taction;

   togglebkpt: taction;
   togglebkptenable: taction;
   bkptsonact: taction;
   watchesonact: taction;

   abortmakeact: taction;
   makeact: taction;
   selecteditpage: taction;

   run: taction;
   //common
   shortcuts: tshortcutcontroller;
   toggleinspector: taction;
   buildact: taction;
   make1act: taction;
   make2act: taction;
   make3act: taction;
   make4act: taction;
   download: taction;
   helpact: taction;
   attachtarget: taction;
   setbm0: taction;
   findbm0: taction;
   findbm1: taction;
   setbm1: taction;
   findbm2: taction;
   setbm2: taction;
   findbm3: taction;
   setbm3: taction;
   findbm4: taction;
   setbm4: taction;
   findbm5: taction;
   setbm5: taction;
   findbm6: taction;
   setbm6: taction;
   findbm7: taction;
   setbm7: taction;
   findbm8: taction;
   setbm8: taction;
   findbm9: taction;
   setbm9: taction;
   setbmnone: taction;
   instemplate: taction;
   projectopenact: taction;
   projectoptionsact: taction;
   projecttreeact: taction;
   projectsourceact: taction;
   projectsaveact: taction;
   projectcloseact: taction;
   c: tstringcontainer;
   copylatexact: taction;
   findcompact: taction;
   findcompallact: taction;
   forcezorderact: taction;
   procedure findinfileonexecute(const sender: tobject);

   //file
   procedure opensourceactonexecute(const sender: tobject);
   procedure saveactonexecute(const sender: tobject);
   procedure saveasactonexecute(const sender: TObject);
   procedure saveallactonexecute(const sender: tobject);
   procedure closeactonexecute(const sender: tobject);
   procedure closeallactonexecute(const sender: tobject);

   //editor
   procedure pasteactonexecute(const sender: tobject);
   procedure deleteactonexecute(const sender: tobject);
   procedure selecteditpageonexecute(const sender: TObject);
   procedure undoactonexecute(const sender: tobject);
   procedure redoactonexecute(const sender: tobject);
   procedure copyactonexecute(const sender: tobject);
   procedure cutactonexecute(const sender: tobject);

   procedure indentonexecute(const sender: TObject);
   procedure unindentonexecute(const sender: TObject);
   procedure lowercaseexecute(const sender: TObject);
   procedure uppercaseexecute(const sender: TObject);
   procedure enableonselect(const sender: tcustomaction);

   procedure lineactonexecute(const sender: TObject);
   procedure findactonexecute(const sender: tobject);
   procedure repeatfindactonexecute(const sender: tobject);
   procedure replaceactonexecute(const sender: TObject);

   procedure togglebreakpointexe(const sender: TObject);
   procedure togglebkptenableactonexecute(const sender: TObject);
   procedure toggleformunitonexecute(const sender: TObject);

   //make
   procedure makeactonexecute(const sender: tobject);
   procedure abortmakeactonexecute(const sender: tobject);

   //debugger
   procedure resetactonexecute(const sender: tobject);
   procedure interruptactonexecute(const sender: tobject);
   procedure continueactonexecute(const sender: tobject);
   procedure nextactonexecute(const sender: tobject);
   procedure finishactonexecute(const sender: tobject);
   procedure stepactonexecute(const sender: tobject);
   procedure stepiactonexecute(const sender: TObject);
   procedure nextiactonexecute(const sender: TObject);
   procedure bkptsononexecute(const sender: TObject);
   procedure watchesononexecute(const sender: TObject);
   procedure bluedotsononchange(const sender: TObject);
   procedure printactonexecute(const sender: TObject);
   procedure ondetachtarget(const sender: TObject);
   procedure onattachprocess(const sender: TObject);
   procedure updateshortcuts(const sender: tshortcutcontroller);
   procedure downloadexe(const sender: TObject);
   procedure helpex(const sender: TObject);
   procedure onattachtarget(const sender: TObject);
   procedure setbmexec(const sender: TObject);
   procedure findbmexec(const sender: TObject);
   procedure instemplateactonexecute(const sender: TObject);
   procedure projectopenexe(const sender: TObject);
   procedure projectoptionsexe(const sender: TObject);
   procedure projecttreeexe(const sender: TObject);
   procedure projectsourceexe(const sender: TObject);
   procedure projectsaveexe(const sender: TObject);
   procedure projectcloeseexe(const sender: TObject);
   procedure creadstateexe(const sender: TObject);
   procedure findupdateexe(const sender: tcustomaction);
   procedure copylatexactonexecute(const sender: TObject);
   procedure findcompexe(const sender: TObject);
   procedure findcompallexe(const sender: TObject);
   procedure forcezorderexe(const sender: TObject);
  private
   function filterfindcomp(const acomponent: tcomponent): boolean;
 end;

var
 actionsmo: tactionsmo;
 
procedure configureide;

implementation
uses
 main,make,actionsmodule_mfm,sourceform,msedesigner,msetypes,msefiledialog,
 projectoptionsform,findinfileform,breakpointsform,watchform,selecteditpageform,
 disassform,printform,msegdbutils,mseintegerenter,msesettings,
 componentstore,cpuform,sysutils,msecomptree,mseformatstr;
 
procedure configureide;
begin
 disassfo.resetshortcuts();
 if editsettings(actionsmo.c[ord(ac_configuremseide)],
                                      actionsmo.shortcuts) then begin
  mainfo.mainstatfile.writestat();
  expandprojectmacros();
 end;
end;

{ tactionsmo }

procedure tactionsmo.updateshortcuts(const sender: tshortcutcontroller);
begin
 undo.shortcut:= sysshortcuts[sho_groupundo];
 undo.shortcut1:= sysshortcuts1[sho_groupundo];
 redo.shortcut:= sysshortcuts[sho_groupredo];
 redo.shortcut1:= sysshortcuts1[sho_groupredo];
 copy.shortcut:= sysshortcuts[sho_copy];
 copy.shortcut1:= sysshortcuts1[sho_copy];
 cut.shortcut:= sysshortcuts[sho_cut];
 cut.shortcut1:= sysshortcuts1[sho_cut];
 paste.shortcut:= sysshortcuts[sho_paste];
 paste.shortcut1:= sysshortcuts1[sho_paste];
 findcompact.shortcut:= find.shortcut;
 findcompact.shortcut1:= find.shortcut1;
 findcompallact.shortcut:= find.shortcut;
 findcompallact.shortcut1:= find.shortcut1;
end;

//common
procedure tactionsmo.findinfileonexecute(const sender: tobject);
begin
 dofindinfile;
end;

//file

procedure tactionsmo.opensourceactonexecute(const sender: tobject);
begin
 with mainfo do begin
  opensource(fk_source,false);
 end;
end;

procedure tactionsmo.saveactonexecute(const sender: tobject);
begin
 with mainfo do begin
  if factivedesignmodule <> nil then begin
   designer.saveformfile(factivedesignmodule,factivedesignmodule^.filename,true);
   updatemodifiedforms;
  end
  else begin
   sourcefo.saveactivepage;
  end;
 end;
end;

procedure tactionsmo.saveasactonexecute(const sender: TObject);
var
 namebefore,str1: filenamety;
 po1: pmoduleinfoty;
begin
 with mainfo do begin
  if factivedesignmodule <> nil then begin
   str1:= factivedesignmodule^.filename;
   if openfile.controller.execute(str1,fdk_save) then begin
    designer.saveformfile(factivedesignmodule,str1,true);
   end;
  end
  else begin
   str1:= sourcefo.activepage.filepath;
   namebefore:= str1;
   if openfile.controller.execute(str1,fdk_save) then begin
    sourcefo.saveactivepage(str1);
    po1:= designer.modules.findmodule(designer.sourcenametoformname(namebefore));
    if po1 <> nil then begin
     str1:= designer.sourcenametoformname(str1);
     designer.saveformfile(po1,str1,true);
     po1^.filename:= str1;
     updatemodifiedforms;
    end;
   end;
  end;
 end;
end;

procedure tactionsmo.saveallactonexecute(const sender: tobject);
begin
 with mainfo do begin
  sourcefo.saveall(true);
  designer.saveall(true,true);
  componentstorefo.saveall(true);
  saveprojectoptions;
  updatemodifiedforms;
 end;
end;

procedure tactionsmo.closeactonexecute(const sender: tobject);
begin
 with mainfo do begin
  if factivedesignmodule <> nil then begin
   if closemodule(factivedesignmodule,true) then begin
    factivedesignmodule:= nil;
   end;
  end
  else begin
   sourcefo.closeactivepage;
  end;
 end;
end;

procedure tactionsmo.closeallactonexecute(const sender: tobject);
begin
 with mainfo do begin
  closeall(false);
 end;
end;

//editor

procedure tactionsmo.pasteactonexecute(const sender: tobject);
begin
 sourcefo.activepage.edit.paste;
end;

procedure tactionsmo.deleteactonexecute(const sender: tobject);
begin
 sourcefo.activepage.edit.deleteselection;
end;

procedure tactionsmo.selecteditpageonexecute(const sender: TObject);
begin
 selecteditpageform.selecteditpage;
end;

procedure tactionsmo.toggleformunitonexecute(const sender: TObject);
begin
 mainfo.toggleformunit;
end;

procedure tactionsmo.undoactonexecute(const sender: tobject);
begin
 sourcefo.activepage.doundo;
end;

procedure tactionsmo.redoactonexecute(const sender: tobject);
begin
 sourcefo.activepage.doredo;
end;

procedure tactionsmo.copyactonexecute(const sender: tobject);
begin
 sourcefo.activepage.edit.copyselection;
end;

procedure tactionsmo.copylatexactonexecute(const sender: TObject);
begin
 sourcefo.activepage.copylatex;
end;

procedure tactionsmo.cutactonexecute(const sender: tobject);
begin
 sourcefo.activepage.edit.cutselection;
end;

procedure tactionsmo.indentonexecute(const sender: TObject);
begin
 sourcefo.activepage.edit.indent(projectoptions.e.blockindent,
                                            projectoptions.e.tabindent);
end;

procedure tactionsmo.unindentonexecute(const sender: TObject);
begin
 sourcefo.activepage.edit.unindent(projectoptions.e.blockindent);
end;

procedure tactionsmo.lowercaseexecute(const sender: TObject);
begin
 sourcefo.activepage.edit.lowercase;
end;

procedure tactionsmo.uppercaseexecute(const sender: TObject);
begin
 sourcefo.activepage.edit.uppercase;
end;

procedure tactionsmo.enableonselect(const sender: tcustomaction);
begin
 sender.enabled:= (sourcefo.activepage <> nil) and 
                                      sourcefo.activepage.edit.hasselection;
end;

procedure tactionsmo.lineactonexecute(const sender: TObject);
begin
 sourcefo.activepage.doline;
end;

procedure tactionsmo.findactonexecute(const sender: tobject);
begin
 if targetconsolefo.activeentered then begin
  targetconsolefo.dofind;
 end
 else begin
  sourcefo.activepage.dofind;
 end;
end;

procedure tactionsmo.repeatfindactonexecute(const sender: tobject);
begin
 if targetconsolefo.activeentered then begin
  targetconsolefo.repeatfind;
 end
 else begin
  sourcefo.activepage.repeatfind;
 end;
end;

procedure tactionsmo.replaceactonexecute(const sender: tobject);
begin
 sourcefo.activepage.doreplace;
end;

procedure tactionsmo.togglebreakpointexe(const sender: TObject);
begin
 sourcefo.activepage.togglebreakpoint;
end;

procedure tactionsmo.togglebkptenableactonexecute(const sender: TObject);
begin
 sourcefo.activepage.togglebreakpointenabled;
end;

procedure tactionsmo.instemplateactonexecute(const sender: TObject);
begin
 sourcefo.activepage.inserttemplate;
end;


//make

procedure tactionsmo.abortmakeactonexecute(const sender: tobject);
begin
 make.abortmake;
end;

procedure tactionsmo.makeactonexecute(const sender: tobject);
begin
 with mainfo do begin
  if sender is tmenuitem then begin
   domake(tmenuitem(sender).tag);
  end
  else begin
   domake(0);
  end;
  resetstartcommand;
 end;
end;

//debugger

procedure tactionsmo.resetactonexecute(const sender: tobject);
begin
 with mainfo do begin
  gdb.abort;
  killtarget; //if running
  programfinished;
  setstattext('');
  startgdb(false);
 end;
end;

procedure tactionsmo.interruptactonexecute(const sender: tobject);
begin
 with mainfo do begin
  gdb.interrupt;
 end;
end;

procedure tactionsmo.continueactonexecute(const sender: tobject);
begin
 with mainfo do begin
  if checkremake(sc_continue) then begin
   cpufo.beforecontinue;
   gdb.continue;
  end;
 end;
end;

procedure tactionsmo.stepactonexecute(const sender: tobject);
begin
 with mainfo do begin
  if checkremake(sc_step) then begin
   gdb.step;
  end;
 end;
end;

procedure tactionsmo.stepiactonexecute(const sender: TObject);
begin
 with mainfo do begin
  if checkremake(sc_step) then begin
   gdb.stepi;
  end;
 end;
end;

procedure tactionsmo.nextactonexecute(const sender: tobject);
begin
 with mainfo do begin
  if checkremake(sc_step) then begin
   gdb.next;
  end;
 end;
end;

procedure tactionsmo.nextiactonexecute(const sender: TObject);
begin
 with mainfo do begin
  if checkremake(sc_step) then begin
   gdb.nexti;
  end;
 end;
end;

procedure tactionsmo.finishactonexecute(const sender: tobject);
begin
 with mainfo do begin
  if checkremake(sc_continue) then begin
   gdb.finish;
  end;
 end;
end;

procedure tactionsmo.bkptsononexecute(const sender: TObject);
begin
 breakpointsfo.bkptson.value:= bkptsonact.checked;
end;

procedure tactionsmo.watchesononexecute(const sender: TObject);
begin
 watchfo.watcheson.value:= watchesonact.checked;
end;

procedure tactionsmo.bluedotsononchange(const sender: TObject);
begin
 mainfo.checkbluedots;
end;

procedure tactionsmo.printactonexecute(const sender: TObject);
begin
 printform.print;
end;

procedure tactionsmo.ondetachtarget(const sender: TObject);
begin
 if mainfo.checkgdberror(mainfo.gdb.detach) then begin
  mainfo.startgdb(false);
 end;
end;

procedure tactionsmo.onattachprocess(const sender: TObject);
var
 int1: integer;
 info: stopinfoty;
begin
 with mainfo do begin
  int1:= 0;
  if integerenter(int1,minint,maxint,self.c[ord(ac_processid)],
                      self.c[ord(ac_attachtoprocess)]) = mr_ok then begin
   setstattext(self.c[ord(ac_attachingprocess)]+' '+
                                    inttostrmse(int1),mtk_running);
   application.processmessages;
   startgdb(false);
   gdb.attach(int1,info);
   loadexec(true,false);
   refreshstopinfo(info);
  end;
 end;
end;

procedure tactionsmo.onattachtarget(const sender: TObject);
var
 info: stopinfoty;
begin
 with mainfo do begin
  startgdb(false);
  if checkgdberror(gdb.filesymbol(gettargetfile)) and
                                startgdbconnection(true) then begin
   gdb.attachtarget(info);
   loadexec(true,false);
   refreshstopinfo(info);
  end;
 end;
end;

procedure tactionsmo.downloadexe(const sender: TObject);
begin
 mainfo.loadexec(false,true);
end;

procedure tactionsmo.helpex(const sender: TObject);
begin
 application.help(application.activewidget);
end;

procedure tactionsmo.setbmexec(const sender: TObject);
begin
 sourcefo.setbmexec(sender); 
end;

procedure tactionsmo.findbmexec(const sender: TObject);
begin
 sourcefo.findbmexec(sender);
end;

procedure tactionsmo.projectopenexe(const sender: TObject);
var
 fna1: filenamety;
begin
 if projectfiledialog(fna1,false) = mr_ok then begin
  mainfo.openproject(fna1);
 end;
end;

procedure tactionsmo.projectoptionsexe(const sender: TObject);
begin
 editprojectoptions;
end;

procedure tactionsmo.projecttreeexe(const sender: TObject);
begin
 projecttreefo.activate;
end;

procedure tactionsmo.projectsourceexe(const sender: TObject);
begin
 sourcefo.openfile(projectoptions.o.texp.mainfile,true);
end;

procedure tactionsmo.projectsaveexe(const sender: TObject);
begin
 if projectoptions.projectfilename = '' then begin
  mainfo.saveprojectasonexecute(sender);
 end
 else begin
  mainfo.saveproject(projectoptions.projectfilename);
 end;
end;

procedure tactionsmo.projectcloeseexe(const sender: TObject);
begin
 mainfo.closeprojectactonexecute (sender);
end;

procedure tactionsmo.creadstateexe(const sender: TObject);
begin
 msegdbutils.localizetext;
end;

procedure tactionsmo.findupdateexe(const sender: tcustomaction);
begin
 if targetconsolefo.activeentered then begin
  find.enabled:= true;
  repeatfind.enabled:= projectoptions.targetconsolefindinfo.text <> ''
 end
 else begin
  find.enabled:= (sourcefo.activepage <> nil) and 
        sourcefo.activepage.activeentered;
  repeatfind.enabled:= find.enabled and 
           (projectoptions.findreplaceinfo.find.text <> '');
 end;
 findcompallact.enabled:= not find.enabled;
end;

procedure tactionsmo.findcompexe(const sender: TObject);
begin
 if mainfo.factivedesignmodule <> nil then begin
  mainfo.factivedesignmodule^.designformintf.findcompdialog();
 end;
end;

function tactionsmo.filterfindcomp(
                                 const acomponent: tcomponent): boolean;
begin
 result:= not (cssubcomponent in acomponent.componentstyle) and
          (not (acomponent is twidget) or 
                (ws_iswidget in twidget(acomponent).widgetstate));
end;

procedure tactionsmo.findcompallexe(const sender: TObject);
var
 name1: msestring;
 comp1: tcomponent;
 po1: pmoduleinfoty;
begin
 name1:= '';
 with designer do begin
  if selections.count > 0 then begin
   name1:= msestring(ownernamepath(selections[0]));
  end;
  if compnamedialog(designer.getcomponentnametree(nil,true,true,nil,
                      @filterfindcomp,nil),name1,true) = mr_ok then begin
   replacechar1(name1,':','.');
   comp1:= designer.getcomponent(ansistring(name1),po1);
   designer.showformdesigner(po1);
   designer.selectcomponent(comp1);
  end;
 end;
end;

procedure tactionsmo.forcezorderexe(const sender: TObject);
begin
 if projectoptions.o <> nil then begin
  projectoptions.o.forcezorder:= taction(sender).checked;
  projectoptionsmodified();
 end;
end;

end.
