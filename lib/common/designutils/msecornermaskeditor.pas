unit msecornermaskeditor;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,msesplitter,
 msesimplewidgets,msedataedits,mseedit,mseificomp,mseificompglob,mseifiglob,
 msestatfile,msestream,msestrings,sysutils,msegrids,msewidgetgrid,msegraphedits,
 msescrollbar,msebitmap;
type
 tmsecornermaskeditorfo = class(tmseform)
   tsplitter1: tsplitter;
   tbutton2: tbutton;
   tbutton1: tbutton;
   tspacer2: tspacer;
   grid: twidgetgrid;
   maskwidthed: tintegeredit;
   statfile1: tstatfile;
   procedure createexe(const sender: TObject);
   procedure closequexe(const sender: tcustommseform;
                   var amodalresult: modalresultty);
  protected
   findexlist: pmsestring;
   fok: pboolean;
  public
   constructor create(var indexlist: msestring; out ok: boolean);
 end;

function editcornermask(var indexlist: msestring): boolean;

implementation
uses
 msecornermaskeditor_mfm;

function editcornermask(var indexlist: msestring): boolean;
begin
 tmsecornermaskeditorfo.create(indexlist,result);
end;

{ tmsecornermaskeditorfo }

constructor tmsecornermaskeditorfo.create(var indexlist: msestring;
                                                           out ok: boolean);
begin
 findexlist:= @indexlist;
 fok:= @ok;
 inherited create(nil);
end;

procedure tmsecornermaskeditorfo.createexe(const sender: TObject);
var
 i1: int32;
 po1: pint16;
begin
 grid.beginupdate();
 grid.rowcount:= length(findexlist^);
 po1:= pointer(findexlist^);
 for i1:= 0 to grid.rowhigh do begin
  maskwidthed[i1]:= po1[i1];
 end;
 grid.endupdate();
end;

procedure tmsecornermaskeditorfo.closequexe(const sender: tcustommseform;
               var amodalresult: modalresultty);
var
 i1: int32;
 po1: pint16;
begin
 fok^:= amodalresult = mr_ok;
 if fok^ then begin
  setlength(findexlist^,grid.rowcount);
  po1:= pointer(findexlist^);
  for i1:= 0 to grid.rowhigh do begin
   po1[i1]:= maskwidthed[i1];
  end;
 end;
end;

end.
