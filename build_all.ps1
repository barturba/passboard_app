# Password Board - Multi-Platform Build Script (PowerShell)
# Builds the Flutter app for Windows, Linux, and macOS

param(
    [switch]$SkipClean = $false,
    [switch]$SkipWeb = $false,
    [switch]$Verbose = $false
)

# Colors for PowerShell output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Blue = "Cyan"
$White = "White"

function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Color = $White,
        [string]$Prefix = "[INFO]"
    )
    Write-Host "[$Prefix] $Message" -ForegroundColor $Color
}

Write-ColoredOutput "🚀 Building Password Board for all platforms..." $Blue "START"
Write-ColoredOutput "===============================================" $Blue

# Check if we're in the right directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-ColoredOutput "Please run this script from the Flutter project root directory" $Red "ERROR"
    exit 1
}

# Clean previous builds (unless skipped)
if (-not $SkipClean) {
    Write-ColoredOutput "Cleaning previous builds..." $Blue
    & flutter clean
    if ($LASTEXITCODE -ne 0) {
        Write-ColoredOutput "Failed to clean previous builds" $Red "ERROR"
        exit 1
    }
}

# Get dependencies
Write-ColoredOutput "Getting dependencies..." $Blue
& flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-ColoredOutput "Failed to get dependencies" $Red "ERROR"
    exit 1
}

# Create build directory
if (-not (Test-Path "builds")) {
    New-Item -ItemType Directory -Path "builds" | Out-Null
}

# Build for Linux
Write-ColoredOutput "Building for Linux..." $Blue
& flutter build linux --release
if ($LASTEXITCODE -eq 0) {
    Write-ColoredOutput "Linux build completed" $Green "SUCCESS"

    # Create Linux archive
    $linuxBundlePath = "build/linux/x64/release/bundle"
    if (Test-Path $linuxBundlePath) {
        $archivePath = "builds/password_board_linux.tar.gz"
        if (Test-Path $archivePath) { Remove-Item $archivePath -Force }

        # Use tar if available, otherwise create zip
        try {
            & tar -czf $archivePath -C $linuxBundlePath .
            Write-ColoredOutput "Linux build archived: $archivePath" $Green "SUCCESS"
        }
        catch {
            Write-ColoredOutput "tar not available, creating zip instead" $Yellow "WARNING"
            Compress-Archive -Path "$linuxBundlePath/*" -DestinationPath $archivePath.Replace('.tar.gz', '.zip') -Force
            Write-ColoredOutput "Linux build archived: $($archivePath.Replace('.tar.gz', '.zip'))" $Green "SUCCESS"
        }
    }
} else {
    Write-ColoredOutput "Linux build failed" $Red "ERROR"
}

# Build for Windows
Write-ColoredOutput "Building for Windows..." $Blue
& flutter build windows --release
if ($LASTEXITCODE -eq 0) {
    Write-ColoredOutput "Windows build completed" $Green "SUCCESS"

    # Create Windows archive
    $windowsReleasePath = "build/windows/x64/runner/Release"
    if (Test-Path $windowsReleasePath) {
        $archivePath = "builds/password_board_windows.zip"
        if (Test-Path $archivePath) { Remove-Item $archivePath -Force }

        Compress-Archive -Path "$windowsReleasePath/*" -DestinationPath $archivePath -Force
        Write-ColoredOutput "Windows build archived: $archivePath" $Green "SUCCESS"
    }
} else {
    Write-ColoredOutput "Windows build failed" $Red "ERROR"
}

# Build for macOS
Write-ColoredOutput "Building for macOS..." $Blue
& flutter build macos --release
if ($LASTEXITCODE -eq 0) {
    Write-ColoredOutput "macOS build completed" $Green "SUCCESS"

    # Create macOS archive
    $macOSAppPath = "build/macos/Build/Products/Release/Password Board.app"
    if (Test-Path $macOSAppPath) {
        $archivePath = "builds/password_board_macos.zip"
        if (Test-Path $archivePath) { Remove-Item $archivePath -Force }

        Compress-Archive -Path $macOSAppPath -DestinationPath $archivePath -Force
        Write-ColoredOutput "macOS build archived: $archivePath" $Green "SUCCESS"
    }
} else {
    Write-ColoredOutput "macOS build failed (expected on non-macOS systems)" $Yellow "WARNING"
}

# Build for Web (unless skipped)
if (-not $SkipWeb) {
    Write-ColoredOutput "Building for Web..." $Blue
    & flutter build web --release
    if ($LASTEXITCODE -eq 0) {
        Write-ColoredOutput "Web build completed" $Green "SUCCESS"

        # Create web archive
        $webBuildPath = "build/web"
        if (Test-Path $webBuildPath) {
            $archivePath = "builds/password_board_web.zip"
            if (Test-Path $archivePath) { Remove-Item $archivePath -Force }

            Compress-Archive -Path "$webBuildPath/*" -DestinationPath $archivePath -Force
            Write-ColoredOutput "Web build archived: $archivePath" $Green "SUCCESS"
        }
    } else {
        Write-ColoredOutput "Web build failed (optional)" $Yellow "WARNING"
    }
}

Write-ColoredOutput "All builds completed!" $Green "SUCCESS"
Write-Host ""
Write-Host "Build artifacts created in 'builds/' directory:"
Write-Host "📦 Linux:   builds/password_board_linux.tar.gz (or .zip)"
Write-Host "📦 Windows: builds/password_board_windows.zip"
Write-Host "📦 macOS:   builds/password_board_macos.zip"
Write-Host "📦 Web:     builds/password_board_web.zip (optional)"
Write-Host ""
Write-Host "To run the apps:"
Write-Host "🐧 Linux:   Extract archive and run ./password_board"
Write-Host "🪟 Windows: Extract zip and run password_board.exe"
Write-Host "🍎 macOS:   Extract zip and run Password Board.app"
Write-Host "🌐 Web:     Extract zip and serve with a web server"
Write-Host ""
Write-ColoredOutput "Happy deploying! 🎉" $Green "SUCCESS"

if ($Verbose) {
    Write-Host ""
    Write-Host "Build details:"
    Get-ChildItem -Path "builds" -File | ForEach-Object {
        $size = [math]::Round($_.Length / 1MB, 2)
        Write-Host "  $($_.Name) - $($size) MB"
    }
}
