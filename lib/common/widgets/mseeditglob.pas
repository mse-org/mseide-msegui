{ MSEgui Copyright (c) 1999-2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseeditglob;

{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}

interface
uses
 mseglob,mseguiglob,msegui,msetypes,msegraphics;

type

 optioneditty = (oe_readonly,oe_undoonesc,
                    oe_closequery,oe_checkmrcancel,
                    oe_exitoncursor,oe_nogray,
                    oe_linebreak, 
                       // if oe_shiftreturn -> shift key_return inserts linebreak
                       // else         -> key_return inserts linebreak
                    oe_shiftreturn,
                    oe_forcereturncheckvalue, 
                       //call checkvalue unconditionally by key_return
                    oe_eatreturn,
              //      oe_returntaborder, //key_return selects next widget in taborder
                    //moved to twidget.optionswidget ow_keyreturntaborder
                    oe_resetselectonexit,

                    //same layout as strincoleditoptionty
                    oe_endonenter,
                    oe_homeonenter,
                    oe_autoselect, //selectall bei widget enter
                    oe_autoselectonfirstclick,
                    oe_caretonreadonly,
                    oe_trimright,
                    oe_trimleft,
                    oe_uppercase,
                    oe_lowercase,
                    oe_hintclippedtext,
                    oe_locate,
                    oe_casesensitive,
                    
                    oe_notnull,
 //                   oe_autopost,  //deprecated, moved to optiondeditdbty
                    oe_autopopupmenu,
                    oe_keyexecute, //shift+down-key starts dialog
                    oe_checkvaluepaststatread,
                    oe_savevalue,oe_savestate,oe_saveoptions
                    );

 optionseditty = set of optioneditty;
const
 defaultoptionsedit = [oe_undoonesc,oe_closequery,oe_exitoncursor,
                       oe_shiftreturn,oe_eatreturn,
                       oe_autoselect,oe_endonenter,
                       oe_autoselectonfirstclick,
                       oe_resetselectonexit,
                       oe_autopopupmenu,oe_keyexecute,
                       oe_savevalue,oe_savestate,oe_checkmrcancel];

 nullcoord: gridcoordty = (col: 0; row: 0);
 invalidcell: gridcoordty = (col: invalidaxis; row: invalidaxis);
 bigcoord: gridcoordty = (col: bigint; row: bigint);

function makegridcoord(col: integer; row: integer): gridcoordty;
function makegridsize(colcount: integer; rowcount: integer): gridsizety;
function makegridrect(const pos: gridcoordty; const size: gridsizety): gridrectty;  overload;
function makegridrect(const start,stop: gridcoordty): gridrectty;  overload;
                  //normalized rect, includes start and stop
function gridcoordisequal(const a,b: gridcoordty): boolean;

implementation

function makegridcoord(col: integer; row: integer): gridcoordty;
begin
 result.col:= col;
 result.row:= row;
end;

function gridcoordisequal(const a,b: gridcoordty): boolean;
begin
 result:= (a.col = b.col) and (a.row = b.row);
end;

function makegridsize(colcount: integer; rowcount: integer): gridsizety;
begin
 result.colcount:= colcount;
 result.rowcount:= rowcount;
end;

function makegridrect(const pos: gridcoordty; const size: gridsizety): gridrectty;  overload;
begin
 result.pos:= pos;
 result.size:= size;
end;

function makegridrect(const start,stop: gridcoordty): gridrectty;  overload;
begin
 if stop.col >= start.col then begin
  result.col:= start.col;
  result.colcount:= stop.col - start.col + 1;
 end
 else begin
  result.col:= stop.col;
  result.colcount:= start.col - stop.col + 1;
 end;
 if stop.row >= start.row then begin
  result.row:= start.row;
  result.rowcount:= stop.row - start.row + 1;
 end
 else begin
  result.row:= stop.row;
  result.rowcount:= start.row - stop.row + 1;
 end;
end;

end.
