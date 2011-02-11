{ MSEgui Copyright (c) 2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseopenlgdi;
//
//under construction
//
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

implementation

procedure notimplemented;
begin
 guierror(gue_notimplemented);
end;

procedure gui_destroygc(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gui_changegc(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gui_drawlines(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure gui_drawlinesegments(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;
procedure(var drawinfo: drawinfoty); //gdifunc
begin
 notimplemented;
end;

const
 gdifunctions: gdifunctionaty = (
   {$ifdef FPC}@{$endif}gui_destroygc,
   {$ifdef FPC}@{$endif}gui_changegc,
   {$ifdef FPC}@{$endif}gui_drawlines,
   {$ifdef FPC}@{$endif}gui_drawlinesegments,
   {$ifdef FPC}@{$endif}gui_drawellipse,
   {$ifdef FPC}@{$endif}gui_drawarc,
   {$ifdef FPC}@{$endif}gui_fillrect,
   {$ifdef FPC}@{$endif}gui_fillelipse,
   {$ifdef FPC}@{$endif}gui_fillarc,
   {$ifdef FPC}@{$endif}gui_fillpolygon,
   {$ifdef FPC}@{$endif}gui_drawstring16,
   {$ifdef FPC}@{$endif}gui_setcliporigin,
   {$ifdef FPC}@{$endif}gui_createemptyregion,
   {$ifdef FPC}@{$endif}gui_createrectregion,
   {$ifdef FPC}@{$endif}gui_createrectsregion,
   {$ifdef FPC}@{$endif}gui_destroyregion,
   {$ifdef FPC}@{$endif}gui_copyregion,
   {$ifdef FPC}@{$endif}gui_moveregion,
   {$ifdef FPC}@{$endif}gui_regionisempty,
   {$ifdef FPC}@{$endif}gui_regionclipbox,
   {$ifdef FPC}@{$endif}gui_regsubrect,
   {$ifdef FPC}@{$endif}gui_regsubregion,
   {$ifdef FPC}@{$endif}gui_regaddrect,
   {$ifdef FPC}@{$endif}gui_regaddregion,
   {$ifdef FPC}@{$endif}gui_regintersectrect,
   {$ifdef FPC}@{$endif}gui_regintersectregion,
   {$ifdef FPC}@{$endif}gui_copyarea,
   {$ifdef FPC}@{$endif}gui_fonthasglyph
 );

end.
