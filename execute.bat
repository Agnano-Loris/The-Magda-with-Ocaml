:; set -e
:; echo
:; printf "Execute %s Magda program\n\n" "$@"
:; cp Magda/src/$@/obj/*.* ./Magda/CompiledCode > tmp.log
:; rm tmp.log
:; java Magda.CompiledCode.MagdaProgram
:; echo
:; 
:; exit

@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Please provide the program name as an argument.
    exit /b 1
)

set PROGRAM=%~1

echo.
echo Execute %PROGRAM% Magda program
echo.

:: Copy all files from obj to CompiledCode
xcopy /y /q "Magda\src\%PROGRAM%\obj\*.*" "Magda\CompiledCode\"
if errorlevel 1 exit /b 1

:: Run the Java program
java Magda.CompiledCode.MagdaProgram
if errorlevel 1 exit /b 1

echo.
