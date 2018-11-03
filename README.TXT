MSEide+MSEgui Pascal Cross Platform GUI Development System.

2018-11-03 Version 4.6.2
Copyright (c) 1999-2018 by Martin Schreiber

- Compiles with FPC 3.0.2 or 3.0.4
- For FreeBSD-x86_64, Linux-i386, Linux-x86_64, Linux-arm(Raspberry Pi),
  Windows-i386, Windows-x86_64.
- Links to xlib and gdi32, no external widget library needed.
- Internal character encoding is utf-16.
- Uses anti aliased fonts on Linux (Xft).
- All screen drawing is double buffered.
- Has docking forms and MDI.
- Has embedded forms (similar to TFrame).
- Has sophisticated database access components and data edit widgets.
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
1. Download and install FPC 3.0.2 or 3.0.4, you can get it from 
   https://www.freepascal.org/download.var
2. Download mseide_msegui_src_4_6_2.zip and the mseide_* archive
   for your system.
   https://sourceforge.net/projects/mseide-msegui/files/mseide-msegui/4.6.2/
3. Extract them to a directory of your choice ('yourdirectory') .
4. Run 'yourdirectory/bin/mseide' on Linux and FreeBSD or 
   'yourdirectory\bin\mseide.exe' on windows.
5. In 'Settings'-'Configure MSEide'-'${MSEDIR}' select 'yourdirectory/msegui'.
6. In 'Project'-'Open' select 'yourdirectory/msegui/apps/demo/demo.prj'.
7. 'Target'-'Continue'.

If you get the error "/usr/bin/ld: cannot find -lX11" install the 
libX11-devel or libX11-dev package or make a symbolic link
/usr/lib/libX11.so -> /usr/lib/libX11.so.6
see 
https://bugs.freepascal.org/view.php?id=32367

If you wish to to compile the IDE:

1. In 'Project'-'Open' select 'yourdirectory/msegui/apps/ide/mseide.prj'.
2. 'Target'-'Continue'.

Compiling MSEide from commandline on Linux and FreeBSD:
fpc -Fulib/common/* -Fulib/common/kernel/linux apps/ide/mseide.pas
On Windows:
fpc -Fulib\common\* -Fulib\common\kernel\windows apps\ide\mseide.pas

If FPC crashes while compiling try on Linux and FreeBSD:
fpc -B -Fulib/common/* -Fulib/common/kernel/linux apps/ide/mseide.pas
On Windows:
fpc -B -Fulib\common\* -Fulib\common\kernel\windows apps\ide\mseide.pas

Creating a new GUI project
**************************
'Project'-'New'-'From Template', select "default.prj"

Creating a new console project
******************************
'Project'-'New'-'From Template', select "console.prj"

MSEgui command line parameters
******************************
--FONTALIAS=<alias>,<fontname>[,<fontheight>[,<fontwidth>[,<options>[,<xscale>]
                              [,<ancestor>]]]]
 Change the used fonts. Example for a 16 pixel height default font:
 --FONTALIAS=stf_default,,16

--NOZEROLINES
 Use 1-width lines instead of 0-width lines. X11 only. Workaround for buggy HW-accelerated
 X-servers which don't draw lineends exactly. Can degrade performance, see
 https://bugzilla.opensuse.org/show_bug.cgi?id=1021803

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

--globstatfile=<filepath> 
 Use <filepath> instead the default global MSEide status file.

--macrogroup=<n>
 Use 'Project'-'Options'-'Macros'-'Active group' number <n>, <n> = 1..6.

--macrodef=<name>,<value>{,<name>,<value>}
 Macro definition, will be overridden by 'Project'-'Options'-'Macros'. Example:
 --macrodef=MAC1,abc,MAC2,def
 defines ${MAC1} with value 'abc' and ${MAC2} with value 'def'.
--storeglobalmacros
 Store --macrodef defines as global 'Settings'-'Configure MSEide' macros and
 terminate MSEide.
   
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
PROJECTNAME, PROJECTDIR, MAINFILE, TARGETFILE,
TARGETENV (in format for "env" unix command), TARGETPARAMS,
they can be overridden by 'Project'-'Options'-'Macros'.

MSEide macro functions
**********************
${MAC_IFDEF(macroname)} returns the macro value if defined.
${MAC_IFDEF(macroname,notdefinedvalue)} returns the macro value if defined,
 notdefinedvalue otherwise.
${MAC_IFDEF(macroname,notdefinedvalue,definedvalue)}
 returns definedvalue if macroname is defined, notdefinedvalue otherwise.

MSEide environment macros
*************************
${ENV_VAR(variablename)} returns the variable value if defined.
${ENV_VAR(variablename,notdefinedvalue)} returns the variable value if defined,
 notdefinedvalue otherwise.
${ENV_VAR(variablename,notdefinedvalue,definedvalue)}
 returns definedvalue if variablename is defined, notdefinedvalue otherwise.

MSEide string macros
********************
Macro format is ${STR_*(text)}.
STR_TRIM
 Trim whitespace from the ends of text.
STR_TRIMLEFT
 Trim whitespace from the beginning of text.
STR_TRIMRIGHT
 Trim whitespace from the end of text.

STR_COALESCE
 Return first not empty value. Format is
 ${STR_COALESCE(text[,text...])} or
 ${STR_COALESCE("text"[,"text"...])}

MSEide file macros
******************
Macro format is ${FILE_*(fileparameter)} or ${FILE_*("fileparameter")}.
FILE_MSE       convert to MSE format.
FILE_SYS       convert to sys format.
FILE_PATH      absolute path.
FILE_FILE      no trailing path delimiter.
FILE_DIR       trailing path delimiter.
FILE_NAME      no directory part.
FILE_NAMEBASE  no directory and no name extension part.
FILE_EXT       file name extension.
FILE_NONAME    directory part only.
FILE_NOEXT     no file name extension.

MSEide exec macros
******************
${EXEC_OUT(commandline[,timeoutms])} 
 Executes commandline, returns the process output. Timeout in
 milli seconds, default = 1000, -1 = infinite.

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

Display problems with Linux radeon and other EXA drivers
********************************************************
If the display is distorted or slow add 
Option "EXAPixmaps" "off"
to 
Section "Device"
of xorg.conf, see
https://bugs.freedesktop.org/show_bug.cgi?id=69543
https://bugs.freedesktop.org/show_bug.cgi?id=84253
or use the proprietary video driver for your video chip.

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

Component units integrated by this mechanism don't need to be GPL, see 
apps/ide/COPYING.IDE

If you want to add custom icons to your components:

- Convert 24*24 pixel BMP or PNG files with tools/bmp2pas to
  an icon unit ('*_bmp.pas').
- Add the name of the icon unit to 'uses' in your register unit.
 
How to run i18ndemo
*******************
- Start MSEide.
- 'Project'-'Open'-'yourdirectory/msegui/apps/i18ndemo/i18ndemo.prj'.
- 'Project'-'Make' to create the rsj files.
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

Crosscompiling and remote debugging i386/x84_64-linux -> arm-linux
***********************************************************
For Raspberry Pi:
- Establish a ssh login without password (public key authentication).

On the i386/x84_64-linux host:
- install the scp program
- download and extract 
  https://sourceforge.net/projects/mseide-msegui/files/fpcrossarm/crossfpc-i386_linux_eabihf_3_0_5.tar.gz
  (or crossfpc-x86_64_linux_eabihf_3_0_5.tar.gz)
  to <your crossfpc directory>.

- Start MSEide, in 'Settings'-'Configure MSEide'-'Global Macros' add:

Name            Value

CROSSMSEDIR     <MSEide+MSEgui directory>
CROSSFPCDIR     <your crossfpc directory>
CROSSFPCVERSION 3.0.5
HOSTIP          <the IP address of the host>
REMOTEIP        <the IP address of the remote target>
REMOTEPORT      <the remote port, ex: 2345>
REMOTEUSER      pi

- 'Project'-'New'-'From Template', select "crossarmdefault.prj" or
  "crossarmconsole.prj".
- Create the new project.
- 'Project'-'Options'-'Macros', set the TARGETPROJECTDIR value to the project
  path in remote target, ex: "/home/pi/proj/testcase".
- Check the TARGETENV macro.
- If your application needs additional libraries copy them from Raspberry Pi
  /lib/arm-linux-gnueabihf or /usr/lib/arm-linux-gnueabihf to
  <your crossfpc directory>/eabihf/lib

Press F9 and hope the best. ;-)
If there is a debugger timeout at startup enlarge the 
'Project'-'Options'-'Target'-'Wait before connect' value.

Have a lot of fun!

Martin
