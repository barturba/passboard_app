# 🚀 Password Board - Build Instructions

Multi-platform build system for the Password Board Flutter application.

## 📋 Quick Start

### Linux/macOS (Bash)
```bash
./build_all.sh
```

### Windows (Command Prompt)
```cmd
build_all.bat
```

### Windows (PowerShell)
```powershell
.\build_all.ps1
```

## 🎯 Build Scripts

### `build_all.sh` (Linux/macOS)
- **Location**: Project root
- **Dependencies**: Flutter SDK, tar, zip
- **Output**: `builds/` directory with platform-specific archives

### `build_all.bat` (Windows CMD)
- **Location**: Project root
- **Dependencies**: Flutter SDK, PowerShell
- **Output**: `builds\` directory with platform-specific archives

### `build_all.ps1` (PowerShell)
- **Location**: Project root
- **Dependencies**: Flutter SDK
- **Features**: Verbose logging, skip options, build size reporting

## 📦 Build Artifacts

After running any build script, you'll find:

```
builds/
├── password_board_linux.tar.gz      # Linux build
├── password_board_windows.zip       # Windows build
├── password_board_macos.zip         # macOS build
└── password_board_web.zip          # Web build (optional)
```

## 🖥️ Platform-Specific Builds

### Linux Build
- **Archive**: `password_board_linux.tar.gz`
- **Contents**: Standalone Linux executable + assets
- **Installation**:
  ```bash
  tar -xzf password_board_linux.tar.gz
  cd password_board
  ./password_board
  ```
- **Requirements**: Ubuntu 18.04+, glibc 2.27+

### Windows Build
- **Archive**: `password_board_windows.zip`
- **Contents**: Windows executable (.exe) + DLLs + assets
- **Installation**: Extract ZIP and run `password_board.exe`
- **Requirements**: Windows 10 version 1903+

### macOS Build
- **Archive**: `password_board_macos.zip`
- **Contents**: Password Board.app bundle
- **Installation**: Extract ZIP and run `Password Board.app`
- **Requirements**: macOS 10.14.6+

### Web Build (Optional)
- **Archive**: `password_board_web.zip`
- **Contents**: HTML/CSS/JS + assets
- **Installation**: Extract and serve with any web server
- **Requirements**: Modern web browser

## ⚙️ Build Configuration

### Flutter Configuration
The project is configured for all desktop platforms:

```bash
# Check current config
flutter config --list

# Enable platforms (if needed)
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-web
```

### Build Commands (Manual)

```bash
# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Web
flutter build web --release
```

## 🔧 Troubleshooting

### Common Issues

1. **"flutter command not found"**
   - Ensure Flutter SDK is in your PATH
   - On macOS: `export PATH="$PATH:/path/to/flutter/bin"`

2. **Build fails on missing dependencies**
   ```bash
   flutter pub get
   flutter clean
   ```

3. **macOS entitlements issues**
   - The build scripts handle entitlements automatically
   - For development, simplified entitlements are used

4. **Windows build fails**
   - Ensure Visual Studio Build Tools are installed
   - Run as Administrator if needed

5. **Linux build fails**
   - Install required system dependencies:
   ```bash
   sudo apt-get update
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev libblkid-dev
   ```

### Build Script Options

#### PowerShell Script Options
```powershell
# Skip cleaning previous builds
.\build_all.ps1 -SkipClean

# Skip web build
.\build_all.ps1 -SkipWeb

# Enable verbose output
.\build_all.ps1 -Verbose

# Combine options
.\build_all.ps1 -SkipWeb -Verbose
```

## 🚀 CI/CD Integration

### GitHub Actions
The project includes automated CI/CD via GitHub Actions (`.github/workflows/build.yml`):

- **Triggers**: Push, PR, Release, Manual
- **Platforms**: Linux, Windows, macOS, Web
- **Artifacts**: Automatically uploaded for each build
- **Releases**: Combined release archives on GitHub releases

### Manual CI/CD
```bash
# Run all builds
./build_all.sh

# Create release
# Upload builds/ contents to your release platform
```

## 📊 Build Information

### Build Size Estimates
- **Linux**: ~50-80 MB (compressed)
- **Windows**: ~60-100 MB (compressed)
- **macOS**: ~80-120 MB (compressed)
- **Web**: ~5-15 MB (compressed)

### Build Time Estimates
- **Linux**: 2-5 minutes
- **Windows**: 3-6 minutes
- **macOS**: 4-8 minutes
- **Web**: 1-3 minutes

## 🎯 Distribution

### For MSP Clients
1. Choose the appropriate platform archive
2. Extract the archive
3. Run the executable/application
4. Start managing passwords securely!

### For Development
1. Clone the repository
2. Run `./build_all.sh` (or equivalent)
3. Test on your target platform
4. Deploy the built artifacts

## 📞 Support

If you encounter build issues:

1. Check Flutter doctor: `flutter doctor -v`
2. Verify platform enablement: `flutter config --list`
3. Clean and rebuild: `flutter clean && flutter pub get`
4. Check system requirements for your platform

---

**Happy Building!** 🎉

*Built with ❤️ for MSP password management*
