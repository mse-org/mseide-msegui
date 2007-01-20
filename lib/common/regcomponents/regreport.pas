{ MSEgui Copyright (c) 1999-2007 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit regreport;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
 
implementation
uses
 classes,msereport,msedesignintf,formdesigner,reportdesigner;
const
 reportintf: designmoduleintfty = 
  (createfunc: {$ifdef FPC}@{$endif}createreport;
   initnewcomponent: {$ifdef FPC}@{$endif}initreportcomponent;
   getscale: {$ifdef FPC}@{$endif}getreportscale);
  
procedure Register;
begin
 registercomponents('Rep',[{treportpage,}tbandarea,tbandgroup,
                    trecordband]); 
 
 registerdesignmoduleclass(treport,reportintf,treportdesignerfo);
end;

initialization
 registerclass(treportpage);
 register;
end.
