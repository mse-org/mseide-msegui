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
program mseide;
{$ifdef FPC}
 {$mode objfpc}{$h+}{$INTERFACES CORBA}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}
uses
{$ifdef FPC}{$ifdef linux}
  cthreads,
{$endif}{$endif}
  msegui,msegraphics,mseguiintf,msestockobjects,
  main in 'main.pas',
  debuggerform in 'debuggerform.pas',
  debuggerform_mfm in 'debuggerform_mfm.pas',
  componentpaletteform in 'componentpaletteform.pas',
  componentpaletteform_mfm in 'componentpaletteform_mfm.pas',
  messageform in 'messageform.pas',
  messageform_mfm in 'messageform_mfm.pas',
  panelform in 'panelform.pas',
  panelform_mfm in 'panelform_mfm.pas',
  sourceform in 'sourceform.pas',
  sourceform_mfm in 'sourceform_mfm.pas',
  sourcepage in 'sourcepage.pas',
  sourcepage_mfm in 'sourcepage_mfm.pas',
  make in 'make.pas',
  watchform in 'watchform.pas',
  stackform in 'stackform.pas',
  stackform_mfm in 'stackform_mfm.pas',
  breakpointsform in 'breakpointsform.pas',
  watchpointsform in 'watchpointsform.pas',
  watchpointsform_mfm in 'watchpointsform_mfm.pas',
  projectoptionsform in 'projectoptionsform.pas',
  projectoptionsform_mfm in 'projectoptionsform_mfm.pas',
  projecttreeform in 'projecttreeform.pas',
  projecttreeform_mfm in 'projecttreeform_mfm.pas',
  finddialogform in 'finddialogform.pas',
  finddialogform_mfm in 'finddialogform_mfm.pas',
  findinfileform in 'findinfileform.pas',
  findinfileform_mfm in 'findinfileform_mfm.pas',
  findinfilepage in 'findinfilepage.pas',
  findinfilepage_mfm in 'findinfilepage_mfm.pas',
  findinfiledialogform in 'findinfiledialogform.pas',
  findinfiledialogform_mfm in 'findinfiledialogform_mfm.pas',
  sourceupdate in 'sourceupdate.pas',
  pascaldesignparser in 'pascaldesignparser.pas',
  selectsubmoduledialogform in 'selectsubmoduledialogform.pas',
  selectsubformdialogform_mfm in 'selectsubformdialogform_mfm.pas',
  main_mfm in 'main_mfm.pas',
  breakpointsform_mfm in 'breakpointsform_mfm.pas',
  designer_bmp in 'designer_bmp.pas',
  formdesigner_mfm in 'formdesigner_mfm.pas',
  objectinspector in 'objectinspector.pas',
  objectinspector_mfm in 'objectinspector_mfm.pas',
  actionsmodule in 'actionsmodule.pas',
  selecteditpageform in 'selecteditpageform.pas',
  selecteditpageform_mfm in 'selecteditpageform_mfm.pas',
  settaborderform in 'settaborderform.pas',
  settaborderform_mfm in 'settaborderform_mfm.pas',
  programparametersform in 'programparametersform.pas',
  cpuform in 'cpuform.pas',
  cpuform_mfm in 'cpuform_mfm.pas',
  disassform in 'disassform.pas',
  disassform_mfm in 'disassform_mfm.pas',
  skeletons in 'skeletons.pas',
  threadsform in 'threadsform.pas',
  threadsform_mfm in 'threadsform_mfm.pas',
  commandlineform in 'commandlineform.pas',
  commandlineform_mfm in 'commandlineform_mfm.pas',
  sourcehintform in 'sourcehintform.pas',
  sourcehintform_mfm in 'sourcehintform_mfm.pas',
  targetconsole in 'targetconsole.pas',
  targetconsole_mfm in 'targetconsole_mfm.pas';

begin
 registerfontalias('mseide_source',gui_getdefaultfontnames[stf_courier],
                    fam_fixnooverwrite,16);
 application.createdatamodule(tactionsmo,actionsmo);
 application.createform(tsourcefo, sourcefo);
 application.createform(tdebuggerfo,debuggerfo);
 application.createform(tcomponentpalettefo,componentpalettefo);
 application.createform(tmessagefo,messagefo);
 application.createform(twatchfo, watchfo);
 application.createform(tobjectinspectorfo, objectinspectorfo);
 application.createform(tbreakpointsfo, breakpointsfo);
 application.createform(twatchpointsfo, watchpointsfo);
 application.createform(tstackfo, stackfo);
 application.createform(tprojecttreefo, projecttreefo);
 application.createform(tfindinfilefo, findinfilefo);
 application.createform(tcpufo, cpufo);
 application.createform(tdisassfo, disassfo);
 application.createform(tthreadsfo, threadsfo);
 application.createform(ttargetconsolefo,targetconsolefo);
 application.createform(tmainfo, mainfo);
 application.run;
end.
