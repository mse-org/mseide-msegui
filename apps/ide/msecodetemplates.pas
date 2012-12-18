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
name=thename
comment=Comment abcdefg HIKLMNO
params=3
 param1
 param2
 param3
noselect=1
cursorcol=12
cursorrow=1
[]
The Template Text with macros ${param1}
more text
${param2} ${param3} more params
"
If noselect=0 or not defined the templateblock will be selected in editor.
If noselect=1 the cursor will be placed at the offset by cursorcol, cursorrow.
If indent=1 the inserted block will be indented at cursor column
Minimal template file:
"
[header]
name=thename
[]
"
Parameters can be entered in editor:
"
thename,valueforparam1,valueforparam2
"
A dialog window will be displayed if there are more params defined than supplied
for param entry or if the template name can not be found.
*)

interface
uses
 msestrings,msehash,msemacros,msetypes,mseforms;
 
type
 templateinfoty = record
  name: msestring;  
  path: filenamety;
  comment: msestring;
  select: boolean;
  indent: boolean;
  cursorcol: integer;
  cursorrow: integer;
  params: msestringarty;
  paramdefaults: msestringarty;
  template: msestring;
  cursorpos: gridcoordty; //variable
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
                          out ainfo: templateinfoty): boolean;
                                     //true if ok
   procedure reload(const selectform: tmseform); //tmsetemplateselectfo
  public
   constructor create;
   destructor destroy; override;
   procedure initinfo(out ainfo: templateinfoty);
   procedure savefile(const ainfo: templateinfoty);
   procedure clear;
   procedure scan(const adirectories: filenamearty);
   function hastemplate(const aname: msestring): boolean;
   function gettemplate(const aname: msestring; out templatetext: msestring;                     
                        const amacrolist: tmacrolist = nil): ptemplateinfoty;
   property templates: templateinfoarty read finfos;
 end;
 
implementation
uses
 msefileutils,msesys,msestat,msestream,mseparamentryform,mseglob,msearrayutils,
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
 sortarray(finfos,sizeof(templateinfoty),@compitems);
 for int1:= 0 to high(finfos) do begin
  flist.add(finfos[int1].name,pointer(ptruint(int1)));
 end; 
end;

procedure tcodetemplates.initinfo(out ainfo: templateinfoty);
begin
 finalize(ainfo);
 fillchar(ainfo,sizeof(ainfo),0);
end;

function tcodetemplates.loadfile(const afilename: filenamety;
               out ainfo: templateinfoty): boolean;
var
 stat: tstatreader; 
begin
 result:= false;
 initinfo(ainfo);
 stat:= tstatreader.create(afilename,ce_utf8n);
 with stat,ainfo do begin
  if findsection('header') then begin
   name:= readmsestring('name','');
   if name <> '' then begin
    path:= afilename;
    comment:= readmsestring('comment','');
    select:= readboolean('select',false);
    indent:= readboolean('indent',false);
    cursorcol:= readinteger('cursorcol',0,0,1000);
    cursorrow:= readinteger('cursorrow',0,0,1000000);
    params:= readarray('params',msestringarty(nil));
    paramdefaults:= readarray('paramdefaults',msestringarty(nil));
    setlength(paramdefaults,length(params));
    template:= streamtext;
    result:= true;
   end;
  end;
 end;
 stat.free;
end;

procedure tcodetemplates.savefile(const ainfo: templateinfoty);
var
 stat: tstatwriter; 
begin
 stat:= tstatwriter.create(ainfo.path,ce_utf8n,true);
 with stat,ainfo do begin
  writesection('header');
  writemsestring('name',name);
  writemsestring('comment',comment);
  writeboolean('select',select);
  writeboolean('indent',indent);
  writeinteger('cursorcol',cursorcol);
  writeinteger('cursorrow',cursorrow);
  writearray('params',params);
  writearray('paramdefaults',paramdefaults);
  streamtext(template);
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
   splitstringquoted(aname,ar1,msechar('"'),msechar(','));
   result:= flist.find(ar1[0],po1);
  end;
 end;
end;

function tcodetemplates.gettemplate(const aname: msestring;
                        out templatetext: msestring;
                        const amacrolist: tmacrolist = nil): ptemplateinfoty;
var
 ar1: msestringarty;
 ar2: integerarty;
 puint1: ptruint;
 mac1: tmacrolist;
 fo: tmseparamentryfo;
 se: tmsetemplateselectfo;
 int1,int2: integer;
 bo1: boolean;
begin
 result:= nil;
 templatetext:= '';
 if aname <> '' then begin
  splitstringquoted(aname,ar1,msechar('"'),msechar(','));
 end
 else begin
  setlength(ar1,1);
 end;
 if (ar1[0] = '') or not flist.find(ar1[0],pointer(puint1),int1) or 
                                                         (int1 > 1) then begin
  se:= tmsetemplateselectfo.create(self);
  try
   reload(se);
   se.show;
   se.grid.setfocus;
   se.templatename.editor.filtertext:= ar1[0];
   if (se.show(true) <> mr_ok) or (se.grid.row < 0) or 
                                      (se.grid.row > high(finfos)) then begin
    exit;
   end;
   puint1:= se.grid.row;
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
  with finfos[puint1] do begin
   fo:= tmseparamentryfo.create(nil);
   try
    fo.caption:= fo.c[ord(codetemplate)]+name+'"';
    fo.comment.caption:= comment;
    fo.macroname.gridvalues:= params;
    fo.macrovalue.gridvalues:= paramdefaults;
    for int1:= 0 to high(params) do begin
     if int1 >= high(ar1) then begin
      break;
     end;
     fo.macrovalue[int1]:= ar1[int1+1];
    end;
    if high(ar1) <= high(params) then begin
     fo.grid.row:= high(ar1);
     bo1:= fo.show(true) = mr_ok;
    end;
    mac1.add(params,fo.macrovalue.gridvalues);         
   finally
    fo.free;
   end;
   if bo1 then begin
    result:= @finfos[puint1];
    cursorpos.col:= cursorcol;
    cursorpos.row:= cursorrow;
    if (cursorcol > 0) or (cursorrow > 0) then begin
     ar1:= breaklines(template);
     int2:= 0;
     for int1:= 0 to high(ar1) do begin
      if int1 >= cursorrow then begin
       break;
      end;
      int2:= int2 + length(ar1[int1]) + length(lineend);
     end;
     int2:= int2 + cursorcol;
     setlength(ar2,1);
     ar2[0]:= int2;
     templatetext:= concatstrings(ar1,lineend);
     mac1.expandmacros(templatetext,ar2);
     ar1:= breaklines(templatetext);
     int2:= ar2[0];
     for int1:= 0 to high(ar1) do begin
      int2:= int2 - (length(ar1[int1]) + length(lineend));
      if int2 < 0 then begin
       cursorpos.row:= int1;
       cursorpos.col:= int2 + (length(ar1[int1]) + length(lineend));
       break;
      end;
     end;
    end
    else begin
     templatetext:= template;
     mac1.expandmacros(templatetext);
    end;
   end;
  end;
 finally
  if mac1 <> amacrolist then begin
   mac1.free;
  end;
 end;
end;

procedure tcodetemplates.reload(const selectform: tmseform);
var
 se: tmsetemplateselectfo;
 int1,int2: integer;
 edit1: tstringedit;
begin
 se:= selectform as tmsetemplateselectfo;
 se.finfos:= finfos;
 se.grid.beginupdate;
 se.grid.clear;
 se.grid.rowcount:= length(finfos)+1;
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
end;

end.
