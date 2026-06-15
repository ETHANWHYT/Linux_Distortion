# Building CustomTails Linux Distribution

Complete step-by-step guide for building the custom Tails-based Linux distribution.

## Prerequisites

### System Requirements
- **Linux System**: Ubuntu 20.04+, Debian 10+, or similar
- **Disk Space**: Minimum 8GB free (recommended 15GB)
- **RAM**: 2GB minimum (4GB+ recommended)
- **Internet**: Reliable connection for downloading packages
- **Time**: 20-45 minutes depending on your system

### Required Tools

```bash
sudo apt-get update
sudo apt-get install -y \
    wget \
    curl \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    debootstrap \
    squashfs-tools \
    dosfstools \
    mtools \
    build-essential \
    git \
    pv
```

### Optional Tools
- **QEMU**: For testing before USB
- **VirtualBox**: For virtual machine testing
- **Live USB Creator**: For GUI-based flashing

## Step 1: Clone/Setup the Project

```bash
cd OS\ Distor
chmod +x build-scripts/*.sh
chmod +x custom-packages/*.sh
```

## Step 2: Customize Configuration (Optional)

Edit configuration files before building:

### Edit Package List
```bash
nano config/packages-list.txt
```
- Add/remove packages as needed
- Lines starting with `#` are ignored
- One package per line

### Edit Boot Configuration
```bash
nano config/grub-config.cfg
```
- Modify boot menu options
- Adjust timeout
- Change boot parameters

### Edit Custom Setup
```bash
nano custom-packages/custom-setup.sh
```
- Add custom scripts/configurations
- Configure services
- Set up custom aliases

## Step 3: Build the Distribution

Run the build script with root privileges:

```bash
sudo ./build-scripts/build-tails-distro.sh
```

### What This Does
1. Verifies system requirements
2. Downloads minimal Debian base system (~500MB)
3. Installs packages from `config/packages-list.txt`
4. Configures the system
5. Creates SquashFS compressed filesystem
6. Configures GRUB bootloader
7. Creates ISO image (~2-4GB)

### Build Progress Indicators

The script will display:
- ✓ for successful steps
- ✗ for errors
- ⚠ for warnings

### Monitoring Build Progress

In another terminal, monitor disk usage:
```bash
watch -n 1 'df -h | head -3; du -sh /tmp/tails-build-* 2>/dev/null'
```

## Step 4: Verify the ISO

After successful build:

```bash
# Check ISO exists
ls -lh iso/custom-tails-*.iso

# Verify ISO integrity
sha256sum iso/custom-tails-*.iso > iso/custom-tails.sha256
cat iso/custom-tails.sha256
```

## Step 5: Flash to USB Drive

### Simple Flash (Recommended)

```bash
# List available drives
lsblk

# Flash to USB (replace sdX with your device)
sudo ./build-scripts/flash-to-usb.sh /dev/sdX
```

### Manual Flash (Alternative)

```bash
# Find USB device
lsblk -d | grep -E "sd|nvme"

# Unmount device
sudo umount /dev/sdX*

# Flash with dd
sudo dd if=iso/custom-tails-*.iso of=/dev/sdX bs=4M status=progress
sudo sync

# Create persistence partition
sudo cfdisk /dev/sdX
# Create new primary partition for remaining space
```

## Step 6: Test the System

### Option A: Boot on Real Hardware
1. Plug USB into target computer
2. Enter boot menu (F12, ESC, DEL, etc.)
3. Select USB device
4. Test functionality

### Option B: Virtual Machine Testing
```bash
# Test with QEMU
qemu-system-x86_64 -m 2G -smp 2 \
    -cdrom iso/custom-tails-*.iso \
    -boot d

# Or use VirtualBox
# Create new VM, attach ISO, boot
```

## Troubleshooting Build Issues

### Issue: "debootstrap: command not found"
**Solution**: Install debootstrap
```bash
sudo apt-get install debootstrap
```

### Issue: "Not enough disk space"
**Solution**: Check disk space
```bash
df -h
# Clean up if needed
sudo apt-get clean
sudo apt-get autoclean
```

### Issue: "Some packages failed to install"
**Solution**: Check package names in config/packages-list.txt
```bash
# Verify package exists
apt-cache search packagename
```

### Issue: "Unmounting filesystems failed"
**Solution**: Manually unmount
```bash
sudo umount /tmp/tails-build-*/chroot/* 2>/dev/null
```

### Issue: "ISO creation failed"
**Solution**: Ensure xorriso is installed
```bash
sudo apt-get install xorriso
```

## Advanced Customization

### Add Custom Packages
Edit `config/packages-list.txt`:
```
# Add any Debian package name
mypackage
another-package
```

### Modify Boot Parameters
Edit `config/grub-config.cfg`:
```
# Common parameters:
quiet splash        # Pretty boot
verbose            # Detailed output
nomodeset          # Fix graphics issues
noapic             # Disable APIC
acpi=off           # Disable ACPI
persistence        # Enable persistent storage
toram              # Load system to RAM
```

### Add Custom Scripts
Create files in `custom-packages/`:
- Scripts are executed during system setup
- Use shebang `#!/bin/bash` at top
- Make executable: `chmod +x scriptname.sh`

### Add Custom Files
Create additional directories:
```bash
mkdir -p custom-packages/files
cp myfile.txt custom-packages/files/
```

## Performance Optimization

### For Slower Systems
- Use `persistence` boot option (reduces RAM usage)
- Disable GUI, use terminal only
- Reduce timeout in GRUB config

### For Faster Systems
- Use `toram` boot option (faster, uses more RAM)
- Increase services running on boot
- Enable hardware acceleration

## Next Steps

1. See `PERSISTENCE.md` for persistent storage setup
2. See `CUSTOMIZATION.md` for advanced tweaks
3. See `TROUBLESHOOTING.md` for common issues

## Getting Help

- Check documentation files
- Review script comments
- Visit: https://tails.boum.org/ (original Tails)
- Visit: https://debian.org/ (Debian documentation)

## Security Notes

- Keep ISO file safe
- Verify SHA256 checksum before distribution
- Test on isolated network when possible
- Keep USB drive in safe place when not in use
- Use encryption for sensitive data on persistent storage

## Legal Disclaimer

This tool is for legitimate privacy and security purposes only. Users are responsible for ensuring compliance with local laws and regulations. Misuse is not condoned.
