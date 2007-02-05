unit commonrefseditform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msesimplewidgets,mseactions,msedb,
 // provides "tfield"
 db
;

type
 tcommonrefseditfo = class(tmseform)
   actSaveAll: taction;
   actUnDo: taction;
   actAdd: taction;
   actDelete: taction;
   btnSaveAll: tbutton;
   btnUnDo: tbutton;
   btnAdd: tbutton;
   btnDelete: tbutton;
   btnClose: tbutton;
   btnCancel: tbutton;
   dsContents: tmsedatasource;
   actUnDoAll: taction;
   tlabel1: tlabel;
   procedure contentschange(Sender: TObject; Field: TField);
   procedure saveallexecute(const sender: TObject);
   procedure undoexecute(const sender: TObject);
   procedure addexecute(const sender: TObject);
   procedure deleteexecute(const sender: TObject);
   procedure undoallexecute(const sender: TObject);
   procedure commonrefseditfoclosequery(const sender: tcustommseform;
                   var amodalresult: modalresultty);
 end;

var
 commonrefseditfo: tcommonrefseditfo;

implementation

uses
 commonrefseditform_mfm,
 // priovides "tmsesqlquery"
 msesqldb,
 msewidgets
;

var
  isexpected : boolean;

procedure tcommonrefseditfo.contentschange(Sender: TObject; Field: TField);
begin
  with ((sender as tdatasource).dataset) as tmsesqlquery do begin
    actDelete.enabled:= recordcount > 0;
    actUnDoAll.enabled:=  changecount > 0;
    actSaveAll.enabled:= changecount > 0;
//    actUnDo.enabled:=  updatestatus = usModified;
  end;
end;

procedure tcommonrefseditfo.saveallexecute(const sender: TObject);
begin
  isexpected:= true;
  if parentwidget.container.canclose(nil) then begin
    with dsContents.dataset as tmsesqlquery do begin
      applyupdates;
      (transaction as tmsesqltransaction).commit;
      active:= true;
    end;
  end;
  isexpected:= false;  
end;

procedure tcommonrefseditfo.undoexecute(const sender: TObject);
begin
//  (dsContents.dataset as tmsesqlquery).cancelupdate;
end;

procedure tcommonrefseditfo.addexecute(const sender: TObject);
begin
  isexpected:= true;
  if parentwidget.canparentclose(nil) then begin
    dsContents.dataset.append;
  end;
  isexpected:= false;
end;

procedure tcommonrefseditfo.deleteexecute(const sender: TObject);
begin
  dsContents.dataset.delete;
end;

procedure tcommonrefseditfo.undoallexecute(const sender: TObject);
begin
  (dsContents.dataset as tmsesqlquery).cancelupdates;
end;

procedure tcommonrefseditfo.commonrefseditfoclosequery(const sender: tcustommseform;
               var amodalresult: modalresultty);
begin
  with dsContents.dataset as tmsesqlquery do begin
    if (not isexpected) and (changecount > 0) then begin
       showmessage(
        'There are unsaved changes in the table. Fix them !',
        'Unsaved changes',
        [mr_ok]
      );
      amodalresult:= mr_none;
    end;
  end;
end;

end.
