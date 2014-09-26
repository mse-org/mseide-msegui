{ MSEgui Copyright (c) 1999-2012 by Martin Schreiber

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
 mseglob,mseguiglob,{msegui,}msetypes,{msegraphics,}msegraphutils;

type
              //used in MSEifi
 optioneditty = (oe_readonly,oe_undoonesc,            
                 oe_closequery,oe_checkmrcancel,
                 oe_nogray,
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
                 oe_exitoncursor,
                 oe_nofirstarrownavig,
                 oe_endonenter,
                 oe_homeonenter,
                 oe_autoselect, //selectall bei widget enter
                 oe_autoselectonfirstclick,
                 oe_caretonreadonly,
                 oe_focusrectonreadonly,
                 oe_trimright,
                 oe_trimleft,
                 oe_uppercase,
                 oe_lowercase,
                 oe_hintclippedtext,
                 oe_locate,
                 oe_casesensitive,
                 
                 oe_notnull,
                 oe_savevalue,oe_savestate,oe_saveoptions,
                 oe_checkvaluepaststatread,
                 
                 oe_autopopupmenu, //deprecated, moved to optionsedit1ty
                 oe_keyexecute 
                 );
 optionseditty = set of optioneditty;
const
 deprecatedoptionsedit = [oe_autopopupmenu,oe_keyexecute];
 invisibleoptionsedit = [ord(oe_autopopupmenu),ord(oe_keyexecute)];
 
type
 optionedit1ty = (oe1_noselectall,oe1_multiline,
                  oe1_autopopupmenu, 
                  oe1_keyexecute,    //alt+down-key starts dialog
                  oe1_readonlydialog);
 optionsedit1ty = set of optionedit1ty;

 dataeditstatety = (des_edited,des_emptytext,des_grayed,
                    des_isdb,des_dbnull,des_dbnullcheck,
                    des_actualcursor,des_updating,des_valueread,
                    des_statreading,
                    des_disabled, //for tdatabutton
                    des_updatelayout,des_editing);
 dataeditstatesty = set of dataeditstatety;

 editactionty = (ea_none,ea_beforechange,ea_textchanged,ea_textedited,ea_undone,
                 ea_textentered,ea_indexmoved,{ea_selectindexmoved,}
                 ea_textsizechanged,
                 ea_delchar,ea_undo,
                 {ea_selectstart,ea_selectend,}ea_clearselection,
                 ea_deleteselection,ea_copyselection,ea_pasteselection,
                 ea_selectall,ea_exit,ea_caretupdating);

 editactionstatety = (eas_shift,eas_delete);
 editactionstatesty = set of editactionstatety;

 editnotificationinfoty = record
  state: editactionstatesty;
  case action: editactionty of
   ea_exit,ea_delchar:(
    dir: graphicdirectionty;
   );
   ea_caretupdating:(
    caretrect: rectty;
    showrect: rectty;
   );
   ea_textsizechanged:(
    sizebefore: sizety;
    newsize: sizety;
   );
   ea_pasteselection,ea_copyselection:(
    bufferkind: clipboardbufferty;
   );
 end;

 idataeditcontroller = interface (inullinterface)
  procedure dokeydown(var info: keyeventinfoty);
  procedure updatereadonlystate;
  procedure internalcreateframe;
  procedure mouseevent(var info: mouseeventinfoty);
  procedure domousewheelevent(var info: mousewheeleventinfoty);
  procedure editnotification(var info: editnotificationinfoty);
 end;
  
const
 defaultoptionsedit = [oe_undoonesc,oe_closequery,oe_exitoncursor,
                       oe_focusrectonreadonly,
                       oe_shiftreturn,oe_eatreturn,
                       oe_autoselect,oe_endonenter,
                       oe_autoselectonfirstclick,
                       oe_resetselectonexit,
//                       oe_autopopupmenu,oe_keyexecute,
                       oe_checkvaluepaststatread,oe_savevalue,oe_savestate,
                       oe_checkmrcancel];
 defaultoptionsedit1 = [oe1_autopopupmenu,oe1_keyexecute];
 
 nullcoord: gridcoordty = (col: 0; row: 0);
 invalidcell: gridcoordty = (col: invalidaxis; row: invalidaxis);
 bigcoord: gridcoordty = (col: bigint; row: bigint);

function makegridcoord(col: integer; row: integer): gridcoordty;                               {$ifdef FPC}inline;{$endif}
                               {$ifdef FPC}inline;{$endif}
function mgc(col: integer; row: integer): gridcoordty;                               {$ifdef FPC}inline;{$endif}
                               {$ifdef FPC}inline;{$endif}
function makegridsize(colcount: integer; rowcount: integer): gridsizety;
                               {$ifdef FPC}inline;{$endif}
function mgs(colcount: integer; rowcount: integer): gridsizety;
                               {$ifdef FPC}inline;{$endif}
function makegridrect(const pos: gridcoordty; const size: gridsizety): gridrectty;  overload;
                               {$ifdef FPC}inline;{$endif}
function mgr(const pos: gridcoordty; const size: gridsizety): gridrectty;  overload;
                               {$ifdef FPC}inline;{$endif}
function makegridrect(const start,stop: gridcoordty): gridrectty;  overload;
                  //normalized rect, includes start and stop
function mgr(const start,stop: gridcoordty): gridrectty;  overload;
                  //normalized rect, includes start and stop

function gridcoordisequal(const a,b: gridcoordty): boolean;

implementation

function makegridcoord(col: integer; row: integer): gridcoordty;
begin
 result.col:= col;
 result.row:= row;
end;

function mgc(col: integer; row: integer): gridcoordty;
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

function mgs(colcount: integer; rowcount: integer): gridsizety;
begin
 result.colcount:= colcount;
 result.rowcount:= rowcount;
end;

function makegridrect(const pos: gridcoordty; const size: gridsizety): gridrectty;  overload;
begin
 result.pos:= pos;
 result.size:= size;
end;

function mgr(const pos: gridcoordty; const size: gridsizety): gridrectty;  overload;
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

function mgr(const start,stop: gridcoordty): gridrectty;  overload;
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
