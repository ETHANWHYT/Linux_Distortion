# Quick Start Guide

Get your CustomTails USB up and running in 5 minutes.

## TL;DR - Quick Steps

### On a Linux System:

```bash
# 1. Navigate to project
cd OS\ Distor

# 2. Make scripts executable
chmod +x build-scripts/*.sh custom-packages/*.sh

# 3. Build (takes 20-40 minutes)
sudo ./build-scripts/build-tails-distro.sh

# 4. Flash to USB (replace sdX with your device!)
lsblk                                           # List devices first
sudo ./build-scripts/flash-to-usb.sh /dev/sdX

# 5. Boot from USB
# Restart computer, press F12/ESC/DEL for boot menu
# Select USB drive, choose "Live System with Persistence"
```

## What You Get

✓ **Privacy-focused OS** based on Tails  
✓ **Bootable USB** with persistence  
✓ **Common Linux tools** (vim, curl, git, etc.)  
✓ **Tor integration** for anonymity  
✓ **No traces left** on host system  

## Before You Start

- ✓ Linux system (Ubuntu/Debian preferred)
- ✓ 16GB USB drive
- ✓ 8GB free disk space
- ✓ Internet connection
- ✓ 30-45 minutes

## Step 1: Install Dependencies (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y \
    wget curl xorriso grub-pc-bin grub-efi-amd64-bin \
    debootstrap squashfs-tools dosfstools mtools \
    build-essential git pv
```

## Step 2: Customize (Optional)

### Add packages:
```bash
nano config/packages-list.txt
# Add package names, one per line
```

### Configure boot options:
```bash
nano config/grub-config.cfg
# Edit boot menu and parameters
```

## Step 3: Build Distribution

```bash
cd OS\ Distor
chmod +x build-scripts/*.sh
sudo ./build-scripts/build-tails-distro.sh
```

**What this does:**
- Downloads ~500MB of base system
- Installs packages (~2-3GB)
- Creates bootable ISO (~3-4GB)
- **Takes 20-40 minutes**

**Monitor progress** in another terminal:
```bash
watch -n 1 'du -sh /tmp/tails-build-*'
```

## Step 4: Flash to USB

### List USB devices:
```bash
lsblk -d | grep -E "sd|nvme"

# Example output:
# sdb     8:16   1  14.9G  0 disk  ← This is likely your USB
```

### Flash (CAREFUL - erases USB):
```bash
sudo ./build-scripts/flash-to-usb.sh /dev/sdX
# Replace sdX with your device (e.g., sdb)
```

**What this does:**
- Unmounts USB drive
- Writes ISO to USB
- Creates persistent partition (3GB+)
- **Takes 5-10 minutes**

## Step 5: Boot

### At your computer:
1. Plug USB into computer
2. Restart computer
3. Press **F12**, **ESC**, or **DEL** (varies by brand)
4. Select USB from boot menu
5. Select **"Live System with Persistence"** ← Recommended

### First time you'll see:
```
CustomTails Boot Menu
━━━━━━━━━━━━━━━━━━━
> Live System with Persistence    ← Select this
  Live System (No Persistence)
  Live System (RAM - Fastest)
  Live System (Verbose - Debug)
```

### After boot:
- Login: `tails` / password: `tails`
- Wait for Tor to start (~30 seconds)
- Ready to use!

## After First Boot

### Check Tor is working:
```bash
check-tor
# Should show: "Congratulations! You are using Tor."
```

### Save files:
```bash
# Files in ~/Persistent/ are saved between reboots
cp myfile.txt ~/Persistent/
```

### Next boots:
- Plug in USB
- Boot from USB
- Select "Live System with Persistence"
- All files in ~/Persistent/ are there!

## Common Boot Options

| Option | Use Case |
|--------|----------|
| **Live with Persistence** | Use most of the time - saves files |
| **Live without Persistence** | Maximum privacy - no data saved |
| **Live (RAM)** | Fastest but uses RAM, no persistence |
| **Live (Debug)** | Troubleshooting |

## Useful Aliases

```bash
check-tor          # Verify Tor connection
check-ip           # Show current IP
tor-restart        # Restart Tor service
cleartemp          # Securely delete temp files
diskusage          # Show disk usage
```

## Persistence Tips

```bash
# Create organized folders
mkdir ~/Persistent/documents
mkdir ~/Persistent/projects
mkdir ~/Persistent/downloads

# Keep SSH keys safe
mkdir ~/Persistent/.ssh
# (Add your keys here)

# Store important files
cp important.txt ~/Persistent/
```

## Customization Quick Reference

| File | Purpose |
|------|---------|
| `config/packages-list.txt` | Add/remove packages |
| `config/grub-config.cfg` | Boot menu options |
| `custom-packages/custom-setup.sh` | Startup scripts |

## Testing First (Recommended)

Before using on a real computer:

```bash
# Test in virtual machine
qemu-system-x86_64 -m 2G -cdrom iso/custom-tails-*.iso -boot d

# Or use VirtualBox
# Create new VM, attach ISO, boot
```

## Troubleshooting Quick Fix

| Problem | Fix |
|---------|-----|
| Won't boot | Check USB in boot menu, try different port |
| No internet | Wait for Tor to start (30-60 sec) |
| Files not saving | Use persistence option, check ~/Persistent |
| System slow | Select "Toram" boot option or reboot |
| Can't find USB | Run `lsblk` to list devices |

## Next Steps

- See `documentation/BUILDING.md` for detailed build steps
- See `documentation/PERSISTENCE.md` for data storage
- See `documentation/CUSTOMIZATION.md` for advanced setup
- See `documentation/TROUBLESHOOTING.md` for help

## Key Reminders

⚠️ **Make scripts executable**:
```bash
chmod +x build-scripts/*.sh
```

⚠️ **Run with sudo** (needs root):
```bash
sudo ./build-scripts/build-tails-distro.sh
```

⚠️ **Flashing erases USB**:
```bash
# DOUBLE-CHECK device name!
sudo ./build-scripts/flash-to-usb.sh /dev/sdX
```

⚠️ **Back up important data** before flashing

## Getting Help

1. Check `documentation/TROUBLESHOOTING.md`
2. Review relevant documentation file
3. Check Tails documentation: https://tails.boum.org/
4. Check Debian documentation: https://debian.org/

## You're All Set!

You now have everything you need to create a privacy-focused, bootable Linux distribution. Start with the build command and follow the prompts. The system will guide you through each step.

**Good luck! 🚀**
