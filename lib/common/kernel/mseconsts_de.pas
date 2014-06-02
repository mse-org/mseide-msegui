{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit mseconsts_de;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseconsts;
 
implementation
uses
 msestrings,sysutils;
const
 de_modalresulttext: defaultmodalresulttextty =
 ('',            //mr_none
  '',            //mr_canclose
  '',            //mr_windowclosed
  '',            //mr_windowdestroyed
  '',            //mr_escape
  '',            //mr_f10
  '',            //mr_exception
  '&Abbrechen',  //mr_cancel
  '&Abbrechen',  //mr_abort
  '&OK',         //mr_ok
  '&Ja',         //mr_yes
  '&Nein',       //mr_no
  'A&lle',       //mr_all
  'N&ein alle',  //mr_noall
  '&Ignorieren',  //mr_ignore
  #220'bers&pringen',    //mr_skip
  '&Alles '#252'berspringen' //mr_skipall
  );

 de_modalresulttextnoshortcut: defaultmodalresulttextty =
 ('',           //mr_none
  '',           //mr_canclose
  '',           //mr_windowclosed
  '',           //mr_windowdestroyed
  '',           //mr_escape
  '',           //mr_f10
  '',           //mr_exception
  'Abbrechen',  //mr_cancel
  'Abbrechen',  //mr_abort
  'OK',         //mr_ok
  'Ja',         //mr_yes
  'Nein',       //mr_no
  'Alle',       //mr_all
  'Nein alle',  //mr_noall
  'Ignorieren',  //mr_ignore
  #220'berspringen',    //mr_skip
  'Alles '#252'berspringen' //mr_skipall
  );

 de_stockcaption: stockcaptionaty = (
  '',                        //sc_none
  'ist ung'#252'ltig',       //sc_is_invalid
  'Format Fehler',           //sc_Format_error
  'Wert wird ben'#246'tigt', //sc_Value_is_required
  'Fehler',                  //sc_Error
  'Min',                     //sc_Min
  'Max',                     //sc_Max
  'Bereichs Fehler',         //sc_Range_error  

  '&R'#252'ckg'#228'ngig',   //sc_Undohk  ///              ///
  '&Redo',                   //sc_Redohk   //               //
  '&Kopieren',               //sc_Copyhk   // hotkeys       //
  '&Ausschneiden',           //sc_Cuthk    //               //
  '&Einf'#252'gen',          //sc_Pastehk ///               // hotkeys
  'Zeile e&inf'#252'gen',    //sc_insert_rowhk ///          //
  'Zeile a&nf'#252'gen',     //sc_append_rowhk  // hotkeys  //
  'Zeile &l'#246'schen',     //sc_delete_rowhk ///         ///

  '&Dir',                 //sc_Dirhk               /// 
  '&Home',                //sc_homehk               //
  '&Auf',                 //sc_Uphk                 //
  'Dir &neu',             //sc_New_dirhk            // hotkeys
  'N&ame',                //sc_Namehk               //
  '&Verst.Dat.anzeigen',  //sc_Show_hidden_fileshk  //
  '&Filter',              //sc_Filterhk            ///   
  'Speichern',            //sc_save 
  #214'ffnen',            //sc_open
  'Name',                 //sc_name
  'Verzeichnis erstellen',//sc_create_new_directory
  'Datei',                                     //sc_file
  'existiert, wollen Sie '#252'berschreiben?', //sc_exists_overwrite
  'wurde geändert, wollen Sie speichern?',     //sc_is_modified_save
  'WARNUNG',                                   //sc_warningupper
  'FEHLER',                                    //sc_errorupper
  'Exception',                                 //sc_exception
  'System',                                    //sc_system
  'existiert nicht',                           //sc_does_not_exist
  'PASSWORT',                 //sc_passwordupper
  'Ppassworteingabe',         //sc_enterpassword
  'Ung'#252'ltiges Passwort!',//sc_invalidpassword
  'Verzeichnis kann nicht gelesen werden',     //sc_can_not_read_directory
  'Grafik Format nicht unterst'#252'tzt', //sc_graphic_not_supported
  'Grafik Format Fehler', //sc_graphic_format_error
  'MS Bitmap',            //sc_MS_Icon
  'MS Icon',              //sc_MS_Icon
  'JPEG Bild',            //sc_JPEG_Image 
  'PNG Bild',             //sc_PNG_Image
  'XPM Bild',             //sc_XPM_Image
  'PNM Bild',             //sc_PNM_Image
  'TARGA Bild',           //sc_TARGA_image
  'TIFF Bild',            //sc_TIFF_image
  'Alle',                 //sc_All
  'Best'#228'tigung',     //sc_Confirmation
  'Datensatz l'#246'schen?', //sc_Delete_record_question
  'Datensatz kopieren?',     //sc_Copy_record_question
  'Seite schliessen',        //sc_close_page
  'Erster',                  //sc_first
  'Vorheriger',              //sc_prior
  'N'#228'chster',           //sc_next
  'Letzter',                 //sc_last
  'Anf'#252'gen',            //sc_append
  'L'#246'schen',            //sc_delete
  'Bearbeiten',              //sc_edit
  'Eintragen',               //sc_post
  'Verwerfen',               //sc_cancel
  'Auffrischen',             //sc_refresh
  'Filter bearbeiten',        //sc_filter_filter
  'Filter Minimum bearbeiten',//sc_edit_filter_min
  'Filter Maximum bearbeiten',//sc_filter_edit_max
  'Filter r'#252'ckstellen',  //sc_reset_filter
  'Filter ein',               //sc_filter_on
  'Suchen',                   //sc_search
  'Automatisch bearbeiten',   //sc_auto_edit
  'Datensatz kopieren',       //sc_copy_record
  'Dialog',                   //sc_dialog
  'Einf'#252'gen',            //sc_insert
  'Kopieren',                 //sc_copy
  'Einf'#252'gen',            //sc_paste
  'Zeile einf'#252'gen',      //sc_row_insert
  'Zeile anf'#252'gen',       //sc_row_append
  'Zeile l'#246'schen',       //sc_row_delete
  'R'#252'ckg'#228'ngig',     //sc_undo
  'Wiederherstellen',         //sc_redo
  'Ausschneiden',             //sc_cut
  'Alles markieren',          //sc_select_all
  'Filter aus',               //sc_filter_off
  'Hochformat',               //sc_portrait print orientation
  'Querformat',               //sc_landscape print orientation
  'Zeile l'#246'schen?',      //sc_Delete_row_question
  'gew'#228'hlte Zeilen',      //sc_selected_rows
  'Nur Einzeleintrag erlaubt', //sc_Single_item_only 
  'Zellen kopieren',           //sc_Copy_Cells
  'Zellen einf'#252'gen'       //sc_Paste_Cells
);
    
function delete_n_selected_rows(const params: array of const): msestring;
begin
 with params[0] do begin
  if vinteger = 1 then begin
   result:= 'Gew'#228'hlte Zeile l'#246'schen?';
  end
  else begin
   result:= inttostr(vinteger)+
     widestring(' gew'#228'hlte Zeilen l'#246'schen?');
  end;
 end;    
end;

const
 de_textgenerator: defaultgeneratortextty = (
              {$ifdef FPC}@{$endif}delete_n_selected_rows //tg_delete_n_selected_rows
                                     );
initialization
 registerlangconsts(langnames[la_de],@de_stockcaption,@de_modalresulttext,
                               @de_modalresulttextnoshortcut,@de_textgenerator);
end.
