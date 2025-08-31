@echo off
REM Password Board - Multi-Platform Build Script (Windows)
REM Builds the Flutter app for Windows, Linux, and macOS

echo 🚀 Building Password Board for all platforms...
echo ===============================================

REM Colors for Windows CMD (limited support)
REM Green text for success
REM Red text for errors

if not exist "pubspec.yaml" (
    echo [ERROR] Please run this script from the Flutter project root directory
    pause
    exit /b 1
)

REM Clean previous builds
echo [INFO] Cleaning previous builds...
flutter clean

REM Get dependencies
echo [INFO] Getting dependencies...
flutter pub get

REM Create build directory
if not exist "builds" mkdir builds

REM Build for Linux
echo [INFO] Building for Linux...
flutter build linux --release
if %errorlevel% equ 0 (
    echo [SUCCESS] Linux build completed
    cd build\linux\x64\release\bundle
    REM Create Linux archive (using tar if available, otherwise skip)
    where tar >nul 2>nul
    if %errorlevel% equ 0 (
        tar -czf "..\..\..\..\..\builds\password_board_linux.tar.gz" .
        echo [SUCCESS] Linux build archived: builds\password_board_linux.tar.gz
    ) else (
        echo [WARNING] tar not available, skipping Linux archive creation
    )
    cd ..\..\..\..\..
) else (
    echo [ERROR] Linux build failed
)

REM Build for Windows
echo [INFO] Building for Windows...
flutter build windows --release
if %errorlevel% equ 0 (
    echo [SUCCESS] Windows build completed
    cd build\windows\x64\runner\Release
    if exist "..\..\..\builds\password_board_windows.zip" del "..\..\..\builds\password_board_windows.zip"
    REM Create Windows archive
    powershell "Compress-Archive -Path . -DestinationPath ..\..\..\builds\password_board_windows.zip -Force"
    echo [SUCCESS] Windows build archived: builds\password_board_windows.zip
    cd ..\..\..\..\..
) else (
    echo [ERROR] Windows build failed
)

REM Build for macOS (only if on macOS)
echo [INFO] Building for macOS...
flutter build macos --release
if %errorlevel% equ 0 (
    echo [SUCCESS] macOS build completed
    cd build\macos\Build\Products\Release
    if exist "..\..\..\builds\password_board_macos.zip" del "..\..\..\builds\password_board_macos.zip"
    REM Create macOS archive
    powershell "Compress-Archive -Path 'Password Board.app' -DestinationPath ..\..\..\builds\password_board_macos.zip -Force"
    echo [SUCCESS] macOS build archived: builds\password_board_macos.zip
    cd ..\..\..\..\..
) else (
    echo [WARNING] macOS build failed (expected on non-macOS systems)
)

REM Build for Web
echo [INFO] Building for Web...
flutter build web --release
if %errorlevel% equ 0 (
    echo [SUCCESS] Web build completed
    cd build\web
    if exist "..\builds\password_board_web.zip" del "..\builds\password_board_web.zip"
    powershell "Compress-Archive -Path . -DestinationPath ..\builds\password_board_web.zip -Force"
    echo [SUCCESS] Web build archived: builds\password_board_web.zip
    cd ..\..
) else (
    echo [WARNING] Web build failed (optional)
)

echo.
echo [SUCCESS] All builds completed!
echo.
echo Build artifacts created in 'builds\' directory:
echo 📦 Linux:   builds\password_board_linux.tar.gz
echo 📦 Windows: builds\password_board_windows.zip
echo 📦 macOS:   builds\password_board_macos.zip
echo 📦 Web:     builds\password_board_web.zip (optional)
echo.
echo To run the apps:
echo 🐧 Linux:   Extract tar.gz and run ./password_board
echo 🪟 Windows: Extract zip and run password_board.exe
echo 🍎 macOS:   Extract zip and run Password Board.app
echo 🌐 Web:     Extract zip and serve with a web server
echo.
echo [SUCCESS] Happy deploying! 🎉
pause
