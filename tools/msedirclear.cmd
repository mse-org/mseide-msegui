@echo off
if "%1"=="" @echo A directory must be supplied! & exit -1
dir /ad %1
if not %errorlevel% equ 0 (@echo %1 must be an existing directory! & exit -1)
for /R %%F in ("%1") do cd %%F && del *.o 2>nul & del *.ppu 2>nul & del *.a 2>nul & for %%M in (*.mfm) do form2pas %%M
