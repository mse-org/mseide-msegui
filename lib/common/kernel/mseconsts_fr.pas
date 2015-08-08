{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    French translation by Fabrice Michel Bouillerot.
    UTF-8 Accented french characters
    
    &#192;  A grave
    &#194;  A circumflex
    &#196;  A diaresis
    &#198;  AE Aesh Ash
    &#200;  E grave
    &#203;  E diaresis
    &#201;  E acute
    &#202;  E circumflex
    &#203;  E diaresis
    &#206;  I circumflex
    &#207;  I diaresis
    &#212;  O circumflex
    &#214;  O diaresis
    &#217;  U grave
    &#219;  U circumflex
    &#220;  U diaresis
    &#224;  a grave
    &#226;  a circumflex
    &#228;  a diaresis
    &#230;  aesc ash
    &#232;  e grave
    &#233;  e acute
    &#234;  e circumflex
    &#235;  e diaresis
    &#238;  i circumflex
    &#239;  i diaresis
    &#244;  o circumflex
    &#246;  o diaresis
    &#249;  u grave
    &#251;  u circumflex
    &#252;  u diaresis
    &#255;  y diaresis
    &#338;  OE ethel
    &#339;  oe ethel
    &#376;  Y diaresis
    
    &#8217; apostrophe
} 
unit mseconsts_fr;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseconsts;
 
implementation
uses
 msestrings,sysutils,mseformatstr;
const
 fr_modalresulttext: defaultmodalresulttextty =
 ('',             //mr_none
  '',             //mr_canclose
  '',             //mr_windowclosed
  '',             //mr_windowdestroyed
  '',             //mr_escape
  '',             //mr_f10
  '',             //mr_exception
  '&Effacer',     //mr_cancel
  '&Arr'#234'ter',//mr_abort
  '&Valider',     //mr_ok
  '&Oui',         //mr_yes
  '&Non',         //mr_no
  '&Tous',        //mr_all
  'A&ucun',       //mr_noall
  '&Ignorer',     //mr_ignore
  '&Skip',        //mr_skip
  'Skip &all'     //mr_skipall
  );

 fr_modalresulttextnoshortcut: defaultmodalresulttextty =
 ('',           //mr_none
  '',           //mr_canclose
  '',           //mr_windowclosed
  '',           //mr_windowdestroyed
  '',           //mr_escape
  '',           //mr_f10
  '',           //mr_exception
  'Effacer',    //mr_cancel
  'Arr'#234'er',//mr_abort
  'Valider',    //mr_ok
  'Oui',        //mr_yes
  'Non',        //mr_no
  'Tous',       //mr_all
  'Aucun',      //mr_noall
  'Ignorer',    //mr_ignore
  'Skip',      //mr_skip
  'Skip all'   //mr_skipall
  );

 fr_stockcaption: stockcaptionaty = (
  '',                                     //sc_none
  'est invalide',                         //sc_is_invalid
  'Erreur de format',                     //sc_Format_error
  'Valeur requise',                       //sc_Value_is_required
  'Erreur',                               //sc_Error
  'Min.',                                 //sc_Min
  'Max.',                                 //sc_Max
  'Erreur de rang',                       //sc_Range_error  

  '&D'#233'faire',                        //sc_Undo  ///         ///
  '&Refaire',                             //sc_Redo   //         //
  '&Copier',                              //sc_Copy   // hotkeys //
  'C&ouper',                              //sc_Cut    //         //
  'Co&ller',                              //sc_Paste ///         // hotkeys
  '&Ins'#233'rer ligne',                  //sc_insert_row ///    //
  '&Ajouter ligne',                       //sc_append_row  // hotkeys  //
  '&Supprimer ligne',                     //sc_delete_row ///         ///

  'R'#233'&pertoire',                     //sc_Dir               /// 
  '&Racine',                              //sc_home              //
  '&Remonter',                            //sc_Up                //
  '&Nouveau r'#233'pertoire',             //sc_New_dir           // hotkeys
  'N&om',                                 //sc_Name              //
  '&Afficher fichiers cach'#233's',       //sc_Show_hidden_files //
  '&Filtre',                              //sc_Filter            ///   
  'Sauver',                               //sc_save 
  'Ouvrir',                               //sc_open
  'Nom',                                  //sc_name1
  'Cr'#233'er un nouveau r'#233'pertoire',//sc_create_new_directory
  'Back',                //sc_back
  'Forward',             //sc_forward
  'Up',                  //sc_up
  'Fichier',                              //sc_file
  'existe, Remplacer ?',                  //sc_exists_overwrite
  'modifi'#233'. Enregistrer ?',          //sc_is_modified_save
  'AVERTISSEMENT',                        //sc_warningupper
  'ERREUR',                               //sc_errorupper
  'Exception',                            //sc_exception
  'Syst'#232'me',                         //sc_system
  'n'#8217'existe pas',                   //sc_does_not_exist
  'PASSWORD',              //sc_passwordupper
  'Enter password',        //sc_enterpassword
  'Invalid password!',     //sc_invalidpassword
  'Impossible lire r'#233'pertoire',      //sc_can_not_read_directory
  'Format graphique non support'#233'',   //sc_graphic_not_supported
  'Erreur de format graphique',           //sc_graphic_format_error
  'Bitmap MS',                            //sc_MS_Icon
  'Icone MS',                             //sc_MS_Icon
  'Image JPEG',                           //sc_JPEG_Image 
  'Image PNG',                            //sc_PNG_Image
  'Image XPM',                            //sc_XPM_Image
  'Image PNM',                            //sc_PNM_Image
  'Image TARGA',                          //sc_TARGA_image
  'Image TIFF',                           //sc_TIFF_image
  'Tous',                                 //sc_All
  'Confirmer',                            //sc_Confirmation
  'Effacer l'#8217'enregistrement ?',     //sc_Delete_record_question
  'Copier l'#8217'enregistrement ?',      //sc_Copy_record_question
  'Fermer page',                          //sc_close_page
  'Premier',                              //sc_first
  'Pr'#233'c'#233'dent',                  //sc_prior
  'Suivant',                              //sc_next
  'Dernier',                              //sc_last
  'Ajouter',                              //sc_append
  'Supprimer',                            //sc_delete
  #201'diter',                            //sc_edit
  'Poster',                               //sc_post
  'Effacer',                              //sc_cancel
  'Rafra'#238'chir',                           //sc_refresh
  #201'dition Filtre',                    //sc_filter_filter
  #201'dition Filtre Minimum',            //sc_edit_filter_min
  #201'dition Filtre Maximum',            //sc_filter_edit_max
  'Reset filter',       //sc_reset_filter
  'Filtre actif',                         //sc_filter_on
  'Rechercher',                           //sc_search
  #201'dition automatique',               //sc_autoedit
  'Copier l'#8217'enregistrement',        //sc_copy_record
  'Dialogue',                             //sc_dialog
  'Ins'#233'rer',                         //sc_insert
  'Copier',                               //sc_copy
  'Coller',                               //sc_paste
  'Ins'#233'rer ligne',                   //sc_row_insert
  'Ajouter ligne',                        //sc_row_append
  'Supprimer ligne',                      //sc_row_delete
  'D'#233'faire',                         //sc_undo
  'Refaire',                              //sc_redo
  'Couper',                               //sc_cut
  'S'#233'lectionner tout',               //sc_select_all
  'Filtre inactif',                       //sc_filter_off
  'Portrait',                             //sc_portrait print orientation
  'Paysage',                              //sc_landscape print orientation
  'Supprimer ligne ?',                    //sc_Delete_row_question
  'Lignes s'#233'lectionn'#233'es',       //sc_selected_rows
  'seulement un '#233'l'#233'ment',       //sc_Single_item_only 
  'Copier cellules',                      //sc_Copy_Cells
  'Coller cellules'                       //sc_Paste_Cells
);
    
function delete_n_selected_rows(const params: array of const): msestring;
begin
 with params[0] do begin
  if vinteger = 1 then begin
   result:= 'Effacer le fichier s'#233'lectionn'#233' ?'
  end
  else begin
   result:= 'Effacer les '+inttostrmse(vinteger)+
            ' fichiers s'#233'lectionn'#233's ?';
  end;
 end;
end;

const
 fr_textgenerator: defaultgeneratortextty = (
              {$ifdef FPC}@{$endif}delete_n_selected_rows //tg_delete_n_selected_rows
                                     );
initialization
 registerlangconsts(langnames[la_fr],@fr_stockcaption,@fr_modalresulttext,
                               @fr_modalresulttextnoshortcut,@fr_textgenerator);
end.
