{ MSEide Copyright (c) 1999-2014 by Martin Schreiber
   
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}
unit messageform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msegui,mseclasses,mseforms,msegrids,msemenus,msedataedits,msesimplewidgets,
 classes,mclasses,projectoptionsform;

type
 tmessagefo = class(tdockform)
   messages: tstringgrid;
   tpopupmenu1: tpopupmenu;
   procedure messagesoncellevent(const sender: tobject;
                                                   var info: celleventinfoty);
   procedure copyexe(const sender: TObject);
  private
   fcolorrow: integer;
  public
   constructor create(aowner: tcomponent); override;
   procedure addtext(const atext: string);
   procedure updateprojectoptions;
 end;
 
var
 messagefo: tmessagefo;

implementation
uses
 messageform_mfm,sourcepage,sourceform,msewidgets,msestrings,msedatalist;

constructor tmessagefo.create(aowner: tcomponent);
begin
 fcolorrow:= -1;
 inherited create(aowner);
end;
 
procedure tmessagefo.messagesoncellevent(const sender: tobject;
  var info: celleventinfoty);
var
 page: tsourcepage;
begin
 if (info.cell.row >= 0) and iscellclick(info,[ccr_dblclick]) then begin
  locateerrormessage(
    messagefo.messages[0].datalist.getparagraph(info.cell.row),page);
 end;
end;

procedure tmessagefo.copyexe(const sender: TObject);
begin
 copytoclipboard(messages.datacols[0].datalist.concatstring('',lineend));
end;

procedure tmessagefo.addtext(const atext: string);
var
 int1,int2: integer;
 lev1: errorlevelty;
 col1,row1: integer;
 fn1: filenamety;
 strcol1: tstringcol;
 rowhigh1: integer;

 procedure setrowcolor(const arowcolor: rowstatenumty);
 var
  int2: integer;
 begin
  messages.rowcolorstate[int1]:= arowcolor;
  for int2:= int1 + 1 to rowhigh1 do begin
   if strcol1.noparagraph[int2] then begin
    messages.rowcolorstate[int2]:= arowcolor;
   end
   else begin
    break;
   end;
  end;
 end; //setrowcolor

var
 opt1: addcharoptionsty;
  
begin
 with messages do begin
  opt1:= [aco_processeditchars];
  if projectoptions.s.stripmessageesc then begin
   include(opt1,aco_stripescsequence);
  end;
  int1:= datacols[0].readpipe(atext,opt1,120);
  rowhigh1:= rowhigh;
  int2:= rowhigh1-int1;
  if int2 < 0 then begin
   int2:= 0;
  end;
  strcol1:= messages[0];
  with strcol1 do begin
   for int1:= rowhigh downto int2 do begin
    if not noparagraph[int1] and
             checkerrormessage(datalist.getparagraph(int1),
                                           lev1,fn1,col1,row1) then begin
     case lev1 of
      el_error: begin
       setrowcolor(0);
      end;
      el_warning: begin
       setrowcolor(1);
      end;
      el_note: begin
       setrowcolor(2);
      end;
     end;
    end;
   end;
  end;
  showlastrow;
 end;  
end;

procedure tmessagefo.updateprojectoptions;
begin
 with messages,projectoptions.s do begin
  rowcolors[0]:= colorerror;
  rowcolors[1]:= colorwarning;
  rowcolors[2]:= colornote;
  invalidate;
 end;
end;

end.
