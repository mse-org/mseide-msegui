unit main;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 msegui,mseclasses,mseforms,msedrawtext,mseevent,msegraphics,msesimplewidgets,
 msestrings,msewidgets,msedataedits,msedatalist,msedropdownlist,mseformatstr,
 mseinplaceedit,msestat,msestatfile,msetypes,msewidgetgrid,msethemesdialog,
 msearrayprops,msegraphutils,mseguiglob,msebitmap,msegraphedits;

type
 tmainfo = class(tmseform)
   tbutton1: tbutton;
   tbutton2: tbutton;
   tbutton3: tbutton;
   tbutton4: tbutton;
   tbutton5: tbutton;
   tbutton6: tbutton;
   tcalendardatetimeedit1: tcalendardatetimeedit;
   tfacecomp1: tfacecomp;
   tgroupbox1: tgroupbox;
   tgroupbox2: tgroupbox;
   tintegeredit1: tintegeredit;
   tlabel1: tlabel;
   tslider1: tslider;
   tslider2: tslider;
   tstatfile1: tstatfile;
   tstringedit1: tstringedit;
   tthemesedit1: tthemesedit;
   procedure changethemes(const sender: TObject);
 end;
var
 mainfo: tmainfo;
implementation
uses
 main_mfm;
procedure tmainfo.changethemes(const sender: TObject);
begin
	tthemesedit1.showdialog;
end;

end.
