unit dbf_str;

interface

{$I dbf_common.inc}
{$I dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := 'Openen: bestand niet gevonden: "%s"';
  STRING_VERSION                      := 'TDbf V%d.%d';

  STRING_RECORD_LOCKED                := 'Record in gebruik.';
  STRING_WRITE_ERROR                  := 'Error tijdens schrijven. (Disk vol?)';
  STRING_KEY_VIOLATION                := 'Indexsleutel bestond al in bestand.'+#13+#10+
                                         'Index: %s'+#13+#10+'Record=%d Sleutel=''%s''';

  STRING_INVALID_DBF_FILE             := 'Ongeldig DBF bestand.';
  STRING_FIELD_TOO_LONG               := 'Waarde is te lang: %d karakters (maximum is %d).';
  STRING_INVALID_FIELD_COUNT          := 'Ongeldig aantal velden: %d (moet tussen 1 en 4095).';
  STRING_INVALID_FIELD_TYPE           := 'Veldtype ''%s'' is ongeldig voor veld ''%s''.';
  STRING_INVALID_VCL_FIELD_TYPE       := 'Veld "%s": VCL veldtype %x wordt niet ondersteund door DBF.';

  STRING_INDEX_BASED_ON_UNKNOWN_FIELD := 'Index gebaseerd op onbekend veld "%s".';
  STRING_INDEX_BASED_ON_INVALID_FIELD := 'Veld "%s" heeft een ongeldig veldtype om index op te baseren.';
  STRING_INDEX_EXPRESSION_TOO_LONG    := 'Index expressie resultaat "%s" is te lang, >100 karakters (%d).';
  STRING_INVALID_INDEX_TYPE           := 'Ongeldig index type: kan alleen karakter of numeriek.';
  STRING_CANNOT_OPEN_INDEX            := 'Openen index gefaald: "%s".';
  STRING_TOO_MANY_INDEXES             := 'Toevoegen index onmogenlijk: te veel indexen in bestand.';
  STRING_INDEX_NOT_EXIST              := 'Index "%s" bestaat niet.';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'Exclusieve toegang is vereist voor deze actie.';
end.

