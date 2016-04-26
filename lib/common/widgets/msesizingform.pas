{ MSEgui Copyright (c) 2016 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msesizingform;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseforms,mseclasses;
 
type
 tsizingform = class(tmseform)
  protected
   class function getmoduleclassname: string; override;
   class function hasresource: boolean; override;
  public
 end;
   
 sizingformclassty = class of tsizingform;

function createsizingform(const aclass: tclass; 
                   const aclassname: pshortstring): tmsecomponent;

implementation
type
 tmsecomponent1 = class(tmsecomponent);
 
function createsizingform(const aclass: tclass; 
                    const aclassname: pshortstring): tmsecomponent;

begin
 result:= sizingformclassty(aclass).create(nil,false);
 tmsecomponent1(result).factualclassname:= aclassname;
end;

{ tsizingform }

class function tsizingform.getmoduleclassname: string;
begin
 result:= 'tsizingform';
end;

class function tsizingform.hasresource: boolean;
begin
 result:= self <> tsizingform;
end;

end.
