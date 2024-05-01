UNIT FieldTypeError;   (* Exception raise procedure for field type errors *)

{$modeSwitch class+}
{$modeSwitch exceptions+}

INTERFACE

USES
  MDB, SysUtils;

CONST
  FieldTypeName: ARRAY [TFieldType] OF string [15] =
    ('ftUnknown', 'ftString', 'ftSmallint', 'ftInteger', 'ftWord', 'ftBoolean', 'ftFloat',
     'ftCurrency', 'ftBCD', 'ftDate', 'ftTime', 'ftDateTime', 'ftBytes', 'ftVarBytes',
     'ftAutoInc', 'ftBlob', 'ftMemo', 'ftGraphic', 'ftFmtMemo', 'ftParadoxOle', 'ftDBaseOle',
     'ftTypedBinary', 'ftCursor', 'ftFixedChar', 'ftWideString', 'ftLargeint', 'ftADT',
     'ftArray', 'ftReference', 'ftDataSet', 'ftOraBlob', 'ftOraClob', 'ftVariant', 'ftInterface',
     'ftIDispatch', 'ftGuid', 'ftTimeStamp', 'ftFMTBcd', 'ftFixedWideChar', 'ftWideMemo');

PROCEDURE FieldError (FieldType: TFieldType);

IMPLEMENTATION

CONST
  FieldTypeMsg = 'Unhandled field type received';

PROCEDURE FieldError (FieldType: TFieldType);
 BEGIN
   Raise Exception.Create (FieldTypeMsg+ ': '+ FieldTypeName [FieldType]) AT
         get_caller_addr (get_frame), get_caller_frame (get_frame);
 END;

END.
