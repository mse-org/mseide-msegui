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
unit regmm;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 mseaudio,msedesignintf,msesigaudio,msemidi,msesigmidi,msespeak;
 
procedure register;
begin
 registercomponents('MM',[taudioout,tmidisource,tespeakng]);
 registercomponenttabhints(['MM'],['Multimedia components (experimental).']);
 registercomponents('Math',[tsigoutaudio,tsigmidiconnector,tsigmidisource]);
end;

initialization
 register;
end.
