MSEide+MSEgui Pascal Cross Platform GUI Development System.
 
2009-06-23 Version 2.2.beta1
Copyright (c) 1999-2009 by Martin Schreiber

- Compiles with FPC 2.2.4
- Tested on i386-linux SuSE 9.0,10.3,11.1 and i386-win32 98, 2000, XP and Vista.
- Links to xlib and gdi32, no external widget library needed.
- Internal character encoding is UCS2.
- Uses anti aliased fonts on Linux (Xft).
- All screen drawing is double buffered.
- Has docking forms and MDI.
- Has embedded forms (similar to TFrame).
- Has database access components and data edit widgets.
- Internationalization functionality with resource modules.
- Report generator.

IDE:
- Integrated debugging.
- Source code highlighting.
- Source code navigation with support for include files.
- Code completion for classes.
- Integrated visual form designer with source code update for components and 
  events.
- Flexible and handy build system with switchable macros.
- Visual form inheritance.
- Integrated report designer.

License:
IDE is under GPL, library under modified LGPL like FPC-RTL.

Installation:
*************
1. Download and install FPC 2.2.4, you can get it from 
   http://www.freepascal.org/download.var
2. Download mseide_msegui_src_2_2beta1.zip and mseide_bin_2_2beta1.zip
   http://sourceforge.net/project/showfiles.php?group_id=165409
3. Extract them to a directory of your choice ('yourdirectory') .
4. Run 'yourdirectory/bin/i386-linux/mseide' on linux or 
   'yourdirectory\bin\i386-win32\mseide.exe' on windows.
5. In 'Settings'-'Configure MSEide'-'${MSEDIR}' select 'yourdirectory/msegui'.
6. In 'Project'-'Open' select 'yourdirectory/msegui/apps/demo/demo.prj'.
7. 'Target'-'Continue'.

If you wish to to compile the IDE:

1. In 'Project'-'Open' select 'yourdirectory/msegui/apps/ide/mseide.prj'.
2. 'Target'-'Continue'.

Creating a new GUI project
**************************
'Project'-'New'-'From Template', select "default.prj"

Creating a new console project
******************************
'Project'-'New'-'From Template', select "console.prj"

MSEide command line parameters
******************************
-np
 Do not load a project.
-ns
 Do not use a skin, no fades.
--macrogroup=<n>
 Use 'Project'-'Options'-'Macros'-'Active group' number <n>, <n> = 1..6.
--macrodef=<name>,<value>{,<name>,<value>}
 Macro definition, will be overridden by 'Project'-'Options'-'Macros'. Example:
 --macrodef=MAC1,abc,MAC2,def
 defines ${MAC1} with value 'abc' and ${MAC2} with value 'def'.
--fontalias=<alias>,<fontname>[,<fontheight>[,<fontwidth>[,<options>[,<xscale>]]]]
 Change the used fonts. <alias> can be stf_default, stf_menu or mseide_source.

MSEide environment variables
****************************
Macros in 'Settings'-'Configure MSEide' can be overridden by environment
variables. They will be overriden by --macrodef and 'Project'-'Options'-'Macros'.
Possible names: 
FPCDIR, FPCLIBDIR, MSEDIR, MSELIBDIR, SYNTAXDEFDIR, TEMPLATEDIR,
COMPSTOREDIR, COMPILER, DEBUGGER, EXEEXT, TARGET.

FPC 2.2.2
*********
patch_fpc_2_2_2 contains patched FPC files in order to fix FPC Mantis 11774, 
11855, 11856.

Debugging
*********
Breakpoints don't work on win32 in units compiled with -CX 
(create smartlinked units). It is recommended to use mingw gdb 6.8 on win32.
String and dynamic array variables of units compiled with 
-gv (Valgrind debug info) are displayed incorrect.
gdb 6.5 has bugs with threads and forking on linux. Please update to gdb 6.6+.
FPC 2.2+ projects must be compiled with -O- (no optimization) for debugging.

Popup widgets behind the forms
******************************
If the popup widgets are showed behind the forms, try to start the 
MSEgui program with the option '--TOPLEVELRAISE'. Do *not* use this option
if is not necessary (KDE, Gnome... work well without).

Blinking taskbar widgets in IceWM
*********************************
Newer revisions of IceWM let the taskbar icons of MSEgui applications blink.
Start the MSEgui application with the option '--TOPLEVELRAISE'.

Invalid inputmanager for Ubuntu
*******************************
The utf-8 setup in Ubuntu seems to be incomplete. If you get the exception
"egui : Invalid inputmanager tinternalapplication ." at program start, try to
replace your language locale in /usr/share/X11/locale/locale.dir
by en_US as a workaround. Example for ru_RU.UTF-8:
replace 
ru_RU.UTF-8/XLC_LOCALE ru_RU.UTF-8
with
en_US.UTF-8/XLC_LOCALE ru_RU.UTF-8

How to add custom components to MSEide
**************************************
There is a project 'apps/myide/mymseide.prj' as a demo.
Start MSEide, open project 'apps/myide/mymseide.prj', 'Project'-'Build',
'Target'-'Continue',
the IDE with the new component 'tmybutton' will be compiled and
started in the the debugger.
Binary name is 'mymseide' (linux) or 'mymseide.exe' (win32).

If you wish to do it from scratch:

- Create a register unit for your components 
  (see 'apps/myide/regmycomps.pas' for an example).
- Enter the unitname followed by a comma 
  ('myregunit,' if your regunitfile is 'myregunit.pas') in 
  a file named 'regcomponents.inc'.
- Build the IDE with -dmorecomponents as option.

If you want add custom icons to your components:

- Convert 24*24 pixel BMP files with tools/bmp2pas to
  an icon unit ('*_bmp.pas').
- Add the name of the icon unit to 'uses' in your register unit.
 
How to run i18ndemo
*******************
- Start MSEide.
- 'Project'-'Open'-'yourdirectory/msegui/apps/i18ndemo/i18ndemo.prj'.
- 'Project'-'Make' to create the rst files.
- 'Project'-'Open'-'yourdirectory/msegui/tools/i18n/msei18n.prj'.
- 'Target'-'Continue'.
In MSEi18n:
 - Adjust 'Settings'-'Configure MSEi18n'-'${MSEDIR}' and ${COMPILER}.
 - 'Open'-'yourdirectory/msegui/apps/i18ndemo/i18ndemo.trp'
 - 'Make'.
 - Close message window.
 - Close MSEi18n.
- 'Project'-'Open'-'yourdirectory/msegui/apps/i18ndemo/i18ndemo.prj'.
- 'Target'-'Continue'.

SQLite
******
To install tmsesqlite3dataset compile the IDE with -dmse_with_sqlite 
(experimental, needs installed libsqlite3.so (linux) or sqlite3.dll (win32) 
on your system).

tsqlite3connection is available without -dmse_with_sqlite. Field type mapping:

      Type name        SQLite storage class  Field type    Data type
+--------------------+---------------------+-------------+-------------+
| INTEGER or INT     | INTEGER 4           | ftinteger   | integer     |
| LARGEINT           | INTEGER 8           | ftlargeint  | largeint    |
| WORD               | INTEGER 2           | ftword      | word        |
| SMALLINT           | INTEGER 2           | ftsmallint  | smallint    |
| BOOLEAN            | INTEGER 2           | ftboolean   | wordbool    |
| FLOAT[...] or REAL | REAL                | ftfloat     | double      |
| or DOUBLE[...]     |                     |             |             |
| CURRENCY           | REAL                | ftcurrency  | double!     |
| DATETIME or        | REAL                | ftdatetime  | tdatetime   |
|  TIMESTAMP         |                     |             |             |
| DATE               | REAL                | ftdate      | tdatetime   |
| TIME               | REAL                | fttime      | tdatetime   |
| NUMERIC[...]       | INTEGER 8 (*10'000) | ftbcd       | currency    |
| VARCHAR[(n)]       | TEXT                | ftstring    | msestring   |
| TEXT               | TEXT                | ftmemo      | utf8 string |
| TEXT               | TEXT dso_stringmemo | ftstring    | msestring   |
| BLOB               | BLOB                | ftblob      | string      |
+--------------------+---------------------+-------------+-------------+

*** Do not use Sqlite3 in multi-threaded applications. Set treport.options 
reo_nothread to true for rendering a Sqlite3 report ***.

ZeosLib
*******
To install the Zeos components add the path to the Zeos source to 'Project'-
'Options'-'Make'-'Directories' and compile the IDE with -dmse_with_zeoslib.
Dependent of the Zeos version it will be necessary to add -MDelphi to 'Project'-
'Options'-'Make'-'Make options'.
There is a predefined IDE project apps/ide/mseide_zeos.prj, update 'Project'-
'Options'-'Macros' according to your installation.

