{ MSEgui Copyright (c) 2017 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mserichstringeditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseapplication,msestat,msemenus,msegui,msegraphics,
 msegraphutils,mseevent,mseclasses,mseforms,msedataedits,mseedit,msestrings,
 msetypes,msestatfile,msesimplewidgets,msewidgets,msedialog,classes,mclasses,
 msedropdownlist,msesplitter,mserichstring;
 
type
 trichstringeditorfo = class(tmseform)
   memo: trichmemoedit;
   tstatfile1: tstatfile;
   tlayouter1: tlayouter;
   tbutton2: tbutton;
   tbutton1: tbutton;
   tpopupmenu1: tpopupmenu;
   procedure menuupdateev(const sender: tcustommenu);
   procedure fontformateditev(const sender: TObject);
  public
   constructor create(const aowner: tcomponent; const readonly: boolean);
                                                                  reintroduce;
 end;
  
function richstringdialog(var avalue: richstringty; 
                             const readonly: boolean): modalresultty;
 
implementation
uses
 mserichstringeditor_mfm,mseeditglob,msekeyboard,msestockobjects,
                                                  msefontformatdialog;
 
function richstringdialog(var avalue: richstringty; 
                                const readonly: boolean): modalresultty;
var
 dia1: trichstringeditorfo;
begin
 dia1:= trichstringeditorfo.create(nil,readonly);
 try
  dia1.memo.richvalue:= avalue;
  result:= dia1.show(true);
  if result = mr_ok then begin
   avalue:= dia1.memo.richvalue;
  end;
 finally
  dia1.free;
 end;
end;

{ trichstringeditorfo }

constructor trichstringeditorfo.create(const aowner: tcomponent;
                                                   const readonly: boolean);
begin
 inherited create(aowner);
 memo.readonly:= readonly;
end;

procedure trichstringeditorfo.menuupdateev(const sender: tcustommenu);
begin
 sender.menu.submenu[0].enabled:= memo.editor.hasselection;
end;

procedure trichstringeditorfo.fontformateditev(const sender: TObject);
begin
 memo.formatvalue:= editfontformat(memo.formatvalue,
                             memo.editor.selstart,memo.editor.sellength);
end;

end.
