@echo off
setlocal enabledelayedexpansion

:: Argument 1: Target folder (default: current directory)
:: Argument 2: Min line threshold (default: 200)
set "TARGET_DIR=%~1"
if "%TARGET_DIR%"=="" set "TARGET_DIR=."

set "MIN_LINES=%~2"
if "%MIN_LINES%"=="" set "MIN_LINES=200"

:: Resolve absolute path
pushd "%TARGET_DIR%" 2>nul
if errorlevel 1 (
    echo Error: Directory "%TARGET_DIR%" not found.
    exit /b 1
)
set "ROOT_PATH=%CD%"
popd

echo ======================================================
echo Scanning: %ROOT_PATH%
echo Threshold: More than %MIN_LINES% lines
echo ======================================================
echo.

set "MATCH_COUNT=0"

:: Recursively loop through all files
for /r "%TARGET_DIR%" %%F in (*) do (
    set "FILE_PATH=%%F"
    
    :: Count lines using find
    set "LINE_COUNT=0"
    for /f "tokens=2 delims=:" %%C in ('find /c /v "" "%%F" 2^>nul') do (
        set "LINE_COUNT=%%C"
    )
    
    :: Strip leading whitespace from count
    set "LINE_COUNT=!LINE_COUNT: =!"
    
    if defined LINE_COUNT (
        if !LINE_COUNT! GTR %MIN_LINES% (
            set /a MATCH_COUNT+=1
            
            :: Compute relative path
            set "REL_PATH=%%F"
            set "REL_PATH=!REL_PATH:%ROOT_PATH%\=!"
            
            echo [!LINE_COUNT! lines]  !REL_PATH!
        )
    )
)

echo.
if %MATCH_COUNT% EQU 0 (
    echo No files found exceeding %MIN_LINES% lines.
) else (
    echo Total files exceeding threshold: %MATCH_COUNT%
)

endlocal
