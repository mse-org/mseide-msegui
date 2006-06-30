unit msei18nglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
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
