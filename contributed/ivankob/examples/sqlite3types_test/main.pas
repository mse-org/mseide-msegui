unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface

uses
 mseglob,msegui,mseclasses,mseforms,msesimplewidgets,msesqlite3conn,msesqldb,msedb,
 msedbedit,msedbgraphics, mseformatjpg,msemenus,msefiledialog, mseevent;
 
type
 tmainfo = class(tmseform)
   tbutton1: tbutton;
   conn: tsqlite3connection;
   qry: tmsesqlquery;
   ds: tmsedatasource;
   booleanedit: tdbbooleanedit;
   blobdisplay: tdbdataimage;
   currencyedit: tdbrealedit;
   blobpopup: tpopupmenu;
   blobdialog: tfiledialog;
   blobfield: tmseblobfield;
   wordedit: tdbintegeredit;
   timeedit: tdbdatetimeedit;
   datetimeedit: tdbdatetimeedit;
   dateedit: tdbdatetimeedit;
   smallintedit: tdbintegeredit;
   integeredit: tdbintegeredit;
   largeintedit: tdbintegeredit;
   textedit: tdbmemoedit;
   numericedit: tdbrealedit;
   realedit: tdbrealedit;
   varcharedit: tdbstringedit;
   trans: tmsesqltransaction;
   procedure saveexec(const sender: TObject);
   procedure loadexec(const sender: TObject);
   procedure clearexec(const sender: TObject);
   procedure popupdisplay(const sender: TObject; var amenu: tpopupmenu;
                   var mouseinfo: mouseeventinfoty);
 end;

var
 mainfo: tmainfo;

implementation

uses
 main_mfm;

procedure tmainfo.saveexec(const sender: TObject);
begin
 with blobdialog, blobfield, dataset do begin
  if (not isnull) and (execute(fdk_save) = mr_ok) then begin
    savetofile(controller.filename);
  end;
 end;

end;

procedure tmainfo.loadexec(const sender: TObject);
begin
 with blobdialog, blobfield, dataset do begin
  if execute(fdk_open) = mr_ok then begin
  	edit;
    loadfromfile(controller.filename);
    post;
  end;
 end;
end;

procedure tmainfo.clearexec(const sender: TObject);
begin
 with blobfield, dataset do begin
  edit;
  clear;
  post; 
 end;
end;

procedure tmainfo.popupdisplay(const sender: TObject; var amenu: tpopupmenu;
               var mouseinfo: mouseeventinfoty);
begin
 with amenu.menu do begin
   submenu[1].enabled:= not blobfield.isnull;
   submenu[2].enabled:= submenu[1].enabled;
 end;
end;

end.
