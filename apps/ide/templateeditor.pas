unit templateeditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,mseforms,msestatfile,
 msesimplewidgets,msewidgets,msedataedits,mseedit,msegrids,msestrings,msetypes,
 msewidgetgrid,msegraphedits,msesplitter,mseeditglob,msetextedit,msedispwidgets,
 msebitmap,msedatanodes,msefiledialog,mselistbrowser,msescrollbar,msesys;
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
   savefiledialog: tfiledialog;
   deletebu: tbutton;
   saveasbu: tbutton;
   procedure onlo(const sender: TObject);
   procedure editnotify(const sender: TObject;
                   var info: editnotificationinfoty);
   procedure setcursorex(const sender: TObject);
   procedure closeq(const sender: tcustommseform;
                   var amodalresult: modalresultty);
   procedure saveasexe(const sender: TObject);
   procedure deleteexe(const sender: TObject);
  private
   findex: integer;
   fpath: filenamety;
   fdeleted: boolean;
   procedure setpath(const avalue: filenamety);
   property path: filenamety read fpath write setpath;
  public
   constructor create(const aindex: integer); reintroduce;
   function show(out aname: msestring): modalresultty; reintroduce;
 end;

implementation
uses
 templateeditor_mfm,msecodetemplates,projectoptionsform,sysutils,msefileutils,
 msedatalist,msesysintf;
 
constructor ttemplateeditorfo.create(const aindex: integer);
begin
 findex:= aindex;
 inherited create(nil);
end;

procedure ttemplateeditorfo.onlo(const sender: TObject);
var
 int1: integer;
 dir1: filenamety;
begin
 if savefiledialog.controller.lastdir = '' then begin
  if findfile('',projectoptions.texp.codetemplatedirs,dir1) or 
     findfile('',expandprmacros('${TEMPLATEDIR}'),dir1) then begin
   savefiledialog.controller.lastdir:= dir1;
  end;
 end;
 projectoptionstofont(templed.font);
 templgrid.datarowheight:= templed.font.lineheight;
 if (findex >= 0) and (findex <= high(codetemplates.templates)) then begin
  with codetemplates.templates[findex] do begin
   self.path:= path;
   selected.value:= select;
   indented.value:= indent;
   coled.value:= cursorcol+1;
   rowed.value:= cursorrow+1;
   commented.value:= comment;
   nameed.value:= name;
   paramgrid[0].datalist.asarray:= params;
   templed.settext(template);
  end;
 end
 else begin
  path:= '';
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
var
 info1: templateinfoty;
 dir1,pa1: filenamety;
 int1: integer;
begin
 if fdeleted then begin
  amodalresult:= mr_ok;
 end
 else begin
  if amodalresult = mr_ok then begin
   codetemplates.initinfo(info1);
   with info1 do begin
    select:= selected.value;
    indent:= indented.value;
    cursorcol:= coled.value - 1;
    cursorrow:= rowed.value - 1;
    comment:= commented.value;
    name:= nameed.value;
    params:= paramgrid[0].datalist.asarray;
    template:= templed.gettext;
    if fpath = '' then begin
     if not savefiledialog.controller.execute(fpath) then begin
      amodalresult:= mr_cancel;
     end;
    end;
    path:= fpath;
   end;
   if amodalresult = mr_ok then begin
    codetemplates.savefile(info1);
    dir1:= filedir(info1.path);
    pa1:= intermediatefilename(dir1+'template');
    if sys_openfile(pa1,fm_create,[],[],int1) = sye_ok then begin
     sys_closefile(int1);
     if not findfile(filename(pa1),
                             projectoptions.texp.codetemplatedirs) then begin
      deletefile(pa1);
      additem(projectoptions.t.codetemplatedirs,dir1);
      expandprojectmacros;
      projectoptionsmodified;
      showmessage('"'+dir1+
  '" has been added to ''Project''-''Options''-''Editor''-''Code Templates''.');
      exit;
     end;
    end;
    deletefile(pa1);
   end;
  end;
 end;
end;

function ttemplateeditorfo.show(out aname: msestring): modalresultty;
begin
 result:= inherited show(true);
 aname:= nameed.value;
end;

procedure ttemplateeditorfo.saveasexe(const sender: TObject);
begin
 if savefiledialog.controller.execute(fpath) then begin
  path:= fpath;
 end;
end;

procedure ttemplateeditorfo.deleteexe(const sender: TObject);
begin
 if askyesno('Do you want to delete "'+fpath+'"?') then begin
  deletefile(fpath);
  fdeleted:= true;
  window.modalresult:= mr_cancel;
 end;
end;

procedure ttemplateeditorfo.setpath(const avalue: filenamety);
begin
 fpath:= avalue;
 if fpath = '' then begin
  caption:= 'Code Template Editor';
  deletebu.enabled:= false;
 end
 else begin
  caption:= shrinkstring(fpath,40);
  deletebu.enabled:= true;
 end;
end;

end.
