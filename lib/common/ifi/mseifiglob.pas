{ MSEgui Copyright (c) 2007-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseifiglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface
uses
 mseglob,mseeditglob,typinfo;
const
 ifiwidgetstatename = '#widgestate#';
 ifiwidgetmodalresultname = '#modalres#';
{$ifdef FPC}
 boolprops = [tkbool,tkinteger,tkenumeration];
{$else}
 boolprops = [tkinteger,tkenumeration];
{$endif}
 
type
 ifiwidgetstatety = ({iws_closed,}iws_visible,iws_focused,iws_active); 
 ifiwidgetstatesty = set of ifiwidgetstatety;
 
type
 iificlient = interface;

 iifiserver = interface(inullinterface)
  procedure execute(const sender: iificlient);
  procedure valuechanged(const sender: iificlient);
  procedure statechanged(const sender: iificlient;
                           const astate: ifiwidgetstatesty);
  procedure setvalue(const sender: iificlient;
                     var avalue; var accept: boolean; const arow: integer);
  procedure dataentered(const sender: iificlient; const arow: integer);
  procedure sendmodalresult(const sender: iificlient; 
                                         const amodalresult: modalresultty);
  procedure updateoptionsedit(var avalue: optionseditty);
 end;
 
 iificlient = interface(iobjectlink)['{E3523E5B-604C-46CE-88D4-55C9970BCF9A}']
  procedure setifiserverintf(const aintf: iifiserver);
//  function getifiserverintf: iifiserver;
 end;
 ificommandcodety = (icc_none,icc_close,icc_release);
 iificommand = interface(inullinterface)
                         ['{693DEACE-508E-465F-826A-801C3979C39E}'] 
  procedure executeificommand(var acommand: ificommandcodety);
 end;
implementation
end.
