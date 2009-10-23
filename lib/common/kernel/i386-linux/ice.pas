
unit ice;
interface
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


  { $Xorg: ICE.h,v 1.4 2001/02/09 02:03:26 xorgcvs Exp $  }
  {*****************************************************************************
  
  
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
  
  Author: Ralph Mor, X Consortium
  
  ***************************************************************************** }
  {
   * Protocol Version
    }

  const
     IceProtoMajor = 1;     
     IceProtoMinor = 0;     
  {
   * Byte Order
    }
     IceLSBfirst = 0;     
     IceMSBfirst = 1;     
  {
   * ICE minor opcodes
    }
     ICE_Error = 0;     
     ICE_ByteOrder = 1;     
     ICE_ConnectionSetup = 2;     
     ICE_AuthRequired = 3;     
     ICE_AuthReply = 4;     
     ICE_AuthNextPhase = 5;     
     ICE_ConnectionReply = 6;     
     ICE_ProtocolSetup = 7;     
     ICE_ProtocolReply = 8;     
     ICE_Ping = 9;     
     ICE_PingReply = 10;     
     ICE_WantToClose = 11;     
     ICE_NoClose = 12;     
  {
   * Error severity
    }
     IceCanContinue = 0;     
     IceFatalToProtocol = 1;     
     IceFatalToConnection = 2;     
  {
   * ICE error classes that are common to all protocols
    }
     IceBadMinor = $8000;     
     IceBadState = $8001;     
     IceBadLength = $8002;     
     IceBadValue = $8003;     
  {
   * ICE error classes that are specific to the ICE protocol
    }
     IceBadMajor = 0;     
     IceNoAuth = 1;     
     IceNoVersion = 2;     
     IceSetupFailed = 3;     
     IceAuthRejected = 4;     
     IceAuthFailed = 5;     
     IceProtocolDuplicate = 6;     
     IceMajorOpcodeDuplicate = 7;     
     IceUnknownProtocol = 8;     
  { _ICE_H_  }

type
 Bool = integer;{longbool}//protocoll does not accept -1 for true
 IcePointer = pointer;
 IceConn = pointer;
 Status = integer;
 IceProcessMessagesStatus = (IceProcessMessagesSuccess,IceProcessMessagesIOError,
                             IceProcessMessagesConnectionClosed);

 IceReplyWaitInfo = record
  sequence_of_request: longword;
  major_opcode_of_request: integer;
  minor_opcode_of_request: integer;
  reply: IcePointer;
 end;
 pIceReplyWaitInfo = ^IceReplyWaitInfo;

 IceWatchProc = procedure(_iceConn: IceConn; clientData: IcePointer;
                     opening: Bool; var watchData: IcePointer); cdecl;

var
 IceConnectionNumber: function (_iceConn: IceConn): integer; cdecl;
 IceAddConnectionWatch: function(watchProc: IceWatchProc;
                     clientData: IcePointer): Status; cdecl;              
 IceRemoveConnectionWatch: procedure(watchProc: IceWatchProc;
                     clientData: IcePointer); cdecl;
 IceProcessMessages: function(_iceConn: IceConn; replyWait: pIceReplyWaitInfo;
                   var replyReadyRet: bool): IceProcessMessagesStatus; cdecl;                     
function geticelib: boolean;

implementation
uses
 msesys,msesonames;
 
function geticelib: boolean;
begin
 result:= checkprocaddresses(icenames,
 [
 'IceConnectionNumber',                          //0
 'IceAddConnectionWatch',                        //1
 'IceRemoveConnectionWatch',                     //2
 'IceProcessMessages'                            //3
 ],
 [
 {$ifndef FPC}@{$endif}@IceConnectionNumber,     //0
 {$ifndef FPC}@{$endif}@IceAddConnectionWatch,   //1
 {$ifndef FPC}@{$endif}@IceRemoveConnectionWatch,//2
 {$ifndef FPC}@{$endif}@IceProcessMessages       //3
 ]);
end;

end.
