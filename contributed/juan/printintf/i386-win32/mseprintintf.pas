unit mseprintintf; // i386-win32

{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}

interface
uses sysutils,msestrings,dynlibs;

// Types
type
  tdevicemode =  packed record
    dmDeviceName: array[0..31] of AnsiChar;
    dmSpecVersion: Word;
    dmDriverVersion: Word;
    dmSize: Word;
    dmDriverExtra: Word;
    dmFields: DWORD;
    dmOrientation: smallint;
    dmPaperSize: smallint;
    dmPaperLength: smallint;
    dmPaperWidth: smallint;
    dmScale: smallint;
    dmCopies: smallint;
    dmDefaultSource: smallint;
    dmPrintQuality: smallint;
    dmColor: smallint;
    dmDuplex: smallint;
    dmYResolution: smallint;
    dmTTOption: smallint;
    dmCollate: smallint;
    dmFormName: Array[0..31] of AnsiChar;
    dmLogPixels: Word;
    dmBitsPerPel: DWORD;
    dmPelsWidth: DWORD;
    dmPelsHeight: DWORD;
    dmDisplayFlags: DWORD;
    dmDisplayFrequency: DWORD;
    dmICMMethod: DWORD;
    dmICMIntent: DWORD;
    dmMediaType: DWORD;
    dmDitherType: DWORD;
    dmICCManufacturer : DWORD;
    dmICCModel: DWORD;
    dmPanningWidth: DWORD;
    dmPanningHeight: DWORD;
  end;

  pdevicemode = ^tdevicemode;
    
  printer_info_2 = packed Record
     pServerName: PChar;
     pPrinterName: PChar;
     pShareName: PChar;
     pPortName: PChar;
     pDriverName: PChar;
     pComment: PChar;
     pLocation: PChar;
     pDevMode: PDeviceMode;
     pSepFile: PChar;
     pPrintProcessor: PChar;
     pDatatype: PChar;
     pParameters: PChar;
     pSecurityDescriptor: Pointer;
     Attributes: DWORD;
     Priority: DWORD;
     DefaultPriority: DWORD;
     StartTime: DWORD;
     UntilTime: DWORD;
     Status: DWORD;
     cJobs: DWORD;
     AveragePPM: DWORD; 
  end;
  
  pprinter_info_2 = ^printer_info_2;
  
  printer_info_4 = packed Record
    pprintername: pchar; 
    pservername: pchar;
    attributes: dword; 
  end;

  pprinter_info_4 = ^printer_info_4;

  printer_info_5 = packed Record
     pprintername: pchar;
     pportname: pchar;
     attributes: dword;
     devicenotselectedtimeout: dword;
     transmissionretrytimeout: dword;
  end;

  pprinter_info_5 = ^printer_info_5;          


const
  PRINT_LIBRARY = 'winspool.drv';

  // DLL load/unload functions
  function initializedll(): boolean;
  procedure finalizedll();

var
  dllpointer: tlibhandle;
  
  // Functions from gdi libs
  enumprinters: function(flags: dword; name: pchar; level: dword;
    pprinterenum: pointer; cbbuf: dword;
    var pcbneeded, pcreturned: dword): boolean; stdcall;

  function getprofilestring(lpappname:pchar;
    lpkeyname: pchar; lpdefault: pchar; lpreturnedstring: pchar;
      nsize: dword): dword; stdcall; external 'kernel32' name 'GetProfileStringA';
  
{$ifdef FPC}
{$include ../mseprintintf.inc}
{$else}
{$include mseprintintf.inc}
{$endif}

implementation

{
*************************************
GDI DLL load function
*************************************
}

function initializedll(): boolean;
begin
  initializedll:= false; // Default value
  
  dllpointer:= 0;
  dllpointer:= loadlibrary(PRINT_LIBRARY);
  
  if dllpointer <> 0 then
  begin
    initializedll:= true;
  end
  else
  begin
    exit;
  end;
  
  pointer(enumprinters):= getprocedureaddress(dllpointer, 'EnumPrintersA');
end;

{
*************************************
GDI DLL unload function
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
  flags: dword;
  needed: dword;
  level: dword;
  infobuffer: pchar;
  infoptr: pchar;
  printercount: dword;
  counter: longint;
begin
  result:= nil;
  flags:= 2 or 4;
  needed:= 0;
  level:= 4;

  if initializedll = false then exit;
  
  enumprinters(flags,nil,level,nil,0,needed,printercount);
  if Needed > 0 then
  begin
    getmem(infobuffer,needed);
    fillchar(infobuffer^,needed,0);
    
    enumprinters(flags,nil,level,infobuffer,needed,needed,printercount);
    infoptr:= infobuffer;
    setlength(result, printercount);
    
    for counter:= 0 to high(result) do
      begin
        result[counter]:= (pprinter_info_4(infoptr)^.pprintername);
        inc(infoptr,sizeof(printer_info_4));
      end;
    freemem(infobuffer);
    
  end;
       
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
  flags: dword;
  level: dword;
  needed: dword;
  infobuffer: pchar;
  printercount: dword;
  defaultprinter: array[0..79] of char;
  
begin
  result:= '';
  
  if initializedll = false then exit;

  flags:= 1;
  needed:=0;  
  level:=5;

  enumprinters(flags,nil,level,nil,0,needed,printercount);
  if Needed > 0 then
  begin
    // Win95/98/ME
    getmem(infobuffer,needed);
    fillchar(infobuffer^,needed,0);

    if enumprinters(flags,nil,level,infobuffer,needed,needed,printercount) then
    begin
      result:=pprinter_info_5(infobuffer)^.pprintername;
    end;
    
    freemem(infobuffer);
  end
  else
  begin
    // WinNT4.0/W2K/WXP
    getprofilestring(pchar('windows'),pchar('device'),pchar(''),
      defaultprinter,sizeof(defaultprinter));
    
    if pos(',',defaultprinter) <> 0 then
    begin;
      defaultprinter:= copy(defaultprinter,1,Pos(',',defaultprinter) - 1);
      result:= strpas(defaultprinter);
    end;
  end;
  
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
  flags: dword;
  level: dword;
  needed: dword;
  infobuffer: pchar;
  printercount: dword;
  pprintername: pchar;
  counter: longint;
  defaultprinter: msestring;
  
begin
  result:= false;

  flags:= 2 or 4;
  needed:= 0;
  level:= 2;
  
  defaultprinter:= pri_getdefaultprinter;
  
  if initializedll = false then exit;
  
  getmem(pprintername,length(printername) + 1);
  fillchar(pprintername^,length(printername) + 1, 0);
  strpcopy(pprintername,printername);
  
  enumprinters(flags,nil,level,nil,0,needed,printercount);
  if Needed > 0 then
  begin
    getmem(infobuffer,needed);
    fillchar(infobuffer^,needed,0);
    
    enumprinters(flags,nil,level,infobuffer,needed,needed,printercount);

    for counter:= 0 to printercount - 1 do
      begin
        if strcomp(pprintername, pprinter_info_2(infobuffer)^.pprintername) = 0 then
        begin
          properties.printername:= strpas(pprinter_info_2(infobuffer)^.pprintername);
          properties.drivername:= strpas(pprinter_info_2(infobuffer)^.pdrivername);
          properties.location:= strpas(pprinter_info_2(infobuffer)^.plocation);
          properties.description:= strpas(pprinter_info_2(infobuffer)^.pcomment);
      
          properties.isdefault:= defaultprinter = 
                         strpas(pprinter_info_2(infobuffer)^.pprintername);
          
          properties.isshared:=
             pprinter_info_2(infobuffer)^.attributes or 8 = 
                      pprinter_info_2(infobuffer)^.attributes;
                      //???? mse
          
          properties.islocal:= pprinter_info_2(infobuffer)^.pservername <> nil;
          
          result:= true;
          freemem(infobuffer);
          freemem(pprintername);
          finalizedll;
          exit;
        end;
        inc(infobuffer,sizeof(printer_info_2));
      end;

    freemem(infobuffer);
  end;
  
  freemem(pprintername);
  
  finalizedll;
end;

end.
