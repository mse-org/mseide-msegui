unit msetaborderoverrideeditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,msestatfile,
 msesplitter,msesimplewidgets,mseact,msedataedits,msedropdownlist,mseedit,
 msegrids,mseificomp,mseificompglob,mseifiglob,msestream,msewidgetgrid,sysutils,
 classes,mclasses,msestrings;
type
 tmsetaborderoverrideeditorfo = class(tmseform)
   tstatfile1: tstatfile;
   tsplitter1: tsplitter;
   tbutton2: tbutton;
   tbutton1: tbutton;
   tspacer2: tspacer;
   texpandingwidget1: texpandingwidget;
   grid: twidgetgrid;
   aed: tdropdownlistedit;
   bed: tdropdownlistedit;
   procedure dialogexev(const sender: TObject);
  private
   frootcomp: tcomponent;
   ftopwidget: twidget;
   function filterwidgets(const acomponent: tcomponent): boolean;
  public
   constructor create(const atopwidget: twidget); reintroduce;
   function findcomp(const aname: msestring): twidget;
   function findwidgetcomp(const aname: msestring): twidget;
   function widgetnamepath(awidget: twidget): string;
   function compnamepath(acomp: tcomponent): string;
 end;

implementation
uses
 msetaborderoverrideeditor_mfm,msedesigner,msecomptree;

constructor tmsetaborderoverrideeditorfo.create(
                                          const atopwidget: twidget);
var
 ar1: msestringarty;
begin
 inherited create(nil);
 ftopwidget:= atopwidget;
 if csinline in atopwidget.componentstate then begin
  frootcomp:= atopwidget;
 end
 else begin
  frootcomp:= atopwidget.owner;
  if frootcomp = nil then begin
   frootcomp:= atopwidget;
  end;
 end;
 ar1:= designer.getwidgetnamelist(nil,ftopwidget,@filterwidgets);
 aed.dropdown.cols[0].asarray:= ar1;
 bed.dropdown.cols[0].asarray:= ar1;
end;

function tmsetaborderoverrideeditorfo.findcomp(const aname: msestring): twidget;
var
 str1: ansistring;
 ar1: stringarty;
 i1: int32;
 comp1: tcomponent;
 w1: twidget;
begin
 str1:= ansistring(aname);
 ar1:= splitstring(str1,'.');
 comp1:= frootcomp;
 w1:= nil;
 for i1:= 0 to high(ar1) do begin
  w1:= twidget(comp1.findcomponent(ar1[i1]));
  if not (w1 is twidget) then begin
   w1:= nil;
   break;
  end;
  comp1:= w1;
 end;
 result:= w1;
end;

function tmsetaborderoverrideeditorfo.findwidgetcomp(
                                       const aname: msestring): twidget;
var
 str1: ansistring;
 ar1: stringarty;
 i1: int32;
 comp1: tcomponent;
 w1: twidget;
begin
 str1:= ansistring(aname);
 ar1:= splitstring(str1,'.');
 comp1:= frootcomp;
 w1:= nil;
 for i1:= 0 to high(ar1) do begin
  w1:= twidget(comp1.findcomponent(ar1[i1]));
  if not (w1 is twidget) then begin
   w1:= nil;
   break;
  end;
  if csinline in w1.componentstate then begin
   comp1:= w1;
  end;
 end;
 result:= w1;
end;

function tmsetaborderoverrideeditorfo.widgetnamepath(awidget: twidget): string;
begin
 result:= '';
 if awidget <> nil then begin
  result:= awidget.name;
  awidget:= awidget.parentwidget;
  while (awidget <> nil) and (awidget <> ftopwidget) do begin
   if ws_iswidget in awidget.widgetstate then begin
    result:= awidget.name+'.'+result;
   end;
   awidget:= awidget.parentwidget;
  end;
 end;
end;

function tmsetaborderoverrideeditorfo.compnamepath(acomp: tcomponent): string;
begin
 result:= '';
 if acomp <> nil then begin
  result:= acomp.name;
  acomp:= acomp.owner;
  while (acomp <> nil) and (acomp <> frootcomp) do begin
   result:= acomp.name+'.'+result;
   acomp:= acomp.owner;
  end;
 end;
end;
 
function tmsetaborderoverrideeditorfo.filterwidgets(
                                        const acomponent: tcomponent): boolean;
begin
 result:= ws_iswidget in twidget(acomponent).widgetstate;
end;
 
procedure tmsetaborderoverrideeditorfo.dialogexev(const sender: TObject);
var
 w1: tdropdownlistedit;
 w2: twidget;
 tree1: tcompnameitem;
 mstr1: msestring;
begin
// if ftopcomponent is twidget then begin
  tree1:= designer.getwidgetnametree(ftopwidget);
  w1:= tdropdownlistedit(tcustomframe(
                         tframebutton(sender).owner).intf.getwidget);
  w2:= findcomp(w1.value);
  if w2 <> nil then begin
   mstr1:= msestring(widgetnamepath(w2));
  end
  else begin
   mstr1:= w1.value;
  end;
  if compnamedialog(tree1,mstr1,false) = mr_ok then begin
   replacechar1(mstr1,':','.');
   w2:= findwidgetcomp(mstr1);
   if w2 <> nil then begin
    mstr1:= msestring(compnamepath(w2));
   end;
   w1.value:= mstr1;
  end;
// end;
end;

end.
