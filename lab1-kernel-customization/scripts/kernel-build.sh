#!/bin/bash
# Lab 1: Kernel Compilation Script
# Customizes and compiles Linux kernel

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
KERNEL_VERSION="6.1.85"  # LTS version, stable
KERNEL_MAJOR="v6.x"
KERNEL_DIR="/usr/src/linux-$KERNEL_VERSION"
CORES=$(nproc)
LOG_FILE="$HOME/lab1/logs/kernel-build-$(date +%Y%m%d_%H%M%S).log"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_step() {
    echo -e "\n${BLUE}==>${NC} ${CYAN}$1${NC}" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)"
   exit 1
fi

# Create log directory
mkdir -p "$(dirname $LOG_FILE)"

echo "========================================="
echo "   Lab 1: Kernel Compilation Process    "
echo "========================================="
echo ""
log_info "Kernel version to build: $KERNEL_VERSION"
log_info "CPU cores available: $CORES"
log_info "Log file: $LOG_FILE"
echo ""

# Check disk space (need at least 20GB)
log_step "Step 1: Checking system resources..."
AVAILABLE_SPACE=$(df /usr/src | tail -1 | awk '{print $4}')
REQUIRED_SPACE=$((20 * 1024 * 1024)) # 20GB in KB

if [ $AVAILABLE_SPACE -lt $REQUIRED_SPACE ]; then
    log_error "Insufficient disk space. Need at least 20GB free in /usr/src"
    log_error "Available: $(($AVAILABLE_SPACE / 1024 / 1024))GB"
    exit 1
fi
log_info "Disk space: OK ($(($AVAILABLE_SPACE / 1024 / 1024))GB available)"

# Check memory
TOTAL_MEM=$(free -m | awk 'NR==2 {print $2}')
if [ $TOTAL_MEM -lt 2048 ]; then
    log_warn "Low memory detected ($TOTAL_MEM MB). Compilation may be slow."
    log_warn "Reducing parallel jobs to $(($CORES / 2))"
    CORES=$(($CORES / 2))
    [ $CORES -lt 1 ] && CORES=1
fi
log_info "Memory: ${TOTAL_MEM}MB"

# Install dependencies
log_step "Step 2: Installing build dependencies..."
log_info "This may take a few minutes..."
apt update >> "$LOG_FILE" 2>&1
apt install -y \
    build-essential \
    libncurses-dev \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    bc \
    dwarves \
    rsync \
    kmod \
    cpio \
    >> "$LOG_FILE" 2>&1
log_info "Dependencies installed successfully"

# Download kernel source
log_step "Step 3: Downloading kernel source..."
cd /usr/src

if [ ! -f "linux-$KERNEL_VERSION.tar.xz" ]; then
    log_info "Downloading Linux $KERNEL_VERSION (this will take 5-10 minutes)..."
    wget -q --show-progress \
        https://cdn.kernel.org/pub/linux/kernel/$KERNEL_MAJOR/linux-$KERNEL_VERSION.tar.xz \
        -O linux-$KERNEL_VERSION.tar.xz
    
    if [ $? -ne 0 ]; then
        log_error "Failed to download kernel source"
        exit 1
    fi
    log_info "Download completed"
else
    log_info "Kernel source already downloaded, skipping..."
fi

# Extract kernel source
if [ ! -d "$KERNEL_DIR" ]; then
    log_info "Extracting kernel source..."
    tar xf linux-$KERNEL_VERSION.tar.xz
    log_info "Extraction completed"
else
    log_info "Kernel source already extracted"
fi

cd $KERNEL_DIR

# Copy current config as base
log_step "Step 4: Configuring kernel..."
log_info "Using current kernel config as base..."
if [ -f /boot/config-$(uname -r) ]; then
    cp /boot/config-$(uname -r) .config
    log_info "Current config copied"
else
    log_warn "Current config not found, using defconfig"
    make defconfig >> "$LOG_FILE" 2>&1
fi

# Customize configuration using scripts/config
log_info "Applying custom kernel configurations..."

# Disable debug options (reduces size and compilation time)
log_info "  → Disabling debug options..."
scripts/config --disable DEBUG_INFO
scripts/config --disable DEBUG_INFO_COMPRESSED
scripts/config --disable DEBUG_INFO_REDUCED
scripts/config --disable DEBUG_INFO_SPLIT
scripts/config --disable GDB_SCRIPTS
scripts/config --disable DEBUG_KERNEL

# Performance optimizations
log_info "  → Enabling performance optimizations..."
scripts/config --enable PREEMPT_VOLUNTARY
scripts/config --enable NO_HZ_IDLE
scripts/config --enable HIGH_RES_TIMERS
scripts/config --enable TREE_RCU

# Security features
log_info "  → Enabling security features..."
scripts/config --enable SECURITY
scripts/config --enable HARDENED_USERCOPY
scripts/config --enable FORTIFY_SOURCE
scripts/config --enable STACKPROTECTOR
scripts/config --enable STACKPROTECTOR_STRONG

# Networking features
log_info "  → Configuring network stack..."
scripts/config --module TCP_CONG_BBR
scripts/config --enable TCP_CONG_CUBIC
scripts/config --enable NET_SCH_FQ
scripts/config --enable NET_SCH_FQ_CODEL

# Filesystem support
log_info "  → Enabling filesystem support..."
scripts/config --enable EXT4_FS
scripts/config --enable EXT4_FS_SECURITY
scripts/config --enable BTRFS_FS
scripts/config --enable XFS_FS
scripts/config --enable F2FS_FS

# Set custom kernel name
log_info "  → Setting custom kernel identifier..."
scripts/config --set-str LOCALVERSION "-lab1-custom"

# Update config with defaults for new options
log_info "Updating configuration with defaults..."
make olddefconfig >> "$LOG_FILE" 2>&1

# Show configuration summary
echo ""
log_info "Kernel configuration summary:"
echo "  • Version: $(make kernelrelease 2>/dev/null)"
echo "  • Preemption: VOLUNTARY"
echo "  • Timer frequency: $(grep "^CONFIG_HZ=" .config | cut -d= -f2)"
echo "  • Security: Enhanced"
echo "  • Networking: BBR congestion control"
echo ""

# Confirm before building
read -p "$(echo -e ${YELLOW}Continue with compilation? This will take 30-60 minutes [y/N]:${NC} )" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warn "Compilation cancelled by user"
    exit 0
fi

# Build kernel
log_step "Step 5: Compiling kernel..."
log_info "Starting compilation with $CORES parallel jobs..."
log_info "This will take 30-60 minutes. You can monitor progress in another terminal with:"
log_info "  tail -f $LOG_FILE"
echo ""

START_TIME=$(date +%s)

# Compile kernel
log_info "Building kernel image..."
if ! make -j$CORES >> "$LOG_FILE" 2>&1; then
    log_error "Kernel compilation failed. Check log: $LOG_FILE"
    exit 1
fi

# Build modules
log_info "Building kernel modules..."
if ! make modules -j$CORES >> "$LOG_FILE" 2>&1; then
    log_error "Module compilation failed. Check log: $LOG_FILE"
    exit 1
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
log_info "Compilation completed in $(($DURATION / 60)) minutes $(($DURATION % 60)) seconds"

# Install modules
log_step "Step 6: Installing kernel modules..."
if ! make modules_install >> "$LOG_FILE" 2>&1; then
    log_error "Module installation failed"
    exit 1
fi
log_info "Modules installed successfully"

# Install kernel
log_step "Step 7: Installing kernel..."
if ! make install >> "$LOG_FILE" 2>&1; then
    log_error "Kernel installation failed"
    exit 1
fi
log_info "Kernel installed successfully"

# Update bootloader
log_step "Step 8: Updating bootloader..."
update-grub >> "$LOG_FILE" 2>&1
log_info "Bootloader updated"

# Create kernel info file
KERNEL_INFO="$HOME/lab1/logs/kernel-info.txt"
cat > "$KERNEL_INFO" << EOF
Lab 1: Custom Kernel Build Information
======================================

Build Date: $(date)
Kernel Version: $(make kernelrelease 2>/dev/null)
Build Time: $(($DURATION / 60))m $(($DURATION % 60))s
CPU Cores Used: $CORES

Configuration:
- Preemption: VOLUNTARY
- Security: Enhanced (HARDENED_USERCOPY, FORTIFY_SOURCE)
- Network: BBR congestion control
- Filesystems: EXT4, BTRFS, XFS, F2FS

Installation:
- Kernel: /boot/vmlinuz-$(make kernelrelease 2>/dev/null)
- Modules: /lib/modules/$(make kernelrelease 2>/dev/null)
- Config: /boot/config-$(make kernelrelease 2>/dev/null)

Log File: $LOG_FILE
EOF

chown $SUDO_USER:$SUDO_USER "$KERNEL_INFO"

echo ""
echo "========================================="
log_info "Kernel compilation completed successfully!"
echo "========================================="
echo ""
echo "New kernel: $(make kernelrelease 2>/dev/null)"
echo "Kernel info saved to: $KERNEL_INFO"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Review the kernel info: cat $KERNEL_INFO"
echo "2. Reboot the system: sudo reboot"
echo "3. After reboot, verify with: uname -r"
echo "4. Check boot options: grep menuentry /boot/grub/grub.cfg"
echo ""
log_warn "IMPORTANT: After reboot, you should see the new kernel version"
log_warn "If system fails to boot, select the old kernel from GRUB menu"
echo ""
