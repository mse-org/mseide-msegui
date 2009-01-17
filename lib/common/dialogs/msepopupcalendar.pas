unit msepopupcalendar;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
{$ifndef FPC}{$ifdef linux} {$define UNIX} {$endif}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msegraphutils,msegrids,msedispwidgets,classes,
 msegraphics,mseeditglob,msetypes,msedropdownlist,msetimer,msesimplewidgets,
 mseinplaceedit,mseevent,mseguiglob;
 
const
 popupcalendarwidth = 233;
 
type
 idropdowncalendar = interface(idropdownwidget)
 end;
 
 tcalendarcontroller = class(tdropdownwidgetcontroller)
  protected
   procedure dropdownkeydown(var info: keyeventinfoty);
  public
   constructor create(const intf: idropdowncalendar);
   procedure editnotification(var info: editnotificationinfoty); override;
  published
   property bounds_cx default popupcalendarwidth;
 end;
 
 tpopupcalendarfo = class(tmseform)
   grid: tstringgrid;
   monthdisp: tdatetimedisp;
   tstockglyphbutton1: tstockglyphbutton;
   tstockglyphbutton2: tstockglyphbutton;
   buup: tstockglyphbutton;
   budo: tstockglyphbutton;
   yeardisp: tdatetimedisp;
   procedure formoncreate(const sender: TObject);
   procedure drawcell(const sender: tcol; const canvas: tcanvas;
                               const cellinfo: cellinfoty);
   procedure cellevent(const sender: TObject; var info: celleventinfoty);
   procedure moup(const sender: TObject);
   procedure modown(const sender: TObject);
   procedure yearup(const sender: TObject);
   procedure yeardown(const sender: TObject);
  private
   fvalue: tdatetime;
   ffirstdate: tdatetime;
   ffirstcol,flastcol,flastrow: integer;
   fvalueupdating: integer;
   fcontroller: tcalendarcontroller;
   procedure setvalue(const avalue: tdatetime);
   function isinvalidcell(const acell: gridcoordty): boolean;
  protected
//   procedure mousewheelevent(var info: mousewheeleventinfoty); override;
   procedure dokeydown(var info: keyeventinfoty); override;
   procedure doactivate; override;
   procedure dodeactivate; override;
   procedure mousewheelevent(var info: mousewheeleventinfoty); override;
  public
   constructor create(const aowner: tcomponent;
                       const acontroller: tcalendarcontroller); reintroduce;
   property value: tdatetime read fvalue write setvalue;
 end;

implementation
uses
 msepopupcalendar_mfm,sysutils,{$ifndef UNIX}
                                 dateutils,
                               {$else}
                                {$ifdef FPC}dateutils,{$endif}
                               {$endif} //kylix compatibility
 msedrawtext,msestrings,
 msekeyboard;

 {$ifdef UNIX}
 {$ifndef FPC} //kylix compatibility
          //copied from dateutil.inc

Function DayOf(const AValue: TDateTime): Word;

Var
  Y,M : Word;

begin
  DecodeDate(AValue,Y,M,Result);
end;

Function DaysBetween(const ANow, AThen: TDateTime): Integer;
begin
  Result:=Trunc(Abs(ANow-AThen));
end;

Function DaysInMonth(const AValue: TDateTime): Word;

Var
  Y,M,D : Word;

begin
  Decodedate(AValue,Y,M,D);
  Result:=MonthDays[IsLeapYear(Y),M];
end;

Function IncDay(const AValue: TDateTime; const ANumberOfDays: Integer): TDateTime;
begin
  Result:=AValue+ANumberOfDays;  //1899 step?
end;
 {$endif}
{$endif}

{ tcalendarcontroller }

constructor tcalendarcontroller.create(const intf: idropdowncalendar);
begin
 inherited create(intf);
 fforcecaret:= true;
 bounds_cx:= popupcalendarwidth;
end;

procedure tcalendarcontroller.editnotification(var info: editnotificationinfoty);
begin
 inherited;
 if fdropdownwidget <> nil then begin
  case info.action of
   ea_textedited: begin
    try
     tpopupcalendarfo(fdropdownwidget).value:= strtodatetime(fintf.geteditor.text);    
    except
    end;    
   end
  end;
 end;
end;

procedure tcalendarcontroller.dropdownkeydown(var info: keyeventinfoty);
var
 editor1: tinplaceedit;
begin
 editor1:= fintf.geteditor;
 editor1.dokeydown(info);
end;

{ tpopupcalendarfo }

constructor tpopupcalendarfo.create(const aowner: tcomponent;
                                       const acontroller: tcalendarcontroller);
begin
 fcontroller:= acontroller;
 inherited create(aowner);
end;

procedure tpopupcalendarfo.formoncreate(const sender: TObject);
var
 int1: integer;
begin
 with grid.fixrows[-1] do begin
  for int1:= 2 to 7 do begin
   captions[int1-2].caption:= shortdaynames[int1];
  end;
  captions[6].caption:= shortdaynames[1];
 end;
 value:= fvalue;
end;

procedure tpopupcalendarfo.setvalue(const avalue: tdatetime);
var
 year,month,day: word;
 int1: integer;
 dat1: tdatetime;
begin
 if fvalueupdating = 0 then begin
  inc(fvalueupdating);
  fvalue:= avalue;
  if yeardisp <> nil then begin
   yeardisp.value:= avalue;
  end;
  if monthdisp <> nil then begin
   monthdisp.value:= avalue;
  end;
  decodedate(avalue,year,month,day);
  dat1:= encodedate(year,month,1);
  int1:= 2-dayofweek(dat1);
  if int1 > 0 then begin
   int1:= int1 - 7;
  end;
  ffirstdate:= incday(dat1,int1);
  ffirstcol:= - int1;
  flastcol:= dayofweek(encodedate(year,month,daysinmonth(avalue))-2) mod 7;
  flastrow:= (ffirstcol + daysinmonth(avalue) - 1) div 7;
  int1:= daysbetween(ffirstdate,avalue);
  grid.focuscell(makegridcoord(int1 mod 7,int1 div 7));
  dec(fvalueupdating);
  invalidate;
 end;
end;

function tpopupcalendarfo.isinvalidcell(const acell: gridcoordty): boolean;
begin
 result:= (acell.row = 0) and (acell.col < ffirstcol) or 
     (acell.row > flastrow) or
     (acell.row >= flastrow) and (acell.col > flastcol);
end;

procedure tpopupcalendarfo.drawcell(const sender: tcol; const canvas: tcanvas;
                                    const cellinfo: cellinfoty);
var
 flags1: textflagsty;
begin
 with cellinfo do begin
  if isinvalidcell(cell) then begin
   flags1:= [tf_xcentered,tf_ycentered,tf_grayed];
  end
  else begin
   flags1:= [tf_xcentered,tf_ycentered];
  end;
  drawtext(canvas,
         msestring(inttostr(dayof(incday(ffirstdate,cell.row*7+cell.col)))),
                   rect,flags1);
 end;
end;

procedure tpopupcalendarfo.cellevent(const sender: TObject;
               var info: celleventinfoty); 
 procedure setcellvalue;
 begin
  if (fvalueupdating = 0) then begin
   with grid.focusedcell do begin
    value:= incday(ffirstdate,row*7+col);
   end;
  end;
 end;
 
begin
 if (fcontroller <> nil) and iscellclick(info,[ccr_buttonpress]) then begin
  setcellvalue;
  options:= options - [fo_freeonclose];
  hide; //do not show error messages above the popup window
  if fcontroller.setdropdowntext(datetimetostr(fvalue),true,false,key_none) then begin
//   release;
  end;
  release;
 end
 else begin
  with info do begin
   case eventkind of
    cek_enter: begin
     setcellvalue;
    end;
    cek_keydown: begin
     with keyeventinfopo^ do begin
      include(eventstate,es_processed);
      case key of
       key_pagedown{,key_wheeldown}: begin
        if shiftstate = [ss_ctrl] then begin
         yearup(nil);
        end
        else begin
         moup(nil);
        end;
       end;
       key_pageup{,key_wheelup}: begin
        if shiftstate = [ss_ctrl] then begin
         yeardown(nil);
        end
        else begin
         modown(nil);
        end;        
       end;
       key_up: begin
        if cell.row = 0 then begin
         value:= incday(fvalue,-7);
        end
        else begin
         exclude(eventstate,es_processed);
        end;
       end;
       key_down: begin
        if cell.row = 5 then begin
         value:= incday(fvalue,7);
        end
        else begin
         exclude(eventstate,es_processed);
        end;
       end;
       else begin
        exclude(eventstate,es_processed);
       end;
      end;
     end;
    end;
   end;
  end;
 end;
end;

procedure tpopupcalendarfo.mousewheelevent(var info: mousewheeleventinfoty);
 function bigstep: boolean;
 begin
  with info do begin
   result:= (shiftstate = [ss_ctrl]) or 
                 pointinrect(pos,yeardisp.widgetrect) or
                 pointinrect(pos,buup.widgetrect) or
                 pointinrect(pos,budo.widgetrect);
  end;
 end;
 
begin
 with info do begin
  if not (es_processed in eventstate) then begin
   include(eventstate,es_processed);
   case wheel of 
    mw_up: begin
     if bigstep then begin
      yearup(nil);
     end
     else begin
      moup(nil);
     end;
    end;
    mw_down: begin
     if bigstep then begin
      yeardown(nil);
     end
     else begin
      modown(nil);
     end;
    end;
   end;
  end;
 end;
end;

procedure tpopupcalendarfo.moup(const sender: TObject);
begin
 value:= incmonth(fvalue,1);
end;

procedure tpopupcalendarfo.modown(const sender: TObject);
begin
 value:= incmonth(fvalue,-1);
end;

procedure tpopupcalendarfo.yearup(const sender: TObject);
begin
 value:= incmonth(fvalue,12);
end;

procedure tpopupcalendarfo.yeardown(const sender: TObject);
begin
 value:= incmonth(fvalue,-12);
end;

procedure tpopupcalendarfo.dokeydown(var info: keyeventinfoty);
begin
 inherited;
 if not (es_processed in info.eventstate) then begin 
  fcontroller.dropdownkeydown(info);
 end;
end;

procedure tpopupcalendarfo.doactivate;
begin
 inherited;
 fcontroller.dropdownactivated;
end;

procedure tpopupcalendarfo.dodeactivate;
begin
 inherited;
 fcontroller.dropdowndeactivated;
end;

end.
