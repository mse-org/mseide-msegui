{ MSEide Copyright (c) 2010 by Martin Schreiber

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
unit mseparamentryform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msesimplewidgets,
 msewidgets,msedataedits,mseedit,msegrids,msestrings,msetypes,msewidgetgrid,
 msememodialog,msesplitter,msestatfile,msestringcontainer;
type
 strinconsts = (
  codetemplate   //0 Code Template "
 );
 
 tmseparamentryfo = class(tmseform)
   grid: twidgetgrid;
   macroname: tstringedit;
   macrovalue: tmemodialogedit;
   tsplitter1: tsplitter;
   tbutton2: tbutton;
   tbutton1: tbutton;
   comment: tlabel;
   tstatfile1: tstatfile;
   c: tstringcontainer;
 end;
var
 mseparamentryfo: tmseparamentryfo;
implementation
uses
 mseparamentryform_mfm;
end.
