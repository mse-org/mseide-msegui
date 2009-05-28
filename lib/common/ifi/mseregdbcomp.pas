{ MSEgui Copyright (c) 2007-2009 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseregdbcomp;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
implementation
uses
 classes,msedbedit,mselookupbuffer,msedb,msedbf,msesdfdata,msememds,msesqldb,
 msqldb,msesqlresult,mseibconnection,msepqconnection,msesqlite3conn,
 mseodbcconn,msemysql40conn,msemysql41conn,msemysql50conn,msedbgraphics,
 msedbdialog,msedbevents,msedbdispwidgets,msedblookup,mseifidbgui,
 msedbcalendardatetimeedit
  {$ifdef mse_with_sqlite}
 ,msesqlite3ds
 {$endif}
;
begin
 registerclasses([tdbnavigator,tdbstringgrid,
      tlookupbuffer,tdblookupbuffer,tdbmemolookupbuffer,
      tmsedatasource,
      tmsedbf,tmsefixedformatdataset,tmsesdfdataset,tmsememdataset,
      tmsesqlquery,tmsesqltransaction,
      tsqlstatement,tmsesqlscript,tsqlresult,tsqllookupbuffer,
      tmseibconnection,tmsepqconnection,tsqlite3connection,tmseodbcconnection,
      tmsemysql40connection,tmsemysql41connection,tmsemysql50connection
      {$ifdef mse_with_sqlite}
       ,tmsesqlite3dataset
      {$endif}]);
 registerclasses([tdbwidgetgrid,tdbrxwidgetgrid,
      tenumeditdb,tkeystringeditdb,tenumeditlb,tkeystringeditlb,
      tdbmemoedit,tdbstringedit,tdbdropdownlistedit,tdbdialogstringedit,
      tdbbooleantextedit,
      tdbkeystringedit,tdbkeystringeditdb,tdbkeystringeditlb,
      tdbintegeredit,tdbenumedit,tdbenumeditdb,tdbenumeditlb,
      tdbdataicon,tdbdataimage,tdbdatabutton,tdbrealedit,tdbprogressbar,
      tdbdatetimeedit,
      tdbcalendardatetimeedit,tdbfilenameedit,
      tdbbooleanedit,tdbbooleaneditradio,
      tdbstringlookuplb,tdbintegerlookuplb,tdbreallookuplb,tdbdatetimelookuplb
      ]);
 registerclasses([
      tfieldparamlink,tfieldlink,ttimestampfieldlink,tfieldfieldlink,
      tsequencelink,tdbevent,
      tmsestringfield,tmselongintfield,tmselargeintfield,tmsesmallintfield,
      tmsewordfield,tmseautoincfield,tmsefloatfield,tmsecurrencyfield,
      tmsebooleanfield,tmsedatetimefield,tmsedatefield,tmsetimefield,
      tmsebinaryfield,tmsebytesfield,tmsevarbytesfield,
      tmsebcdfield,tmseblobfield,tmsememofield,tmsegraphicfield,
      tdblabel,tdbstringdisp,tdbintegerdisp,tdbbooleandisp,
      tdbrealdisp,tdbdatetimedisp,
      tdbstringdisplb,tdbintegerdisplb,tdbrealdisplb,tdbdatetimedisplb
      ]);
 
end.
