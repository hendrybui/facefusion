@echo off
REM Update Pinokio FaceFusion to use custom b2b branch
REM This switches to hendrybui/facefusion b2b branch with NSFW disabled

echo Switching to custom b2b branch...
cd /d g:\pinokio.home\api\facefusion-pinokio.git\facefusion

echo Stashing local changes...
git stash

echo Setting remote to hendrybui/facefusion...
git remote set-url origin https://github.com/hendrybui/facefusion.git

echo Fetching latest from b2b branch...
git fetch origin b2b

echo Checking out b2b branch...
git checkout b2b

echo Pulling latest changes...
git pull origin b2b

echo.
echo Update complete! Your Pinokio FaceFusion now uses:
echo - Repository: https://github.com/hendrybui/facefusion.git
echo - Branch: b2b
echo - Version: 3.4.2
echo - NSFW: Disabled
echo - Claude Haiku 4.5: Enabled
echo.
pause
