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
echo [Step 1/4] Installing core packages...
pip install gradio-rangeslider gradio onnx onnxruntime opencv-python psutil tqdm scipy pillow requests --quiet
echo [Step 2/4] Installing additional packages...
pip install pydantic pydantic-settings moviepy customtkinter --quiet
echo [Step 3/4] Fixing numpy compatibility...
pip install numpy==2.2.4 --force-reinstall --no-deps --quiet
echo [Step 4/4] Installing ffmpeg via imageio...
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
