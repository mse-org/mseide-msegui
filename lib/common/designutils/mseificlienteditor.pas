{ MSEgui Copyright (c) 1999-2014 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseificlienteditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,mseificomp,msedataedits,
 mseedit,msegrids,msestrings,msetypes,msewidgetgrid,msesimplewidgets,msewidgets,
 msegraphedits,msedatanodes,mselistbrowser,classes,mclasses,msestatfile;

type
 tmseificlienteditorfo = class(tmseform)
   grid: twidgetgrid;
   tbutton1: tbutton;
   tbutton2: tbutton;
   po: tpointeredit;
   na: tmbdropdownitemedit;
   tstatfile1: tstatfile;
   procedure befdrop(const sender: TObject);
   procedure setval(const sender: TObject; var avalue: msestring;
                   var accept: Boolean);
   procedure celle(const sender: TObject; var info: celleventinfoty);
   procedure editexe(const sender: TObject);
   procedure statexe(const sender: TObject; const filer: tstatfiler);
   procedure keydownexe(const sender: twidget; var ainfo: keyeventinfoty);
  private
   fcomp: tifilinkcomp;
   finstances: ppointeraty;
   fpath: msestring;
   function filtercomponent(const acomponent: tcomponent): boolean;
 end;
 
function editificlient(const acomponent: tifilinkcomp): modalresultty;
 
implementation
uses
 mseificlienteditor_mfm,msepropertyeditors,msedesignintf,msedesigner,
 objectinspector,typinfo,msearrayutils,msecomptree;
type
 tmsecomponent1 = class(tmsecomponent);

function getdispname(const aobject: tobject): msestring;
begin
 if aobject is tcomponent then begin
  result:= getcomponentpropname(tcomponent(aobject));
 end
 else begin
  result:= aobject.classname;
 end;
end;
 
function editificlient(const acomponent: tifilinkcomp): modalresultty;
var
 edfo: tmseificlienteditorfo;
 ar1: objectarty;
 int1: integer;
 ar2: pointerarty;
begin
 edfo:= tmseificlienteditorfo.create(nil);
 try
{$warnings off}
  ar1:= tmsecomponent1(acomponent).getobjectlinker.linkedobjects(
                                                     acomponent.controller);
{$warnings on}
  edfo.po.gridvalues:= pointerarty(ar1);
  edfo.fcomp:= acomponent;
  for int1:= 0 to high(ar1) do begin
   edfo.na[int1].caption:= getdispname(ar1[int1]);
  end;
  edfo.caption:= edfo.caption + ' ('+acomponent.name+')';
  result:= edfo.show(true);
  if result = mr_ok then begin
   ar2:= edfo.po.gridvalues;
   for int1:= 0 to high(ar1) do begin //remove not linked
    if finditem(ar2,ar1[int1]) < 0 then begin
     setobjectprop(ar1[int1],'ifilink',nil);
     designer.componentmodified(ar1[int1]);
     ar1[int1]:= nil;
    end;
   end;
   for int1:= 0 to high(ar2) do begin //add linked
    if (ar2[int1] <> nil) and 
                 (finditem(pointerarty(ar1),ar2[int1]) < 0) then begin
     setobjectprop(tobject(ar2[int1]),'ifilink',acomponent);
     designer.componentmodified(tcomponent(ar2[int1]));
    end;
   end;
  end;
 finally
  edfo.free;
 end;
end;

function tmseificlienteditorfo.filtercomponent(
                                   const acomponent: tcomponent): boolean;
var
 int1: integer;
 po1: ppropinfo;
begin
 result:= fcomp.controller.canconnect(acomponent);
 if result and (pointer(acomponent) <> po.value) then begin
  for int1:= 0 to grid.rowhigh do begin
   if finstances^[int1] = pointer(acomponent) then begin
    result:= false;
    exit;
   end;
  end;
  po1:=  getpropinfo(acomponent,'ifilink');
  result:= (po1 <> nil) and (po1^.proptype^.kind = tkclass) and
               (fcomp is gettypedata(po1^.proptype{$ifndef FPC}^{$endif})^.classtype);
 end; 
end;
 
procedure tmseificlienteditorfo.befdrop(const sender: TObject);
begin
 finstances:= po.griddata.datapo;
 with tmbdropdownitemedit(sender) do begin
  dropdown.cols[0].asarray:= designer.getcomponentnamelist(
        tcomponent,false,nil,{$ifdef FPC}@{$endif}filtercomponent);
 end;
end;

procedure tmseificlienteditorfo.setval(const sender: TObject;
               var avalue: msestring; var accept: Boolean);
var
 comp1: tcomponent;
 int1: integer;
begin
 comp1:= designer.getcomponent(avalue,fcomp.owner);
 po.value:= comp1;
 if comp1 <> nil then begin
  avalue:= getdispname(tcomponent(po.value));
  fpath:= ownernamepath(comp1);
  int1:= findlastchar(fpath,'.');
  if int1 > 0 then begin
   setlength(fpath,int1-1);
  end;
 end;
end;

procedure tmseificlienteditorfo.celle(const sender: TObject;
               var info: celleventinfoty);
begin
 if iscellclick(info,[ccr_dblclick,ccr_nokeyreturn]) then begin
  designer.showformdesigner(designer.modules.findmodulebycomponent(
                                                       tcomponent(po.value)));
  designer.selectcomponent(tcomponent(po.value));
  window.modalresult:= mr_ok;
//  objectinspectorfo.activate;
 end;
end;

procedure tmseificlienteditorfo.editexe(const sender: TObject);
var
 tree1: tcompnameitem;
 mstr1: msestring;
 bo1: boolean;
begin
 finstances:= po.griddata.datapo;
 tree1:= designer.getcomponentnametree(tcomponent,true{false},nil,
                                      {$ifdef FPC}@{$endif}filtercomponent);
 mstr1:= ownernamepath(tcomponent(po.value));
 if mstr1 = '' then begin
  mstr1:= fpath;
 end;
 if compnamedialog(tree1,mstr1) = mr_ok then begin
  bo1:= true;
  setval(nil,mstr1,bo1);
  na.item.caption:= mstr1;
 end;

end;

procedure tmseificlienteditorfo.statexe(const sender: TObject;
               const filer: tstatfiler);
begin
 filer.updatevalue('path',fpath);
end;

procedure tmseificlienteditorfo.keydownexe(const sender: twidget;
               var ainfo: keyeventinfoty);
begin
 if isenterkey(nil,ainfo.key) and (ainfo.shiftstate = []) and
                            not na.edited then begin
  include(ainfo.eventstate,es_processed);
  editexe(nil);  
 end;
end;

end.
