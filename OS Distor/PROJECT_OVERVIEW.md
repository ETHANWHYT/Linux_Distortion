# CustomTails Linux Distribution - Complete Project Overview

## Project Summary

This project provides everything you need to create a custom, privacy-focused Linux distribution based on Tails OS, bootable from a 16GB USB drive with persistent storage capability.

## What's Included

### Core Files

**README.md** - Project overview and feature list
**QUICKSTART.md** - Get started in 5 minutes
**SETUP.md** - Platform-specific setup instructions

### Build Scripts (`build-scripts/`)

| File | Purpose |
|------|---------|
| `build-tails-distro.sh` | Main build script (downloads, installs, creates ISO) |
| `flash-to-usb.sh` | Flashes ISO to USB drive with persistence |

### Configuration Files (`config/`)

| File | Purpose |
|------|---------|
| `packages-list.txt` | List of packages to install (customize here) |
| `grub-config.cfg` | Boot menu configuration |

### Customization (`custom-packages/`)

| File | Purpose |
|------|---------|
| `custom-setup.sh` | Custom startup scripts and configurations |

### Documentation (`documentation/`)

| File | Topics |
|------|--------|
| `BUILDING.md` | Complete build instructions, troubleshooting |
| `PERSISTENCE.md` | Persistent storage setup, encryption, backups |
| `CUSTOMIZATION.md` | Advanced customization, themes, packages |
| `TROUBLESHOOTING.md` | Common issues and solutions |

## Quick Start (TL;DR)

```bash
# On Linux system:
cd OS\ Distor
chmod +x build-scripts/*.sh
sudo ./build-scripts/build-tails-distro.sh    # Build (20-40 min)
lsblk                                          # Find USB device
sudo ./build-scripts/flash-to-usb.sh /dev/sdX # Flash to USB
# Boot from USB, select "Live with Persistence"
```

## Project Structure

```
OS Distor/
├── README.md                      # Project overview
├── QUICKSTART.md                  # 5-minute quick start
├── SETUP.md                       # Platform setup guide
│
├── build-scripts/
│   ├── build-tails-distro.sh     # Create ISO (main script)
│   └── flash-to-usb.sh           # Write to USB
│
├── config/
│   ├── packages-list.txt         # Packages to install
│   └── grub-config.cfg           # Boot configuration
│
├── custom-packages/
│   └── custom-setup.sh           # Custom scripts
│
├── documentation/
│   ├── BUILDING.md               # Detailed build guide
│   ├── PERSISTENCE.md            # Storage setup
│   ├── CUSTOMIZATION.md          # Advanced tweaks
│   └── TROUBLESHOOTING.md        # Help & fixes
│
└── iso/                          # Output (created after build)
    └── custom-tails-*.iso        # Bootable image
```

## Key Features

✅ **Privacy-focused** - Based on Tails OS  
✅ **Bootable USB** - Works on any x86-64 computer  
✅ **Persistent Storage** - Save files between reboots  
✅ **Common Tools** - Development, security, utilities  
✅ **Easy to Customize** - Modify packages, configs, scripts  
✅ **Tor Integration** - Built-in anonymization  
✅ **No Traces** - Leaves minimal data on host system  

## Requirements

- **Linux system** (Ubuntu, Debian, Fedora, etc.)
- **8GB free disk space**
- **2GB+ RAM** (4GB+ recommended)
- **16GB USB drive** (or larger)
- **Stable internet** for downloads

## How It Works

### Phase 1: Build (20-40 minutes)
```
1. Downloads minimal Debian base
2. Installs packages from list
3. Configures system & Tor
4. Creates compressed filesystem
5. Packages into bootable ISO (~3-4GB)
```

### Phase 2: Flash (5-10 minutes)
```
1. Writes ISO to USB drive
2. Creates persistence partition
3. Prepares boot configuration
4. USB is ready to use
```

### Phase 3: Use
```
1. Boot from USB
2. Choose boot option (persistence recommended)
3. System loads from USB
4. Changes saved to persistence partition
5. Shutdown clears RAM, preserves persistent files
```

## Customization Options

Without rebuilding:
- ✓ Add files to persistent storage
- ✓ Install packages manually
- ✓ Modify configuration files

With rebuilding:
- ✓ Add permanent packages (`config/packages-list.txt`)
- ✓ Change boot options (`config/grub-config.cfg`)
- ✓ Add custom scripts (`custom-packages/custom-setup.sh`)
- ✓ Modify Tor/Privoxy settings
- ✓ Add themes, wallpapers, desktop environment

## Common Workflows

### Fresh User
1. Read `QUICKSTART.md`
2. Run `build-scripts/build-tails-distro.sh`
3. Run `build-scripts/flash-to-usb.sh`
4. Boot and use

### Advanced Customizer
1. Edit `config/packages-list.txt` (add programs)
2. Edit `custom-packages/custom-setup.sh` (add scripts)
3. Run build script
4. Flash to USB

### Persistent User
1. Boot with persistence
2. Create files in `~/Persistent/`
3. Files survive between reboots
4. See `documentation/PERSISTENCE.md` for details

### Troubleshooter
1. Check `documentation/TROUBLESHOOTING.md`
2. Run specific commands
3. Fix and retry

## File Sizes

| Item | Size | Time |
|------|------|------|
| Base system | ~500MB | Varies |
| Downloaded packages | ~2-3GB | 2-10 min |
| Final ISO | ~3-4GB | Minutes |
| USB drive needed | ~8GB+ | - |

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Ubuntu/Debian | ✅ Recommended | Best support |
| Fedora/CentOS | ✅ Works | Use `dnf` instead |
| Arch Linux | ✅ Works | Use `pacman` instead |
| WSL2 (Windows) | ✅ Works | Slower than native |
| macOS VM | ✅ Works | Requires VM |
| Cloud Services | ✅ Works | AWS, DigitalOcean, etc. |

## Security Considerations

⚠️ **Privacy Warnings:**
- Tor disabled by default on boot (you enable it)
- Without persistence, no data is saved
- With persistence, encrypt sensitive files
- Don't save passwords in plain text
- Use GPG for encryption

✅ **Privacy Protections:**
- Live system leaves no traces
- Tor prevents ISP snooping
- Persistent storage optional
- Can boot multiple ways (different anonymity levels)

## Comparison with Alternatives

| Feature | CustomTails | Tails OS | Kali | Ubuntu |
|---------|-------------|----------|------|--------|
| Privacy-focused | ✅ | ✅ | ✗ | ✗ |
| Easy customizable | ✅ | ✗ | ✅ | ✅ |
| Tor integrated | ✅ | ✅ | ✗ | ✗ |
| Bootable USB | ✅ | ✅ | ✅ | ✅ |
| Persistent storage | ✅ | ✅ | Partial | ✅ |
| Common tools | ✅ | Limited | ✅ | ✅ |
| Based on | Tails | Custom | Debian | Debian |

## Getting Started Paths

### Path 1: I want to build it now (Experienced Linux user)
1. **Prerequisite check**: Do you have Linux with 8GB free space?
2. **Go to**: `QUICKSTART.md`
3. **Then**: `BUILDING.md` if issues arise

### Path 2: I need to set up my system first (Windows/Mac user)
1. **Go to**: `SETUP.md`
2. **Choose your platform** (WSL, VM, Cloud, Docker)
3. **Complete setup**, then start building

### Path 3: I want to customize before building (Advanced user)
1. **Go to**: `CUSTOMIZATION.md`
2. **Edit**: `config/packages-list.txt`, scripts
3. **Go to**: `BUILDING.md`
4. **Build** with your customizations

### Path 4: Something's wrong (Troubleshooting)
1. **Go to**: `TROUBLESHOOTING.md`
2. **Find your issue**, try solution
3. **Still stuck?** Check other documentation

## Documentation Index

**For Quick Start**: Read in this order
1. This file (you are here)
2. `QUICKSTART.md` - 5 minute overview
3. `BUILDING.md` - Detailed instructions

**For Setup**: Based on your platform
- Linux: `SETUP.md` → Ubuntu/Debian section
- Windows: `SETUP.md` → WSL section
- Mac: `SETUP.md` → Virtual Machine section
- Cloud: `SETUP.md` → Cloud Services section

**For Customization**: If you want to modify
1. `CUSTOMIZATION.md` - How to add/remove packages
2. `BUILDING.md` - How to rebuild
3. `PERSISTENCE.md` - Store custom data

**For Help**: If something goes wrong
1. `TROUBLESHOOTING.md` - Solutions for common issues
2. Relevant documentation file - Detailed information
3. Project README - General info

## Key Concepts

### Live System
- Loads entirely into RAM (when using toram option)
- Or runs from USB (default with persistence)
- No permanent changes unless using persistence
- Faster than regular installation

### Persistence
- Optional third partition on USB
- Saves files between reboots
- Labeled "TailsData" by default
- Can be encrypted

### Tor
- Onion routing for anonymity
- Built-in to system
- Can be enabled/disabled
- Reroutes all traffic through Tor network

### Chroot Environment
- Isolated filesystem for building
- Build script creates/manages automatically
- Uses debootstrap to create minimal Debian
- Packages installed inside chroot

## Typical Timeline

```
Setup & preparation     : 5-10 minutes
Downloading packages    : 2-10 minutes (depends on internet)
Building system        : 10-30 minutes
Creating ISO           : 5 minutes
Flashing to USB        : 5-10 minutes
First boot & testing   : 5-10 minutes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total                  : 30-75 minutes
```

## Next Steps

### I want to build now:
→ Go to **`QUICKSTART.md`**

### I need to setup my system:
→ Go to **`SETUP.md`**

### I want detailed instructions:
→ Go to **`BUILDING.md`**

### I have issues:
→ Go to **`TROUBLESHOOTING.md`**

### I want to customize:
→ Go to **`CUSTOMIZATION.md`**

### I want persistent storage info:
→ Go to **`PERSISTENCE.md`**

## Support Resources

- **Tails Documentation**: https://tails.boum.org/
- **Debian Documentation**: https://debian.org/
- **Linux Foundation**: https://www.linuxfoundation.org/
- **Community Forums**: Stack Overflow, Reddit, Linux forums

## Tips for Success

✓ Read the QUICKSTART.md first
✓ Test in virtual machine before flashing
✓ Keep adequate disk space (15GB minimum)
✓ Use reliable internet connection
✓ Back up important data before flashing USB
✓ Follow device selection carefully
✓ Test boot on different computers
✓ Document your customizations
✓ Keep persistent data encrypted
✓ Verify persistent storage works

## Disclaimer

This tool is for **legitimate privacy and security purposes only**. Users are responsible for:
- Complying with local laws and regulations
- Using the system responsibly and ethically
- Ensuring proper data protection
- Regular backups of important data

Misuse of privacy tools is not condoned and may violate laws in your jurisdiction.

## License

Based on Tails OS (GNU GPL 3.0)
This customization project inherits the same license.

---

**You're ready to build CustomTails!**  
Choose your starting point from the "Next Steps" section above.  
Happy building! 🚀
