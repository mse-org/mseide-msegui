{ MSEide Copyright (c) 1999-2010 by Martin Schreiber

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
unit regsysutils;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

implementation
uses
 msedesignintf,msesysenv,msefilechange,regsysutils_bmp,mseprocess,
 msecomponenteditors,mclasses,msesysenvmanagereditor,mseglob;
type
 tsysenvmanagereditor = class(tcomponenteditor)
  public
   constructor create(const adesigner: idesigner;
                           acomponent: tcomponent); override;
   procedure edit; override;
 end;

procedure Register;
begin
 registercomponents('NoGui',[tsysenvmanager,tfilechangenotifyer,tmseprocess]);
 registercomponenteditor(tsysenvmanager,tsysenvmanagereditor);
end;

{ tsysenvmanagereditor }

constructor tsysenvmanagereditor.create(const adesigner: idesigner;
               acomponent: tcomponent);
begin
 inherited;
 fstate:= fstate + [cs_canedit];
end;

procedure tsysenvmanagereditor.edit;
begin
 if editsysenvmanager(tsysenvmanager(fcomponent)) = mr_ok then begin
  fdesigner.componentmodified(fcomponent);
 end;
end;

initialization
 register;
end.
