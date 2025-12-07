@echo off
REM Update Pinokio FaceFusion to use newcherry branch (v3.5.1)
REM This switches to hendrybui/facefusion newcherry branch with NSFW disabled

echo Switching to newcherry branch (v3.5.1 with NSFW disabled)...
cd /d g:\pinokio.home\api\facefusion-pinokio.git\facefusion

echo Stashing local changes...
git stash

echo Setting remote to hendrybui/facefusion...
git remote set-url origin https://github.com/hendrybui/facefusion.git

echo Fetching latest from newcherry branch...
git fetch origin newcherry

echo Checking out newcherry branch...
git checkout newcherry

echo Pulling latest changes...
git pull origin newcherry

echo.
echo Setting up Python virtual environment...
if not exist .venv (
    echo Creating new virtual environment...
    python -m venv .venv
) else (
    echo Virtual environment already exists
)

echo Activating virtual environment...
call .venv\Scripts\activate.bat

echo.
echo Installing/updating dependencies...
echo [Step 1/5] Installing compatible numpy first...
pip install numpy==2.2.4 --quiet
echo [Step 2/5] Installing compatible pillow and pydantic...
pip install "pillow<12.0,>=8.0" "pydantic<2.12,>=2.0" --quiet
echo [Step 3/5] Installing core packages...
pip install gradio-rangeslider==0.0.8 gradio==5.44.1 onnx==1.19.1 onnxruntime==1.23.2 opencv-python==4.12.0.88 psutil==7.1.2 tqdm==4.67.1 scipy==1.16.3 requests --quiet
echo [Step 4/5] Installing additional packages...
pip install pydantic-settings moviepy customtkinter --quiet
echo [Step 5/5] Installing ffmpeg via imageio...
pip install imageio[ffmpeg] --quiet

echo.
echo Checking ffmpeg installation...
python -c "import imageio_ffmpeg; print('✓ ffmpeg installed via imageio')" 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Installing ffmpeg-python...
    pip install ffmpeg-python --quiet
)

echo.
echo Testing FaceFusion startup...
python -c "from facefusion import core; print('✓ FaceFusion loaded successfully')"
if %ERRORLEVEL% EQU 0 (
    echo [OK] All dependencies are installed
) else (
    echo [WARNING] Dependency check failed - check requirements.txt
)

echo.
echo Update complete! Your Pinokio FaceFusion now uses:
echo - Repository: https://github.com/hendrybui/facefusion.git
echo - Branch: newcherry
echo - Version: 3.5.1 (latest)
echo - NSFW: Disabled
echo - Features: Full v3.5.1 capabilities
echo.
pause
