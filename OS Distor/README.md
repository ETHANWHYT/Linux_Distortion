# Custom Tails-Based Linux Distribution for USB

A bootable, privacy-focused Linux distribution based on Tails OS with common Linux features, optimized for 16GB USB drives with persistent storage capability.

## Features

✓ **Privacy-Focused**: Based on Tails OS  
✓ **Bootable USB**: Live USB with persistence  
✓ **Common Tools**: Development, security, multimedia tools  
✓ **Persistence**: Store data between sessions  
✓ **16GB Optimized**: Perfectly sized for 16GB USB drives  
✓ **Tor Integration**: Automatic anonymization  
✓ **No Disk Traces**: Leaves no data on host system  

## Quick Start

### Prerequisites
- Linux system (Ubuntu/Debian recommended)
- 16GB USB drive
- ~8GB free disk space for building
- Internet connection

### Build Steps

1. **Clone/Setup Project**
   ```bash
   cd OS\ Distor
   chmod +x build-scripts/*.sh
   ```

2. **Run Build Script**
   ```bash
   sudo ./build-scripts/build-tails-distro.sh
   ```

3. **Flash to USB Drive**
   ```bash
   sudo ./build-scripts/flash-to-usb.sh /dev/sdX
   ```

4. **Boot and Run**
   - Plug USB into target computer
   - Boot from USB (F12, ESC, or DEL during startup)
   - Select "Live with persistence" option

## Project Structure

```
OS Distor/
├── README.md                 # This file
├── build-scripts/           # Building and flashing scripts
│   ├── build-tails-distro.sh      # Main build script
│   ├── flash-to-usb.sh            # USB flashing script
│   └── setup-persistence.sh       # Persistence configuration
├── config/                  # Configuration files
│   ├── packages-list.txt          # Packages to install
│   ├── live-build.conf            # Live-build configuration
│   └── grub-config.cfg            # Boot configuration
├── custom-packages/         # Custom scripts and packages
│   └── custom-setup.sh             # Custom initialization
├── documentation/           # Detailed guides
│   ├── BUILDING.md                 # Detailed build instructions
│   ├── PERSISTENCE.md              # Persistence setup guide
│   ├── CUSTOMIZATION.md            # How to customize
│   └── TROUBLESHOOTING.md          # Common issues
└── iso/                     # Output directory (created after build)
    └── custom-tails.iso           # Final bootable ISO
```

## Customization

Edit these files to customize your distro:

1. **Packages** (`config/packages-list.txt`) - Add/remove tools
2. **Boot Options** (`config/grub-config.cfg`) - Modify boot behavior
3. **Custom Scripts** (`custom-packages/custom-setup.sh`) - Run on boot

## Important Notes

⚠️ **This requires a Linux system to build**  
⚠️ **Flashing will erase the USB drive**  
⚠️ **Use only for legal purposes**  

## Safety Warnings

- This creates a live system that leaves minimal traces
- Use responsibly and legally
- Store sensitive data with encryption
- Test in virtual machine first if possible

## Support

See `documentation/TROUBLESHOOTING.md` for common issues.

## License

Based on Tails OS (GNU GPL 3.0)

## Disclaimer

This tool is provided for educational and legitimate privacy purposes only. Users are responsible for ensuring their use complies with local laws and regulations.
