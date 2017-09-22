{ MSEide Copyright (c) 1999-2013 by Martin Schreiber
   
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
unit settaborderform;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface
uses
 msetypes,mseforms,msegrids,msegui,msewidgetgrid,msedataedits,msesimplewidgets,
 msedesigner,
 mseevent,mseglob,mseguiglob,msestat,msestatfile,msegridsglob,msestrings;

type

 tsettaborderfo = class(tmseform)
   grid: twidgetgrid;
   ok: tbutton;
   cancel: tbutton;
   start: tbutton;
   stop: tbutton;
   mousetaborder: tintegeredit;
   statfile1: tstatfile;
   tlabel1: tlabel;
   windex: tintegeredit;
   wname: tstringedit;
   procedure formmouseevent(const sender: twidget; var info: mouseeventinfoty);
   procedure formonclosequery(const sender: tcustommseform;
                    var amodalresult: modalresultty);
   procedure formonloaded(const sender: TObject);
   procedure gridoncellevent(const sender: TObject; var info: celleventinfoty);
   procedure mousetaborderonsetvalue(const sender: TObject; var avalue: Integer; var accept: Boolean);
   procedure startexecute(const sender: TObject);
   procedure stopexecute(const sender: TObject);
   procedure gridonrowsmoved(const sender: tcustomgrid; const fromindex: Integer;
                   const toindex: Integer; const acount: Integer);
  private
   fwidget: twidget;
   fparent: twidget;
   fchildren: widgetarty;
   fdesigner: tdesigner;
   fwidgetorder: boolean; //set Z-order instead of taborder
  public
   constructor create(awidget: twidget; adesigner: tdesigner;
                                           const awidgetorder: boolean);
 end;

procedure settaborderdialog(const awidget: twidget; 
                                           const awidgetorder: boolean);

implementation
uses
 settaborderform_mfm,msegraphutils;
type
 twidget1 = class(twidget);
  
procedure settaborderdialog(const awidget: twidget; 
                                           const awidgetorder: boolean);
var
 fo: tsettaborderfo;
begin
 fo:= tsettaborderfo.create(awidget,designer,awidgetorder);
 try
  fo.show(true);
 finally
  fo.Free;
 end;
end;

 {tsettaborderfo}
 
constructor tsettaborderfo.create(awidget: twidget; adesigner: tdesigner; 
                                           const awidgetorder: boolean);
begin
 fwidget:= awidget;
 fparent:= awidget.parentwidget;
 fdesigner:= adesigner;
 fwidgetorder:= awidgetorder;
 inherited create(nil);
 if fwidgetorder then begin
  caption:= 'Set Widget Order';
 end;
end;

procedure tsettaborderfo.formmouseevent(const sender: twidget; var info: mouseeventinfoty);
var
 widget1: twidget;
 int1,int2: integer;
begin
 with info do begin
  if (eventkind = ek_buttonpress) then begin
   if stop.enabled and pointinrect(pos,paintrect) then begin
//    stopexecute(nil);
   end
   else begin
    if stop.enabled and (button = mb_left) and 
                       (shiftstate * keyshiftstatesmask = []) then begin
     widget1:= fparent.childatpos(translatewidgetpoint(pos,self,fparent),false);
     if widget1 <> nil then begin
      int2:= -1;
      for int1:= 0 to high(fchildren) do begin
       if widget1 = fchildren[int1] then begin
        int2:= int1;
        break;
       end;
      end;
      if int2 >= 0 then begin
       for int1:= 0 to high(fchildren) do begin
        if windex[int1] = int2 then begin
         grid.moverow(int1,mousetaborder.value);
         break;
        end;
       end;
       if mousetaborder.value = high(fchildren) then begin
        stopexecute(nil);
       end
       else begin
        mousetaborder.value:= mousetaborder.value + 1;
       end;
       grid.row:= mousetaborder.value;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tsettaborderfo.formonclosequery(const sender: tcustommseform;
           var amodalresult: modalresultty);
var
 i1: integer;
 ar1: widgetarty;
begin
 if amodalresult = mr_ok then begin
  if fwidgetorder then begin
   setlength(ar1,grid.rowcount);
   for i1:= 0 to grid.rowcount - 1 do begin
    ar1[i1]:= fchildren[windex[i1]];
   end;
   with twidget1(fparent.container) do begin
    fwidgets:= ar1;
    widgetregionchanged(nil);    
   end;
  end
  else begin
   for i1:= 0 to grid.rowcount - 1 do begin
    fchildren[windex[i1]].taborder:= i1;
   end;
   for i1:= 0 to high(fchildren) do begin
    fdesigner.componentmodified(fchildren[i1]);
   end;
  end;
 end;
end;

procedure tsettaborderfo.formonloaded(const sender: TObject);
var
 int1: integer;
begin
 if fwidgetorder then begin
  fchildren:= twidget1(fparent.container).fwidgets;
 end
 else begin
  fchildren:= fparent.container.gettaborderedwidgets;
 end;
 grid.rowcount:= length(fchildren);
 for int1:= 0 to high(fchildren) do begin
  wname[int1]:= msestring(fchildren[int1].Name);
  windex[int1]:= int1;
  if wname[int1] = msestring(fwidget.name) then begin
   grid.row:= int1;
  end;
 end;
 mousetaborder.valuemax:= high(fchildren);
end;


procedure tsettaborderfo.stopexecute(const sender: TObject);
begin
 start.enabled:= true;
 if stop.focused then begin
  start.setfocus;
 end;
 stop.enabled:= false;
 window.releasemouse;
end;

procedure tsettaborderfo.gridoncellevent(const sender: TObject; 
                                                 var info: celleventinfoty);
var
 w1: twidget;
begin
 if info.eventkind = cek_enter then begin
  mousetaborder.value:= info.newcell.row;
 end
 else begin
  if start.enabled and iscellclick(info,[ccr_dblclick,ccr_nokeyreturn]) then begin
   w1:= fchildren[windex[info.cell.row]];
   if w1.childrencount > 0 then begin
    settaborderdialog(w1[0],fwidgetorder);
   end;
  end;
 end;
end;

procedure tsettaborderfo.gridonrowsmoved(const sender: tcustomgrid;
         const fromindex: Integer; const toindex: Integer; const acount: Integer);
begin
 mousetaborder.value:= toindex;
end;

procedure tsettaborderfo.mousetaborderonsetvalue(const sender: TObject; var avalue: Integer; var accept: Boolean);
begin
 grid.row:= avalue;
end;

procedure tsettaborderfo.startexecute(const sender: TObject);
begin
 stop.enabled:= true;
 if start.focused then begin
  stop.setfocus;
 end;
 start.enabled:= false;
 window.capturemouse;
// capturemouse(true);
end;

end.
