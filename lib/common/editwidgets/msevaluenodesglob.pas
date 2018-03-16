{ MSEgui Copyright (c) 1999-2015 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msevaluenodesglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msedatalist,mseglob;
type
 recvaluety = record
  datatype: listdatatypety;
  valueindex: int32;
  valuead: pointer;
  dummypointer: pointer; //can be used by clients, inited with nil
 end;
 precvaluety = ^recvaluety;
 recvaluearty = array of recvaluety;
 
implementation
end.
