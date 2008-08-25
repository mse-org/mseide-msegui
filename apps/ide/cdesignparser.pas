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
   constructor create(unitinfopo: punitinfoty;
              const afilelist: tmseindexednamelist;
              const getincludefile: getincludefileeventty;
              const ainterfaceonly: boolean; const atext: ansistring); overload;
   procedure parse; override;  
 end;

implementation
//uses
// msedesigner;
 
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

constructor tcdesignparser.create(unitinfopo: punitinfoty;
              const afilelist: tmseindexednamelist;
              const getincludefile: getincludefileeventty;
              const ainterfaceonly: boolean; const atext: ansistring); overload;
begin
 create(unitinfopo,afilelist,getincludefile,ainterfaceonly);
 create(afilelist,atext);
end;

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
 ch1: char;
begin
 result:= false;
 mark;
 if getorigname(lstr1) and getorigname(lstr2) then begin
  if parsefunctionparams then begin
   if checkoperator(';') then begin
    result:= true;  //header
   end
   else begin
    if testoperator('{') then begin
     if parseblock then begin
      result:= true;
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
end;

function tcdesignparser.parsestatement: boolean;
begin
 result:= true;
// case 
 if not parsefunction then begin
  if not parsetypedef then begin
   if not parsevardef then begin
    skipstatement;
   end;
  end;
 end;
end;

procedure tcdesignparser.parse;
begin
 inherited;
 while not eof do begin
  parsestatement;
 end;
end;

end.
