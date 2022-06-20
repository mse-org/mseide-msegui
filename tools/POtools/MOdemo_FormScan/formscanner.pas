UNIT FormScanner;

{$mode objfpc}{$H+}{$inline on}

INTERFACE

USES
  Classes, SysUtils, TypInfo,
  MClasses, MSEClasses, MSETypes, MSEApplication, MSEGUI, MSEDataList, MSEActions, MSEEdit,
  MSEForms, MSEDock, MSEMenus, MSEDataModules, MSEStringContainer, MSEsimpleWidgets, MSEWidgets;


TYPE
  AppChecker = CLASS Helper for TGUIApplication
    FUNCTION CreateFormEx (InstanceClass: WidgetClassty; VAR Reference): TWidget;
    FUNCTION CreateDataModuleEx (InstanceClass: MSEComponentClassty; VAR Reference): TMSEComponent;
    PROCEDURE runApplicationEx;
  END;

  FormChecker = CLASS Helper for TCustomMSEForm
    PROCEDURE getChildText (Child: TComponent);
    PROCEDURE WorkOnChilds (ChildProc: TGetChildProc);
  END;

  DockChecker = CLASS Helper for TCustomDockform
    PROCEDURE getChildText (Child: TComponent);
    PROCEDURE WorkOnChilds (ChildProc: TGetChildProc);
  END;

  MenuChecker = CLASS Helper for TCustomMenu
    PROCEDURE getChildText (Child: TComponent);
    PROCEDURE WorkOnChilds (ChildProc: TGetChildProc);
  END;

  PopupChecker = CLASS Helper for TPopupMenu
    PROCEDURE getChildText (Child: TComponent);
    PROCEDURE WorkOnChilds (ChildProc: TGetChildProc);
  END;

  ButtonChecker = CLASS Helper for TCustomButton
    PROCEDURE getChildText (Child: TComponent);
    PROCEDURE WorkOnChilds (ChildProc: TGetChildProc);
  END;

  EditChecker = CLASS Helper for TCustomEdit
    PROCEDURE getChildText (Child: TComponent);
    PROCEDURE WorkOnChilds (ChildProc: TGetChildProc);
  END;

  DataModuleChecker = CLASS Helper for TMSEDataModule
    PROCEDURE getChildText (Child: TComponent);
    PROCEDURE WorkOnChilds (ChildProc: TGetChildProc);
  END;

  StringContainerChecker = CLASS Helper for TStringContainer
    PROCEDURE getChildText (Child: TComponent);
    PROCEDURE WorkOnChilds (ChildProc: TGetChildProc);
  END;

VAR
  showitems: boolean = {$ifndef do_show_items}false{$else}true{$endif};
  verbose:   boolean = {$ifndef scan_verbose}false{$else}true{$endif};
  FormArea:  integer = 0;
  PropName:  ARRAY OF string = ('Caption', 'Hint', 'Value', 'Text', 'Frame');


// Return array of all text messages found
FUNCTION TextMessages: msestringarty;

// Return all found text items of form as a string list
FUNCTION FormItemList: TStringList;

// List out all found text items of form
PROCEDURE ListFormItems (CONST FormName: string = '');

// Translate all items found
PROCEDURE TranslateItems;


IMPLEMENTATION


USES
  mo4stock;

CONST
  MaxMsgLength = 76;
  PropCaption =   0;
  PropHint =      1;
  PropValue =     2;
  PropText =      3;
  PropFrame =     4;

TYPE
  MethodStore =  RECORD
                   Owner: TObject;
                   Which,
                   Kind:  shortint;
                 END;
  MethodLister = ARRAY OF MethodStore;
  PropLister =   ARRAY OF MethodLister;

VAR
  PropList:    PropLister;
  MessageText: msestringarty;
//->  MessageText: TStringList;
  inset: string;
  only1: boolean;


// Return array of all text messages found
FUNCTION TextMessages: msestringarty;
 BEGIN
   Result:= MessageText;
 END;

// Return all found text items of form as a string list
FUNCTION FormItemList: TStringList;
 VAR
   s: MSEString;
 BEGIN
   Result:= NIL;
   IF Length (MessageText) <> 0 THEN BEGIN
     Result:= TStringList.Create;
     FOR s IN MessageText DO Result.add (s);
   END;
 END;


// List out all found text items of form
PROCEDURE ListFormItems (CONST FormName: string = '');
 VAR
   o, p: integer;
   s:    MSEString;
 BEGIN
   IF showitems THEN BEGIN
     WriteLn ('--------');
     IF FormName <> '' THEN WriteLn ('Messages of Form "', FormName, '":');
     FOR s IN MessageText DO BEGIN
       Write ('msgid '); p:= 1; o:= Length ('msgid ');
       REPEAT
         WriteLn ('"', Copy (s, p, MaxMsgLength- o), '"');
         Inc (p, MaxMsgLength- o); o:= 0;
       UNTIL Length (s) <= p;
       WriteLn ('msgstr ""', LineEnding);
     END;
     WriteLn ('--------');
   END;
 END;


// Translate all items found
PROCEDURE TranslateItems;
 VAR
   k, n:  integer;
   Previous,
   Value: msestring;
   F:     TObject;
 BEGIN
   IF only1 THEN BEGIN
     IF verbose THEN WriteLn ('Ooooopsss....');
     Exit;
   END;
   only1:= true;

   IF verbose THEN WriteLn ('=== Translating...');

   FOR k:= 0 TO High (MessageText) DO
     IF PropList [k] <> NIL THEN
       FOR n:= 0 TO High (PropList [k]) DO
         WITH PropList [k][n] DO BEGIN
           IF verbose AND showitems THEN
             IF Owner IS Tcustomdockform THEN
               writeln ('customdockform ', Tcustomdockform (Owner).name, '/', Kind, '/', Tcustomdockform (Owner).caption)
             ELSE IF Owner IS Tcustommseform THEN
               writeln ('custommseform ', Tcustommseform (Owner).name, '/', Kind, '/', Tcustommseform (Owner).caption)
             ELSE IF Owner IS TMainMenu THEN
               writeln ('mainMenu ', TCustomMenu (Owner).name, '/', Kind, '/', Which)
             ELSE IF Owner IS TPopupMenu THEN
               writeln ('popupMenu ', TPopupMenu (Owner).name, '/', Kind, '/', Which)
             ELSE IF Owner IS TCustomMenu THEN
               writeln ('customMenu ', TCustomMenu (Owner).name, '/', Kind, '/', Which)
             ELSE IF Owner IS TMenuItem THEN
               writeln ('Menuitem ', TMenuItem (Owner).caption, '/', Kind, '/', Which)
             ELSE IF Owner IS TMenuItems THEN
               writeln ('Menuitems ', TMenuItems (Owner) [Which].caption, '/', Kind, '/', Which)
             ELSE IF Owner IS TButton THEN
               writeln ('Button ', TButton (Owner).name, '/', Kind, '/', TButton (Owner).caption)
             ELSE IF Owner IS TCustomEdit THEN
               writeln ('Edit ', TCustomEdit (Owner).name, '/', Kind, '/', TCustomEdit (Owner).frame.caption)
             ELSE IF Owner IS Tmsedatamodule THEN
               writeln ('msedatamodule ', Tmsedatamodule (Owner).name, '/', Kind)
             ELSE IF Owner IS Tstringcontainer THEN
               writeln ('stringcontainer ', Tstringcontainer (Owner).name, '/', Kind);
//             ELSE IF Owner IS Tcustomedit THEN
//               writeln ('customedit ', Tcustomedit (Owner).name);

           Value:= Trim (getApplicationString (FormArea, k));
           IF Value <> 'English' THEN BEGIN
             Value:= UnicodeStringReplace (Value, '\"', '"', [rfReplaceAll]);
             Value:= UnicodeStringReplace (Value, '\n', #10, [rfReplaceAll]);

             IF Owner IS TMenuItems THEN
               WITH Owner AS TMenuItems DO BEGIN
                 IF getPropInfo (Items [Which], PropName [Kind]) <> NIL THEN BEGIN
                   Previous:= getWideStrProp (Items [Which], PropName [Kind]);
                   IF (Value <> '') AND (Value <> Previous) THEN BEGIN
                     setWideStrProp (Items [Which], PropName [Kind], Value);
                     IF verbose THEN BEGIN
                       Write ('    Menuitem #', Which);
                       WriteLn (' "', Previous, '" >>>> "', Value, '" <<<< "', MessageText [k], '"');
                     END;
                   END;
                 END
                 ELSE
                 IF verbose THEN BEGIN
                   Write ('Menu object ');
                   IF Owner IS TComponent THEN Write ('"', TComponent (Owner).Name, '"')
                   ELSE Write ('@', IntToHex (longint (pointer (Owner))));
                   WriteLn (' for Value "', Value, '" not found!')
                 END;
               END
             ELSE IF Owner IS TStringContainer THEN
               WITH Owner AS TStringContainer DO BEGIN
                 Previous:= Trim (Strings [Which]);
                 IF (Value <> '') AND (Value <> Previous) THEN BEGIN
                   Strings [Which]:= Value;
                   IF verbose THEN BEGIN
                     Write ('    StringContainer "', TStringContainer (Owner).Name, '" [', Which, ']:');
                     WriteLn (' "', Previous, '" >>>> "', Value, '" <<<< "', MessageText [k], '"');
                   END;
                 END;
               END
             ELSE
             IF getPropInfo (Owner, PropName [Kind]) <> NIL THEN BEGIN
               Previous:= getWideStrProp (Owner, PropName [Kind]);
               IF (Value <> '') AND (Value <> Previous) THEN BEGIN
                 IF Kind = PropFrame THEN BEGIN
                   F:= getObjectProp (Owner, PropName [Kind]);
                   IF F <> NIL THEN BEGIN
                     Previous:= getWideStrProp (F, PropName [PropCaption]);
                     IF (Value <> '') AND (Value <> Previous) THEN
                       setWideStrProp (F, PropName [PropCaption], Value);
                   END;
                 END ELSE setWideStrProp (Owner, PropName [Kind], Value);
                 IF verbose THEN WriteLn ('    "', Previous, '" >>>> "', Value, '" <<<< "', MessageText [k], '"');
               END;
             END
             ELSE
             IF verbose THEN BEGIN
               Write ('Child object ');
               IF Owner IS TComponent THEN Write ('"', TComponent (Owner).Name, '"')
               ELSE Write ('@', IntToHex (longint (pointer (Owner))));
               WriteLn (' for Value "', Value, '" not found!')
             END;
           END;
         END;

   Application.ProcessMessages;
   IF verbose THEN WriteLn ('=== Translation done.');
   only1:= false;
 END;

///////////////////////////////////////////
PROCEDURE AddItem (VAR List: msestringarty; Prop: integer; CONST Child: TObject; Value: msestring; Index: integer = -1);
 VAR
   n, m: integer;

 FUNCTION isMacro (tocheck: msestring): boolean;
  BEGIN
    Result:= (Copy (tocheck, 1, 2) = '${') AND (tocheck [Length (tocheck)] = '}');
  END;

 BEGIN
   Value:= Trim (Value);
   IF (Value = '') OR           // Empty strings are ignored
      (isMacro (Value)) {OR     // Macros may not  be translated
      (Value = 'English')}      // Language caption --- ????
   THEN Exit;

   IF Value <> '' THEN BEGIN
     Value:= UnicodeStringReplace (Value, '"', '\"', [rfReplaceAll]);
     Value:= UnicodeStringReplace (Value, #10, '\n', [rfReplaceAll]);

     IF Child <> NIL THEN BEGIN                        // Otherwise not a component Child...
       n:= Length (List);                              // Deduplication:
       REPEAT
         Dec (n);                                      // Scan currently registered strings
       UNTIL (n < 0) OR (Value = List [n]);            // Until equal or none found
       IF n < 0 THEN BEGIN                             // Enter new string only if not registered yet
         n:= Length (List);                            // Get current end of language string list
         SetLength (List, succ (n)); List [n]:= Value; // Add new entry into language string list
         SetLength (PropList, succ (n));               // And to reference list
         SetLength (PropList [n], 1);                  // Create new list array
         WITH PropList [n][0] DO BEGIN                 // Set to current reference data
           Owner:= Child; Which:= Index; Kind:= Prop;
         END;
       END
       ELSE BEGIN                                      // String already there, add new reference
         m:= Length (PropList [n]);
         REPEAT                                        // Try to find same data
           Dec (m);                                    // Scan currently registered regerenced
         UNTIL (m < 0) OR                              // Until no more or one found
               ((PropList [n][m].Owner = Child) AND (PropList [n][m].Kind = Prop));

         IF m < 0 THEN BEGIN                           // Add new reference entry
           SetLength (PropList [n], succ (Length (PropList [n])));
           WITH PropList [n][High (PropList [n])] DO BEGIN
             Owner:= Child; Which:= Index; Kind:= Prop;
           END;
         END;
       END;
     END;
   END;
 END;
///////////////////////////////////////////
///////////////////////////////////////////
PROCEDURE FormChecker.WorkOnChilds (ChildProc: TGetChildProc);
 BEGIN
   IF verbose THEN WriteLn ('': 4, 'TopComponent Form: "', ModuleClassname, '"');
   ChildProc (self);
 END;
///////////////////////////////////////////
PROCEDURE FormChecker.getChildText (Child: TComponent);
 VAR
   Prop:  integer;
   Value: MSEString;
   Frame: TCaptionFrame;
 BEGIN
   IF NOT assigned (Child) THEN WriteLn ('!!!! FormChecker found unassigned child!')
   ELSE IF Child IS TCustomDockform THEN TCustomDockform (Child).getChildText (Child)
   ELSE IF Child IS TPopupMenu THEN TPopupMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomMenu THEN TCustomMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomButton THEN TCustomButton (Child).getChildText (Child)
   ELSE IF Child IS TCustomEdit THEN TCustomEdit (Child).getChildText (Child)
   ELSE IF Child IS TMSEDataModule THEN TMSEDataModule (Child).getChildText (Child)
   ELSE IF Child IS TStringContainer THEN TStringContainer (Child).getChildText (Child)
   ELSE BEGIN
     IF verbose THEN BEGIN
       IF Child IS TCustomMSEForm THEN WriteLn (inset, ' Child form "', Child.Name, '"')
       ELSE IF Child IS TAction THEN WriteLn (inset, ' Child action "', Child.Name, '"')
       ELSE WriteLn (inset, ' Child component "', Child.Name, '"');
       inset:= '++';
     END;

     FOR Prop:= 0 TO pred (High (PropName)) DO BEGIN
       IF getPropInfo (Child, PropName [Prop]) <> NIL THEN BEGIN
         Value:= getWideStrProp (Child, PropName [Prop]);
         IF Value <> '' THEN AddItem (MessageText, Prop, TObject (Child), Value);
       END;
     END;

     IF getPropInfo (Child, 'frame') <> NIL THEN BEGIN
       Frame:= TCaptionFrame (getObjectProp (Child, 'frame'));

       IF assigned (Frame) AND (getPropInfo (Frame, 'caption') <> NIL) THEN BEGIN
         Value:= Frame.Caption;
         IF Value <> '' THEN BEGIN
           AddItem (MessageText, PropFrame, TObject (Child), Frame.Caption);
           IF verbose THEN WriteLn (inset, '++ Child frame caption "', Frame.Caption, '"');
         END;
       END;
     END;

     WITH Child DO
       IF ComponentCount > 0 THEN getchildren (@getChildText, self);
   END;
 END;
///////////////////////////////////////////
///////////////////////////////////////////
PROCEDURE DockChecker.WorkOnChilds (ChildProc: TGetChildProc);
 BEGIN
   IF verbose THEN WriteLn ('': 4, 'TopComponent Dock: "', ModuleClassname, '"');
   ChildProc (self);
 END;
///////////////////////////////////////////
PROCEDURE DockChecker.getChildText (Child: TComponent);
 VAR
   Prop:  integer;
   Value: MSEString;
   Frame: TGripFrame;
 BEGIN
   IF NOT assigned (Child) THEN WriteLn ('!!!! DockChecker found unassigned child!')
   ELSE IF Child IS TPopupMenu THEN TPopupMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomMenu THEN TCustomMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomButton THEN TCustomButton (Child).getChildText (Child)
   ELSE IF Child IS TCustomEdit THEN TCustomEdit (Child).getChildText (Child)
   ELSE IF Child IS TMSEDataModule THEN TMSEDataModule (Child).getChildText (Child)
   ELSE IF Child IS TStringContainer THEN TStringContainer (Child).getChildText (Child)
   ELSE BEGIN
     IF verbose THEN BEGIN
       IF Child IS TCustomDockform THEN WriteLn (inset, ' Child dock "', Child.Name, '"')
       ELSE IF Child IS TAction THEN WriteLn (inset, ' Child action "', Child.Name, '"')
       ELSE WriteLn (inset, ' Child component "', Child.Name, '"');
       inset:= '++';
     END;

     FOR Prop:= 0 TO pred (High (PropName)) DO
       IF getPropInfo (Child, PropName [Prop]) <> NIL THEN BEGIN
         Value:= getWideStrProp (Child, PropName [Prop]);
         IF Value <> '' THEN AddItem (MessageText, Prop, TObject (Child), Value);
       END;

     IF getPropInfo (Child, 'frame') <> NIL THEN BEGIN
       Frame:= TGripFrame (getObjectProp (Child, 'frame'));

       IF assigned (Frame) AND (getPropInfo (Frame, 'caption') <> NIL) THEN BEGIN
         Value:= Frame.Caption;
         IF Value <> '' THEN BEGIN
           AddItem (MessageText, PropFrame, TObject (Child), Frame.Caption);
           IF verbose THEN WriteLn (inset, '++ Child frame caption "', Frame.Caption, '"');
         END;
       END;
     END;

     WITH Child DO
       IF ComponentCount > 0 THEN getchildren (@getChildText, self);
   END;
 END;
///////////////////////////////////////////
///////////////////////////////////////////
PROCEDURE MenuChecker.WorkOnChilds (ChildProc: TGetChildProc);
 BEGIN
   IF verbose THEN WriteLn ('': 4, 'TopComponent Menu: "', ModuleClassname, '"');
   ChildProc (self);
 END;
///////////////////////////////////////////
PROCEDURE MenuChecker.getChildText (Child: TComponent);
 VAR
   Prop:  integer;
   Value: MSEString;

 PROCEDURE ScanSubmenu (Submenu: TMenuItems);
  VAR
    m, Prop: integer;
  BEGIN
    IF verbose THEN inset:= inset+ '++';

    FOR Prop:= 0 TO 1{ only captions & hints - pred (High (PropName))} DO
      IF getPropInfo (Submenu, PropName [Prop]) <> NIL THEN BEGIN
        Value:= getWideStrProp (Submenu, PropName [Prop]);
        IF Value <> '' THEN BEGIN
          AddItem (MessageText, Prop, Submenu, Value);
          IF verbose THEN WriteLn (inset, '++ Submenu ', PropName [Prop], ' "', Value, '"');
        END;
      END;

    FOR m:= 0 TO pred (Submenu.Count) DO BEGIN
      FOR Prop:= 0 TO 1{ only captions & hints - pred (High (PropName))} DO
        IF getPropInfo (Submenu [m], PropName [Prop]) <> NIL THEN BEGIN
          Value:= getWideStrProp (Submenu [m], PropName [Prop]);
          IF Value <> '' THEN BEGIN
            AddItem (MessageText, Prop, Submenu, Value, m);
            IF verbose THEN WriteLn (inset, '++ Submenu [', m, '] ', PropName [Prop], ' "', Value, '"');
          END;
        END;

      WITH Submenu [m] DO
        IF assigned (Submenu) THEN ScanSubmenu (Submenu);
    END;
    IF verbose THEN inset:= copy (inset, 3, length (inset));
  END;

 BEGIN
   IF NOT assigned (Child) THEN WriteLn ('!!!! MenuChecker found unassigned child!')
   ELSE IF Child IS TCustomDockform THEN TCustomDockform (Child).getChildText (Child)
   ELSE IF Child IS TCustomMSEForm THEN TCustomMSEForm (Child).getChildText (Child)
   ELSE IF Child IS TPopupMenu THEN TPopupMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomButton THEN TCustomButton (Child).getChildText (Child)
   ELSE IF Child IS TCustomEdit THEN TCustomEdit (Child).getChildText (Child)
   ELSE IF Child IS TMSEDataModule THEN TMSEDataModule (Child).getChildText (Child)
   ELSE IF Child IS TStringContainer THEN TStringContainer (Child).getChildText (Child)
   ELSE BEGIN
     IF verbose THEN BEGIN
       IF Child IS TMainMenu THEN WriteLn (inset, ' Child main menu "', Child.Name, '"')
       ELSE IF Child IS TPopupMenu THEN WriteLn (inset, ' Child popup menu "', Child.Name, '"')
       ELSE IF Child IS TCustomMenu THEN WriteLn (inset, ' Child custom menu "', Child.Name, '"')
       ELSE IF Child IS TAction THEN WriteLn (inset, ' Child action "', Child.Name, '"')
       ELSE WriteLn (inset, ' Child component "', Child.Name, '"');
       inset:= '++';
     END;

     FOR Prop:= 0 TO 1{ only captions & hints - pred (High (PropName))} DO
       IF getPropInfo (Child, PropName [Prop]) <> NIL THEN BEGIN
         Value:= getWideStrProp (Child, PropName [Prop]);
         IF Value <> '' THEN BEGIN
           AddItem (MessageText, Prop, TObject (Child), Value);
           IF verbose THEN WriteLn (inset, '++ Child ', PropName [Prop], ' "', Value, '"');
         END;
       END;

     // Now also scan any menu items defined
     IF Child IS TCustomMenu THEN
       WITH TCustomMenu (Child).Menu DO
         IF assigned (Submenu) THEN ScanSubmenu (Submenu);

     WITH Child DO
       IF ComponentCount > 0 THEN getchildren (@getChildText, self);
   END;
 END;
///////////////////////////////////////////
///////////////////////////////////////////
PROCEDURE PopupChecker.WorkOnChilds (ChildProc: TGetChildProc);
 BEGIN
   IF verbose THEN WriteLn ('': 4, 'TopComponent PopupMenu: "', ModuleClassname, '"');
   ChildProc (self);
 END;
///////////////////////////////////////////
PROCEDURE PopupChecker.getChildText (Child: TComponent);
 VAR
   Prop:  integer;
   Value: MSEString;

 PROCEDURE ScanSubmenu (Submenu: TMenuItems);
  VAR
    m, Prop: integer;
  BEGIN
    IF verbose THEN inset:= inset+ '++';

    FOR Prop:= 0 TO 1{ only captions & hints - pred (High (PropName))} DO
      IF getPropInfo (Submenu, PropName [Prop]) <> NIL THEN BEGIN
        Value:= getWideStrProp (Submenu, PropName [Prop]);
        IF Value <> '' THEN BEGIN
          AddItem (MessageText, Prop, Submenu, Value);
          IF verbose THEN WriteLn (inset, '++ Submenu ', PropName [Prop], ' "', Value, '"');
        END;
      END;

    FOR m:= 0 TO pred (Submenu.Count) DO BEGIN
      FOR Prop:= 0 TO 1{ only captions & hints - pred (High (PropName))} DO
        IF getPropInfo (Submenu [m], PropName [Prop]) <> NIL THEN BEGIN
          Value:= getWideStrProp (Submenu [m], PropName [Prop]);
          IF Value <> '' THEN BEGIN
            AddItem (MessageText, Prop, Submenu, Value, m);
            IF verbose THEN WriteLn (inset, '++ Submenu [', m, '] ', PropName [Prop], ' "', Value, '"');
          END;
        END;

      WITH Submenu [m] DO
        IF assigned (Submenu) THEN ScanSubmenu (Submenu);
    END;
    IF verbose THEN inset:= copy (inset, 3, length (inset));
  END;

 BEGIN
   IF NOT assigned (Child) THEN WriteLn ('!!!! PopupChecker found unassigned child!')
   ELSE IF Child IS TCustomDockform THEN TCustomDockform (Child).getChildText (Child)
   ELSE IF Child IS TCustomMSEForm THEN TCustomMSEForm (Child).getChildText (Child)
//   ELSE IF Child IS TCustomMenu THEN TCustomMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomButton THEN TCustomButton (Child).getChildText (Child)
   ELSE IF Child IS TCustomEdit THEN TCustomEdit (Child).getChildText (Child)
   ELSE IF Child IS TMSEDataModule THEN TMSEDataModule (Child).getChildText (Child)
   ELSE IF Child IS TStringContainer THEN TStringContainer (Child).getChildText (Child)
   ELSE BEGIN
     IF verbose THEN BEGIN
       IF Child IS TPopupMenu THEN WriteLn (inset, ' Child popup menu "', Child.Name, '"')
       ELSE IF Child IS TMainMenu THEN WriteLn (inset, ' Child main menu "', Child.Name, '"')
       ELSE IF Child IS TCustomMenu THEN WriteLn (inset, ' Child custom menu "', Child.Name, '"')
       ELSE IF Child IS TAction THEN WriteLn (inset, ' Child action "', Child.Name, '"')
       ELSE WriteLn (inset, ' Child component "', Child.Name, '"');
       inset:= '++';
     END;

     FOR Prop:= 0 TO 1{ only captions & hints - pred (High (PropName))} DO
       IF getPropInfo (Child, PropName [Prop]) <> NIL THEN BEGIN
         Value:= getWideStrProp (Child, PropName [Prop]);
         IF Value <> '' THEN BEGIN
           AddItem (MessageText, Prop, TObject (Child), Value);
           IF verbose THEN WriteLn (inset, '++ Child ', PropName [Prop], ' "', Value, '"');
         END;
       END;

     // Now also scan any menu items defined
     IF Child IS TPopupMenu THEN
       WITH TPopupMenu (Child).Menu DO
         IF assigned (Submenu) THEN ScanSubmenu (Submenu);

     WITH Child DO
       IF ComponentCount > 0 THEN getchildren (@getChildText, self);
   END;
 END;
///////////////////////////////////////////
///////////////////////////////////////////
PROCEDURE ButtonChecker.WorkOnChilds (ChildProc: TGetChildProc);
 BEGIN
   IF verbose THEN WriteLn ('': 4, 'TopComponent Button: "', ModuleClassname, '"');
   ChildProc (self);
 END;
///////////////////////////////////////////
PROCEDURE ButtonChecker.getChildText (Child: TComponent);
 VAR
   Prop:  integer;
   Value: MSEString;
 BEGIN
   IF NOT assigned (Child) THEN WriteLn ('!!!! DockChecker found unassigned child!')
   ELSE IF Child IS TCustomDockform THEN TCustomDockform (Child).getChildText (Child)
   ELSE IF Child IS TCustomMSEForm THEN TCustomMSEForm (Child).getChildText (Child)
   ELSE IF Child IS TPopupMenu THEN TPopupMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomMenu THEN TCustomMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomEdit THEN TCustomEdit (Child).getChildText (Child)
   ELSE IF Child IS TMSEDataModule THEN TMSEDataModule (Child).getChildText (Child)
   ELSE IF Child IS TStringContainer THEN TStringContainer (Child).getChildText (Child)
   ELSE BEGIN
     IF verbose THEN BEGIN
       IF Child IS TCustomButton THEN WriteLn (inset, ' Child Button "', Child.Name, '"')
       ELSE IF Child IS TAction THEN WriteLn (inset, ' Child action "', Child.Name, '"')
       ELSE WriteLn (inset, ' Child component "', Child.Name, '"');
       inset:= '++';
     END;

     FOR Prop:= 0 TO High (PropName) DO
       IF getPropInfo (Child, PropName [Prop]) <> NIL THEN BEGIN
         Value:= getWideStrProp (Child, PropName [Prop]);
         IF Value <> '' THEN BEGIN
           AddItem (MessageText, Prop, TObject (Child), Value);
           IF verbose THEN WriteLn (inset, '++ Child ', PropName [Prop], ' "', Value, '"');
         END;
       END;

     WITH Child DO
       IF ComponentCount > 0 THEN getchildren (@getChildText, self);
   END;
 END;
///////////////////////////////////////////
///////////////////////////////////////////
PROCEDURE EditChecker.WorkOnChilds (ChildProc: TGetChildProc);
 BEGIN
   IF verbose THEN WriteLn ('': 4, 'TopComponent Edit: "', ModuleClassname, '"');
   ChildProc (self);
 END;
///////////////////////////////////////////
PROCEDURE EditChecker.getChildText (Child: TComponent);
 VAR
   Prop:  integer;
   Value: MSEString;
 BEGIN
   IF NOT assigned (Child) THEN WriteLn ('!!!! DockChecker found unassigned child!')
   ELSE IF Child IS TCustomDockform THEN TCustomDockform (Child).getChildText (Child)
   ELSE IF Child IS TCustomMSEForm THEN TCustomMSEForm (Child).getChildText (Child)
   ELSE IF Child IS TPopupMenu THEN TPopupMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomMenu THEN TCustomMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomButton THEN TCustomButton (Child).getChildText (Child)
   ELSE IF Child IS TMSEDataModule THEN TMSEDataModule (Child).getChildText (Child)
   ELSE IF Child IS TStringContainer THEN TStringContainer (Child).getChildText (Child)
   ELSE BEGIN
     IF verbose THEN BEGIN
       IF Child IS TCustomEdit THEN WriteLn (inset, ' Child Edit "', Child.Name, '"')
       ELSE IF Child IS TAction THEN WriteLn (inset, ' Child action "', Child.Name, '"')
       ELSE WriteLn (inset, ' Child component "', Child.Name, '"');
       inset:= '++';
     END;

     FOR Prop:= 0 TO High (PropName) DO
       IF getPropInfo (Child, PropName [Prop]) <> NIL THEN BEGIN
         Value:= getWideStrProp (Child, PropName [Prop]);
         IF Value <> '' THEN BEGIN
           AddItem (MessageText, Prop, TObject (Child), Value);
           IF verbose THEN WriteLn (inset, '++ Child ', PropName [Prop], ' "', Value, '"');
         END;
       END;

     IF getPropInfo (Child, 'frame') <> NIL THEN BEGIN
       Frame:= TCaptionFrame (getObjectProp (Child, 'frame'));

       IF assigned (Frame) AND (getPropInfo (Frame, 'caption') <> NIL) THEN BEGIN
         Value:= Frame.Caption;
         IF Value <> '' THEN BEGIN
           AddItem (MessageText, PropFrame, TObject (Child), Frame.Caption);
           IF verbose THEN WriteLn (inset, '++ Child frame caption "', Frame.Caption, '"');
         END;
       END;
     END;

     WITH Child DO
       IF ComponentCount > 0 THEN getchildren (@getChildText, self);
   END;
 END;
///////////////////////////////////////////
///////////////////////////////////////////
PROCEDURE DataModuleChecker.WorkOnChilds (ChildProc: TGetChildProc);
 BEGIN
   IF verbose THEN WriteLn ('': 4, 'TopComponent DataModule: "', ModuleClassName, '"');
   ChildProc (self);
 END;
///////////////////////////////////////////
PROCEDURE DataModuleChecker.getChildText (Child: TComponent);
 VAR
   Prop:  integer;
   Value: MSEString;
 BEGIN
   IF NOT assigned (Child) THEN WriteLn ('!!!! DataModuleChecker found unassigned child!')
   ELSE IF Child IS TCustomDockform THEN TCustomDockform (Child).getChildText (Child)
   ELSE IF Child IS TCustomMSEForm THEN TCustomMSEForm (Child).getChildText (Child)
   ELSE IF Child IS TPopupMenu THEN TPopupMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomMenu THEN TCustomMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomButton THEN TCustomButton (Child).getChildText (Child)
   ELSE IF Child IS TCustomEdit THEN TCustomEdit (Child).getChildText (Child)
   ELSE IF Child IS TStringContainer THEN TStringContainer (Child).getChildText (Child)
   ELSE BEGIN
     IF verbose THEN BEGIN
       IF Child IS TMSEDataModule THEN WriteLn (inset, ' Child data module "', Child.Name, '"')
       ELSE IF Child IS TAction THEN WriteLn (inset, ' Child action "', Child.Name, '"')
       ELSE WriteLn (inset, ' Child component "', Child.Name, '"');
       inset:= '++';
     END;

     FOR Prop:= 0 TO High (PropName) DO
       IF getPropInfo (Child, PropName [Prop]) <> NIL THEN BEGIN
         Value:= getWideStrProp (Child, PropName [Prop]);
         IF Value <> '' THEN BEGIN
           AddItem (MessageText, Prop, TObject (Child), Value);
           IF verbose THEN WriteLn (inset, '++ Child ', PropName [Prop], ' "', Value, '"');
         END;
       END;

     WITH Child DO
       IF ComponentCount > 0 THEN getchildren (@getChildText, self);
   END;
 END;
///////////////////////////////////////////
///////////////////////////////////////////
PROCEDURE StringContainerChecker.WorkOnChilds (ChildProc: TGetChildProc);
 BEGIN
   IF verbose THEN WriteLn ('': 4, 'TopComponent StringContainer: "', ModuleClassName, '"');
   ChildProc (self);
 END;
///////////////////////////////////////////
PROCEDURE StringContainerChecker.getChildText (Child: TComponent);
 VAR
   n:     integer;
   Value: MSEString;
 BEGIN
   IF NOT assigned (Child) THEN WriteLn ('!!!! StringContainerChecker found unassigned child!')
   ELSE IF Child IS TCustomDockform THEN TCustomDockform (Child).getChildText (Child)
   ELSE IF Child IS TCustomMSEForm THEN TCustomMSEForm (Child).getChildText (Child)
   ELSE IF Child IS TPopupMenu THEN TPopupMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomMenu THEN TCustomMenu (Child).getChildText (Child)
   ELSE IF Child IS TCustomButton THEN TCustomButton (Child).getChildText (Child)
   ELSE IF Child IS TCustomEdit THEN TCustomEdit (Child).getChildText (Child)
   ELSE IF Child IS TMSEDataModule THEN TMSEDataModule (Child).getChildText (Child)
   ELSE BEGIN
     IF verbose THEN BEGIN
       IF Child IS TStringContainer THEN WriteLn (inset, ' Child string container "', Child.Name, '"')
       ELSE IF Child IS TAction THEN WriteLn (inset, ' Child action "', Child.Name, '"')
       ELSE WriteLn (inset, ' Child component "', Child.Name, '"');
       inset:= '++';
     END;

     // This only provides a string list named 'strings'
     IF verbose THEN WriteLn (inset, '++ Child strings begin');
     WITH TStringContainer (Child) DO
       FOR n:= 0 TO pred (Strings.Count) DO BEGIN
         Value:= Trim (Strings [n]);
         IF Value <> '' THEN BEGIN
           AddItem (MessageText, 0, TObject (Child), Value, n);
           IF verbose THEN WriteLn (inset, '   Strings [', n, ']: "', Value, '"');
         END;
       END;
     IF verbose THEN WriteLn (inset, '++ Child strings end');

     // There aren't usually any child components...
     WITH Child DO
       IF ComponentCount > 0 THEN getchildren (@getChildText, self);
   END;
 END;
///////////////////////////////////////////
///////////////////////////////////////////
FUNCTION AppChecker.CreateFormEx (InstanceClass: WidgetClassty; VAR Reference): TWidget;
 BEGIN
   Result:= Application.CreateForm (InstanceClass, Reference);
   IF verbose THEN WriteLn ('AppChecker.CreateFormEx: (', TCustomMSEForm (Result).ModuleClassname, ') ', TComponent (Reference).Name);

   IF TCustomMSEForm (Result).ModuleClassname = 'tdockform'
   THEN WITH TCustomDockform (Result) DO WorkOnChilds (@getChildText)
   ELSE WITH TCustomMSEForm  (Result) DO WorkOnChilds (@getChildText);
 END;
///////////////////////////////////////////
FUNCTION AppChecker.CreateDataModuleEx (InstanceClass: MSEComponentClassty; VAR Reference): TMSEComponent;
 BEGIN
   Result:= Application.CreateDataModule (InstanceClass, Reference);
   IF verbose THEN WriteLn ('AppChecker.CreateDataModuleEx: ', TComponent (Reference).Name);

   WITH TMSEDataModule (Result) DO WorkOnChilds (@getChildText);
 END;
///////////////////////////////////////////
PROCEDURE AppChecker.runApplicationEx;
 BEGIN
   FormArea:= addApplicationStrings (MessageText);
   Application.Run;
 END;
///////////////////////////////////////////
///////////////////////////////////////////
{4.45.4 TComponent Property overview
Page Properties     Access Description
 356 ComObject      r      Interface reference implemented by the component
 357 ComponentCount r      Count of owned components
 357 ComponentIndex rw     Index of component in it’s owner’s list.
 357 Components     r      Indexed list (zero-based) of all owned components.
 357 ComponentState r      Current component’s state.
 358 ComponentStyle r      Current component’s style.
 358 DesignInfo     rw     Information for IDE designer.
 359 Name           rws    Name of the component.
 358 Owner          r      Owner of this component.
 359 Tag            rw     Tag value of the component.
 359 VCLComObject   rw     Not implemented.
///////////////////////////////////////////
TPropInfo = packed record
   PropType : PTypeInfo;
   GetProc : CodePointer;
   SetProc : CodePointer;
   StoredProc : CodePointer;
   Index : Integer;
   Default : LongInt;
   NameIndex : SmallInt;
   // contains the type of the Get/Set/Storedproc, see also ptxxx
   // bit 0..1 GetProc
   //     2..3 SetProc
   //     4..5 StoredProc
   //     6 : true, constant index property
   PropProcs : Byte;
   Name : ShortString;
end
///////////////////////////////////////////}
END.
