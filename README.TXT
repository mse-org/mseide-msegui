MSEide+MSEgui Pascal Cross Platform GUI Development System.

2014-08-20 Version 3.4a
Copyright (c) 1999-2014 by Martin Schreiber

* 2.8.6 -> 3.0:
* MSEgui now has own implementations for "classes" and "db" units.
* FPC has no support for unit alias
* http://www.mail-archive.com/fpc-pascal%40lists.freepascal.org/msg31117.html
* Please change "db" to "mdb" in uses and add 
* "mclasses" after "classes" in uses in your units

- Compiles with FPC 2.6.2 or 2.6.4
- Tested on i386-linux SuSE 13.1, x86_64-linux SuSE 13.1, x86_64-freebsd,
  i386-win32 2000, XP and Vista.
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
IDE and tools are under GPL, library under modified LGPL like FPC-RTL.
Package maintainers may delete the files "apps/ide/COPYING.GPL", 
"lib/common/COPYING.LGPL" and "lib/common/COPYING.MSE".

Installation:
*************
1. Download and install FPC 2.6.4, you can get it from 
   http://www.freepascal.org/download.var
2. Download mseide_msegui_src_3_4a.zip and mseide_i386_win32_3_4a.zip or
   mseide_i386_linux_3_4a.tar.gz or mseide_x84_64_linux_3_4a.tar.gz or
   mseide_x84_64_freebsd_3_4a.tar.gz
   http://sourceforge.net/projects/mseide-msegui/files/mseide-msegui/3.4/
3. Extract them to a directory of your choice ('yourdirectory') .
4. Run 'yourdirectory/bin/mseide' on linux or 
   'yourdirectory\bin\mseide.exe' on windows.
5. In 'Settings'-'Configure MSEide'-'${MSEDIR}' select 'yourdirectory/msegui'.
6. In 'Project'-'Open' select 'yourdirectory/msegui/apps/demo/demo.prj'.
7. 'Target'-'Continue'.

If you wish to to compile the IDE:

1. In 'Project'-'Open' select 'yourdirectory/msegui/apps/ide/mseide.prj'.
2. 'Target'-'Continue'.

Compiling MSEide from commandline on Linux and FreeBSD:
fpc -Fulib/common/* -Fulib/common/kernel/linux apps/ide/mseide.pas
On Windows:
ppc386.exe -Fulib\common\* -Fulib\common\kernel\windows apps\ide\mseide.pas


Creating a new GUI project
**************************
'Project'-'New'-'From Template', select "default.prj"

Creating a new console project
******************************
'Project'-'New'-'From Template', select "console.prj"

MSEgui command line parameters
******************************
--NOZORDERHANDLING
 Do not touch Z-order of the windows.
--NORESTACKWINDOW
 Do not use the NET_RESTACK_WINDOW protocol.
--RESTACKWINDOW
 Use the NET_RESTACK_WINDOW protocol.
--NORECONFIGUREWMWINDOW
 Do not use xreconfigurewmwindow() for window stacking operation.
--RECONFIGUREWMWINDOW
 Use xreconfigurewmwindow() for window stacking operation.
--STACKMODEBELOWWORKAROUND
 Necessary for windowmanagers with buggy xreconfigurewmwindow() handling.
--NOSTACKMODEBELOWWORKAROUND
 No workaround.
--TOPLEVELRAISE
 Use the top level frame window id instead of the application client window id
 for window raise operation. Implies --NORESTACKWINDOW and
 --NORECONFIGUREWMWINDOW.
--NOSTATICGRAVITY
 Simulates staticgravity for buggy window managers.
 
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
--fontalias=<alias>,<fontname>[,<fontheight>[,<fontwidth>[,<options>[,<xscale>]
                              [,<ancestor>]]]]
 Change the used fonts. <alias> can be stf_default, stf_menu or mseide_source.
 
MSEide environment variables
****************************
Macros in 'Settings'-'Configure MSEide' can be overridden by environment
variables. They will be overriden by --macrodef and 'Project'-'Options'-'Macros'.
Possible names: 
FPCDIR, FPCLIBDIR, MSEDIR, MSELIBDIR, SYNTAXDEFDIR, TEMPLATEDIR,
COMPSTOREDIR, COMPILER, DEBUGGER, EXEEXT, TARGET, TARGETOSDIR.

MSEide project macros
*********************
Predefined project macros:
PROJECTNAME, PROJECTDIR, MAINFILE, TARGETFILE, they can be overridden by 
'Project'-'Options'-'Macros'.

MSEide file macros
******************
Macro format is ${FILE_*(fileparameter)} or ${FILE_*("fileparameter")}.
FILE_MSE    convert to MSE format.
FILE_SYS    convert to sys format.
FILE_PATH   absolute path.
FILE_FILE   no trailing path delimiter.
FILE_DIR    trailing path delimiter.
FILE_NAME   no directory part.
FILE_EXT    file name extension.
FILE_NONAME directory part only.
FILE_NOEXT  no file name extension.

MSEide macros in 'Project'-'Options'-'Debugger'-'xterm Command'
***************************************************************
${PTS} expands to tty pts path.
${PTSN} expands to tty pts number.
${PTSH} expands to tty pts handle.
Entering an empty string restores the default.

MSEide external tools parameters macros
***************************************
Predefined macros in 'Project'-'Options'-'Tools'-'Parameters':
CURSOURCEFILE current source file.
CURMODULEFILE current *.mfm file.
CURSSELECTION selected text in source editor.
CURSWORD word at cursor in source editor
CURSDEFINITION} definition of the current token at cursor 
 (Ctrl+LClick destination), needs activated P-column
 (Parse source before call) to be current.
CURCOMPONENTCLASS current selected component class in form editor.
CURPROPERTY current selected property in object inspector.

Antialiased text with MSEgui 32 bit on 64 bit Linux
****************************************************
MSEgui uses Xft for antialiased fonts on Linux. Please install lib32-libxft
package if necessary.

Popup widgets behind the forms
******************************
If the popup widgets are showed behind the forms, try to start the 
MSEgui program with the option '--TOPLEVELRAISE'. Do *not* use this option
if is not necessary (KDE, Gnome... work well without).

Display problems with Linux radeon driver
*****************************************
If the display is distorted or slow add 
Option "EXAPixmaps" "off"
to 
Section "Device"
of xorg.conf, see
https://bugs.freedesktop.org/show_bug.cgi?id=69543

Flashing taskbar widgets in IceWM
*********************************
Newer revisions of IceWM let the taskbar icons of MSEgui applications flash.
Start the MSEgui application with the option '--TOPLEVELRAISE'.

Invalid inputmanager for Ubuntu
*******************************
The utf-8 setup in Ubuntu seems to be incomplete. If you get the exception
"egui : Invalid inputmanager tinternalapplication ." at program start, try to
replace your language locale in /usr/share/X11/locale/locale.dir
by en_US as a workaround. Example for ru_RU.UTF-8:
replace 
ru_RU.UTF-8/XLC_LOCALE ru_RU.UTF-8
by
en_US.UTF-8/XLC_LOCALE ru_RU.UTF-8

Wrong window positions for Ubuntu 14.04
***************************************
Window positions in Unity are wrong because the Ubuntu windowmanager
does not support static_gravity:
http://askubuntu.com/questions/451903/wingravity-static-gravity-not-suppo
https://bugs.launchpad.net/ubuntu/+bug/1312044
http://askubuntu.com/questions/457456/wingravity-static-gravity-not-supported-in-14-04

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

- Convert 24*24 pixel BMP or PNG files with tools/bmp2pas to
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
tsqlite3connection field type mapping:

      Type name        SQLite storage class  Field type    Data type
+--------------------+---------------------+-------------+-------------+
| INTEGER or INT     | INTEGER 4           | ftinteger   | integer     |
| LARGEINT           | INTEGER 8           | ftlargeint  | largeint    |
| BIGINT             | INTEGER 8           | ftlargeint  | largeint    |
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

ZeosLib
*******
In order to install the Zeos components add the path to the Zeos source to 
'Project'-'Options'-'Make'-'Directories' and compile the IDE with
-dmse_with_zeoslib -dMSEgui.
There is a predefined IDE project apps/ide/mseide_zeos.prj, update 'Project'-
'Options'-'Macros' according to your installation.

Have a lot of fun!

Martin