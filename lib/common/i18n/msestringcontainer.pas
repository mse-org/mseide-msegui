{ MSEgui Copyright (c) 2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msestringcontainer;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseclasses,msedatalist,classes,msehash,msestrings;
 
type
 tcontainerstringdatalist = class(tdoublemsestringdatalist)
 end;
 
 tstringcontainer = class;

 getstringeventty = procedure(const sender: tstringcontainer;
                      const aindex: integer; var avalue: msestring) of object;

 tstringcontainer = class(tmsecomponent)
  private
   fstrings: tcontainerstringdatalist;
   fhash: tintegermsestringhashdatalist;
   fongetstring: getstringeventty;
   procedure setstrings(const avalue: tcontainerstringdatalist);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function n(const aname: msestring): msestring; //by name
   function i(const aindex: integer): msestring;  //by index
  published
   property strings: tcontainerstringdatalist read fstrings write setstrings;
                   //a = strings, b = names
   property ongetstring: getstringeventty read fongetstring write fongetstring;
 end;
 
implementation

{ tstringcontainer }

constructor tstringcontainer.create(aowner: tcomponent);
begin
 fstrings:= tcontainerstringdatalist.create;
 fhash:= tintegermsestringhashdatalist.create;
 inherited;
end;

destructor tstringcontainer.destroy;
begin
 inherited;
 fstrings.free;
 fhash.free;
end;

function tstringcontainer.n(const aname: msestring): msestring;
var
 po1: pdoublemsestringaty;
 int1: integer;
begin
 with fstrings do begin
  if not (dls_sortio in fstate) then begin
   include(fstate,dls_sortio);
   fhash.clear;
   fhash.capacity:= count;
   po1:= datapo;
   for int1:= 0 to count-1 do begin
    fhash.add(po1^[int1].b,int1);
   end;
  end;
 end;
 result:= i(fhash.find(aname));
end;

function tstringcontainer.i(const aindex: integer): msestring;
begin
 if (aindex < 0) or (aindex >= fstrings.count) then begin
  result:= '';
 end
 else begin
  result:= pdoublemsestringaty(fstrings.datapo)^[aindex].a;
  if assigned(fongetstring) then begin
   fongetstring(self,aindex,result);
  end;
 end;
end;

procedure tstringcontainer.setstrings(const avalue: tcontainerstringdatalist);
begin
 fstrings.assign(avalue);
end;

end.
