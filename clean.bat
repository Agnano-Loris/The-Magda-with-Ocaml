:; set -e
:; printf "Removing all compiled files in the entire project"
:; 
:; find Magda -type f -name "*.class" -delete
:; find Magda/CompiledCode -type f -name "MagdaProgram.java" -delete
:; find Magda/src/*/obj -type f -name "MagdaProgram.java" -delete
:; rm Magda/Parser/*.java -f
:; rm Magda/PreParser/*.java -f
:; 
:; echo 
:; printf "Removal was successful"
:; echo
:; 
:; exit


@echo off
setlocal enabledelayedexpansion

echo Removing all compiled files in the entire project

:: Delete all .class files recursively in Magda
for /r Magda %%f in (*.class) do del "%%f"

:: Delete MagdaProgram.java in specific folders
del /q "Magda\CompiledCode\MagdaProgram.java" 2>nul
for /d %%d in (Magda\src\*) do (
    if exist "%%d\obj\MagdaProgram.java" del /q "%%d\obj\MagdaProgram.java"
)

:: Delete generated Java files in Parser and PreParser
del /q "Magda\Parser\*.java" 2>nul
del /q "Magda\PreParser\*.java" 2>nul

echo Removal was successful
