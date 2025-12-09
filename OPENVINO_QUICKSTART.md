# 🚀 Vino+window Quick Start Guide

## What is Vino+window?

**Vino+window** is a dedicated FaceFusion branch with Intel OpenVINO integration optimized for local Windows deployment at `G:\facefusion`.

## Quick Setup (3 Steps)

### Step 1: Install & Setup
```bash
install-vino-window.bat
```
This will:
- Clone the Vino+window branch to G:\facefusion
- Create Python virtual environment
- Install all dependencies including OpenVINO
- Verify everything works

### Step 2: Configure OpenVINO Device
```bash
configure-openvino.bat
```
Choose your device:
- **1** = CPU Only (most compatible)
- **2** = GPU + CPU Fallback (RECOMMENDED)
- **3** = NVIDIA GPU (fast)
- **4** = Intel Arc GPU (fast)

### Step 3: Launch FaceFusion
```bash
start-vino-window.bat
```
FaceFusion will start with:
- ✅ OpenVINO optimized inference
- ✅ NSFW disabled
- ✅ Teal UI theme
- ✅ Available at http://localhost:7860

## File Structure

```
G:\facefusion\                    # Root directory
├── .venv\                        # Python virtual environment (auto-created)
├── .git\                         # Git repository
├── facefusion\                   # FaceFusion source code
├── install-vino-window.bat       # Initial setup script
├── start-vino-window.bat         # Startup launcher
├── configure-openvino.bat        # Device configuration
├── OPENVINO_SETUP.md            # Full OpenVINO guide
├── OPENVINO_QUICKSTART.md       # Quick reference
├── openvino.conf                # Configuration template
└── requirements.txt              # Python dependencies (with OpenVINO)
```

## Device Selection Guide

### CPU Only
- ✅ Most compatible
- ✅ No driver issues
- ⚠️ Slower (but adequate)
- **Use if**: Testing, compatibility needed

### GPU + CPU (RECOMMENDED)
- ✅ Fast inference
- ✅ Automatic fallback
- ✅ Best stability
- **Use if**: Want best balance of speed & stability

### NVIDIA GPU
- ✅ Very fast (if you have NVIDIA GPU)
- ⚠️ Requires CUDA 11.8+
- ⚠️ Driver dependent
- **Use if**: You have NVIDIA GPU

### Intel Arc GPU
- ✅ Fast (if you have Intel Arc)
- ⚠️ Requires latest drivers
- **Use if**: You have Intel Arc GPU

## First Run Checklist

- [ ] Run `install-vino-window.bat` (takes 10-15 minutes)
- [ ] Run `configure-openvino.bat` (choose device)
- [ ] Run `start-vino-window.bat`
- [ ] Check for "OpenVINO Version: 2024.0.0 (✓)" in output
- [ ] Open http://localhost:7860 in browser

## Common Commands

### Check OpenVINO Version
```bash
cd G:\facefusion
.venv\Scripts\activate.bat
python -c "import openvino; print(openvino.__version__)"
```

### See Available Devices
```bash
cd G:\facefusion
.venv\Scripts\activate.bat
python -c "from openvino import Core; print(Core().available_devices)"
```

### Reconfigure Device
```bash
configure-openvino.bat
```

### Start FaceFusion
```bash
start-vino-window.bat
```

## Environment Variables (Optional)

If you want to manually set device:
```batch
set OPENVINO_DEVICE=HETERO:GPU,CPU
set OPENVINO_PERFORMANCE_HINT=THROUGHPUT
```

Then run:
```bash
python facefusion.py
```

## Troubleshooting

### "Virtual environment not found"
```bash
install-vino-window.bat
```

### "OpenVINO not installed"
```bash
cd G:\facefusion
.venv\Scripts\activate.bat
pip install openvino openvino-dev
```

### "GPU not detected"
- Update your GPU drivers
- Try: `configure-openvino.bat` → Option 1 (CPU)
- Check: `python -c "from openvino import Core; print(Core().available_devices)"`

### "Port 7860 in use"
- Close other FaceFusion instances
- Or change port: `python facefusion.py --ui-port 7861`

## Performance Tips

- **First run**: Slower (model caching)
- **Subsequent runs**: Much faster
- **Best performance**: Use GPU option
- **Most stable**: Use GPU + CPU fallback

## File Reference

| File | Purpose |
|------|---------|
| `install-vino-window.bat` | First-time setup |
| `start-vino-window.bat` | Startup launcher |
| `configure-openvino.bat` | Device configuration |
| `OPENVINO_SETUP.md` | Full guide (100+ lines) |
| `OPENVINO_QUICKSTART.md` | Quick reference |
| `openvino.conf` | Config template |

## Key Features of Vino+window

✅ **OpenVINO Optimized** - Intel's optimization for CPU/GPU
✅ **NSFW Disabled** - No content filtering
✅ **Teal UI** - Custom colored interface
✅ **Windows Ready** - Batch scripts for easy use
✅ **Local Installation** - G:\facefusion directory
✅ **Self-Contained** - Virtual environment included
✅ **Production Ready** - Fully tested and stable

## Next Steps

1. Open Command Prompt (cmd)
2. Run: `install-vino-window.bat`
3. When done, run: `configure-openvino.bat`
4. Then run: `start-vino-window.bat`
5. Open browser to http://localhost:7860

## Support

For detailed information, see:
- `OPENVINO_SETUP.md` - Complete setup guide
- `OPENVINO_QUICKSTART.md` - Quick reference
- `openvino.conf` - Configuration options

---

**FaceFusion v3.5.1 + Intel OpenVINO**
**Branch: Vino+window**
**Location: G:\facefusion**
**Status: Production Ready ✅**
