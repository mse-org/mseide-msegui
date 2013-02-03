{ MSEgui Copyright (c) 1999-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msecommutils;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msedataedits,msecommport,msetypes,msedatalist,
 classes,mclasses,mseclasses,msedropdownlist,
 msemenus,mseevent,msestrings,msegui,mseguiglob,mseedit;
type
 setcommnreventty =  procedure(const sender: tobject; var avalue: commnrty;
                          var accept: boolean) of object;

 tcommselector = class(tcustomselector)
  private
   function getvalue: commnrty;
   procedure setvalue(const aValue: commnrty);
   function readonsetvalue: setcommnreventty;
   procedure writeonsetvalue(const aValue: setcommnreventty);
  protected
   procedure getdropdowninfo(var aenums: integerarty;
         const names: tdropdowncols); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property value: commnrty read getvalue write setvalue default cnr_1;
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
   property dropdown;
   property onsetvalue: setcommnreventty read readonsetvalue write writeonsetvalue;
   property onbeforedropdown;
   property onafterclosedropdown;
 end;

implementation

type
 comminforecty = record anzeigetext, dropdowntext: string; commnr: commnrty end;
 comminfoty = array[commnrty] of comminforecty;
const

 {$ifdef mswindows}
 comminfo: comminfoty = ((anzeigetext:'COM1'; dropdowntext:'1 COM1'; commnr: cnr_1),
                         (anzeigetext:'COM2'; dropdowntext:'2 COM2'; commnr: cnr_2),
                         (anzeigetext:'COM3'; dropdowntext:'3 COM3'; commnr: cnr_3),
                         (anzeigetext:'COM4'; dropdowntext:'4 COM4'; commnr: cnr_4),
                         (anzeigetext:'COM5'; dropdowntext:'5 COM5'; commnr: cnr_5),
                         (anzeigetext:'COM6'; dropdowntext:'6 COM6'; commnr: cnr_6),
                         (anzeigetext:'COM7'; dropdowntext:'7 COM7'; commnr: cnr_7),
                         (anzeigetext:'COM8'; dropdowntext:'8 COM8'; commnr: cnr_8),
                         (anzeigetext:'COM9'; dropdowntext:'9 COM9'; commnr: cnr_9)
                        );
  {$else}

 comminfo: comminfoty = ((anzeigetext:'ttyS0'; dropdowntext:'0 ttyS0'; commnr: cnr_1),
                         (anzeigetext:'ttyS1'; dropdowntext:'1 ttyS1'; commnr: cnr_2),
                         (anzeigetext:'ttyS2'; dropdowntext:'2 ttyS2'; commnr: cnr_3),
                         (anzeigetext:'ttyS3'; dropdowntext:'3 ttyS3'; commnr: cnr_4),
                         (anzeigetext:'ttyS4'; dropdowntext:'4 ttyS4'; commnr: cnr_5),
                         (anzeigetext:'ttyS5'; dropdowntext:'5 ttyS5'; commnr: cnr_6),
                         (anzeigetext:'ttyS6'; dropdowntext:'6 ttyS6'; commnr: cnr_7),
                         (anzeigetext:'ttyS7'; dropdowntext:'7 ttyS7'; commnr: cnr_8),
                         (anzeigetext:'ttyS8'; dropdowntext:'8 ttyS8'; commnr: cnr_9)
                         );
  {
 comminfo: comminfoty = ((anzeigetext:'ttys0'; dropdowntext:'0 ttys0'; commnr: cnr_1),
                         (anzeigetext:'ttys1'; dropdowntext:'1 ttys1'; commnr: cnr_2),
                         (anzeigetext:'ttys2'; dropdowntext:'2 ttys2'; commnr: cnr_3),
                         (anzeigetext:'ttys3'; dropdowntext:'3 ttys3'; commnr: cnr_4),
                         (anzeigetext:'ttys4'; dropdowntext:'4 ttys4'; commnr: cnr_5),
                         (anzeigetext:'ttys5'; dropdowntext:'5 ttys5'; commnr: cnr_6),
                         (anzeigetext:'ttys6'; dropdowntext:'6 ttys6'; commnr: cnr_7),
                         (anzeigetext:'ttys7'; dropdowntext:'7 ttys7'; commnr: cnr_8),
                         (anzeigetext:'ttys8'; dropdowntext:'8 ttys8'; commnr: cnr_9)
                         );
  }
  {$endif}


{ tcommselector }

constructor tcommselector.create(aowner: tcomponent);
var
 comm: commnrty;
begin
 inherited;
 inherited value:= integer(cnr_1);
 for comm:= low(commnrty) to high(commnrty) do begin
  tdropdownlistcontroller(fdropdown).cols[0].add(comminfo[comm].anzeigetext);
 end;
end;

procedure tcommselector.getdropdowninfo(var aenums: integerarty;
  const names: tdropdowncols);
var
 comm: commnrty;
 int1: integer;
begin
 setlength(aenums,integer(high(commnrty))+1);
 names[0].clear;
 int1:= 0;
 for comm:= low(commnrty) to high(commnrty) do begin
  if checkcommport(comm) then begin
   aenums[int1]:= integer(comm);
   names[0].add(comminfo[comm].dropdowntext);
   inc(int1);
  end;
 end;
 setlength(aenums,int1);
end;

function tcommselector.getvalue: commnrty;
begin
 result:= commnrty(fvalue1);
end;

function tcommselector.readonsetvalue: setcommnreventty;
begin
 result:= setcommnreventty(fonsetvalue1);
end;

procedure tcommselector.writeonsetvalue(const aValue: setcommnreventty);
begin
 fonsetvalue1:= setintegereventty(avalue);
end;

procedure tcommselector.setvalue(const aValue: commnrty);
begin
 inherited setvalue(integer(avalue));
end;

end.
