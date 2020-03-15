
unit sm;
interface
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

{$IFDEF FPC}
 {$PACKRECORDS C}
{$else}
 {$ALIGN 4}
 {$MINENUMSIZE 4}
{$ENDIF}


  { $Xorg: SM.h,v 1.4 2001/02/09 02:03:30 xorgcvs Exp $  }
  {

  Copyright 1993, 1998  The Open Group

  Permission to use, copy, modify, distribute, and sell this software and its
  documentation for any purpose is hereby granted without fee, provided that
  the above copyright notice appear in all copies and that both that
  copyright notice and this permission notice appear in supporting
  documentation.

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
  AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  Except as contained in this notice, the name of The Open Group shall not be
  used in advertising or otherwise to promote the sale, use or other dealings
  in this Software without prior written authorization from The Open Group.

   }
  {
   * Author: Ralph Mor, X Consortium
    }
  {
   * Protocol Version
    }

  const
     SmProtoMajor = 1;
     SmProtoMinor = 0;
  {
   * Interact Style
    }
     SmInteractStyleNone = 0;
     SmInteractStyleErrors = 1;
     SmInteractStyleAny = 2;
  {
   * Dialog Type
    }
     SmDialogError = 0;
     SmDialogNormal = 1;
  {
   * Save Type
    }
     SmSaveGlobal = 0;
     SmSaveLocal = 1;
     SmSaveBoth = 2;
  {
   * Restart Style Hints
    }
     SmRestartIfRunning = 0;
     SmRestartAnyway = 1;
     SmRestartImmediately = 2;
     SmRestartNever = 3;
  {
   * Property names
    }
     SmCloneCommand = 'CloneCommand';
     SmCurrentDirectory = 'CurrentDirectory';
     SmDiscardCommand = 'DiscardCommand';
     SmEnvironment = 'Environment';
     SmProcessID = 'ProcessID';
     SmProgram = 'Program';
     SmRestartCommand = 'RestartCommand';
     SmResignCommand = 'ResignCommand';
     SmRestartStyleHint = 'RestartStyleHint';
     SmShutdownCommand = 'ShutdownCommand';
     SmUserID = 'UserID';
  {
   * Property types
    }
     SmCARD8 = 'CARD8';
     SmARRAY8 = 'ARRAY8';
     SmLISTofARRAY8 = 'LISTofARRAY8';
  {
   * SM minor opcodes
    }
     SM_Error = 0;
     SM_RegisterClient = 1;
     SM_RegisterClientReply = 2;
     SM_SaveYourself = 3;
     SM_SaveYourselfRequest = 4;
     SM_InteractRequest = 5;
     SM_Interact = 6;
     SM_InteractDone = 7;
     SM_SaveYourselfDone = 8;
     SM_Die = 9;
     SM_ShutdownCancelled = 10;
     SM_CloseConnection = 11;
     SM_SetProperties = 12;
     SM_DeleteProperties = 13;
     SM_GetProperties = 14;
     SM_PropertiesReply = 15;
     SM_SaveYourselfPhase2Request = 16;
     SM_SaveYourselfPhase2 = 17;
     SM_SaveComplete = 18;
  { _SM_H_  }
 SmcSaveYourselfProcMask =	    1 shl 0;
 SmcDieProcMask =               1 shl 1;
 SmcSaveCompleteProcMask =      1 shl 2;
 SmcShutdownCancelledProcMask = 1 shl 3;

type
 bool = integer;{longbool} //protocoll does not accept -1 for true
 Status = integer;
 SmPointer = pointer;
 SmcConn = pointer;
 SmcCloseStatus = (SmcClosedNow,SmcClosedASAP,SmcConnectionInUse);

 SmcSaveYourselfProc = procedure(_smcConn: SmcConn; clientData: pointer;
                        saveType: integer; shutdown: bool;
                        interactStyle: integer; fast: bool); cdecl;
 SmcDieProc = procedure(_smcConn: SmcConn; clientData: pointer); cdecl;
 SmcSaveCompleteProc = procedure(_smcConn: SmcConn; clientData: pointer); cdecl;
 SmcShutdownCancelledProc = procedure(_smcConn: SmcConn;
                               clientData: pointer); cdecl;

 SmcCallbacks = record
  save_yourself: record
   callback: SmcSaveYourselfProc;
   client_data: pointer;
  end;
  die: record
   callback: SmcDieProc;
   client_data: pointer;
  end;
  save_complete: record
   callback: SmcSaveCompleteProc;
   client_data: pointer;
  end;
  shutdown_cancelled: record
   callback: SmcShutdownCancelledProc;
   client_data: pointer;
  end;
 end;

 SmcInteractProc = procedure(_smcConn: SmcConn; clientData: SmPointer); cdecl;

var
 SmcOpenConnection: function(networkIdsList: pchar; context: Pointer;
             xsmpMajorRev: integer; xsmpMinorRev: integer;
             mask: longword; var callbacks: SmcCallbacks;
             previousId: pchar; var clientIdRet: pchar;
             errorLength: integer; errorStringRet: pchar): SmcConn; cdecl;
 SmcCloseConnection: function(_smcConn: SmcConn;
            count: integer; reasonMsgs: ppchar): SmcCloseStatus; cdecl;
 SmcSaveYourselfDone: procedure(_smcConn: SmcConn; success: Bool); cdecl;
 SmcInteractRequest: function(_smcConn: SmcConn; dialogType: integer;
                interactProc: SmcInteractProc; clientData: SmPointer): Status;
                           cdecl;
 SmcInteractDone: procedure(_smcConn: SmcConn; cancelShutdown: Bool); cdecl;

function getsmlib: boolean;

implementation
uses
 msesys,msesonames,msedynload;

function getsmlib: boolean;
begin
 result:= checkprocaddresses(smnames,
 [
 'SmcOpenConnection',                         //0
 'SmcCloseConnection',                        //1
 'SmcSaveYourselfDone',                       //2
 'SmcInteractRequest',                        //3
 'SmcInteractDone'                            //4
 ],
 [
 {$ifndef FPC}@{$endif}@SmcOpenConnection,    //0
 {$ifndef FPC}@{$endif}@SmcCloseConnection,   //1
 {$ifndef FPC}@{$endif}@SmcSaveYourselfDone,  //2
 {$ifndef FPC}@{$endif}@SmcInteractRequest,   //3
 {$ifndef FPC}@{$endif}@SmcInteractDone       //4
 ]);
end;

end.
