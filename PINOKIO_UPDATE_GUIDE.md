# FaceFusion Pinokio Update Guide - newcherry Branch

## Overview
This guide helps you update your Pinokio FaceFusion installation to use the `newcherry` branch (v3.5.1 with NSFW disabled).

## Prerequisites
- Pinokio installed on your system
- Git installed and configured
- Access to `g:\pinokio.home\api\facefusion-pinokio.git\facefusion` directory

## Method 1: Automatic Update (Recommended)

### Windows CMD
Run this batch script from your workspace:
```cmd
c:\Users\kentb\Workspace\facefusion\update-pinokio-newcherry.bat
```

This script will:
1. Navigate to your Pinokio installation
2. Stash any local changes
3. Set remote to your GitHub fork
4. Checkout newcherry branch
5. Pull latest changes

### Manual Verification
After running, verify the update:
```cmd
cd /d g:\pinokio.home\api\facefusion-pinokio.git\facefusion
git branch --show-current
git log --oneline -1
```

Expected output:
```
newcherry
2279424 Add Pinokio update script for newcherry branch
```

## Method 2: Manual Update

### Step 1: Navigate to Pinokio FaceFusion
```cmd
cd /d g:\pinokio.home\api\facefusion-pinokio.git\facefusion
```

### Step 2: Stash Local Changes
```cmd
git stash
```

### Step 3: Set Remote to Your Fork
```cmd
git remote set-url origin https://github.com/hendrybui/facefusion.git
```

### Step 4: Fetch newcherry Branch
```cmd
git fetch origin newcherry
```

### Step 5: Switch to newcherry
```cmd
git checkout newcherry
```

### Step 6: Pull Latest Changes
```cmd
git pull origin newcherry
```

## Verify Installation

### Check Branch
```cmd
git branch --show-current
```
Should show: `newcherry`

### Check Version
```cmd
findstr "version" facefusion\metadata.py
```
Should show: `'version': '3.5.1'`

### Verify NSFW is Disabled
```cmd
findstr "# NSFW detection disabled" facefusion\content_analyser.py
```
Should return a match.

## Switch Between Branches

### Switch to b2b (v3.4.2)
```cmd
cd /d g:\pinokio.home\api\facefusion-pinokio.git\facefusion
git checkout b2b
git pull origin b2b
```

### Switch Back to newcherry (v3.5.1)
```cmd
cd /d g:\pinokio.home\api\facefusion-pinokio.git\facefusion
git checkout newcherry
git pull origin newcherry
```

## Available Branches

| Branch | Version | NSFW | UI Color | Status | Latest Commit |
|--------|---------|------|----------|--------|---------------|
| `newcherry` | v3.5.1 | Disabled | Default | ✅ Active | 3c33d04 |
| `b2b` | v3.4.2 | Disabled | Teal | ✅ Stable | 65c9ca3 |
| `master` | v3.4.2 | Enabled | Default | 📌 Fork Main | 81c5e85 |
| `pinokio-config` | v3.4.2 | Enabled | Default | 🔧 Experimental | 176a1bf |

## Troubleshooting

### "Your local changes would be overwritten"
```cmd
git stash
git checkout newcherry
```

### "Permission denied" when cloning
Ensure you have write permissions to the Pinokio directory.

### Still seeing old version
1. Restart Pinokio/FaceFusion application
2. Clear browser cache (if using web UI)
3. Verify with `git log --oneline -1`

## Restart Pinokio

After updating, you need to restart FaceFusion in Pinokio:
1. Close Pinokio
2. Close the FaceFusion application/browser window
3. Reopen Pinokio
4. Launch FaceFusion again

## Support

For issues, check:
- Repository: https://github.com/hendrybui/facefusion
- Branches: b2b, newcherry, master
- Test script: `test-newcherry-nsfw.bat`
