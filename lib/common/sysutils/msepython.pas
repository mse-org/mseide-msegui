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
 mseprocess,mclasses,msearrayprops,msemacros,mseclasses,msestrings;

type
 tpythonstringlist = class(tmacrostringlist)
 end;
 
 tpythonstringlistitem = class(townedpersistent)
  private
   fname: msestring;
   fscript: tpythonstringlist;
   procedure setscript(const avalue: tpythonstringlist);
  protected
  public
   constructor create(aowner: tobject); override;
   destructor destroy; override;
   procedure assign(source: tpersistent); override;
  published
   property name: msestring read fname write fname;
   property script: tpythonstringlist read fscript write setscript;
 end;
 
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
 fscripts:= tpythonscripts.create(self,tpythonstringlistitem);
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

{ tpythonstringlistitem }

constructor tpythonstringlistitem.create(aowner: tobject);
begin
 fscript:= tpythonstringlist.create();
 inherited;
end;

destructor tpythonstringlistitem.destroy;
begin
 fscript.free;
 inherited;
end;

procedure tpythonstringlistitem.assign(source: tpersistent);
begin
 if source is tpythonstringlistitem then begin
  with tpythonstringlistitem(source) do begin
   self.name:= name;
   self.script:= script;
  end;
 end;
end;

procedure tpythonstringlistitem.setscript(const avalue: tpythonstringlist);
begin
 fscript.assign(avalue);
end;

end.
