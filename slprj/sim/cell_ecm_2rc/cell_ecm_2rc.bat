@echo off

call "setup_mingw.bat"


call  "\\Dhia\D$\Program Files\MATLAB\R2024b\bin\win64\checkMATLABRootForDriveMap.exe" "\\Dhia\D$\Program Files\MATLAB\R2024b"  > mlEnv.txt
for /f %%a in (mlEnv.txt) do set "%%a"\n
cd .

chcp 1252

if "%1"=="" ("%MINGW_ROOT%\mingw32-make.exe" MATLAB_ROOT=%MATLAB_ROOT% ALT_MATLAB_ROOT=%ALT_MATLAB_ROOT% MATLAB_BIN=%MATLAB_BIN% ALT_MATLAB_BIN=%ALT_MATLAB_BIN%  -j 6 -l 10 -Oline -f cell_ecm_2rc.mk all) else ("%MINGW_ROOT%\mingw32-make.exe" MATLAB_ROOT=%MATLAB_ROOT% ALT_MATLAB_ROOT=%ALT_MATLAB_ROOT% MATLAB_BIN=%MATLAB_BIN% ALT_MATLAB_BIN=%ALT_MATLAB_BIN%  -j 6 -l 10 -Oline -f cell_ecm_2rc.mk %1)
@if errorlevel 1 goto error_exit

exit /B 0

:error_exit
echo The make command returned an error of %errorlevel%
exit /B 1