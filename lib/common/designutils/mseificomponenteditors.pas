{ MSEgui Copyright (c) 2009-2013 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseificomponenteditors;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msecomponenteditors,msedesignintf,classes,mclasses,mseificlienteditor;

const
 ificlienteditorstatname = 'ificlienteditor.sta';
 
type
 tifilinkcompeditor = class(tcomponenteditor)
  public
   constructor create(const adesigner: idesigner;
                           acomponent: tcomponent); override;
   procedure edit; override;
 end;
 
implementation
uses
 mseificomp,mseglob;
 
{ tifilinkcompeditor }

constructor tifilinkcompeditor.create(const adesigner: idesigner;
               acomponent: tcomponent);
begin
 inherited;
 fstate:= fstate + [cs_canedit];
end;

procedure tifilinkcompeditor.edit;
begin
 if editificlient(tifilinkcomp(fcomponent)) = mr_ok then begin
  fdesigner.componentmodified(fcomponent);
 end;
end;

end.
