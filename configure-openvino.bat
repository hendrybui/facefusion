@echo off
REM ============================================================================
REM OpenVINO Configuration Utility for FaceFusion
REM ============================================================================
REM This script helps configure OpenVINO device and performance settings

setlocal enabledelayedexpansion

echo.
echo ============================================================================
echo  OpenVINO Configuration Utility
echo ============================================================================
echo.

REM Check if OpenVINO is installed
echo [INFO] Checking OpenVINO installation...
python -c "import openvino; print(f'OpenVINO {openvino.__version__} installed')" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] OpenVINO not installed
    echo [INFO] Run: install-vino-window.bat to install OpenVINO
    pause
    exit /b 1
)

echo [INFO] Detected available devices:
python -c "from openvino import Core; core = Core(); print('  ' + ', '.join(core.available_devices))" 2>nul

echo.
echo Choose OpenVINO configuration:
echo.
echo 1. CPU Only (Most Compatible)
echo 2. GPU First, CPU Fallback (Heterogeneous - RECOMMENDED)
echo 3. NVIDIA GPU Only
echo 4. Intel Arc GPU Only
echo 5. Custom Configuration
echo 6. View Current Settings
echo 0. Exit
echo.
set /p choice="Enter your choice (0-6): "

if "%choice%"=="1" goto cpu_only
if "%choice%"=="2" goto hetero
if "%choice%"=="3" goto nvidia_gpu
if "%choice%"=="4" goto intel_gpu
if "%choice%"=="5" goto custom
if "%choice%"=="6" goto view_settings
if "%choice%"=="0" exit /b 0

echo [ERROR] Invalid choice
pause
goto end

:cpu_only
echo.
echo [INFO] Setting OpenVINO to CPU only...
setx OPENVINO_DEVICE CPU
setx OPENVINO_PERFORMANCE_HINT THROUGHPUT
echo [OK] Configuration applied
echo.
echo Next steps:
echo   1. Restart terminal or open new command prompt
echo   2. Run: python facefusion.py
echo.
pause
goto end

:hetero
echo.
echo [INFO] Setting OpenVINO to Heterogeneous mode (GPU + CPU fallback)...
setx OPENVINO_DEVICE HETERO:GPU,CPU
setx OPENVINO_PERFORMANCE_HINT THROUGHPUT
echo [OK] Configuration applied
echo.
echo Benefits:
echo   - GPU processes when available
echo   - CPU automatically takes over for unsupported operations
echo   - Best stability and compatibility
echo.
echo Next steps:
echo   1. Restart terminal or open new command prompt
echo   2. Run: python facefusion.py
echo.
pause
goto end

:nvidia_gpu
echo.
echo [INFO] Setting OpenVINO to NVIDIA GPU...
setx OPENVINO_DEVICE GPU.0
setx OPENVINO_PERFORMANCE_HINT THROUGHPUT
echo [OK] Configuration applied
echo.
echo Requirements:
echo   - NVIDIA drivers (version 460 or higher)
echo   - CUDA toolkit 11.8 or higher
echo.
echo Next steps:
echo   1. Verify NVIDIA drivers: nvidia-smi
echo   2. Restart terminal or open new command prompt
echo   3. Run: python facefusion.py
echo.
pause
goto end

:intel_gpu
echo.
echo [INFO] Setting OpenVINO to Intel Arc GPU...
setx OPENVINO_DEVICE GPU
setx OPENVINO_PERFORMANCE_HINT THROUGHPUT
echo [OK] Configuration applied
echo.
echo Requirements:
echo   - Intel Arc drivers (latest version)
echo   - Intel Arc graphics card
echo.
echo Next steps:
echo   1. Update Intel Arc drivers
echo   2. Restart terminal or open new command prompt
echo   3. Run: python facefusion.py
echo.
pause
goto end

:custom
echo.
echo Available devices: CPU, GPU, GPU.0, HETERO:GPU,CPU
echo.
set /p device="Enter OpenVINO device: "
set /p perf="Enter performance hint (THROUGHPUT/LATENCY): "

if "!device!"=="" set device=CPU
if "!perf!"=="" set perf=THROUGHPUT

echo.
echo [INFO] Setting custom configuration...
setx OPENVINO_DEVICE !device!
setx OPENVINO_PERFORMANCE_HINT !perf!
echo [OK] Configuration applied
echo   Device: !device!
echo   Performance: !perf!
echo.
echo Restart terminal and run: python facefusion.py
echo.
pause
goto end

:view_settings
echo.
echo [INFO] Current OpenVINO environment variables:
echo.
python -c "import os; [print(f'  {k}={v}') for k,v in os.environ.items() if 'OPENVINO' in k]" 2>nul
if errorlevel 1 (
    echo   (No custom OpenVINO variables set - using defaults)
)
echo.
echo [INFO] Available devices detected:
python -c "from openvino import Core; core = Core(); [print(f'  - {device}') for device in core.available_devices]" 2>nul
echo.
echo [INFO] OpenVINO version and supported features:
python -c "import openvino; print(f'  Version: {openvino.__version__}'); from openvino import Core; core = Core(); print(f'  Properties: {core.get_property(\"CPU\", \"FULL_DEVICE_NAME\")}')" 2>nul
echo.
pause
goto end

:end
echo.
echo For more information, see: OPENVINO_SETUP.md
echo.
