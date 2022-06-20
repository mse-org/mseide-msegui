UNIT mo4stock;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

INTERFACE

USES
  msetypes,
  SysUtils;

CONST
  ModalresultArea =           0;
  ModalresultnoShortcutArea = 1;
  StockcaptionArea =          2;
  ExtendedArea =              3;
  LangFlag =                '*';

VAR
  customsetLangFilePattern: FUNCTION: string;
  realizeApplicationLanguages: PROCEDURE = NIL;
  LangDir: string = 'lang';
  Appname: string;

PROCEDURE createnewlang (alang: msestring);
FUNCTION findmofiles: msestringarty;
// procedure createnewlangmo (alang: msestring);
// procedure findmofiles ();
// FUNCTION findpofiles (LinuxSystem: boolean = false): msestringarty;

// FUNCTION addApplicationStrings (ApplicationStrings: msestringarty; VAR ApplicationDefaults: msestringarty): integer;
// FUNCTION addApplicationStrings (ApplicationStrings: msestringarty; VAR Area: integer): msestringarty;
// FUNCTION addApplicationStrings (ApplicationStrings: msestringarty): integer;
FUNCTION addApplicationStrings (ApplicationStrings: ARRAY OF msestring; VAR ApplicationDefaults: msestringarty): integer;
FUNCTION addApplicationStrings (ApplicationStrings: ARRAY OF msestring; VAR Area: integer): msestringarty;
FUNCTION addApplicationStrings (ApplicationStrings: ARRAY OF msestring): integer;
FUNCTION getApplicationString (Area, Index: integer): msestring;
FUNCTION getApplicationLanguage (Area: integer): msestringarty;
FUNCTION ApplicationStringCount (Area: integer): integer;

IMPLEMENTATION

USES
  Classes,
  StrUtils,
  gettext,
  mseconsts,
  msestockobjects;

TYPE
  Localisator = ARRAY OF msestringarty;

CONST
  LangExt =   '.mo';
  BaseLang =  'English [en]';
  LinuxFlag = '/LC_MESSAGES/';

VAR
  LocalisationReference,
  LocalisationActive: Localisator;


// FUNCTION addApplicationStrings (ApplicationStrings: msestringarty; VAR ApplicationDefaults: msestringarty): integer;
FUNCTION addApplicationStrings (ApplicationStrings: ARRAY OF msestring; VAR ApplicationDefaults: msestringarty): integer;
 BEGIN
   Result:= addApplicationStrings (ApplicationStrings);
   ApplicationDefaults:= LocalisationActive [Result];
 END;

// FUNCTION addApplicationStrings (ApplicationStrings: msestringarty; VAR Area: integer): msestringarty;
FUNCTION addApplicationStrings (ApplicationStrings: ARRAY OF msestring; VAR Area: integer): msestringarty;
 BEGIN
   Area:=  addApplicationStrings (ApplicationStrings);
   Result:= LocalisationActive [Area];
 END;

// FUNCTION addApplicationStrings (ApplicationStrings: msestringarty): integer;
FUNCTION addApplicationStrings (ApplicationStrings: ARRAY OF msestring): integer;
 VAR
   i: integer;
 BEGIN
   Result:= Length (LocalisationReference);
   SetLength (LocalisationReference, succ (Result));
   SetLength (LocalisationActive,    succ (Result));

   SetLength (LocalisationReference [Result], Length (ApplicationStrings));
   FOR i:= 0 TO High (ApplicationStrings) DO
     LocalisationReference [Result][i]:= ApplicationStrings [i];

   SetLength (LocalisationActive [Result], 0);
 END;

FUNCTION getApplicationString (Area, Index: integer): msestring;
 BEGIN
   Result:= LocalisationActive [Area][Index];
 END;

FUNCTION getApplicationLanguage (Area: integer): msestringarty;
 BEGIN
   Result:= LocalisationActive [Area];
 END;

FUNCTION ApplicationStringCount (Area: integer): integer;
 BEGIN
   Result:= Length (LocalisationActive [Area]);
 END;


FUNCTION findMOfiles: msestringarty;
 VAR
   i, l:         integer;
   ListOfFiles:  TStringList;
   Langname:     string;
   MOfile: TMOfile;

 FUNCTION findMOfilesLangdir: TStringList;
  VAR
    SearchResult: TSearchRec;
    Attribute:    word;
  BEGIN
    Attribute:= faReadOnly OR faArchive;
    Result:= TStringList.Create; i:= 0;

    // List the files, LangDir:= expandprmacros('${LANGDIR}');
    FindFirst (LangDir+ Appname+ LangFlag+ LangExt, Attribute, SearchResult);
    WHILE i = 0 DO BEGIN
      Result.Add (SearchResult.Name);       // Add it to the the list
      i:= FindNext (SearchResult);
    END;
    FindClose (SearchResult);
  END;

{$ifdef Linux}
 FUNCTION findMOfilesLinuxSys: TStringList;  // !!!!!!!!!!!!!!!!!!!!!
  VAR
    SearchResult: TSearchRec;
    Attribute:    word;
  BEGIN
    Attribute:= faReadOnly OR faArchive OR faDirectory;
    Result:= TStringList.Create; i:= 0;

    // List the files, Linux: LangDir = /usr/share/locale/<language>/LC_MESSAGES
    FindFirst (LangDir+ LangFlag{+ Appname+ LangExt}, Attribute, SearchResult);
    WHILE i = 0 DO BEGIN
      IF (SearchResult.Name <> '.') AND
         DirectoryExists (LangDir+ SearchResult.Name) AND
         FileExists (LangDir+ SearchResult.Name+ Appname+ LangExt)
      THEN
      Result.Add (SearchResult.Name+ Appname+ LangExt);       // Add it to the list
      i:= FindNext (SearchResult);
    END;
    FindClose (SearchResult);
  END;
{$endif}

 BEGIN
{$ifdef Linux}
   IF System.Pos (LinuxFlag, LangDir+ Appname) <> 0  // Linux System
     THEN ListOfFiles:= findMOfilesLinuxSys
     ELSE
     {$endif} ListOfFiles:= findMOfilesLangdir;

   IF ListOfFiles.Count = 0 THEN BEGIN               // NO files?
     SetLength (Result, 1); Result [0]:= BaseLang;   // 'English'
     Exit;
   END;
   ListOfFiles.Sort;
   SetLength (Result, ListOfFiles.Count); Result [0]:= BaseLang;  // 'English'
   l:= 0;
   FOR i:= 0 TO pred (ListOfFiles.Count) DO BEGIN
     Langname:= ListOfFiles [i];

     IF System.Pos ('empty', Langname) = 0 THEN BEGIN
       MOfile:= TMOfile.Create (LangDir+ Langname);
       Langname:= MOfile.Translate (BaseLang); Inc (l);
       //writeln (Lang);
       MOfile.Destroy;
       IF l >= Length (Result)
         THEN setLength (Result, succ (Length (Result)));  // maybe no 'empty' lang file?
       Result [l]:= Trim (Langname);
     END;
   END;
 END;
(*
procedure findmofiles ();
var
  ListOfFiles: array of string;
  MOfile: TMOfile;
  SearchResult: TSearchRec;
  file1: ttextdatastream;
  Attribute: word;
  i: integer = 0;
  str1, str2, str3: msestring;
begin
  Attribute := faReadOnly or faArchive;

  SetLength(ListOfFiles, 0);

  //str1 := LangDir + directoryseparator;

//  str1 := expandprmacros('${LANGDIR}') + directoryseparator;

  // List the files
  FindFirst(LangDir{str1} + '*'+ LangExt, Attribute, SearchResult);
   WHILE i = 0 DO BEGIN
     SetLength (ListOfFiles, succ (Length (ListOfFiles)));      // Increase the list
     ListOfFiles [High (ListOfFiles)]:= SearchResult.Name;      // Add it at the end of the list
     i:= FindNext (SearchResult);
   END;
  FindClose(SearchResult);

  setlength(lang_langnames, 1);
  lang_langnames[0] :=  BaseLang;

//   str2 := expandprmacros('${LANGDIR}') + directoryseparator;

  for i := Low(ListOfFiles) to High(ListOfFiles) do
    if system.pos('empty', ListOfFiles[i]) = 0 then
    begin
       setlength(lang_langnames, length(lang_langnames) + 1);
       str1 := ListOfFiles[i];
       MOfile:= TMOfile.Create (LangDir{str2}+str1);
       str1 := MOfile.Translate (BaseLang);
       //writeln(str1);
       lang_langnames[length(lang_langnames) - 1] := trim(str1);
       MOfile.Destroy;
    end;
end;
*)

PROCEDURE translate_stock (VAR lang_stocktext, default_stocktext: msestringarty;
                           MOfile: TMOfile);
VAR
  x: integer;
  astrt: mseString;
BEGIN
   SetLength (lang_stocktext, Length (default_stocktext));

   FOR x:= 0 TO High (default_stocktext) DO BEGIN
      astrt:= MOfile.translate (default_stocktext [x]);
{$ifndef no_remove_hot_chars}
      // if no translation, but original contains '&', try w/ '&' characters removed
      IF (astrt = '') AND (Pos ('&', default_stocktext [x]) <> 0) THEN
        astrt:= MOfile.translate (StringReplace (default_stocktext [x], '&',  '', [rfReplaceAll]));

      // if no translation still, try w/ default upper cased
      IF (astrt = '') AND (Pos ('&', default_stocktext [x]) <> 0) THEN
        astrt:= MOfile.translate (uppercase (StringReplace (default_stocktext [x], '&',  '', [rfReplaceAll])));

      // if translated but original doesn't contain '&', remove from translation too
      IF (astrt <> '') AND (Pos ('&', default_stocktext [x]) = 0) THEN
        astrt:= {Unicode}StringReplace (astrt, '&',  '', [rfReplaceAll]);
{$endif}
      IF astrt = '' THEN astrt:= default_stocktext [x]
      ELSE BEGIN
        astrt:= {Unicode}StringReplace (astrt, ',',  '‚', [rfReplaceAll]);
        astrt:= {Unicode}StringReplace (astrt, #039, '‘', [rfReplaceAll]);
      END;
      lang_stocktext [x]:= astrt;
   END;
END;

PROCEDURE buildlangtext (VAR LocalisationArea: Localisator);
 VAR
   i, x: integer;
 BEGIN
    FOR x:= 0 TO pred (Length (LocalisationReference)) DO BEGIN
      SetLength (LocalisationArea [x], length (LocalisationReference [x]));
      FOR i:= Low (LocalisationReference [x]) to High (LocalisationReference [x]) DO
        LocalisationArea [x][i]:= LocalisationReference [x][i];
    END;
 END;

PROCEDURE createnewlang (alang: msestring);
 VAR
   x:               integer;
   currentLangFile: msestring;
   MOfile:          TMOfile;
 BEGIN
   // Patterns of language file names are:
   // - for "standard" location (below applications directory):
   //   LangDir = ExtractFilePath (ParamStr (0))+ LangDir+ directoryseparator+ Appname+ alang+ LangExt;
   // - for files residing in Linux' system locale repository:
   //   LangDir = "/usr/share/locale/"+ alang+ "/LC_MESSAGES"+ directoryseparator+ Appname+ LangExt;
   // Different formats handled through "variable replacement"
   // - Variable "LangPath"; Contains complete path of language file w/ place holders for variables,
   //                        "Standard":   <applcation dirextory>/$Appname_$Language.<LangExt>
   //                        Linux system: /usr/share/locale/$Language/LC_MESSAGES/$Appname.<LangExt>
   // - Variable "Appname";  Content like currently
   // - Variable "Language"; Contains current "alang"
   // Variables can be replaced by fpc's StrUtils function "StringReplace"
   // Pattern of "LangPath" can determine search function required,
   //   decided e.g. by occurrence of substring "LC_MESSAGES"

   IF assigned (customsetLangFilePattern) THEN LangDir:= customsetLangFilePattern ();
   x:= System.Pos (LangFlag, LangDir);

   IF x > 0 THEN BEGIN
     Appname:= Copy (LangDir, succ (x), Length (LangDir));
     System.Delete (LangDir, x, Length (LangDir));
     x:= High (LangDir);

     WHILE (x > 0) AND (LangDir [x] <> directoryseparator) DO Dec (x);
     IF x < High (LangDir) THEN BEGIN
       Appname:= Copy (LangDir, succ (x), Length (LangDir));
       System.Delete (LangDir, succ (x), Length (LangDir));
     END;
   END;
{$ifdef Linux}
   IF System.Pos (LinuxFlag, LangDir+ Appname) <> 0  // Linux System
     THEN currentLangFile := LangDir+ alang+ Appname+ LangExt
     ELSE currentLangFile := LangDir+ Appname+ alang+ LangExt;
{$endif}

//  writeln(currentLangFile);

   IF (Trim (alang) = '') OR {(lowercase (alang) = BaseLang) OR} (NOT FileExists (currentLangFile))
   THEN BEGIN
     buildlangtext (LocalisationActive);
   END
   ELSE IF FileExists (currentLangFile) THEN BEGIN
     MOfile:= TMOfile.Create (currentLangFile);

     FOR x:= 0 TO pred (Length (LocalisationReference)) DO
       translate_stock (LocalisationActive [x], LocalisationReference [x], MOfile);

     MOfile.Destroy;
   END;
   lang_langnames:= findmofiles;

   lang_modalresult:=           getApplicationLanguage (ModalresultArea);
   lang_modalresultnoshortcut:= getApplicationLanguage (ModalresultnoShortcutArea);
   lang_stockcaption:=          getApplicationLanguage (StockcaptionArea);
   lang_extended:=              getApplicationLanguage (ExtendedArea);

   IF assigned (realizeApplicationLanguages) THEN realizeApplicationLanguages;
 END;

INITIALIZATION
  Appname:= lowercase (ChangeFileExt (ExtractFileName (ParamStr (0)), '_'));
  LangDir:= ExtractFilePath (ParamStr (0))+ LangDir+ directoryseparator;

  LocalisationReference:= Localisator.Create (en_modalresulttext, en_modalresulttextnoshortcut,
                                              en_stockcaption, en_extendedtext);
  LocalisationActive:=    Localisator.Create (en_modalresulttext, en_modalresulttextnoshortcut,
                                              en_stockcaption, en_extendedtext);
END.
