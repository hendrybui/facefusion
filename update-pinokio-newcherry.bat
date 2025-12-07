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
echo Update complete! Your Pinokio FaceFusion now uses:
echo - Repository: https://github.com/hendrybui/facefusion.git
echo - Branch: newcherry
echo - Version: 3.5.1 (latest)
echo - NSFW: Disabled
echo - Features: Full v3.5.1 capabilities
echo.
pause
