# Password Board

Enterprise password management tool for MSPs (Managed Service Providers).

## 🎯 Overview

Password Board is a desktop application that helps MSPs organize and manage passwords for multiple clients. Store credentials securely, categorize by client and password type, and access them with one-click copy functionality.

## ✨ Features

- **Client Organization** - Group passwords by client/company
- **Password Types** - Regular, Admin, Enable, Service, Custom categories
- **One-Click Copy** - Instant clipboard access to usernames and passwords
- **Search & Filter** - Quickly find specific credentials
- **Secure Storage** - Local encrypted storage (ready for keychain integration)
- **Cross-Platform** - Linux, Windows, macOS support
- **Modern UI** - Material Design 3 interface

## 🚀 Quick Start

### Prerequisites
- Flutter 3.35.2 or later
- Dart 3.9.0 or later

### Installation

1. **Clone the repository:**
   ```bash
   git clone <your-private-repo-url>
   cd password-board
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   # Linux
   flutter run -d linux

   # Windows
   flutter run -d windows

   # macOS
   flutter run -d macos
   ```

## 📦 Distribution

Pre-built binaries are available for all platforms via GitHub Actions CI/CD:

- **Linux**: `password_board_linux.tar.gz`
- **Windows**: `password_board_windows.zip`
- **macOS**: `password_board_macos.zip`

## 🔧 Development

### Build Scripts
Use the provided build scripts for multi-platform builds:

```bash
# Linux/macOS
./build_all.sh

# Windows
build_all.bat

# PowerShell (all platforms)
.\build_all.ps1
```

### Project Structure
```
lib/
├── models/          # Data models (Client, PasswordEntry)
├── services/        # Business logic (encryption, storage)
├── providers/       # State management
├── screens/         # UI screens
└── widgets/         # Reusable components
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.35.2
- **Language**: Dart 3.9.0
- **State Management**: Provider
- **Storage**: SharedPreferences (with encryption framework)
- **UI**: Material Design 3

## 🔒 Security

- AES encryption framework ready
- Local secure storage implementation
- No cloud dependencies
- Enterprise-ready architecture

## 📋 Usage

1. **Add Clients** - Create client/company profiles
2. **Add Passwords** - Store credentials with categories
3. **Organize** - Group by password types (Admin, Enable, etc.)
4. **Search** - Find passwords instantly
5. **Copy** - One-click clipboard access

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test across all platforms
5. Submit a pull request

## 📄 License

Private repository - All rights reserved.

---

**Built for MSPs, by MSPs.** 🔐
