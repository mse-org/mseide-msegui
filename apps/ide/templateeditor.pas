unit templateeditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msestatfile,
 msesimplewidgets,msewidgets,msedataedits,mseedit,msegrids,msestrings,msetypes,
 msewidgetgrid,msegraphedits,msesplitter,mseeditglob,msetextedit,msedispwidgets;
type
 ttemplateeditorfo = class(tmseform)
   tstatfile1: tstatfile;
   tbutton1: tbutton;
   tbutton2: tbutton;
   nameed: tstringedit;
   commented: tstringedit;
   paramgrid: tstringgrid;
   tspacer1: tspacer;
   tsplitter1: tsplitter;
   templgrid: twidgetgrid;
   templed: ttextedit;
   cursordisp: tstringdisp;
   tsplitter2: tsplitter;
   coled: tintegeredit;
   rowed: tintegeredit;
   tbutton3: tbutton;
   selected: tbooleanedit;
   indented: tbooleanedit;
   procedure onlo(const sender: TObject);
   procedure editnotify(const sender: TObject;
                   var info: editnotificationinfoty);
   procedure setcursorex(const sender: TObject);
   procedure closeq(const sender: tcustommseform;
                   var amodalresult: modalresultty);
  private
   findex: integer;
  public
   constructor create(const aindex: integer); reintroduce;
 end;

implementation
uses
 templateeditor_mfm,msecodetemplates,projectoptionsform,sysutils;
 
constructor ttemplateeditorfo.create(const aindex: integer);
begin
 findex:= aindex;
 inherited create(nil);
end;

procedure ttemplateeditorfo.onlo(const sender: TObject);
var
 int1: integer;
begin
 projectoptionstofont(templed.font);
 templgrid.datarowheight:= templed.font.lineheight;
 if (findex >= 0) and (findex <= high(codetemplates.templates)) then begin
  with codetemplates.templates[findex] do begin
   caption:= shrinkstring(path,40);
   selected.value:= select;
   indented.value:= indent;
   coled.value:= cursorcol+1;
   rowed.value:= cursorrow+1;
   commented.value:= comment;
   nameed.value:= name;
   paramgrid[0].datalist.asarray:= params;
   templed.settext(template);
  end;
 end;
end;

procedure ttemplateeditorfo.editnotify(const sender: TObject;
               var info: editnotificationinfoty);
begin
 case info.action of
  ea_indexmoved: begin
   with templed.editpos do begin
    cursordisp.value:= inttostr(row+1) + ':'+inttostr(col+1);
   end;
  end;
 end;
end;

procedure ttemplateeditorfo.setcursorex(const sender: TObject);
begin
 if templgrid.isdatacell(templgrid.focusedcell) then begin
  with templed.editpos do begin
   coled.value:= col+1;
   rowed.value:= row+1;
  end;
 end
 else begin
  coled.value:= 1;
  rowed.value:= 1;
 end;
end;

procedure ttemplateeditorfo.closeq(const sender: tcustommseform;
               var amodalresult: modalresultty);
begin
 if amodalresult = mr_ok then begin
  with codetemplates.templates[findex] do begin
   select:= selected.value;
   indent:= indented.value;
   cursorcol:= coled.value - 1;
   cursorrow:= rowed.value - 1;
   comment:= commented.value;
   name:= nameed.value;
   params:= paramgrid[0].datalist.asarray;
   template:= templed.gettext;
  end;
  codetemplates.savefile(codetemplates.templates[findex]);
 end;
end;

end.
