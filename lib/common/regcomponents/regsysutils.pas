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
 msecomponenteditors,msepython,msestrings,
 sysutils,mclasses,msesysenvmanagereditor,mseglob,msepropertyeditors;
type
 tarrayelementeditor1 = class(tarrayelementeditor);
 
 tsysenvmanagereditor = class(tcomponenteditor)
  public
   constructor create(const adesigner: idesigner;
                           acomponent: tcomponent); override;
   procedure edit; override;
 end;

 tprocessoptionseditor = class(tsetpropertyeditor)
  protected
   function getinvisibleitems: tintegerset; override;
 end;

 tpythonscriptseditor = class(tpersistentarraypropertyeditor)
  protected
   function itemgetvalue(const sender: tarrayelementeditor): msestring
                                                                  override;
 end;
    
procedure Register;
begin
 registercomponents('NoGui',[tsysenvmanager,tfilechangenotifyer,tmseprocess,
                             tpythonscript]);
 registercomponenteditor(tsysenvmanager,tsysenvmanagereditor);
 registerpropertyeditor(typeinfo(processoptionsty),nil,'',
                                           tprocessoptionseditor);
 registerpropertyeditor(typeinfo(tpythonscripts),nil,'',
                                    tpythonscriptseditor);
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

{ tprocessoptionseditor }

function tprocessoptionseditor.getinvisibleitems: tintegerset;
begin
 result:= [ord(pro_nopipeterminate)];
end;

{ tpythonscriptseditor }

function tpythonscriptseditor.itemgetvalue(
              const sender: tarrayelementeditor): msestring;
begin
 with tpythonstringlistitem(
              tarrayelementeditor1(sender).getpointervalue) do begin
  result:= '<'+name+'>';
 end;
end;

initialization
 register;
end.
