@echo off
REM ============================================================================
REM FaceFusion Pinokio Launcher - newcherry Branch (v3.5.1 with NSFW Disabled)
REM ============================================================================
REM This script starts FaceFusion in the Pinokio environment with NSFW disabled
REM Location: Pinokio's facefusion-pinokio.git directory
REM ============================================================================

setlocal enabledelayedexpansion

REM Colors and formatting
for /F %%A in ('copy /Z "%~f0" nul') do set "BS=%%A"

echo.
echo ============================================================================
echo  FaceFusion Pinokio Launcher - newcherry Branch
echo ============================================================================
echo.
echo  Version: 3.5.1 (Latest)
echo  Branch: newcherry (NSFW Disabled)
echo  Date: December 7, 2025
echo.

REM Check if virtual environment exists
if not exist ".venv\Scripts\activate.bat" (
    echo [WARNING] Virtual environment not found at .venv
    echo [INFO] Creating virtual environment...
    python -m venv .venv
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment
        echo [ERROR] Make sure Python is installed and accessible
        pause
        exit /b 1
    )
)

REM Activate virtual environment
echo [INFO] Activating virtual environment...
call .venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERROR] Failed to activate virtual environment
    pause
    exit /b 1
)

REM Verify dependencies
echo [INFO] Verifying dependencies...
python -m pip check >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Dependency issues detected
    echo [INFO] Run: update-pinokio-newcherry.bat to fix dependencies
)

REM Display NSFW status
echo.
echo [INFO] NSFW Status Check:
python -c "import sys; sys.path.insert(0, '.'); from facefusion import content_analyser; status='DISABLED (✓)' if not content_analyser.analyse_frame(None) else 'ENABLED (✗)'; print(f'    NSFW Detection: {status}')" 2>nul

REM Display branch info
echo [INFO] Branch: newcherry (v3.5.1)
echo.

REM Start FaceFusion UI
echo [INFO] Starting FaceFusion UI...
echo [INFO] UI will be available at: http://localhost:7860
echo.
echo ============================================================================
echo  Press Ctrl+C to stop FaceFusion
echo ============================================================================
echo.

python facefusion.py --ui-headless=False --ui-analytics=False 2>&1

REM Check exit status
if errorlevel 1 (
    echo.
    echo [ERROR] FaceFusion exited with error
    echo [INFO] Check logs above for details
    echo [INFO] Common issues:
    echo   - Missing dependencies: Run update-pinokio-newcherry.bat
    echo   - Port 7860 in use: Close other FaceFusion instances
    echo   - GPU issues: Ensure GPU drivers are up to date
    pause
    exit /b 1
)

echo.
echo [INFO] FaceFusion shutdown gracefully
echo.
pause
