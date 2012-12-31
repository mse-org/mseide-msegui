{ MSEide Copyright (c) 2002-2008 by Martin Schreiber
   
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
 msesys,msetypes,msegraphics,msewidgets,mseactions,mseifiglob,msesplitter;

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
  defaultsettingmacros: array[settingsmacroty] of msestring = (
                 '','','','${MSEDIR}lib/common/','${MSEDIR}apps/ide/syntaxdefs/',
                 '${MSEDIR}apps/ide/templates/','${MSEDIR}apps/ide/compstore/',
                 'ppc386','gdb','','i386-linux','linux');
  {$endif}
 {$endif}
                
type
 settingsmacrosty = array[settingsmacroty] of filenamety;
 settingsty = record
  macros: settingsmacrosty;
  printcommand: string;
 end;
  
 tsettingsfo = class(tmseform)
   tbutton1: tbutton;
   tbutton2: tbutton;
   templatedir: tfilenameedit;
   fpcdir: tfilenameedit;
   msedir: tfilenameedit;
   compiler: tfilenameedit;
   debugger: tfilenameedit;
   syntaxdefdir: tfilenameedit;
   mselibdir: tfilenameedit;
   fpclibdir: tfilenameedit;
   tstatfile1: tstatfile;
   exeext: tstringedit;
   target: tstringedit;
   printcomm: tstringedit;
   compstoredir: tfilenameedit;
   shortcutbu: tbutton;
   targetosdir: tstringedit;
   tsplitter2: tsplitter;
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
function getprintcommand: string;
function editsettings(const acaption: msestring = '';
                           const shortcuts: tshortcutcontroller = nil): boolean;
 
implementation
uses
 msesettings_mfm,classes,msesysintf,msefileutils,mseshortcutdialog;
 
function getsettingsmacros1(const amacros: settingsmacrosty): macroinfoarty;
var
 ma1: settingsmacroty;
begin
 setlength(result,ord(high(settingsmacroty))+1);
 for  ma1:= low(settingsmacroty) to high(settingsmacroty) do begin
  result[ord(ma1)].name:= settingsmacronames[ma1]; 
  result[ord(ma1)].value:= amacros[ma1];
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
 
function getprintcommand: string;
begin
 result:= settings.printcommand;
end;

procedure updatesettings(const filer: tstatfiler);
var
 ma1: settingsmacroty;
begin
 with settings do begin
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
 with settings do begin
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
 end;
end;

function tsettingsfo.widgetstomacros: settingsmacrosty;
begin
 result[sma_fpcdir]:= fpcdir.value;
 result[sma_fpclibdir]:= fpclibdir.value;
 result[sma_msedir]:= msedir.value;
 result[sma_mselibdir]:= mselibdir.value;
 result[sma_syntaxdefdir]:= syntaxdefdir.value;
 result[sma_templatedir]:= templatedir.value;
 result[sma_compstoredir]:= compstoredir.value;
 result[sma_compiler]:= compiler.value;
 result[sma_debugger]:= debugger.value;
 result[sma_exeext]:= exeext.value;
 result[sma_target]:= target.value;
 result[sma_targetosdir]:= targetosdir.value;
end;

procedure tsettingsfo.epandfilenamemacro(const sender: TObject;
               var avalue: msestring; var accept: Boolean);
begin
 avalue:= expandmacros(avalue,getsettingsmacros1(widgetstomacros));
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
