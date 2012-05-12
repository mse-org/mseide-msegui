{ MSEtools Copyright (c) 1999-2006 by Martin Schreiber
   
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
program msei18n;
{$ifdef FPC}
 {$mode objfpc}{$h+}
 {$ifdef mswindows}{$apptype gui}{$endif}
{$endif}
{$ifdef mswindows}
 {$R msei18n.res}
{$endif}

uses
  {$ifdef FPC}{$ifdef unix}cthreads,{$endif}{$endif}msegui,
  main,messagesform,project;

begin
 application.createForm(tmainfo,mainfo);
 application.createForm(tmessagesfo,messagesfo);
 application.run;
end.
 
