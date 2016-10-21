{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msepython;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseprocess,mclasses,msearrayprops;

type
{
 tpythonscript = class(tsqlstringlist)
 end;
}
 tpythonscripts = class(townedpersistentarrayprop)
 end;
 
 tpythonscript = class(tmseprocess)
  private
   fscripts: tpythonscripts;
   procedure setscripts(const avalue: tpythonscripts);
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy(); override;
  published
   property scripts: tpythonscripts read fscripts write setscripts;
 end;
 
implementation

{ tpythonscript }

constructor tpythonscript.create(aowner: tcomponent);
begin
// fscripts:= tpythonscripts.create(self);
 inherited;
end;

destructor tpythonscript.destroy();
begin
 inherited;
 fscripts.free();
end;

procedure tpythonscript.setscripts(const avalue: tpythonscripts);
begin
 fscripts.assign(avalue);
end;

end.
