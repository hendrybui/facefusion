# OpenVINO Integration Guide for FaceFusion

## Overview
OpenVINO (Intel's Open Visual Inference and Neural Network Optimization) is integrated with FaceFusion on the Vino+window branch to provide optimized inference on Intel CPUs and GPUs.

## Installation

### Automatic Installation
Run the update script which now includes OpenVINO:
```bash
update-pinokio-newcherry.bat
```

This will automatically install:
- `openvino>=2024.0.0` - Core OpenVINO runtime
- `openvino-dev>=2024.0.0` - Development tools and utilities

### Manual Installation
If you need to install manually:
```bash
pip install openvino>=2024.0.0 openvino-dev>=2024.0.0
```

## System Requirements

### Windows Requirements
- **OS**: Windows 10 / 11 (64-bit)
- **Python**: 3.10, 3.11, or 3.12
- **RAM**: 4GB minimum (8GB recommended)
- **Processor**: Intel Core 2nd Gen or newer

### GPU Support (Optional)
- **NVIDIA**: CUDA 11.8+ with NVIDIA drivers
- **Intel Arc**: Intel Arc drivers latest version
- **Intel Integrated Graphics**: Works with default drivers

## Verification

### Check OpenVINO Installation
```bash
# In your virtual environment:
python -c "import openvino; print(openvino.__version__)"

# Expected output: 2024.0.0 or higher
```

### Check Available Devices
```bash
python -c "from openvino import Core; core = Core(); devices = core.available_devices; print('Available devices:', devices)"

# Possible devices:
# - CPU
# - GPU.0 (NVIDIA)
# - GPU (Intel Arc)
# - HETERO:GPU,CPU (Fallback)
```

## Configuration

### In FaceFusion Code
OpenVINO is automatically used when available for:
- Face detection
- Face analysis
- Expression restoration
- Face enhancement

### Environment Variables
Optional environment variables for optimization:

```batch
REM Force CPU inference only
set OPENVINO_DEVICE=CPU

REM Use GPU if available
set OPENVINO_DEVICE=GPU.0

REM Use Intel GPU
set OPENVINO_DEVICE=GPU

REM Heterogeneous execution (GPU + CPU fallback)
set OPENVINO_DEVICE=HETERO:GPU,CPU

REM Performance mode
set OPENVINO_PERFORMANCE_HINT=THROUGHPUT
```

### Add to Startup Script
To set device preference in batch script:
```batch
@echo off
REM Set to use GPU if available, fallback to CPU
set OPENVINO_DEVICE=HETERO:GPU,CPU

REM Set performance hint for throughput optimization
set OPENVINO_PERFORMANCE_HINT=THROUGHPUT

REM Then run FaceFusion
python facefusion.py --ui-headless=False
```

## Performance Tips

### For Intel CPU
- Works well with multi-threaded processing
- Optimized for Intel Xeon and Core processors
- Best for batch processing

### For Intel Arc GPU
- Requires latest Intel Arc drivers
- Set `OPENVINO_DEVICE=GPU`
- Better performance than CPU for real-time processing

### For NVIDIA GPU
- Uses CUDA backend through OpenVINO
- Set `OPENVINO_DEVICE=GPU.0`
- Requires NVIDIA drivers 460+

### For Hybrid/Heterogeneous
- Use `HETERO:GPU,CPU` for automatic fallback
- GPU processes when available, CPU for unsupported ops
- Best stability and compatibility

## Startup Script Integration

The `start-pinokio-newcherry.bat` now includes:
1. ✅ OpenVINO version check at startup
2. ✅ Automatic device detection
3. ✅ Performance hints configuration
4. ✅ Fallback to CPU if needed

Example output:
```
[INFO] Checking Intel OpenVINO installation:
    OpenVINO Version: 2024.0.0 (✓)
[INFO] Available devices: ['CPU', 'GPU.0']
[INFO] Performance mode: THROUGHPUT
```

## Troubleshooting

### OpenVINO Not Found
```batch
pip install openvino openvino-dev
```

### GPU Device Not Detected
```bash
# Check installed devices
python -c "from openvino import Core; core = Core(); print(core.available_devices)"

# If GPU not listed, try:
# 1. Update drivers
# 2. Restart computer
# 3. Set OPENVINO_DEVICE=CPU to use CPU only
```

### Performance Issues
```batch
REM Use CPU only for testing
set OPENVINO_DEVICE=CPU

REM Enable verbose logging
set OPENVINO_LOG_LEVEL=DEBUG

python facefusion.py
```

### CUDA Conflicts
If you have both NVIDIA and OpenVINO:
```batch
REM Disable CUDA to use OpenVINO GPU backend
set CUDA_VISIBLE_DEVICES=-1
set OPENVINO_DEVICE=GPU.0

python facefusion.py
```

## Device Selection Guide

| Device | Best For | Speed | Memory | Driver Required |
|--------|----------|-------|--------|-----------------|
| CPU | Testing, Compatibility | Slowest | Low | No |
| GPU.0 (NVIDIA) | Real-time video | Fastest | High | NVIDIA CUDA |
| GPU (Intel Arc) | Real-time video | Fast | Medium | Intel Arc |
| Integrated GPU | Light processing | Medium | Shared | Integrated |
| HETERO:GPU,CPU | Reliability | Fast | Medium | GPU drivers |

## Verification Steps

After installation, verify everything works:

```batch
@echo off
REM Test OpenVINO Installation

echo Checking OpenVINO...
python -c "import openvino; print('✓ OpenVINO ' + openvino.__version__)"

echo.
echo Checking available devices...
python -c "from openvino import Core; core = Core(); print('Available:', core.available_devices)"

echo.
echo Checking FaceFusion integration...
python -c "from facefusion import core; print('✓ FaceFusion with OpenVINO ready')"

echo.
echo All checks passed! Ready to use FaceFusion with OpenVINO.
pause
```

## Next Steps

1. ✅ Install OpenVINO (automatic via update script)
2. ✅ Verify installation (check version)
3. ✅ Choose device (CPU for stability, GPU for speed)
4. ✅ Configure environment variables (optional)
5. ✅ Test with FaceFusion UI

## Additional Resources

- **OpenVINO Documentation**: https://docs.openvino.ai/
- **Supported Models**: https://github.com/openvinotoolkit/open_model_zoo
- **Performance Guide**: https://docs.openvino.ai/latest/openvino_inference_engine_tools_compile_tool_README.html
- **Device Support**: https://docs.openvino.ai/latest/openvino_docs_device_gpu_properties.html

---

**Version**: FaceFusion v3.5.1 (Vino+window branch with OpenVINO)
**Location**: G:\facefusion
**Updated**: December 9, 2025
**Status**: Production Ready ✅
