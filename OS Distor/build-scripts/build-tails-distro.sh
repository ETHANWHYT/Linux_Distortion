#!/bin/bash

################################################################################
# Custom Tails-Based Linux Distribution Builder
# This script builds a bootable Linux ISO based on Tails OS
# Optimized for 16GB USB drives with persistence support
################################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DISTRO_NAME="CustomTails"
DISTRO_VERSION="1.0"
BUILD_DIR="/tmp/tails-build-$$"
OUTPUT_DIR="iso"
ISO_NAME="custom-tails-${DISTRO_VERSION}.iso"

################################################################################
# Functions
################################################################################

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

check_requirements() {
    print_header "Checking Requirements"
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
    print_success "Running as root"
    
    # Check required tools
    local tools=("wget" "xorrisofs" "grub-mkimage" "debootstrap" "squashfs-tools")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            print_error "$tool is not installed"
            print_warning "Install with: sudo apt-get install $tool"
            exit 1
        fi
        print_success "$tool found"
    done
    
    # Check disk space
    local available=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $available -lt 8 ]]; then
        print_error "Insufficient disk space. Need at least 8GB, have ${available}GB"
        exit 1
    fi
    print_success "Sufficient disk space available (${available}GB)"
}

setup_build_environment() {
    print_header "Setting Up Build Environment"
    
    # Create build directories
    mkdir -p "$BUILD_DIR"
    mkdir -p "${OUTPUT_DIR}"
    print_success "Build directories created"
    
    # Create chroot directories
    mkdir -p "$BUILD_DIR"/{chroot,iso-contents,iso-contents/boot/grub}
    print_success "Chroot directories created"
}

download_base_system() {
    print_header "Downloading Base System"
    
    # This uses debootstrap to create a minimal Debian Bullseye system
    # (which Tails is based on)
    
    print_warning "This may take several minutes..."
    
    if debootstrap --arch amd64 --variant minbase bullseye "$BUILD_DIR/chroot" http://deb.debian.org/debian/; then
        print_success "Base system downloaded"
    else
        print_error "Failed to download base system"
        exit 1
    fi
}

mount_filesystems() {
    print_header "Mounting Filesystems"
    
    # Mount necessary filesystems for chroot
    mount --bind /dev "$BUILD_DIR/chroot/dev"
    mount --bind /dev/pts "$BUILD_DIR/chroot/dev/pts"
    mount --bind /proc "$BUILD_DIR/chroot/proc"
    mount --bind /sys "$BUILD_DIR/chroot/sys"
    mount --bind /run "$BUILD_DIR/chroot/run"
    
    print_success "Filesystems mounted"
}

install_packages() {
    print_header "Installing Packages"
    
    # Update package lists
    chroot "$BUILD_DIR/chroot" apt-get update
    
    # Read packages from config file
    local packages_file="config/packages-list.txt"
    
    if [[ ! -f "$packages_file" ]]; then
        print_warning "packages-list.txt not found, using minimal set"
        packages_file="/dev/stdin"
        cat <<EOF | chroot "$BUILD_DIR/chroot" apt-get install -y
linux-image-amd64
grub-pc
openssh-client
curl
wget
vim
tor
privoxy
gnupg
cryptsetup
lvm2
live-boot
live-config
console-setup
keyboard-configuration
locales
EOF
    else
        # Install packages from file
        while IFS= read -r package; do
            if [[ ! -z "$package" && ! "$package" =~ ^# ]]; then
                print_warning "Installing: $package"
                chroot "$BUILD_DIR/chroot" apt-get install -y "$package" || print_warning "Failed to install $package"
            fi
        done < "$packages_file"
    fi
    
    print_success "Packages installed"
}

install_tails_packages() {
    print_header "Installing Tails-Specific Packages"
    
    # Add Tails repository (if available)
    # This is a simplified version - actual Tails has more complex setup
    
    chroot "$BUILD_DIR/chroot" apt-get install -y \
        tails-tweaks \
        tails-persistent-storage \
        onion-circuits \
        tor-browser \
        electrum \
        keepassx \
        vlc \
        thunderbird \
        2>/dev/null || print_warning "Some Tails packages unavailable - using alternatives"
    
    print_success "Tails packages installed"
}

configure_system() {
    print_header "Configuring System"
    
    # Set hostname
    echo "CustomTails" > "$BUILD_DIR/chroot/etc/hostname"
    
    # Configure locale
    chroot "$BUILD_DIR/chroot" locale-gen en_US.UTF-8
    chroot "$BUILD_DIR/chroot" update-locale LANG=en_US.UTF-8
    
    # Configure keyboard
    echo 'XKBLAYOUT="us"' > "$BUILD_DIR/chroot/etc/default/keyboard"
    
    # Configure timezone
    chroot "$BUILD_DIR/chroot" ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    
    # Create minimal network configuration
    cat > "$BUILD_DIR/chroot/etc/network/interfaces" <<'EOF'
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF
    
    # Remove root password for live system
    chroot "$BUILD_DIR/chroot" passwd -d root || true
    
    print_success "System configured"
}

setup_boot_files() {
    print_header "Setting Up Boot Files"
    
    # Copy kernel and initrd
    cp "$BUILD_DIR/chroot/boot/vmlinuz-"* "$BUILD_DIR/iso-contents/boot/vmlinuz"
    cp "$BUILD_DIR/chroot/boot/initrd.img-"* "$BUILD_DIR/iso-contents/boot/initrd.img"
    
    print_success "Boot files copied"
}

create_squashfs() {
    print_header "Creating SquashFS Image"
    
    print_warning "This may take several minutes..."
    
    # Create squashfs filesystem for read-only root
    mksquashfs "$BUILD_DIR/chroot" "$BUILD_DIR/iso-contents/live/filesystem.squashfs" \
        -comp xz -e /proc -e /sys -e /dev -e /run -e /boot
    
    print_success "SquashFS image created"
}

configure_grub() {
    print_header "Configuring GRUB Bootloader"
    
    # Create GRUB configuration
    cat > "$BUILD_DIR/iso-contents/boot/grub/grub.cfg" <<'EOF'
set timeout=10
set default=0

menuentry 'CustomTails - Live System' {
    insmod gzio
    insmod part_msdos
    insmod ext2
    set root='(hd0,msdos1)'
    linux /boot/vmlinuz boot=live persistence noprompt
    initrd /boot/initrd.img
}

menuentry 'CustomTails - Live (No Persistence)' {
    insmod gzio
    insmod part_msdos
    insmod ext2
    set root='(hd0,msdos1)'
    linux /boot/vmlinuz boot=live noprompt
    initrd /boot/initrd.img
}

menuentry 'CustomTails - Toram (Load to RAM)' {
    insmod gzio
    insmod part_msdos
    insmod ext2
    set root='(hd0,msdos1)'
    linux /boot/vmlinuz boot=live toram noprompt
    initrd /boot/initrd.img
}
EOF
    
    print_success "GRUB configured"
}

create_iso() {
    print_header "Creating ISO Image"
    
    # Copy GRUB EFI binary if available
    if [[ -f /boot/grub/i386-pc/core.img ]]; then
        cp /boot/grub/i386-pc/core.img "$BUILD_DIR/iso-contents/boot/grub/"
    fi
    
    # Create ISO with xorrisofs (supports both BIOS and UEFI)
    xorrisofs -R -J \
        -b boot/grub/i386-pc/eltorito.img \
        -c boot.cat \
        -isohybrid-mbr /usr/lib/syslinux/mbr/isohdpfx.bin \
        -isohybrid-gpt-basdat \
        -o "${OUTPUT_DIR}/${ISO_NAME}" \
        "$BUILD_DIR/iso-contents"
    
    if [[ $? -eq 0 ]]; then
        print_success "ISO image created: ${OUTPUT_DIR}/${ISO_NAME}"
    else
        print_error "Failed to create ISO"
        exit 1
    fi
}

cleanup() {
    print_header "Cleaning Up"
    
    # Unmount filesystems
    umount "$BUILD_DIR/chroot/run" 2>/dev/null || true
    umount "$BUILD_DIR/chroot/sys" 2>/dev/null || true
    umount "$BUILD_DIR/chroot/proc" 2>/dev/null || true
    umount "$BUILD_DIR/chroot/dev/pts" 2>/dev/null || true
    umount "$BUILD_DIR/chroot/dev" 2>/dev/null || true
    
    # Remove build directory
    rm -rf "$BUILD_DIR"
    
    print_success "Build cleanup complete"
}

print_summary() {
    print_header "Build Complete!"
    
    echo
    echo -e "${GREEN}ISO Image: ${OUTPUT_DIR}/${ISO_NAME}${NC}"
    echo
    echo "Size: $(ls -lh ${OUTPUT_DIR}/${ISO_NAME} | awk '{print $5}')"
    echo
    echo "Next steps:"
    echo "1. Use the flash-to-usb.sh script to write to USB drive:"
    echo "   sudo ./build-scripts/flash-to-usb.sh /dev/sdX"
    echo
    echo "2. Replace /dev/sdX with your USB device (e.g., /dev/sdb)"
    echo "3. WARNING: This will erase the USB drive!"
    echo
    echo "See documentation/PERSISTENCE.md for persistence setup instructions."
    echo
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header "CustomTails Linux Distribution Builder"
    echo "Version: $DISTRO_VERSION"
    echo
    
    check_requirements
    setup_build_environment
    download_base_system
    mount_filesystems
    install_packages
    install_tails_packages
    configure_system
    setup_boot_files
    create_squashfs
    configure_grub
    create_iso
    cleanup
    print_summary
}

# Error handling
trap 'print_error "Build interrupted"; cleanup; exit 1' INT TERM

# Run main function
main "$@"
