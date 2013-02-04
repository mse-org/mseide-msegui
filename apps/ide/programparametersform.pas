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
unit programparametersform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msestat,mseglob,msestatfile,msesimplewidgets,msedataedits,msefiledialog,
 msewidgetgrid,msegraphedits,msememodialog,msegui,msestrings;

type
 tprogramparametersfo = class(tmseform)

   ok: tbutton;
   envvaron: tbooleanedit;
   tbutton2: tbutton;
   parameters: tmemodialoghistoryedit;
   statfile1: tstatfile;
   envvarname: tstringedit;
   envvarvalue: tmemodialogedit;
   grid: twidgetgrid;
   workingdirectory: tfilenameedit;
   procedure hintexpandedmacros(const sender: TObject; var info: hintinfoty);
   procedure expandfilename(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
 end;

procedure editprogramparameters;
procedure updatestat(const filer: tstatfiler);

implementation
uses
 programparametersform_mfm,projectoptionsform,mseguiglob,mseedit;

procedure editprogramparameters;
var
 fo: tprogramparametersfo;
begin
 fo:= tprogramparametersfo.create(nil);
 try
  with projectoptions,d.t do begin
   fo.parameters.value:= progparameters;
   fo.parameters.dropdown.valuelist.asarray:= propgparamhistory;
   fo.workingdirectory.value:= progworkingdirectory;
   fo.envvaron.gridvalues:= envvarons;
   fo.envvarname.gridvalues:= envvarnames;
   fo.envvarvalue.gridvalues:= envvarvalues;
  end;
  if fo.show(true,nil) = mr_ok then begin
   fo.grid.removeappendedrow;
   with projectoptions,d.t do begin
    progparameters:= fo.parameters.value;
    propgparamhistory:= fo.parameters.dropdown.valuelist.asarray;
    progworkingdirectory:= fo.workingdirectory.value;
    envvarons:= fo.envvaron.gridvalues;
    envvarnames:= fo.envvarname.gridvalues;
    envvarvalues:= fo.envvarvalue.gridvalues;
   end;
   expandprojectmacros;
  end;
 finally
  fo.Free;
 end;
end;

procedure updatestat(const filer: tstatfiler);
begin
 filer.setsection('progparams');       //backward  compatibility
 with projectoptions,d,tstatreader(filer) do begin
  if not filer.iswriter then begin
   with t do begin
    progparameters:= readstring('parameters',progparameters);
//   progparamhistory:= readarray('progparamhistory',propgparamhistory);
    progworkingdirectory:= readstring('workingdirectory',progworkingdirectory);
//    envvarons:= readarray('envvarons',envvarons);
    envvarnames:= readarray('envvarnames',envvarnames);
    envvarvalues:= readarray('envvarvalues',envvarvalues);
   end;
  end;
  
//   filer.updatevalue('parameters',progparameters);
  filer.updatevalue('progparamhistory',propgparamhistory);
//   filer.updatevalue('workingdirectory',progworkingdirectory);
  filer.updatevalue('envvarons',envvarons);
 //  filer.updatevalue('envvarnames',envvarnames);
//   filer.updatevalue('envvarvalues',envvarvalues);
 end;
end;

procedure tprogramparametersfo.hintexpandedmacros(const sender: TObject;
               var info: hintinfoty);
begin
 info.caption:= tcustomedit(sender).text;
 expandprmacros1(info.caption);
 include(info.flags,hfl_show); //show empty caption
end;

procedure tprogramparametersfo.expandfilename(const sender: TObject;
               var avalue: msestring; var accept: Boolean);
begin
 expandprmacros1(avalue);
end;

end.
