# Documentation Index

Complete guide to all documentation files in this project.

## Start Here

**New to this project?** Start with one of these:

1. [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) - Complete project summary (5 min read)
2. [QUICKSTART.md](QUICKSTART.md) - Get building in 5 minutes (3 min read)
3. [PRE-BUILD-CHECKLIST.md](PRE-BUILD-CHECKLIST.md) - Verify you're ready (5 min)

## Main Documentation Files

### [README.md](README.md)
**Quick Reference**
- Project features and benefits
- Basic requirements
- Quick build/flash steps
- Safety warnings

**Best for**: Getting an overview, sharing with others

### [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)
**Comprehensive Guide**
- Full project structure
- How the system works
- Feature comparison
- Getting started paths
- Timeline estimates

**Best for**: Understanding the entire project, planning your approach

### [QUICKSTART.md](QUICKSTART.md)
**Fast Start Guide**
- TL;DR quick steps
- What you get
- Customization options (optional)
- Useful aliases
- Troubleshooting quick reference

**Best for**: Getting started immediately, experienced Linux users

## Setup and Installation

### [SETUP.md](SETUP.md)
**Platform-Specific Setup**
- Linux (native) - Ubuntu, Debian, Fedora, Arch
- Windows (WSL2)
- macOS (Virtual Machine)
- Cloud services (AWS, DigitalOcean, Google Cloud, Azure)
- Docker
- Vagrant
- Troubleshooting setup issues

**Best for**: Preparing your system before building

### [PRE-BUILD-CHECKLIST.md](PRE-BUILD-CHECKLIST.md)
**Verification Checklist**
- Hardware requirements verification
- Software dependencies checklist
- Configuration verification
- USB drive preparation
- Pre-build verification
- Step-by-step build verification

**Best for**: Making sure you're ready before starting

## Building the Distribution

### [BUILDING.md](documentation/BUILDING.md)
**Detailed Build Instructions**
- Prerequisites and tools
- Step-by-step build process
- Customization before build
- Monitoring build progress
- Verification steps
- Advanced customization
- Performance optimization
- Build troubleshooting

**Best for**: Detailed build instructions, advanced users, when things go wrong

**Topics covered:**
- Installing dependencies for different Linux distros
- Customizing package list
- Modifying boot configuration
- Building step-by-step
- Monitoring and verification
- Common build issues and solutions

## Using Persistent Storage

### [PERSISTENCE.md](documentation/PERSISTENCE.md)
**Persistent Storage Guide**
- What persistence is
- Creating persistence partition
- Using persistent storage
- Encrypting persistent storage
- Backing up persistent data
- Resizing partitions
- Performance tips
- Troubleshooting persistence

**Best for**: Using and managing persistent storage

**Topics covered:**
- Automatic vs manual partition creation
- File organization in persistent storage
- LUKS encryption
- SSH and GPG keys in persistent storage
- Incremental backups
- Recovering corrupted data

## Customization and Tweaking

### [CUSTOMIZATION.md](documentation/CUSTOMIZATION.md)
**Advanced Customization**
- Modifying package list
- Boot configuration options
- Custom startup scripts
- Adding applications
- Desktop environments
- Performance tuning
- Network customization
- Language and locale
- Building custom packages

**Best for**: Advanced users, customizing beyond defaults

**Topics covered:**
- Adding/removing packages
- Boot menu customization
- Custom scripts and setup
- Themes and wallpapers
- VPN configuration
- Lightweight vs performance setups
- Kernel customization
- Custom .deb packages

## Troubleshooting and Support

### [TROUBLESHOOTING.md](documentation/TROUBLESHOOTING.md)
**Problem Solving Guide**
- Build issues (debootstrap, disk space, dependencies, mounting)
- USB flashing issues (device not found, busy, verification)
- Boot issues (won't boot, black screen, slow)
- Runtime issues (no internet, Tor problems, persistence)
- Performance issues (system slow, high I/O)
- Data recovery options
- How to report issues

**Best for**: When something goes wrong

**Coverage:**
- 15+ common issues with solutions
- Troubleshooting tips and commands
- How to collect diagnostic information
- When to seek external help

## Using This Documentation

### By Task

| I want to... | Start with... |
|-------------|---------------|
| Understand the project | PROJECT_OVERVIEW.md |
| Get started quickly | QUICKSTART.md |
| Set up my system | SETUP.md |
| Verify I'm ready | PRE-BUILD-CHECKLIST.md |
| Build step-by-step | BUILDING.md |
| Use persistence | PERSISTENCE.md |
| Customize the system | CUSTOMIZATION.md |
| Fix a problem | TROUBLESHOOTING.md |
| Learn about files | This file (INDEX.md) |

### By Experience Level

**Beginner**
1. README.md - Overview
2. SETUP.md - Prepare system
3. QUICKSTART.md - Fast start
4. PRE-BUILD-CHECKLIST.md - Verify
5. Ask for help if stuck

**Intermediate**
1. PROJECT_OVERVIEW.md - Full understanding
2. BUILDING.md - Detailed process
3. PERSISTENCE.md - Storage setup
4. TROUBLESHOOTING.md - Problems

**Advanced**
1. CUSTOMIZATION.md - Advanced tweaks
2. BUILDING.md - Build process details
3. Script source code - Under the hood
4. Debian documentation - For deep dives

## File Locations

### Root Directory
- **README.md** - Project introduction
- **QUICKSTART.md** - 5-minute quick start
- **PROJECT_OVERVIEW.md** - Complete overview
- **SETUP.md** - System setup guide
- **PRE-BUILD-CHECKLIST.md** - Pre-build verification
- **INDEX.md** - This file

### /build-scripts/
- **build-tails-distro.sh** - Main build script
- **flash-to-usb.sh** - USB flashing script

### /config/
- **packages-list.txt** - Packages to install
- **grub-config.cfg** - Boot configuration

### /custom-packages/
- **custom-setup.sh** - Custom initialization

### /documentation/
- **BUILDING.md** - Detailed build guide
- **PERSISTENCE.md** - Storage guide
- **CUSTOMIZATION.md** - Customization guide
- **TROUBLESHOOTING.md** - Problem solving

## Quick Reference Commands

### Common Commands

```bash
# Navigate to project
cd OS\ Distor

# Make scripts executable
chmod +x build-scripts/*.sh

# Build the distribution
sudo ./build-scripts/build-tails-distro.sh

# List USB devices
lsblk -d | grep -E "sd|nvme"

# Flash to USB
sudo ./build-scripts/flash-to-usb.sh /dev/sdX

# Check system specs
uname -a
df -h
free -h
lsb_release -a

# Verify build
sha256sum iso/custom-tails-*.iso
```

## Key Concepts

**Live System** - OS runs from USB/RAM, no permanent changes unless persistence enabled

**Persistence** - Optional storage partition that saves files between reboots

**Tor** - Built-in anonymization network for privacy

**Chroot** - Isolated filesystem environment used for building

**ISO** - Bootable disk image that gets written to USB

**SquashFS** - Compressed read-only filesystem used for system files

## System Requirements Quick Check

```bash
# Check disk space
df -h /

# Check RAM
free -h

# Check processor
lscpu

# Check for 64-bit
uname -m  # Should show: x86_64
```

## Documentation Maintenance

- Last updated: 2026-06-15
- Version: 1.0
- Based on: Tails OS / Debian Bullseye

## Getting Help

### If You're Stuck

1. **Check TROUBLESHOOTING.md** - Most questions are answered there
2. **Check relevant documentation file** - Specific instructions for your task
3. **Search this INDEX.md** - Find right documentation
4. **Check script comments** - Scripts have helpful comments
5. **Consult external resources**:
   - Tails documentation: https://tails.boum.org/
   - Debian documentation: https://debian.org/
   - Linux Forums and Communities

### Reporting Issues

Include:
- [ ] Which step failed
- [ ] Exact error message
- [ ] Your system info (Linux distro, version)
- [ ] Which documentation you tried
- [ ] What you already tried to fix it

## Documentation Tips

- **Use Ctrl+F** to search within files
- **Follow recommended reading order** for your experience level
- **Check the table of contents** at top of each file
- **Links between files** navigate to related topics
- **Code blocks** can be copied and pasted directly
- **Checkboxes** help you track progress

## Next Steps

### Choose Your Path:

- **Not sure what to do?** → [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)
- **Want quick start?** → [QUICKSTART.md](QUICKSTART.md)
- **Need system setup?** → [SETUP.md](SETUP.md)
- **Ready to verify?** → [PRE-BUILD-CHECKLIST.md](PRE-BUILD-CHECKLIST.md)
- **Have a problem?** → [TROUBLESHOOTING.md](documentation/TROUBLESHOOTING.md)
- **Want details?** → [BUILDING.md](documentation/BUILDING.md)

---

**Happy Building! 🚀**

For the complete index of all documentation, see this file.
For quick start, go to QUICKSTART.md.
For the big picture, go to PROJECT_OVERVIEW.md.
