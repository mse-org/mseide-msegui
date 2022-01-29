unit po2arrays;

{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface

uses
  msetypes,
  msesys,
  mseguiintf,
  SysUtils,
  LazUTF8,
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
procedure findpofiles();

implementation

uses
  msestockobjects,
  mseconsts,
  form_conflang;

var
  constvaluearray: array of msestring;
  astro, astrt, acomp: utf8String;
  hasfound: Boolean = False;
  empty: Boolean = False;
  lang_langnamestmp: array of msestring;

procedure findpofiles();
var
  ListOfFiles: array of string;
  SearchResult: TSearchRec;
  Attribute: word;
  i: integer = 0;
  str1: string;
begin
  Attribute := faReadOnly or faArchive;

  SetLength(ListOfFiles, 0);

  str1 := ExtractFilePath(ParamStr(0)) + 'lang' + directoryseparator;

  // List the files
  FindFirst(str1 + '*.po', Attribute, SearchResult);
  while (i = 0) do
  begin
    SetLength(ListOfFiles, Length(ListOfFiles) + 1);     // Increase the list
    ListOfFiles[High(ListOfFiles)] := SearchResult.Name; // Add it at the end of the list
    i := FindNext(SearchResult);
  end;
  FindClose(SearchResult);

  setlength(lang_langnamestmp, 1);
  lang_langnamestmp[0] := '[en]';

  for i := Low(ListOfFiles) to High(ListOfFiles) do
    if system.pos('empty', ListOfFiles[i]) = 0 then
    begin
      setlength(lang_langnamestmp, length(lang_langnamestmp) + 1);
      str1 := ListOfFiles[i];
      str1 := utf8StringReplace(str1, 'podemo_', '', [rfReplaceAll]);
      str1 := utf8StringReplace(str1, '.po', '', [rfReplaceAll]);
      lang_langnamestmp[length(lang_langnamestmp) - 1] := '[' + trim(str1) + ']';
    end;
end;

procedure dosearch(thearray: array of msestring; theindex: integer);
var
  str2: utf8String;
  y: integer;
begin
  y        := 0;
  hasfound := False;

  while (y < length(constvaluearray)) and (hasfound = False) do
  begin
    str2  := (constvaluearray[y]);
    acomp := UTF8Copy(str2, 1, system.pos(';', str2) - 1);
    // writeln('---acomp:' + acomp);
    str2  := (UTF8Copy(str2, system.pos(';', str2) + 1, length(str2) - system.pos(';', str2) + 1));
    astro := (UTF8Copy(str2, 1, system.pos(';', str2) - 1));
    astro := utf8StringReplace(astro, '\"', '"', [rfReplaceAll]);
    //  writeln('---astro:' + astro);
    str2  := (UTF8Copy(str2, system.pos(';', str2) + 1, length(str2) - system.pos(';', str2) + 1));
    astrt := UTF8Copy(str2, 1, length(str2));
    astrt := utf8StringReplace(astrt, '\"', '"', [rfReplaceAll]);

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
  str1: msestring;
  str2, str3, str4, strtemp: utf8String;
  isstring: Boolean = False;
  isid: Boolean = False;
  iscontext: Boolean = False;
  ispocontext: Boolean = False;
  // The enums of msegui widgets:
  imodalresultty: modalresultty;
  iextendedty: extendedty;
  istockcaptionty: stockcaptionty;
  // The arrays of msegui widgets:
  default_modalresulttext, default_modalresulttextnoshortcut, default_stockcaption,
  default_langnamestext, default_extendedtext: array of msestring;
  // Your enum
  imyformty: myformty;
  // Your array
  default_myformtext: array of msestring;
begin

  str1 := ExtractFilePath(ParamStr(0)) + 'lang' + directoryseparator + 'podemo_' + alang + '.po';

  if (not fileexists(str1)) or (lowercase(alang) = 'en') or (trim(alang) = '') then
  begin
    setlength(lang_modalresult, length(en_modalresulttext));
    for imodalresultty := Low(modalresultty) to High(modalresultty) do
      lang_modalresult[Ord(imodalresultty)] := en_modalresulttext[(imodalresultty)];

    setlength(lang_modalresultnoshortcut, length(en_modalresulttextnoshortcut));
    for imodalresultty := Low(modalresultty) to High(modalresultty) do
      lang_modalresultnoshortcut[Ord(imodalresultty)] :=
        en_modalresulttextnoshortcut[(imodalresultty)];

    setlength(lang_stockcaption, length(en_stockcaption));
    for istockcaptionty := Low(stockcaptionty) to High(stockcaptionty) do
      lang_stockcaption[Ord(istockcaptionty)] :=
        en_stockcaption[(istockcaptionty)];

    setlength(lang_extended, length(en_extendedtext));
    for iextendedty := Low(extendedty) to High(extendedty) do
      lang_extended[Ord(iextendedty)] :=
        en_extendedtext[(iextendedty)];

    setlength(lang_myform, length(en_myformtext));
    for imyformty := Low(myformty) to High(myformty) do
      lang_myform[Ord(imyformty)] :=
        en_myformtext[(imyformty)];

    findpofiles();

    if length(lang_langnamestmp) > length(en_langnamestext) then
      setlength(lang_langnames, length(lang_langnamestmp))
    else
      setlength(lang_langnames, length(en_langnamestext));

    for x := 0 to length(en_langnamestext) - 1 do
      lang_langnames[x] := en_langnamestext[x];

    if length(lang_langnames) > length(en_langnamestext) then
    begin
      for x := 0 to high(lang_langnames) do
      begin
        str2   := trim(copy(lang_langnames[x], system.pos('[', lang_langnames[x]), 10));
        for x2 := 0 to high(lang_langnamestmp) do
          if trim(lang_langnamestmp[x2]) = str2 then
            lang_langnamestmp[x2] := '';
      end;

      x2    := length(en_langnamestext);
      for x := 0 to high(lang_langnamestmp) do
        if trim(lang_langnamestmp[x]) <> '' then
        begin
          lang_langnames[x2] := 'Language ' + trim(lang_langnamestmp[x]);
          Inc(x2);
        end;

    end;
  end
  else if fileexists(str1) then
  begin

    file1 := ttextdatastream.Create(str1, fm_read);

    file1.encoding := ce_utf8;

    setlength(constvaluearray, 0);

    file1.readln(str1);

    str2 := '';
    str3 := '';
    str4 := '';

    while not file1.EOF do
    begin
      str1    := '';
      file1.readln(str1);
      strtemp := '';

      if (trim(str1) <> '') and (UTF8Copy(str1, 1, 1) <> '#') then
        if (UTF8Copy(str1, 1, 7) = 'msgctxt') then
        begin
          ispocontext := True;

          setlength(constvaluearray, length(constvaluearray) + 1);
          str2      := str4 + utf8String(';') + str2 + utf8String(';') + str3;
          str2      := utf8StringReplace(str2, '\n', '', [rfReplaceAll]);
          str2      := utf8StringReplace(str2, '\', '', [rfReplaceAll]);
          constvaluearray[length(constvaluearray) - 1] := str2;
          str3      := '';
          str4      := '';
          str4      := (UTF8Copy(str1, 10, length(str1) - 10));
          iscontext := True;
          isid      := False;
          isstring  := False;
        end
        else if (copy(str1, 1, 5) = 'msgid') then
        begin
          if ispocontext = False then
          begin
            setlength(constvaluearray, length(constvaluearray) + 1);
            str2 := str4 + utf8String(';') + str2 + utf8String(';') + str3;
            str2 := utf8StringReplace(str2, '\n', '', [rfReplaceAll]);
            str2 := utf8StringReplace(str2, '\', '', [rfReplaceAll]);
            constvaluearray[length(constvaluearray) - 1] := str2;
            str3 := '';
            str4 := '';
          end;
          str2 := UTF8Copy(str1, 8, length(str1) - 8);
          iscontext := False;
          isid      := True;
          isstring  := False;
        end
        else if (UTF8Copy(str1, 1, 6) = 'msgstr') then
        begin
          str3      := (UTF8Copy(str1, 9, length(str1) - 9));
          str3      := utf8StringReplace(str3, '\n', '', [rfReplaceAll]);
          iscontext := False;
          isid      := False;
          isstring  := True;
        end
        else if iscontext then
        begin
          strtemp := UTF8Copy(str1, 2, length(str1) - 2);
          if (system.pos('\n', strtemp) > 0) then
          begin
            strtemp := utf8StringReplace(strtemp, '\n', '', [rfReplaceAll]);
            str4    := str4 + strtemp + utf8String(sLineBreak);
          end
          else
            str4    := str4 + strtemp;
        end
        else if isid then
        begin
          strtemp := UTF8Copy(str1, 2, length(str1) - 2);
          if (system.pos('\n', strtemp) > 0) then
          begin
            strtemp := utf8StringReplace(strtemp, '\n', '', [rfReplaceAll]);
            str2    := str2 + strtemp + utf8String(sLineBreak);
          end
          else
            str2    := str2 + strtemp;
        end
        else if isstring then
        begin
          strtemp := UTF8Copy(str1, 2, length(str1) - 2);
          if (system.pos('\n', strtemp) > 0) then
          begin
            strtemp := utf8StringReplace(strtemp, '\n', '', [rfReplaceAll]);
            str3    := (str3 + strtemp + utf8String(sLineBreak));
          end
          else
            str3    := str3 + strtemp;
        end;
    end;
    setlength(constvaluearray, length(constvaluearray) + 1);
    str2 := str4 + utf8String(';') + str2 + utf8String(';') + str3;
    str2 := utf8StringReplace(str2, '\n', '', [rfReplaceAll]);
    str2 := utf8StringReplace(str2, '\', '', [rfReplaceAll]);
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

    setlength(default_myformtext, length(en_myformtext));
    for imyformty := Low(myformty) to High(myformty) do
      default_myformtext[Ord(imyformty)] :=
        en_myformtext[(imyformty)];

    setlength(default_langnamestext, length(en_langnamestext));
    for x := 0 to length(en_langnamestext) - 1 do
      default_langnamestext[x] := en_langnamestext[x];

    setlength(lang_modalresult, length(default_modalresulttext));

    for x := 0 to length(default_modalresulttext) - 1 do
    begin

      dosearch(default_modalresulttext, x);
      if hasfound then
      else
        astrt := default_modalresulttext[x];
      if trim(astrt) = '' then
        astrt := default_modalresulttext[x];

      astrt := utf8StringReplace(astrt, ',', '‚', [rfReplaceAll]);
      astrt := utf8StringReplace(astrt, #039, '‘', [rfReplaceAll]);

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

      astrt := utf8StringReplace(astrt, ',', '‚', [rfReplaceAll]);
      astrt := utf8StringReplace(astrt, #039, '‘', [rfReplaceAll]);

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

      astrt := utf8StringReplace(astrt, ',', '‚', [rfReplaceAll]);
      astrt := utf8StringReplace(astrt, #039, '‘', [rfReplaceAll]);

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

      astrt := utf8StringReplace(astrt, ',', '‚', [rfReplaceAll]);
      astrt := utf8StringReplace(astrt, #039, '‘', [rfReplaceAll]);

      lang_extended[x] := astrt;

    end;

    setlength(lang_myform, length(default_myformtext));

    for x := 0 to length(default_myformtext) - 1 do
    begin
      dosearch(default_myformtext, x);

      if hasfound then
      else
        astrt := default_myformtext[x];
      if trim(astrt) = '' then
        astrt := default_myformtext[x];

      astrt := utf8StringReplace(astrt, ',', '‚', [rfReplaceAll]);
      astrt := utf8StringReplace(astrt, #039, '‘', [rfReplaceAll]);

      lang_myform[x] := astrt;
    end;

    setlength(lang_langnames, length(default_langnamestext));

    for x := 0 to length(default_langnamestext) - 1 do
    begin
      dosearch(default_langnamestext, x);

      if hasfound then
      else
        astrt := default_langnamestext[x];
      if trim(astrt) = '' then
        astrt := default_langnamestext[x];

      astrt := utf8StringReplace(astrt, ',', '‚', [rfReplaceAll]);
      astrt := utf8StringReplace(astrt, #039, '‘', [rfReplaceAll]);

      lang_langnames[x] := astrt;

    end;

    findpofiles();

    if length(lang_langnamestmp) > length(lang_langnames) then
    begin
      x3     := length(lang_langnames);
      setlength(lang_langnames, length(lang_langnamestmp));
      for x  := 0 to high(lang_langnames) do
      begin
        str2 := trim(copy(lang_langnames[x], system.pos('[', lang_langnames[x]), 10));
        for x2 := 0 to high(lang_langnamestmp) do
          if trim(lang_langnamestmp[x2]) = str2 then
            lang_langnamestmp[x2] := '';
      end;

      for x := 0 to high(lang_langnamestmp) do
        if trim(lang_langnamestmp[x]) <> '' then
        begin
          lang_langnames[x3] := 'Language ' + trim(lang_langnamestmp[x]);
          Inc(x3);
        end;

    end;
  end;
end;

end.

