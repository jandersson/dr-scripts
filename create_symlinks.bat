@ECHO OFF
Set _Destination=%LICH_SCRIPTS%

FOR /f %%a IN (
 'dir /b *.lic'
 ) DO (
 call:symlink %%a
)

rmdir %_Destination%\profiles
mklink /h /j %_Destination%\profiles .\profiles
rmdir %_Destination%\data
mklink /h /j %_Destination%\data .\data

goto:eof

:symlink
del %_Destination%\%~1
mklink %_Destination%\%~1 %~dp0%~1
REM mklink /H %_Destination%\%~1 .\%~1