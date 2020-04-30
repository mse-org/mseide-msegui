unit dbf_str;

interface

{$I dbf_common.inc}
{$I dbf_str.inc}


implementation

initialization

  STRING_FILE_NOT_FOUND               := 'Apertura: file non trovato: "%s"';
  STRING_VERSION                      := 'TDbf V%d.%d';

  STRING_RECORD_LOCKED                := 'Record già in uso.';

  STRING_INVALID_DBF_FILE             := 'File DBF non valido.';
  STRING_FIELD_TOO_LONG               := 'Valore troppo elevato: %d caratteri (esso non può essere più di %d).';
  STRING_INVALID_FIELD_COUNT          := 'Campo non valido (count): %d (deve essere tra 1 e 4095).';

  STRING_INDEX_BASED_ON_UNKNOWN_FIELD := 'Indice basato su un campo sconosciuto "%s"';
  STRING_INDEX_BASED_ON_INVALID_FIELD := 'Campo "%s" è di tipo non valido per un indice';
  STRING_INVALID_INDEX_TYPE           := 'Tipo indice non valido: Può essere solo string o float';
  STRING_CANNOT_OPEN_INDEX            := 'Non è possibile aprire indice : "%s"';
  STRING_TOO_MANY_INDEXES             := 'Non è possibile creare indice: Troppi indici aperti.';
  STRING_INDEX_NOT_EXIST              := 'Indice "%s" non esiste.';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'L''Accesso in esclusiva è richiesto per questa operazione.';
end.
