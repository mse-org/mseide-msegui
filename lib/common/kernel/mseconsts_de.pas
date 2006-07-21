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
  '&Einf'#252'gen',          //sc_Paste ///
  '&Dir',               //sc_Dir               /// 
  '&Auf',               //sc_Up                 //
  'Dir &neu',           //sc_New_dir            // hotkeys
  'N&ame',              //sc_Name               //
  '&Verst.Dat.anzeigen',//sc_Show_hidden_files  //
  '&Filter',            //sc_Filter            ///   
  'Speichern',          //sc_save 
  #214'ffnen',           //sc_open
  'Grafik Format nicht unterstützt', //sc_graphic_not_supported
  'Grafik Format Fehler', //sc_graphic_format_error
  'MS Bitmap',            //sc_MS_Icon
  'MS Icon',              //sc_MS_Icon
  'JPEG Bild',            //sc_JPEG_Image 
  'PNG Bild',             //sc_PNG_Image
  'XPM Bild',             //sc_XPM_Image
  'PNM Bild',             //sc_PNM_Image
  'TARGA Bild',           //sc_TARGA_image
  'Alle'                  //sc_All
);
    
initialization
 registerlangconsts(langnames[la_de],de_stockcaption,de_modalresulttext,
                               de_modalresulttextnoshortcut);
end.
