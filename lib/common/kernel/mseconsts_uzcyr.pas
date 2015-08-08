{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    
    Uzbek-Cyrillic translation by IvankoB.
    
}


unit mseconsts_uzcyr;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseconsts;
 
implementation
uses
 msestrings,sysutils,mseformatstr;
const
 uzcyr_modalresulttext: defaultmodalresulttextty = (
  '',                                             //mr_none => Nichego
  '',                                             //mr_canclose => Mozhno zakryt`
  '',                                             //mr_windowclosed => Okno zakryto
  '',                                             //mr_windowdestroyed => Okno udaleno
  '',                                             //mr_escape
  '',                                             //mr_f10
  #1061#1072#1090#1086 ,                                       //mr_exception => Neozhidannaya situatsiya
  '&'#1041#1077#1082#1086#1088' '#1179#1080#1083#1080#1096 ,   //mr_cancel => &Otmenit`
  '&'#1059#1079#1080#1073' '#1179#1118#1081#1080#1096 ,        //mr_abort => &Prervat`
  '&'#1058#1072#1081#1105#1088 ,                  //mr_ok => &Gotovo
  '&'#1202#1072 ,                                 //mr_yes => &Da
  '&'#1049#1118#1082 ,                            //mr_no => &Net
  #1041#1072'&'#1088#1095#1072 ,                  //mr_all => &Vse
  #1202#1077'&'#1095' '#1073#1080#1088#1080 ,     //mr_noall =>  N&ikakie
  '&'#1052#1072#1085' '#1101#1090#1080#1096,       //mr_ignore => Neva&zhno
  '&Skip',    //mr_skip
  'Skip &all' //mr_skipall
 );

 uzcyr_modalresulttextnoshortcut: defaultmodalresulttextty =
 ('',                                             //mr_none
  '',                                             //mr_canclose
  '',                                             //mr_windowclosed
  '',                                             //mr_windowdestroyed
  '',                                             //mr_escape
  '',                                             //mr_f10
  #1061#1072#1090#1086 , //mr_exception
  #1041#1077#1082#1086#1088' '#1179#1080#1083#1080#1096 , //mr_cancel => Otmenit`
  #1059#1079#1080#1073' '#1179#1118#1081#1080#1096 ,      //mr_abort => Prervat`
  #1058#1072#1081#1105#1088 ,                //mr_ok => Gotovo
  #1202#1072 ,                               //mr_yes => Da
  #1049#1118#1082 ,                          //mr_no => Net
  #1041#1072#1088#1095#1072 ,                //mr_all => Vse
  #1202#1077#1095' '#1073#1080#1088#1080 ,   //mr_noall =>  Nikakie  
  #1052#1072#1085' '#1101#1090#1080#1096,	 //mr_ignore => Nevazhno
  'Skip',    //mr_skip
  'Skip all' //mr_skipall
  );

 uzcyr_stockcaption: stockcaptionaty = (
  '',                                        //sc_none
  '- '#1085#1086#1072#1085#1080#1179 ,       //sc_is_invalid => - neverno
  #1060#1086#1088#1084#1072#1090' '#1085#1086#1090#1118#1171#1088#1080 ,   
                              //sc_Format_error => Nesootvetstvie formatu
  #1202#1077#1095' '#1085#1072#1088#1089#1072' '#1082#1077#1088#1072#1082' '#1101#1084#1072#1089 , 
                             //sc_Value_is_required => Trebuetsya znachenie
  #1053#1086#1090#1118#1171#1088#1080 ,           //sc_Error    => Oshibka
  #1052#1080#1085'.' ,                            //sc_Min      => Min.
  #1052#1072#1082#1089'.' ,                       //sc_Max      => Maks.
  #1053#1086#1090#1118#1171#1088#1080' '#1076#1080#1072#1087#1072#1079#1086#1085 , 
                             //sc_Range_error => Nesootvetstvie diapazonu

  #1054#1083#1076#1080#1085#1075#1080 ,           //sc_Undohk     => Vernut`
  '&Redo',                                        //sc_Redohk   //            //
  #1050#1118#1095#1080#1088#1080#1096 ,           //sc_Copyhk   // hotkeys=> Skopirovat`
  #1054#1083#1080#1073' '#1090#1072#1096#1083#1072#1096 ,      //sc_Cuthk      => Vyrezat`
  #1025#1079#1080#1073' '#1179#1118#1081#1080#1096 ,           //sc_Pastehk    => Vstavit`
  '&Insert Row',        //sc_insert_rowhk ///          //
  '&Append Row',        //sc_append_rowhk  // hotkeys  //
  '&Delete Row',        //sc_delete_rowhk ///         ///

  #1050#1072#1090#1072#1083#1086#1075 ,        //sc_Dirhk      => Katalog
  '&Home',              //sc_homehk               //
  #1058#1077#1087#1087#1072#1075#1072 ,                  //sc_Up       => Vverh
  #1071#1085#1075#1080' '#1082#1072#1090'.' , //sc_New_dir  => Nov. kat-g
  #1053#1086#1084#1080 ,   ///sc_Name    => Nazvanie
  #1041#1077#1088#1080#1090#1080#1083#1075#1072#1085' '#1092#1072#1081#1083#1072#1088#1085#1080' '#1179#1091#1088#1089#1072#1090#1080#1096 , //sc_Show_hidden_files => Pokaz. skryt. faily
  #1060#1080#1083#1100#1090#1088 ,             //sc_Filter   => Fil`tr
  #1057#1072#1082#1083#1072#1096 , //sc_save     =>  Sohranit`
  #1054#1095#1080#1096 ,            //sc_open     =>  Otkryt`
  'Name',                //sc_name
  'Create new directory',//sc_create_new_directory
  'Back',                //sc_back
  'Forward',             //sc_forward
  'Up',                  //sc_up
  'File',                //sc_file
  'exists, do you want to overwrite?', //sc_exists_overwrite
  'is modified. Save?',  //sc_is_modified_save
  'WARNING',                //sc_warningupper
  'ERROR',                  //sc_errorupper
  'Exception',             //sc_exception
  'System',                //sc_system
  'does not exist',         //sc_does_not_exist
  'PASSWORD',              //sc_passwordupper
  'Enter password',        //sc_enterpassword
  'Invalid password!',     //sc_invalidpassword
  'Can not read directory', //sc_can_not_read_directory
  #1043#1088#1072#1092#1080#1082' '#1092#1086#1088#1084#1072#1090' '#1090#1072#1098#1084#1080#1085#1083#1072#1085#1084#1072#1075#1072#1085 , //sc_graphic_not_supported
  #1053#1086#1090#1118#1171#1088#1080' '#1075#1088#1072#1092#1080#1082' '#1092#1086#1088#1084#1072#1090#1080 ,         //sc_graphic_format_error
  'BMP-'#1088#1072#1089#1084#1080 ,          //sc_MS_Bitmap
  'ICO-'#1088#1072#1089#1084#1080 ,            //sc_MS_Icon
  'JPEG-'#1088#1072#1089#1084#1080 ,         //sc_JPEG_Image 
  'PNG-'#1088#1072#1089#1084#1080 ,          //sc_PNG_Image
  'XPM-'#1088#1072#1089#1084#1080 ,          //sc_XPM_Image
  'PNM-'#1088#1072#1089#1084#1080 ,          //sc_PNM_Image
  'TARGA-'#1088#1072#1089#1084#1080 ,        //sc_TARGA_image
  'TIFF-'#1088#1072#1089#1084#1080 ,        //sc_TIFF_image
  #1041#1072#1088#1095#1072 ,                //sc_All
  #1058#1072#1089#1076#1080#1179#1083#1072#1096 ,       //sc_Confirmation
  #1025#1079#1091#1074#1085#1080' '#1118#1095#1080#1088#1080#1096,     //sc_Delete_record_question
  'Copy record?',       //sc_Copy_record_question
  'Close page',          //sc_close_page
  'First',              //sc_first
  'Prior',              //sc_prior
  'Next',               //sc_next
  'Last',               //sc_last
  'Append',             //sc_append
  'Delete',             //sc_delete
  'Edit',               //sc_edit
  'Post',               //sc_post
  'Cancel',             //sc_cancel
  'Refresh',            //sc_refresh
  'Edit filter',        //sc_filter_filter
  'Edit filter minimum',//sc_edit_filter_min
  'Edit filter maximum',//sc_filter_edit_max
  'Reset filter',       //sc_reset_filter
  'Filter on',          //sc_filter_on
  'Search',             //sc_search
  'Auto edit',          //sc_autoedit
  'Copy record',        //sc_copy_record
  'Dialog',             //sc_dialog
  'Insert',             //sc_insert
  'Copy',               //sc_copy
  'Paste',              //sc_paste
  'Row insert',         //sc_row_insert
  'Row append',         //sc_row_append
  'Row delete',         //sc_row_delete
  'Undo',               //sc_undo
  'Redo',               //sc_redo
  'Cut',                //sc_cut
  'Select all',         //sc_select_all
  'Filter off',         //sc_filter_off
  'Portrait',           //sc_portrait print orientation
  'Landscape',          //sc_landscape print orientation
  'Delete row?',        //sc_Delete_row_question
  'selected rows?',     //sc_selected_rows
  'Single item only',    //sc_Single_item_only 
  'Copy Cells',          //sc_Copy_Cells
  'Paste Cells'          //sc_Paste_Cells
);
    
function delete_n_selected_rows(const params: array of const): msestring;
begin
 with params[0] do begin
  if vinteger = 1 then begin
   result:= 'Delete selected row?'
  end
  else begin
   result:= 'Delete '+inttostrmse(vinteger)+' selected rows?';
  end;
 end;
end;

const
 uzcyr_textgenerator: defaultgeneratortextty = (
              {$ifdef FPC}@{$endif}delete_n_selected_rows //tg_delete_n_selected_rows
                                     );
initialization
 registerlangconsts(langnames[la_uzcyr],@uzcyr_stockcaption,@uzcyr_modalresulttext,
                               @uzcyr_modalresulttextnoshortcut,@uzcyr_textgenerator);
end.
