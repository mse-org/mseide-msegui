unit msetexteditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msesimplewidgets,msewidgetgrid,msesyntaxedit,
 msemenus,msefiledialog,msestat,msesyntaxpainter,msedispwidgets,mseinplaceedit;

const
 texteditorstatname =  'texteditor.sta';
type
 tmsetexteditorfo = class(tmseform)
   ok: tbutton;
   cancel: tbutton;
   filedialog: tfiledialog;
   test: tbutton;
   tpopupmenu1: tpopupmenu;
   textedit: tsyntaxedit;
   tstatfile1: tstatfile;
   linedisp: tstringdisp;
   grid: twidgetgrid;
   procedure undoexe(const sender: TObject);
   procedure redoexe(const sender: TObject);
   procedure popupuponupdate(const sender: tcustommenu);
   procedure loadfileexe(const sender: TObject);
   procedure savefileexe(const sender: TObject);
   procedure editnotify(const sender: TObject; var info: editnotificationinfoty);
   procedure copyexe(const sender: TObject);
   procedure cutexe(const sender: TObject);
   procedure pasteexe(const sender: TObject);
   procedure testexe(const sender: TObject);
  public
   constructor create(const aonclosequery: closequeryeventty;
                const asyntaxpainter: tsyntaxpainter;
                const asyntaxindex: integer; const testbutton: boolean); reintroduce;
 end;

var
 syntaxpainter: tsyntaxpainter;
 
implementation
uses
 msetexteditor_mfm,sysutils,msewidgets,mseshapes;

const
 sqlsyntaxdef = '';
 
constructor tmsetexteditorfo.create(const aonclosequery: closequeryeventty;
            const asyntaxpainter: tsyntaxpainter; const asyntaxindex: integer;
            const testbutton: boolean);
begin
 inherited create(nil);
 onclosequery:= aonclosequery;
 if (asyntaxpainter <> nil) and (asyntaxindex >= 0) then begin
  textedit.syntaxpainter:= asyntaxpainter;
  textedit.setsyntaxdef(asyntaxindex);
 end;  
 if testbutton then begin
  test.state:= test.state - [as_invisible,as_disabled];
 end;
end;

procedure tmsetexteditorfo.loadfileexe(const sender: TObject);
begin
 if filedialog.execute(fdk_open) = mr_ok then begin
  textedit.loadfromfile(filedialog.controller.filename);
 end;
end;

procedure tmsetexteditorfo.savefileexe(const sender: TObject);
begin
 if filedialog.execute(fdk_save) = mr_ok then begin
  textedit.savetofile(filedialog.controller.filename);
 end;
end;

procedure tmsetexteditorfo.editnotify(const sender: TObject;
             var info: editnotificationinfoty);
begin
 if info.action = ea_indexmoved then begin
  linedisp.value:= inttostr(textedit.editpos.row+1) + ':'+
                          inttostr(textedit.editpos.col+1);
 end;
end;

procedure tmsetexteditorfo.popupuponupdate(const sender: tcustommenu);
begin
 sender.menu.itembyname('undo').enabled:= textedit.canundo;
 sender.menu.itembyname('redo').enabled:= textedit.canredo;
 sender.menu.itembyname('copy').enabled:= textedit.hasselection;
 sender.menu.itembyname('cut').enabled:= textedit.hasselection;
 sender.menu.itembyname('paste').enabled:= textedit.canpaste;
end;

procedure tmsetexteditorfo.undoexe(const sender: TObject);
begin
 textedit.undo;
end;

procedure tmsetexteditorfo.redoexe(const sender: TObject);
begin
 textedit.redo;
end;

procedure tmsetexteditorfo.copyexe(const sender: TObject);
begin
 textedit.copyselection;
end;

procedure tmsetexteditorfo.cutexe(const sender: TObject);
begin
 textedit.cutselection;
end;

procedure tmsetexteditorfo.pasteexe(const sender: TObject);
begin
 textedit.paste;
end;

procedure tmsetexteditorfo.testexe(const sender: TObject);
var
 modres: modalresultty;
begin
 modres:= mr_canclose;
 onclosequery(self,modres);
 if modres = mr_canclose then begin
  showmessage('Test OK');
 end;
end;

initialization
 syntaxpainter:= tsyntaxpainter.create(nil);
finalization
 syntaxpainter.free;
end.
