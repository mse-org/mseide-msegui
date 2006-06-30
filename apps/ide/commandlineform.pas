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
unit commandlineform;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msedataedits;
 
type

 tcommandlinefo = class(tmseform)
   disp: tmemoedit;
 end;

procedure showcommandline;

implementation
uses
 commandlineform_mfm,make,projectoptionsform;

procedure showcommandline;
var
 fo: tcommandlinefo;
begin
 fo:= tcommandlinefo.create(nil);
 try
  if projectoptions.defaultmake >= maxdefaultmake then begin
   fo.disp.value:= 'Make disabled by Default make col!';
  end
  else begin
   fo.disp.value:= buildmakecommandline(projectoptions.defaultmake);
  end;
  fo.show(true);
 finally
  fo.Free;
 end;
end;

end.                                                                    
