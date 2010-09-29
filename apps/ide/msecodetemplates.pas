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
unit msecodetemplates;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

(*
Extension for template files is *.mct
Example of a template file:
"
[header]
name=test
comment=Comment abcdefg HIKLMNO
params=3
 param1
 param2
 param3
[]
The Template Text with macros ${param1}
more text
${param2} ${param3} more params
"
Minimal template file:
"
[header]
name=test
[]
"
Parameters can be entered in editor:
"
test,valueforparam1,valueforparam2
"
If there are more params defined than supplied a dialog window will be showed
for param entry.
*)

interface
uses
 msestrings,msehash,msesysenv;
 
type
 templateinfoty = record
  name: msestring;  
  path: filenamety;
  comment: msestring;
  params: msestringarty;
  template: msestring;
 end;
 ptemplateinfoty = ^templateinfoty;
 templateinfoarty = array of templateinfoty;
 
 tcodetemplates = class(tobject)
  private
   finfos: templateinfoarty;
   fmask: filenamety;
   flist: tpointermsestringhashdatalist;
  protected
   function loadfile(const afilename: filenamety;
                          var ainfo: templateinfoty): boolean;
                                     //true if ok
  public
   constructor create;
   destructor destroy; override;
   procedure clear;
   procedure scan(const adirectories: filenamearty);
   function hastemplate(const aname: msestring): boolean;
   function gettemplate(const aname: msestring; out templatetext: msestring;                     
                        const amacrolist: tmacrolist = nil): ptemplateinfoty;
 end;
 
implementation
uses
 msefileutils,msesys,msestat,msestream,mseparamentryform,mseglob,msedatalist,
 msetemplateselectform,msedataedits;
 
{ tcodetemplates }

constructor tcodetemplates.create;
begin
 fmask:= '*.mct';
 flist:= tpointermsestringhashdatalist.create;
 inherited;
end;

destructor tcodetemplates.destroy;
begin
 clear;
 flist.free;
 inherited;
end;

procedure tcodetemplates.clear;
begin
 finfos:= nil;
 flist.clear;
end;

function compitems(const l,r): integer;
begin
 result:= msecomparetext(templateinfoty(l).name,templateinfoty(r).name);
end;

procedure tcodetemplates.scan(const adirectories: filenamearty);
var
 int1,int2: integer;
 ar1: filenamearty;
begin
 clear;
 ar1:= searchfiles(fmask,adirectories);
 int2:= 0;
 for int1:= 0 to high(ar1) do begin
  if high(finfos) < int2 then begin
   setlength(finfos,int2*2+16);
  end;
  if loadfile(ar1[int1],finfos[int2]) then begin
   inc(int2);
  end;
 end;
 setlength(finfos,int2);
 sortarray(finfos,@compitems,sizeof(templateinfoty));
 for int1:= 0 to high(finfos) do begin
  flist.add(finfos[int1].name,pointer(ptruint(int1)));
 end; 
end;

function tcodetemplates.loadfile(const afilename: filenamety;
               var ainfo: templateinfoty): boolean;
var
 stat: tstatreader; 
begin
 result:= false;
 finalize(ainfo);
 fillchar(ainfo,sizeof(ainfo),0);
 stat:= tstatreader.create(afilename,ce_utf8n);
 with stat,ainfo do begin
  if findsection('header') then begin
   name:= readmsestring('name','');
   if name <> '' then begin
    path:= afilename;
    comment:= readmsestring('comment','');
    params:= readarray('params',msestringarty(nil));
    template:= streamtext;
    result:= true;
   end;
  end;
 end;
 stat.free;
end;

function tcodetemplates.hastemplate(const aname: msestring): boolean;
var
 po1: pointer;
 ar1: msestringarty;
begin
 result:= false;
 if aname <> '' then begin
  result:= flist.find(aname,po1);
  if not result then begin
   splitstringquoted(aname,ar1,'"',',');
   result:= flist.find(ar1[0],po1);
  end;
 end;
end;

function tcodetemplates.gettemplate(const aname: msestring;
                        out templatetext: msestring;
                        const amacrolist: tmacrolist = nil): ptemplateinfoty;
var
 ar1: msestringarty;
 po1: ptruint;
 mac1: tmacrolist;
 fo: tmseparamentryfo;
 se: tmsetemplateselectfo;
 int1,int2: integer;
 bo1: boolean;
 edit1: tstringedit;
begin
 result:= nil;
 templatetext:= '';
 if aname <> '' then begin
  splitstringquoted(aname,ar1,'"',',');
 end
 else begin
  setlength(ar1,1);
 end;
 if (ar1[0] = '') or not flist.find(ar1[0],pointer(po1)) then begin
  se:= tmsetemplateselectfo.create(nil);
  try
   se.finfos:= finfos;
   se.grid.beginupdate;
   se.grid.rowcount:= length(finfos);
   for int1:= 0 to high(finfos) do begin
    with finfos[int1] do begin
     se.templatename[int1]:= name;
     se.comment[int1]:= comment;
     for int2:= 0 to high(params) do begin
      edit1:= tstringedit(se.grid.findtagwidget(int2+1,tstringedit));
      if edit1 <> nil then begin
       edit1[int1]:= params[int2];
      end;
     end;
    end;
   end;
   se.grid.endupdate;
   se.show;
   se.grid.setfocus;
   se.templatename.editor.filtertext:= ar1[0];
   if (se.show(true) <> mr_ok) or (se.grid.row < 0) then begin
    exit;
   end;
   po1:= se.grid.row;
  finally
   se.free;
  end;
 end;
 bo1:= true;
 mac1:= amacrolist;
 if mac1 = nil then begin
  mac1:= tmacrolist.create([mao_caseinsensitive,mao_curlybraceonly]);
 end;
 try
  with finfos[po1] do begin
   fo:= tmseparamentryfo.create(nil);
   try
    fo.caption:= 'Code Template "'+name+'"';
    fo.comment.caption:= comment;
    fo.macroname.gridvalues:= params;
    for int1:= 0 to high(params) do begin
     if int1 >= high(ar1) then begin
      break;
     end;
     fo.macrovalue[int1]:= ar1[int1+1];
    end;
    if high(ar1) <= high(params) then begin
     bo1:= fo.show(true) = mr_ok;
    end;
    mac1.add(params,fo.macrovalue.gridvalues);         
   finally
    fo.free;
   end;
   if bo1 then begin
    result:= @finfos[ptruint(po1)];
    templatetext:= template;
    mac1.expandmacros(templatetext);
   end;
  end;
 finally
  if mac1 <> amacrolist then begin
   mac1.free;
  end;
 end;
end;

end.
