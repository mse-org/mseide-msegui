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
unit project;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 mseforms,msewidgetgrid,msefiledialog,msestat,msestatfile,msegraphedits,
 msedataedits,msesimplewidgets,msesplitter,msegui,msestrings,msedbedit,msegrids,
 msetypes,mseedit,mseglob,mseguiglob,mseifiglob,msemenus,msememodialog;

type
 tprojectfo = class(tmseform)
   projectstat: tstatfile;
   grid: twidgetgrid;
   filename: tfilenameedit;
   filekind: tenumtypeedit;
   datafilename: tfilenameedit;
   impexpfiledialog: tfiledialog;
   grid2: twidgetgrid;
   lang: tstringedit;
   dir: tdirdropdownedit;
   rootname: tstringedit;
   splitter: tsplitter;
   makecommand: tmemodialogedit;
   makeon: tbooleanedit;
   ok: tbutton;
   cancel: tbutton;
   impexpencoding: tenumtypeedit;
   destname: tstringedit;
   beforemake: tmemodialogedit;
   aftermake: tmemodialogedit;
   procedure projectstatonupdatestat(const sender: TObject;
                      const filer: tstatfiler);
   procedure projectstatonafterreadstat(const sender: tobject);
   procedure filekindoninit(const sender: tenumtypeedit);
   procedure childscaled(const sender: TObject);
   procedure showhintexe(const sender: TObject; var info: hintinfoty);
   procedure makecommandsetvalue(const sender: TObject;
                 var avalue: msestring; var accept: Boolean);
   procedure impexpencinit(const sender: tenumtypeedit);
   procedure langdeleted(const sender: tcustomgrid; const aindex: integer;
                 const acount: integer);
   procedure projectstatonbeforewritestat(const sender: TObject);
   procedure filenamedataentered(const sender: TObject);
  public
 //  colwidths: integerarty;
 end;

var
 projectfo: tprojectfo;

implementation

uses
 main,project_mfm,msesysenv,msesettings,msestream,msemacros;
const
 defaultmakecommand = '${COMPILER} -Fu${MSELIBDIR}i18n -FE.. -FU. ${LIBFILE}';

procedure tprojectfo.filekindoninit(const sender: tenumtypeedit);
begin
 tenumtypeedit(sender).typeinfopo:= typeinfo(resfilekindty);
end;

procedure tprojectfo.projectstatonbeforewritestat(const sender: TObject);
//var
// int1: integer;
begin
{
 setlength(colwidths,mainfo.grid.datacols.count - variantshift);
 for int1:= 0 to high(colwidths) do begin
  colwidths[int1]:= mainfo.grid.datacols[int1+variantshift].width;
 end;
}
end;

procedure tprojectfo.projectstatonupdatestat(const sender: TObject;
                     const filer: tstatfiler);
var
 int1: integer;
begin
 int1:= mainfo.grid.datacols.count;
 filer.updatevalue('colcount',int1);
 mainfo.grid.datacols.count:= int1+variantshift;
end;

procedure tprojectfo.projectstatonafterreadstat(const sender: tobject);
//var
// int1: integer;
begin
 try
  mainfo.loadproject;
 except
  application.handleexception(nil);
 end;
 {
 for int1:= 0 to high(colwidths) do begin
  if int1 >= mainfo.grid.datacols.count + variantshift then begin
   break;
  end;
  mainfo.grid.datacols[int1+variantshift].width:= colwidths[int1];
 end;
}
end;

procedure tprojectfo.childscaled(const sender: TObject);
begin
 placeyorder(0,[0,0,2,0,0,0,0,4],[datafilename,destname,
                  beforemake,makecommand,aftermake,
                  grid,splitter,grid2,ok],4);
 aligny(wam_center,[makecommand,makeon]);
 aligny(wam_center,[ok,cancel,impexpencoding]);
end;

procedure tprojectfo.showhintexe(const sender: TObject; var info: hintinfoty);
begin
 info.caption:= expandmacros(makecommand.value,getsyssettingsmacros);
end;

procedure tprojectfo.makecommandsetvalue(const sender: TObject;
           var avalue: msestring; var accept: Boolean);
begin
 if avalue = '' then begin
  avalue:= defaultmakecommand;
 end;
end;

procedure tprojectfo.impexpencinit(const sender: tenumtypeedit);
begin
 sender.typeinfopo:= typeinfo(charencodingty);
end;

procedure tprojectfo.langdeleted(const sender: tcustomgrid; const aindex: integer;
                    const acount: integer);
begin
 rootnode.deletelang(aindex);
end;

procedure tprojectfo.filenamedataentered(const sender: TObject);
begin
 rootname.value:= '';
end;

end.
