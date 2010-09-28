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
  comment: msestring;
  params: msestringarty;
  template: msestring;
 end;
 templateinfoarty = array of templateinfoty;
 
 tcodetemplates = class(tobject)
  private
   finfos: templateinfoarty;
   fmask: filenamety;
   flist: tpointermsestringhashdatalist;
  protected
   function loadfile(const afilename: filenamety;
                          const aindex: integer): boolean;
                                     //true if ok
  public
   constructor create;
   destructor destroy; override;
   procedure clear;
   procedure scan(const adirectories: filenamearty);
   function hastemplate(const aname: msestring): boolean;
   function gettemplate(const aname: msestring;
                              const amacrolist: tmacrolist = nil): msestring;
 end;
 
implementation
uses
 msefileutils,msesys,msestat,msestream,mseparamentryform,mseglob;
 
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
  if loadfile(ar1[int1],int2) then begin
   inc(int2);
  end;
 end;
 setlength(finfos,int2);
end;

function tcodetemplates.loadfile(const afilename: filenamety;
               const aindex: integer): boolean;
var
 stat: tstatreader; 
begin
 result:= false;
 stat:= tstatreader.create(afilename,ce_utf8n);
 with stat,finfos[aindex] do begin
  if findsection('header') then begin
   name:= readmsestring('name','');
   if name <> '' then begin
    comment:= readmsestring('comment','');
    params:= readarray('params',msestringarty(nil));
    template:= streamtext;
    flist.add(name,pointer(ptruint(aindex)));
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
                                const amacrolist: tmacrolist = nil): msestring;
var
 ar1: msestringarty;
 po1: pointer;
 mac1: tmacrolist;
 fo: tmseparamentryfo;
 int1: integer;
 bo1: boolean;
begin
 result:= '';
 if aname <> '' then begin
  splitstringquoted(aname,ar1,'"',',');
  if flist.find(ar1[0],po1) then begin
   bo1:= true;
   mac1:= amacrolist;
   if mac1 = nil then begin
    mac1:= tmacrolist.create([mao_caseinsensitive,mao_curlybraceonly]);
   end;
   try
    with finfos[ptruint(po1)] do begin
     fo:= tmseparamentryfo.create(nil);
     try
      fo.caption:= 'Code Template "'+ar1[0]+'"';
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
      result:= template;
      mac1.expandmacros(result);
     end;
    end;
   finally
    if mac1 <> amacrolist then begin
     mac1.free;
    end;
   end;
  end;
 end;
end;

end.
