			PROGRAM PO2MO;

// By Sieghard 2022			
			
{$mode objfpc}
{$LONGSTRINGS ON}

USES
  SysUtils, POtoMO, {StrUtils,} Classes;

VAR
  MOmake: MObuilder;

PROCEDURE WriteErr (Msg: string);
 BEGIN
   WriteLn (Msg);
 END;

BEGIN
  IF ParamCount < 1 THEN Halt (1);
  MOmake:= MObuilder.Create;
  WITH MOmake DO
    TRY
//    Use this output method if you want
//    to process errors one by one
//    LogError:= @WriteErr;
      MObuild (Paramstr (1));
    FINALLY
//    Use this output method if you want
//    to process errors once for all
//    IF Errors.Count <> 0 THEN WriteLn (Errors.Text);
      Free;
    END;
END.
