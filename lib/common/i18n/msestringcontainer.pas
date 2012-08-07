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
 mseclasses,msedatalist,classes;
 
type
 tstringcontainer = class(tmsecomponent)
  private
   fstrings: tdoublemsestringdatalist;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
  published
   property strings: tdoublemsestringdatalist read fstrings;
 end;
 
implementation

{ tstringcontainer }

constructor tstringcontainer.create(aowner: tcomponent);
begin
 fstrings:= tdoublemsestringdatalist.create;
end;

destructor tstringcontainer.destroy;
begin
 inherited;
 fstrings.free;
end;

end.
