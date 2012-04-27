{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    
    Russian translation by IvankoB.
    
}

unit mseconsts_ru;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseconsts,msestrings,sysutils;
 
implementation
const
 ru_modalresulttext: defaultmodalresulttextty = (
  '',                                             //mr_none => Nichego
  '',                                             //mr_canclose => 
                                                  //Mozhno zakryt`
  '',                                             //mr_windowclosed => 
                                                  //Okno zakryto
  '',                                             //mr_windowdestroyed => 
                                                  //Okno udaleno
  '',                                             //mr_escape
  '',                                             //mr_f10
  '',                                             //mr_exception => 
                                                  //Neozhidannaya situatsiya
  '&'#1054#1090#1084#1077#1085#1080#1090#1100 ,   //mr_cancel => &Otmenit`
  '&'#1055#1088#1077#1088#1074#1072#1090#1100 ,   //mr_abort => &Prervat`
  '&'#1043#1086#1090#1086#1074#1086 ,             //mr_ok => &Gotovo
  '&'#1044#1072 ,                                 //mr_yes => &Da
  '&'#1053#1077#1090 ,                            //mr_no => &Net
  '&'#1042#1089#1077 ,                            //mr_all => &Vse
  #1053'&'#1080#1082#1072#1082#1080#1077 ,        //mr_noall =>  N&ikakie
  #1053#1077#1074#1072'&'#1078#1085#1086          //mr_ignore => Neva&zhno
 );

 ru_modalresulttextnoshortcut: defaultmodalresulttextty =
 ('',                                             //mr_none
  '',                                             //mr_canclose
  '',                                             //mr_windowclosed
  '',                                             //mr_windowdestroyed
  '',                                             //mr_escape
  '',                                             //mr_f10
  #1053#1077#1086#1078#1080#1076#1072#1085#1085#1072#1103' ' + 
       #1089#1080#1090#1091#1072#1094#1080#1103 , //mr_exception
  #1054#1090#1084#1077#1085#1080#1090#1100 ,      //mr_cancel => Otmenit`
  #1055#1088#1077#1088#1074#1072#1090#1100 ,      //mr_abort => Prervat`
  #1043#1086#1090#1086#1074#1086 ,                //mr_ok => Gotovo
  #1044#1072 ,                                    //mr_yes => Da
  #1053#1077#1090 ,                               //mr_no => Net
  #1042#1089#1077 ,                               //mr_all => Vse
  #1053#1080#1082#1072#1082#1080#1077 ,           //mr_noall =>  Nikakie  
  #1053#1077#1074#1072#1078#1085#1086	          //mr_ignore => Nevazhno
  );

 ru_stockcaption: stockcaptionaty = (
  '',                                             //sc_none
  '- '#1085#1077#1074#1077#1088#1085#1086 ,       //sc_is_invalid => - neverno
  #1053#1077#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1080#1077' '+
  #1092#1086#1088#1084#1072#1090#1091 ,           //sc_Format_error => 
                                                  //Nesootvetstvie formatu
  #1058#1088#1077#1073#1091#1077#1090#1089#1103' '+
  #1079#1085#1072#1095#1077#1085#1080#1077 ,      //sc_Value_is_required => 
                                                  //Trebuetsya znachenie
  #1054#1096#1080#1073#1082#1072 ,                //sc_Error    => Oshibka
  #1052#1080#1085'.' ,                            //sc_Min      => Min.
  #1052#1072#1082#1089'.' ,                       //sc_Max      => Maks.
  #1053#1077#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1080#1077' '+
  #1076#1080#1072#1087#1072#1079#1086#1085#1091 ,
                                                  //sc_Range_error => 
                                                  //Nesootvetstvie diapazonu

                                       // hotkeys///
  #1042#1077#1088#1085#1091#1090#1100 ,           //sc_Undohk     => Vernut`
  '&Redo',                             //sc_Redohk  //               //
  #1057#1082#1086#1087#1080#1088#1086#1074#1072#1090#1100 , 
                                                  //sc_Copyhk    => Skopirovat`
  #1042#1099#1088#1077#1079#1072#1090#1100 ,      //sc_Cuthk      => Vyrezat`
  #1042#1089#1090#1072#1074#1080#1090#1100 ,     ///sc_Pastehk    => Vstavit`
  '&Insert Row',        //sc_insert_rowhk ///          //
  '&Append Row',        //sc_append_rowhk  // hotkeys  //
  '&Delete Row',        //sc_delete_rowhk ///         ///
  
                                       // hotkeys///
  '&'#1050#1072#1090#1072#1083#1086#1075 ,        //sc_Dirhk      => Katalog
  '&Home',                //sc_homehk               //
  '&'#1042#1074#1077#1088#1093 ,                  //sc_Uphk       => Vverh
  '&'#1053#1086#1074'. '#1082#1072#1090'-'#1075 , //sc_New_dirhk  => Nov. kat-g
  #1053#1072'&'#1079#1074#1072#1085#1080#1077 ,   //sc_Namehk     => Nazvanie
  
  #1055#1086#1082#1072#1079'. &'#1089#1082#1088#1099#1090'. '+
           #1092#1072#1081#1083#1099 ,            //sc_Show_hidden_fileshk =>
                                                  //Pokaz. skryt. faily
  '&'#1060#1080#1083#1100#1090#1088 ,            ///sc_Filterhk   => Fil`tr
  
  #1057#1086#1093#1088#1072#1085#1080#1090#1100 , //sc_save     =>  Sohranit`
  #1054#1090#1082#1088#1099#1090#1100 ,           //sc_open     =>  Otkryt`
  #1048#1084#1103,                                //sc_name
  #1057#1086#1079#1076#1072#1090#1100' '#1085#1086#1074#1099#1081' '+
      #1082#1072#1090#1072#1083#1086#1075 ,       //sc_create_new_directory
  #1060#1072#1081#1083 ,                          //sc_file
  #1091#1078#1077' '#1077#1089#1090#1100', '+
  #1087#1077#1088#1077#1079#1072#1087#1080#1089#1072#1090#1100'?' , 
                                                  //sc_exists_overwrite
  #1055#1056#1045#1044#1059#1055#1056#1045#1046#1044#1045#1053#1048#1045 , 
                                                  //sc_warningupper
  #1054#1064#1048#1041#1050#1040 ,                //sc_errorupper
  #1085#1077' '#1089#1091#1097#1077#1089#1090#1074#1091#1077#1090 , 
                                                 //sc_does_not_exist
  #1053#1077' '#1091#1076#1072#1077#1090#1089#1103' '+
  #1087#1088#1086#1095#1077#1089#1090#1100' '+
  #1089#1086#1076#1077#1088#1078#1080#1084#1086#1077+
  ' '#1082#1072#1090#1072#1083#1086#1075#1072 ,  //sc_can_not_read_directory
  #1043#1088#1072#1092#1080#1095#1077#1089#1082#1080#1081' '+
  #1092#1086#1088#1084#1072#1090' '#1085#1077' '+
  #1087#1086#1076#1076#1077#1088#1078#1080#1074#1072#1077#1090#1089#1103 , 
                                                //sc_graphic_not_supported
  #1043#1088#1072#1092#1080#1095#1077#1089#1082#1080#1077' '+
  #1076#1072#1085#1085#1099#1077' '#1085#1077' '+
  #1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1091#1102#1090' '+
  #1092#1086#1088#1084#1072#1090#1091 ,         //sc_graphic_format_error
  'BMP-'#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077 , 
                                                //sc_MS_Bitmap
  'ICO-'#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077 , 
                                                //sc_MS_Icon
  'JPEG-'#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077 ,
                                                //sc_JPEG_Image 
  'PNG-'#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077 , 
                                                //sc_PNG_Image
  'XPM-'#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077 , 
                                                //sc_XPM_Image
  'PNM-'#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077 , 
                                                //sc_PNM_Image
  'TARGA-'#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077 ,
                                                //sc_TARGA_image
  'TIFF-'#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077 ,
                                                //sc_TIFF_image
  #1042#1089#1077 ,                             //sc_All
  #1055#1086#1076#1090#1074#1077#1088#1078#1076#1077#1085#1080#1077 ,
                                                //sc_Confirmation
  #1059#1076#1072#1083#1080#1090#1100' '#1079#1072#1087#1080#1089#1100'?',
                                                //sc_Delete_record_question
  'Close page',         //sc_close_page
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
  'Filter on',          //sc_filter_on
  'Search',             //sc_search
  'Auto edit',          //sc_autoedit
  'Copy record',        //sc_copy_record
  'Copy record?',       //sc_Copy_record_question
  'Dialog',             //sc_dialog
  'Insert',             //sc_insert
  'Copy',               //sc_copy
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
   result:= 'Delete '+inttostr(vinteger)+' selected rows?';
  end;
 end;
end;

const
 ru_textgenerator: defaultgeneratortextty = (
              {$ifdef FPC}@{$endif}delete_n_selected_rows //tg_delete_n_selected_rows
                                     );
initialization
 registerlangconsts(langnames[la_ru],@ru_stockcaption,@ru_modalresulttext,
                               @ru_modalresulttextnoshortcut,@ru_textgenerator);
end.
