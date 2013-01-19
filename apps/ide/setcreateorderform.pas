{ MSEide Copyright (c) 1999-2013 by Martin Schreiber
   
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
unit setcreateorderform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 classes,mclasses,msegui,mseclasses,mseforms,msestat,msestatfile,msestrings,
 msedatalist,
 msedrawtext,mseevent,msegraphics,msegraphutils,msegrids,mseguiglob,mseglob,
 msepipestream,msetypes,msesimplewidgets,msewidgets,msestringcontainer;

type
 tsetcreateorderfo = class(tmseform)
   statfile1: tstatfile;
   grid: tstringgrid;
   tbutton1: tbutton;
   tbutton2: tbutton;
   c: tstringcontainer;
   procedure formonclosequery(const sender: tcustommseform;
                   var amodalresult: modalresultty);
  private
   fmodule: tcomponent;
  public
   constructor create(const amodule: tcomponent; const acurrentcompname: string);
                       reintroduce;
 end;
var
 setcreateorderfo: tsetcreateorderfo;
 
implementation
uses
 setcreateorderform_mfm,msedesigner;
type
 stringconsttsty = (
  setcomponentcreateorder          //0 Set Component create Order of
 );
  
{ tsetcreateorderfo }

constructor tsetcreateorderfo.create(const amodule: tcomponent;
                         const acurrentcompname: string);
var
 int1: integer;
// str1: string;
begin
 inherited create(nil);
 caption:= c[ord(setcomponentcreateorder)]+' '+amodule.name;
 fmodule:= amodule;
 with amodule do begin
  for int1:= 0 to componentcount - 1 do begin
   with components[int1] do begin
    if not hasparent or (csinline in componentstate) then begin
     grid.appendrow([msestring(name),msestring(classname)]);
     if acurrentcompname = name then begin
      grid.row:=int1;
     end;
    end;
   end;
  end;
 end;
end;

procedure tsetcreateorderfo.formonclosequery(const sender: tcustommseform;
               var amodalresult: modalresultty);
//var
// int1: integer;
// comp1: tcomponent;
begin
 if amodalresult = mr_ok then begin
  setcomponentorder(fmodule,grid[0].datalist.asarray);
  designer.componentmodified(fmodule);
 end;
end;

end.
