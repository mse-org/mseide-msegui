unit mse_dbf_str;

interface

{$I mse_dbf_common.inc}
{$I mse_dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := 'Apertura: archivo no encontrado: "%s".';
  STRING_VERSION                      := 'TDbf V%d.%d';

  STRING_RECORD_LOCKED                := 'Registro bloqueado.';
  STRING_WRITE_ERROR                  := 'Error de escritura. (Disco lleno?)';
  STRING_WRITE_INDEX_ERROR            := 'Error de escritura; ?ndices probablemente corruptos. (Disco lleno?)';
  STRING_KEY_VIOLATION                := 'Violaci?n de clave. (Clave ya presente en archivo).'+#13+#10+
                                         'Indice: %s'+#13+#10+'Registro=%d Clave=''%s''.';

  STRING_INVALID_DBF_FILE             := 'Archivo DBF inv?lido.';
  STRING_FIELD_TOO_LONG               := 'Valor demasiado largo: %d caracteres (no puede ser mayor de %d).';
  STRING_INVALID_FIELD_COUNT          := 'Cantidad de campos inv?lida: %d (debe estar entre 1 y 4095).';
  STRING_INVALID_FIELD_TYPE           := 'Tipo de campo inv?lido ''%s'' para el campo ''%s''.';
  STRING_INVALID_VCL_FIELD_TYPE       := 'No se puede crear el campo "%s", campo VCL tipo %x no soportado por DBF.';

  STRING_INDEX_BASED_ON_UNKNOWN_FIELD := 'Indice basado en campo desconocido "%s".';
  STRING_INDEX_BASED_ON_INVALID_FIELD := 'Campo "%s" inv?lido para crear un ?ndice.';
  STRING_INDEX_EXPRESSION_TOO_LONG    := 'Resultado de ?ndice para "%s" demasiado largo, >100 caracteres (%d).';
  STRING_INVALID_INDEX_TYPE           := 'Tipo de ?ndice invalido: solo puede ser string o float.';
  STRING_CANNOT_OPEN_INDEX            := 'No se puede abrir el ?ndice: "%s".';
  STRING_TOO_MANY_INDEXES             := 'No se puede crear el ?ndice: demasiados indices en el archivo.';
  STRING_INDEX_NOT_EXIST              := 'Indice "%s" no existe.';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'Acceso Exclusivo requirido para esta operaci?n.';
end.

