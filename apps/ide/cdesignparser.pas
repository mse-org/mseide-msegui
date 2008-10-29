{ MSEide Copyright (c) 2008 by Martin Schreiber
   
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
 mseparser,msedesignparser,mselist,msestrings;
 
type

 tcdesignparser = class(tcparser,idesignparser)
  private
   funitinfopo: punitinfoty;
   fimplementation: boolean;
   finterface: boolean;
   finterfaceonly: boolean;
   fnoautoparse: boolean;
   ffunctionlevel: integer;
  protected
   procedure initidents; override;
   function parsefunction: boolean;
   function parsefunctionparams: boolean;
   function parseblock: boolean;
   function parsetypedef: boolean;
   function parsevardef: boolean;
   function parsestatement: boolean;
   function dogetincludefile(const afilename: filenamety;
                     const astatementstart,astatementend: sourceposty): tscanner; override;
  public
   constructor create(unitinfopo: punitinfoty;
              const afilelist: tmseindexednamelist;
              const getincludefile: getincludefileeventty;
              const ainterfaceonly: boolean); overload;
   constructor create(const afilelist: tmseindexednamelist; 
                 const atext: string); overload;
   procedure parse; override;  
   procedure clear; override;
 end;
 
procedure parsecdef(const adef: pdefinfoty; out atext: string; out scope: tdeflist);

implementation
uses
 sourceupdate,msedesigner;

procedure parsecdef(const adef: pdefinfoty; out atext: string; out scope: tdeflist);
 //add used identifiers
var
 parser: tcparser;

 procedure doaddidents;
 begin
  with parser do begin
   while checkoperator('*') do begin
   end;
   scope.addidents(parser);
   if checkoperator('[') then begin
    findoperator(']');
   end;
   while checkoperator('*') do begin
   end;
   scope.addidents(parser);
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

function tcdesignparser.parsefunction: boolean;
var
 lstr1,lstr2: lstringty;
 str1: string;
 ch1: char;
 pos1: sourceposty;
 po1: pfunctioninfoty;
 po2: pfunctionheaderinfoty;
begin
 inc(ffunctionlevel);
 result:= false;
 skipwhitespace;
 mark;
 pos1:= sourcepos;
 with funitinfopo^ do begin
  if getorigname(lstr1) and getorigname(lstr2) then begin
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
      if ffunctionlevel = 1 then begin
       po1:= c.functions.newitem;
       po1^.name:= str1;
      end;      
      deflist.beginnode(str1,syk_procimp,pos1,sourcepos);
                          //new scope
      parseblock;
      deflist.endnode(sourcepos);
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
 lstr1,lstr2: lstringty;
 ch1: char;
 bo1: boolean;
 pos1: sourceposty;
begin
 result:= true;
 bo1:= ffunctionlevel = 0;
 mark;
 if not bo1 then begin //in function body
  repeat
  until getident = -1; //remove keywords
  pos1:= sourcepos;
  if getnamenoident(lstr1) then begin
   repeat
    ch1:= getoperator;
    case ch1 of
     '(': begin
      funitinfopo^.deflist.actnode.addident(pos1,lstr1.len);
      findclosingbracket; //function call
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
   bo1:= true;
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

end.
