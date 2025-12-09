@echo off
REM ============================================================================
REM FaceFusion OpenVINO Setup for Windows - Local Installation
REM ============================================================================
REM This script sets up FaceFusion with OpenVINO in G:\facefusion
REM Branch: Vino+window

setlocal enabledelayedexpansion

echo.
echo ============================================================================
echo  FaceFusion + OpenVINO Setup
echo ============================================================================
echo.
echo  Version: v3.5.1 (newcherry)
echo  Branch: Vino+window
echo  Location: G:\facefusion
echo  Date: December 9, 2025
echo.

REM Check if G:\facefusion exists
if not exist "G:\facefusion" (
    echo [ERROR] G:\facefusion directory not found
    echo [INFO] Please ensure G:\facefusion exists and contains FaceFusion
    pause
    exit /b 1
)

cd /d G:\facefusion

REM Clone or update repository if needed
if not exist ".git" (
    echo [INFO] Cloning Vino+window branch...
    git clone -b Vino+window https://github.com/hendrybui/facefusion.git .
) else (
    echo [INFO] Updating to Vino+window branch...
    git fetch origin
    git checkout Vino+window
    git pull origin Vino+window
)

echo.
echo Setting up Python virtual environment...
if not exist ".venv" (
    echo Creating new virtual environment...
    python -m venv .venv
) else (
    echo Virtual environment already exists
)

echo Activating virtual environment...
call .venv\Scripts\activate.bat

echo.
echo Installing/updating dependencies...
echo [Step 1/6] Installing compatible numpy first...
pip install numpy==2.2.4 --quiet
echo [Step 2/6] Installing compatible pillow and pydantic...
pip install "pillow<12.0,>=8.0" "pydantic<2.12,>=2.0" --quiet
echo [Step 3/6] Installing core packages...
pip install gradio-rangeslider==0.0.8 gradio==5.44.1 onnx==1.19.1 onnxruntime==1.23.2 opencv-python==4.12.0.88 psutil==7.1.2 tqdm==4.67.1 scipy==1.16.3 requests --quiet
echo [Step 4/6] Installing additional packages...
pip install pydantic-settings moviepy customtkinter --quiet
echo [Step 5/6] Installing ffmpeg via imageio...
pip install imageio[ffmpeg] --quiet

echo.
echo [Step 6/6] Installing OpenVINO for optimized inference...
pip install "openvino>=2024.0.0" "openvino-dev>=2024.0.0" --quiet

echo.
echo Checking ffmpeg installation...
python -c "import imageio_ffmpeg; print('✓ ffmpeg installed via imageio')" 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Installing ffmpeg-python...
    pip install ffmpeg-python --quiet
)

echo.
echo Checking OpenVINO installation...
python -c "import openvino; print('✓ OpenVINO installed successfully')" 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] OpenVINO installation may have failed. Run: pip install openvino openvino-dev
)

echo.
echo Testing FaceFusion startup...
python -c "from facefusion import core; print('✓ FaceFusion loaded successfully')"
if %ERRORLEVEL% EQU 0 (
    echo [OK] All dependencies are installed
) else (
    echo [ERROR] FaceFusion failed to load
    echo [INFO] Check errors above
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo  Setup Complete!
echo ============================================================================
echo.
echo Location: G:\facefusion
echo Branch: Vino+window (with OpenVINO)
echo Virtual Env: G:\facefusion\.venv
echo.
echo Next steps:
echo  1. Run: configure-openvino.bat (to choose device: CPU/GPU/etc)
echo  2. Run: python facefusion.py
echo.
echo Virtual environment is already activated in this terminal.
echo You can now run FaceFusion commands directly.
echo.
pause
