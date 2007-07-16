unit msegdiprint;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 classes,mseprinter,msegraphics,msegraphutils;
type
 tgdiprintercanvas = class(tprintercanvas)
  
 end;
 
 tgdiprinter = class(tprinter,icanvas)
  protected
   //icanvas
   procedure gcneeded(const sender: tcanvas);
   function getmonochrome: boolean;
  public
   constructor create(aowner: tcomponent); override;
 end;
 
implementation

{ tgdiprinter }

constructor tgdiprinter.create(aowner: tcomponent);
begin
 fcanvas:= tgdiprintercanvas.create(self,icanvas(self));
 inherited;
end;

procedure tgdiprinter.gcneeded(const sender: tcanvas);
begin
end;

function tgdiprinter.getmonochrome: boolean;
begin
 result:= false;
end;

end.
