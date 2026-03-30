:; set -e
:; echo 
:; printf "Compile Magda program: %s.magda (Magda parser step)" "$@"
:; echo
:; cp Magda/src/$@/$@.magda ./ > tmp.log
:; rm tmp.log
:; 
:; if [ ! -d "Magda/src/$@/obj" ]; then
:;     mkdir "Magda/src/$@/obj"
:; fi
:; 
:; if java Magda.Parser.Parser $@.magda > Magda/src/$@/obj/MagdaProgram.java;then
:;     rm $@.magda 
:; else
:;     rm $@.magda
:;     exit 1
:; fi
:; 
:; echo 
:; printf "Compile Magda program: $@ (Java compiler step)"
:; echo
:; javac Magda/src/$@/obj/*.java -Xlint
:; 
:; echo 
:; echo JOB DONE!
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
echo Compile Magda program: %PROGRAM%.magda (Magda parser step)
echo.

copy /y "Magda\src\%PROGRAM%\%PROGRAM%.magda" . > tmp.log
if errorlevel 1 exit /b 1
del tmp.log

if not exist "Magda\src\%PROGRAM%\obj\" (
    mkdir "Magda\src\%PROGRAM%\obj"
)

:: Run the Java parser
java Magda.Parser.Parser "%PROGRAM%.magda" > "Magda\src\%PROGRAM%\obj\MagdaProgram.java"
if errorlevel 1 (
    del "%PROGRAM%.magda"
    exit /b 1
)

del "%PROGRAM%.magda"

echo Compile Magda program: %PROGRAM% (Java compiler step)
echo.

javac Magda\src\%PROGRAM%\obj\*.java -Xlint
if errorlevel 1 exit /b 1

echo JOB DONE!
echo.

