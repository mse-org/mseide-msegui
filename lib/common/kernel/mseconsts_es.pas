{ MSEgui Copyright (c) 1999-2006 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Spanish translation by Julio Jimenez Borreguero.

}
unit mseconsts_es;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 mseconsts;

implementation
uses
 msetypes{msestrings},sysutils,mseformatstr;
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
  '&S'#0237,     //mr_yes
  '&S'#0237' &todo',    //mr_yesall
  '&No',         //mr_no
  '&Todo',       //mr_all
  'N&o todo',    //mr_noall
  '&Ignorar',    //mr_ignore
  'O&mitir',     //mr_skip
  'Omitir &todo', //mr_skipall
  'Co&ntinuar'  //mr_continue
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
  'S'#0237,      //mr_yes
  'Yes all',    //mr_yesall
  'No',         //mr_no
  'Todo',       //mr_all
  'No todo',    //mr_noall
  'Ignorar',    //mr_ignore
  'Omitir',     //mr_skip
  'Omitir todo', //mr_skipall
  'Continuar'  //mr_continue
  );

 es_stockcaption: stockcaptionaty = (
  '',                           //sc_none
  'es inv'#0225'lido',           //sc_is_invalid
  'Error de formato',           //sc_Format_error
  'Debe introducir un valor',   //sc_Value_is_required
  'Error',                      //sc_Error
  'M'#0237'n.',                  //sc_Min
  'M'#0225'x.',                  //sc_Max
  'Error de rango',             //sc_Range_error

  '&Deshacer',                  //sc_Undohk        ///         ///
  '&Rehacer',                   //sc_Redohk         //          //
  '&Copiar',                    //sc_Copyhk         // hotkeys  //
  'C&ortar',                    //sc_Cuthk          //          //
  '&Pegar',                     //sc_Pastehk        //          // hotkeys
  '&Select all',                //sc_Select_allhk  ///          //
  '&Insertar fila',             //sc_insert_rowhk  ///          //
  '&A'#0241'adir fila',          //sc_append_rowhk  // hotkeys  //
  '&Borrar fila',               //sc_delete_rowhk  ///         ///

  '&Carpetas',                    //sc_Dir               ///
  '&Principal',                   //sc_home               //
  '&Subir un nivel',              //sc_Up                 //
  'Crear carpeta',                //sc_New_dir            // hotkeys
  'N&ombre',                      //sc_Name               //
  '&Mostrar archivos ocultos',    //sc_Show_hidden_files  //
  '&Filtro',                      //sc_Filter            ///
  'Guardar',                      //sc_save
  'Abrir',                        //sc_open
  'Nombre',                       //sc_name1
  'Crear una carpeta nueva',               //sc_create_new_directory
  'Atr'#0225's',                   //sc_back
  'Adelante',                     //sc_forward
  'Arriba',                       //sc_up
  'Archivo',                               //sc_file
  'existe, '#0191'quiere sobreescribirlo?', //sc_exists_overwrite
  'ha sido modificado. '#0191'Guardar?',    //sc_is_modified_save
  'ADVERTENCIA',                       //sc_warningupper
  'ERROR',                             //sc_errorupper
  'Excepci'#0243'n',                    //sc_exception
  'Sistema',                           //sc_system
  'no existe',                         //sc_does_not_exist
  'CONTRASE'#0209'A',                   //sc_passwordupper
  'Introduzca contrase'#0241'a',        //sc_enterpassword
  #0161'contrase'#0241'a incorrecta!',   //sc_invalidpassword
  'No puedo leer la carpeta',          //sc_can_not_read_directory
  'Formato gr'#0225'fico no soportado', //sc_graphic_not_supported
  'Error de formato gr'#0225'fico',     //sc_graphic_format_error
  'Bitmap MS',                         //sc_MS_Icon
  'Icono MS',                          //sc_MS_Icon
  'Imagen JPEG',                       //sc_JPEG_Image
  'Imagen PNG',                        //sc_PNG_Image
  'Imagen XPM',                        //sc_XPM_Image
  'Imagen PNM',                        //sc_PNM_Image
  'Imagen TARGA',                      //sc_TARGA_image
  'Imagen TIFF',                       //sc_TIFF_image
  'Todo',                              //sc_All
  'Confirme',                          //sc_Confirmation
  #0191'Borrar el registro?',           //sc_Delete_record_question
  #0191'Copiar el registro?',           //sc_Copy_record_question
  'Cerrar p'#0225'gina',                //sc_close_page
  'Primero',                           //sc_first
  'Anterior',                          //sc_prior
  'Siguiente',                         //sc_next
  #0218'ltimo',                         //sc_last
  'A'#0241'adir',                       //sc_append
  'Borrar',                            //sc_delete
  'Editar',                            //sc_edit
  'Guardar',                           //sc_post
  'Cancelar',                          //sc_cancel
  'Refrescar',                         //sc_refresh
  'Filtro edici'#0243'n',               //sc_filter_filter
  'Filtro edici'#0243'n m'#0237'nimo',   //sc_edit_filter_min
  'Filtro edici'#0243'n m'#0225'ximo',   //sc_filter_edit_max
  'Reiniciar filtro',                  //sc_reset_filter
  'Filtro activo',                     //sc_filter_on
  'Buscar',                            //sc_search
  'Edici'#0243'n autom'#0225'tica',      //sc_autoedit
  'Copiar registro',                   //sc_copy_record
  'Di'#0225'logo',                      //sc_dialog
  'Insertar',                          //sc_insert
  'Copiar',                            //sc_copy
  'Pegar',                             //sc_paste
  'Insertar fila',                     //sc_row_insert
  'A'#0241'adir fila',                  //sc_row_append
  'Borrar fila',                       //sc_row_delete
  'Deshacer',                          //sc_undo
  'Rehacer',                           //sc_redo
  'Cortar',                            //sc_cut
  'Seleccionar todo',                  //sc_select_all
  'Filtro apagado',                    //sc_filter_off
  'Vertical',                          //sc_portrait print orientation
  'Apaisado',                          //sc_landscape print orientation
  #0191'Borrar fila?',                  //sc_Delete_row_question
  'filas seleccionadas?',              //sc_selected_rows
  'un elemento solamente',             //sc_Single_item_only
  'Copiar Celdas',                     //sc_Copy_Cells
  'Pegar Celdas',                      //sc_Paste_Cells
  'Cerrar',               //sc_close
  'Maximizar',            //sc_maximize
  'Restaurar',            //sc_normalize
  'Minimizar',            //sc_minimize
  'Ajustar tama'#0241'o',  //sc_fix_size
  'Flotar',               //sc_float
  'Permanecer en el primer plano',     //sc_stay_on_top
  'Permanecer en el fondo',            //sc_stay_in_background
  'Bloquear hijas',                    //sc_lock_children
  'Sin bloquear',                      //sc_no_lock
  'Entrada',                           //sc_input
  'Bot'#0243'n',                       //sc_button
  'Encendido',                         //sc_on
  'Apagado',                           //sc_off
  'Borde izquierdo',         //sc_leftborder
  'Borde superior',          //sc_topborder
  'Borde derecho',           //sc_rightborder
  'Borde inferior',          //sc_bottomborder
  'Principio del texto',     //sc_beginoftext
  'Fin del texto',           //sc_endoftext
  'Modo entrada',            //sc_inputmode
  'Sobrescribir',            //sc_overwrite
  'Borrado',                 //sc_deleted
  'Copiado',                 //sc_copied
  'Insertado',               //sc_inserted
  'Pegado',                  //sc_pasted
  'Retirado',                //sc_withdrawn
  'Ventana activada',        //sc_windowactivated
  'Men'#0250,                //sc_menu
  'Principio del archivo',       //sc_bof
  'Fin del archivo',             //sc_eof
  'Salida de voz',               //sc_voiceoutput
  'Hablar de nuevo',             //sc_speakagain
  'Primera columna',             //sc_firstcol
  'Primera fila',                //sc_firstrow
  #0218'ltima columna',          //sc_lastcol
  #0218'ltima fila',             //sc_lastrow
  'Selecci'#0243'n',             //sc_selection
  'Ruta de hablar',              //sc_speakpath
  'Deshabilitar bot'#0243'n'     //sc_disabledbutton
);

function delete_n_selected_rows(const params: array of const): msestring;
begin
 with params[0] do begin
  if vinteger = 1 then begin
   result:= #0191'Borrar la fila seleccionada?'
  end
  else begin
   result:= #0191'Borrar '+inttostrmse(vinteger)+' filas seleccionadas?';
  end;
 end;
end;

const
 es_textgenerator: defaultgeneratortextty = (
              {$ifdef FPC}@{$endif}delete_n_selected_rows //tg_delete_n_selected_rows
                                     );
initialization
 registerlangconsts(langnames[la_es],@es_stockcaption,@es_modalresulttext,
                               @es_modalresulttextnoshortcut,@es_textgenerator);
end.
