@echo off
setlocal EnableExtensions

REM ============================================================================
REM build-windows.bat — Build et lance le builder pour r-type (Windows)
REM ----------------------------------------------------------------------------
REM Usage :
REM   build-windows.bat           → build le jar si nécessaire puis génère le .fd/.t2
REM   build-windows.bat --clean   → force le rebuild du jar Java
REM
REM Prérequis : Java 11+, Maven 3.6+
REM ============================================================================

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

pushd "%SCRIPT_DIR%\..\.."
set "ENGINE_ROOT=%CD%"
popd

set "GENERATOR_DIR=%ENGINE_ROOT%\java-generator"
set "JAR_NAME=game-engine-0.0.1-SNAPSHOT-jar-with-dependencies.jar"
set "JAR_PATH=%GENERATOR_DIR%\target\%JAR_NAME%"
set "CONFIG=.\config-windows.properties"
set "CLEAN=0"

:parse_args
if "%~1"=="" goto args_done
if /i "%~1"=="--clean" (
    set "CLEAN=1"
    shift
    goto parse_args
)
echo Unknown option: %~1 1>&2
exit /b 1

:args_done

where java >nul 2>&1 || (echo Error: java introuvable dans PATH 1>&2 & exit /b 1)
where mvn >nul 2>&1 || (echo Error: mvn introuvable dans PATH 1>&2 & exit /b 1)

if "%CLEAN%"=="1" goto build_jar
if exist "%JAR_PATH%" goto run_builder

:build_jar
echo ==^> Build du générateur Java...
pushd "%GENERATOR_DIR%"
call mvn clean compile assembly:single
if errorlevel 1 (
    popd
    exit /b 1
)
popd
if not exist "%JAR_PATH%" (
    echo Error: jar non produit à %JAR_PATH% 1>&2
    exit /b 1
)

:run_builder
cd /d "%SCRIPT_DIR%"
echo ==^> Génération du jeu depuis %CONFIG% ...
java -Xverify:none -jar "%JAR_PATH%" "%CONFIG%"
if errorlevel 1 exit /b 1

echo.
echo ==^> Build terminé. Outputs :
if exist dist (
    dir dist\
) else (
    echo   (dossier dist\ non trouvé)
)

endlocal
