MSEide+MSEgui Pascal Cross Platform GUI Development System.
Version 0.9

- Compiles with FPC 2.0.2
- Tested on i386-linux SuSE 9.0,9.2,10.0 and i386-win32 98 and 2000.
- Links to xlib and gdi32, no external widget library needed.
- Internal character encoding is UCS2.
- Uses anti aliased fonts on Linux (Xft).
- All screen drawing is double buffered.
- Has docking forms.
- Has embedded forms (similar to TFrame).
- Internationalization functionality with resource modules.

IDE:
- Integrated debugging.
- Source code highlighting.
- Source code navigation with support for include files.
- Code completion for classes.
- Integrated visual form designer with source code update for components and 
events.
- Flexible and handy build system with switchable macros.

License:
IDE is under GPL, library under modified LGPL like FPC-RTL.

Installation:
*************
1. Download and install FPC 2.0.2, you can get it from http://www.freepascal.org/download.html
2. Download src and bin zip's.
3. Extract them to a directory of your choice ('yourdirectory') .
4. Run 'yourdirectory/bin/i386-linux/mseide' on linux or 
'yourdirectory\bin\i386-win32\mseide.exe' on windows.
5. In 'Settings'-'Configure MSEide'-'${MSEDIR}' select 'yourdirectory/msegui'.
5a. On windows you have to setup ${COMPILER} (ppc386.exe) and ${DEBUGGER} (gdb.exe).
6. In 'Project'-'Open' select 'yourdirectory/msegui/apps/demo/demo.prj'.
7. 'Target'-'Continue'.

If you wish to to compile the IDE:

1. In 'Project'-'Open' select 'yourdirectory/msegui/apps/ide/mseide.prj'.
2. 'Target'-'Continue'.

Debugging
*********
Breakpoints don't work on win32 in units compiled with -CX 
(create smartlinked units).

How to add custom components to MSEide
**************************************
There is a project 'apps/myide/mymseide.prj' as a demo.
Start MSEide, open project 'apps/myide/mymseide.prj', 'Project'-'Build', 'Target'-'Continue',
the IDE with the new component 'tmybutton' will be compiled and
started in the the debugger.
Binaryname is 'mymseide' (linux) or 'mymseide.exe' (win32).

If you wish to do it from scratch:

- Create a register unit for your components 
  (see 'apps/myide/regmycomps.pas' for an example).
- Enter the unitname followed by a comma 
  ('myregunit,' if your regunitfile is 'myregunit.pas') in 
  a file named 'regcomponents.inc'.
- build the ide with -dmorecomponents as option.

If you want add custom icons to your components:

- Convert 24*24 pixel BMP files with tools/bmp2pas to
  a icon unit ('*_bmp.pas').
- add the name of the icon unit to 'uses' in your register unit.
 
How to run i18ndemo
*******************
- Start MSEide version 0.9.
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

FPC patches
***********
In patch_fpc_2_0_3 are the needed modified FPC files for MSEgui 
and FPC 2.0.3.
There are some fixes to let the FPC compiler work with -Fcutf8,
and some hotfixes for DB-issues.
In lib/common/kernel/i386-linux is the modified file cwstring.pp
to get thread safe unicode<>locale text conversion on linux.
With the original FPC file there can be destroyed source files with
FPC 2.0.2 and FPC 2.0.3.

SQLite
******
To install SQLite support into the IDE compile the ide with -dmse_with_sqlite
(experimental, needs installed libsqlite3.so (linux) or sqlite3.dll (win32)
on your system.
