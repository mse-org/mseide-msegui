New features for "newdialogs”                     So 7. Apr 13:21:45 CEST 2024

Unit "vectors”
  Completely new set of arithmetic operators for 2-dimensional vectors of "PointTy"
  OPERATOR  +  adds £wo vectors, i.e. appends one to the other
  OPERATOR  -  subtracts two vectors, i.e. appands the negative of the second to the first one
  OPERATOR  =  compares two vectors, returns "true" if both components match
  OPERATOR <>  compares two vectors, returns "true” if at least one component DOES NOT match
  OPERATOR  *  calculates the scalar product of a vector
  OPERATOR  *  multiplies a vector with an integer and returns the resulting larger vector
               (sequence if operands does not matter)
  OPERATOR DIV divides a vector by an integer and returns the resulting reduced vector
  OPERATOR := assigns an array of two integers to the components of a vector


Unit "msedialog":

  New type definition:

    dialogposty - enumeration type to specify dialog window positioning
      dp_none:                 no positioning, use form setting
      dp_mousepos:             show dialog centered at current mouse position
      dp_defaultpos:           show dialog at design position or position set after form creation
      dp_screencentered:       show dialog centered on screen
      dp_screencenteredvirt:   show dialog centered on virtual screen
      dp_transientforcentered: show dialog centered on currently active window (?)
      dp_mainwindowcentered:   show dialog centered on application main window

  New functionality for "tdialogform":
    Two new constructors adding positioning and state memory

      CONSTRUCTOR Create (Sender: TComponent; where: dialogposty = dp_none);
        Allows specification of dialog positioning according to parameter "where".
        If "where" isn't specified, uses form setting

      CONSTRUCTOR Create (Sender: TComponent; CONST StatName: msestring; where: dialogposty);
        Allows specification of dialog positioning according to parameter "where" as above,
        additionaly specifies memory statfile name for keeping state memory between invocations.

  New ancillary functions:

    FUNCTION keepOnScreen (CONST Sender: twidget; shift: PointTy): PointTy;
      Calculates new position for "Sender" window to put it at a position "shift" picels away
      from its current one, new position should be assigned to "Window.decoratedPos" to keep
      window frame on screen also.

    PROCEDURE registerSavedDialogs (StateFile: tStatFile; CONST DialogNames: msestringarty);
    PROCEDURE registerSavedDialogs (BaseForm: tmseform; CONST DialogNames: msestringarty);
      These procedures allow saving dialog state memory over application invocations for the
      (accordingly created) dialogs whose "StatName"s are specified by "DialogNames".
      The first version keeps these data through a directly specified sz´tatfile "StateFile",
      while the second uses the statfile set up for the form "BaseForm", usually the
      application main form.
      --- REMARK:
          With the modified stat file processing as of 2024-04, the dialog states can be
          perpetuated "automatically" by defining an "onstatupdate" procedure like this:

      PROCEDURE <Form class name>.AssessStates (CONST sender: TObject; CONST filer: tstatfiler);
       VAR
         MemFiles: msestringarty;
       BEGIN
         IF filer IS tStatReader THEN BEGIN
           MemFiles:= [''];
           MemFiles:= (filer AS tStatReader).ReadArray ('savedmemoryfiles', MemFiles);
           registerSavedDialogs (PStateFile, MemFiles);
         END;
       //  IF filer IS tStatWriter THEN BEGIN END; -- not needed here!
       END;


Unit "msecolordialog":

  New functionality for calling function "colordialog":
    This function now also takes a (final) parameter "providedform" of type "tcolordialogfo"
    that can be preinitialized to application specific properties.
    If no such form is passed, it is MODIFIED in such a manner as to NO LONGER show up FIXED
    at its design position, but to appear at the current mouse position.
    This ALTERS the behaviour if used from within a "tcoloredit" and possibly other ones too.


Unit "msesearchreplace":
  New calling interface and functionality for class "treplacedialogfo":
    CONSTRUCTOR Create (CONST Sender: TComponent; replacer: boolean = true;
                        where: dialogposty = dp_none); OVERLOAD;
    CONSTRUCTOR Create (CONST Sender: TComponent; CONST StatName: msestring;
                        replacer: boolean = true; where: dialogposty = dp_none); OVERLOAD;
      The constructor now already defines the kind of dialog created and the positioning method.
      Positioning is handled like for a simple "tdialogform" and preset to "dp_none" as well.
      Parameter "replacer" specifies the kind of dislog created:
        the default setting of "true" yields a replace dialog,
        the explicit value "false" yields a search-only dialog.


