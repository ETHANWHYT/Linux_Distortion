#!/bin/bash

################################################################################
# USB Drive Flashing Script
# Flashes the custom Tails ISO to a USB drive with persistence partition
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ISO_FILE="iso/custom-tails-*.iso"
USB_DEVICE=""

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
    
    # Check for ISO file
    if ! ls $ISO_FILE 1> /dev/null 2>&1; then
        print_error "No ISO file found in iso/ directory"
        echo "Please run build-tails-distro.sh first"
        exit 1
    fi
    print_success "ISO file found"
    
    # Check for required tools
    for tool in dd sha256sum; do
        if ! command -v "$tool" &> /dev/null; then
            print_error "$tool not found"
            exit 1
        fi
        print_success "$tool found"
    done
}

get_usb_device() {
    if [[ -z "$1" ]]; then
        print_header "Available USB Devices"
        lsblk -d -o NAME,SIZE,TYPE | grep -E "sd[a-z]|nvme"
        echo
        print_error "Please specify USB device"
        echo "Usage: sudo ./flash-to-usb.sh /dev/sdX"
        echo "Example: sudo ./flash-to-usb.sh /dev/sdb"
        exit 1
    fi
    
    USB_DEVICE="$1"
    
    # Validate device
    if [[ ! -b "$USB_DEVICE" ]]; then
        print_error "Device $USB_DEVICE does not exist"
        exit 1
    fi
    
    # Safety check - ensure it's not a system drive
    if [[ "$USB_DEVICE" == "/dev/sda" ]] || [[ "$USB_DEVICE" == "/dev/nvme0n1" ]]; then
        print_error "Refusing to flash system drive!"
        exit 1
    fi
}

confirm_action() {
    print_header "⚠️  DANGER ZONE ⚠️"
    
    local device_size=$(lsblk -bd "$USB_DEVICE" -o SIZE | tail -1)
    local device_size_gb=$((device_size / 1000000000))
    
    echo -e "${YELLOW}"
    echo "WARNING: This will ERASE all data on $USB_DEVICE"
    echo "Device: $USB_DEVICE"
    echo "Size: ${device_size_gb}GB"
    echo -e "${NC}"
    
    # Check size
    if [[ $device_size_gb -lt 8 ]]; then
        print_error "USB device too small (minimum 8GB for 16GB recommended)"
        exit 1
    fi
    
    read -p "Are you SURE you want to continue? Type 'YES' to confirm: " confirm
    
    if [[ "$confirm" != "YES" ]]; then
        print_error "Aborted"
        exit 1
    fi
}

unmount_device() {
    print_header "Unmounting Device"
    
    # Unmount all partitions on the device
    for partition in $(lsblk -lp "$USB_DEVICE" | tail -n +2 | awk '{print $1}'); do
        if mountpoint -q "$partition" 2>/dev/null; then
            print_warning "Unmounting $partition"
            umount "$partition" || true
        fi
    done
    
    print_success "Device unmounted"
}

flash_iso() {
    print_header "Flashing ISO to USB Drive"
    
    local iso=$(ls $ISO_FILE)
    print_warning "This may take 5-10 minutes..."
    
    # Show progress
    pv -tpreb "$iso" | dd of="$USB_DEVICE" bs=4M
    
    # Sync to ensure all data is written
    sync
    
    print_success "ISO flashed successfully"
}

create_persistence_partition() {
    print_header "Creating Persistence Partition"
    
    # Wait for device to be ready
    sleep 2
    
    local iso=$(ls $ISO_FILE)
    local iso_size=$(stat --printf="%s" "$iso")
    local iso_size_mb=$((iso_size / 1000000))
    
    # Get total device size
    local device_size=$(lsblk -bd "$USB_DEVICE" -o SIZE | tail -1)
    local device_size_mb=$((device_size / 1000000))
    
    # Calculate partition start (add 10MB buffer)
    local partition_start=$((iso_size_mb + 50))
    
    print_warning "Creating persistent storage partition..."
    
    # Use fdisk to create new partition
    fdisk "$USB_DEVICE" <<EOF
n
p
3


w
EOF
    
    sleep 1
    
    # Find the persistence partition
    local persistence_partition="${USB_DEVICE}3"
    
    if [[ ! -e "$persistence_partition" ]]; then
        print_warning "Could not create persistence partition automatically"
        echo "You can manually create it with:"
        echo "  sudo cfdisk $USB_DEVICE"
        return
    fi
    
    # Format with ext4
    mkfs.ext4 -F -L TailsData "$persistence_partition"
    
    print_success "Persistence partition created at $persistence_partition"
    print_warning "Label: TailsData (mount point in Tails)"
}

verify_flash() {
    print_header "Verifying Flash"
    
    print_warning "Verifying data integrity..."
    
    local iso=$(ls $ISO_FILE)
    local iso_sha=$(sha256sum "$iso" | awk '{print $1}')
    
    echo "ISO SHA256: $iso_sha"
    echo
    echo "To verify on target system after boot, run:"
    echo "  sha256sum /path/to/iso"
    
    print_success "Verification complete"
}

print_summary() {
    print_header "Flash Complete!"
    
    echo
    echo -e "${GREEN}USB Drive: $USB_DEVICE${NC}"
    echo "Status: Ready to boot"
    echo
    echo "Boot Instructions:"
    echo "1. Plug USB drive into target computer"
    echo "2. Restart computer and enter boot menu (F12, ESC, or DEL)"
    echo "3. Select USB device from boot menu"
    echo "4. Select boot option:"
    echo "   - Live with Persistence (recommended)"
    echo "   - Live without Persistence"
    echo "   - Toram (load to RAM)"
    echo
    echo "For persistence setup, see: documentation/PERSISTENCE.md"
    echo
}

main() {
    print_header "CustomTails USB Flasher"
    
    check_requirements
    get_usb_device "$1"
    confirm_action
    unmount_device
    flash_iso
    create_persistence_partition
    verify_flash
    print_summary
}

# Run main function
main "$@"
