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
unit sourcehintform;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses
 msegui,mseclasses,mseforms,mseedit,msegraphutils;

type
 stringeditarty = array of tedit;
 tsourcehintfo = class(tmseform)
   procedure sourcehintfoonclose(const sender: TObject);
   procedure formonresize(const sender: TObject);
  public
   dispar: stringeditarty;
 end;

implementation
uses
 sourceform,sourcehintform_mfm;
 
procedure tsourcehintfo.sourcehintfoonclose(const sender: TObject);
begin
 sourcefo.hintsize:= size;
end;

procedure tsourcehintfo.formonresize(const sender: TObject);
var
 int1,int3: integer;
begin
 int3:= 0;
 for int1:= 0 to high(dispar) do begin
  dispar[int1].clientheight:= dispar[int1].editor.textrect.cy + 2;
  inc(int3,dispar[int1].bounds_cy);
 end;
 placeyorder(0,[0],widgetarty(dispar));
 bounds_cymax:= int3;
end;

end.
