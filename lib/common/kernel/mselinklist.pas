{ MSEgui Copyright (c) 2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mselinklist;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
type

 linkheaderty = record
  next: ptruint; //offset in data
 end;
 plinkheaderty = ^linkheaderty;
 linkinfoty = record
  header: linkheaderty;
  data: record
  end;
 end;

 doublelinkheaderty = record
  lh: linkheaderty;
  prev: ptruint; //offset in data
 end;
 pdoublelinkheaderty = ^doublelinkheaderty;
 doublelinkinfoty = record
  header: doublelinkheaderty;
  data: record
  end;
 end;
 
 tlinklist = class(tobject)
  private
   fcapacity: ptruint;
   flast: ptruint;
   fdeleted: ptruint;
   fdata: pointer; //dummy item at 0
   fcount: integer;
   function getcapacity: integer;
   procedure setcapacity(const avalue: integer);
  protected
   fitemsize: integer;
   function getheadersize: integer; virtual;
   procedure grow;
   function add: pointer;
   procedure delete(const aoffset: ptruint);
  public
   constructor create(const adatasize: integer);
   destructor destroy; override;
   property count: integer read fcount;
   property capacity: integer read getcapacity write setcapacity;
                    //grow only
 end;
 
 tsinglelinklist = class(tlinklist)
  protected
  public
 end;
 
 tdoublelinklist = class(tlinklist)
  protected
   function getheadersize: integer; override;
   procedure delete(const aoffset: ptruint);
  public
 end;
 
implementation

{ tlinklist }

constructor tlinklist.create(const adatasize: integer);
begin
 fitemsize:= adatasize + getheadersize;
end;

destructor tlinklist.destroy;
begin
 if fdata <> nil then begin
  freemem(fdata);
 end;
 inherited;
end;

function tlinklist.getheadersize: integer;
begin
 result:= sizeof(linkheaderty);
end;

function tlinklist.getcapacity: integer;
begin
 result:= fcapacity div fitemsize
end;

procedure tlinklist.setcapacity(const avalue: integer);
var
 ca1: ptruint;
begin
 ca1:= avalue * fitemsize;
 if ca1 > fcapacity then begin
  reallocmem(fdata,ca1+fitemsize);
  fcapacity:= ca1;
 end;
end;

procedure tlinklist.grow;
begin
 capacity:= 2*count+256;
end;

function tlinklist.add: pointer;
begin
 if fdeleted = 0 then begin
  flast:= flast+fitemsize;
  if flast >= fcapacity then begin
   grow;
  end;
  result:= fdata+flast;
 end
 else begin
  result:= fdata + fdeleted;
  fdeleted:= plinkheaderty(result)^.next;
 end;
 inc(fcount);
end;

procedure tlinklist.delete(const aoffset: ptruint);
begin
 plinkheaderty(fdata+aoffset)^.next:= fdeleted;
 fdeleted:= aoffset;
 dec(fcount);
end;

{ tsinglelinklist }


{ tdoublelinklist }

function tdoublelinklist.getheadersize: integer;
begin
 result:= sizeof(doublelinkheaderty);
end;

procedure tdoublelinklist.delete(const aoffset: ptruint);
begin
 with pdoublelinkheaderty(fdata+aoffset)^ do begin
  pdoublelinkheaderty(fdata+prev)^.lh.next:= lh.next;
  pdoublelinkheaderty(fdata+lh.next)^.prev:= prev;
 end;
 inherited;
end;

end.
