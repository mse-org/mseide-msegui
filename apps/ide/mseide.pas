{ MSEide Copyright (c) 1999-2007 by Martin Schreiber
   
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
 {$ifdef mswindows}
  {$ifdef mse_debug}{$apptype console}{$else}{$apptype gui}{$endif}
 {$endif}
{$endif}
uses
{$ifdef FPC}{$ifdef linux}
  cthreads,
{$endif}{$endif}
  msegui,msegraphics,actionsmodule,sourceform,debuggerform,
  componentpaletteform,componentstore,
  messageform,watchform,objectinspector,breakpointsform,watchpointsform,
  stackform,projecttreeform,findinfileform,cpuform,disassform,threadsform,
  targetconsole,main,mseguiintf,msestockobjects,regunitgroups,guitemplates,
  msegraphutils;
begin
 registerfontalias('mseide_source',gui_getdefaultfontnames[stf_courier],
                    fam_fixnooverwrite,16);
 application.createdatamodule(tguitemplatesmo,guitemplatesmo);
 application.createdatamodule(tactionsmo,actionsmo);
 application.createform(tsourcefo, sourcefo);
 application.createform(tdebuggerfo,debuggerfo);
 application.createform(tcomponentpalettefo,componentpalettefo);
 application.createform(tcomponentstorefo,componentstorefo);
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
