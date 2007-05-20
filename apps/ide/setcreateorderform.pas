unit setcreateorderform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,msegui,mseclasses,mseforms,msestat,msestatfile,msestrings,msedatalist,
 msedrawtext,mseevent,msegraphics,msegraphutils,msegrids,mseguiglob,
 msepipestream,msetypes,msesimplewidgets,msewidgets;

type
 tsetcreateorderfo = class(tmseform)
   statfile1: tstatfile;
   grid: tstringgrid;
   tbutton1: tbutton;
   tbutton2: tbutton;
   procedure formonclosequery(const sender: tcustommseform;
                   var amodalresult: modalresultty);
  private
   fmodule: tcomponent;
  public
   constructor create(aowner: tcomponent); override;
 end;
var
 setcreateorderfo: tsetcreateorderfo;
 
implementation
uses
 setcreateorderform_mfm,msedesigner;
 
{ tsetcreateorderfo }

constructor tsetcreateorderfo.create(aowner: tcomponent);
var
 int1: integer;
begin
 inherited create(nil);
 caption:= 'Set Component create Order of '+aowner.name;
 fmodule:= aowner;
 with aowner do begin
  for int1:= 0 to componentcount - 1 do begin
   with components[int1] do begin
    if not hasparent then begin
     grid.appendrow([msestring(name),msestring(classname)]);
    end;
   end;
  end;
 end;
end;

procedure tsetcreateorderfo.formonclosequery(const sender: tcustommseform;
               var amodalresult: modalresultty);
var
 int1: integer;
 comp1: tcomponent;
begin
 if amodalresult = mr_ok then begin
  setcomponentorder(fmodule,grid[0].datalist.asarray);
  designer.componentmodified(fmodule);
 end;
end;

end.
