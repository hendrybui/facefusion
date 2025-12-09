@echo off
REM ============================================================================
REM FaceFusion Launcher - Vino+window Branch (OpenVINO Optimized)
REM ============================================================================
REM This script starts FaceFusion with OpenVINO in G:\facefusion

setlocal enabledelayedexpansion

echo.
echo ============================================================================
echo  FaceFusion + OpenVINO Launcher
echo ============================================================================
echo.
echo  Version: 3.5.1 (Latest)
echo  Branch: Vino+window (OpenVINO Optimized)
echo  Location: G:\facefusion
echo  Date: December 9, 2025
echo.

REM Change to G:\facefusion
cd /d G:\facefusion

REM Check if virtual environment exists
if not exist ".venv\Scripts\activate.bat" (
    echo [ERROR] Virtual environment not found at G:\facefusion\.venv
    echo [INFO] Run: install-vino-window.bat to set up the environment
    pause
    exit /b 1
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
    echo [INFO] Run: install-vino-window.bat to fix dependencies
)

REM Check OpenVINO installation
echo.
echo [INFO] Checking Intel OpenVINO installation:
python -c "import openvino; print(f'    OpenVINO Version: {openvino.__version__} (✓)')" 2>nul
if errorlevel 1 (
    echo     OpenVINO: Not installed (run install-vino-window.bat)
)

REM Check available devices
echo.
echo [INFO] Checking available devices:
python -c "from openvino import Core; core = Core(); [print(f'    - {device}') for device in core.available_devices]" 2>nul

REM Display NSFW status
echo.
echo [INFO] NSFW Status Check:
python -c "import sys; sys.path.insert(0, '.'); from facefusion import content_analyser; status='DISABLED (✓)' if not content_analyser.analyse_frame(None) else 'ENABLED (✗)'; print(f'    NSFW Detection: {status}')" 2>nul

REM Display branch info
echo [INFO] Branch: Vino+window (v3.5.1) with OpenVINO
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
    echo   - Missing dependencies: Run install-vino-window.bat
    echo   - Port 7860 in use: Close other FaceFusion instances
    echo   - OpenVINO not installed: Run install-vino-window.bat
    pause
    exit /b 1
)

echo.
echo [INFO] FaceFusion shutdown gracefully
echo.
pause
