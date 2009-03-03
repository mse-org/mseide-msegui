{ MSEgui Copyright (c) 2007-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseregificomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 classes,mseifi,mseifilink,mseifigui,mseifids,msesockets,msessl;
initialization
 registerclasses([tmodulelink,tformlink,
                     {tpipeifichannel,tsocketpipeifichannel,
                     tsocketclientifichannel,tsocketserverifichannel,}
                     ttxdataset,trxdataset,ttxdatagrid,trxwidgetgrid,
                     tpipeiochannel,tsocketstdiochannel,
                     tsocketclientiochannel,tsocketserveriochannel,
                     tsocketstdio,tsocketclient,
                     tsocketserver,tsocketserverstdio,
                     tssl]);
end.
