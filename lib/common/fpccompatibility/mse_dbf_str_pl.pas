unit dbf_str;

interface

{$I dbf_common.inc}
{$I dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := 'Open: brak pliku: "%s"';
  STRING_VERSION                      := 'TDbf V%d.%d';

  STRING_RECORD_LOCKED                := 'Rekord zablokowany.';
  STRING_WRITE_ERROR                  := 'Niezapisano(Brak miejsca na dysku?)';
  STRING_KEY_VIOLATION                := 'Konflikt klucza. (Klucz obecny w pliku).'+#13+#10+
                                         'Indeks: %s'+#13+#10+'Rekord=%d Klucz=''%s''';

  STRING_INVALID_DBF_FILE             := 'Uszkodzony plik bazy.';
  STRING_FIELD_TOO_LONG               := 'Dana za d³uga : %d znaków (dopuszczalne do %d).';
  STRING_INVALID_FIELD_COUNT          := 'Z³a liczba pól: %d (dozwolone 1 do 4095).';
  STRING_INVALID_FIELD_TYPE           := 'B³êdny typ pola ''%c'' dla pola ''%s''.';
  STRING_INVALID_VCL_FIELD_TYPE       := 'Nie mogê tworzyæ pola "%s", typ pola VCL %x nie wspierany przez DBF.';


  STRING_INDEX_BASED_ON_UNKNOWN_FIELD := 'Kluczowe pole indeksu "%s" nie istnieje';
  STRING_INDEX_BASED_ON_INVALID_FIELD := 'Typ pola "%s" niedozwolony dla indeksów';
  STRING_INDEX_EXPRESSION_TOO_LONG    := 'Zbyt d³ugi wynik "%s", >100 znaków (%d).';
  STRING_INVALID_INDEX_TYPE           := 'Z³y typ indeksu: tylko string lub float';
  STRING_CANNOT_OPEN_INDEX            := 'Nie mogê otworzyæ indeksu: "%s"';
  STRING_TOO_MANY_INDEXES             := 'Nie mogê stworzyæ indeksu: za du¿o w pliku.';
  STRING_INDEX_NOT_EXIST              := 'Brak indeksu "%s".';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'Operacja wymaga dostêpu w trybie Exclusive.';
end.

