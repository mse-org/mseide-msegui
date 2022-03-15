
unit po2arrays;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

interface

uses
  msetypes,
  msesys,
  mseguiintf,
  SysUtils,
  msefileutils,
  msegraphics,
  mseglob,
  msestream,
  msegui,
  msegraphutils,
  mseclasses,
  mclasses,
  msestrings,
  msedatamodules,
  mseguiglob;

procedure createnewlang(alang: msestring);
procedure dosearch(thearray: array of msestring; theindex: integer);
procedure listpofiles();

implementation

uses
  msestockobjects,
  mseconsts,
  captionpodemo;

var
  constvaluearray: array of msestring;
  astro, astrt, acomp: mseString;
  hasfound: Boolean = False;
  empty: Boolean = False;

procedure listpofiles();
var
  ListOfFiles: array of string;
  SearchResult: TSearchRec;
  file1: ttextdatastream;
  Attribute: word;
  i: integer = 0;
  x: integer;
  str1, str2, pat: string;
begin
  Attribute := faReadOnly or faArchive;

  SetLength(ListOfFiles, 0);

  str1 := ExtractFilePath(ParamStr(0)) + 'lang' + directoryseparator;

  // List the files
  FindFirst(str1 + '*.po', Attribute, SearchResult);
  while (i = 0) do
  begin
    SetLength(ListOfFiles, Length(ListOfFiles) + 1);
    // Increase the list
    ListOfFiles[High(ListOfFiles)] := SearchResult.Name;
    // Add it at the of the list
    i := FindNext(SearchResult);
  end;
  FindClose(SearchResult);

  setlength(lang_langnames, 1);
  lang_langnames[0] := 'English [en]';

  pat := ExtractFilePath(ParamStr(0)) + 'lang' + directoryseparator;

  for i := Low(ListOfFiles) to High(ListOfFiles) do
    if system.pos('empty', ListOfFiles[i]) = 0 then
    begin
      setlength(lang_langnames, length(lang_langnames) + 1);
      str1 := ListOfFiles[i];
     {
      writeln(str1 + '  ' + inttostr(FileAge(str1)));
      writeln(str1 + DateTimeToStr(FileDateToDateTime(FileAge(pat + directoryseparator + str1))));

      str2 := copy(str1,1,system.pos('.',str1)) + 'mo';
      writeln(str2 +DateTimeToStr(FileDateToDateTime(FileAge(pat + directoryseparator + str2))));

     if FileDateToDateTime(FileAge(pat + directoryseparator + str1))
      < FileDateToDateTime(FileAge(pat + directoryseparator + str2)) then
      writeln(str1 + ' is younger than ' + str2) else
       writeln(str1 + ' is older than ' + str2);

      writeln();
      }

      //writeln(pat+str1);
      file1 := ttextdatastream.Create(pat + str1, fm_read);
      file1.encoding := ce_utf8;
      x := 0;
      while (not file1.EOF) and (x = 0) do
      begin
        str1 := '';
        file1.readln(str1);
        if system.pos('msgid "English [en]"', str1) > 0 then
        begin
          file1.readln(str1);
          if system.pos('msgstr', str1) > 0 then
          begin
            x    := 1;
            str1 := StringReplace(str1, 'msgstr', '', [rfReplaceAll]);
            str1 := StringReplace(str1, '"', '', [rfReplaceAll]);
            lang_langnames[length(lang_langnames) - 1] := trim(str1);
          end;
          // writeln(lang_langnamestmp[length(lang_langnamestmp) - 1]);
        end;
      end;
      file1.Free;
    end;
end;

procedure dosearch(thearray: array of msestring; theindex: integer);
var
  str2: mseString;
  y: integer;
begin
  y        := 0;
  hasfound := False;

  while (y < length(constvaluearray)) and (hasfound = False) do
  begin
    str2  := (constvaluearray[y]);
    acomp := Copy(str2, 1, system.pos(';', str2) - 1);
    // writeln('---acomp:' + acomp);
    str2  := (Copy(str2, system.pos(';', str2) + 1, length(str2) - system.pos(';', str2) + 1));
    astro := (Copy(str2, 1, system.pos(';', str2) - 1));
    astro := StringReplace(astro, '\"', '"', [rfReplaceAll]);
    //  writeln('---astro:' + astro);
    str2  := (Copy(str2, system.pos(';', str2) + 1, length(str2) - system.pos(';', str2) + 1));
    astrt := Copy(str2, 1, length(str2));
    astrt := StringReplace(astrt, '\"', '"', [rfReplaceAll]);

    if thearray[theindex] = astro then
      hasfound := True;
    // writeln('---astrt:' + astrt);

    Inc(y);
  end;
end;

procedure createnewlang(alang: msestring);
var
  x, x2, x3: integer;
  file1: ttextdatastream;
  str1, strinit, strlang, filename1: msestring;
  str2, str3, str4, strtemp: mseString;
  int1: integer;
  isstring: Boolean = False;
  isid: Boolean = False;
  iscontext: Boolean = False;
  ispocontext: Boolean = False;
  imodalresultty: modalresultty;
  iconflangfoty: conflangfoty;
  iextendedty: extendedty;
  istockcaptionty: stockcaptionty;
  default_conflangfo, defaultresult, default_resulttext, default_modalresulttext, default_modalresulttextnoshortcut, default_stockcaption, default_extendedtext: array of msestring;
begin

  strlang := '';
  str1    := ExtractFilePath(ParamStr(0)) + 'lang' + directoryseparator + 'podemo_' + alang + '.po';

  if (not fileexists(str1)) or (lowercase(alang) = 'en') or (trim(alang) = '') then
  begin
    setlength(lang_modalresult, length(en_modalresulttext));
    for imodalresultty := Low(modalresultty) to High(modalresultty) do
      lang_modalresult[Ord(imodalresultty)] := en_modalresulttext[(imodalresultty)];

    setlength(lang_modalresultnoshortcut, length(en_modalresulttextnoshortcut));
    for imodalresultty := Low(modalresultty) to High(modalresultty) do
      lang_modalresultnoshortcut[Ord(imodalresultty)] :=
        en_modalresulttextnoshortcut[(
        imodalresultty)];

    setlength(lang_stockcaption, length(en_stockcaption));
    for istockcaptionty := Low(stockcaptionty) to High(stockcaptionty) do
      lang_stockcaption[Ord(istockcaptionty)] :=
        en_stockcaption[(istockcaptionty)];

    setlength(lang_extended, length(en_extendedtext));
    for iextendedty := Low(extendedty) to High(extendedty) do
      lang_extended[Ord(iextendedty)] :=
        en_extendedtext[(iextendedty)];

    // You applcation
    setlength(lang_conflangfo, length(en_conflangfotext));
    for iconflangfoty := Low(conflangfoty) to High(conflangfoty) do
      lang_conflangfo[Ord(iconflangfoty)] :=
        en_conflangfotext[(iconflangfoty)];

    listpofiles();

  end
  else if fileexists(str1) then
  begin

    file1 := ttextdatastream.Create(str1, fm_read);

    file1.encoding := ce_utf8;

    setlength(constvaluearray, 0);

    str3 := '';
    str2 := '';
    str4 := '';

    while not file1.EOF do
    begin
      str1    := '';
      file1.readln(str1);
      strtemp := '';

      if (trim(str1) <> '') and (Copy(str1, 1, 1) <> '#') then
        if (Copy(str1, 1, 7) = 'msgctxt') then
        begin
          ispocontext := True;

          setlength(constvaluearray, length(constvaluearray) + 1);
          str2      := str4 + string(';') + str2 + string(';') + str3;
          str2      := StringReplace(str2, '\n', '', [rfReplaceAll]);
          str2      := StringReplace(str2, '\', '', [rfReplaceAll]);
          constvaluearray[length(constvaluearray) - 1] := str2;
          str3      := '';
          str4      := '';
          str4      := (Copy(str1, 10, length(str1) - 10));
          iscontext := True;
          isid      := False;
          isstring  := False;
        end
        else if (copy(str1, 1, 5) = 'msgid') then
        begin
          if ispocontext = False then
          begin
            setlength(constvaluearray, length(constvaluearray) + 1);
            str2 := str4 + string(';') + str2 + string(';') + str3;
            str2 := StringReplace(str2, '\n', '', [rfReplaceAll]);
            str2 := StringReplace(str2, '\', '', [rfReplaceAll]);
            constvaluearray[length(constvaluearray) - 1] := str2;
            str3 := '';
            str4 := '';
          end;
          str2 := Copy(str1, 8, length(str1) - 8);
          iscontext := False;
          isid      := True;
          isstring  := False;
        end
        else if (Copy(str1, 1, 6) = 'msgstr') then
        begin
          str3      := (Copy(str1, 9, length(str1) - 9));
          str3      := StringReplace(str3, '\n', '', [rfReplaceAll]);
          iscontext := False;
          isid      := False;
          isstring  := True;
        end
        else if iscontext then
        begin
          strtemp := Copy(str1, 2, length(str1) - 2);
          if (system.pos('\n', strtemp) > 0) then
          begin
            strtemp := StringReplace(strtemp, '\n', '', [rfReplaceAll]);
            str4    := str4 + strtemp + string(sLineBreak);
          end
          else
            str4    := str4 + strtemp;
        end
        else if isid then
        begin
          strtemp := Copy(str1, 2, length(str1) - 2);
          if (system.pos('\n', strtemp) > 0) then
          begin
            strtemp := StringReplace(strtemp, '\n', '', [rfReplaceAll]);
            str2    := str2 + strtemp + string(sLineBreak);
          end
          else
            str2    := str2 + strtemp;
        end
        else if isstring then
        begin
          strtemp := Copy(str1, 2, length(str1) - 2);
          if (system.pos('\n', strtemp) > 0) then
          begin
            strtemp := StringReplace(strtemp, '\n', '', [rfReplaceAll]);
            str3    := (str3 + strtemp + string(sLineBreak));
          end
          else
            str3    := str3 + strtemp;
        end;
    end;

    setlength(constvaluearray, length(constvaluearray) + 1);
    str2 := str4 + string(';') + str2 + string(';') + str3;
    str2 := StringReplace(str2, '\n', '', [rfReplaceAll]);
    str2 := StringReplace(str2, '\', '', [rfReplaceAll]);
    constvaluearray[length(constvaluearray) - 1] := str2;

    file1.Free;

    setlength(default_modalresulttext, length(en_modalresulttext));
    for imodalresultty := Low(modalresultty) to High(modalresultty) do
      default_modalresulttext[Ord(imodalresultty)] := en_modalresulttext[(imodalresultty)];

    setlength(default_modalresulttextnoshortcut, length(en_modalresulttextnoshortcut));
    for imodalresultty := Low(modalresultty) to High(modalresultty) do
      default_modalresulttextnoshortcut[Ord(imodalresultty)] :=
        en_modalresulttextnoshortcut[(imodalresultty)];

    setlength(default_stockcaption, length(en_stockcaption));
    for istockcaptionty := Low(stockcaptionty) to High(stockcaptionty) do
      default_stockcaption[Ord(istockcaptionty)] :=
        en_stockcaption[(istockcaptionty)];

    setlength(default_extendedtext, length(en_extendedtext));
    for iextendedty := Low(extendedty) to High(extendedty) do
      default_extendedtext[Ord(iextendedty)] :=
        en_extendedtext[(iextendedty)];

    // You applcation
    setlength(default_conflangfo, length(en_conflangfotext));
    for iconflangfoty := Low(conflangfoty) to High(conflangfoty) do
      default_conflangfo[Ord(iconflangfoty)] :=
        en_conflangfotext[(iconflangfoty)];

    setlength(lang_modalresult, length(default_modalresulttext));

    for x := 0 to length(default_modalresulttext) - 1 do
    begin

      dosearch(default_modalresulttext, x);
      if hasfound then
      else
        astrt := default_modalresulttext[x];
      if trim(astrt) = '' then
        astrt := default_modalresulttext[x];

      astrt := StringReplace(astrt, ',', '‚', [rfReplaceAll]);
      astrt := StringReplace(astrt, #039, '‘', [rfReplaceAll]);

      lang_modalresult[x] := astrt;

    end;

    setlength(lang_modalresultnoshortcut, length(default_modalresulttextnoshortcut));

    for x := 0 to length(default_modalresulttextnoshortcut) - 1 do
    begin
      dosearch(default_modalresulttextnoshortcut, x);

      if hasfound then
      else
        astrt := default_modalresulttextnoshortcut[x];
      if trim(astrt) = '' then
        astrt := default_modalresulttextnoshortcut[x];

      astrt := StringReplace(astrt, ',', '‚', [rfReplaceAll]);
      astrt := StringReplace(astrt, #039, '‘', [rfReplaceAll]);

      lang_modalresultnoshortcut[x] := astrt;
    end;

    setlength(lang_stockcaption, length(default_stockcaption));

    for x := 0 to length(default_stockcaption) - 1 do
    begin
      dosearch(default_stockcaption, x);

      if hasfound then
      else
        astrt := default_stockcaption[x];
      if trim(astrt) = '' then
        astrt := default_stockcaption[x];

      astrt := StringReplace(astrt, ',', '‚', [rfReplaceAll]);
      astrt := StringReplace(astrt, #039, '‘', [rfReplaceAll]);

      lang_stockcaption[x] := astrt;

    end;

    setlength(lang_extended, length(default_extendedtext));

    for x := 0 to length(default_extendedtext) - 1 do
    begin
      dosearch(default_extendedtext, x);

      if hasfound then
      else
        astrt := default_extendedtext[x];
      if trim(astrt) = '' then
        astrt := default_extendedtext[x];

      astrt := StringReplace(astrt, ',', '‚', [rfReplaceAll]);
      astrt := StringReplace(astrt, #039, '‘', [rfReplaceAll]);

      lang_extended[x] := astrt;

    end;

    // Your application
    setlength(lang_conflangfo, length(default_conflangfo));

    for x := 0 to length(default_conflangfo) - 1 do
    begin
      dosearch(default_conflangfo, x);

      if hasfound then
      else
        astrt := default_conflangfo[x];
      if trim(astrt) = '' then
        astrt := default_conflangfo[x];

      astrt := StringReplace(astrt, ',', '‚', [rfReplaceAll]);
      astrt := StringReplace(astrt, #039, '‘', [rfReplaceAll]);

      lang_conflangfo[x] := astrt;

    end;

    listpofiles();

  end;
end;

end.

