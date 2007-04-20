unit mainform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface

uses
 msegui,mseclasses,mseforms,msedock,msemenus, subform1, msedatalist,
 msedispwidgets,msesimplewidgets,classes;

const
 horshift =  20;
 vershift =  20;
 
type
 tmainfo = class(tdockform)
   sdSubformNum: tstringdisp;
   dockarea: tdockformwidget;
   tframecomp1: tframecomp;
   grpStatusBar: tgroupbox;
   tmainmenu1: tmainmenu;
   sdSubformCnt: tstringdisp;
   procedure makenewform(const sender: TObject);
  private
   subforms: tcomponentqueue;
   activesubform: tsubform1fo;
  public
   constructor create(aowner: tcomponent); override;
   destructor destroy; override;
   procedure listchanged;
   procedure subformactivated(const sender: tsubform1fo);
 end;

var
 mainfo: tmainfo;

implementation

uses
 mainform_mfm,
 sysutils, // inttostr
 msegraphutils // makepoint
;

constructor tmainfo.create(aowner: tcomponent);
begin
 subforms:= tcomponentqueue.create(true);
 inherited;
end;

destructor tmainfo.destroy;
begin
 subforms.free;
 inherited;
end;

procedure tmainfo.listchanged;
begin
 if not (csdestroying in componentstate) then begin
  sdSubformCnt.value:= inttostr(subforms.count);
  sdSubformNum.value:= inttostr(subforms.findobject(activesubform));
 end;
end;

procedure tmainfo.makenewform(const sender: TObject);
var
 idx: integer;
 subfo: tsubform1fo;
begin
 subfo:= tsubform1fo.create(nil);
 idx:= subforms.add(subfo);
 with dockarea.container do begin
  insertwidget(
   subfo,
   makepoint(
    clientwidgetpos.x + idx*horshift,
    clientwidgetpos.y + idx*vershift
   )
  ); 
 end;
// shows the initially invisible form 
// then brings it to front 
 subfo.activate; 
 listchanged;
end;

procedure tmainfo.subformactivated(const sender: tsubform1fo);
begin
 activesubform:= sender;
 listchanged;
end;


end.
