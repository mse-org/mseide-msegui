unit msedirtreesub;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,mseglob,mseguiglob,mseguiintf,mseapplication,msestat,msemenus,msegui,
 msegraphics,msegraphutils,mseevent,mseclasses,msewidgets,mseforms,
 msedirtree,msefiledialog,mclasses;

type
 tdirtreesubfo = class(tdirtreefo)
  private
  protected
   procedure doondataentered(); override;
  public
   constructor create(aowner: tcomponent); override;
  published
 end;

implementation
uses
 msedirtreesub_mfm;

{ tdirtreesubfo }

procedure tdirtreesubfo.doondataentered();
begin
 //do nothing
end;

constructor tdirtreesubfo.create(aowner: tcomponent);
begin
 inherited;
end;

end.
