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
unit skeletons;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msestream,mseclasses;

procedure programskeleton(const stream: ttextstream; const name: string);
procedure unitskeleton(const stream: ttextstream; const name: string);
procedure formskeleton(const stream: ttextstream; const unitname,formname,ancestor: string);

implementation
const
 defaults = compilerdefaults;
  
procedure programskeleton(const stream: ttextstream; const name: string);
begin
 with stream do begin
  writeln('program '+name+';');
  writeln(defaults);
  writeln('{$ifdef FPC}');
  writeln(' {$ifdef mswindows}{$apptype gui}{$endif}');
  writeln('{$endif}');

  writeln('uses');
  writeln(
' {$ifdef FPC}{$ifdef unix}cthreads,{$endif}{$endif}msegui,mseforms,main;');
  writeln('begin');
  writeln(' application.createform(tmainfo,mainfo);');
  writeln(' application.run;');
  writeln('end.');
 end;
end;

procedure unitskeleton(const stream: ttextstream; const name: string);
begin
 with stream do begin
  writeln('unit '+name+';');
  writeln(defaults);
  writeln('interface');
  writeln('implementation');
  writeln('end.');
 end;
end;

procedure formskeleton(const stream: ttextstream; const unitname,formname,ancestor: string);
begin
 with stream do begin
  writeln('unit '+unitname+';');
  writeln(defaults);
  writeln('interface');
  writeln('uses');
  writeln(' msegui,mseclasses,mseforms,msedatamodules;');
  writeln('');
  writeln('type');
  writeln(' t'+formname+' = class('+ancestor+')');
  writeln(' end;');
  writeln('var');
  writeln(' '+formname+': '+'t'+formname+';');
  writeln('implementation');
  writeln('uses');
  writeln(' '+unitname+'_mfm;');
  writeln('end.');
 end;
end;

end.
