unit dbf_str;

interface

{$I dbf_common.inc}
{$I dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := 'Open: file not found: "%s".';
  STRING_VERSION                      := 'TDbf V%d.%d';

  STRING_RECORD_LOCKED                := 'Record locked.';
  STRING_WRITE_ERROR                  := 'Error while writing occurred. (Disk full?)';
  STRING_WRITE_INDEX_ERROR            := 'Error while writing occurred; indexes probably corrupted. (Disk full?)';
  STRING_KEY_VIOLATION                := 'Key violation. (Key already present in file).'+#13+#10+
                                         'Index: %s'+#13+#10+'Record=%d Key=''%s''.';

  STRING_INVALID_DBF_FILE             := 'Invalid DBF file.';
  STRING_FIELD_TOO_LONG               := 'Value is too long: %d characters (it can''t be more than %d).';
  STRING_INVALID_FIELD_COUNT          := 'Invalid field count: %d (must be between 1 and 4095).';
  STRING_INVALID_FIELD_TYPE           := 'Invalid field type ''%s'' for field ''%s''.';
  STRING_INVALID_VCL_FIELD_TYPE       := 'Cannot create field "%s", VCL field type %x not supported by DBF.';

  STRING_INDEX_BASED_ON_UNKNOWN_FIELD := 'Index based on unknown field "%s".';
  STRING_INDEX_BASED_ON_INVALID_FIELD := 'Field "%s" is an invalid field type to base index on.';
  STRING_INDEX_EXPRESSION_TOO_LONG    := 'Index result for "%s" too long, >100 characters (%d).';
  STRING_INVALID_INDEX_TYPE           := 'Invalid index type: can only be string or float.';
  STRING_CANNOT_OPEN_INDEX            := 'Cannot open index: "%s".';
  STRING_TOO_MANY_INDEXES             := 'Can not create index: too many indexes in file.';
  STRING_INDEX_NOT_EXIST              := 'Index "%s" does not exist.';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'Exclusive access is required for this operation.';
end.

