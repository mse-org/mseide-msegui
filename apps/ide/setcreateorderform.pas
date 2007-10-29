unit setcreateorderform;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,msegui,mseclasses,mseforms,msestat,msestatfile,msestrings,msedatalist,
 msedrawtext,mseevent,msegraphics,msegraphutils,msegrids,mseguiglob,mseglob,
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
   constructor create(const amodule: tcomponent; const acurrentcompname: string);
                       reintroduce;
 end;
var
 setcreateorderfo: tsetcreateorderfo;
 
implementation
uses
 setcreateorderform_mfm,msedesigner;
 
{ tsetcreateorderfo }

constructor tsetcreateorderfo.create(const amodule: tcomponent;
                         const acurrentcompname: string);
var
 int1: integer;
 str1: string;
begin
 inherited create(nil);
 caption:= 'Set Component create Order of '+amodule.name;
 fmodule:= amodule;
 with amodule do begin
  for int1:= 0 to componentcount - 1 do begin
   with components[int1] do begin
    if not hasparent then begin
     grid.appendrow([msestring(name),msestring(classname)]);
     if acurrentcompname = name then begin
      grid.row:=int1;
     end;
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
