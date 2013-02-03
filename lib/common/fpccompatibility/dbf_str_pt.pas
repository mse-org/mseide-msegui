unit dbf_str;

{ note this is Brazilian Portuguese }

interface

{$I dbf_common.inc}
{$I dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := 'Abertura: arquivo não encontrado: "%s".';
  STRING_VERSION                      := 'TDbf V%d.%d';

  STRING_RECORD_LOCKED                := 'Registro bloqueado.';
  STRING_WRITE_ERROR                  := 'Erro de escrita. (Disco cheio?)';
  STRING_WRITE_INDEX_ERROR            := 'Erro de escrita; índices provavelmente corrompidos. (Disco cheio?)';
  STRING_KEY_VIOLATION                := 'Violação de chave. (Chave já presente no archivo).'+#13+#10+
                                         'Índice: %s'+#13+#10+'Registro=%d Chave=''%s''.';

  STRING_INVALID_DBF_FILE             := 'Arquivo DBF inválido.';
  STRING_FIELD_TOO_LONG               := 'Valor muito grande: %d caracteres (não pode ser maior que %d).';
  STRING_INVALID_FIELD_COUNT          := 'Quantidade de campos inválida: %d (deve estar entre 1 e 4095).';
  STRING_INVALID_FIELD_TYPE           := 'Tipo de campo inválido ''%s'' para o campo ''%s''.';
  STRING_INVALID_VCL_FIELD_TYPE       := 'Não se pode criar o campo "%s", campo VCL tipo %x não suportado por DBF.';

  STRING_INDEX_BASED_ON_UNKNOWN_FIELD := 'Índice baseado em campo desconhecido "%s".';
  STRING_INDEX_BASED_ON_INVALID_FIELD := 'Campo "%s" inválido para criar um índice.';
  STRING_INDEX_EXPRESSION_TOO_LONG    := 'Resultado de índice para "%s" demasiado grande, >100 caracteres (%d).';
  STRING_INVALID_INDEX_TYPE           := 'Tipo de índice inválido: só pode ser string ou float.';
  STRING_CANNOT_OPEN_INDEX            := 'Não se pode abrir o índice: "%s".';
  STRING_TOO_MANY_INDEXES             := 'Não se pode criar o índice: demasiados índices no archivo.';
  STRING_INDEX_NOT_EXIST              := 'Ìndice "%s" não existe.';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'Acesso Exclusivo requerido para esta operação.';
end.
