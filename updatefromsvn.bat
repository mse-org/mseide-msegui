@REM This script gets an update of MSEide+MSEgui into .\trunk or .\
@REM if .\ is a SVN directory
@REM from SVN and compiles MSEide. The new IDE is 
@REM .\trunk\apps\ide\mseide.exe or .\apps\ide\mseide.exe
@REM SVN 
@REM http://subversion.tigris.org/project_packages.html
@REM and FPC 2.2 
@REM http://www.freepascal.org/download.var
@REM must be installed on the system.
@REM 
@set DESTDIR=.
@if not exist .svn set DESTDIR=.\trunk
svn co https://mseide-msegui.svn.sourceforge.net/svnroot/mseide-msegui/trunk %DESTDIR%
@if errorlevel 1 goto err
cd %DESTDIR%
ppc386.exe -Fulib\common\* -B -Fulib\common\kernel\i386-win32 -Filib\common\kernel apps\ide\mseide.pas
@if errorlevel 1 goto err1
@echo Success:
@echo MSEide compiled to %DESTDIR%\apps\ide\mseide.exe
:err1
@if %DESTDIR%==.\trunk cd ..
:err
@set DESTDIR=
