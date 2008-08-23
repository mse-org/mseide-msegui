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
   procedure parsefunction(const atype,aname: lstringty);
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

procedure tcdesignparser.parsefunction(const atype: lstringty;
               const aname: lstringty);
begin
end;

procedure tcdesignparser.parse;
var
 lstr1,lstr2: lstringty;
 ch1: char;
begin
 inherited;
 while not eof do begin
  if getorigname(lstr1) and getorigname(lstr2) then begin
   ch1:= getoperator;
   case ch1 of 
    '(': begin
     parsefunction(lstr1,lstr2);
    end;
   end;
  end;
 end;
end;

end.
