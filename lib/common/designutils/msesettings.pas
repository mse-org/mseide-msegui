{ MSEide Copyright (c) 2002-2013 by Martin Schreiber
   
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
unit msesettings;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,msegui,mseclasses,mseforms,msestat,msestatfile,
 msesimplewidgets,msefiledialog,msestrings,msemacros,msedataedits,msebitmap,
 msedatanodes,mseedit,mseevent,msegraphutils,msegrids,mselistbrowser,msemenus,
 msesys,msetypes,msegraphics,msewidgets,mseactions,mseifiglob,msesplitter,
 mseificomp,mseificompglob,msememodialog,msewidgetgrid;

type
 settingsmacroty = (sma_fpcdir,sma_fpclibdir,sma_msedir,sma_mselibdir,
                   sma_syntaxdefdir,sma_templatedir,sma_compstoredir,
                   sma_compiler,sma_debugger,
                   sma_exeext,sma_target,sma_targetosdir);
const
 statdirname = '^/.mseide';
 settingsmacronames: array[settingsmacroty] of msestring = (
                     'fpcdir','fpclibdir','msedir','mselibdir','syntaxdefdir',
                     'templatedir','compstoredir','compiler','debugger',
                     'exeext','target','targetosdir');
 {$ifdef mswindows}
 defaultsettingmacros: array[settingsmacroty] of msestring = (
                '','','','${MSEDIR}lib/common/','${MSEDIR}apps/ide/syntaxdefs/',
                '${MSEDIR}apps/ide/templates/','${MSEDIR}apps/ide/compstore/',
                'ppc386.exe','gdb.exe','.exe','i386-win32','windows');
 {$else}
  {$ifdef CPU64}
  defaultsettingmacros: array[settingsmacroty] of msestring = (
                 '','','','${MSEDIR}lib/common/','${MSEDIR}apps/ide/syntaxdefs/',
                 '${MSEDIR}apps/ide/templates/','${MSEDIR}apps/ide/compstore/',
                 'ppcx64','gdb','','x86_64-linux','linux');
  {$else}
   {$ifdef CPUARM}
  defaultsettingmacros: array[settingsmacroty] of msestring = (
                 '','','','${MSEDIR}lib/common/','${MSEDIR}apps/ide/syntaxdefs/',
                 '${MSEDIR}apps/ide/templates/','${MSEDIR}apps/ide/compstore/',
                 'ppcarm','gdb','','arm-linux','linux');
   {$else}
  defaultsettingmacros: array[settingsmacroty] of msestring = (
                 '','','','${MSEDIR}lib/common/','${MSEDIR}apps/ide/syntaxdefs/',
                 '${MSEDIR}apps/ide/templates/','${MSEDIR}apps/ide/compstore/',
                 'ppc386','gdb','','i386-linux','linux');
   {$endif}
  {$endif}
 {$endif}
                
type
 settingsmacroarty = array[settingsmacroty] of filenamety;
 settingsmacrosty = record
  macros: settingsmacroarty;
  globmacronames: msestringarty;
  globmacrovalues: msestringarty;
 end;
 settingsty = record
  macros: settingsmacrosty;
  printcommand: msestring;
 end;
  
 tsettingsfo = class(tmseform)
   tstatfile1: tstatfile;
   tlayouter1: tlayouter;
   printcomm: tstringedit;
   debugger: tfilenameedit;
   compiler: tfilenameedit;
   compstoredir: tfilenameedit;
   templatedir: tfilenameedit;
   syntaxdefdir: tfilenameedit;
   mselibdir: tfilenameedit;
   msedir: tfilenameedit;
   fpclibdir: tfilenameedit;
   fpcdir: tfilenameedit;
   tspacer1: tlayouter;
   targetosdir: tstringedit;
   target: tstringedit;
   exeext: tstringedit;
   tsplitter1: tsplitter;
   tbutton2: tbutton;
   tbutton1: tbutton;
   shortcutbu: tbutton;
   macrogrid: twidgetgrid;
   macroname: tstringedit;
   macrovalue: tmemodialogedit;
   tspacer2: tspacer;
   procedure epandfilenamemacro(const sender: TObject; var avalue: msestring;
                     var accept: Boolean);
   procedure formoncreate(const sender: TObject);
   procedure setvalue(const sender: TObject; var avalue: msestring;
             var accept: Boolean);
   procedure setprintcomm(const sender: TObject; var avalue: msestring;
                             var accept: Boolean);
   procedure editshortcuts(const sender: TObject);
  private
   fshortcutcontroller: tshortcutcontroller;
  protected
   function widgetstomacros: settingsmacrosty;
 end;

var
 settings: settingsty;

procedure updatesettings(const filer: tstatfiler);
function getsettingsmacros: macroinfoarty;
function getsyssettingsmacros: macroinfoarty;
function getprintcommand: msestring;
function editsettings(const acaption: msestring = '';
                           const shortcuts: tshortcutcontroller = nil): boolean;
 
implementation
uses
 msesettings_mfm,classes,mclasses,msesysintf,msefileutils,mseshortcutdialog;
 
function getsettingsmacros1(var amacros: settingsmacrosty): macroinfoarty;
var
 ma1: settingsmacroty;
 int1: integer;
begin
 with amacros do begin
  setlength(globmacrovalues,length(globmacronames));
  setlength(result,ord(high(settingsmacroty))+1+length(globmacronames));
  for  ma1:= low(settingsmacroty) to high(settingsmacroty) do begin
   result[ord(ma1)].name:= settingsmacronames[ma1]; 
   result[ord(ma1)].value:= macros[ma1];
  end;
  for int1:= 0 to high(globmacronames) do begin
   result[ord(high(settingsmacroty))+1+int1].name:= globmacronames[int1]; 
   result[ord(high(settingsmacroty))+1+int1].value:= globmacrovalues[int1]; 
  end;
 end;
end;

function getsettingsmacros: macroinfoarty;
begin
 result:= getsettingsmacros1(settings.macros);
end;

function getsyssettingsmacros: macroinfoarty;
var
 int1: integer;
begin
 result:= getsettingsmacros1(settings.macros);
 for int1:= 0 to ord(sma_debugger) do begin
  result[int1].value:= tosysfilepath(result[int1].value);
 end;
end;
 
function getprintcommand: msestring;
begin
 result:= settings.printcommand;
end;

procedure updatesettings(const filer: tstatfiler);
var
 ma1: settingsmacroty;
begin
 with settings,macros do begin
  if filer.iswriter then begin
   for ma1:= low(settingsmacroty) to high(settingsmacroty) do begin
    filer.updatevalue(settingsmacronames[ma1],macros[ma1]);
   end;
  end
  else begin
   with tstatreader(filer) do begin
    for ma1:= low(settingsmacroty) to high(settingsmacroty) do begin
     macros[ma1]:= readmsestring(settingsmacronames[ma1],defaultsettingmacros[ma1]);
    end;
   end;
   printcommand:= sys_getprintcommand;
  end;
  filer.updatevalue('printcommand',printcommand);
  filer.updatevalue('globmacronames',globmacronames); 
  filer.updatevalue('globmacrovalues',globmacrovalues); 
 end;
end;

function editsettings(const acaption: msestring = '';
                  const shortcuts: tshortcutcontroller = nil): boolean;
var
 settingsfo: tsettingsfo;
begin
 result:= false;
 settingsfo:= tsettingsfo.create(nil);
 with settingsfo do begin
  try
   fshortcutcontroller:= shortcuts;
   if shortcuts = nil then begin
    shortcutbu.visible:= false;
   end;
   if acaption <> '' then begin
    settingsfo.caption:= acaption;
   end;
   if show(true) = mr_ok then begin
    result:= true;
    with settings do begin
     macros:= widgetstomacros;
//     expandprojectmacros;
     printcommand:= printcomm.value;
    end;
   end;
  finally
   free;
  end;
 end;
end;

{ tsettingsfo }

procedure tsettingsfo.formoncreate(const sender: TObject);
begin
 with settings,macros do begin
  fpcdir.value:= macros[sma_fpcdir];
  fpclibdir.value:= macros[sma_fpclibdir];
  msedir.value:= macros[sma_msedir];
  mselibdir.value:= macros[sma_mselibdir];
  syntaxdefdir.value:= macros[sma_syntaxdefdir];
  templatedir.value:= macros[sma_templatedir];
  compstoredir.value:= macros[sma_compstoredir];
  compiler.value:= macros[sma_compiler];
  debugger.value:= macros[sma_debugger];
  exeext.value:= macros[sma_exeext];
  target.value:= macros[sma_target];
  targetosdir.value:= macros[sma_targetosdir];
  printcomm.value:= printcommand;
  macroname.gridvalues:= globmacronames;
  macrovalue.gridvalues:= globmacrovalues;
 end;
end;

function tsettingsfo.widgetstomacros: settingsmacrosty;
begin
 with result do begin
  macros[sma_fpcdir]:= fpcdir.value;
  macros[sma_fpclibdir]:= fpclibdir.value;
  macros[sma_msedir]:= msedir.value;
  macros[sma_mselibdir]:= mselibdir.value;
  macros[sma_syntaxdefdir]:= syntaxdefdir.value;
  macros[sma_templatedir]:= templatedir.value;
  macros[sma_compstoredir]:= compstoredir.value;
  macros[sma_compiler]:= compiler.value;
  macros[sma_debugger]:= debugger.value;
  macros[sma_exeext]:= exeext.value;
  macros[sma_target]:= target.value;
  macros[sma_targetosdir]:= targetosdir.value;
  globmacronames:= macroname.gridvalues;
  globmacrovalues:= macrovalue.gridvalues;
 end;
end;

procedure tsettingsfo.epandfilenamemacro(const sender: TObject;
               var avalue: msestring; var accept: Boolean);
var
 mac1: settingsmacrosty;
begin
 mac1:= widgetstomacros;
 avalue:= expandmacros(avalue,getsettingsmacros1(mac1));
end;

procedure tsettingsfo.setvalue(const sender: TObject; var avalue: msestring;
           var accept: Boolean);
begin
 if avalue = '' then begin
  avalue:= defaultsettingmacros[settingsmacroty(tcomponent(sender).tag)];
 end;
end;

procedure tsettingsfo.setprintcomm(const sender: TObject; var avalue: msestring;
                    var accept: Boolean);
begin
 if avalue = '' then begin
  avalue:= sys_getprintcommand;
 end;
end;

procedure tsettingsfo.editshortcuts(const sender: TObject);
begin
 shortcutdialog(fshortcutcontroller);
end;

end.
