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
 msegui,msedrag,msestrings,msetypes,msegraphutils,mseglob,mseguiglob,mseclasses;
 
type

 tmimedragobject = class;
 
 imimesource = interface(iobjectlink)
   procedure convertmimedata(const sender: tmimedragobject;
                                      var adata: string; const atypeindex);
   procedure convertmimetext(const sender: tmimedragobject;
                                      var adata: msestring; const atypeindex);
 end;
  
 tmimedragobject = class(tdragobject,iobjectlink)
  private
   fdata: string;
   ftext: msestring;
   fobjectlinker: tobjectlinker;
   procedure setformatindex(const avalue: integer);
  protected
   fformats: msestringarty;
   fformatistext: booleanarty;
   fformatindex: integer;
   fintf: imimesource;
   function getdata: string; virtual;
   function gettext: msestring; virtual;
   procedure setdata(const avalue: string); virtual;
   procedure settext(const avalue: msestring); virtual;
    //iobjectlink
   procedure link(const source,dest: iobjectlink; valuepo: pointer = nil;
                   ainterfacetype: pointer = nil; once: boolean = false);
   procedure unlink(const source,dest: iobjectlink; valuepo: pointer = nil);
   procedure objevent(const asender: iobjectlink; const event: objecteventty);
   function getinstance: tobject;
  public
   constructor create(const asender: tobject; var instance: tdragobject;
               const apickpos: pointty; const aformats: array of msestring;
               const aformatistext: array of boolean;
               const aactions: dndactionsty = [];
                             const aintf: imimesource = nil); virtual;
   constructor createwrite(const asender: tobject; var instance: tdragobject;
               const apickpos: pointty; const aformats: array of msestring;
               const aformatistext: array of boolean;
               const aactions: dndactionsty = [];
               const aintf: imimesource = nil);
   destructor destroy; override;
   function checkformat(const awanted: array of msestring): boolean;
   property formats: msestringarty read fformats;         //do not modify
   property formatistext: booleanarty read fformatistext; //do not modify
   property formatindex: integer read fformatindex 
                               write setformatindex default -1;
                       //-1 -> none selected
   property data: string read getdata write setdata;
   property text: msestring read gettext write settext;
   function convertmimedata(const atypeindex: integer): string; virtual;
   function convertmimetext(const atypeindex: integer): msestring; virtual;
 end;

implementation
uses
 msearrayutils;
 
{ tmimedragobject }

constructor tmimedragobject.create(const asender: tobject;
               var instance: tdragobject; const apickpos: pointty;
               const aformats: array of msestring;
               const aformatistext: array of boolean;
               const aactions: dndactionsty = [];
                             const aintf: imimesource = nil);
begin
 fobjectlinker:= tobjectlinker.create(iobjectlink(self),nil);
 fformats:= opentodynarraym(aformats);
 fformatistext:= opentodynarraybo(aformatistext);
 setlength(fformatistext,length(fformats));
 factions:= aactions;
 fformatindex:= -1;
 fintf:= aintf;
 if fintf <> nil then begin
  fobjectlinker.link(iobjectlink(self),fintf);
 end;
 inherited create(asender,instance,apickpos,aactions);
end;

constructor tmimedragobject.createwrite(const asender: tobject;
               var instance: tdragobject; const apickpos: pointty;
               const aformats: array of msestring;
               const aformatistext: array of boolean;
               const aactions: dndactionsty = [];
               const aintf: imimesource = nil);
begin
 include(fstate,dos_write);
 create(asender,instance,apickpos,aformats,aformatistext,aactions,aintf);
end;

destructor tmimedragobject.destroy;
begin
 fobjectlinker.free;
 inherited;
end;

procedure tmimedragobject.setformatindex(const avalue: integer);
begin
 if avalue < 0 then begin
  fformatindex:= -1;
 end
 else begin
  checkarrayindex(fformats,avalue);
  fformatindex:= avalue;
 end;
end;

function tmimedragobject.checkformat(
                              const awanted: array of msestring): boolean;
var
 int1,int2: integer;
begin
 result:= false;
 for int1:= 0 to high(awanted) do begin
  for int2:= 0 to high(fformats) do begin
   if awanted[int1] = fformats[int2] then begin
    result:= true;
    fformatindex:= int2;
    exit;
   end;
  end;
 end;
end;

function tmimedragobject.getdata: string;
begin
 if fformatindex >= 0 then begin
  result:= convertmimedata(fformatindex);
 end
 else begin
  if fdata = '' then begin
   result:= ftext;
  end
  else begin
   result:= fdata;
  end;
 end;
end;

function tmimedragobject.gettext: msestring;
begin
 if fformatindex >= 0 then begin
  result:= convertmimetext(fformatindex);
 end
 else begin
  if ftext = '' then begin
   result:= fdata;
  end
  else begin
   result:= ftext;
  end;
 end;
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

function tmimedragobject.convertmimedata(const atypeindex: integer): string;
begin
 if fdata = '' then begin
  result:= ftext;
 end
 else begin
  result:= fdata;
 end;
 if fintf <> nil then begin
  fintf.convertmimedata(self,result,atypeindex);
 end;
end;

function tmimedragobject.convertmimetext(const atypeindex: integer): msestring;
begin
 if ftext = '' then begin
  result:= fdata;
 end
 else begin
  result:= ftext;
 end;
 if fintf <> nil then begin
  fintf.convertmimetext(self,result,atypeindex);
 end;
end;

procedure tmimedragobject.link(const source: iobjectlink;
               const dest: iobjectlink; valuepo: pointer = nil;
               ainterfacetype: pointer = nil; once: boolean = false);
begin
 fobjectlinker.link(source,dest,valuepo,ainterfacetype,once);
end;

procedure tmimedragobject.unlink(const source: iobjectlink;
               const dest: iobjectlink; valuepo: pointer = nil);
begin
 fobjectlinker.unlink(source,dest,valuepo);
end;

procedure tmimedragobject.objevent(const asender: iobjectlink;
               const event: objecteventty);
begin
 if (asender = fintf) and (event = oe_destroyed) then begin
  destroy;
 end;
end;

function tmimedragobject.getinstance: tobject;
begin
 result:= self;
end;

end.
