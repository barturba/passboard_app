#!/bin/bash

# Password Board - Multi-Platform Build Script
# Builds the Flutter app for Windows, Linux, and macOS

set -e  # Exit on any error

echo "🚀 Building Password Board for all platforms..."
echo "==============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Please run this script from the Flutter project root directory"
    exit 1
fi

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Create build directory
mkdir -p builds

# Build for Linux
print_status "Building for Linux..."
if flutter build linux --release; then
    print_success "Linux build completed"
    # Create Linux archive
    cd build/linux/x64/release/bundle
    tar -czf "../../../../builds/password_board_linux.tar.gz" .
    cd ../../../../
    print_success "Linux build archived: builds/password_board_linux.tar.gz"
else
    print_error "Linux build failed"
fi

# Build for Windows
print_status "Building for Windows..."
if flutter build windows --release; then
    print_success "Windows build completed"
    # Create Windows archive
    cd build/windows/x64/runner/Release
    zip -r "../../../../builds/password_board_windows.zip" .
    cd ../../../../
    print_success "Windows build archived: builds/password_board_windows.zip"
else
    print_error "Windows build failed"
fi

# Build for macOS
print_status "Building for macOS..."
if flutter build macos --release; then
    print_success "macOS build completed"
    # Create macOS archive
    cd build/macos/Build/Products/Release
    zip -r "../../../../builds/password_board_macos.zip" Password\ Board.app
    cd ../../../../
    print_success "macOS build archived: builds/password_board_macos.zip"
else
    print_error "macOS build failed"
fi

# Build for Web (optional)
print_status "Building for Web..."
if flutter build web --release; then
    print_success "Web build completed"
    # Create web archive
    cd build/web
    zip -r "../builds/password_board_web.zip" .
    cd ../..
    print_success "Web build archived: builds/password_board_web.zip"
else
    print_warning "Web build failed (optional)"
fi

print_success "All builds completed!"
echo ""
echo "Build artifacts created in 'builds/' directory:"
echo "📦 Linux:   builds/password_board_linux.tar.gz"
echo "📦 Windows: builds/password_board_windows.zip"
echo "📦 macOS:   builds/password_board_macos.zip"
echo "📦 Web:     builds/password_board_web.zip (optional)"
echo ""
echo "To run the apps:"
echo "🐧 Linux:   Extract tar.gz and run ./password_board"
echo "🪟 Windows: Extract zip and run password_board.exe"
echo "🍎 macOS:   Extract zip and run Password Board.app"
echo "🌐 Web:     Extract zip and serve with a web server"
echo ""
print_success "Happy deploying! 🎉"
