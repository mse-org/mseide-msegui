unit main;

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 mseglob,msegui,mseclasses,mseforms,msesimplewidgets,msemenus,msereport,msedbedit,
 msesqldb,msedb,msedbgraphics,mseevent,mseactions,msebitmap,mseibconnection,
 msefiledialog, msestrings,msesplitter;

type
 tmainfo = class(tmseform)
   ds: tmsedatasource;
   qry: tmsesqlquery;
   actLoad: taction;
   actSave: taction;
   actClear: taction;
   tbutton1: tbutton;
   tbutton2: tbutton;
   mnuMain: tmainmenu;
   ftButtons: tframecomp;
   ftMenu: tframecomp;
   tbutton3: tbutton;
   tdbdataimage1: tdbdataimage;
   tdbmemoedit1: tdbmemoedit;
   tdbrealedit1: tdbrealedit;
   dlgImageFile: tfiledialog;
   tgroupbox1: tgroupbox;
   ilActions: timagelist;
   tlabel2: tlabel;
   tlabel3: tlabel;
   fldFloatStuff: tmsefloatfield;
   fldPhoto: tmsegraphicfield;
   fldLongText: tmsememofield;
   pmPhoto: tpopupmenu;
   tspacer2: tspacer;
   wgrdMain: tdbwidgetgrid;
   procedure reportexec(const sender: TObject);
   procedure printproc(const areport: tcustomreport);   
   procedure exit(const sender: TObject);
   procedure loadexec(const sender: TObject);
   procedure saveexec(const sender: TObject);
   procedure clearexec(const sender: TObject);
   procedure reportcurrexec(const sender: TObject);
 end;
var
 mainfo: tmainfo;

implementation

uses
 main_mfm,
 reportik,
 reportcurr,
 msestream, // ttextstream
 mseprinter, // pao_*
 msesys, // fm_create
 sysutils,  // gettemp*
 dmprint,
 msewidgets,
 mseformatpng,
 mseformatjpg,
 mseformatbmpico
;

var
 psoutfile: msestring;

procedure tmainfo.printproc(const areport: tcustomreport);
begin
 dmprint.printout(psoutfile);
end;

procedure tmainfo.reportexec(const sender: TObject);
var
 psstream : ttextstream;
begin
 canclose(nil);
 psoutfile:= gettempfilename(gettempdir ,'printtestcase');
 psstream:= ttextstream.create(psoutfile,fm_create);
 reportikre:= treportikre.create(nil);
 with dmprintmo,psprn,canvas do begin
  reportikre.render(
   psprn,
   psstream,
   {$ifdef fpc}@{$endif}printproc
  );
 end;
end;

procedure tmainfo.exit(const sender: TObject);
begin
 application.terminate;
end;

procedure tmainfo.loadexec(const sender: TObject);
begin
 with fldPhoto, dataset do begin
  if dlgImageFile.execute(fdk_open) = mr_ok then begin
   edit;
   loadfromfile(dlgImageFile.controller.filename);
   post;
  end;
 end;
end;

procedure tmainfo.saveexec(const sender: TObject);
begin
 with fldPhoto, dataset do begin
  if (not isnull) and (dlgImageFile.execute(fdk_save) = mr_ok) then begin
   savetofile(dlgImageFile.controller.filename);
  end;
 end;
end;

procedure tmainfo.clearexec(const sender: TObject);
begin
 with fldPhoto, dataset do begin   
  edit;
  fldPhoto.clear;
  post; 
 end;
end;

procedure tmainfo.reportcurrexec(const sender: TObject);
var
 psstream : ttextstream;
begin
 canclose(nil);
 psoutfile:= gettempfilename(gettempdir ,'printtestcasecurr');
 psstream:= ttextstream.create(psoutfile,fm_create);
 reportcurrre:= treportcurrre.create(nil);
 with dmprintmo,psprn,canvas do begin
  reportcurrre.render(
   psprn,
   psstream,
   {$ifdef fpc}@{$endif}printproc
  );
 end;

end;

end.
