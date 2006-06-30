{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseconsts_de;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseconsts;
 
implementation
const
 de_modalresulttext: defaultmodalresulttextty =
 ('',            //mr_none
  '',            //mr_canclose
  '',            //mr_windowclosed
  '',            //mr_windowdestroyed
  '',            //mr_exception
  '&Abbrechen',  //mr_cancel
  '&Abbrechen',  //mr_abort
  '&OK',         //mr_ok
  '&Ja',         //mr_yes
  '&Nein',       //mr_no
  'A&lle',       //mr_all
  'N&ein alle',  //mr_noall
  '&Ignorieren'  //mr_ignore
  );

 de_modalresulttextnoshortcut: defaultmodalresulttextty =
 ('',           //mr_none
  '',           //mr_canclose
  '',           //mr_windowclosed
  '',           //mr_windowdestroyed
  '',           //mr_exception
  'Abbrechen',  //mr_cancel
  'Abbrechen',  //mr_abort
  'OK',         //mr_ok
  'Ja',         //mr_yes
  'Nein',       //mr_no
  'Alle',       //mr_all
  'Nein alle',  //mr_noall
  'Ignorieren'  //mr_ignore
  );

 de_stockcaption: stockcaptionty = (
  '',                        //sc_none
  'ist ung'#252'ltig',       //sc_is_invalid
  'Format Fehler',           //sc_Format_error
  'Wert wird ben'#246'tigt', //sc_Value_is_required
  'Fehler',                  //sc_Error
  'Min',                     //sc_Min
  'Max',                     //sc_Max
  'Bereichs Fehler',         //sc_Range_error  
  '&R'#252'ckg'#228'ngig',   //sc_Undo  ///
  '&Kopieren',               //sc_Copy   // hotkeys
  '&Ausschneiden',           //sc_Cut    //
  '&Einf'#252'gen'           //sc_Paste ///
  );
    
initialization
 registerlangconsts(langnames[la_de],de_stockcaption,de_modalresulttext,
                               de_modalresulttextnoshortcut);
end.
