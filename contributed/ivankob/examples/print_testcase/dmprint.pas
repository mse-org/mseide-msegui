unit dmprint;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseglob,msegui,mseclasses,mseforms,msepostscriptprinter, msestrings,
 msetypes,mseactions,msestat,msedatamodules,msestatfile, mseprinter; 

type

 tdmprintmo = class(tmsedatamodule)
   psprn: tpostscriptprinter;
   actPrinterSetup: taction;
   sfPrinter: tstatfile;
   procedure dmprintmocreated(const sender: TObject);
   procedure printersetupexec(const sender: TObject);
 end;

 
var
 dmprintmo: tdmprintmo;
 
 function queuenamecheck(const aname: msestring): boolean;
 procedure printout(afile: msestring);

  
implementation

uses
 dmprint_mfm,
 sysutils, // inttostr
 msewidgets, // showmessage
 mseprocutils, // activateprocesswindow, execmse*
 msefileutils, // findfile
 msedatalist, // opentodynarraym
 {$ifndef mswindows}printersetupform{$else}printersetupformw32{$endif}
;
 

function queuenamecheck(const aname: msestring): boolean;
begin
 result:= true;
 if findchar(aname,' ') > 0 then begin
  showmessage(
   'There are spaces in the printer name what can not be processed by Ghostscript.' +
   lineend +
   'Either use another printer queue or rename to the entered name in the OS printer settings for the queue.',
   'Incorrect queue name',
   [mr_ok],
   mr_ok
  );
  result:= false; 
 end;
end;


function GetFinalCommand( aoutfile: string; var ausegui: boolean ): string;
var
 quotedfname: msestring;
{$ifndef mswindows}
 gs_device: string; 
 sQueue: string;  
 sDummy: msestring; 
 iQualityCol: integer;
{$endif}
begin

 quotedfname:= aoutfile;
 
 result:= '';
{$ifndef mswindows}
 with printersetupfo do begin // with
  if brePS.value then begin  // if(1)

   if not findfile('gs',['/usr/local/bin/','/usr/bin/'],sDummy) then begin // if(3)
    showmessage(
    'Ghostscript is required to print but not installed.' + 
    lineend +
    'Install GhostScript then retry.',
    'Ghostscript is not operable',
    [mr_ok],
    mr_ok
    );
    exit;
   end; // if(3)
 
   if breUsePreview.value then begin // if(2)
    ausegui:= true;

    if trim(kseDialogprogram.value) = '' then begin
     showmessage(
      'Printing via preview is choosen but unavailable' + 
      lineend +
      'since no preview program is assigned.',
      'Preview mode unavailable',
      [mr_ok],
      mr_ok
      );
     exit;
    end;

    if not findfile(
     kseDialogprogram.value,
     opentodynarraym([
      '/usr/local/bin/',
      '/usr/bin/',
      '/usr/bin/X11/',
      '/opt/kde3/bin/',
      '/opt/kde4/bin/'
      ]),sDummy) then begin // if(3)
     showmessage(
     'The view program assigned ( "' + kseDialogprogram.value + '" ) is unavailable.' + 
     lineend +
     'Either install it or assign another in the printer settings dialogue.',
     'The view program is not operable',
     [mr_ok],
     mr_ok
     );
     exit;
    end; // if(3)
    
    result:= kseDialogprogram.value + ' ' + quotedfname;
    
   end else begin // else(2) - no preview
   
    ausegui:= false;
    
    case brIbm.checkedtag of
     1: begin
       gs_device:= 'okiibm';
       iQualityCol:= 1; 
      end;
     2: begin 
       gs_device:= 'eps9mid';
       iQualityCol:= 2; 
      end;
     else begin
       gs_device:= 'laserjet';
       iQualityCol:= 3; 
     end;
    end; // case
    
    sQueue:= '';
    if trim(seQueueName.value) <> '' then 
     sQueue:= '-d ' + seQueueName.value;
    
    with kseQuality.dropdown do begin 
     result:= 'gs -q -dBATCH -dNOPAUSE -dSAFER -sOutputFile=-' +
      ' -r' + cols[iQualityCol][itemindex] +
      ' -sDEVICE=' + gs_device + ' ' + quotedfname +
      ' | lp ' + sQueue;
    end;
    
   end; // if(2)
  end; // if(1)
 end; // with
{$else} // -----------win32--------------
 with printersetupformw32fo do begin // with
  if brePS.value then begin  // if(1)

   if breUsePreview.value then begin // if(2)
    ausegui:= true;

    if not findfile(fneGSVPath.value) then begin // if(3)
     showmessage(
     '"Ghostscript Viewer" is not available.' + 
     lineend +
     'Close the program then install GhostScript then set it up using the printer settings dialogue.',
     'Ghostscript is not operable',
     [mr_ok],
     mr_ok
     );
     exit;
    end; // if(3)
    
    result:= quotefilename(tosysfilepath(fneGSVPath.value)) + ' ' + quotedfname;
   end else begin // else(2) - no preview
    ausegui:= false;

    if not queuenamecheck(seQueueName.value) then exit;
    
    result:= quotefilename(tosysfilepath(fneGSVPath.value)) +
     ' -p' + seQueueName.value +
     ' ' + quotedfname;
   end; // if(2)
  end; // if(1)
 end; // with

{$endif}
end;

//-----------------------------
function PrintFile(afile: msestring; out aprintcommand: msestring; atimeout: integer = 0): integer;
var
 print_cmd:msestring;
 usegui: boolean;
 print_ph: integer;

begin
 print_cmd:= GetFinalCommand(afile, usegui);
 aprintcommand:= print_cmd;
 
 if print_cmd <> '' then begin // if(1)

  if usegui then begin // if(2)
   print_ph:= execmse2(print_cmd,nil,nil,nil,false,-1,false);
   activateprocesswindow(print_ph);
    waitforprocess(print_ph); // GUI : don't autocomplete
   result:= 0; // GUI : always OK
  end else begin
   print_ph:= execmse2(print_cmd);
   getprocessexitcode(print_ph,result,atimeout*1000000);
  end;
 end else
  result:= 99; // no command to print 
  
end;

//-----------------------------

procedure tdmprintmo.dmprintmocreated(const sender: TObject);
begin
 application.createform(
  {$ifndef mswindows}
   tprintersetupfo,printersetupfo
  {$else}
   tprintersetupformw32fo,printersetupformw32fo
  {$endif}
 );
end;

 
procedure tdmprintmo.printersetupexec(const sender: TObject);
begin
   {$ifndef mswindows}
    printersetupfo
   {$else}
    printersetupformw32fo
   {$endif}.show(true);

end;

procedure printout(afile: msestring);
var
 print_cmd: msestring;
 print_exitcode: integer;
begin
  print_exitcode:= PrintFile(afile,print_cmd,30); // 30 сек timeout for non-GUI

  if print_exitcode = 99 then begin // the printing command is empty
   showmessage('Printing is cancelled.','Information',[mr_ok],mr_ok);
  end else if print_exitcode <> 0 then begin
    showmessage(
     'An error occured when printing. The printing command:' + lineend + 
     print_cmd + '.' + lineend +
     'The return code: ' + inttostr(print_exitcode),
     'Printing error',
     [mr_ok],
     mr_ok
    );
  end;

  if fileexists(afile) then 
   deletefile(afile); // clean up the PS output

end;

end.
