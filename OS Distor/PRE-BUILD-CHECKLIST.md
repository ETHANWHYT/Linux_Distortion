# Pre-Build Checklist

Complete this checklist before starting the build process.

## System Requirements Checklist

### Hardware
- [ ] Have access to a Linux system (or WSL2/VM)
  - Ubuntu 20.04+
  - Debian 10+
  - Fedora 34+
  - Or other Linux distribution

- [ ] Minimum 8GB free disk space
  - Run `df -h` to verify
  - Ideal: 15GB+ free space

- [ ] At least 2GB RAM (4GB+ recommended)
  - Run `free -h` to check

- [ ] 16GB USB drive available
  - Or larger (larger is fine)
  - Will be completely erased
  - Back up data if needed

- [ ] Internet connection
  - Stable connection
  - At least 2GB download

### Software
- [ ] Linux system is up to date
  ```bash
  sudo apt-get update
  sudo apt-get upgrade
  ```

- [ ] Can run sudo commands without password
  - Or know your sudo password
  - Build requires root privileges

## Project Setup Checklist

### Project Files
- [ ] Project files are in place
  ```bash
  ls -la OS\ Distor/
  # Should show: README.md, QUICKSTART.md, etc.
  ```

- [ ] All directories exist
  ```bash
  # Verify these directories exist:
  - build-scripts/
  - config/
  - custom-packages/
  - documentation/
  ```

- [ ] All required files are present
  - [ ] build-scripts/build-tails-distro.sh
  - [ ] build-scripts/flash-to-usb.sh
  - [ ] config/packages-list.txt
  - [ ] config/grub-config.cfg
  - [ ] custom-packages/custom-setup.sh
  - [ ] documentation/*.md files

### Documentation
- [ ] Read QUICKSTART.md
- [ ] Understand the process (build → flash → boot)
- [ ] Know the system requirements
- [ ] Familiar with basic Linux commands

## Dependencies Checklist

### Ubuntu/Debian Users

```bash
# Run this command to install all dependencies
sudo apt-get install -y \
    wget curl xorriso grub-pc-bin grub-efi-amd64-bin \
    debootstrap squashfs-tools dosfstools mtools \
    build-essential git pv

# After installation, run this to verify
which wget curl xorrisofs debootstrap mksquashfs
```

Check off:
- [ ] wget (installed)
- [ ] curl (installed)
- [ ] xorrisofs (installed)
- [ ] debootstrap (installed)
- [ ] squashfs-tools/mksquashfs (installed)
- [ ] dosfstools (installed)
- [ ] mtools (installed)
- [ ] pv (installed)

### Fedora/RHEL Users

```bash
sudo dnf install -y \
    wget curl xorriso grub2-tools grub2-efi-modules \
    debootstrap squashfs-tools dosfstools mtools \
    gcc make git pv
```

Check off:
- [ ] All packages installed successfully

### Arch Linux Users

```bash
sudo pacman -S \
    wget curl xorriso grub debootstrap \
    squashfs-tools dosfstools mtools \
    base-devel git pv
```

Check off:
- [ ] All packages installed successfully

## Configuration Checklist

### Optional Customization (if desired)

- [ ] Reviewed config/packages-list.txt
  - Keep default or add/remove packages?

- [ ] Reviewed config/grub-config.cfg
  - Adjust boot menu options?

- [ ] Reviewed custom-packages/custom-setup.sh
  - Add custom scripts?

- [ ] Decided on persistence strategy
  - Using persistence? (recommended)
  - Maximum privacy? (no persistence)

## USB Drive Preparation

### Drive Selection
- [ ] Identified your USB device
  ```bash
  lsblk -d | grep -E "sd|nvme"
  # Look for size matching your USB (e.g., 14.9G for 16GB)
  # Note the device name (sdX, nvmeXnXpX, etc.)
  ```

- [ ] Verified it's NOT your system drive
  - [ ] Not /dev/sda (usually system)
  - [ ] Not /dev/nvme0n1 (usually system)
  - [ ] Is a USB drive or external drive

- [ ] Backed up any important data on USB
  ```bash
  # Copy files off USB drive if needed
  cp -r /media/usb/important-data ./backup/
  ```

- [ ] Verified USB size
  ```bash
  lsblk | grep sdX  # Should show ~16GB or larger
  ```

### Drive Unmounting
- [ ] USB drive is currently unmounted
  ```bash
  mount | grep sdX  # Should show nothing
  ```

- [ ] Know how to unmount if needed
  ```bash
  sudo umount /dev/sdX*
  ```

## Disk Space Verification

### Before Starting Build

```bash
# Check available space
df -h

# You need:
# - 8GB for build process
# - 4GB for final ISO
# - Total: 12GB (15GB+ recommended)
```

- [ ] Have verified 8GB+ free space
- [ ] Know where files will be stored
  ```
  Build: /tmp/tails-build-*
  ISO: OS\ Distor/iso/custom-tails-*.iso
  ```

## Backup Verification

If modifying system:
- [ ] Backed up system before installing dependencies
- [ ] Have bootable recovery media available
- [ ] Know how to restore if needed

## Final Verification

### System Ready
- [ ] Linux system running
- [ ] Internet connected
- [ ] At least 8GB free disk space
- [ ] 16GB USB drive identified (not mounted)
- [ ] All dependencies installed
- [ ] All project files present

### Knowledge Ready
- [ ] Understand build takes 20-40 minutes
- [ ] Understand flashing takes 5-10 minutes
- [ ] Know how to select boot menu (F12, ESC, DEL, etc.)
- [ ] Have read QUICKSTART.md
- [ ] Understand persistence concept

### Customization Ready (if customizing)
- [ ] Edited config files if needed
- [ ] Know what packages to add/remove
- [ ] Tested changes in virtual machine first (optional)

## Starting the Build

Once all checkboxes above are checked:

### Step 1: Make Scripts Executable
```bash
cd OS\ Distor
chmod +x build-scripts/*.sh
chmod +x custom-packages/*.sh
```
- [ ] Scripts are executable

### Step 2: Start Build
```bash
sudo ./build-scripts/build-tails-distro.sh
```
- [ ] Build started successfully
- [ ] Watch for any errors
- [ ] Allow 20-40 minutes to complete

### Step 3: Watch Build Progress
In another terminal:
```bash
watch -n 1 'du -sh /tmp/tails-build-*'
```
- [ ] Disk usage is increasing
- [ ] No errors in main terminal
- [ ] Estimated completion time understood

### Step 4: After Build Completes
```bash
ls -lh OS\ Distor/iso/custom-tails-*.iso
```
- [ ] ISO file exists
- [ ] File is ~3-4GB in size
- [ ] Build successful (look for green ✓ indicators)

### Step 5: Flash to USB
```bash
lsblk  # Verify device name one more time
sudo ./build-scripts/flash-to-usb.sh /dev/sdX
```
- [ ] Flashing started (confirm device is correct!)
- [ ] Watch progress
- [ ] Allow 5-10 minutes to complete

### Step 6: First Boot
- [ ] USB removed from computer
- [ ] USB plugged into target computer
- [ ] Target computer restarted
- [ ] Boot menu entered (F12/ESC/DEL)
- [ ] USB selected from boot menu
- [ ] GRUB menu appeared
- [ ] "Live with Persistence" selected
- [ ] System loading
- [ ] Login: tails / password: tails
- [ ] Successfully booted!

## Troubleshooting Checklist

If something goes wrong:

### Build Fails
- [ ] Check disk space (df -h)
- [ ] Check internet connection
- [ ] Review TROUBLESHOOTING.md
- [ ] Check error messages in console
- [ ] Try again (sometimes transient errors)

### Flash Fails
- [ ] Unmount USB (sudo umount /dev/sdX*)
- [ ] Verify USB device name (lsblk)
- [ ] Check disk space (df -h)
- [ ] Try different USB port
- [ ] Use different USB drive

### Boot Fails
- [ ] Check BIOS boot order (enter boot menu)
- [ ] Try different USB port
- [ ] Try pressing different keys for boot menu
- [ ] Test on different computer
- [ ] Check BIOS for USB support

### Still Having Issues
- [ ] Read relevant section in TROUBLESHOOTING.md
- [ ] Check documentation for your system type
- [ ] Verify all steps were followed correctly
- [ ] Try building on different system if possible

## Success Indicators

✅ Build Successful if:
- All steps complete without errors
- ISO file created (~3-4GB)
- Green ✓ checkmarks displayed

✅ Flash Successful if:
- USB appears to be written
- Persistence partition created
- No errors during process

✅ Boot Successful if:
- USB boots on target computer
- GRUB menu appears
- System loads after boot option selected
- Can login (tails/tails)

## Next: Post-Build Steps

Once checklist complete and system running:

1. **First Time Setup**
   - [ ] Wait for Tor to start (~30 seconds)
   - [ ] Verify Tor: Run `check-tor`
   - [ ] Create persistent directories: `mkdir ~/Persistent/{docs,projects}`
   - [ ] Test persistence: Create file, reboot, verify it exists

2. **Regular Use**
   - [ ] Store important files in ~/Persistent/
   - [ ] Enable Tor (usually automatic)
   - [ ] Use for intended purpose

3. **Maintenance**
   - [ ] Keep USB in safe place
   - [ ] Back up persistent data
   - [ ] Rebuild if adding new packages
   - [ ] Document any customizations

## Questions Before Starting?

- **How long will build take?** 20-40 minutes
- **Will I lose data?** Only on the USB drive (will be erased)
- **Can I use on any computer?** Yes, any x86-64 computer
- **Can I save files?** Yes, with persistence enabled
- **Is it really private?** Yes, based on Tails OS
- **Need internet after building?** No, only during build

---

**Ready to start building CustomTails?**

Go to: `QUICKSTART.md`

Or if you need system setup help: `SETUP.md`

Good luck! 🚀
