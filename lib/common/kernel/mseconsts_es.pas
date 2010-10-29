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
 msestrings,sysutils;
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

  '&Deshacer',                  //sc_Undo  ///              ///
  '&Redo',                      //sc_Redo   //               //
  '&Copiar',                    //sc_Copy   // hotkeys       //
  'C&ortar',                    //sc_Cut    //               //
  '&Pegar',                     //sc_Paste ///               // hotkeys
  '&Insertar fila',             //sc_insert_row ///          //
  '&A'#241'adir fila',          //sc_append_row  // hotkeys  //
  '&Borrar fila',               //sc_delete_row ///         ///

  '&Carpetas',                //sc_Dir               /// 
  '&Principal',                      //sc_home               //
  '&Subir un nivel',                     //sc_Up                 //
  'Crear carpeta',                //sc_New_dir            // hotkeys
  'N&ombre',                    //sc_Name               //
  '&Mostrar archivos ocultos',  //sc_Show_hidden_files  //
  '&Filtro',                    //sc_Filter            ///   
  'Guardar',                    //sc_save 
  'Abrir',                      //sc_open
  'Nombre',                     //sc_name1
  'Crear una carpeta nueva',  //sc_create_new_directory
  'Archivo',                    //sc_file
  'existe, '#191'quiere sobreescribirlo?', //sc_exists_overwrite
  'ADVERTENCIA',                //sc_warningupper
  'ERROR',                      //sc_errorupper
  'no existe',                  //sc_does_not_exist
  'No puedo leer la carpeta',       //sc_can_not_read_directory
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
  'Cerrar p'#225'gina',                //sc_close_page
  'Primero',                           //sc_first
  'Anterior',                          //sc_prior
  'Siguiente',                         //sc_next
  #218'ltimo',                         //sc_last
  'A'#241'adir',                       //sc_append
  'Borrar',                            //sc_delete
  'Editar',                            //sc_edit
  'Guardar',                           //sc_post
  'Cancelar',                          //sc_cancel
  'Refrescar',                         //sc_refresh
  'Filtro edici'#243'n',               //sc_filter_filter
  'Filtro edici'#243'n m'#237'nimo',   //sc_edit_filter_min
  'Filtro edici'#243'n m'#225'ximo',   //sc_filter_edit_max
  'Filtro activo',                     //sc_filter_on
  'Buscar',                            //sc_search
  'Insertar',                          //sc_insert
  'Filtro apagado',                    //sc_filter_off
  'Vertical',                          //sc_portrait print orientation
  'Apaisado',                          //sc_landscape print orientation
  #191'Borrar fila?',                  //sc_Delete_row_question
  'filas seleccionadas?',              //sc_selected_rows
  'un elemento solamente',             //sc_Single_item_only 
  'Copiar Celdas',                     //sc_Copy_Cells
  'Pegar Celdas'                       //sc_Paste_Cells
);
    
function delete_n_selected_rows(const params: array of const): msestring;
begin
 with params[0] do begin
  if vinteger = 1 then begin
   result:= #191'Borrar la fila seleccionada?'
  end
  else begin
   result:= #191'Borrar '+inttostr(vinteger)+' filas seleccionadas?';
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
