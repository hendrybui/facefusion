@echo off
REM ============================================================================
REM Quick Terminal Opener for G:\facefusion
REM ============================================================================
REM This batch file opens a new Command Prompt window in G:\facefusion

REM Change to G:\facefusion directory
cd /d G:\facefusion

REM Verify we're in the right place
echo.
echo ============================================================================
echo  FaceFusion Terminal - Vino+window Branch
echo ============================================================================
echo.
echo  Location: %cd%
echo  Branch: Vino+window (with OpenVINO)
echo.
echo  Available commands:
echo    install-vino-window.bat  - Initial setup (installs to G:\facefusion)
echo    configure-openvino.bat   - Configure OpenVINO device
echo    start-vino-window.bat    - Start FaceFusion
echo.
echo ============================================================================
echo.

REM Keep the window open
cmd /k
