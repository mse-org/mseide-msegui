unit dbf_str_ru;

// file is encoded in Windows-1251 encoding
// for using with Linux/Kylix must be re-coded to KOI8-R
// for use with DOS & OS/2 (if it will be possible with FreePascal or VirtualPascal)
//    file should be recoded to cp866

interface

{$I dbf_common.inc}
{$I dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := 'Файл "%s" не существует. Открыть невозможно.';
  STRING_VERSION                      := 'TDbf V%d.%d';

  STRING_RECORD_LOCKED                := 'Запись (строка таблицы) заблокирована.';
  STRING_WRITE_ERROR                  := 'Ошибка записи на диск (Диск заполнен?)';
  STRING_KEY_VIOLATION                := 'Ключевое значение не должно повторяться!.'+#13+#10+
                                         'Индекс: %s'+#13+#10+'Запись (строка)=%d  Ключ="%s".';

  STRING_INVALID_DBF_FILE             := 'Файл DBF поврежден или его структура не DBF.';
  STRING_FIELD_TOO_LONG               := 'Длина значения - %d символов, это больше максимума - %d.';
  STRING_INVALID_FIELD_COUNT          := 'Количество полей в таблице (%d) невозможно. Допустимо от 1 до 4095.';
  STRING_INVALID_FIELD_TYPE           := 'Тип значения "%s", затребованный полем "%s" невозможен.';
  STRING_INVALID_VCL_FIELD_TYPE       := 'Невозможно создать поле "%s", Тип данных VCL[%x] не может быть записан в DBF.';

  STRING_INDEX_BASED_ON_UNKNOWN_FIELD := 'Индекс ссылается на несуществующее поле "%s".';
  STRING_INDEX_BASED_ON_INVALID_FIELD := 'Поле "%s" не может быть индексированно. Индексы не поддерживают такой тип поля.';
  STRING_INDEX_EXPRESSION_TOO_LONG    := '%s: Слишком длинное значение для индекса (%d). Должно быть не больше 100 символов.';
  STRING_INVALID_INDEX_TYPE           := 'Невозможный тип индекса: индексация возможно только по числу или строке';
  STRING_CANNOT_OPEN_INDEX            := 'Невозможно открыть индекс "%s".';
  STRING_TOO_MANY_INDEXES             := 'Невозможно создать еще один индекс. Файл полон.';
  STRING_INDEX_NOT_EXIST              := 'Индекс "%s" не существует.';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'Невозможно выполнить - сначала нужно получить монопольный доступ.';
end.

