{ MSEgui Copyright (c) 2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msemime;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msegui,msedrag,msestrings,msetypes,msegraphutils;
 
type
 tmimedragobject = class(tdragobject)
  private
   ftypes: stringarty;
   ftypeindex: integer;
   fdata: string;
   ftext: msestring;
   procedure settypeindex(const avalue: integer);
  protected
   function getdata: string; virtual;
   function gettext: msestring; virtual;
   procedure setdata(const avalue: string); virtual;
   procedure settext(const avalue: msestring); virtual;
  public
   constructor create(const asender: tobject; var instance: tdragobject;
               const apickpos: pointty; const atypes: stringarty);
   function checktypes(const awanted: array of string): boolean;
   property types: stringarty read ftypes; //do not modify
   property typeindex: integer read ftypeindex write settypeindex default -1;
                       //-1 -> none selected
   property data: string read getdata write setdata;
   property text: msestring read gettext write settext;
 end;

implementation
uses
 msearrayutils;
 
{ tmimedragobject }

constructor tmimedragobject.create(const asender: tobject;
               var instance: tdragobject; const apickpos: pointty;
               const atypes: stringarty);
begin
 ftypes:= atypes;
 ftypeindex:= -1;
 inherited create(asender,instance,apickpos);
end;

procedure tmimedragobject.settypeindex(const avalue: integer);
begin
 if avalue < 0 then begin
  ftypeindex:= -1;
 end
 else begin
  checkarrayindex(ftypes,avalue);
  ftypeindex:= avalue;
 end;
end;

function tmimedragobject.checktypes(const awanted: array of string): boolean;
var
 int1,int2: integer;
begin
 result:= false;
 for int1:= 0 to high(awanted) do begin
  for int2:= 0 to high(ftypes) do begin
   if awanted[int1] = ftypes[int2] then begin
    result:= true;
    ftypeindex:= int2;
    exit;
   end;
  end;
 end;
end;

function tmimedragobject.getdata: string;
begin
 result:= fdata;
end;

function tmimedragobject.gettext: msestring;
begin
 result:= ftext;
end;

procedure tmimedragobject.setdata(const avalue: string);
begin
 ftext:= '';
 fdata:= avalue;
end;

procedure tmimedragobject.settext(const avalue: msestring);
begin
 fdata:= '';
 ftext:= avalue;
end;

end.
