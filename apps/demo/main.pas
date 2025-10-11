unit main;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
 msegui,mseclasses,mseforms,msesimplewidgets, msegraphics, msegraphutils,
 mseguiglob, msemenus, msewidgets, sysutils;

type
 tmainfo = class(tmseform)
   tbutton1: tbutton;
   tbutton2: tbutton;
   tbutton3: tbutton;
   tbutton4: tbutton;
   tbutton5: tbutton;
   procedure exitonexecute(const sender: TObject);
   procedure onchangetitle(const sender: TObject);
   procedure onmovewindow(const sender: TObject);
   procedure onchangecolor(const sender: TObject);
   procedure onresizwindow(const sender: TObject);
 end;

var
 mainfo: tmainfo;
 titinc: integer = 0;

implementation
uses
 main_mfm;

procedure tmainfo.exitonexecute(const sender: TObject);
begin
 application.terminated:= true;
end;

procedure tmainfo.onchangetitle(const sender: TObject);
begin
inc(titinc);
caption := 'New Title ' + inttostr(titinc);
end;

procedure tmainfo.onmovewindow(const sender: TObject);
begin
left := left + 20;
top := top + 20;
end;

procedure tmainfo.onchangecolor(const sender: TObject);
begin
if color = cl_red then color := cl_yellow else color := cl_red;
end;

procedure tmainfo.onresizwindow(const sender: TObject);
begin
width := width + 20;
height := height + 20;
end;

end.
