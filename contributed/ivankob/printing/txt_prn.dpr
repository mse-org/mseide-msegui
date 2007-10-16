{ Copyright (c) 2007 by IvankoB

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
program txt_prn;

{$APPTYPE CONSOLE}

uses
  SysUtils, Winspool, Wintypes;

var
  buff:  array[0..255] of Char;

  FileName: PChar;

  sPrnName: AnsiString;
  hPrnHandle: THandle;

  JobInfo: record
    JobInfo1: record // ADDJOB_INFO_1
      Path: PChar;
      JobID: LongWord;
    end;
    PathBuffer: array[0..255] of Char;
  end;
  job_info_size: LongWord;

begin
  { TODO -oUser -cConsole Main : Insert code here }

  if not (ParamCount = 1) then begin
    writeln('One argument should be supplied - file name to print!');
    halt;
  end;

  if not FileExists(ParamStr(1)) then begin
    writeln('The input file does not exist or could not be open! Exiting...');
    halt;
  end;
  FileName:= PChar(ParamStr(1));

  // Obtaining the default printer description...
  if not (GetProfileString('windows','device','', buff, SizeOf(buff)) > 0) then begin
    writeln('No default printer defined! Exiting...');
    halt;
  end;
  SetString(sPrnName, buff, Pos(',', buff)-1);
  writeln('The default printer is: '+sPrnName);

  try

    if OpenPrinter(PChar(sPrnName),hPrnHandle,nil) then begin

      writeln('The printer is successfully open with handle: '+IntToStr(hPrnHandle)+'.');
      if AddJob(
        hPrnHandle,	// specifies printer for the print job
        1,	// specifies version of print job information data structure
        @JobInfo,	// pointer to buffer to receive print job information data
        sizeof(JobInfo),
        job_info_size 	// pointer to variable to receive size of print job information data
      ) then begin
        writeln('The job is allocated as a file : '+JobInfo.JobInfo1.Path+'.');

        if CopyFile(FileName, JobInfo.JobInfo1.Path, True) then begin
          writeln ('The input file is successfully copied to the job file.');

          if ScheduleJob(hPrnHandle,JobInfo.JobInfo1.JobID) then
            writeln ('The job is now scheduled to print on: '+sPrnName+'.')
          else
            writeln ('The job could not be sheduled! Exiting...')
          end
        else
          writeln ('The job file could not be written to! Exiting...')
        end
      else
        writeln('The job could not be added! Exiting...')
      end
    else
      writeln('The printer could not be open! Exiting...');

  finally
    ClosePrinter(hPrnHandle);
  end;

end.
