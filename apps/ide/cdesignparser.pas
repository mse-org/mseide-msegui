{ MSEide Copyright (c) 2012 by Martin Schreiber

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
unit cdesignparser;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseparser,msedesignparser,mselist,msestrings,msehash;

type

 tcdesignparser = class(tcparser,idesignparser)
  private
   funitinfopo: punitinfoty;
//   fimplementation: boolean;
//   finterface: boolean;
   finterfaceonly: boolean;
   fnoautoparse: boolean;
   ffunctionlevel: integer;
  protected
   function parsefunction: boolean;
   function parsefunctionparams: boolean;
   function parseblock: boolean;
   function parsetypedef: boolean;
   function parsevardef: boolean;
   function parsestatement: boolean;
  public
   constructor create(unitinfopo: punitinfoty;
              const afilelist: tmseindexednamelist;
              const getincludefile: getincludefileeventty;
              const ainterfaceonly: boolean); overload;
   constructor create(const afilelist: tmseindexednamelist;
                 const atext: string); overload;
   procedure initidents; override;
   function dogetincludefile(const afilename: filenamety;
           const astatementstart,astatementend: sourceposty): tscanner; override;
   procedure parse; override;
   procedure clear; override;
 end;

 tcfunctions = class(tfunctions)
 end;

 tcunitinfo = class(tunitinfo)
  public
   constructor create;
   destructor destroy; override;
 end;

 tcrootdeflist = class(trootdeflist)
  protected
   procedure finalizerecord(var item); override;
 end;

 cglobfuncinfoty = record
  list: tcrootdeflist;
  id: integer;
 end;
 pcglobfuncinfoty = ^cglobfuncinfoty;
 cglobfunchashdataty = record
  header: hashheaderty;
  data: cglobfuncinfoty;
 end;
 pcglobfunchashdataty = ^cglobfunchashdataty;

 tcglobals = class(thashdatalist)
  private
   fclosing: boolean;
   flistparam: tcrootdeflist;
   fidparam: integer;
   fansistringparam: ansistring;
   procedure checkfunctioninfo(const aitem: phashdataty; var accept: boolean);
   procedure checkfindname(var stop: boolean);
  protected
   procedure add(const alist: tcrootdeflist; const aid: integer);
//   procedure checkexact(const aitemdata; var accept: boolean); override;
   function hashkey(const akey): hashvaluety; override;
   function checkkey(const akey; const aitem: phashdataty): boolean; override;
   procedure delete(const alist: tcrootdeflist; const aid: integer);
   function checkfind(const aname: ansistring): pcglobfuncinfoty;
   function getrecordsize(): int32 override;
  public
   property closing: boolean read fclosing;
//   constructor create;
   function finddef(const aname: ansistring): pdefinfoty;
   function findfunction(const aname: ansistring): pfunctioninfoty;
 end;

 tcprocdeflist = class(tdeflist)
 end;

procedure parsecdef(const adef: pdefinfoty; out atext: string; out scope: tdeflist);
function cglobals: tcglobals;
procedure beginfinalizecglobals;
procedure finalizecglobals;

implementation
uses
 sourceupdate,msedesigner,sysutils,projecttreeform;
var
 fcglobals: tcglobals;

function cglobals: tcglobals;
begin
 if fcglobals = nil then begin
  fcglobals:= tcglobals.create;
 end;
 result:= fcglobals;
end;

procedure finalizecglobals;
begin
 freeandnil(fcglobals);
end;

procedure beginfinalizecglobals;
begin
 if fcglobals <> nil then begin
  fcglobals.fclosing:= true;
 end;
end;

procedure parsecdef(const adef: pdefinfoty; out atext: string; out scope: tdeflist);
 //add used identifiers
var
 parser: tcparser;

 procedure doaddidents;
 begin
  with parser do begin
   while checkoperator('*') do begin
   end;
   scope.addidentpath(parser,'.');
   if checkoperator('[') then begin
    findoperator(']');
   end;
   while checkoperator('*') do begin
   end;
   scope.addidentpath(parser,'.');
  end;
 end;

 procedure dofunctionparameters;
 begin
  with parser do begin
   while not eof do begin
    doaddidents; //type, parameter
    if checkoperator(')') then begin
     break;
    end;
    if not checkoperator(';') then begin
     nexttoken;
    end;
   end;
  end;
 end;

begin
 scope:= tdeflist.create(adef^.kind,true);
 atext:= sourceupdater.getdefinfotext(adef);
 if atext <> '' then begin
  parser:= tcparser.create(designer.designfiles,atext);
  try
   with parser do begin
    doaddidents; //type, function name
    if checkoperator('(') then begin
     dofunctionparameters;
    end;
    if checkoperator('{') then begin
     repeat
      doaddidents;
      if checkoperator('=') then begin //assignment
       doaddidents;
       checkoperator(';');
      end
      else begin
       if checkoperator('(') then begin
        dofunctionparameters;
       end
       else begin
        nexttoken;
       end;
      end;
     until eof or checkoperator('}');
    end;
   end;
  finally
   parser.free;
  end;
 end;
end;

{ tcdesignparser }

constructor tcdesignparser.create(unitinfopo: punitinfoty;
               const afilelist: tmseindexednamelist;
               const getincludefile: getincludefileeventty;
               const ainterfaceonly: boolean);
begin
 finterfaceonly:= ainterfaceonly;
 inherited create(afilelist);
 funitinfopo:= unitinfopo;
 funitinfopo^.interfacecompiled:= false;
 funitinfopo^.implementationcompiled:= false;
 ongetincludefile:= getincludefile;
end;

constructor tcdesignparser.create(const afilelist: tmseindexednamelist;
                 const atext: string);
begin
 fnoautoparse:= true;
 inherited create(afilelist,atext);
end;

{
constructor tcdesignparser.create(unitinfopo: punitinfoty;
              const afilelist: tmseindexednamelist;
              const getincludefile: getincludefileeventty;
              const ainterfaceonly: boolean; const atext: ansistring);
begin
 create(unitinfopo,afilelist,getincludefile,ainterfaceonly);
 create(afilelist,atext);
end;
}
function tcdesignparser.parsetypedef: boolean;
begin
 result:= false;
end;

function tcdesignparser.parsevardef: boolean;
begin
 result:= false;
end;

function tcdesignparser.parsefunctionparams: boolean;
begin
 result:= false;
 mark;
 if checkoperator('(') then begin
  result:= findoperator(')');
 end;
 if result then begin
  pop;
 end
 else begin
  back;
 end;
end;

function tcdesignparser.parseblock: boolean;
var
 ch1: char;
begin
 result:= true;
 skipwhitespace;
 mark;
 if checkoperator('{') then begin
  while not eof do begin
   ch1:= getoperator;
   case ch1 of
    '}': begin
     break;
    end;
    '{': begin
     parseblock();
    end;
    else begin
     parsestatement;
    end;
   end;
  end;
 end;
 if result then begin
  pop;
 end
 else begin
  back;
 end;
end;

function tcdesignparser.parsefunction: boolean; //todo: optimize
var
 {lstr1,}lstr2: lstringty;
 str1: string;
// ch1: char;
 pos1: sourceposty;
// po1: pfunctioninfoty;
 po2: pfunctionheaderinfoty;
 static: boolean;
 bo1: boolean;
begin
 inc(ffunctionlevel);
 result:= false;
 skipwhitespace;
 mark;
 pos1:= sourcepos;
 with funitinfopo^ do begin
  static:= false;
  bo1:= false;
  while not eof do begin
   case fto^.kind of
    tk_name: begin
     if checkident(ord(cid_static)) then begin
      static:= true;
     end
     else begin
      nexttoken;
     end;
    end;
    tk_operator: begin
     if fto^.op = '(' then begin
      bo1:= true;
      break;
     end
     else begin
      if fto^.op = ';' then begin
       break;
      end;
      nexttoken;
     end;
    end;
    else begin
     nexttoken;
    end;
   end;
  end;
  if bo1 then begin
   lastnonwhitetoken;
   if getorigname(lstr2) then begin //function name
    if parsefunctionparams then begin
     if (ffunctionlevel = 1) and testoperator(';') then begin
      po2:= c.functionheaders.newitem;
      po2^.name:= lstringtostring(lstr2);
      deflist.add(pos1,sourcepos,po2);
      nexttoken;
      result:= true;  //header
     end
     else begin
      if testoperator('{') then begin
       result:= true;
       str1:= lstringtostring(lstr2);
       with deflist.beginnode(str1,syk_procimp,pos1,sourcepos)^ do begin
                           //new scope
        if ffunctionlevel = 1 then begin
         include(symbolflags,syf_global);
         c.functions.add(str1,pos1,sourcepos);
        end;
       end;
       parseblock;
       deflist.endnode(sourcepos);
       if not static and (ffunctionlevel = 1) then begin
        cglobals.add(tcrootdeflist(deflist),deflist.infocount-1);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
 if result then begin
  pop;
 end
 else begin
  back;
 end;
 dec(ffunctionlevel);
end;

function tcdesignparser.parsestatement: boolean;
var
 lstr1{,lstr2}: lstringty;
 ch1: char;
 bo1: boolean;
 pos1: sourceposty;
begin
 result:= true;
 bo1:= ffunctionlevel = 0;
 skipwhitespace;
 mark;
 if not bo1 then begin //in function body
  skipidents;          //remove keywords
  pos1:= sourcepos;
  if getnamenoident(lstr1) then begin
   repeat
    ch1:= getoperator;
    case ch1 of
     '(': begin
      funitinfopo^.deflist.actnode.startident(pos1,lstr1.len);
//      funitinfopo^.deflist.actnode.addident(pos1,lstr1.len);
      findclosingbracket; //function call
      funitinfopo^.deflist.actnode.endident(self);
     end;
     '=': begin
      skipstatement;      //assignment
      break;
     end;
     ';': begin
      break;
     end;
     else begin
      bo1:= true;
      break;
     end;
    end;
   until ch1 = #0;
  end
  else begin
   if checkoperator('{') then begin
    parseblock;
   end
   else begin
    bo1:= true;
   end;
  end;
 end;
 if bo1 then begin
  back;
  if not parsefunction then begin
   if not parsetypedef then begin
    if not parsevardef then begin
     skipstatement;
    end;
   end;
  end;
 end
 else begin
  pop;
 end;
end;

procedure tcdesignparser.parse;
//var
// po1: pfunctioninfoty;
// int1: integer;
begin
 inherited;
 if fnoautoparse then begin
  exit;
 end;
 initcompinfo(funitinfopo^);
 while not eof do begin
  parsestatement;
 end;
 afterparse(self,funitinfopo^,true);
 projecttree.cmodules.modulecompiled(funitinfopo^.sourcefilename);
end;

procedure tcdesignparser.clear;
begin
 inherited;
 ffunctionlevel:= 0;
end;

function tcdesignparser.dogetincludefile(const afilename: filenamety;
               const astatementstart: sourceposty;
               const astatementend: sourceposty): tscanner;
begin
 result:= inherited dogetincludefile(afilename,astatementstart,astatementend);
 if result <> nil then begin
  addincludefile(funitinfopo^,afilename,astatementstart,astatementend);
 end;
end;

procedure tcdesignparser.initidents;
begin
 setidents(cidents);
end;

{ tcunitinfo }

constructor tcunitinfo.create;
begin
 with info do begin
  proglang:= pl_c;
  c.functionheaders:= tfunctionheaders.create;
  c.functions:= tcfunctions.create;
  if deflist = nil then begin
   deflist:= tcrootdeflist.create(@info);
  end;
 end;
 inherited;
end;

destructor tcunitinfo.destroy;
//var
// int1: integer;
// po1: pfunctioninfoty;
begin
 with info do begin
  c.functionheaders.free;
  c.functions.free;
 end;
 inherited;
end;

{ tcglobals }
{
constructor tcglobals.create;
begin
 inherited create(sizeof(cglobfuncinfoty));
end;
}
procedure tcglobals.add(const alist: tcrootdeflist; const aid: integer);
var
 po1: pcglobfunchashdataty;
begin
 with alist.finfos[aid] do begin
  po1:= pcglobfunchashdataty(internaladd(name));
 end;
 with po1^.data do begin
  list:= alist;
  id:= aid;
 end;
end;

function tcglobals.hashkey(const akey): hashvaluety;
begin
 result:= stringhash(ansistring(akey));
end;

procedure tcglobals.checkfunctioninfo(const aitem: phashdataty;
                                                  var accept: boolean);
begin
 with pcglobfunchashdataty(aitem)^.data do begin
  accept:= (list = flistparam) and (id = fidparam);
 end;
end;

procedure tcglobals.delete(const alist: tcrootdeflist; const aid: integer);
var
 po1: phashdataty;
begin
 flistparam:= alist;
 fidparam:= aid;
 with alist.finfos[aid] do begin
  po1:= internalfind(name,{$ifdef FPC}@{$endif}checkfunctioninfo);
 end;
 if po1 <> nil then begin
  internaldeleteitem(po1);
 end;
end;

function tcglobals.checkkey(const akey; const aitem: phashdataty): boolean;
begin
 with pcglobfunchashdataty(aitem)^.data do begin
  with list.finfos[id] do begin
   result:= ansistring(akey) = name;
  end;
 end;
end;

procedure tcglobals.checkfindname(var stop: boolean);
begin
 stop:= internalfind(fansistringparam) <> nil;
end;

function tcglobals.checkfind(const aname: ansistring): pcglobfuncinfoty;
var
 po1: pcglobfunchashdataty;
begin
 result:= nil;
 po1:= pcglobfunchashdataty(internalfind(aname));
 if po1 = nil then begin
  fansistringparam:= aname;
  projecttree.cmodules.parse({$ifdef FPC}@{$endif}checkfindname);
  po1:= pcglobfunchashdataty(internalfind(aname));
 end;
 if po1 <> nil then begin
  result:= @po1^.data;
 end;
end;

function tcglobals.getrecordsize(): int32;
begin
 result:= sizeof(cglobfunchashdataty);
end;

function tcglobals.finddef(const aname: ansistring): pdefinfoty;
var
 po1: pcglobfuncinfoty;
begin
 result:= nil;
 po1:= checkfind(aname);
 if po1 <> nil then begin
  with po1^ do begin
   result:= @list.finfos[id];
  end;
 end;
end;

function tcglobals.findfunction(const aname: ansistring): pfunctioninfoty;
var
 po1: pcglobfunchashdataty;
begin
 result:= nil;
 po1:= pcglobfunchashdataty(internalfind(aname));
 if po1 <> nil then begin
  with po1^.data do begin
   with list.unitinfopo^ do begin
    if proglang = pl_c then begin
     result:= c.functions.find(aname);
    end;
   end;
  end;
 end;
end;

{ tcrootdeflist }

procedure tcrootdeflist.finalizerecord(var item);
begin
 if (fcglobals <> nil) and not fcglobals.closing then begin
  with finfos[defnamety(item).id] do begin
   if (kind = syk_procimp) and (syf_global in symbolflags) then begin
    fcglobals.delete(self,defnamety(item).id);
   end;
  end;
 end;
 inherited;
end;
initialization
finalization
 finalizecglobals;
end.
