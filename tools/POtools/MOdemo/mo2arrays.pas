unit mo2arrays;

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
procedure findpofiles();

implementation

uses
  gettext,
  msestockobjects,
  captionmodemo,
  mseconsts;

const
  appname = 'modemo_';
  langext = '.mo';

var
  lang_langnamestmp: array of msestring;

///////////////

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
      str1 := StringReplace(str1, appname, '', [rfReplaceAll]);
      str1 := StringReplace(str1, langext, '', [rfReplaceAll]);
      lang_langnamestmp[length(lang_langnamestmp) - 1] := '[' + trim(str1) + ']';
      //writeln(lang_langnamestmp[length(lang_langnamestmp) - 1]);
    end;
end;

procedure translate_stock (var lang_stocktext, default_stocktext: {array of msestring}msestringarty;
                           MOfile: TMOfile);
var
  x: integer;
  astrt: mseString;
begin
    setlength (lang_stocktext, length (default_stocktext));

    for x:= 0 to length (default_stocktext) - 1 do
    begin
      astrt:= MOfile.translate (default_stocktext [x]);
      astrt:= StringReplace (astrt, ',',  '‚', [rfReplaceAll]);
      astrt:= StringReplace (astrt, #039, '‘', [rfReplaceAll]);
      lang_stocktext [x]:= astrt;
    end;
end;

procedure buildlangtext (var lang_modalresults, lang_modalresultnoshortcuts, lang_stockcaptions,
                             lang_extendeds, lang_mainforms: {array of msestring}msestringarty);

 procedure buildonelang (var lang, reflang: {array of msestring}msestringarty);
 var
   i: integer;
 begin
    setlength (lang, length (reflang));
    for i:= Low (reflang) to High (reflang) do lang [i]:= reflang [i];
 end;

begin
    buildonelang (lang_modalresults, msestringarty (en_modalresulttext));
    buildonelang (lang_modalresultnoshortcuts, msestringarty (en_modalresulttextnoshortcut));
    buildonelang (lang_stockcaptions, msestringarty (en_stockcaption));
    buildonelang (lang_extendeds, msestringarty (en_extendedtext));
    buildonelang (lang_mainforms, msestringarty (en_mainformtext));
end;

procedure createnewlang(alang: msestring);
var
  x, x2, x3: integer;
  str1: msestring;
  str2: mseString;
  default_modalresulttext, default_modalresulttextnoshortcut, default_mainformtext, default_stockcaption, default_langnamestext, default_extendedtext: array of msestring;

    MOfile: TMOfile;

begin
    setlength (default_modalresulttext, 0);
    setlength (default_modalresulttextnoshortcut, 0);
    setlength (default_stockcaption, 0);
    setlength (default_extendedtext, 0);
    setlength (default_mainformtext, 0);

  str1 := ExtractFilePath(ParamStr(0)) + 'lang' + directoryseparator + appname + alang + langext;

  if (not fileexists(str1)) or (lowercase(alang) = 'en') or (trim(alang) = '') then
  begin
    buildlangtext (lang_modalresult, lang_modalresultnoshortcut, lang_stockcaption,
                   lang_extended, lang_mainform);

    findpofiles();

    if length(lang_langnamestmp) > length(en_langnamestext) then
      setlength(lang_langnames, length(lang_langnamestmp))
    else
      setlength(lang_langnames, length(en_langnamestext));

    //    writeln('length(en_langnamestext) ' + inttostr(length(en_langnamestext)));
    //       writeln('lang_langnames[x] ' + inttostr(length(lang_langnames)));

    for x := 0 to length(en_langnamestext) - 1 do
      lang_langnames[x] := en_langnamestext[x];

    if length(lang_langnames) > length(en_langnamestext) then
    begin
      for x := 0 to high(lang_langnames) do
      begin
        str2:= trim(copy(lang_langnames[x], system.pos('[', lang_langnames[x]), 10));
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

    MOfile:= TMOfile.Create (str1);

    buildlangtext (default_modalresulttext, default_modalresulttextnoshortcut, default_stockcaption,
                   default_extendedtext, default_mainformtext);

    setlength(default_langnamestext, length(en_langnamestext));
//    for x := 0 to length(en_langnamestext) - 1 do
//      default_langnamestext[x] := MOfile.translate (en_langnamestext[x]);
    default_langnamestext:= en_langnamestext;

    translate_stock (lang_modalresult, default_modalresulttext, MOfile);
    translate_stock (lang_modalresultnoshortcut, default_modalresulttextnoshortcut, MOfile);
    translate_stock (lang_stockcaption, default_stockcaption, MOfile);
    translate_stock (lang_extended, default_extendedtext, MOfile);
    translate_stock (lang_mainform, default_mainformtext, MOfile);
    translate_stock (lang_langnames, default_langnamestext, MOfile);

    MOfile.Destroy;

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
