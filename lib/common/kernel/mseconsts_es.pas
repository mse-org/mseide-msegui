{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Spanish translation by Julio Jimenez Borreguero.
    
} 
unit mseconsts_es;
{$ifdef FPC}{$mode objfpc}{$h+}{$INTERFACES CORBA}{$endif}
interface
uses
 mseconsts;
 
implementation
const
 es_modalresulttext: defaultmodalresulttextty =
 ('',            //mr_none
  '',            //mr_canclose
  '',            //mr_windowclosed
  '',            //mr_windowdestroyed
  '',            //mr_escape
  '',            //mr_f10
  '',            //mr_exception
  '&Cancelar',   //mr_cancel
  '&Abortar',    //mr_abort
  '&OK',         //mr_ok
  '&S'#237,      //mr_yes
  '&No',         //mr_no
  '&Todo',       //mr_all
  'N&o todo',    //mr_noall
  '&Ignorar'     //mr_ignore
  );

 es_modalresulttextnoshortcut: defaultmodalresulttextty =
 ('',           //mr_none
  '',           //mr_canclose
  '',           //mr_windowclosed
  '',           //mr_windowdestroyed
  '',           //mr_escape
  '',           //mr_f10
  '',           //mr_exception
  'Cancelar',   //mr_cancel
  'Abortar',    //mr_abort
  'OK',         //mr_ok
  'S'#237,      //mr_yes
  'No',         //mr_no
  'Todo',       //mr_all
  'No todo',    //mr_noall
  'Ignorar'     //mr_ignore
  );

 es_stockcaption: stockcaptionaty = (
  '',                           //sc_none
  'es inv'#225'lido',           //sc_is_invalid
  'Error de formato',           //sc_Format_error
  'Debe introducir un valor',   //sc_Value_is_required
  'Error',                      //sc_Error
  'M'#237'n.',                  //sc_Min
  'M'#225'x.',                  //sc_Max
  'Error de rango',             //sc_Range_error  
  '&Deshacer',                  //sc_Undo  ///
  '&Copiar',                    //sc_Copy   // hotkeys
  'C&ortar',                    //sc_Cut    //
  '&Pegar',                     //sc_Paste ///
  '&Directorio',                //sc_Dir               /// 
  '&Subir',                     //sc_Up                 //
  'N&uevo dir.',                //sc_New_dir            // hotkeys
  'N&ombre',                    //sc_Name               //
  '&Mostrar archivos ocultos',  //sc_Show_hidden_files  //
  '&Filtro',                    //sc_Filter            ///   
  'Guardar',                    //sc_save 
  'Abrir',                      //sc_open
  'Nombre',                     //sc_name1
  'Crear un directorio nuevo',  //sc_create_new_directory
  'Archivo',                    //sc_file
  'existe, '#191'quiere sobreescribirlo?', //sc_exists_overwrite
  'ADVERTENCIA',                //sc_warningupper
  'ERROR',                      //sc_errorupper
  'no existe',                  //sc_does_not_exist
  'No puedo leer el directorio',       //sc_can_not_read_directory
  'Formato gr'#225'fico no soportado', //sc_graphic_not_supported
  'Error de formato gr'#225'fico',     //sc_graphic_format_error
  'MS Bitmap',                         //sc_MS_Icon
  'MS Icono',                          //sc_MS_Icon
  'JPEG imagen',                       //sc_JPEG_Image 
  'PNG imagen',                        //sc_PNG_Image
  'XPM imagen',                        //sc_XPM_Image
  'PNM imagen',                        //sc_PNM_Image
  'TARGA imagen',                      //sc_TARGA_image
  'Todo',                              //sc_All
  'Confirme',                          //sc_Confirmation
  #191'Borrar el registro?',           //sc_Delete_record
  'Cerrar p'#225'gina',                 //sc_close_page
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
  'Insert',             //sc_insert
  'Filter off'         //sc_filter_off
);
    
initialization
 registerlangconsts(langnames[la_es],es_stockcaption,es_modalresulttext,
                               es_modalresulttextnoshortcut);
end.
