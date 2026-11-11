{**
 * An opaque handle representing a toplevel system tray object.
 *
 * \since This struct is available since SDL 3.2.0.
 *}
type
  PSDL_Tray = type Pointer;
  PPSDL_Tray = ^PSDL_Tray;

{**
 * An opaque handle representing a menu/submenu on a system tray object.
 *
 * \since This struct is available since SDL 3.2.0.
 *}
type
  PSDL_TrayMenu = type Pointer;
  PPSDL_TrayMenu = ^PSDL_TrayMenu;

{**
 * An opaque handle representing an entry on a system tray object.
 *
 * \since This struct is available since SDL 3.2.0.
 *}
type
  PSDL_TrayEntry = type Pointer;
  PPSDL_TrayEntry = ^PSDL_TrayEntry;

{**
 * Flags that control the creation of system tray entries.
 *
 * Some of these flags are required; exactly one of them must be specified at
 * the time a tray entry is created. Other flags are optional; zero or more of
 * those can be OR'ed together with the required flag.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_InsertTrayEntryAt
 *}
type
  TSDL_TrayEntryFlags = type cuint32;

const
  {* Make the entry a simple button. Required. *}
  SDL_TRAYENTRY_BUTTON   = TSDL_TrayEntryFlags($00000001);
  {* Make the entry a checkbox. Required. *}
  SDL_TRAYENTRY_CHECKBOX = TSDL_TrayEntryFlags($00000002);
  {* Prepare the entry to have a submenu. Required *}
  SDL_TRAYENTRY_SUBMENU  = TSDL_TrayEntryFlags($00000004);
  {* Make the entry disabled. Optional. *}
  SDL_TRAYENTRY_DISABLED = TSDL_TrayEntryFlags($80000000);
  {* Make the entry checked. This is valid only for checkboxes. Optional. *}
  SDL_TRAYENTRY_CHECKED  = TSDL_TrayEntryFlags($40000000);

{**
 * A callback that is invoked when a tray entry is selected.
 *
 * \param userdata an optional pointer to pass extra data to the callback when
 *                 it will be invoked.
 * \param entry the tray entry that was selected.
 *
 * \since This datatype is available since SDL 3.2.0.
 *
 * \sa SDL_SetTrayEntryCallback
 *}
type
  TSDL_TrayCallback = procedure(userdata: Pointer; entry: PSDL_TrayEntry); cdecl;
  PSDL_TrayCallback = ^TSDL_TrayCallback;
  PPSDL_TrayCallback = ^PSDL_TrayCallback;

{**
 * Create an icon to be placed in the operating system's tray, or equivalent.
 *
 * Many platforms advise not using a system tray unless persistence is a
 * necessary feature. Avoid needlessly creating a tray icon, as the user may
 * feel like it clutters their interface.
 *
 * Using tray icons require the video subsystem.
 *
 * \param icon a surface to be used as icon. May be NIL.
 * \param tooltip a tooltip to be displayed when the mouse hovers the icon in
 *                UTF-8 encoding. Not supported on all platforms. May be NIL.
 * \returns The newly created system tray icon.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateTrayMenu
 * \sa SDL_GetTrayMenu
 * \sa SDL_DestroyTray
 *}
function SDL_CreateTray(icon: PSDL_Surface; const tooltip: PAnsiChar): PSDL_Tray; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateTray' {$ENDIF} {$ENDIF};

{**
 * Updates the system tray icon's icon.
 *
 * \param tray the tray icon to be updated.
 * \param icon the new icon. May be NIL.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateTray
 *}
procedure SDL_SetTrayIcon(tray: PSDL_Tray; icon: PSDL_Surface); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTrayIcon' {$ENDIF} {$ENDIF};

{**
 * Updates the system tray icon's tooltip.
 *
 * \param tray the tray icon to be updated.
 * \param tooltip the new tooltip in UTF-8 encoding. May be NIL.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateTray
 *}
procedure SDL_SetTrayTooltip(tray: PSDL_Tray; const tooltip: PAnsiChar); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTrayTooltip' {$ENDIF} {$ENDIF};

{**
 * Create a menu for a system tray.
 *
 * This should be called at most once per tray icon.
 *
 * This function does the same thing as SDL_CreateTraySubmenu(), except that
 * it takes a SDL_Tray instead of a SDL_TrayEntry.
 *
 * A menu does not need to be destroyed; it will be destroyed with the tray.
 *
 * \param tray the tray to bind the menu to.
 * \returns the newly created menu.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateTray
 * \sa SDL_GetTrayMenu
 * \sa SDL_GetTrayMenuParentTray
 *}
function SDL_CreateTrayMenu(tray: PSDL_Tray): PSDL_TrayMenu; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateTrayMenu' {$ENDIF} {$ENDIF};

{**
 * Create a submenu for a system tray entry.
 *
 * This should be called at most once per tray entry.
 *
 * This function does the same thing as SDL_CreateTrayMenu, except that it
 * takes a SDL_TrayEntry instead of a SDL_Tray.
 *
 * A menu does not need to be destroyed; it will be destroyed with the tray.
 *
 * \param entry the tray entry to bind the menu to.
 * \returns the newly created menu.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_InsertTrayEntryAt
 * \sa SDL_GetTraySubmenu
 * \sa SDL_GetTrayMenuParentEntry
 *}
function SDL_CreateTraySubmenu(entry: PSDL_TrayEntry): PSDL_TrayMenu; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_CreateTraySubmenu' {$ENDIF} {$ENDIF};

{**
 * Gets a previously created tray menu.
 *
 * You should have called SDL_CreateTrayMenu() on the tray object. This
 * function allows you to fetch it again later.
 *
 * This function does the same thing as SDL_GetTraySubmenu(), except that it
 * takes a SDL_Tray instead of a SDL_TrayEntry.
 *
 * A menu does not need to be destroyed; it will be destroyed with the tray.
 *
 * \param tray the tray entry to bind the menu to.
 * \returns the newly created menu.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateTray
 * \sa SDL_CreateTrayMenu
 *}
function SDL_GetTrayMenu(tray: PSDL_Tray): PSDL_TrayMenu; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTrayMenu' {$ENDIF} {$ENDIF};

{**
 * Gets a previously created tray entry submenu.
 *
 * You should have called SDL_CreateTraySubmenu() on the entry object. This
 * function allows you to fetch it again later.
 *
 * This function does the same thing as SDL_GetTrayMenu(), except that it
 * takes a SDL_TrayEntry instead of a SDL_Tray.
 *
 * A menu does not need to be destroyed; it will be destroyed with the tray.
 *
 * \param entry the tray entry to bind the menu to.
 * \returns the newly created menu.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_InsertTrayEntryAt
 * \sa SDL_CreateTraySubmenu
 *}
function SDL_GetTraySubmenu(entry: PSDL_TrayEntry): PSDL_TrayMenu; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTraySubmenu' {$ENDIF} {$ENDIF};

{**
 * Returns a list of entries in the menu, in order.
 *
 * \param menu The menu to get entries from.
 * \param count An optional pointer to obtain the number of entries in the
 *              menu.
 * \returns a NIL-terminated list of entries within the given menu. The
 *          pointer becomes invalid when any function that inserts or deletes
 *          entries in the menu is called.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RemoveTrayEntry
 * \sa SDL_InsertTrayEntryAt
 *}
function SDL_GetTrayEntries(menu: PSDL_TrayMenu; count: pcint): PPSDL_TrayEntry; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTrayEntries' {$ENDIF} {$ENDIF};

{**
 * Removes a tray entry.
 *
 * \param entry The entry to be deleted.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTrayEntries
 * \sa SDL_InsertTrayEntryAt
 *}
procedure SDL_RemoveTrayEntry(entry: PSDL_TrayEntry); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_RemoveTrayEntry' {$ENDIF} {$ENDIF};

{**
 * Insert a tray entry at a given position.
 *
 * If label is NIL, the entry will be a separator. Many functions won't work
 * for an entry that is a separator.
 *
 * An entry does not need to be destroyed; it will be destroyed with the tray.
 *
 * \param menu the menu to append the entry to.
 * \param pos the desired position for the new entry. Entries at or following
 *            this place will be moved. If pos is -1, the entry is appended.
 * \param label_ the text to be displayed on the entry, in UTF-8 encoding, or
 *               NIL for a separator.
 * \param flags a combination of flags, some of which are mandatory.
 * \returns the newly created entry, or NIL if pos is out of bounds.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_TrayEntryFlags
 * \sa SDL_GetTrayEntries
 * \sa SDL_RemoveTrayEntry
 * \sa SDL_GetTrayEntryParent
 *}
function SDL_InsertTrayEntryAt(
  menu: PSDL_TrayMenu;
  pos: cint;
  const label_: PAnsiChar;
  flags: TSDL_TrayEntryFlags
): PSDL_TrayEntry; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_InsertTrayEntryAt' {$ENDIF} {$ENDIF};

{**
 * Sets the label of an entry.
 *
 * An entry cannot change between a separator and an ordinary entry; that is,
 * it is not possible to set a non-NIL label on an entry that has a NIL
 * label (separators), or to set a NIL label to an entry that has a non-NIL
 * label. The function will silently fail if that happens.
 *
 * \param entry the entry to be updated.
 * \param label the new label for the entry in UTF-8 encoding.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTrayEntries
 * \sa SDL_InsertTrayEntryAt
 * \sa SDL_GetTrayEntryLabel
 *}
procedure SDL_SetTrayEntryLabel(entry: PSDL_TrayEntry; const label_: PAnsiChar); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTrayEntryLabel' {$ENDIF} {$ENDIF};

{**
 * Gets the label of an entry.
 *
 * If the returned value is NIL, the entry is a separator.
 *
 * \param entry the entry to be read.
 * \returns the label of the entry in UTF-8 encoding.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTrayEntries
 * \sa SDL_InsertTrayEntryAt
 * \sa SDL_SetTrayEntryLabel
 *}
function SDL_GetTrayEntryLabel(entry: PSDL_TrayEntry): PAnsiChar; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTrayEntryLabel' {$ENDIF} {$ENDIF};

{**
 * Sets whether or not an entry is checked.
 *
 * The entry must have been created with the SDL_TRAYENTRY_CHECKBOX flag.
 *
 * \param entry the entry to be updated.
 * \param checked true if the entry should be checked; false otherwise.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTrayEntries
 * \sa SDL_InsertTrayEntryAt
 * \sa SDL_GetTrayEntryChecked
 *}
procedure SDL_SetTrayEntryChecked(entry: PSDL_TrayEntry; checked: Boolean); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTrayEntryChecked' {$ENDIF} {$ENDIF};

{**
 * Gets whether or not an entry is checked.
 *
 * The entry must have been created with the SDL_TRAYENTRY_CHECKBOX flag.
 *
 * \param entry the entry to be read.
 * \returns true if the entry is checked; false otherwise.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTrayEntries
 * \sa SDL_InsertTrayEntryAt
 * \sa SDL_SetTrayEntryChecked
 *}
function SDL_GetTrayEntryChecked(entry: PSDL_TrayEntry): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTrayEntryChecked' {$ENDIF} {$ENDIF};

{**
 * Sets whether or not an entry is enabled.
 *
 * \param entry the entry to be updated.
 * \param enabled true if the entry should be enabled; false otherwise.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTrayEntries
 * \sa SDL_InsertTrayEntryAt
 * \sa SDL_GetTrayEntryEnabled
 *}
procedure SDL_SetTrayEntryEnabled(entry: PSDL_TrayEntry; enabled: Boolean); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTrayEntryEnabled' {$ENDIF} {$ENDIF};

{**
 * Gets whether or not an entry is enabled.
 *
 * \param entry the entry to be read.
 * \returns true if the entry is enabled; false otherwise.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTrayEntries
 * \sa SDL_InsertTrayEntryAt
 * \sa SDL_SetTrayEntryEnabled
 *}
function SDL_GetTrayEntryEnabled(entry: PSDL_TrayEntry): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTrayEntryEnabled' {$ENDIF} {$ENDIF};

{**
 * Sets a callback to be invoked when the entry is selected.
 *
 * \param entry the entry to be updated.
 * \param callback a callback to be invoked when the entry is selected.
 * \param userdata an optional pointer to pass extra data to the callback when
 *                 it will be invoked.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetTrayEntries
 * \sa SDL_InsertTrayEntryAt
 *}
procedure SDL_SetTrayEntryCallback(entry: PSDL_TrayEntry; callback: PSDL_TrayCallback; userdata: Pointer); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_SetTrayEntryCallback' {$ENDIF} {$ENDIF};

{**
 * Simulate a click on a tray entry.
 *
 * \param entry The entry to activate.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *}
procedure SDL_ClickTrayEntry(entry: PSDL_TrayEntry); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_ClickTrayEntry' {$ENDIF} {$ENDIF};

{**
 * Destroys a tray object.
 *
 * This also destroys all associated menus and entries.
 *
 * \param tray the tray icon to be destroyed.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateTray
 *}
procedure SDL_DestroyTray(tray: PSDL_Tray); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_DestroyTray' {$ENDIF} {$ENDIF};

{**
 * Gets the menu containing a certain tray entry.
 *
 * \param entry the entry for which to get the parent menu.
 * \returns the parent menu.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_InsertTrayEntryAt
 *}
function SDL_GetTrayEntryParent(entry: PSDL_TrayEntry): PSDL_TrayMenu; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTrayEntryParent' {$ENDIF} {$ENDIF};

{**
 * Gets the entry for which the menu is a submenu, if the current menu is a
 * submenu.
 *
 * Either this function or SDL_GetTrayMenuParentTray() will return non-NIL
 * for any given menu.
 *
 * \param menu the menu for which to get the parent entry.
 * \returns the parent entry, or NIL if this menu is not a submenu.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateTraySubmenu
 * \sa SDL_GetTrayMenuParentTray
 *}
function SDL_GetTrayMenuParentEntry(menu: PSDL_TrayMenu): PSDL_TrayEntry; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTrayMenuParentEntry' {$ENDIF} {$ENDIF};

{**
 * Gets the tray for which this menu is the first-level menu, if the current
 * menu isn't a submenu.
 *
 * Either this function or SDL_GetTrayMenuParentEntry() will return non-NIL
 * for any given menu.
 *
 * \param menu the menu for which to get the parent enttrayry.
 * \returns the parent tray, or NIL if this menu is a submenu.
 *
 * \threadsafety This function should be called on the thread that created the
 *               tray.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_CreateTrayMenu
 * \sa SDL_GetTrayMenuParentEntry
 *}
function SDL_GetTrayMenuParentTray(menu: PSDL_TrayMenu): PSDL_Tray; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetTrayMenuParentTray' {$ENDIF} {$ENDIF};

{**
 * Update the trays.
 *
 * This is called automatically by the event loop and is only needed if you're
 * using trays but aren't handling SDL events.
 *
 * \threadsafety This function should only be called on the main thread.
 *
 * \since This function is available since SDL 3.2.0.
 *}
procedure SDL_UpdateTrays(); cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_UpdateTrays' {$ENDIF} {$ENDIF};
