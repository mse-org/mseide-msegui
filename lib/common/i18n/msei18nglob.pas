{ MSEgui Copyright (c) 2005-2012 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msei18nglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
const
 registerlangname = 'registerlang';
 unregisterlangname = 'unregisterlang';
type
 registermodulety = procedure(datapo: pointer; //pobjectdataty
                            const objectclassname: shortstring;
                            const name: shortstring); cdecl;
 registerresourcety = procedure(datapo: pointer); cdecl; 
                                               //pobjectdataty

// procedure registerlang(const registerlangmoduleproc: registerlangmodulety);
 
implementation
end.
