@echo off
REM Start FaceFusion with NSFW disabled and teal UI
REM This ensures the UI color is properly applied

cd /d g:\pinokio.home\api\facefusion-pinokio.git\facefusion

echo.
echo ===================================================
echo Starting FaceFusion v3.5.1 (newcherry branch)
echo ===================================================
echo.
echo Features:
echo - NSFW: Disabled
echo - UI Color: Teal/Cyan
echo - Version: 3.5.1 (latest)
echo.

if exist .venv\Scripts\activate.bat (
    echo Activating virtual environment...
    call .venv\Scripts\activate.bat
) else (
    echo WARNING: Virtual environment not found!
    echo Please run update-pinokio-newcherry.bat first
    echo.
)

echo Starting UI...
echo.

python facefusion.py run --ui-layouts default --execution-providers cpu

pause
