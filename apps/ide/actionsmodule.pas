{ MSEide Copyright (c) 1999-2006 by Martin Schreiber
   
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
 mseclasses,mseact,mseactions,msebitmap,msestrings,msegui,msedatamodules,mseglob;
 
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
 end;

var
 actionsmo: tactionsmo;
 
procedure configureide;

implementation
uses
 main,make,actionsmodule_mfm,msemenus,sourceform,msedesigner,msetypes,msefiledialog,
 projectoptionsform,findinfileform,breakpointsform,watchform,selecteditpageform,
 msewidgets,disassform,printform,msegdbutils,mseintegerenter,msesettings,
 mseguiglob,componentstore;

procedure configureide;
begin
 if editsettings('Configure MSEide',actionsmo.shortcuts) then begin
  expandprojectmacros;
 end;
end;

{ tactionsmo }

procedure tactionsmo.updateshortcuts(const sender: tshortcutcontroller);
begin
 copy.shortcut:= sysshortcuts[sho_copy];
 copy.shortcut1:= sysshortcuts1[sho_copy];
 cut.shortcut:= sysshortcuts[sho_cut];
 cut.shortcut1:= sysshortcuts1[sho_cut];
 paste.shortcut:= sysshortcuts[sho_paste];
 paste.shortcut1:= sysshortcuts1[sho_paste];
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
 sourcefo.activepage.edit.undo;
end;

procedure tactionsmo.redoactonexecute(const sender: tobject);
begin
 sourcefo.activepage.edit.redo;
end;

procedure tactionsmo.copyactonexecute(const sender: tobject);
begin
 sourcefo.activepage.edit.copyselection;
end;

procedure tactionsmo.cutactonexecute(const sender: tobject);
begin
 sourcefo.activepage.edit.cutselection;
end;

procedure tactionsmo.indentonexecute(const sender: TObject);
begin
 sourcefo.activepage.edit.indent(projectoptions.blockindent);
end;

procedure tactionsmo.unindentonexecute(const sender: TObject);
begin
 sourcefo.activepage.edit.unindent(projectoptions.blockindent);
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
 sourcefo.activepage.dofind;
end;

procedure tactionsmo.repeatfindactonexecute(const sender: tobject);
begin
 sourcefo.activepage.repeatfind;
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
  programfinished;
  setstattext('');
  startgdbonexecute(sender);
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
 mainfo.gdb.detach;
 mainfo.startgdbonexecute(nil);
end;

procedure tactionsmo.onattachprocess(const sender: TObject);
var
 int1: integer;
 info: stopinfoty;
begin
 with mainfo do begin
  int1:= 0;
  if integerenter(int1,minint,maxint,
          'Process ID','Attach to process') = mr_ok then begin
   startgdbonexecute(nil);
   gdb.attach(int1,info);
   loadexec(true);
   refreshstopinfo(info);
  end;
 end;
end;

end.
