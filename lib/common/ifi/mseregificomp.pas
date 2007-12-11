unit mseregificomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
implementation
uses
 classes,mseifi,mseifilink,mseifigui,mseifids,msesockets,msessl;
initialization
 registerclasses([tmodulelink,tformlink,
                     {tpipeifichannel,tsocketpipeifichannel,
                     tsocketclientifichannel,tsocketserverifichannel,}
                     ttxdataset,trxdataset,
                     tpipeiochannel,tsocketstdiochannel,
                     tsocketclientiochannel,tsocketserveriochannel,
                     tsocketstdio,tsocketclient,
                     tsocketserver,tsocketserverstdio,
                     tssl]);
end.
