UNIT fontlist;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
{$ifdef unix}

INTERFACE

USES
  CThreads, CWString, SysUtils, StrUtils, Classes, MClasses, msegraphutils, Process;

FUNCTION FontsList (forLanguage: string = ''): TStringList;
FUNCTION FontPropertiesList (forLanguage: string = ''; consistentNaming: boolean = false): TStringList;

FUNCTION FontStyle (Styles: String): FontStylesTy;


IMPLEMENTATION


USES
  DynLibs,
  msetypes, mseclasses{, msegraphutils}, mserichstring, msestrings;


TYPE
  // Only internelly used
  FcRequestKind = (Fc_Family, Fc_Style, Fc_Slant, Fc_Weight, Fc_Size);
  FcRequestSet = SET OF FcRequestKind;

{$ifdef useLibFontConfig}
CONST
  PtrArrayLimit = 200000000;  //?? Not really used anyhow

TYPE
  FcConfig = RECORD
  // unspecified structure, usually NULL as a parameter
  END;

  FcConfigPtr = ^FcConfig;

  FcPattern = RECORD
  // unspecified structure, to be built by special functions
  END;

  FcPatternPtr = ^FcPattern;

  FcFontSet = RECORD
    nfont,
    sfont: integer;
    fonts: ^FcPatternPtr;
  END;

  FcFontsetPtr = ^FcFontset;

  PCharArray = ARRAY [0..PtrArrayLimit] OF PChar;

  FcObjectSet = RECORD
    nobject,
    sobject: integer;
    objects: ^PCharArray;
  END;

  FcObjectSetPtr = ^FcObjectSet;

  FcNameParseFunc =        FUNCTION  (CONST name: PChar): FcPatternPtr; CDecl;
  FcObjectSetCreateFunc =  FUNCTION: FcObjectSetPtr; CDecl;
  FcObjectSetAddFunc =     FUNCTION  (os: FcObjectSetPtr; CONST addobject: PChar): boolean; CDecl;
  FcFontListFunc =         FUNCTION  (config: FcConfigPtr; p: FcPatternPtr; os: FcObjectSetPtr): FcFontsetPtr; CDecl;
  FcPatternFormatFunc =    FUNCTION  (pat: FcPatternPtr; CONST format: PChar): PChar; CDecl;
  FcObjectSetDestroyProc = PROCEDURE (os: FcObjectSetPtr); CDecl;
  FcPatternDestroyProc =   PROCEDURE (pat: FcPatternPtr); CDecl;
  FcFontSetDestroyProc =   PROCEDURE (os: FcFontSetPtr); CDecl;
{$endif}

CONST
{$ifndef useLibFontConfig}
  Lister =    'fc-list';
  BaseDir = '/usr/bin/';
  LocalDir =   'local/';
{$endif}
  StyleMark =       '=';
  ListMark =        ';';

  ListRequest =            ':';
  LangRequest =        'lang=';
{$ifndef useLibFontConfig}
  FormatRequest =  '--format=';
{$else}
  FCLibraryName = 'libfontconfig.so';
{$endif}
  NameRequest = '%{family[0]}';
  StyleRequest = '%{style[0]}';

  BoldMark:   ARRAY OF string = ('bold', 'black', 'heavy', 'fett', 'halbfett', 'bolditalic', 'fettkursiv');
  ItalicMark: ARRAY OF string = ('italic', 'oblique', 'cursive', 'kursiv', 'bolditalic', 'fettkursiv');

{$ifdef useLibFontConfig}
VAR
   FcNameParse:        FcNameParseFunc;
   FcObjectSetCreate:  FcObjectSetCreateFunc;
   FcObjectSetAdd:     FcObjectSetAddFunc;
   FcFontList:         FcFontListFunc;
   FcPatternFormat:    FcPatternFormatFunc;
   FcObjectSetDestroy: FcObjectSetDestroyProc;
   FcPatternDestroy:   FcPatternDestroyProc;
   FcFontSetDestroy:   FcFontSetDestroyProc;
{$endif}

FUNCTION requestFontList (RequestKind: FcRequestSet; forLanguage: string = ''): string;
 VAR
   Request: string;
{$ifndef useLibFontConfig}
   comstr:  string;
{$else}
   i:       integer;
   FcLib:   TLibHandle;
   Fontset: FcFontsetPtr;
   Pattern: FcPatternPtr;
   ObjSet:  FcObjectSetPtr;
{$endif}

 BEGIN
{$ifndef useLibFontConfig}
   comstr:= BaseDir+ Lister;
   IF NOT FileExists (comstr) THEN BEGIN
     comstr:= BaseDir+ LocalDir+ Lister;
     IF NOT FileExists (comstr) THEN comstr:= '';
   END;

   IF comstr <> '' THEN BEGIN
     // fc-list : family style fontformat scalable decorative symbol
     // "%{file|basename|cescape}" "%{-file{%{=unparse|cescape}}}" %{file:-<unknown filename>|basename}: 
     // "%{family[0]:-<unknown family>}" "%{style[0]:-<unknown style>}"

     IF Fc_Style IN RequestKind
       THEN Request:= FormatRequest+ NameRequest+ StyleMark+ StyleRequest+ LineEnd
       ELSE Request:= FormatRequest+ NameRequest+ LineEnd;

     IF forLanguage <> '' THEN forLanguage:= LangRequest+ forLanguage;
     RunCommand (comstr, [ListRequest+ forLanguage, Request], Result);
   END;
{$else}
   FcLib:= LoadLibrary (FCLibraryName);
   IF FcLib = NilHandle THEN Result:= ''
   ELSE BEGIN
     FcNameParse:=        FcNameParseFunc        (GetProcedureAddress (FcLib, 'FcNameParse'));
     FcObjectSetCreate:=  FcObjectSetCreateFunc  (GetProcedureAddress (FcLib, 'FcObjectSetCreate'));
     FcObjectSetAdd:=     FcObjectSetAddFunc     (GetProcedureAddress (FcLib, 'FcObjectSetAdd'));
     FcFontList:=         FcFontListFunc         (GetProcedureAddress (FcLib, 'FcFontList'));
     FcPatternFormat:=    FcPatternFormatFunc    (GetProcedureAddress (FcLib, 'FcPatternFormat'));
     FcObjectSetDestroy:= FcObjectSetDestroyProc (GetProcedureAddress (FcLib, 'FcObjectSetDestroy'));
     FcPatternDestroy:=   FcPatternDestroyProc   (GetProcedureAddress (FcLib, 'FcPatternDestroy'));
     FcFontSetDestroy:=   FcFontSetDestroyProc   (GetProcedureAddress (FcLib, 'FcFontSetDestroy'));

//// Test only:     WriteLn ('Fontconfig initialized: ', FcInit, ' # ', RequestKind);

     Result:= ''; Pattern:= NIL; ObjSet:= NIL; Fontset:= NIL;  // New (FcFontsetPtr);

     IF forLanguage = ''
       THEN forLanguage:= ListRequest
       ELSE forLanguage:= ListRequest+ LangRequest+ forLanguage;

     Pattern:= FcNameParse (PChar (forLanguage));
     ObjSet:= FcObjectSetCreate (); FcObjectSetAdd (ObjSet, 'family');

     IF Fc_Style IN RequestKind THEN BEGIN
       FcObjectSetAdd (ObjSet, 'style'); 
       Request:= NameRequest+ StyleMark+ StyleRequest+ LineEnd;
     END
     ELSE Request:= NameRequest+ LineEnd;

     Fontset:= FcFontList (NIL, Pattern, ObjSet);
     FcObjectSetDestroy (ObjSet); FcPatternDestroy (Pattern);

     WITH Fontset^ DO
       FOR i:= 0 TO pred (nfont) DO
         Result:= Result+ FcPatternFormat (fonts [i], PChar (Request));

     FcFontSetDestroy (Fontset); UnloadLibrary (FcLib);
   END;
{$endif}
 END;

FUNCTION requestFontsOnly (forLanguage: string = ''): TStringList;
 BEGIN
   Result:= TStringList.create;
   Result.Sorted:= True;
   Result.Duplicates:= dupIgnore;
   Result.Text:= requestFontList ([Fc_Family], forLanguage);

   IF Result.Count <> 0 THEN BEGIN
// Test only:     FOR n:= 0 TO pred (Result.count) DO WriteLn (Result [n]);
// Test only:     writeln (LineEnd, '*** TStringList ', Result.count, ' entries');
   END
   ELSE BEGIN
     FreeAndNil (Result);
// Test only:     WriteLn ('Sorry, ', Lister, ' not found - no Fonts available!');
   END;
 END;

FUNCTION requestFontsProperties (forLanguage: string = ''; consistentNaming: boolean = false): TStringList;
 VAR
   n, l, x: integer;
   m, s,
   fn, sm:  string;
   Fonts:   TStringList;

 BEGIN
   Fonts:= TStringList.create;
   Fonts.Text:= requestFontList ([Fc_Family, Fc_Style], forLanguage);

   IF Fonts.Count <> 0 THEN BEGIN
     Result:= TStringList.create;
     Result.Sorted:= True;
     Result.Duplicates:= dupIgnore;

     FOR x:= 0 TO pred (Fonts.Count) DO BEGIN      // Scan resulting list, separate individual fonts
       fn:= Fonts [x];
       l:= System.Pos (StyleMark, fn);

       IF l = 0 THEN sm:= ''          // Get style value, possibly empty
       ELSE BEGIN
         sm:= System.Copy (fn, succ (l), Length (fn));
         SetLength (fn, pred (l));

         IF consistentNaming THEN BEGIN
           // Coerce style markers to consistent names
           sm:= lowercase (sm); m:= ''; n:= 1;
           REPEAT
             s:= ExtractWord (n, sm, [' ']); Inc (n);
             IF s <> '' THEN BEGIN
               // BOTH markings CAN apply! (E.g. "bolditalic")
               IF s IN BoldMark   THEN s:= BoldMark [0];
               IF s IN ItalicMark THEN s:= ItalicMark [0];
               IF m = ''
                 THEN m:= s
                 ELSE m:= m+ ' '+ s;
             END;
           UNTIL s = '';
           sm:= m;
         END;
       END;

       n:= Result.IndexOfName (fn);   // Font already registered?
       IF n < 0 THEN BEGIN            // No, add along w/ style
         fn:= fn+ StyleMark+ sm;
       END
       ELSE BEGIN                     // Yes, possibly add new style and remove from list
         IF System.Pos (sm+ ListMark, Result.ValueFromIndex [n]+ ListMark) = 0
         THEN BEGIN
           fn:= Result [n]+ ListMark+ sm;
           Result.delete (n); n:= -1;
         END;
       END;
       IF n < 0 THEN Result.add (fn); // (Possibly re-) add entry to list
     END;
     FreeAndNil (Fonts);

// Test only:     FOR n:= 0 TO pred (Result.count) DO WriteLn (Result [n]);
// Test only:     writeln (LineEnd, '*** TStringList ', Result.count, ' entries');
   END
   ELSE BEGIN
     Result:= NIL;
// Test only:     WriteLn ('Sorry, ', Lister, ' not found - no Fonts available!');
   END;
 END;


FUNCTION FontsList (forLanguage: string = ''): TStringList;
 BEGIN
   Result:= requestFontsOnly (forLanguage);
 END;

FUNCTION FontPropertiesList (forLanguage: string = ''; consistentNaming: boolean = false): TStringList;
 BEGIN
   Result:= requestFontsProperties (forLanguage, consistentNaming);
 END;


FUNCTION FontStyle (Styles: String): FontStylesTy;
 VAR
   n: integer;
   s: string;
 BEGIN
   Styles:= lowercase (Styles);
   n:= 1; Result:= [];
   REPEAT
     s:= ExtractWord (n, Styles, [' ']); Inc (n);
     IF s <> '' THEN BEGIN
       // BOTH markings CAN apply! (E.g. "bolditalic")
       IF s IN BoldMark   THEN include (Result, fs_bold);
       IF s IN ItalicMark THEN include (Result, fs_italic);
     END;
   UNTIL s = '';
 END;

{$else}
INTERFACE
IMPLEMENTATION
{$endif}
END.
