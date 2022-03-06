PROGRAM PO2MO;
{$mode objfpc}
{$LONGSTRINGS ON}

USES
  SysUtils, POtoMO, {StrUtils,} Classes;

VAR
  MOmake: MObuilder;

BEGIN
  IF ParamCount < 1 THEN Halt (1);
  MOmake:= MObuilder.Create;
  WITH MOmake DO
    TRY
      MObuild (Paramstr (1));
    FINALLY
      Free;
    END;
END.

// BEGIN
//   IF ParamCount < 1 THEN Halt (1);
//   IF ParamCount < 2 THEN Halt (2);
//   MOmake:= MObuilder.Create;
//   WITH MOmake DO BEGIN
//     POparse (Paramstr (1));
//     MOwrite (Paramstr (2));
//     Free;
//   END;
// END.
