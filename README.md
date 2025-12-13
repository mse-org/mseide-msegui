# MSEide+MSEgui Pascal Cross Platform GUI Development System

2025-12-13 Version 5.12.0.
Copyright (c) 1999-2025 by Martin Schreiber and friends.

MSEgui is a complete independent Free Pascal widgetset.
It does not use any other widgetsets like GTK2/GTK3/Qt4/Qt5.
MSEgui interacts on Unix directly with X11 server (like other widgetsets do).
On Windows, it deals with the low level Windows GDI interface.

MSEgui is like a GTK2/GTK3/Qt5 widgetset with same look-and-feel on each OS (Linux, FreeBSD, OpenBSD, NetBSD, MacOS and Windows).
And because it is developed in Pascal, you have full control on the widgetset.

## Features

- Compiles with FPC 2.6.4, 3.0.0, 3.0.2, 3.2.0, 3.2.2. and 3.3.1.
- Compiles with FPC-LLVM 3.3.1.
- For FreeBSD-x86_64, FreeBSD-i386, FreeBSD-aarch64,
  Linux-x86_64, Linux-i386,
  Linux-Rpi-arm32, Linux-Rpi-aarch64,
  NetBSD-x86_64, NetBSD-i386,
  OpenBSD x86_64, OpenBSD-i386,
  DragonFlyBSD x86_64, 
  Darwin-MacOs-x86_64, Darwin-MacOs-aarch64,
  Windows-i386, Windows-x86_64.
- Links to xlib and gdi32, no external widget library needed.
- Internal character encoding is UTF-16.
- Uses anti-aliased fonts on Linux (Xft).
- All screen drawing is double-buffered.
- Has docking forms and MDI.
- Has embedded forms (similar to TFrame).
- Has sophisticated database access components and data edit widgets.
- Internationalization functionality with resource modules.
- Report generator.
- BGRABitmap graphic library compatible.

## IDE

- Integrated debugging.
- Source code highlighting.
- Source code navigation with support for include files.
- Code completion for classes.
- Procedures list.
- Integrated visual form designer with source code update for components and
  events.
- Flexible and handy build system with switchable macros.
- Visual form inheritance.
- Integrated report designer.

## About MSEide+MSEgui

MSEide+MSEgui is exclusively designed for use with Free Pascal (FPC). It is not compatible with Delphi or Lazarus.

## Demos and Examples

To get the most out of MSEide+MSEgui, we highly recommend exploring our extensive collection of demos located in this repository. These demos are tailored to showcase various aspects of MSEgui's capabilities, usage patterns, and how to address common programming tasks with FPC. 

- **Demos in package**: in the mseide-msegui/apps/ folder.
- **Demos from mseuniverse**: https://github.com/mse-org/mseuniverse
  
Before you ask questions, contribute, or report issues, please take a moment to look through these demos. They can provide insights, solutions, and a better understanding of MSEide+MSEgui's functionality.

[![Examples](https://img.shields.io/badge/Examples-Important-orange)](/apps)

[![Examples](https://img.shields.io/badge/Examples-Important-orange)](https://github.com/mse-org/mseuniverse)

## License

IDE and tools are under GPL, library under modified LGPL like FPC-RTL.
Package maintainers may delete the files "apps/ide/COPYING.GPL",
"lib/common/COPYING.LGPL" and "lib/common/COPYING.MSE".

## Installation

1. Download and install FPC, you can get it from 
   http://www.freepascal.org/download.var
2. Download MSEide+MSEgui source from 
   https://github.com/mse-org/mseide-msegui/archive/master.zip
3. Extract them to a directory of your choice. For example "/home/myself/mseide-msegui".
4. Download and unzip mseide binary according your OS from here:
   https://github.com/mse-org/mseide-msegui/releases/
5. Run '/directory-of-unzipped/mseide_linxx/mseide' on Linux or FreeBSD
   or 'directory-of-unzipped\mseide_winxx\mseide.exe' on Windows.
6. In 'Settings'-'Configure MSEide'-'${MSEDIR}' select the root directory of MSEgui source. 
   For example "/home/myself/mseide-msegui"
7. In 'Project'-'Open' select '/home/myself/mseide-msegui/apps/demo/demo.prj'.
8. 'Target'-'Continue'.

Video of installation + load/run demo:
https://user-images.githubusercontent.com/3421249/198116838-e3eaa3ca-0150-4df5-8c9f-b23bd945f5ba.mp4

If you get the error "/usr/bin/ld: cannot find -lX11" install the
libX11-devel or libX11-dev package or make a symbolic link
/usr/lib/libX11.so -> /usr/lib/libX11.so.6
see
https://bugs.freepascal.org/view.php?id=32367

## Other installation methods

### Bash installer

There is a Bash installer for Linux that you can find [here](https://github.com/rchastain2/scripts/tree/main/install-mseide).

The script clones the git repository, build the IDE, and creates a desktop shortcut.

The **-d** option allows to choose installation root directory.

```bash
sh install-mseide.sh -d $HOME
```

## If you want to compile the IDE

1. In 'Project'-'Open' select 'sourcedirectory/apps/ide/mseide.prj'.
2. 'Target'-'Continue'.

### Compiling MSEide from commandline

On Unix:

```
fpc -Fulib/common/* -Fulib/common/kernel/linux apps/ide/mseide.pas
```

On Windows:

```
fpc -Fulib\common\* -Fulib\common\kernel\windows apps\ide\mseide.pas
```

### If FPC crashes while compiling try on Linux and FreeBSD

```
fpc -B -Fulib/common/* -Fulib/common/kernel/linux apps/ide/mseide.pas
```

On Windows:

```
fpc -B -Fulib\common\* -Fulib\common\kernel\windows apps\ide\mseide.pas
```

## Creating a new GUI project

'Project'-'New'-'From Template', select "default.prj"

## Creating a new console project

'Project'-'New'-'From Template', select "console.prj"

## MSEide command-line parameters

```
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
```

## MSEide environment variables

Macros in 'Settings'-'Configure MSEide' can be overridden by environment
variables. They will be overriden by --macrodef and 'Project'-'Options'-'Macros'.

Possible names:
FPCDIR, FPCLIBDIR, MSEDIR, MSELIBDIR, SYNTAXDEFDIR, TEMPLATEDIR,
COMPSTOREDIR, COMPILER, DEBUGGER, EXEEXT, TARGET, TARGETOSDIR.

## MSEide project macros

Predefined project macros:
PROJECTNAME, PROJECTDIR, MAINFILE, TARGETFILE,
TARGETENV (in format for "env" unix command), TARGETPARAMS,
they can be overridden by 'Project'-'Options'-'Macros'.

## MSEide macro functions

```
${MAC_IFDEF(macroname)} returns the macro value if defined.
${MAC_IFDEF(macroname,notdefinedvalue)} returns the macro value if defined,
 notdefinedvalue otherwise.
${MAC_IFDEF(macroname,notdefinedvalue,definedvalue)}
 returns definedvalue if macroname is defined, notdefinedvalue otherwise.
```

## MSEide environment macros

```
${ENV_VAR(variablename)} returns the variable value if defined.
${ENV_VAR(variablename,notdefinedvalue)} returns the variable value if defined,
 notdefinedvalue otherwise.
${ENV_VAR(variablename,notdefinedvalue,definedvalue)}
 returns definedvalue if variablename is defined, notdefinedvalue otherwise.
```

## MSEide string macros

```
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
```

## MSEide file macros

```
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
```

## MSEide exec macros

```
${EXEC_OUT(commandline[,timeoutms])}
 Executes commandline, returns the process output. Timeout in
 milli seconds, default = 1000, -1 = infinite.
```

## MSEide macros in 'Project'-'Options'-'Debugger'-'xterm Command'

```
${PTS} expands to tty pts path.
${PTSN} expands to tty pts number.
${PTSH} expands to tty pts handle.
Entering an empty string restores the default.
```

## MSEide external tools parameters macros

Predefined macros in 'Project'-'Options'-'Tools'-'Parameters':

```
CURSOURCEFILE current source file.
CURMODULEFILE current *.mfm file.
CURSSELECTION selected text in source editor.
CURSWORD word at cursor in source editor
CURSDEFINITION} definition of the current token at cursor
 (Ctrl+LClick destination), needs activated P-column
 (Parse source before call) to be current.
CURCOMPONENTCLASS current selected component class in form editor.
CURPROPERTY current selected property in object inspector.
```

## Known issues

### Antialiased text with MSEgui 32-bit on 64-bit Linux

MSEgui uses Xft for antialiased fonts on Linux. Please install lib32-libxft
package if necessary.

### Popup widgets behind the forms

If the popup widgets are showed behind the forms, try to start the
MSEgui program with the option '--TOPLEVELRAISE'. Do *not* use this option
if is not necessary (KDE, Gnome... work well without).

### Display problems with Linux radeon and other EXA drivers

If the display is distorted or slow add
Option "EXAPixmaps" "off"
to
Section "Device"
of xorg.conf, see
https://bugs.freedesktop.org/show_bug.cgi?id=69543
https://bugs.freedesktop.org/show_bug.cgi?id=84253
or use the proprietary video driver for your video chip.

### Flashing taskbar widgets in IceWM

Newer revisions of IceWM let the taskbar icons of MSEgui applications flash.
Start the MSEgui application with the option '--TOPLEVELRAISE'.

### Invalid inputmanager for Ubuntu

The utf-8 setup in Ubuntu seems to be incomplete. If you get the exception
"egui : Invalid inputmanager tinternalapplication" at program start, try to
replace your language locale in /usr/share/X11/locale/locale.dir
by en_US as a workaround. Example for ru_RU.UTF-8:
replace
ru_RU.UTF-8/XLC_LOCALE ru_RU.UTF-8
by
en_US.UTF-8/XLC_LOCALE ru_RU.UTF-8

### Wrong window positions for Ubuntu 14.04

Window positions in Unity are wrong because the Ubuntu windowmanager
does not support static_gravity:
http://askubuntu.com/questions/451903/wingravity-static-gravity-not-suppo
https://bugs.launchpad.net/ubuntu/+bug/1312044
http://askubuntu.com/questions/457456/wingravity-static-gravity-not-supported-in-14-04

## How to add custom components to MSEide

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

- Convert 24x24 pixel BMP or PNG files with tools/bmp2pas to
  an icon unit ('*_bmp.pas').
- Add the name of the icon unit to 'uses' in your register unit.

## How to run i18ndemo

```
- Start MSEide.
- 'Project'-'Open'-'yourdirectory/msegui/apps/i18ndemo/i18ndemo.prj'.
- 'Project'-'Make' to create the rsj files.
- 'Project'-'Open'-'yourdirectory/msegui/tools/i18n/msei18n.prj'.
- 'Target'-'Continue'.
```

In MSEi18n:

```
 - Adjust 'Settings'-'Configure MSEi18n'-'${MSEDIR}' and ${COMPILER}.
 - 'Open'-'yourdirectory/msegui/apps/i18ndemo/i18ndemo.trp'
 - 'Make'.
 - Close message window.
 - Close MSEi18n.
 - 'Project'-'Open'-'yourdirectory/msegui/apps/i18ndemo/i18ndemo.prj'.
 - 'Target'-'Continue'.
```

## SQLite

tsqlite3connection field type mapping:

```
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
```

## ZeosLib

Since msegui commit fbbaa979b, ZeosLib components are included in mseide by default.
Also last stable source are included in /mseide-msegui/lib/common/mzeoslib/.

If you want to use other ZeosLib source, you need to delete directory /mseide-msegui/lib/common/mzeoslib/.
Then add the path to the ZeosLib source to 'Project'-'Options'-'Make'-'Directories' and compile your applicatio with '-dMSEgui'.

If you want to recompile the IDE with new ZeosLib source, add parameter '-dmse_with_zeoslib -dMSEgui'.
There is a predefined IDE project apps/ide/mseide_zeos.prj, update 'Project'-
'Options'-'Macros' according to your installation.

## Crosscompiling and remote debugging i386/x84_64-linux -> arm-linux

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
'Project'-'Options'-'Debugger'-'Target'-'Wait before connect' value.

Have a lot of fun!

Martin
