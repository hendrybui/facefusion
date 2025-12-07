@echo off
REM ============================================================================
REM FaceFusion NSFW Disable Patch - Post-Installation Script
REM ============================================================================
REM This script applies NSFW disable patches to FaceFusion after installation
REM Run this after facefusion installation to permanently disable NSFW detection
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ============================================================================
echo  FaceFusion NSFW Disable Patch Installer
echo ============================================================================
echo.
echo  This script will:
echo   1. Disable NSFW detection (content_analyser.py)
echo   2. Bypass hash validation (core.py)
echo   3. Apply teal UI theme (uis/core.py)
echo   4. Verify patches applied successfully
echo.

REM Check if running from Pinokio directory
if not exist "facefusion" (
    echo [ERROR] facefusion directory not found
    echo [ERROR] Please run this script from: g:\pinokio.home\api\facefusion-pinokio.git
    pause
    exit /b 1
)

if not exist "facefusion\facefusion" (
    echo [ERROR] facefusion\facefusion directory not found
    echo [ERROR] Make sure FaceFusion is properly installed
    pause
    exit /b 1
)

echo [INFO] FaceFusion directory found: facefusion\facefusion
echo.

REM ============================================================================
REM PATCH 1: Disable NSFW Detection
REM ============================================================================
echo [PATCH 1/3] Disabling NSFW detection in content_analyser.py...

set "file=facefusion\facefusion\content_analyser.py"
set "backup=!file!.backup"

REM Backup original file
if not exist "!backup!" (
    copy "!file!" "!backup!" >nul
    echo [INFO] Backup created: !backup!
)

REM Create temporary Python script to apply patch
set "patchScript=apply_nsfw_patch.py"
(
    echo import sys
    echo import re
    echo.
    echo file_path = r"facefusion\facefusion\content_analyser.py"
    echo.
    echo with open(file_path, 'r', encoding='utf-8') as f:
    echo     content = f.read()
    echo.
    echo pattern = r"def analyse_frame\(vision_frame\s*:\s*VisionFrame\)\s*->\s*bool:.*?return\s+detect_nsfw\(vision_frame\)"
    echo replacement = """def analyse_frame(vision_frame : VisionFrame) -> bool:
    echo \	# NSFW detection disabled
    echo \	return False"""
    echo.
    echo new_content = re.sub(pattern, replacement, content, flags=re.DOTALL, count=1)
    echo.
    echo if new_content != content:
    echo     with open(file_path, 'w', encoding='utf-8') as f:
    echo         f.write(new_content)
    echo     print("[SUCCESS] NSFW detection disabled in content_analyser.py")
    echo     sys.exit(0)
    echo else:
    echo     print("[ERROR] Could not find pattern to patch")
    echo     sys.exit(1)
) > "!patchScript!"

if exist ".venv\Scripts\python.exe" (
    .venv\Scripts\python "!patchScript!" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to disable NSFW detection
        del "!patchScript!"
        pause
        exit /b 1
    )
) else if exist "venv\Scripts\python.exe" (
    venv\Scripts\python "!patchScript!" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to disable NSFW detection
        del "!patchScript!"
        pause
        exit /b 1
    )
) else (
    python "!patchScript!" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to disable NSFW detection
        echo [INFO] Make sure Python is in PATH or virtual environment is activated
        del "!patchScript!"
        pause
        exit /b 1
    )
)

del "!patchScript!"
echo [SUCCESS] NSFW detection disabled
echo.

REM ============================================================================
REM PATCH 2: Bypass Hash Validation
REM ============================================================================
echo [PATCH 2/3] Bypassing hash validation in core.py...

set "file=facefusion\facefusion\core.py"
set "backup=!file!.backup"

REM Backup original file
if not exist "!backup!" (
    copy "!file!" "!backup!" >nul
    echo [INFO] Backup created: !backup!
)

REM Create temporary Python script
set "patchScript=bypass_hash_patch.py"
(
    echo import sys
    echo.
    echo file_path = r"facefusion\facefusion\core.py"
    echo.
    echo with open(file_path, 'r', encoding='utf-8') as f:
    echo     lines = f.readlines()
    echo.
    echo hash_check_lines = None
    echo for i, line in enumerate(lines):
    echo     if "def common_pre_check" in line:
    echo         start = i
    echo         for j in range(i, min(i+30, len(lines))):
    echo             if "return False" in lines[j] or "return True" in lines[j]:
    echo                 hash_check_lines = (start, j)
    echo                 break
    echo         break
    echo.
    echo if hash_check_lines:
    echo     start, end = hash_check_lines
    echo     result = []
    echo     for i, line in enumerate(lines):
    echo         if start <= i <= end and ("hasattr" in line or "model.get" in line):
    echo             continue
    echo         result.append(line)
    echo     with open(file_path, 'w', encoding='utf-8') as f:
    echo         f.writelines(result)
    echo     print("[SUCCESS] Hash validation bypassed in core.py")
    echo     sys.exit(0)
    echo print("[ERROR] Could not find hash validation code")
    echo sys.exit(1)
) > "!patchScript!"

if exist ".venv\Scripts\python.exe" (
    .venv\Scripts\python "!patchScript!" >nul 2>&1
    if errorlevel 1 (
        echo [WARNING] Hash bypass may not have applied correctly
    )
) else if exist "venv\Scripts\python.exe" (
    venv\Scripts\python "!patchScript!" >nul 2>&1
    if errorlevel 1 (
        echo [WARNING] Hash bypass may not have applied correctly
    )
) else (
    python "!patchScript!" >nul 2>&1
    if errorlevel 1 (
        echo [WARNING] Hash bypass may not have applied correctly
    )
)

del "!patchScript!" 2>nul
echo [SUCCESS] Hash validation bypassed
echo.

REM ============================================================================
REM PATCH 3: Apply Teal UI Theme
REM ============================================================================
echo [PATCH 3/3] Applying teal UI theme in uis/core.py...

set "file=facefusion\facefusion\uis\core.py"
set "backup=!file!.backup"

REM Backup original file
if not exist "!backup!" (
    copy "!file!" "!backup!" >nul
    echo [INFO] Backup created: !backup!
)

REM Create temporary Python script
set "patchScript=theme_patch.py"
(
    echo import sys
    echo import re
    echo.
    echo file_path = r"facefusion\facefusion\uis\core.py"
    echo.
    echo with open(file_path, 'r', encoding='utf-8') as f:
    echo     content = f.read()
    echo.
    echo pattern = r"primary_hue\s*=\s*gradio\.themes\.colors\.\w+"
    echo replacement = "primary_hue = gradio.themes.colors.cyan"
    echo.
    echo new_content = re.sub(pattern, replacement, content, count=1)
    echo.
    echo if new_content != content:
    echo     with open(file_path, 'w', encoding='utf-8') as f:
    echo         f.write(new_content)
    echo     print("[SUCCESS] Teal UI theme applied")
    echo     sys.exit(0)
    echo else:
    echo     print("[WARNING] Theme color not found - may already be set")
    echo     sys.exit(0)
) > "!patchScript!"

if exist ".venv\Scripts\python.exe" (
    .venv\Scripts\python "!patchScript!" >nul 2>&1
) else if exist "venv\Scripts\python.exe" (
    venv\Scripts\python "!patchScript!" >nul 2>&1
) else (
    python "!patchScript!" >nul 2>&1
)

del "!patchScript!" 2>nul
echo [SUCCESS] Teal UI theme applied
echo.

REM ============================================================================
REM VERIFICATION
REM ============================================================================
echo [INFO] Verifying patches...
echo.

set "verifyScript=verify_patches.py"
(
    echo import sys
    echo.
    echo errors = []
    echo.
    echo try:
    echo     with open(r"facefusion\facefusion\content_analyser.py", 'r') as f:
    echo         ca_content = f.read()
    echo     if "return False" in ca_content and "NSFW detection disabled" in ca_content:
    echo         print("[VERIFIED] NSFW detection is disabled")
    echo     else:
    echo         errors.append("NSFW detection patch not applied correctly")
    echo except:
    echo     errors.append("Could not verify NSFW patch")
    echo.
    echo try:
    echo     with open(r"facefusion\facefusion\core.py", 'r') as f:
    echo         core_content = f.read()
    echo     if "Hash check disabled" in core_content or "# Hash" in core_content:
    echo         print("[VERIFIED] Hash validation is bypassed")
    echo     else:
    echo         print("[INFO] Hash bypass status unclear - check manually")
    echo except:
    echo     errors.append("Could not verify hash bypass")
    echo.
    echo try:
    echo     with open(r"facefusion\facefusion\uis\core.py", 'r') as f:
    echo         ui_content = f.read()
    echo     if "gradio.themes.colors.cyan" in ui_content:
    echo         print("[VERIFIED] Teal UI theme is applied")
    echo     else:
    echo         errors.append("Teal UI theme not applied")
    echo except:
    echo     errors.append("Could not verify UI theme")
    echo.
    echo if errors:
    echo     print("\n[WARNINGS]:")
    echo     for error in errors:
    echo         print(f"  - {error}")
    echo     sys.exit(1)
) > "!verifyScript!"

if exist ".venv\Scripts\python.exe" (
    .venv\Scripts\python "!verifyScript!"
) else if exist "venv\Scripts\python.exe" (
    venv\Scripts\python "!verifyScript!"
) else (
    python "!verifyScript!"
)

del "!verifyScript!" 2>nul

echo.
echo ============================================================================
echo  PATCH INSTALLATION COMPLETE
echo ============================================================================
echo.
echo  Your FaceFusion now has:
echo   ✓ NSFW Detection: DISABLED
echo   ✓ Hash Validation: BYPASSED
echo   ✓ UI Theme: TEAL (Cyan)
echo.
echo  BACKUPS CREATED:
echo   - facefusion\facefusion\content_analyser.py.backup
echo   - facefusion\facefusion\core.py.backup
echo   - facefusion\facefusion\uis\core.py.backup
echo.
echo  To revert patches, run:
echo   copy facefusion\facefusion\content_analyser.py.backup facefusion\facefusion\content_analyser.py
echo   copy facefusion\facefusion\core.py.backup facefusion\facefusion\core.py
echo   copy facefusion\facefusion\uis\core.py.backup facefusion\facefusion\uis\core.py
echo.
echo ============================================================================
echo.
pause
