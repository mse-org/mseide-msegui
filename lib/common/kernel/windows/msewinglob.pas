{ MSEgui Copyright (c) 1999-2011 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msewinglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 windows{$ifndef FPC},messages{$endif};

const
 msemessage = wm_user + $3694;
 wakeupmessage = msemessage + 1;
 destroymessage = msemessage + 2;
 traycallbackmessage = msemessage + 3;
 timermessage = msemessage + 4;

implementation
end.
