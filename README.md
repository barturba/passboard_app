# Password Board

Password manager for organizations. Desktop app for Linux, Windows, macOS.

## Run

```bash
flutter pub get
flutter run -d linux    # or windows or macos
```

## Build

```bash
# All platforms
./build_all.sh

# Individual
flutter build linux
flutter build windows
flutter build macos
```

## Download

Pre-built binaries available on GitHub releases:
- Linux: password_board_linux.tar.gz
- Windows: password_board_windows.zip
- macOS: password_board_macos.zip

## Version Management

### Option 1: Manual Versioning (Recommended)
1. Update version in `pubspec.yaml`
2. Push to main branch
3. Workflow auto-creates tag and release with platform downloads

### Option 2: Auto Version Increment
```bash
# Bump patch version (1.1.1 -> 1.1.2)
./bump_version.sh patch

# Bump minor version (1.1.1 -> 1.2.0)
./bump_version.sh minor

# Bump major version (1.1.1 -> 2.0.0)
./bump_version.sh major

# Then push to trigger release
git push origin main
```

## Testing the Fix

To test that platform downloads are working:

```bash
# Update to a new version (e.g., 1.1.5)
# Edit pubspec.yaml: version: 1.1.5+1

# Commit and push
git add pubspec.yaml
git commit -m "chore: Bump version to 1.1.5"
git push origin main
```

The workflow will build all platforms and upload:
- `password_board_linux.tar.gz`
- `password_board_windows.exe` or `password_board_windows.zip`
- `password_board_macos.zip`
