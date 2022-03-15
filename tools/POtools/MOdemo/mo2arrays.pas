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
  MOfile: TMOfile;
  Attribute: word;
  i: integer = 0;
  str1, str2: string;
begin
  Attribute := faReadOnly or faArchive;

  SetLength(ListOfFiles, 0);

  str1 := ExtractFilePath(ParamStr(0)) + 'lang' + directoryseparator;

  // List the files
  FindFirst(str1 + '*.mo', Attribute, SearchResult);
  while (i = 0) do
  begin
    SetLength(ListOfFiles, Length(ListOfFiles) + 1);     // Increase the list
    ListOfFiles[High(ListOfFiles)] := SearchResult.Name; // Add it at the end of the list
    i := FindNext(SearchResult);
  end;
  FindClose(SearchResult);

  setlength(lang_langnames, 1);
  lang_langnames[0] := 'English [en]';

  for i := Low(ListOfFiles) to High(ListOfFiles) do
    if system.pos('empty', ListOfFiles[i]) = 0 then
    begin
     setlength(lang_langnames, length(lang_langnames) + 1);
       str2 := ListOfFiles[i];
       MOfile:= TMOfile.Create (str1+str2);
       str2 := MOfile.Translate('English [en]');
       //writeln(str1);
       lang_langnames[length(lang_langnames) - 1] := trim(str2);
       MOfile.Destroy;
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

   //    writeln('length(en_langnamestext) ' + inttostr(length(en_langnamestext)));
    //       writeln('lang_langnames[x] ' + inttostr(length(lang_langnames)));

  end
  else if fileexists(str1) then
  begin

    MOfile:= TMOfile.Create (str1);

    buildlangtext (default_modalresulttext, default_modalresulttextnoshortcut, default_stockcaption,
                   default_extendedtext, default_mainformtext);

    translate_stock (lang_modalresult, default_modalresulttext, MOfile);
    translate_stock (lang_modalresultnoshortcut, default_modalresulttextnoshortcut, MOfile);
    translate_stock (lang_stockcaption, default_stockcaption, MOfile);
    translate_stock (lang_extended, default_extendedtext, MOfile);
    translate_stock (lang_mainform, default_mainformtext, MOfile);

    MOfile.Destroy;

    findpofiles();

  end;
end;

end.
