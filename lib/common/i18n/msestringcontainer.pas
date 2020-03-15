{ MSEgui Copyright (c) 2012-2013 by Martin Schreiber

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
 msetypes,mseclasses,msedatalist,classes,mclasses,msehash,msestrings;

type
 tstringcontainer = class;

 getstringeventty = procedure(const sender: tobject;
                      const aindex: integer; var avalue: msestring) of object;

 tcustomstringcontainer = class(tmsecomponent)
  private
   fonreadstate: notifyeventty;
   foneventloopstart: notifyeventty;
  protected
   procedure readstate(reader: treader); override;
   procedure doasyncevent(var atag: integer); override;
  published
   property onreadstate: notifyeventty read fonreadstate write fonreadstate;
   property oneventloopstart: notifyeventty read foneventloopstart
                                                    write foneventloopstart;
 end;

 tstringcontainer = class(tcustomstringcontainer)
  private
   fstrings: tmsestringdatalist;
   fongetstring: getstringeventty;
   procedure setstrings(const avalue: tmsestringdatalist);
  protected
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function i(const aindex: integer): msestring;  //by index
   property byindex[const aindex: integer]: msestring read i; default;
  published
   property strings: tmsestringdatalist read fstrings write setstrings;
   property ongetstring: getstringeventty read fongetstring write fongetstring;
 end;

 tkeystringdatalist = class(tdoublemsestringdatalist)
 end;

 tkeystringcontainer = class(tcustomstringcontainer)
  private
   fstrings: tkeystringdatalist;
   fhash: tintegermsestringhashdatalist;
   fongetstring: getstringeventty;
   procedure setstrings(const avalue: tkeystringdatalist);
  protected
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   function k(const akey: msestring): msestring; //by key
   function i(const aindex: integer): msestring;  //by index
   property byindex[const aindex: integer]: msestring read i; default;
  published
   property strings: tkeystringdatalist read fstrings write setstrings;
                   //a = strings, b = keys
   property ongetstring: getstringeventty read fongetstring write fongetstring;
 end;

implementation

{ tcustomstringcontainer }

procedure tcustomstringcontainer.readstate(reader: treader);
begin
 inherited;
 if assigned(fonreadstate) then begin
  fonreadstate(self);
 end;
 if assigned(foneventloopstart) then begin
  asyncevent;
 end;
end;

procedure tcustomstringcontainer.doasyncevent(var atag: integer);
begin
 inherited;
 if canevent(tmethod(foneventloopstart)) then begin
  foneventloopstart(self);
 end;
end;

{ tstringcontainer }

constructor tstringcontainer.create(aowner: tcomponent);
begin
 fstrings:= tmsestringdatalist.create;
 inherited;
end;

destructor tstringcontainer.destroy;
begin
 inherited;
 fstrings.free;
end;

function tstringcontainer.i(const aindex: integer): msestring;
begin
 if (aindex < 0) or (aindex >= fstrings.count) then begin
  result:= '';
 end
 else begin
  result:= pmsestringaty(fstrings.datapo)^[aindex];
  if assigned(fongetstring) then begin
   fongetstring(self,aindex,result);
  end;
 end;
end;

procedure tstringcontainer.setstrings(const avalue: tmsestringdatalist);
begin
 fstrings.assign(avalue);
end;

{ tkeystringcontainer }

constructor tkeystringcontainer.create(aowner: tcomponent);
begin
 fstrings:= tkeystringdatalist.create;
 fhash:= tintegermsestringhashdatalist.create;
 inherited;
end;

destructor tkeystringcontainer.destroy;
begin
 inherited;
 fstrings.free;
 fhash.free;
end;

function tkeystringcontainer.k(const akey: msestring): msestring;
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
 result:= i(fhash.find(akey));
 if result = '' then begin
  result:= akey;
 end;
end;

function tkeystringcontainer.i(const aindex: integer): msestring;
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

procedure tkeystringcontainer.setstrings(const avalue: tkeystringdatalist);
begin
 fstrings.assign(avalue);
end;

end.
