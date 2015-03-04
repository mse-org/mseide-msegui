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
 classes,mclasses,mseclasses,msedropdownlist,msestat,
 msemenus,mseevent,msestrings,msegui,mseguiglob,mseedit;
type
 setcommnreventty =  procedure(const sender: tobject; var avalue: commnrty;
                          var accept: boolean) of object;
 getcommnreventty = procedure(const sender: tobject;
                          var avalue: commnrty) of object;
 
 tcommselector = class(tcustomselector)
  private
   fongetactivecommnr: getcommnreventty;
   fvaluename: filenamety;
   function getvalue: commnrty;
   procedure setvalue(const aValue: commnrty);
   function readonsetvalue: setcommnreventty;
   procedure writeonsetvalue(const aValue: setcommnreventty);
   procedure setvaluename(const avalue: filenamety);
  protected
   procedure getdropdowninfo(var aenums: integerarty;
         const names: tdropdowndatacols); override;
//   function createdropdowncontroller: tcustomdropdowncontroller; override;
   procedure texttovalue(var accept: boolean; const quiet: boolean); override;
   function internaldatatotext(const data): msestring; override;
   procedure readstatvalue(const reader: tstatreader); override;
   procedure writestatvalue(const writer: tstatwriter); override;
  public
   constructor create(aowner: tcomponent); override;
  published
   property value: commnrty read getvalue write setvalue default cnr_1;
   property valuename: filenamety read fvaluename write setvaluename;
{$ifdef mse_with_ifi}
   property ifilink;
{$endif}
   property dropdown;
   property onsetvalue: setcommnreventty read readonsetvalue write writeonsetvalue;
   property onbeforedropdown;
   property onafterclosedropdown;
   property ongetactivecommnr: getcommnreventty read fongetactivecommnr 
                                                       write fongetactivecommnr;
 end;

implementation
uses
 mseeditglob;
  
type
 comminforecty = record anzeigetext, dropdowntext: string; commnr: commnrty end;
 comminfoty = array[cnr_1..cnr_9] of comminforecty;
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
 dropdown.cols.nostreaming:= true;
 inherited value:= integer(cnr_1);
 for comm:= low(comminfo) to high(comminfo) do begin
  tdropdownlistcontroller(fdropdown).cols[0].add(comminfo[comm].anzeigetext);
 end;
end;

procedure tcommselector.getdropdowninfo(var aenums: integerarty;
  const names: tdropdowndatacols);
var
 comm: commnrty;
 int1: integer;
 activecomm: commnrty;
begin
 setlength(aenums,integer(high(commnrty)));
 names[0].clear;
 activecomm:= commnrty(-1);
 if canevent(tmethod(fongetactivecommnr)) then begin
  fongetactivecommnr(self,activecomm);
 end;
 int1:= 0;
 for comm:= low(comminfo) to high(comminfo) do begin
  if (comm = activecomm) or checkcommport(comm) then begin
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
{
function tcommselector.createdropdowncontroller: tcustomdropdowncontroller;
begin
 result:= tnocolsenumdropdowncontroller.create(idropdownlist(self));
end;
}
procedure tcommselector.setvaluename(const avalue: filenamety);
begin
 if avalue <> fvaluename then begin
  fvaluename:= avalue;
  changed;
 end;
end;

procedure tcommselector.texttovalue(var accept: boolean; const quiet: boolean);
var
 mstr1: msestring;
begin
 mstr1:= fvaluename;
 if not (des_statreading in fstate) then begin
  fvaluename:= text;
 end;
 inherited;
 if not accept then begin
  fvaluename:= mstr1;
 end;
end;

function tcommselector.internaldatatotext(const data): msestring;
begin
 result:= inherited internaldatatotext(data);
 if (@data = nil) and (value = cnr_invalid) then begin
  result:= fvaluename;
 end;
end;

procedure tcommselector.readstatvalue(const reader: tstatreader);
begin
 inherited;
 valuename:= reader.readmsestring(valuevarname+'_name',fvaluename);
end;

procedure tcommselector.writestatvalue(const writer: tstatwriter);
begin
 inherited;
 writer.writemsestring(valuevarname+'_name',fvaluename);
end;

end.
