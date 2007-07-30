// Implementation of common printing interface
// i386-linux system

unit mseprintintf; // i386-linux

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses sysutils,msestrings,dynlibs;

// Types
type
  cups_option_t = record
    name: pchar; // Option name
    value: pchar; // Option value
  end;

  pcups_option_t = ^cups_option_t;
  ppcups_option_t =^pcups_option_t;

  cups_dest_t = record
    name: pchar; // Printer name
    instance: pchar;          
    is_default: longint; // Default printer?
    num_options: longint; // Number of options
    options: pcups_option_t; // Options
  end;

  pcups_dest_t = ^cups_dest_t;
  ppcups_dest_t = ^pcups_dest_t;

const
  CUPS_LIBRARY = 'libcups.so';
  
  // DLL load/unload functions
  function initializedll(): boolean;
  procedure finalizedll();

var
  dllpointer: tlibhandle;
  
  // Functions from cups libs
  cupsgetdests: function(dests: ppcups_dest_t): longint;cdecl;
  cupsfreedests: procedure(num_dests: longint; dests: pcups_dest_t);cdecl;
  cupsgetoption: function(name: pchar; num_options: longint; options: pcups_option_t): pchar;cdecl;
  
{$ifdef FPC}
{$include ../mseprintintf.inc}
{$else}
{$include mseprintintf.inc}
{$endif}

implementation

{
*************************************
CUPS DLL load function
*************************************
}

function initializedll(): boolean;
begin
  initializedll:= false; // Default value
  
  dllpointer:= 0;
  dllpointer:= loadlibrary(CUPS_LIBRARY);
  
  if dllpointer <> 0 then
  begin
    initializedll:= true;
  end
  else
  begin
    exit;
  end;
  
  pointer(cupsgetdests):= getprocedureaddress(dllpointer, 'cupsGetDests');
  pointer(cupsfreedests):= getprocedureaddress(dllpointer, 'cupsFreeDests');
  pointer(cupsgetoption):= getprocedureaddress(dllpointer, 'cupsGetOption');
end;

{
*************************************
CUPS DLL unload function
*************************************
}

procedure finalizedll();
begin
  unloadlibrary(dllpointer);
end;

{
*************************************
Function to retrieve printer
names list and printer count
*************************************
}

function pri_getprinterlist: msestringarty;
var
  printercount: longint; // Number of printers
  printerlist: pcups_dest_t; // List of printers
  counter: longint;
begin
  result:= nil;
  if initializedll = false then exit;

  printercount:= cupsgetdests(@printerlist);
  setlength(result, printercount);
    
  // Make printer list 
  for counter:= 0 to high(result) do
  begin
    result[counter]:= printerlist[counter].name;
  end;
  
  // Free printer list
  cupsfreedests(printercount, printerlist);
  
  finalizedll;
end;

{
*************************************
Function to retrieve
default printer name
*************************************
}

function pri_getdefaultprinter: msestring;
var
  printercount: longint; // Number of printers
  printerlist: pcups_dest_t; // List of printers
  counter: longint;
begin
  result:= '';
  
  if initializedll = false then exit;
  
  printercount:= cupsgetdests(@printerlist);

  for counter:= 0 to printercount - 1 do
  begin
    if printerlist[counter].is_default <> 0 then
    begin
      result:= printerlist[counter].name;
      break;
    end;
  end;
  
  // Free printer list
  cupsfreedests(printercount, printerlist);

  finalizedll;
end;

{
*************************************
Function to retrieve printer
properties
*************************************
}

function pri_getprinterproperties(const printername: msestring;
                            var properties: printerpropertiesty): boolean;
var
  printercount: longint; // Number of printers
  printerlist: pcups_dest_t; // List of printers
  counter: longint;
begin 
  pri_getprinterproperties:= false; // Default value
  
  if initializedll = false then exit;
  
  printercount:= cupsgetdests(@printerlist);

  for counter:= 0 to printercount - 1 do
  begin
    if AnsiCompareStr(printerlist[counter].name, printername) = 0 then
    begin
      properties.printername:= strpas(printerlist[counter].name);
      properties.drivername:= strpas(cupsgetoption('printer-make-and-model', 
         printerlist[counter].num_options, printerlist[counter].options));
      properties.location:= ''; // Provisional
      properties.description:= strpas(cupsgetoption('printer-info', 
           printerlist[counter].num_options, printerlist[counter].options));
      properties.isdefault:= boolean(printerlist[counter].is_default);
      properties.isshared:= boolean(strtoint(cupsgetoption('printer-is-shared',
            printerlist[counter].num_options, printerlist[counter].options)));
      properties.islocal:= true; // Provisional
      
      pri_getprinterproperties:= true; // Printer found
    end;
  end;
  
  // Free printer list
  cupsfreedests(printercount, printerlist);

  finalizedll;
end;

end.
