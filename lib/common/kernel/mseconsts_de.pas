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
  '&Ignorieren'  //mr_ignore
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
  'Ignorieren'  //mr_ignore
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

  '&R'#252'ckg'#228'ngig',   //sc_Undo  ///              ///
  '&Redo',                   //sc_Redo   //               //
  '&Kopieren',               //sc_Copy   // hotkeys       //
  '&Ausschneiden',           //sc_Cut    //               //
  '&Einf'#252'gen',          //sc_Paste ///               // hotkeys
  'Zeile e&inf'#252'gen',    //sc_insert_row ///          //
  'Zeile a&nf'#252'gen',     //sc_append_row  // hotkeys  //
  'Zeile &l'#246'schen',     //sc_delete_row ///         ///

  '&Dir',                 //sc_Dir               /// 
  '&Home',                //sc_home               //
  '&Auf',                 //sc_Up                 //
  'Dir &neu',             //sc_New_dir            // hotkeys
  'N&ame',                //sc_Name               //
  '&Verst.Dat.anzeigen',  //sc_Show_hidden_files  //
  '&Filter',              //sc_Filter            ///   
  'Speichern',            //sc_save 
  #214'ffnen',            //sc_open
  'Name',                 //sc_name1
  'Verzeichnis erstellen',//sc_create_new_directory
  'Datei',                                     //sc_file
  'existiert, wollen Sie '#252'berschreiben?', //sc_exists_overwrite
  'WARNUNG',                                   //sc_warningupper
  'FEHLER',                                    //sc_errorupper
  'existiert nicht',                           //sc_does_not_exist
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
  'Alle',                 //sc_All
  'Best'#228'tigung',     //sc_Confirmation
  'Datensatz l'#246'schen?', //sc_Delete_record
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
  'Filter ein',               //sc_filter_on
  'Suchen',                   //sc_search
  'Einfügen',                 //sc_insert
  'Filter aus',               //sc_filter_off
  'Hochformat',               //sc_portrait print orientation
  'Querformat',               //sc_landscape print orientation
  'Zeile l'#246'schen?',      //sc_Delete_row_question
  'gew'#228'hlte Zeilen',      //sc_selected_rows
  'Nur Einzeleintrag erlaubt', //sc_Single_item_only 
  'Zellen kopieren',           //sc_Copy_Cells
  'Zellen einfügen'            //sc_Paste_Cells
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
