{ MSEide Copyright (c) 1999-2016 by Martin Schreiber
   
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
unit sourceupdate;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}
uses
 msedesigner,mseclasses,msedesignintf,classes,mclasses,typinfo,
 msetypes,msestrings,pascaldesignparser,cdesignparser,mseglob,
 msestream,mseparser,msesyntaxedit,mselist,msehash,msedesignparser;

const
 procheaderbreakchars = '(;';
type  
 unitinfoaty = array[0..0] of tunitinfo;
 punitinfoaty = ^unitinfoaty;
// unitinfopoarty = array of punitinfoty;

 tfilenameinfo = class
  private
   funits: unitinfopoarty;
  public
   procedure addunitinfo(ainfo: punitinfoty);
 end;

 tfilenamelist = class(tobjectmsestringhashdatalist)
  public
   procedure add(const key: filenamety; info: punitinfoty);
   function find(const key: filenamety): tfilenameinfo;
   procedure sourcefilemodified(key: filenamety);
 end;

 tunitinfolist = class(tobjectqueue)
  private
//   fnamelist: thashedstrings;
   fnamelist: tpointeransistringhashdatalist;
  protected
   function getitempo(const index: integer): punitinfoty;
  public
   constructor create;
   destructor destroy; override;
   procedure clear; override;
   function datapo: punitinfoaty; reintroduce;
   function newitem(const lang: proglangty): punitinfoty;
   property itempo[const index: integer]: punitinfoty read getitempo; default;
   function finditembyformfilename(const afilename: filenamety): punitinfoty;
   function finditembysourcefilename(const afilename: filenamety;
                       var filenum: integer): punitinfoty;
   function finditembyunitname(const aname: string): punitinfoty;
 end;

 tsourceupdater = class(tnullinterfacedobject,idesignnotification)
  private
   fdesigner: tdesigner;
   funitinfolist: tunitinfolist;
   ffilenamelist: tfilenamelist;
   falphabeticprocorder: boolean;
   fmaxlinelength: integer;
  protected
   //idesignnotification
   procedure itemdeleted(const adesigner: idesigner;
                const amodule: tmsecomponent; const aitem: tcomponent);
   procedure iteminserted(const adesigner: idesigner;
                const amodule: tmsecomponent; const aitem: tcomponent);
   procedure itemsmodified(const adesigner: idesigner; const aitem: tobject);
                       //nil for undefined aitem
   procedure componentnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const aitem: tcomponent;
                     const newname: string);
   procedure moduleclassnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
   procedure instancevarnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
   procedure selectionchanged(const adesigner: idesigner;
                const aselection: idesignerSelections);
   procedure moduleactivated(const adesigner: idesigner;
                           const amodule: tmsecomponent);
   procedure moduledeactivated(const adesigner: idesigner;
                           const amodule: tmsecomponent);
   procedure moduledestroyed(const adesigner: idesigner;
                           const amodule: tmsecomponent);
   procedure methodcreated(const adesigner: idesigner;
                           const amodule: tmsecomponent;
                           const aname: string; const atype: ptypeinfo);
   procedure methodnamechanged(const adesigner: idesigner;
                          const amodule: tmsecomponent;
                          const newname,oldname: string;
                          const atypeinfo: ptypeinfo);
   procedure showobjecttext(const adesigner: idesigner;
                   const afilename: filenamety; const backupcreated: boolean);
   procedure closeobjecttext(const adesigner: idesigner;
                    const afilename: filenamety; var cancel: boolean);
   procedure beforefilesave(const adesigner: idesigner;
                                    const afilename: filenamety);
   procedure beforemake(const adesigner: idesigner; const maketag: integer;
                         var abort: boolean);
   procedure aftermake(const adesigner: idesigner; const exitcode: integer);

   procedure getincludefile(const sender: tparser; const scanner: tscanner);
   procedure updatepascalunit(const infopo: punitinfoty;
                          const interfaceonly: boolean); overload;
   procedure updatecunit(const infopo: punitinfoty;
                          const interfaceonly: boolean); overload;
   procedure updateunit(const infopo: punitinfoty;
                          const interfaceonly: boolean); overload;
   function composeproceduretext(const name: string; const info: methodparaminfoty;
                                 const withdefault: boolean): string; overload;
   function composeprocedureheader(const name: string;
                 const info: methodparaminfoty; const withdefault: boolean;
                                       const classproc: boolean): string; overload;
   function composeprocedureheader(const infopo: pprocedureinfoty;
                                 const classinfopo: pclassinfoty;
                                 const withdefault: boolean): string; overload;
   function composeprocedureheader(const name: string; const typeinfo: ptypeinfo;
                                 const withdefault: boolean;
                                 const classproc: boolean): string; overload;
   procedure createmethodbody(const unitinfopo: punitinfoty;
                const classinfopo: pclassinfoty; const aname: string;
                const atype: ptypeinfo; beforeitem: integer);
   function createscratchfile(const origname: filenamety): ttextstream;
   function updateline(module: punitinfoty; var apos: sourceposty): boolean; overload;
   function updateline(module: punitinfoty; var apos: sourceposty;
                  const afilename: filenamety): boolean; overload;
                  //calculates absolute line number from includefiles,
                  //false if invalid
   procedure updateincludefilenum(module: punitinfoty;
                  const filename: filenamety; var filenum: integer);

   function findsourceitem1(const infopo: punitinfoty; const apos: sourceposty;
                                  out scope: tdeflist): pdefinfoty;
   procedure checkitemlist(const infopo: punitinfoty);
   function findsourceitem(const infopo: punitinfoty;
                const apos: sourceposty): psourceitemty; overload;
   function findsourceitem(const infopo: punitinfoty; const apos: sourceposty;
                             out aindex: integer): psourceitemty; overload;
   function getidentpath(const infopo: punitinfoty; const apos: sourceposty;
                         const firstidentuse: boolean;
                               out scope: tdeflist): stringarty; overload;
   function getidentpath(const parser: tpascalparser): stringarty; overload;
   function switchheaderimplementation(const infopo: punitinfoty;
                                    var headerstart,headerstop: sourceposty;
                                       out isimplementation: boolean): boolean;
   function completeclass(const infopo: punitinfoty;
                      const pos: sourceposty): boolean; //true if changed
   procedure sourcechanged(const filename: filenamety);
   function listprocheaders(const infopo: punitinfoty;
                   const apos: sourceposty): procedureinfopoarty;
   function listsourceitems(const infopo: punitinfoty;
                   const apos: sourceposty; out scopes: deflistarty;
                     out defs: definfopoarty;
                     const maxcount: integer = 100): boolean;
  public
   constructor create(const adesigner: tdesigner);
   destructor destroy; override;
   procedure clear;

   procedure unitchanged(const aunit: punitinfoty = nil); overload;
   procedure unitchanged(const asourcefilename: filenamety); overload;
   procedure resetunitsearched; //resets all allreadysearchedflags of rootdeflists

   function updateunitinterface(const aunitname: string): punitinfoty;
   function updatemodule(const amodule: tmsecomponent): punitinfoty;
   function updateformunit(const aformfilename: filenamety;
                          const interfaceonly: boolean): punitinfoty;
   function updatesourceunit(const asourcefilename: filenamety;
                out filenum: integer; const interfaceonly: boolean): punitinfoty;

   function gettext(const infopo: punitinfoty;
                          const startpos,endpos: sourceposty): msestring;
   procedure replacetext(const infopo: punitinfoty; 
              const startpos,endpos: sourceposty; const newtext: msestring);

   function getmatchingmethods(const amodule: tmsecomponent;
                                   const atype: ptypeinfo): msestringarty;
   function parsemodule(const amodule: tmsecomponent): pclassinfoty;
   function findunitfile(const aunitname: msestring): msestring;
   function findmethodpos(const amethod: tmethod; const imp: boolean = false): sourceposty;
   function findcfunctionimplementation(const aname: ansistring;
                      out headerstart,headerstop: sourceposty): boolean;
                          //true if found

   function composeproceduretext(const infopo: pprocedureinfoty;
                     const withdefault: boolean): string; overload;
   function composeprocedureheader(const infopo: pprocedureinfoty;
                                   const withdefault: boolean): string; overload;
   function gettype(const adef: pdefinfoty): stringarty;
   function finddef(const infopo: punitinfoty;
                   const apos: sourceposty): pdefinfoty; overload;
   function finddef(const infopo: punitinfoty;
                   const typename: string): pdefinfoty; overload;
   function getitemtext(const aitem: sourceitemty): string;
   function getdefinfotext(const adef: pdefinfoty): string;
   property maxlinelength: integer read fmaxlinelength 
                                    write fmaxlinelength default 80;
 end;

var
 sourceupdater: tsourceupdater;

procedure init(const adesigner: tdesigner);
procedure deinit(const adesigner: tdesigner);

procedure sourcechanged(const filename: filenamety);
function switchheaderimplementation(const filename: filenamety;
                    var astart,astop: sourceposty;
                               out isimplementation: boolean): boolean;
function findlinkdest(const edit: tsyntaxedit; var apos: sourceposty;
                         out definition: msestring): boolean;
  //true if dest found
function listprocheaders(const filename: filenamety;
                     var apos: sourceposty): procedureinfoarty;
function listsourceitems(const filename: filenamety;
                     var apos: sourceposty; out scopes: deflistarty;
                     out defs: definfopoarty;
                     const maxcount: integer = 100): boolean;
   //true if found
function completeclass(const filename: filenamety; var pos: sourceposty): boolean;
   //true if source changed 
function getimplementationtext(const amodule: tmsecomponent; out aunit: punitinfoty;
                out start,stop: sourceposty; out adest: msestring): boolean;
                //false if not found
implementation
uses
 sysutils,msesys,msefileutils,sourceform,sourcepage,projectoptionsform,
 msegui,msearrayutils,projecttreeform;
{$ifndef mse_allwarnings}
 {$if fpc_fullversion >= 030100}
  {$warn 5089 off}
  {$warn 5090 off}
  {$warn 5093 off}
  {$warn 6058 off}
 {$endif}
{$endif}

function findprogramlanguage(const afilename: filenamety): proglangty;
var
 mstr1: msestring;
begin
 mstr1:= mseuppercase(fileext(afilename));
 if (mstr1 = 'C') or (mstr1 = 'H') then begin
  result:= pl_c;
 end
 else begin
  result:= pl_pascal;
 end;
end;

function limitlinelength(const atext: msestring; const maxlength: integer;
               const breakchars: msestring; const indent: integer;
               const startoffset: integer = 0): msestring;
var
 ar1: msestringarty;
 mstr1: msestring;
 int1: integer;
 po1,po2: pmsechar;
 linelength: integer;
 bo1: boolean;
begin
 result:= '';
 if atext <> '' then begin
  ar1:= breaklines(atext);
  mstr1:= concatstrings(ar1,' ');
  ar1:= nil;
  po1:= pmsechar(mstr1);
  po2:= po1;
  bo1:= false;
  while po2^ <> #0 do begin
   if bo1 and (findchar(breakchars,po2^) <> 0) then begin
    inc(po2);
    additem(ar1,stringsegment(po1,po2));
    po1:= po2;
   end
   else begin
    bo1:= true;
    inc(po2);
   end;
  end;
  additem(ar1,stringsegment(po1,po2));
  result:= ar1[0];
  linelength:= length(result) + startoffset;
  for int1:= 1 to high(ar1) do begin
   if (ar1[int1] <> '') and 
             (length(ar1[int1]) + linelength > maxlength) then begin
    result:= result + lineend + charstring(msechar(' '),indent) + ar1[int1];
    linelength:= indent + length(ar1[int1]);
   end
   else begin
    result:= result + ar1[int1];
    linelength:= linelength + length(ar1[int1]);
   end;
  end;
 end;
end;

procedure init(const adesigner: tdesigner);
begin
 sourceupdater:= tsourceupdater.Create(adesigner);
 sourceupdater.maxlinelength:= projectoptions.e.rightmarginchars;
end;

procedure deinit(const adesigner: tdesigner);
begin
 freeandnil(sourceupdater);
end;

procedure sourcechanged(const filename: filenamety);
begin
 if sourceupdater <> nil then begin
  sourceupdater.sourcechanged(filename);
 end;
end;

function switchheaderimplementation(const filename: filenamety;
                var astart,astop: sourceposty; out isimplementation: boolean): boolean;
var
 po1: punitinfoty;
begin
 with sourceupdater do begin
  po1:= updatesourceunit(filename,astart.filenum,false);
  if updateline(po1,astart) then begin
   result:= switchheaderimplementation(po1,astart,astop,isimplementation);
  end
  else begin
   result:= false;
  end;
 end;
end;

function completeclass(const filename: filenamety; var pos: sourceposty): boolean;
var
 po1: punitinfoty;
begin
 with sourceupdater do begin
  po1:= updatesourceunit(filename,pos.filenum,false);
  if updateline(po1,pos) then begin
   result:= completeclass(po1,pos);
  end
  else begin
   result:= false;
  end;
 end;
end;

function getimplementationtext(const amodule: tmsecomponent; 
              out aunit: punitinfoty;
              out start,stop: sourceposty; out adest: msestring): boolean;
                //false if not found
begin
 result:= false;
 with sourceupdater do begin
  aunit:= updatemodule(amodule);
  if aunit <> nil then begin
   with aunit^ do begin
    start:= p.implementationbodystart;
    if isemptysourcepos(start) then begin
     start:= p.implementationstart;
    end;
    stop:= p.implementationend;
    if not isemptysourcepos(start) then begin
     adest:= msestring(gettext(aunit,start,stop));
     result:= true;
    end;
   end;
  end;
 end;
end;

function findlinkdest(const edit: tsyntaxedit; var apos: sourceposty;
                             out definition: msestring): boolean;
var
 po1: punitinfoty;
 po2: psourceitemty;
 str1: msestring;
// coord1: gridcoordty;
 po3: pdefinfoty;
 int1: integer;

begin
 result:= false;
 definition:= '';
 with sourceupdater do begin
  application.beginwait;
  try
   if not application.waitcanceled then begin
    po1:= updatesourceunit(edit.filename,apos.filenum,false);
    if updateline(po1,apos) then begin
     po2:= findsourceitem(po1,apos);
     if po2 <> nil then begin
      case po2^.kind of
       sik_uses: begin
        {coord1:= }
        edit.wordatpos(apos.pos,str1,defaultdelimchars + ',;{}/',[]);
        if str1 <> '' then begin
         definition:= str1;
         str1:= findunitfile(str1);
         if str1 <> '' then begin
          result:= true;
          apos.filename:= designer.designfiles.add(str1);
          apos.pos.col:= 0;
          apos.pos.row:= 0;
         end;
        end;
       end;
       sik_include: begin
        apos.filename:=
            designer.designfiles.find(po1^.includestatements[po2^.index].filename);
        definition:= designer.designfiles.getname(apos.filename);
        apos.pos.col:= 0;
        apos.pos.row:= 0;
        result:= true;
       end;
      end;
     end
     else begin
      po3:= finddef(po1,apos);
      if po3 <> nil then begin
       if po3^.deflist <> nil then begin
        definition:= msestring(po3^.deflist.rootnamepath);
       end
       else begin
        definition:= msestring(po3^.owner.rootnamepath+'.'+
                                                 uppercase(po3^.name));
       end;
       if po3^.kind in [syk_procdef,syk_procimp] then begin
        int1:= findchar(definition,'$');
        if int1> 0 then begin
         setlength(definition,int1-1);
        end;
       end;
       apos.filename:= po3^.pos.filename;
       apos.pos:= po3^.pos.pos;
       result:= true;
      end;
     end;
    end;
   end;
  finally
   application.endwait;
  end;
 end;
end;

function listprocheaders(const filename: filenamety;
                 var apos: sourceposty): procedureinfoarty;
var
 po1: punitinfoty;
 ar1: procedureinfopoarty;
 int1: integer;
begin
 ar1:= nil; //compiler warning
 with sourceupdater do begin
  po1:= updatesourceunit(filename,apos.filenum,false);
  if updateline(po1,apos,filename) then begin
   ar1:= listprocheaders(po1,apos);
   setlength(result,length(ar1));
   for int1:= 0 to high(ar1) do begin
    result[int1]:= ar1[int1]^;
   end;
  end
  else begin
   result:= nil;
  end;
 end;
end;

function listsourceitems(const filename: filenamety;
                     var apos: sourceposty; out scopes: deflistarty;
                     out defs: definfopoarty; const maxcount: integer = 100): boolean;
var
 po1: punitinfoty;
begin
 with sourceupdater do begin
  po1:= updatesourceunit(filename,apos.filenum,false);
  if updateline(po1,apos,filename) then begin
   result:= listsourceitems(po1,apos,scopes,defs,maxcount);
  end
  else begin
   result:= false;
   scopes:= nil;
   defs:= nil;
  end;
 end;
end;

{ tfilenameinfo }

procedure tfilenameinfo.addunitinfo(ainfo: punitinfoty);
var
 int1: integer;
begin
 for int1:= 0 to high(funits) do begin
  if funits[int1] = ainfo then begin
   exit;
  end;
 end;
 setlength(funits,high(funits) + 2);
 funits[high(funits)]:= ainfo;
end;

{ tfilenamelist }

procedure tfilenamelist.add(const key: filenamety; info: punitinfoty);
var
 adata: tfilenameinfo;
begin
 adata:= find(key);
 if adata = nil then begin
  adata:= tfilenameinfo.Create;
  if filesystemiscaseinsensitive then begin
   inherited add(mseuppercase(key),adata);
  end
  else begin
   inherited add(key,adata);
  end;
 end;
 adata.addunitinfo(info);
end;

function tfilenamelist.find(const key: filenamety): tfilenameinfo;
begin
 if filesystemiscaseinsensitive then begin
  result:= tfilenameinfo(inherited find(mseuppercase(key)));
 end
 else begin
  result:= tfilenameinfo(inherited find(key));
 end;
end;

procedure tfilenamelist.sourcefilemodified(key: filenamety);
var
 int1: integer;
 ainfo: tfilenameinfo;
begin
 ainfo:= find(key);
 if ainfo <> nil then begin
  for int1:= 0 to high(ainfo.funits) do begin
   with ainfo.funits[int1]^ do begin
    if interfacecompiled then begin
     interfacecompiled:= false;
     if (proglang = pl_c) and (deflist <> nil) then begin
      deflist.clear; //remove entries in cglobals;
      projecttree.cmodules.modulechanged(key);
     end;
    end;
   end;
  end;
 end;
end;

{ tunitinfolist }

constructor tunitinfolist.create;
begin
// fnamelist:= thashedstrings.create;
 fnamelist:= tpointeransistringhashdatalist.create;
 inherited create(true);
end;

destructor tunitinfolist.destroy;
begin
 inherited;
 fnamelist.Free;
end;

procedure tunitinfolist.clear;
begin
 beginfinalizecglobals;
 try
  inherited;
  fnamelist.clear;
 finally
  finalizecglobals;
 end;
end;

function tunitinfolist.datapo: punitinfoaty;
begin
 result:= punitinfoaty(inherited datapo);
end;

function tunitinfolist.newitem(const lang: proglangty): punitinfoty;
var
 aitem: tunitinfo;
begin
 case lang of
  pl_pascal: begin
   aitem:= tpascalunitinfo.create;
  end;
  pl_c: begin
   aitem:= tcunitinfo.create;
  end;
  else begin
   aitem:= tunitinfo.create;
  end;
 end;
 add(aitem);
 result:= aitem.infopo;
end;

function tunitinfolist.getitempo(const index: integer): punitinfoty;
begin
 result:= @tunitinfo(items[index]).info;
end;

function tunitinfolist.finditembyformfilename(const afilename: filenamety): punitinfoty;
var
 po1: punitinfoaty;
 int1: integer;
begin
 result:= nil;
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if issamefilename(afilename,po1^[int1].info.formfilename) then begin
   result:= po1^[int1].infopo;
   break;
  end;
 end;
end;

function tunitinfolist.finditembysourcefilename(const afilename: filenamety;
                    var filenum: integer): punitinfoty;
var
 po1: punitinfoaty;
 int1,int2: integer;
begin
 result:= nil;
 po1:= datapo;
 filenum:= 0;
 for int1:= 0 to fcount - 1 do begin //check includefiles first
  for int2:= 1 to high(po1^[int1].info.sourcefiles) do begin
   if issamefilename(afilename,po1^[int1].info.sourcefiles[int2].filename) then begin
    filenum:= int2 + 1;
    result:= po1^[int1].infopo;
    break;
   end;
  end;
  if result <> nil then begin
   exit;
  end;
 end;
 po1:= datapo;
 for int1:= 0 to fcount - 1 do begin
  if issamefilename(afilename,po1^[int1].info.sourcefilename) then begin
   filenum:= 1;
   result:= po1^[int1].infopo;
   break;
  end;
 end;
end;

function tunitinfolist.finditembyunitname(const aname: string): punitinfoty;
begin
 result:= fnamelist.find(struppercase(aname));
end;

{ tsourceupdater }

procedure tsourceupdater.sourcechanged(const filename: filenamety);
begin
 ffilenamelist.sourcefilemodified(filename);
end;

function tsourceupdater.createscratchfile(const origname: filenamety): ttextstream;
begin
 result:= ttextstream.create(origname + '.$$$',fm_create);
end;

function tsourceupdater.gettext(const infopo: punitinfoty;
                 const startpos,endpos: sourceposty): msestring;
begin
 result:= sourcefo.getfiletext(infopo^.sourcefilename,startpos.pos,endpos.pos);
end;

procedure tsourceupdater.replacetext(const infopo: punitinfoty;
  const startpos, endpos: sourceposty; const newtext: msestring);
begin
 sourcefo.replacefiletext(infopo^.sourcefilename,startpos.pos,endpos.pos,newtext);
end;

function tsourceupdater.updateline(module: punitinfoty;
                                       var apos: sourceposty): boolean;
var
 int1,int2: integer;
 aincludefiles: integer;
begin
 if apos.filenum > 0 then begin
  result:= true;
  apos.line:= apos.pos.row;
  int2:= apos.filenum - 1;
  with module^.sourcefiles[int2] do begin
   inc(apos.line,startline);
   aincludefiles:= includecount;
  end;
  for int1:= int2 + 1 to high(module^.sourcefiles) do begin
   with module^.sourcefiles[int1] do begin
    dec(aincludefiles);
    if aincludefiles < 0 then begin
     break;
    end;
    if apos.line <= startline then begin
     break;
    end;
    inc(aincludefiles,includecount);
    inc(apos.line,count);
   end;
  end;
 end
 else begin
  result:= false;
 end;
end;

function tsourceupdater.updateline(module: punitinfoty; var apos: sourceposty;
            const afilename: filenamety): boolean;
begin
 apos.filename:= designer.designfiles.find(afilename);
 result:= (apos.filename >= 0) and updateline(module,apos);
end;

procedure tsourceupdater.checkitemlist(const infopo: punitinfoty);
var
 int1: integer;
begin
 with infopo^ do begin
  if itemlist = nil then begin
   itemlist:= tsourceitemlist.create;
   for int1:= 0 to high(includestatements) do begin
    with includestatements[int1] do begin
     with itemlist.newitem(startpos,endpos,sik_include)^ do begin
      index:= int1;
     end;
    end;
   end;
   case proglang of
    pl_c: begin
    end;
    else begin
     p.interfaceuses.getsourceitems(itemlist);
     p.implementationuses.getsourceitems(itemlist);
    end;
   end;
  end;
 end;
end;

function tsourceupdater.findsourceitem(const infopo: punitinfoty;
           const apos: sourceposty): psourceitemty;
begin
 checkitemlist(infopo);
 result:= infopo^.itemlist.find(apos);
end;

function tsourceupdater.findsourceitem(const infopo: punitinfoty; const apos: sourceposty;
                             out aindex: integer): psourceitemty;
begin
 checkitemlist(infopo);
 result:= infopo^.itemlist.find(apos,aindex);
end;

function tsourceupdater.findsourceitem1(const infopo: punitinfoty; const apos: sourceposty;
                                  out scope: tdeflist): pdefinfoty;
begin
 with infopo^.deflist do begin
  result:= finditem(apos,false,scope);
 end;
end;

function tsourceupdater.getitemtext(const aitem: sourceitemty): string;
var
 infile: ttextstream;
 int1: integer;
begin
 infile:= sourcefo.gettextstream(designer.designfiles.getname(aitem.filename),false);
 if infile <> nil then begin
  try
   infile.position:= aitem.startoffset;
   int1:= aitem.endoffset - aitem.startoffset;
   setlength(result,int1);
   infile.ReadBuffer(result[1],int1);
  finally
   infile.Free;
  end;
 end
 else begin
  result:= '';
 end;
end;

function tsourceupdater.getdefinfotext(const adef: pdefinfoty): string;
var
 item1: sourceitemty;
begin
 if adef^.kind in [syk_typedef,syk_vardef,syk_pardef,syk_classdef,
                         syk_procdef,syk_procimp,
                         syk_classprocimp,syk_interfacedef] then begin
  item1.filename:= adef^.pos.filename;
  item1.startoffset:= adef^.pos.offset;
  item1.endoffset:= adef^.stop1.offset;
  result:= getitemtext(item1);
 end
 else begin
  result:= '';
 end;
end;

function tsourceupdater.getidentpath(const infopo: punitinfoty;
                 const apos: sourceposty; const firstidentuse: boolean;
                              out scope: tdeflist): stringarty;

 procedure getidents(apo: pdefinfoty; const infile: ttextstream);
 var
  int1,int2,int3: integer;
 begin
  if infile <> nil then begin
   try
    int2:= 0;
    if (apo <> nil) and (apo^.kind = syk_identuse) then begin
     while (apo^.kind = syk_identuse) and
       not (if_first in apo^.identflags) do begin
      inc(int2);
      dec(apo);
     end;
     setlength(result,int2+1);
     for int1:= 0 to int2 do begin
      infile.position:= apo^.pos.offset;
      int3:= apo^.identlen;
      if not((int1 = int2) and (apos.pos.col <= apo^.pos.pos.col) or 
                              (apos.pos.row < apo^.pos.pos.row)) then begin
       setlength(result[int1],int3);
       infile.ReadBuffer(result[int1][1],int3);
        //else ''
      end;
      inc(apo);
     end;
    end;
   finally
    infile.destroy;
   end;
  end;
 end;

var
 po1: pdefinfoty;
 pos1: sourceposty;
 str1: string;
 list1,list2: tdeflist;

begin
 result:= nil;
 po1:= infopo^.deflist.finditem(apos,firstidentuse,scope);
 if (po1 <> nil) then begin
  case po1^.kind of
   syk_identuse: begin
    getidents(po1,sourcefo.gettextstream(designer.designfiles.getname(
                              po1^.pos.filename),false));
   end;
   syk_typedef,syk_vardef,syk_pardef,syk_classdef,syk_procdef,syk_classprocimp,
                         syk_procimp,syk_interfacedef: begin
    list1:= nil;
    try
     case infopo^.proglang of
      pl_c: begin
       parsecdef(po1,str1,list1);
      end
      else begin
       parsepascaldef(po1,str1,list1);
      end;
     end;
     pos1.line:= apos.line - po1^.pos.line;
     if pos1.line = 0 then begin
      pos1.pos.col:= apos.pos.col - po1^.pos.pos.col;
     end
     else begin
      pos1.pos.col:= apos.pos.col;
     end;
     getidents(list1.finditem(pos1,false,list2),ttextstream.createdata(str1));
    finally
     list1.Free;
    end;
   end;
  end;
 end;
end;

function tsourceupdater.finddef(const infopo: punitinfoty;
                                       const apos: sourceposty): pdefinfoty;
var
 ar1: stringarty;
 scope: tdeflist;
 scopes: deflistarty;
 defs: definfopoarty;
begin
 application.beginwait;
 try
  result:= nil;
  resetunitsearched;
  ar1:= getidentpath(infopo,apos,false,scope);
  if scope.finddef(ar1,scopes,defs,true,dsl_normal,syk_nopars) then begin
   result:= defs[0];
  end;
 finally
  application.endwait;
 end;
end;

function tsourceupdater.finddef(const infopo: punitinfoty;
                   const typename: string): pdefinfoty;
var
 ar1: stringarty;
 scope: tdeflist;
 scopes: deflistarty;
 defs: definfopoarty;
begin
 result:= nil;
 resetunitsearched;
 ar1:= splitstring(typename,'.');
 scope:= infopo^.deflist;
 if scope.finddef(ar1,scopes,defs,true,dsl_normal,syk_nopars) then begin
  result:= defs[0];
 end; 
end;

function tsourceupdater.listprocheaders(const infopo: punitinfoty;
                        const apos: sourceposty): procedureinfopoarty;
var
 ar1: stringarty;
 int1: integer;
 scopes: deflistarty;
 defs: definfopoarty;
 scope1: tdeflist;

begin
 application.beginwait;
 try
  result:= nil;
  resetunitsearched;
  ar1:= getidentpath(infopo,apos,true,scope1);
  if scope1.finddef(ar1,scopes,defs,false,dsl_normal,syk_nopars) then begin
   for int1:= 0 to high(defs) do begin
    if defs[int1]^.kind in [syk_procdef,syk_procimp] then begin
     case scopes[int1].kind of
      syk_classdef: begin
       setlength(result,high(result) + 2);
       result[high(result)]:= scopes[int1].rootlist.unitinfopo^.
          p.classinfolist[scopes[int1].definfopo^.classindex]^.
                                        procedurelist[defs[int1]^.procindex];
      end;
      syk_root: begin
       setlength(result,high(result) + 2);
       result[high(result)]:= trootdeflist(scopes[int1]).rootlist.unitinfopo^.
          p.procedurelist[defs[int1]^.procindex];
      end;
     end;
    end;
   end;
  end;
  removearrayduplicates(pointerarty(result));
 finally
  application.endwait;
 end;
end;

function tsourceupdater.listsourceitems(const infopo: punitinfoty;
                   const apos: sourceposty; out scopes: deflistarty;
                   out defs: definfopoarty; const maxcount: integer = 100): boolean;
var
 ar1: stringarty;
 scope1: tdeflist;
// ar2,ar4: deflistarty;
// ar3,ar5: definfopoarty;
 int1,int2: integer;

begin
 application.beginwait;
 try
  resetunitsearched;
  ar1:= getidentpath(infopo,apos,false,scope1);
  result:= scope1.finddef(ar1,scopes,defs,false,dsl_normal,syk_substr,maxcount);
  for int1:= 0 to high(defs) do begin //remove duplicates
   if defs[int1] <> nil then begin
    for int2:= int1 + 1 to high(defs) do begin
     if defs[int2] = defs[int1] then begin
      defs[int2]:= nil
     end;
    end;
   end;
  end;
  int2:= 0;
  for int1:= 0 to high(defs) do begin
   if defs[int1] <> nil then begin
    defs[int2]:= defs[int1];
    scopes[int2]:= scopes[int1];
    inc(int2);
   end;
  end;
  setlength(defs,int2);
  setlength(scopes,int2);
 finally
  application.endwait;
 end;
end;

function tsourceupdater.findunitfile(const aunitname: msestring): msestring;

 function dofind(const aname: filenamety): filenamety;
 var
  apage: tsourcepage;
 begin
  apage:= sourcefo.findsourcepage(aname,false);
  if apage <> nil then begin
   result:= apage.filepath;
  end
  else begin
   result:= '';
   findfile(aname,projectoptions.d.texp.sourcedirs,result);
  end;
 end;

 function dofind1(const aunitname: filenamety): filenamety;
 var
  str1: msestring;
 begin
  result:= dofind(aunitname);
  if result = '' then begin
   str1:= mselowercase(aunitname);
   if str1 <> aunitname then begin
    result:= dofind(str1);
   end;
   if result = '' then begin
    str1:= mseuppercase(aunitname);
    if str1 <> aunitname then begin
     result:= dofind(str1);
    end;
   end;
  end;
 end;

begin
 result:= dofind1(aunitname+'.pas');
 if result <> '' then exit;
 result:= dofind1(aunitname+'.pp');
 if result <> '' then exit;
 result:= dofind1(aunitname+'.mla');
end;

function tsourceupdater.findmethodpos(const amethod: tmethod;
                 const imp: boolean = false): sourceposty;
var
 moduleinfo: pmoduleinfoty;
 methodinfo: pmethodinfoty;
// unitinfo: punitinfoty;
// classinfo1: pclassinfoty;
 procedureinfo: pprocedureinfoty;
 ar1: classinfopoarty;
 int1: integer;
begin
 result:= emptysourcepos;
 if amethod.data <> nil then begin
  designer.getmethodinfo(amethod,moduleinfo,methodinfo);
  if moduleinfo <> nil then begin
   ar1:= designer.getancestorclassinfo(moduleinfo^.instance,false);
   procedureinfo:= nil;
   for int1:= high(ar1) downto 0 do begin
    procedureinfo:= ar1[int1]^.procedurelist.finditembyname(methodinfo^.name);
    if procedureinfo <> nil then begin
     break;
    end;
   end;
//   unitinfo:= updateformunit(moduleinfo^.filename,false);
//   if unitinfo <> nil then begin
//    classinfo1:= unitinfo^.p.classinfolist.finditembyname(
//            moduleinfo^.moduleclassname,true);
//    if classinfo1 <> nil then begin
//     procedureinfo:= classinfo1^.procedurelist.finditembyname(methodinfo^.name);
     if procedureinfo <> nil then begin
      with procedureinfo^do begin
       if imp and (impheaderendpos.filenum > 0) then begin
        result:= impheaderendpos;
       end
       else begin
        if intendpos.filenum > 0 then begin
         result:= intendpos;
        end
        else begin
         result:= impheaderendpos;
        end;
       end;
      end;
     end;
//    end;
//   end;
  end;
 end;
end;

function tsourceupdater.switchheaderimplementation(const infopo: punitinfoty;
                        var headerstart,headerstop: sourceposty; 
                                      out isimplementation: boolean): boolean;
var
 po1,po2: pdefinfoty;
 scope: tdeflist;
 str1: string;
 ar1: stringarty;
 bo1: boolean;
 scopes: deflistarty;
 defs: definfopoarty;

begin
 result:= false;
 ar1:= nil; //compiler warning
 isimplementation:= false;
 with infopo^ do begin
  po1:= deflist.finditem(headerstart,false,scope);
  if po1 <> nil then begin
   po2:= nil;
   if po1^.kind = syk_procdef then begin
    isimplementation:= true;
    if scope.kind = syk_classdef then begin
     str1:= scope.name + '.'+ po1^.name; //as direct procparameter  delphi bug
     po2:= scope.parent.find(str1,syk_classprocimp);
    end
    else begin
     po2:= scope.find(po1^.name,syk_procimp);
     if (po2 = nil) and (infopo^.proglang = pl_c) then begin
      result:= findcfunctionimplementation(po1^.name,headerstart,
                                                        headerstop);
     end;
    end;
   end
   else begin
    while (scope <> nil) and 
              not (scope.kind in [syk_root,syk_classdef]) do begin
     po1:= scope.definfopo;
     scope:= scope.parentscope;
    end;
    if scope <> nil then begin
     ar1:= splitstring(po1^.name,'.');
     if scope.kind = syk_classdef then begin
      bo1:= scope.finddef(copy(ar1,high(ar1),1),scopes,defs,true,dsl_normal);
     end
     else begin
      bo1:= scope.finddef(ar1,scopes,defs,true,dsl_normal,syk_procdef);
     end;
     if bo1 then begin
      po2:= defs[0];
     end;
    end;
   end;
   if po2 <> nil then begin
    headerstart:= po2^.pos;
    headerstop:= po2^.stop1;
    result:= true;
   end;
  end;
 end;
 if (headerstart.filenum = 0) or (headerstop.filenum = 0) then begin
  result:= false;
 end;
end;

type
 propinfoty = record
  indextext: string;
  typetext: stringarty;
  getter: string;
  setter: string;
 end;
 propinfoarty = array of propinfoty;
 
function tsourceupdater.composeproceduretext(const name: string;
             const info: methodparaminfoty; const withdefault: boolean): string;

var
 int1,int2: integer;
 {$if FPC_FULLVERSION > 030200} 
 namemeth : string;
 {$endif}
 begin
 result:= name;
 {$if FPC_FULLVERSION > 030200} 
 namemeth := result;
 {$endif}
 with info do begin
  int2:= high(params);
  if kind in [mk_function,mk_procedurefunc,mk_methodfunc] then begin
   dec(int2);
  end;
  if int2 >= 0 then begin
   result:= result + '(';
   for int1:= 0 to int2 do begin
    with params[int1] do begin     //todo: merge equal types
     if pfconst in flags then begin
      result:= result + 'const ';
     end
     else begin
      if pfvar in flags then begin
       result:= result + 'var ';
      end
      else begin
       if pfout in flags then begin
        result:= result + 'out ';
       end;
      end;
     end;
     result:= result + name;
     if typename <> '' then begin
      result:= result + ': ';
      if pfarray in flags then begin
       result:= result + 'array of ';
       if typename = 'TVarRec' then begin
        result:= result + 'const';
       end
       else begin
        result:= result + typename;
       end;
      end
      else begin
       result:= result + typename;
      end;
      if withdefault and (defaultvalue <> '') then begin
       result:= result + ' = '+defaultvalue;
      end;
     end;
      {$if FPC_FULLVERSION > 030200} 
      if name = '$self' then result := namemeth + '(' else
      {$endif}
      result:= result + '; ';
    end;
   end;
   setlength(result,length(result)-1); //remove last space
   result[length(result)]:= ')';
  end
  else begin
   if mef_brackets in flags then begin
    result:= result + '()';
   end;
  end;
  if kind in [mk_function,mk_procedurefunc,mk_methodfunc] then begin
   result:= result + ': ' + params[high(params)].typename;
  end;
  result:= result + ';';
 end;
end;

function tsourceupdater.composeproceduretext(const infopo: pprocedureinfoty;
              const withdefault: boolean): string;
begin
 with infopo^ do begin
  result:= composeproceduretext(name,params,withdefault);
 end;
end;

function tsourceupdater.composeprocedureheader(const infopo: pprocedureinfoty;
              const withdefault: boolean): string;
begin
 with infopo^ do begin
  result:= composeprocedureheader(name,params,withdefault,classproc);
 end;
end;

procedure tsourceupdater.createmethodbody(const unitinfopo: punitinfoty;
                const classinfopo: pclassinfoty; const aname: string;
                const atype: ptypeinfo; beforeitem: integer);
var
 str1: msestring;
 pos1: sourceposty;
 int1: integer;
 bo1: boolean;
begin
 pos1:= emptysourcepos;
 bo1:= false;
 if falphabeticprocorder then begin
  with classinfopo^.procedurelist do begin
   for int1:= beforeitem to count - 1 do begin
    with items[int1]^ do begin
     if not isemptysourcepos(impheaderstartpos) then begin
      bo1:= true;
      pos1:= impheaderstartpos;
      break;
     end;
    end;
   end;
  end;
 end;
 if isemptysourcepos(pos1) then begin
  pos1:= classinfopo^.procimpend;
  if isemptysourcepos(pos1) then begin
   pos1:= unitinfopo^.p.implementationend;
   bo1:= true;
  end;
 end;
 if pos1.filenum <> unitinfopo^.unitend.filenum then begin
  pos1:= unitinfopo^.p.implementationend;
  if pos1.filenum <> unitinfopo^.unitend.filenum then begin
   pos1:= unitinfopo^.unitend;
  end;
 end;
 if issamesourcepos(unitinfopo^.unitend,pos1) then begin
  dec(pos1.line);    //no 'end.'
  dec(pos1.pos.row);
  if pos1.pos.row < 0 then begin
   exit; //invalid
  end;
 end;
 if bo1 then begin
  str1:= '';
 end
 else begin
  str1:= lineend;
 end;
 str1:= str1 + limitlinelength(msestring(
        composeprocedureheader(classinfopo^.name+'.'+aname,atype,false,false)),
                             fmaxlinelength,procheaderbreakchars,14) + lineend;
 str1:= str1 + 'begin' + lineend + 'end;' + lineend;
 if bo1 then begin
  str1:= str1 + lineend;
 end;
 replacetext(unitinfopo,pos1,pos1,str1);
end;

function tsourceupdater.completeclass(const infopo: punitinfoty;
                      const pos: sourceposty): boolean;
var
 ppo: pprocedureinfoty;
 cpo: pclassinfoty;
 scope: tdeflist;
 int1: integer;
 str1: msestring;
 parser: tpascalparser;
 po1: pchar;
 ar1: propinfoarty;
 
 procedure insertprivate(const isfield: boolean; const atext: string);
 var
  int1: integer;
 begin
  completeclass:= true;
  infopo^.interfacecompiled:= false;
  int1:= length(breaklines(atext));
  with cpo^ do begin
   if isfield then begin
    replacetext(infopo,privatefieldend,privatefieldend,
                                   msestring('   '+atext+lineend));
    inc(privatefieldend.pos.row,int1);
   end
   else begin
    replacetext(infopo,privateend,privateend,msestring('   '+atext+lineend));
   end;
   inc(privateend.pos.row,int1);
   privateend.pos.col:= 0;
  end;
 end;
 
 procedure checkfield(const name: string; const propinfo: propinfoty);
 var
  scope1: tdeflist;
 begin
  if scope.finddef(name,syk_vardef,scope1) = nil then begin
   insertprivate(true,name+': '+concatstrings(propinfo.typetext,'.')+';');
  end;
 end;

 procedure checkproc(const issetter: boolean; const propinfo: propinfoty);
 
  function breakline(const atext: msestring): msestring;
  begin
   result:= limitlinelength(atext,fmaxlinelength,procheaderbreakchars,18);
  end;
  
 var
  scope1: tdeflist;
 begin                     //checkproc
  with propinfo do begin
   if issetter then begin
    if scope.finddef(setter,syk_nopars,scope1) = nil then begin
     if indextext <> '' then begin
      insertprivate(false,ansistring(
       breakline('procedure '+msestring(setter+'('+
       indextext+'; const avalue: ')+
       msestring(concatstrings(typetext,'.')+');'))));
     end
     else begin
      insertprivate(false,ansistring(
       breakline('procedure '+msestring(setter)+'(const avalue: '+
                         msestring(concatstrings(typetext,'.'))+');')));
     end;
    end;
   end
   else begin
    if scope.finddef(getter,syk_nopars,scope1) = nil then begin
     if indextext <> '' then begin
      insertprivate(false,ansistring(
       breakline('function '+msestring(getter)+'('+msestring(indextext)+'): '+
       msestring(concatstrings(typetext,'.'))+';')));
     end
     else begin
      insertprivate(false,ansistring(breakline('function '+
                                            msestring(getter)+': '+
       msestring(concatstrings(typetext,'.'))))+';');
     end;
    end;
   end;
  end;
 end;

 procedure checklineinsert(const info: classinfoty; const startindex: int32;
                              const startline: int32; const linecount: int32);
 var
  po1,pe: pprocedureinfoty;
 begin
  po1:= info.procedurelist.datapo;
  pe:= po1 + info.procedurelist.count;
  while po1 < pe do begin
   if po1^.impendpos.pos.row >= startindex then begin
    inc(po1^.impendpos.pos.row,linecount);
   end;
   inc(po1);
  end;
 end; //checklineinsert
 
var
 po2: pdefinfoty;   
 atstart: boolean;
 classindex1: integer;
 str2: string;
 i2: int32;
 insertpos: sourceposty;
 
begin                        //completeclass
 result:= false;
 with infopo^ do begin
  cpo:= nil;
  po2:= deflist.finditem(pos,false,scope);
  if po2 <> nil then begin
   if po2^.kind = syk_classdef then begin
    scope:= po2^.deflist;
   end;
   if (scope <> nil) and (scope.kind = syk_classdef) then begin
    classindex1:= scope.definfopo^.classindex;
    cpo:= infopo^.p.classinfolist[classindex1];
   end
  end;
  if cpo <> nil then begin
   with cpo^ do begin
    ar1:= nil;
    for int1:= 0 to high(scope.infos) do begin
     with scope.infos[int1] do begin
      if (kind = syk_vardef) and (vf_property in varflags) then begin
       str2:= getdefinfotext(@scope.infos[int1]);     
       if str2 <> '' then begin
        parser:= tpascalparser.create(designer.designfiles,str2);
        try
         with parser do begin
          setlength(ar1,high(ar1)+2);
          with ar1[high(ar1)] do begin
           skipwhitespace;
           nexttoken; //skip name 
           if checkoperator('[') then begin
            po1:= token^.value.po;
            if findoperator(']') then begin
             indextext:= getlastorigtext(po1);
            end;
           end
           else begin
            indextext:= '';
           end;
           if checkoperator(':') then begin
            typetext:= getidentpath(parser);
            getter:= '';
            setter:= '';
            if checkpropertyident(pid_read) then begin
             getter:= getorigname;
             if checkpropertyident(pid_write) then begin
              setter:= getorigname;
             end;
            end
            else begin
             if checkpropertyident(pid_write) then begin
              setter:= getorigname;
              if checkpropertyident(pid_read) then begin
               getter:= getorigname;
              end;
             end;
            end;
           end;
          end;
         end;
        finally
         parser.free;
        end;
       end;
      end;
     end;
    end;
    if ar1 <> nil then begin
     if isemptysourcepos(privatestart) then begin
      result:= true;
      replacetext(infopo,managedend,managedend,'  private'+lineend);
      privatestart:= managedend;
      inc(privatestart.pos.row);
      privateend:= privatestart;
      privateend.pos.col:= 0;
      privatefieldend:= privateend;
     end;
     for int1:= 0 to high(ar1) do begin
      with ar1[int1] do begin
       if getter <> '' then begin
        if stringicomp(getter,setter) = 0 then begin
         checkfield(getter,ar1[int1]);      //fieldref
         continue;
        end
        else begin
         if startsstr('GET',struppercase(getter)) then begin
          checkproc(false,ar1[int1]);
         end
         else begin
          checkfield(getter,ar1[int1]);      //fieldref
         end;
        end;
       end;
       if setter <> '' then begin
        if startsstr('SET',struppercase(setter)) then begin
         checkproc(true,ar1[int1]);
        end
        else begin
         checkfield(setter,ar1[int1]);      //fieldref
        end;
       end;
      end;
     end;    
    end;
    if result then begin
     updateunit(infopo,false);
    end;
   end;
   cpo:= infopo^.p.classinfolist[classindex1]; 
                                     //cpo is invalid after updateunit
   with cpo^ do begin                     
    if isemptysourcepos(procimpstart) then begin
     procimpstart:= infopo^.p.implementationend;
     replacetext(infopo,procimpstart,procimpstart,
                                 msestring('{ '+name+' }'+lineend+lineend));
     result:= true;
     checklineinsert(cpo^,0,procimpstart.pos.row,2);
     inc(procimpstart.pos.row,2);
     procimpstart.pos.col:= 0;
     procimpend:= procimpstart;
    end;
    insertpos:= procimpstart;
    insertpos.pos.col:= 0;
    atstart:= true;
    for int1:= 0 to procedurelist.count - 1 do begin
     ppo:= procedurelist[int1];
     with ppo^ do begin
      if not (mef_abstract in params.flags) then begin
       if isemptysourcepos(impheaderstartpos) then begin
        if atstart then begin
         str1:= '';
        end
        else begin
         str1:= lineend;
        end;
        str1:= str1 +
              limitlinelength(msestring(composeprocedureheader(ppo,cpo,true)),
                           fmaxlinelength,procheaderbreakchars,14) + lineend +
                  'begin'+lineend+
                  'end;'+lineend;
        if atstart then begin
         str1:= str1 + lineend;
        end;
        replacetext(infopo,insertpos,insertpos,str1);
        result:= true;
        i2:= high(breaklines(str1));
        checklineinsert(cpo^,insertpos.pos.row,int1,i2);
        inc(insertpos.pos.row,i2);
       end
       else begin
        insertpos.pos.row:= impendpos.pos.row;
        atstart:= false;
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tsourceupdater.methodcreated(const adesigner: idesigner;
  const amodule: tmsecomponent; const aname: string;
  const atype: ptypeinfo);

var
 po1: punitinfoty;
 po2: pclassinfoty;
 str1: string;
 int1: integer;
 pos1: sourceposty;
 posindex: integer;
 ar1: classinfopoarty;
begin
 if atype^.Kind = tkmethod then begin
  ar1:= designer.getancestorclassinfo(amodule,true);
  if ar1 = nil then begin
   exit;
  end;
  for int1:= high(ar1) downto 0 do begin
   if ar1[int1]^.procedurelist.finditembyname(aname{,atype}) <> nil then begin
    exit;
   end;
  end;
  po2:= ar1[high(ar1)];
  po1:= updatemodule(amodule);
//  po2:= findclassinfobyinstance(amodule,po1);
//  if (po2 <> nil) and (po2^.procedurelist.finditembyname(aname{,atype}) = nil) then begin
  pos1:= emptysourcepos;
  str1:= uppercase(aname);
  with po2^.procedurelist do begin
   posindex:= count;
   if falphabeticprocorder then begin
    for int1:= 0 to count - 1 do begin
     with items[int1]^ do begin
      if uppername > str1 then begin
       posindex:= int1;
       pos1:= intinsertpos;
      end;
      break;
     end;
    end;
   end;
  end;
  if isemptysourcepos(pos1) then begin
   pos1:= po2^.managedend;
  end;
  if not isemptysourcepos(pos1) then begin
   createmethodbody(po1,po2,aname,atype,posindex);
   str1:= composeprocedureheader(aname,atype,false,false);
   replacetext(po1,pos1,pos1,
     limitlinelength('   ' + msestring(str1),
                              fmaxlinelength,procheaderbreakchars,18)+lineend);
  end;
 end;
//end;
end;

procedure tsourceupdater.methodnamechanged(const adesigner: idesigner;
  const amodule: tmsecomponent; const newname, oldname: string;
   const atypeinfo: ptypeinfo);
var
 po1: punitinfoty;
 po2: pclassinfoty;
 po3: pprocedureinfoty;
 ar1: classinfopoarty;
 ar2: unitinfopoarty;
 int1: integer;
begin
 ar1:= designer.getancestorclassinfo(amodule,false,ar2);
 po1:= nil;
 po2:= nil;
 po3:= nil;
 for int1:= high(ar1) downto 0 do begin
  po1:= ar2[int1];
  if (po1 <> nil) and (ar1[int1] <> nil) then begin
   po3:= ar1[int1]^.procedurelist.finditembyname(oldname);
   if po3 <> nil then begin
    po2:= ar1[int1];
    break;
   end;
  end;
 end;
// po1:= updatemodule(amodule);
// po2:= findclassinfobyinstance(amodule,po1);
// if po2 <> nil then begin
//  po3:= po2^.procedurelist.finditembyname(oldname{,atypeinfo});
 if po3 <> nil then begin
  with po3^ do begin
   name:= newname;
   if not isemptysourcepos(impheaderstartpos) then begin
    replacetext(po1,impheaderstartpos,impheaderendpos,
      limitlinelength(msestring(composeprocedureheader(po3,po2,false)),
            fmaxlinelength,procheaderbreakchars,14,impheaderstartpos.pos.col));
   end;
   if not isemptysourcepos(intstartpos) then begin
    replacetext(po1,intstartpos,intendpos,
      limitlinelength(msestring(composeproceduretext(po3,false)),fmaxlinelength,
             procheaderbreakchars,18,intstartpos.pos.col));
   end;
  end;
 end;
end;

function tsourceupdater.getidentpath(const parser: tpascalparser): stringarty;
var
 ident1: integer;
begin
 result:= nil;
 with parser do begin
  ident1:= getident;
  if (token^.kind = tk_name) and (ident1 < 0) then begin
   additem(result,getorigname);
   while checkoperator('.') do begin
    if (token^.kind = tk_name) and (ident1 < 0) then begin
     additem(result,getorigname);
    end;
   end;
  end;
 end;
end;

function tsourceupdater.gettype(const adef: pdefinfoty): stringarty;
var
 str1: string;
 parser: tpascaldesignparser;
 ident1: integer;
 procinfo: procedureinfoty;
begin
 result:= nil;
 if adef^.kind in [syk_vardef,syk_procdef,syk_procimp] then begin
  str1:= getdefinfotext(adef);
  if str1 <> '' then begin
   parser:= tpascaldesignparser.create(designer.designfiles,str1);
   try
    with parser do begin
      ident1:= getident;
      if adef^.kind = syk_vardef then begin
      if (token^.kind = tk_name) and (ident1 < 0) then begin
       nexttoken;
       if checkoperator(':') then begin
        result:= getidentpath(parser);
       end;
      end;
     end
     else begin
      if ident1 = integer(pid_function) then begin
       if parser.parseprocedureheader(pascalidentty(ident1),@procinfo) then begin
        result:= splitidentpath(
              procinfo.params.params[high(procinfo.params.params)].typename);
       end;
      end;
     end;
    end;
   finally
    parser.Free;
   end;
  end;
 end;
end;

function tsourceupdater.composeprocedureheader(const name: string;
            const info: methodparaminfoty; const withdefault: boolean;
            const classproc: boolean): string;
begin
 result:= '';
 if classproc then begin
  result:= 'class ';
 end;
 case info.kind of 
  mk_function: begin
   result:= result + 'function ';
  end;
  mk_method,mk_methodfunc: begin
   result:= result + 'method ';
  end;
  mk_constructor: begin
   result:= result + 'constructor ';
  end;
  mk_destructor: begin
   result:= result + 'destructor ';
  end;
  else begin
   result:= result + 'procedure ';
  end;
 end;
 result:= result + composeproceduretext(name,info,withdefault);
end;

function tsourceupdater.composeprocedureheader(const infopo: pprocedureinfoty;
             const classinfopo: pclassinfoty; const withdefault: boolean): string;
var
 str1: string;
begin
 with infopo^ do begin
  if classinfopo <> nil then begin
   str1:= classinfopo^.name + '.' + name;
  end
  else begin
   str1:= name;
  end;
  result:= composeprocedureheader(str1,params,withdefault,infopo^.classproc);
 end;
end;

function tsourceupdater.composeprocedureheader(const name: string;
                                 const typeinfo: ptypeinfo;
                                 const withdefault: boolean;
                                 const classproc: boolean): string;
var
 info: methodparaminfoty;
begin
 getmethodparaminfo(typeinfo,info);
 result:= composeprocedureheader(name,info,withdefault,classproc);
end;

constructor tsourceupdater.create(const adesigner: tdesigner);
begin
 fmaxlinelength:= 80;
 fdesigner:= adesigner;
 designnotifications.registernotification(idesignnotification(self));
 funitinfolist:= tunitinfolist.create;
 ffilenamelist:= tfilenamelist.create;
 msedesignparser.updateunitinterface:= {$ifdef FPC}@{$endif}updateunitinterface;
 msedesignparser.gettype:= {$ifdef FPC}@{$endif}gettype;
 msedesignparser.resetunitsearched:= {$ifdef FPC}@{$endif}resetunitsearched;
end;

destructor tsourceupdater.destroy;
begin
 designnotifications.unregisternotification(idesignnotification(self));
 funitinfolist.free;
 ffilenamelist.Free;
 inherited;
end;

procedure tsourceupdater.clear;
begin
 funitinfolist.clear;
 ffilenamelist.clear;
end;

procedure tsourceupdater.unitchanged(const aunit: punitinfoty = nil);
var
 int1: integer;
begin
 if aunit <> nil then begin
  aunit^.interfacecompiled:= false;
 end
 else begin
  for int1:= 0 to funitinfolist.count - 1 do begin
   funitinfolist[int1]^.interfacecompiled:= false;
  end;
 end;
end;

procedure tsourceupdater.unitchanged(const asourcefilename: filenamety);
var
 po1: punitinfoty;
 int1: integer;
begin
 po1:= funitinfolist.finditembysourcefilename(asourcefilename,int1);
 if po1 <> nil then begin
  unitchanged(po1);
 end;
end;

procedure tsourceupdater.resetunitsearched;
       //resets all allreadysearchedflags of rootdeflists
var
 int1: integer;
begin
 for int1:= 0 to funitinfolist.count - 1 do begin
  funitinfolist[int1]^.deflist.allreadysearched:= false;
 end;
end;

function tsourceupdater.getmatchingmethods(const amodule: tmsecomponent;
  const atype: ptypeinfo): msestringarty;
var
 po1: pclassinfoty;
begin
 result:= nil;
 po1:= parsemodule(amodule);
 if po1 <> nil then begin
  result:= po1^.procedurelist.matchedmethodnames(atype,true);
 end;
end;

procedure tsourceupdater.itemsmodified(const adesigner: idesigner;
               const aitem: tobject);
begin
 //dummy
end;

procedure tsourceupdater.componentnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const aitem: tcomponent;
                     const newname: string);
var
 po1: punitinfoty;
 po2: pclassinfoty;
 po3,po4: pcompinfoty;
 str1: string;
 int1: integer;
begin
 try
  po1:= updatemodule(amodule);
 except
  exit; //no source file, no sourcepdate
 end;
 po2:= findclassinfobyinstance(amodule,po1);
 str1:= uppercase(aitem.Name);
 if po2 <> nil then begin
  with po2^.componentlist do begin
   po3:= nil;
   po4:= datapo;
   for int1:= 0 to count - 1 do begin
    if po4^.uppername = str1 then begin
     po3:= po4;
     break;
    end;
    inc(po4);
   end;
   if po3 <> nil then begin
    replacetext(po1,po3^.namepos,po3^.nameend,msestring(newname));
   end;
  end;
 end;
end;

procedure tsourceupdater.moduleclassnamechanging(const adesigner: idesigner;
                    const amodule: tmsecomponent; const newname: string);
begin
end;

procedure tsourceupdater.instancevarnamechanging(const adesigner: idesigner;
                     const amodule: tmsecomponent; const newname: string);
begin
end;

procedure tsourceupdater.iteminserted(const adesigner: idesigner;
            const amodule: tmsecomponent; const aitem: tcomponent);
var
 po1,po4: punitinfoty;
 po2: pclassinfoty;
 po3: pmoduleinfoty;
 pos1: sourceposty;
 str1,str2: msestring;
 classna,unitna: string;
 int1: integer;
 ar1: msestringarty;
 ar2: stringarty;
 first: boolean;
begin
 try
  po1:= updatemodule(amodule);
 except
  exit; //no source file, no sourcepdate
 end;
 updateunit(po1,true);
 po2:= findclassinfobyinstance(amodule,po1);
 str1:= msestring(uppercase(aitem.Name));
 pos1:= emptysourcepos;
 if po2 <> nil then begin
  if (csinline in aitem.componentstate) and 
           designer.checksubmodule(aitem,po3) then begin
   classna:= po3^.moduleclassname;
   po4:= updatemodule(po3^.instance);
   if po4 <> nil then begin
    unitna:= po4^.origunitname;
   end;
  end
  else begin
   classna:= aitem.ClassName;
   unitna:= gettypedata(ptypeinfo(aitem.classinfo))^.unitname;
  end;
  if isemptysourcepos(pos1) then begin
   pos1:= po2^.procedurestart;
  end;
  if not isemptysourcepos(pos1) then begin
   str1:= msestring('   ' + aitem.Name + ': ' + classna+';' + lineend);
   replacetext(po1,pos1,pos1,str1);
  end;
  with po1^.p.interfaceuses do begin
   if (unitna <> '') then begin
    if (startpos.filenum = endpos.filenum) and 
           not isemptysourcepos(startpos) then begin
     str2:= gettext(po1,startpos,endpos);
     ar2:= unitgroups.getneededunits(unitna);
     first:= count = 0;
     for int1:= 0 to high(ar2) do begin
      if (find(ar2[int1]) = nil) then begin
       if not first then begin
        str2:= str2 + ',';
       end
       else begin
        first:= false;
       end;
       str2:= str2 + msestring(ar2[int1]);
      end
     end;
     if str2 <> '' then begin
      ar1:= breaklines(str2);
      for int1:= 0 to high(ar1) do begin
       ar1[int1]:= trim(ar1[int1]);
      end;
      if ar1[0] = '' then begin
       deleteitem(ar1,0);
      end;
      str2:= concatstrings(ar1,'');
      str2:= lineend+' '+
                   limitlinelength(str2,fmaxlinelength,',',1,1);
     end;
     replacetext(po1,startpos,endpos,str2);
    end;
   end;
  end;
 end;
end;

procedure tsourceupdater.itemdeleted(const adesigner: idesigner;
               const amodule: tmsecomponent; const aitem: tcomponent);
var
 po1: punitinfoty;
 po2: pclassinfoty;
 po3: pcompinfoty;
begin
 try
  po1:= updatemodule(amodule);
 except
  exit; //no source file, no sourcepdate
 end;
 po2:= findclassinfobyinstance(amodule,po1);
 if po2 <> nil then begin
  po3:= po2^.componentlist.finditembyname(aitem.name);
  if po3 <> nil then begin
   with po3^ do begin
    replacetext(po1,insertpos,endpos,'');
   end;
  end;
 end;
end;


procedure tsourceupdater.showobjecttext(const adesigner: idesigner; 
              const afilename: filenamety; const backupcreated: boolean);
begin
 //dummy
end;

procedure tsourceupdater.closeobjecttext(const adesigner: idesigner; 
                           const afilename: filenamety; var cancel: boolean);
begin
 //dummy
end;

procedure tsourceupdater.moduleactivated(const adesigner: idesigner;
  const amodule: tmsecomponent);
begin
 //dummy
end;

procedure tsourceupdater.moduledeactivated(const adesigner: idesigner;
  const amodule: tmsecomponent);
begin
 //dummy
end;

procedure tsourceupdater.moduledestroyed(const adesigner: idesigner;
  const amodule: tmsecomponent);
begin
 //dummy
end;

function tsourceupdater.parsemodule(const amodule: tmsecomponent): pclassinfoty;
begin
 result:= findclassinfobyinstance(amodule,updatemodule(amodule));
end;

procedure tsourceupdater.selectionchanged(const adesigner: idesigner;
  const aselection: idesignerSelections);
begin
 //dummy
end;

procedure tsourceupdater.getincludefile(const sender: tparser; const scanner: tscanner);
var
 infile: ttextstream;
begin
 infile:= sourcefo.gettextstream(scanner.filename,false);
 try
  scanner.source:= infile.readdatastring;
 finally
  infile.Free;
 end;
end;

procedure tsourceupdater.updatepascalunit(const infopo: punitinfoty; 
                                             const interfaceonly: boolean);
var
 scanner: tpascalscanner;
 parser: tpascaldesignparser;
 infile: ttextstream;
 int1,int2,int3: integer;
 ar1: stringarty;
 ar3: msestringarty;
begin
 ar3:= nil; //compiler warning
 {
 if not infopo^.interfacecompiled or
       not infopo^.implementationcompiled and not interfaceonly then begin
  if infopo^.unitname <> '' then begin
   funitinfolist.fnamelist.delete(infopo^.unitname);
  end;
  }
  scanner:= tpascalscanner.Create;
  application.beginwait;
  try
   infile:= sourcefo.gettextstream(infopo^.sourcefilename,false);
   scanner.setfilename(infopo^.sourcefilename,designer.designfiles);
   try
    scanner.source:= infile.readdatastring;
   finally
    infile.Free;
   end;
   parser:= tpascaldesignparser.create(infopo,designer.designfiles,
               {$ifdef FPC}@{$endif}getincludefile,interfaceonly);
   try
    parser.includefiledirs:= projectoptions.d.texp.sourcedirs;
    ar1:= nil;
    int3:= 0;
    for int1:= 0 to high(projectoptions.d.texp.defines) do begin
     if int1 > high(projectoptions.d.defineson) then begin
      break;
     end;
     if projectoptions.d.defineson[int1] then begin
      ar3:= splitstring(projectoptions.d.texp.defines[int1],msechar(' '));
      for int2:= 0 to high(ar3) do begin
       additem(ar1,string(ar3[int2]),int3);
      end;
     end;
    end;
    setlength(ar1,int3);
    parser.startdefines:= ar1;
    parser.scanner:= scanner;
    {
    if infopo^.unitname <> '' then begin
     funitinfolist.fnamelist.add(infopo^.unitname,infopo);
    end;
    }
   finally
    parser.Free;
   end;
  finally
   scanner.Free;
   application.endwait;
  end;
// end;
end;

procedure tsourceupdater.updatecunit(const infopo: punitinfoty; 
                                             const interfaceonly: boolean);
var
 scanner: tcscanner;
 parser: tcdesignparser;
 infile: ttextstream;
 int1,int2,int3: integer;
 ar1: stringarty;
 ar3: msestringarty;
begin
 ar3:= nil; //compiler warning
  scanner:= tcscanner.Create;
  application.beginwait;
  try
   infile:= sourcefo.gettextstream(infopo^.sourcefilename,false);
   scanner.setfilename(infopo^.sourcefilename,designer.designfiles);
   try
    scanner.source:= infile.readdatastring;
   finally
    infile.Free;
   end;
   parser:= tcdesignparser.create(infopo,designer.designfiles,
               {$ifdef FPC}@{$endif}getincludefile,interfaceonly);
   try
    parser.includefiledirs:= projectoptions.d.texp.sourcedirs;
    ar1:= nil;
    int3:= 0;
    for int1:= 0 to high(projectoptions.d.texp.defines) do begin
     if int1 > high(projectoptions.d.defineson) then begin
      break;
     end;
     if projectoptions.d.defineson[int1] then begin
      ar3:= splitstring(projectoptions.d.texp.defines[int1],msechar(' '));
      for int2:= 0 to high(ar3) do begin
       additem(ar1,string(ar3[int2]),int3);
      end;
     end;
    end;
    setlength(ar1,int3);
    parser.startdefines:= ar1;
    parser.scanner:= scanner;
   finally
    parser.Free;
   end;
  finally
   scanner.Free;
   application.endwait;
  end;
// end;
end;

procedure tsourceupdater.updateunit(const infopo: punitinfoty; 
                                             const interfaceonly: boolean);
begin
 if not infopo^.interfacecompiled or
       not infopo^.implementationcompiled and not interfaceonly then begin
  if infopo^.unitname <> '' then begin
   funitinfolist.fnamelist.delete(ansistring(infopo^.unitname),true);
  end;
  case infopo^.proglang of
   pl_c: begin
    updatecunit(infopo,interfaceonly);
   end
   else begin
    updatepascalunit(infopo,interfaceonly);
   end;
  end;
  if infopo^.unitname <> '' then begin
   funitinfolist.fnamelist.add(infopo^.unitname,infopo);
  end;
 end;
end;

function tsourceupdater.updatemodule(const amodule: tmsecomponent): punitinfoty;
var
 po1: pmoduleinfoty;
begin
 result:= nil;
 po1:= fdesigner.modules.findmodulebyinstance(amodule);
 if po1 <> nil then begin
  result:= updateformunit(po1^.filename,false);
 end;
end;

function tsourceupdater.updateformunit(const aformfilename: filenamety;
                         const interfaceonly: boolean): punitinfoty;
begin
 result:= funitinfolist.finditembyformfilename(aformfilename);
 if result = nil then begin
  result:= funitinfolist.newitem(pl_pascal);
  with result^ do begin
   formfilename:= aformfilename;
   sourcefilename:= replacefileext(aformfilename,'pas');
  end;
 end;
 updateunit(result,interfaceonly);
 ffilenamelist.add(result^.sourcefilename,result);
end;

procedure tsourceupdater.updateincludefilenum(module: punitinfoty;
                  const filename: filenamety; var filenum: integer);
var
 int1: integer;
begin
 filenum:= 0;
 with module^ do begin
  for int1:= 0 to high(sourcefiles) do begin
   if issamefilename(filename,sourcefiles[int1].filename) then begin
    filenum:= int1 + 1;
    break;
   end;
  end;
 end;
end;

function tsourceupdater.updatesourceunit(const asourcefilename: filenamety;
                out filenum: integer; const interfaceonly: boolean): punitinfoty;
begin
 result:= funitinfolist.finditembysourcefilename(asourcefilename,filenum);
 if result = nil then begin
  result:= funitinfolist.newitem(findprogramlanguage(asourcefilename));
  with result^ do begin
   formfilename:= replacefileext(asourcefilename,'mfm');
   sourcefilename:= asourcefilename;
  end;
  filenum:= 1;
 end;
 updateunit(result,interfaceonly);
 ffilenamelist.add(asourcefilename,result);
end;

function tsourceupdater.updateunitinterface(const aunitname: string): punitinfoty;
var
 str1: filenamety;
 int1: integer;
begin
 result:= funitinfolist.finditembyunitname(aunitname);
 if result <> nil then begin
  updateunit(result,true);
 end
 else begin
  str1:= findunitfile(msestring(aunitname));
  if str1 <> '' then begin
   result:= updatesourceunit(str1,int1,true);
  end
  else begin
   result:= nil;
  end;
 end;
end;

procedure tsourceupdater.beforemake(const adesigner: idesigner;
               const maketag: integer; var abort: boolean);
begin
 //dummy
end;

procedure tsourceupdater.aftermake(const adesigner: idesigner;
                      const exitcode: integer);
begin
 //dummy
end;

procedure tsourceupdater.beforefilesave(const adesigner: idesigner;
               const afilename: filenamety);
begin
 //dummy
end;

function tsourceupdater.findcfunctionimplementation(const aname: ansistring;
               out headerstart: sourceposty;
               out headerstop: sourceposty): boolean;
var
// int1: integer;
 po3: pfunctioninfoty;
// int2: integer;
// mstr1: filenamety;
begin
 result:= false;
 po3:= cglobals.findfunction(aname);
 if po3 <> nil then begin
  headerstart:= po3^.start;
  headerstop:= po3^.stop;
  result:= true;
 end;
end;

end.

