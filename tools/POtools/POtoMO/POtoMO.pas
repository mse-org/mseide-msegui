UNIT POtoMO;
{$mode objfpc}
{$LONGSTRINGS ON}

// By Sieghard 2022

INTERFACE

USES
  SysUtils, msetypes, StrUtils, Classes, StreamIO;

TYPE
  MOhead = RECORD
             Magic,
             Version: longword;
             Count,
             IDtable,
             TxTable: longword;
             HashSize,
             HashPos: longword;
           END;

  MOentry = RECORD
              Length,
              Offset: longword;
            END;

  MOtable =   ARRAY OF MOentry;
  HashArray = ARRAY OF longword;

  LogProcedure = PROCEDURE (Msg: string);

  MObuilder = CLASS
              PRIVATE
                MOheader:  MOhead;
                IDentry,
                TxEntry:   MOtable;
                HashEntry: HashArray;
                po2moerror,
                IDs, Msgs: TStringList;
                ErrLog:    LogProcedure;

                FUNCTION  HashSpace      (Entries: integer): integer;
                FUNCTION  parsed         (InString: String): String;
                PROCEDURE BuildHashtable (VAR Hashes: HashArray);
                PROCEDURE ErrLogger      (l: integer; Msg: string);
              PUBLIC
                // Create object & initalize data structures
                CONSTRUCTOR Create;
                // Parse PO file contents & build neccessary data structures
                PROCEDURE POparse (POstream: TStream);
                PROCEDURE POparse (CONST POfilename: String);
                // Output MO file built from previously parsed data structures
                PROCEDURE MOwrite (MOstream: TStream);
                PROCEDURE MOwrite (CONST MOfilename: String);
                // Read named PO file, build data structures & write out MO file w/ equivalent name
                PROCEDURE MObuild (POfilename: String);

                PROPERTY LogError: LogProcedure READ ErrLog WRITE ErrLog;
                PROPERTY Errors:   TStringList  READ po2moerror;
              END;
              
IMPLEMENTATION

TYPE
  MsgType = (isNot, isID, isStr);
  StringArray = ARRAY OF String;

CONST
  MOmagic = $950412DE;
  MOversion =       0;

  Comment =       '#';  // Comment lead in character in .po files
  Quote =         '"';  // String continuation character
  MsgStart =      'm';  // PROBABELY start of a msg specification entry
  MsgID =    'msgid ';
  MsgStr =  'msgstr ';
  EscapeSeqs:  StringArray = ('\n', '\r', '\f', '\b', '\t', '\e', '\0', '\\', '\"');
  Escapeds:    StringArray = (#10, #13, #12, #8, #9, #27, #0, '\', '"');
  
FUNCTION MObuilder.HashSpace (Entries: integer): integer;
 BEGIN
   Result:= succ (4* Entries) DIV 3;
   IF (Result MOD 2) = 0 THEN Inc (Result);
 END;

FUNCTION MObuilder.parsed (InString: String): String;
 BEGIN
   parsed:= StringsReplace (InString, EscapeSeqs, Escapeds, [rfReplaceAll, rfIgnoreCase]);
 END;

PROCEDURE MObuilder.BuildHashtable (VAR Hashes: HashArray);
 VAR
   i, n, h, l,
   SkipSize: longword;
   HashSet:  HashArray;
 BEGIN
   SetLength (HashSet, Length (Hashes));          // Create de-duplication store
   FOR i:= 0 TO High (IDentry) DO BEGIN
     h:= Hash (IDs [i]);

     IF h = longword (-1) THEN Hashes [0]:= succ (i)   // insert in first position
     ELSE BEGIN
       SkipSize:= succ (h MOD (Length (Hashes)- 2));
       n:= h MOD Length (Hashes);

       IF (0 < n) AND (n < Length (Hashes)) AND (Hashes [n] = 0) THEN BEGIN
         Hashes [n]:= succ (i);                   // direct insertion possible
         HashSet [n]:= h;                         // and remember item used
       END
       ELSE BEGIN                                 // need overflow handling
         REPEAT                                   // find suitable free position
           IF n >= (Length (Hashes)- SkipSize)
             THEN Dec (n, Length (Hashes)- SkipSize)
             ELSE Inc (n, SkipSize);
         UNTIL (0 < n) AND (n < Length (Hashes)) AND ((Hashes [n] = 0) OR (HashSet [n] = h));
         IF Hashes [n] = 0 THEN BEGIN             // If not a duplicate
           Hashes [n]:= succ (i);                 // insert overflow
           HashSet [n]:= h;                       // and remember item used
         END;
       END (* ELSE *);
     END (* ELSE *);
   END (* FOR i:= 0 TO High (IDentry) *);
 END;


CONSTRUCTOR MObuilder.Create;
 BEGIN
   INHERITED;
   WITH MOheader DO BEGIN
     Magic:= MOmagic; Version:= MOversion;
     Count:= 0; IDtable:= SizeOf (MOhead); TxTable:= 0;
     HashSize:= 0; HashPos:= 0;
   END (* WITH MOheader *);
 END;


PROCEDURE MObuilder.ErrLogger (l: integer; Msg: string);
 BEGIN
   IF assigned (ErrLog) THEN ErrLog (Format ('%4d: ', [l])+ Msg)
   ELSE po2moerror.add (Format ('%4d: ', [l])+ Msg);
 END;


PROCEDURE MObuilder.POparse (POstream: TStream);
 VAR
   skipdup: boolean;
   i, n, l: integer;
   MsgKind: MsgType;
   InpLine: String;
   POfile:  TextFile;
 BEGIN
   AssignStream (POfile, POstream); Reset (POfile);
   po2moerror:= TStringList.Create;
   IDs:= TStringList.Create; l:= 0;
   WITH IDs DO BEGIN
     sorted:= true; CaseSensitive:= true; Duplicates:= dupError{Ignore};
   END (* WITH IDs *);
   Msgs:=TStringList.Create;  Msgs.sorted:= false; n:= 0; MsgKind:= isNot;
   skipdup:= false;

   WHILE NOT EoF (POfile) DO BEGIN
     ReadLn (POfile, InpLine); InpLine:= Trim (InpLine); Inc (l);

     IF InpLine <> '' THEN BEGIN
       CASE InpLine [1] OF
         Comment: { ignored };

         Quote:   { string continuation }
           BEGIN
             CASE MsgKind OF
               isNot: { ignored };
               isID:
                 BEGIN
                   InpLine:= Copy (InpLine, 2, Length (InpLine)- 2);
                   IF IDs.Count <> 0 THEN
                     TRY
                       // IDs [n]:= IDs [n]+ parsed (InpLine);
                       i:= n;
                       InpLine:= IDs [n]+ parsed (InpLine);
                       IDs.delete (n); n:= IDs.add (InpLine);
                       InpLine:= Msgs [i]; Msgs.delete (i);
                       Msgs.insert (n, InpLine);
                     EXCEPT
                       ON e: EXCEPTION DO
                         ErrLogger (l, e.Message);
                     END
                   ELSE ErrLogger (l, 'MsgID continuation found w/o MsgID: "'+ InpLine+ '"');
                 END (* isID *);
               isStr:
                 IF NOT skipdup THEN BEGIN
                   InpLine:= Copy (InpLine, 2, Length (InpLine)- 2);
                   IF Copy (InpLine, 1, 12) <> 'POT-Creation' THEN
                   IF IDs.Count <> 0 THEN
                     TRY
                       Msgs [n]:= Msgs [n]+ parsed (InpLine);
                     EXCEPT
                       ON e: EXCEPTION DO
                         ErrLogger (l, e.Message);
                     END
                   ELSE ErrLogger (l, 'MsgStr continuation found w/o MsgID: "'+ InpLine+ '"');
                 END (* isID *);
             END (* CASE MsgKind *);
           END (* Quote: *);

         MsgStart:
           BEGIN  // Probabely .po description, gather lines and save in array
             IF Copy (InpLine, 1, Length (MsgId)) = MsgId THEN BEGIN
               MsgKind:= isID; i:= Pos (Quote, InpLine);
               InpLine:= parsed (Copy (InpLine, succ (i), pred (Length (InpLine)- i)));
               TRY
                 n:= IDs.add (InpLine);
                 skipdup:= false;
               EXCEPT
                 ON EStringListError DO BEGIN
                   skipdup:= true;
                   ErrLogger (l, 'Duplicate MsgID found: "'+ InpLine+ '"');
                 END (* ON EStringListError *);
               END (* TRY *);
             END (* IF Copy (InpLine, 1, Length (MsgId)) ... *)
             ELSE IF Copy (InpLine, 1, Length (MsgStr)) = MsgStr THEN BEGIN
               MsgKind:= isStr;
               IF NOT skipdup THEN BEGIN
                 i:= Pos (Quote, InpLine);
                 InpLine:= parsed (Copy (InpLine, succ (i), pred (Length (InpLine)- i)));
                 IF IDs.Count <> 0 THEN
                   TRY
                     Msgs.Insert (n, InpLine);
                   EXCEPT
                     ON e: EXCEPTION DO
                       ErrLogger (l, e.Message);
                   END
                 ELSE ErrLogger (l, 'MsgStr found w/o MsgID: "'+ InpLine+ '"')
               END (* IF NOT skipdup *);
             END (* IF Copy (InpLine, 1, Length (MsgStr)) ... *)
             { ELSE perhaps more, but ignored for now };
           END (* MsgStart: *);

         ELSE     { something different but unknown, ignore? };
       END (* CASE InpLine [1] *);
     END (* IF InpLine [1] <> '' *);
   END (* WHILE NOT EoF (POfile) *);

   SetLength (IDentry, IDs.Count); SetLength (TxEntry, IDs.Count);
   WITH MOheader DO BEGIN
     Count:= Length (IDentry);
     HashSize:= HashSpace (Count);
     TxTable:= IDtable+ Length (IDentry)* SizeOf (MOentry);
     HashPos:= TxTable+ Length (TxEntry)* SizeOf (MOentry);
     IDentry [0].Offset:= HashPos+ HashSize* SizeOf (longword);
   END (* WITH MOheader *);

   FOR i:= 0 TO pred (High (IDentry)) DO BEGIN
     IDentry [i].Length:= Length (IDs [i]);
     IDentry [succ (i)].Offset:= IDentry [i].Offset+ succ (IDentry [i].Length);
   END (* FOR i:= 0 TO pred (High (IDentry)) *);
   IDentry [High (IDentry)].Length:= Length (IDs [High (IDentry)]);

   WITH IDentry [High (IDentry)] DO TxEntry [0].Offset:= Offset+ succ (Length);
   FOR i:= 0 TO pred (High (TxEntry)) DO BEGIN
     TxEntry [i].Length:= Length (Msgs [i]);
     TxEntry [succ (i)].Offset:= TxEntry [i].Offset+ succ (TxEntry [i].Length);
   END (* FOR i:= 0 TO pred (High (TxEntry)) *);

   TxEntry [High (TxEntry)].Length:= Length (Msgs [High (TxEntry)]);
   FOR i:= 0 TO pred (High (TxEntry)) DO BEGIN
     TxEntry [i].Length:= Length (Msgs [i]);
     TxEntry [succ (i)].Offset:= TxEntry [i].Offset+ succ (TxEntry [i].Length);
   END (* FOR i:= 0 TO pred (High (TxEntry)) *);

   SetLength (HashEntry, Moheader.HashSize);
   BuildHashtable (HashEntry);
 END (* POparse *);

PROCEDURE MObuilder.POparse (CONST POfilename: String);
 VAR
   POstream: TStream;
 BEGIN
   POstream:= TFileStream.Create (POfilename, fmOpenRead);
   TRY
     POparse (POstream);
   FINALLY
     POstream.Free;
   END;
 END (* MOwrite *);


PROCEDURE MObuilder.MOwrite (MOstream: TStream);
 VAR
   i:      integer;
   Str:    String;
 BEGIN
   MOstream.Write (MOheader, SizeOf (MOhead));

   FOR i:= 0 TO High (IDentry) DO
     MOstream.Write (IDentry [i],  SizeOf (MOentry));

   FOR i:= 0 TO High (TxEntry) DO
     MOstream.Write (TxEntry [i],  SizeOf (MOentry));

   FOR i:= 0 TO High (HashEntry) DO
     MOstream.Write (HashEntry [i],  SizeOf (longword));

   FOR i:= 0 TO High (IDentry) DO BEGIN
     Str:= IDs [i]+ chr (0);
     MOstream.Write (Str [1],  Length (Str));
   END (* FOR i:= 0 TO High (IDentry) *);

   FOR i:= 0 TO High (TxEntry) DO BEGIN
     Str:= Msgs [i]+ chr (0);
     MOstream.Write (Str [1],  Length (Str));
   END (* FOR i:= 0 TO High (TxEntry) *);
 END (* MOwrite *);

PROCEDURE MObuilder.MOwrite (CONST MOfilename: String);
 VAR
   MOstream: TStream;
 BEGIN
   MOstream:= TFileStream.Create (MOfilename, fmCreate OR fmOpenWrite OR fmShareExclusive);
   TRY
     MOwrite (MOstream);
   FINALLY
     MOstream.Free;
   END;
 END (* MOwrite *);


PROCEDURE MObuilder.MObuild (POfilename: String);
 VAR
   PMOstream: TStream;
 BEGIN
   PMOstream:= TFileStream.Create (POfilename, fmOpenRead);
   TRY
     POparse (PMOstream);
   FINALLY
     PMOstream.Free;
   END;

   POfilename [pred (Length (POfilename))]:= 'm';
   PMOstream:= TFileStream.Create (POfilename, fmCreate OR fmOpenWrite OR fmShareExclusive);
   TRY
     MOwrite (PMOstream);
   FINALLY
     PMOstream.Free;
   END;
 END (* MOwrite *);

END.
