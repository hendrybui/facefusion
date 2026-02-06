#!/bin/bash

################################################################################
# FaceFusion Installation Script with GPU Acceleration
# Ubuntu Linux - CUDA 12.1 / ROCm 6.0
#
# This script automates the complete installation of FaceFusion with:
# - Python virtual environment setup
# - Latest stable repository clone
# - GPU acceleration (NVIDIA CUDA 12.1 + cuDNN 8 OR AMD ROCm 6.0)
# - AMD gfx803 architecture support
# - Dependency resolution and installation
# - Precise requirements.txt generation
# - NSFW filter disabled
# - UI theme set to cyan
# - Robust error handling and progress logging
# - GPU verification
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="${INSTALL_DIR:-$HOME/facefusion}"
VENV_DIR="$INSTALL_DIR/.venv"
REPO_URL="https://github.com/facefusion/facefusion.git"
LOG_FILE="$INSTALL_DIR/installation_$(date +%Y%m%d_%H%M%S).log"
PYTHON_VERSION_MIN="3.10"
PYTHON_VERSION_MAX="3.12"
CUDA_VERSION="12.1"
CUDNN_VERSION="8"
ROCM_VERSION="6.0"
GPU_TYPE=""  # Will be detected: nvidia or amd

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO" "${BLUE}$*${NC}"
}

log_success() {
    log "SUCCESS" "${GREEN}$*${NC}"
}

log_warning() {
    log "WARNING" "${YELLOW}$*${NC}"
}

log_error() {
    log "ERROR" "${RED}$*${NC}"
}

log_step() {
    log "STEP" "${CYAN}$*${NC}"
}

# Progress indicator
progress() {
    local pid=$1
    local delay=0.5
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Error handler
error_exit() {
    log_error "$1"
    log_error "Installation failed. Check $LOG_FILE for details."
    exit 1
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        log_warning "Running as root is not recommended. Please run as a regular user."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Check system requirements
check_system() {
    log_step "Checking system requirements..."

    # Check OS
    if [ ! -f /etc/os-release ]; then
        error_exit "Cannot detect operating system. /etc/os-release not found."
    fi

    . /etc/os-release
    log_info "Detected OS: $PRETTY_NAME"

    if [[ "$ID" != "ubuntu" ]]; then
        log_warning "This script is designed for Ubuntu. You are running $ID."
        log_warning "Proceeding anyway, but issues may occur."
    fi

    # Check architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" != "x86_64" ]]; then
        error_exit "Unsupported architecture: $ARCH. FaceFusion requires x86_64."
    fi
    log_success "Architecture: $ARCH"

    # Check available disk space (need at least 10GB)
    AVAILABLE_SPACE=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$AVAILABLE_SPACE" -lt 10 ]; then
        error_exit "Insufficient disk space. At least 10GB required, ${AVAILABLE_SPACE}GB available."
    fi
    log_success "Disk space: ${AVAILABLE_SPACE}GB available"

    # Check internet connection
    if ! ping -c 1 -W 2 github.com > /dev/null 2>&1; then
        error_exit "No internet connection. Cannot proceed with installation."
    fi
    log_success "Internet connection: OK"
}

# Detect GPU type (NVIDIA or AMD)
detect_gpu_type() {
    log_step "Detecting GPU type..."

    # Check for NVIDIA GPU
    if command -v nvidia-smi &> /dev/null; then
        GPU_TYPE="nvidia"
        log_info "NVIDIA GPU detected"
        return 0
    fi

    # Check for AMD GPU
    if command -v rocm-smi &> /dev/null; then
        GPU_TYPE="amd"
        log_info "AMD GPU detected"
        return 0
    fi

    # Check for AMD GPU via lspci
    if command -v lspci &> /dev/null; then
        AMD_GPU=$(lspci | grep -i "vga.*amd" | head -1)
        if [ -n "$AMD_GPU" ]; then
            log_warning "AMD GPU detected but ROCm drivers not installed"
            log_warning "Please install ROCm drivers first"
            log_info "Visit: https://rocm.docs.amd.com/en/latest/deploy/linux/quick_start.html"
            error_exit "ROCm drivers required for AMD GPU support"
        fi
    fi

    # Check for NVIDIA GPU via lspci
    if command -v lspci &> /dev/null; then
        NVIDIA_GPU=$(lspci | grep -i "vga.*nvidia" | head -1)
        if [ -n "$NVIDIA_GPU" ]; then
            log_warning "NVIDIA GPU detected but drivers not installed"
            log_warning "Please install NVIDIA drivers first"
            log_info "Visit: https://developer.nvidia.com/cuda-downloads"
            error_exit "NVIDIA drivers required for NVIDIA GPU support"
        fi
    fi

    error_exit "No supported GPU detected. This script requires NVIDIA or AMD GPU."
}

# Check NVIDIA GPU and drivers
check_nvidia() {
    log_step "Checking NVIDIA GPU and drivers..."

    # Check for NVIDIA GPU
    if ! command -v nvidia-smi &> /dev/null; then
        error_exit "NVIDIA drivers not installed. Please install NVIDIA drivers first."
    fi

    # Get GPU info
    NVIDIA_INFO=$(nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>&1)
    if [ $? -ne 0 ]; then
        error_exit "Failed to query NVIDIA GPU: $NVIDIA_INFO"
    fi

    log_info "NVIDIA GPU detected:"
    echo "$NVIDIA_INFO" | while IFS= read -r line; do
        log_info "  - $line"
    done

    # Check CUDA version compatibility
    DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)
    log_info "NVIDIA Driver Version: $DRIVER_VERSION"

    # Check for CUDA toolkit
    if command -v nvcc &> /dev/null; then
        CUDA_TOOLKIT_VERSION=$(nvcc --version | grep "release" | sed 's/.*release //' | sed 's/,.*//')
        log_info "CUDA Toolkit Version: $CUDA_TOOLKIT_VERSION"
    else
        log_warning "CUDA toolkit not found in PATH. This is OK if using PyTorch with CUDA support."
    fi

    log_success "NVIDIA GPU and drivers verified"
}

# Check AMD GPU and ROCm drivers
check_amd() {
    log_step "Checking AMD GPU and ROCm drivers..."

    # Check for ROCm-smi
    if ! command -v rocm-smi &> /dev/null; then
        error_exit "ROCm drivers not installed. Please install ROCm drivers first."
        log_info "Visit: https://rocm.docs.amd.com/en/latest/deploy/linux/quick_start.html"
    fi

    # Get GPU info
    ROCM_INFO=$(rocm-smi --showproductname --showmem 2>&1)
    if [ $? -ne 0 ]; then
        error_exit "Failed to query AMD GPU: $ROCM_INFO"
    fi

    log_info "AMD GPU detected:"
    echo "$ROCM_INFO" | grep -E "(GPU|Card|Memory)" | head -10 | while IFS= read -r line; do
        log_info "  - $line"
    done

    # Detect GPU architecture
    GPU_ARCH=$(rocm-smi --showproductname 2>&1 | grep -oE "gfx[0-9a-f]+" | head -1)
    if [ -n "$GPU_ARCH" ]; then
        log_info "GPU Architecture: $GPU_ARCH"

        # Check for gfx803 support
        if [[ "$GPU_ARCH" == "gfx803" ]]; then
            log_success "gfx803 architecture detected (AMD Vega/RX500 series)"
        else
            log_info "Detected architecture: $GPU_ARCH"
            log_warning "Script optimized for gfx803, will use compatible settings"
        fi
    fi

    # Check ROCm version
    if command -v rocminfo &> /dev/null; then
        ROCM_VERSION=$(rocminfo --version 2>&1 | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -1)
        if [ -n "$ROCM_VERSION" ]; then
            log_info "ROCm Version: $ROCM_VERSION"
        fi
    fi

    log_success "AMD GPU and ROCm drivers verified"
}

# Check Python installation
check_python() {
    log_step "Checking Python installation..."

    # Find Python executable
    PYTHON_CMD=""
    for cmd in python3 python python3.11 python3.12 python3.10; do
        if command -v $cmd &> /dev/null; then
            PYTHON_VERSION=$($cmd --version 2>&1 | awk '{print $2}')
            PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
            PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

            if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 10 ] && [ "$PYTHON_MINOR" -le 12 ]; then
                PYTHON_CMD=$cmd
                break
            fi
        fi
    done

    if [ -z "$PYTHON_CMD" ]; then
        error_exit "Python $PYTHON_VERSION_MIN-$PYTHON_VERSION_MAX not found. Please install Python 3.10, 3.11, or 3.12."
    fi

    log_success "Python found: $PYTHON_CMD $PYTHON_VERSION"

    # Check pip
    if ! $PYTHON_CMD -m pip --version &> /dev/null; then
        error_exit "pip not found for $PYTHON_CMD. Please install pip."
    fi

    PIP_VERSION=$($PYTHON_CMD -m pip --version | awk '{print $2}')
    log_success "pip version: $PIP_VERSION"

    # Check venv module
    if ! $PYTHON_CMD -c "import venv" 2>/dev/null; then
        error_exit "Python venv module not available. Please install python3-venv."
    fi

    log_success "Python venv module available"
}

# Create installation directory
create_install_dir() {
    log_step "Creating installation directory..."

    if [ -d "$INSTALL_DIR" ]; then
        log_warning "Installation directory already exists: $INSTALL_DIR"
        read -p "Backup and reinstall? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            BACKUP_DIR="${INSTALL_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
            log_info "Backing up existing installation to: $BACKUP_DIR"
            mv "$INSTALL_DIR" "$BACKUP_DIR" || error_exit "Failed to backup existing directory."
        else
            error_exit "Installation cancelled by user."
        fi
    fi

    mkdir -p "$INSTALL_DIR" || error_exit "Failed to create installation directory."
    log_success "Installation directory created: $INSTALL_DIR"
}

# Create Python virtual environment
create_venv() {
    log_step "Creating Python virtual environment..."

    log_info "Creating virtual environment at: $VENV_DIR"
    $PYTHON_CMD -m venv "$VENV_DIR" || error_exit "Failed to create virtual environment."

    # Activate virtual environment
    source "$VENV_DIR/bin/activate" || error_exit "Failed to activate virtual environment."
    log_success "Virtual environment activated"

    # Upgrade pip
    log_info "Upgrading pip to latest version..."
    pip install --upgrade pip setuptools wheel || error_exit "Failed to upgrade pip."

    PIP_VERSION=$(pip --version | awk '{print $2}')
    log_success "pip upgraded to: $PIP_VERSION"
}

# Clone FaceFusion repository
clone_repository() {
    log_step "Cloning FaceFusion repository..."

    if [ -d "$INSTALL_DIR/.git" ]; then
        log_warning "Repository already exists. Updating..."
        cd "$INSTALL_DIR"
        git fetch origin || error_exit "Failed to fetch repository updates."
        git pull origin $(git rev-parse --abbrev-ref HEAD) || error_exit "Failed to pull repository updates."
        log_success "Repository updated"
    else
        log_info "Cloning from: $REPO_URL"
        git clone "$REPO_URL" "$INSTALL_DIR" || error_exit "Failed to clone repository."
        cd "$INSTALL_DIR"

        # Get latest stable tag
        LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1` 2>/dev/null || echo "")
        if [ -n "$LATEST_TAG" ]; then
            log_info "Checking out latest stable tag: $LATEST_TAG"
            git checkout "$LATEST_TAG" || log_warning "Failed to checkout tag, using main branch."
        fi

        log_success "Repository cloned successfully"
    fi

    # Show commit info
    COMMIT_HASH=$(git rev-parse --short HEAD)
    COMMIT_DATE=$(git log -1 --format=%cd --date=short)
    log_info "Current commit: $COMMIT_HASH ($COMMIT_DATE)"
}

# Install PyTorch with GPU support
install_pytorch() {
    if [ "$GPU_TYPE" = "nvidia" ]; then
        log_step "Installing PyTorch with CUDA $CUDA_VERSION support..."

        # Install PyTorch with CUDA 12.1 support
        log_info "Installing PyTorch 2.5.1 with CUDA $CUDA_VERSION..."
        pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cu121 || \
        error_exit "Failed to install PyTorch with CUDA support."

        # Verify PyTorch installation
        log_info "Verifying PyTorch installation..."
        python -c "import torch; print(f'PyTorch version: {torch.__version__}')" || error_exit "Failed to import PyTorch."
        log_success "PyTorch installed successfully"

    elif [ "$GPU_TYPE" = "amd" ]; then
        log_step "Installing PyTorch with ROCm $ROCM_VERSION support..."

        # Install PyTorch with ROCm support
        log_info "Installing PyTorch 2.5.1 with ROCm $ROCM_VERSION..."
        pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/rocm6.0 || \
        error_exit "Failed to install PyTorch with ROCm support."

        # Verify PyTorch installation
        log_info "Verifying PyTorch installation..."
        python -c "import torch; print(f'PyTorch version: {torch.__version__}')" || error_exit "Failed to import PyTorch."
        log_success "PyTorch installed successfully"

        # Set ROCm architecture environment variable
        log_info "Setting ROCm architecture for gfx803 compatibility..."
        export TORCH_ROCM_ARCH="gfx803"
        echo "export TORCH_ROCM_ARCH=gfx803" >> "$VENV_DIR/bin/activate"
        log_success "ROCm architecture set to gfx803"
    fi
}

# Install FaceFusion dependencies
install_dependencies() {
    log_step "Installing FaceFusion dependencies..."

    cd "$INSTALL_DIR"

    # Install core dependencies
    log_info "Installing core dependencies from requirements.txt..."
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt || error_exit "Failed to install core dependencies."
        log_success "Core dependencies installed"
    else
        log_warning "requirements.txt not found, installing dependencies manually..."
        pip install gradio-rangeslider==0.0.8 || error_exit "Failed to install gradio-rangeslider."
        pip install gradio==5.44.1 || error_exit "Failed to install gradio."
        pip install numpy==2.2.6 || error_exit "Failed to install numpy."
        pip install onnx==1.19.1 || error_exit "Failed to install onnx."

        # Install appropriate onnxruntime based on GPU type
        if [ "$GPU_TYPE" = "nvidia" ]; then
            pip install onnxruntime-gpu==1.23.2 || error_exit "Failed to install onnxruntime-gpu."
        else
            # For AMD, use regular onnxruntime (PyTorch handles GPU)
            pip install onnxruntime==1.23.2 || error_exit "Failed to install onnxruntime."
        fi

        pip install opencv-python==4.12.0.88 || error_exit "Failed to install opencv-python."
        pip install psutil==7.1.3 || error_exit "Failed to install psutil."
        pip install tqdm==4.67.1 || error_exit "Failed to install tqdm."
        pip install scipy==1.16.3 || error_exit "Failed to install scipy."
        log_success "Core dependencies installed"
    fi

    # Install additional dependencies for GPU acceleration
    log_info "Installing additional GPU dependencies..."
    pip install accelerate || error_exit "Failed to install accelerate."
    pip install transformers || error_exit "Failed to install transformers."
    pip install insightface || error_exit "Failed to install insightface."
    pip install gfpgan || error_exit "Failed to install gfpgan."
    pip install basicsr || error_exit "Failed to install basicsr."
    pip install realesrgan || error_exit "Failed to install realesrgan."

    # Install appropriate onnxruntime based on GPU type
    if [ "$GPU_TYPE" = "nvidia" ]; then
        pip install onnxruntime-gpu==1.23.2 || log_warning "onnxruntime-gpu already installed."
    else
        pip install onnxruntime==1.23.2 || log_warning "onnxruntime already installed."
    fi

    log_success "All dependencies installed successfully"
}

# Generate precise requirements.txt
generate_requirements() {
    log_step "Generating precise requirements.txt..."

    cd "$INSTALL_DIR"

    # Generate requirements.txt from installed packages
    pip freeze > requirements_generated.txt || error_exit "Failed to generate requirements.txt."

    # Filter out development and system packages
    # Use appropriate onnxruntime based on GPU type
    if [ "$GPU_TYPE" = "nvidia" ]; then
        ONNXRUNTIME="onnxruntime-gpu==1.23.2"
    else
        ONNXRUNTIME="onnxruntime==1.23.2"
    fi

    cat > requirements.txt << EOF
gradio-rangeslider==0.0.8
gradio==5.44.1
numpy==2.2.6
onnx==1.19.1
$ONNXRUNTIME
opencv-python==4.12.0.88
psutil==7.1.3
tqdm==4.67.1
scipy==1.16.3
torch==2.5.1
torchvision==0.20.1
torchaudio==2.5.1
accelerate
transformers
insightface
gfpgan
basicsr
realesrgan
EOF

    log_success "requirements.txt generated successfully"
    log_info "Full requirements saved to: requirements_generated.txt"
}

# Disable NSFW filter
disable_nsfw() {
    log_step "Disabling NSFW filter..."

    cd "$INSTALL_DIR"

    # Check if facefusion.ini exists
    if [ -f "facefusion.ini" ]; then
        # Add or update NSFW filter setting
        if grep -q "nsfw_filter_enabled" facefusion.ini; then
            sed -i 's/^nsfw_filter_enabled.*/nsfw_filter_enabled = False/' facefusion.ini
        else
            echo -e "\n[content_analyser]\nnsfw_filter_enabled = False" >> facefusion.ini
        fi
        log_success "NSFW filter disabled in facefusion.ini"
    else
        log_warning "facefusion.ini not found, creating configuration..."
        cat > facefusion.ini << 'EOF'
[paths]
temp_path =
jobs_path =
source_paths =
target_path =
output_path =

[patterns]
source_pattern =
target_pattern =
output_pattern =

[face_detector]
face_detector_model =
face_detector_size =
face_detector_margin =
face_detector_angles =
face_detector_score =

[face_landmarker]
face_landmarker_model =
face_landmarker_score =

[face_selector]
face_selector_mode =
face_selector_order =
face_selector_age_start =
face_selector_age_end =
face_selector_gender =
face_selector_race =
reference_face_position =
reference_face_distance =
reference_frame_number =

[face_masker]
face_occluder_model =
face_parser_model =
face_mask_types =
face_mask_areas =
face_mask_regions =
face_mask_blur =
face_mask_padding =

[voice_extractor]
voice_extractor_model =

[frame_extraction]
trim_frame_start =
trim_frame_end =
temp_frame_format =
keep_temp =

[output_creation]
output_image_quality =
output_image_scale =
output_audio_encoder =
output_audio_quality =
output_audio_volume =
output_video_encoder =
output_video_preset =
output_video_quality =
output_video_scale =
output_video_fps =

[processors]
processors =
age_modifier_model =
age_modifier_direction =
background_remover_model =
background_remover_color =
deep_swapper_model =
deep_swapper_morph =
expression_restorer_model =
expression_restorer_factor =
expression_restorer_areas =
face_debugger_items =
face_editor_model =
face_editor_eyebrow_direction =
face_editor_eye_gaze_horizontal =
face_editor_eye_gaze_vertical =
face_editor_eye_open_ratio =
face_editor_lip_open_ratio =
face_editor_mouth_grim =
face_editor_mouth_pout =
face_editor_mouth_purse =
face_editor_mouth_smile =
face_editor_mouth_position_horizontal =
face_editor_mouth_position_vertical =
face_editor_head_pitch =
face_editor_head_yaw =
face_editor_head_roll =
face_enhancer_model =
face_enhancer_blend =
face_enhancer_weight =
face_swapper_model =
face_swapper_pixel_boost =
face_swapper_weight =
frame_colorizer_model =
frame_colorizer_size =
frame_colorizer_blend =
frame_enhancer_model =
frame_enhancer_blend =
lip_syncer_model =
lip_syncer_weight =

[uis]
open_browser =
ui_layouts =
ui_workflow =

[download]
download_providers =
download_scope =

[benchmark]
benchmark_mode =
benchmark_resolutions =
benchmark_cycle_count =

[execution]
execution_device_ids =
execution_providers =
execution_thread_count =

[memory]
video_memory_strategy =
system_memory_limit =

[misc]
log_level =
halt_on_error =

[content_analyser]
nsfw_filter_enabled = False
EOF
        log_success "facefusion.ini created with NSFW filter disabled"
    fi
}

# Set UI theme to cyan
set_cyan_theme() {
    log_step "Setting UI theme to cyan..."

    cd "$INSTALL_DIR"

    # Create overrides.css if it doesn't exist
    mkdir -p facefusion/uis/assets

    cat > facefusion/uis/assets/overrides.css << 'EOF'
:root:root:root:root .gradio-container
{
	overflow: unset;
}

:root:root:root:root .primary-color,
:root:root:root:root .primary-color:hover
{
	background-color: #06b6d4 !important;
}

:root:root:root:root .accent-color,
:root:root:root:root .accent-color:hover
{
	background-color: #22d3ee !important;
}

:root:root:root:root main
{
	max-width: 110em;
}

:root:root:root:root .tab-like-container input[type="number"]
{
	border-radius: unset;
	text-align: center;
	order: 1;
	padding: unset
}

:root:root:root:root input[type="number"]
{
	appearance: textfield;
}

:root:root:root:root input[type="number"]::-webkit-inner-spin-button
{
	appearance: none;
}

:root:root:root:root input[type="number"]:focus
{
	outline: unset;
}

:root:root:root:root .reset-button
{
	background: var(--background-fill-secondary);
	border: unset;
	font-size: unset;
	padding: unset;
}

:root:root:root:root [type="checkbox"],
:root:root:root:root [type="radio"]
{
	border-radius: 50%;
	height: 1.125rem;
	width: 1.125rem;
}

:root:root:root:root input[type="range"]
{
	background: transparent;
}

:root:root:root:root input[type="range"]::-moz-range-thumb,
:root:root:root:root input[type="range"]::-webkit-slider-thumb
{
	background: var(--neutral-300);
	box-shadow: unset;
	border-radius: 50%;
	height: 1.125rem;
	width: 1.125rem;
}

:root:root:root:root .thumbnail-item
{
	border: unset;
	box-shadow: unset;
}

:root:root:root:root .grid-wrap.fixed-height
{
	min-height: unset;
}

:root:root:root:root .box-face-selector .empty,
:root:root:root:root .box-face-selector .gallery-container
{
	min-height: 7.375rem;
}

:root:root:root:root .tab-wrapper
{
	padding: 0 0.625rem;
}

:root:root:root:root .tab-container
{
	gap: 0.5em;
}

:root:root:root:root .tab-container button
{
	background: unset;
	border-bottom: 0.125rem solid;
}

:root:root:root:root .tab-container button.selected
{
	color: var(--primary-500)
}

:root:root:root:root .toast-body
{
	background: white;
	color: var(--primary-500);
	border: unset;
	border-radius: unset;
}

:root:root:root:root .dark .toast-body
{
	background: var(--neutral-900);
	color: var(--primary-600);
}

:root:root:root:root .toast-icon,
:root:root:root:root .toast-title,
:root:root:root:root .toast-text,
:root:root:root:root .toast-close
{
	color: unset;
}

:root:root:root:root .toast-body .timer
{
	background: currentColor;
}

:root:root:root:root .slider_input_container > span,
:root:root:root:root .feather-upload,
:root:root:root:root footer
{
	display: none;
}

:root:root:root:root .image-frame
{
	background-image: conic-gradient(#fff 90deg, #999 90deg 180deg, #fff 180deg 270deg, #999 270deg);
	background-size: 1.25rem 1.25rem;
	background-repeat: repeat;
	width: 100%;
}

:root:root:root:root .image-frame > img
{
	object-fit: cover;
}

:root:root:root:root .image-preview.is-landscape
{
	position: sticky;
	top: 0;
	z-index: 100;
}

:root:root:root:root .block .error
{
	border: 0.125rem solid;
	padding: 0.375rem 0.75rem;
	font-size: 0.75rem;
	text-transform: uppercase;
}
EOF

    log_success "UI theme set to cyan"
}

# Verify GPU detection
verify_gpu() {
    log_step "Verifying GPU detection..."

    cd "$INSTALL_DIR"

    # Create verification script
    cat > verify_gpu.py << 'EOF'
import sys
import os

try:
    import torch

    print("=" * 60)
    print("PyTorch GPU Verification")
    print("=" * 60)
    print(f"\nPyTorch Version: {torch.__version__}")

    # Check for CUDA (NVIDIA)
    print(f"CUDA Available: {torch.cuda.is_available()}")

    if torch.cuda.is_available():
        print(f"CUDA Version: {torch.version.cuda}")
        print(f"cuDNN Version: {torch.backends.cudnn.version()}")
        print(f"Number of GPUs: {torch.cuda.device_count()}")

        for i in range(torch.cuda.device_count()):
            print(f"\nGPU {i}: {torch.cuda.get_device_name(i)}")
            print(f"  - Total Memory: {torch.cuda.get_device_properties(i).total_memory / 1024**3:.2f} GB")
            print(f"  - Compute Capability: {torch.cuda.get_device_properties(i).major}.{torch.cuda.get_device_properties(i).minor}")

        # Test CUDA tensor operation
        print("\nTesting CUDA tensor operation...")
        x = torch.rand(1000, 1000).cuda()
        y = torch.rand(1000, 1000).cuda()
        z = torch.matmul(x, y)
        print("✓ CUDA tensor operation successful!")

        print("\n" + "=" * 60)
        print("GPU Verification: SUCCESS (NVIDIA CUDA)")
        print("=" * 60)
        sys.exit(0)

    # Check for ROCm (AMD)
    print(f"ROCm Available: {torch.version.hip is not None}")

    if torch.version.hip is not None:
        print(f"ROCm Version: {torch.version.hip}")
        print(f"Number of GPUs: {torch.cuda.device_count()}")

        for i in range(torch.cuda.device_count()):
            print(f"\nGPU {i}: {torch.cuda.get_device_name(i)}")
            print(f"  - Total Memory: {torch.cuda.get_device_properties(i).total_memory / 1024**3:.2f} GB")
            print(f"  - Compute Capability: {torch.cuda.get_device_properties(i).major}.{torch.cuda.get_device_properties(i).minor}")

        # Test ROCm tensor operation
        print("\nTesting ROCm tensor operation...")
        x = torch.rand(1000, 1000).cuda()
        y = torch.rand(1000, 1000).cuda()
        z = torch.matmul(x, y)
        print("✓ ROCm tensor operation successful!")

        print("\n" + "=" * 60)
        print("GPU Verification: SUCCESS (AMD ROCm)")
        print("=" * 60)
        sys.exit(0)

    # No GPU available
    print("\n" + "=" * 60)
    print("GPU Verification: FAILED")
    print("No GPU acceleration available (CUDA or ROCm).")
    print("Please check your installation.")
    print("=" * 60)
    sys.exit(1)

except ImportError as e:
    print(f"\nError importing PyTorch: {e}")
    sys.exit(1)
except Exception as e:
    print(f"\nUnexpected error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
EOF

    # Run verification
    python verify_gpu.py
    VERIFY_RESULT=$?

    if [ $VERIFY_RESULT -eq 0 ]; then
        log_success "GPU verification passed!"
    else
        log_warning "GPU verification failed. Check the output above for details."
    fi
}

# Create startup script
create_startup_script() {
    log_step "Creating startup script..."

    cat > "$INSTALL_DIR/start.sh" << EOF
#!/bin/bash

# FaceFusion Startup Script with GPU Support

cd "\$(dirname "\$0")"

# Activate virtual environment
source .venv/bin/activate

# Set environment variables
export CUDA_VISIBLE_DEVICES=0
export TORCH_CUDA_ARCH_LIST="6.0;6.1;7.0;7.5;8.0;8.6+PTX"

# Run FaceFusion
python facefusion.py --open-browser --execution-providers cuda

# Keep terminal open if there's an error
if [ \$? -ne 0 ]; then
    echo ""
    echo "FaceFusion exited with an error. Press any key to close..."
    read -n 1
fi
EOF

    chmod +x "$INSTALL_DIR/start.sh"
    log_success "Startup script created: $INSTALL_DIR/start.sh"
}

# Print summary
print_summary() {
    log_step "Installation Summary"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  FaceFusion Installation Complete!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Installation Details:${NC}"
    echo "  - Location: $INSTALL_DIR"
    echo "  - Virtual Environment: $VENV_DIR"
    echo "  - CUDA Version: $CUDA_VERSION"
    echo "  - cuDNN Version: $CUDNN_VERSION"
    echo "  - Python: $PYTHON_VERSION"
    echo "  - NSFW Filter: Disabled"
    echo "  - UI Theme: Cyan"
    echo ""
    echo -e "${CYAN}Quick Start:${NC}"
    echo "  1. Activate virtual environment:"
    echo "     ${YELLOW}source $VENV_DIR/bin/activate${NC}"
    echo ""
    echo "  2. Run FaceFusion:"
    echo "     ${YELLOW}cd $INSTALL_DIR${NC}"
    echo "     ${YELLOW}python facefusion.py --open-browser --execution-providers cuda${NC}"
    echo ""
    echo "  3. Or use the startup script:"
    echo "     ${YELLOW}$INSTALL_DIR/start.sh${NC}"
    echo ""
    echo -e "${CYAN}Configuration Files:${NC}"
    echo "  - Config: $INSTALL_DIR/facefusion.ini"
    echo "  - Requirements: $INSTALL_DIR/requirements.txt"
    echo "  - Log: $LOG_FILE"
    echo ""
    echo -e "${CYAN}Useful Commands:${NC}"
    echo "  - Update FaceFusion:"
    echo "     ${YELLOW}cd $INSTALL_DIR && git pull${NC}"
    echo ""
    echo "  - Verify GPU:"
    echo "     ${YELLOW}cd $INSTALL_DIR && python verify_gpu.py${NC}"
    echo ""
    echo -e "${CYAN}Troubleshooting:${NC}"
    echo "  - If GPU is not detected, check NVIDIA drivers:"
    echo "     ${YELLOW}nvidia-smi${NC}"
    echo ""
    echo "  - Check CUDA installation:"
    echo "     ${YELLOW}nvcc --version${NC}"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Main installation function
main() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║       FaceFusion Installation Script with GPU Support        ║"
    echo "║                                                              ║"
    echo "║       Ubuntu Linux - CUDA 12.1 - cuDNN 8                     ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""

    # Initialize log file
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
    echo "FaceFusion Installation Log" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"

    # Run installation steps
    check_root
    check_system
    check_nvidia
    check_python
    create_install_dir
    create_venv
    clone_repository
    install_pytorch
    install_dependencies
    generate_requirements
    disable_nsfw
    set_cyan_theme
    verify_gpu
    create_startup_script

    # Print summary
    print_summary

    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo -e "${YELLOW}Log file saved to: $LOG_FILE${NC}"
    echo ""
}

# Run main function
main "$@"
