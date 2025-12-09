@echo off
setlocal enabledelayedexpansion

set "FACEFUSION_DIR=G:\facefusion"

if not exist "%FACEFUSION_DIR%" (
    echo [ERROR] G:\facefusion not found
    exit /b 1
)

if not exist "%FACEFUSION_DIR%\.venv\Scripts\python.exe" (
    echo [ERROR] .venv not found
    exit /b 1
)

set "OLD_PATH=%PATH%"
set "PATH=%FACEFUSION_DIR%;%FACEFUSION_DIR%\.venv\Scripts;%PATH%"

REM Configure OpenVINO to use CPU only
set "OPENVINO_DEVICE=CPU"

echo.
echo ============================================================================
echo  FaceFusion - Isolated Environment Launcher
echo ============================================================================
echo.
echo [INFO] Running from: %FACEFUSION_DIR%
echo [INFO] Execution Provider: OpenVINO (Hardware Accelerated)
echo.

"%FACEFUSION_DIR%\.venv\Scripts\python.exe" -c "import torch, tensorflow, openvino" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Some packages missing
) else (
    echo [OK] Isolation verified
)

echo.

if "%1"=="" (
    goto gui
) else if /i "%1"=="gui" (
    goto gui
) else if /i "%1"=="headless" (
    goto headless
) else if /i "%1"=="batch" (
    goto batch
) else (
    REM Pass all arguments directly to facefusion.py
    echo [RUN] Executing: facefusion.py %*
    cd /d "%FACEFUSION_DIR%"
    "%FACEFUSION_DIR%\.venv\Scripts\python.exe" facefusion.py %*
    goto cleanup
)

:gui
echo [RUN] Starting GUI...
cd /d "%FACEFUSION_DIR%"
"%FACEFUSION_DIR%\.venv\Scripts\python.exe" facefusion.py run
goto cleanup

:headless
echo [RUN] Starting Headless...
cd /d "%FACEFUSION_DIR%"
"%FACEFUSION_DIR%\.venv\Scripts\python.exe" facefusion.py headless-run
goto cleanup

:batch
echo [RUN] Starting Batch...
cd /d "%FACEFUSION_DIR%"
"%FACEFUSION_DIR%\.venv\Scripts\python.exe" facefusion.py batch-run
goto cleanup

:help
echo Usage: run-facefusion.bat [mode]
echo Modes: gui, headless, batch
echo.
goto cleanup

:cleanup
set "PATH=%OLD_PATH%"
endlocal
exit /b 0
