@echo off
REM Aggressive NSFW disable verification and fix for Pinokio
REM This script verifies and reinforces NSFW disable patches

echo.
echo ===================================================
echo FaceFusion NSFW Disable - Verification & Fix
echo ===================================================
echo.

cd /d g:\pinokio.home\api\facefusion-pinokio.git\facefusion

echo [1] Checking current branch...
git branch --show-current
echo.

echo [2] Verifying NSFW patches...
echo.

echo --- Checking content_analyser.py ---
findstr "# NSFW detection disabled" facefusion\content_analyser.py
if %ERRORLEVEL% EQU 0 (
    echo [OK] NSFW disable patch found
) else (
    echo [FAILED] NSFW disable patch NOT found - reapplying...
    cd facefusion
    powershell -Command "((Get-Content content_analyser.py) -replace 'def analyse_frame.*?\n.*?return detect_nsfw.*?\)', 'def analyse_frame(vision_frame : VisionFrame) -> bool:`n`t# NSFW detection disabled`n`treturn False') | Set-Content content_analyser.py"
    cd ..
)
echo.

echo --- Checking core.py ---
findstr "# Hash check disabled" facefusion\core.py
if %ERRORLEVEL% EQU 0 (
    echo [OK] Hash validation bypass found
) else (
    echo [FAILED] Hash check bypass NOT found - reapplying...
    echo Please manually reapply the patch
)
echo.

echo [3] Checking version...
findstr "version" facefusion\metadata.py
echo.

echo [4] Git Status...
git status --short
echo.

echo [5] Latest commits...
git log --oneline -3
echo.

echo [6] Testing FaceFusion startup...
python -c "from facefusion import core; print('✓ FaceFusion loaded successfully')"
if %ERRORLEVEL% EQU 0 (
    echo [OK] Application loads without errors
) else (
    echo [FAILED] Application failed to load - check dependencies
)
echo.

echo ===================================================
echo IMPORTANT: After verification, restart Pinokio!
echo 1. Close Pinokio completely
echo 2. Close any FaceFusion browser windows
echo 3. Reopen Pinokio
echo 4. Restart FaceFusion
echo ===================================================
echo.

pause
