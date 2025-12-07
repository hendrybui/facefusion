@echo off
REM Test script to verify NSFW is disabled in newcherry branch

echo Testing newcherry branch v3.5.1 with NSFW disabled...
echo.

REM Show current branch
git branch --show-current
echo.

REM Show version
echo Checking version:
findstr "version" facefusion\metadata.py 2>nul || echo Version info not found

echo.
echo Verifying NSFW patches:
echo.

echo 1. Checking analyse_frame patch in content_analyser.py:
findstr /N "# NSFW detection disabled" facefusion\content_analyser.py
if %ERRORLEVEL% EQU 0 (
    echo [OK] NSFW detection is disabled
) else (
    echo [FAILED] NSFW detection patch not found
)

echo.
echo 2. Checking hash validation bypass in core.py:
findstr /N "# Hash check disabled" facefusion\core.py
if %ERRORLEVEL% EQU 0 (
    echo [OK] Hash validation is bypassed
) else (
    echo [FAILED] Hash check bypass not found
)

echo.
echo Test complete!
echo.
pause
