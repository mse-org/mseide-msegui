unit mse_dbf_str;

{ note this is Brazilian Portuguese }

interface

{$I mse_dbf_common.inc}
{$I mse_dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := 'Abertura: arquivo n?o encontrado: "%s".';
  STRING_VERSION                      := 'TDbf V%d.%d';

  STRING_RECORD_LOCKED                := 'Registro bloqueado.';
  STRING_WRITE_ERROR                  := 'Erro de escrita. (Disco cheio?)';
  STRING_WRITE_INDEX_ERROR            := 'Erro de escrita; ?ndices provavelmente corrompidos. (Disco cheio?)';
  STRING_KEY_VIOLATION                := 'Viola??o de chave. (Chave j? presente no archivo).'+#13+#10+
                                         '?ndice: %s'+#13+#10+'Registro=%d Chave=''%s''.';

  STRING_INVALID_DBF_FILE             := 'Arquivo DBF inv?lido.';
  STRING_FIELD_TOO_LONG               := 'Valor muito grande: %d caracteres (n?o pode ser maior que %d).';
  STRING_INVALID_FIELD_COUNT          := 'Quantidade de campos inv?lida: %d (deve estar entre 1 e 4095).';
  STRING_INVALID_FIELD_TYPE           := 'Tipo de campo inv?lido ''%s'' para o campo ''%s''.';
  STRING_INVALID_VCL_FIELD_TYPE       := 'N?o se pode criar o campo "%s", campo VCL tipo %x n?o suportado por DBF.';

  STRING_INDEX_BASED_ON_UNKNOWN_FIELD := '?ndice baseado em campo desconhecido "%s".';
  STRING_INDEX_BASED_ON_INVALID_FIELD := 'Campo "%s" inv?lido para criar um ?ndice.';
  STRING_INDEX_EXPRESSION_TOO_LONG    := 'Resultado de ?ndice para "%s" demasiado grande, >100 caracteres (%d).';
  STRING_INVALID_INDEX_TYPE           := 'Tipo de ?ndice inv?lido: s? pode ser string ou float.';
  STRING_CANNOT_OPEN_INDEX            := 'N?o se pode abrir o ?ndice: "%s".';
  STRING_TOO_MANY_INDEXES             := 'N?o se pode criar o ?ndice: demasiados ?ndices no archivo.';
  STRING_INDEX_NOT_EXIST              := '?ndice "%s" n?o existe.';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'Acesso Exclusivo requerido para esta opera??o.';
end.
