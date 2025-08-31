# macOS Code Signing Guide for Password Board

## Problem
macOS is blocking your Flutter app with: *"Apple could not verify 'passboard_app' is free of malware"*

This happens because the app is **not code signed** with an Apple Developer certificate.

## 🛠️ Quick Fix (For Testing Only)

### Option 1: Run Once (Simplest)
```bash
# Right-click the app and select "Open"
# OR from terminal:
xattr -d com.apple.quarantine /path/to/passboard_app.app
```

### Option 2: Disable Gatekeeper Temporarily
```bash
# Disable Gatekeeper (not recommended for production)
sudo spctl --master-disable

# Re-enable later:
sudo spctl --master-enable
```

### Option 3: Allow Apps from Anywhere (macOS < 13)
```bash
# For older macOS versions:
sudo spctl --global-disable
```

## ✅ Proper Solution: Code Signing (Recommended)

### Step 1: Join Apple Developer Program
1. Go to [Apple Developer Program](https://developer.apple.com/programs/)
2. Pay $99/year for Individual or Organization account
3. Verify your account (takes 24-48 hours)

### Step 2: Create Developer Certificate
1. **On your Mac**: Open **Keychain Access**
2. **Keychain Access** → **Certificate Assistant** → **Request Certificate from Certificate Authority**
3. Fill in your Apple Developer email and name
4. Save to disk as `.certSigningRequest`

### Step 3: Upload Certificate Request
1. **Apple Developer Portal** → **Certificates, Identifiers & Profiles**
2. **Certificates** → **+** → **macOS App Development**
3. Upload your `.certSigningRequest` file
4. Download the generated `.cer` file

### Step 4: Install Certificate
1. Double-click the downloaded `.cer` file to install in Keychain Access
2. Verify certificate appears in **Keychain Access** → **My Certificates**

### Step 5: Configure Xcode
1. Open your Flutter project in Xcode:
   ```bash
   cd /path/to/your/flutter/project
   open macos/Runner.xcworkspace
   ```
2. **Xcode** → **Runner** → **Signing & Capabilities**
3. **Team**: Select your Apple Developer account
4. **Bundle Identifier**: Use `com.bartasurba.passboard` or your custom domain
5. **Signing Certificate**: Select your development certificate

### Step 6: Update Bundle Identifier (Important!)
```bash
# In Xcode, update the bundle identifier to match your certificate
# Example: com.yourdomain.passboard
```

### Step 7: Build Signed App
```bash
# Clean and rebuild
flutter clean
flutter pub get

# Build signed macOS app
flutter build macos --release
```

### Step 8: Test Signed App
1. The signed app should open without warnings
2. Verify in **System Settings** → **Privacy & Security** → **Developer Tools**

## 🔧 Alternative: Notarization (Advanced)

For distribution outside the App Store, you'll also need notarization:

1. **Create App Store Connect API Key**
2. **Use `altool` or Xcode** to notarize the app
3. **Staple the notarization ticket** to the app

## 📋 Checklist for MSP Deployment

- [ ] Apple Developer Program membership
- [ ] Development certificate installed
- [ ] Proper bundle identifier
- [ ] App signed with certificate
- [ ] Notarized for distribution (optional)
- [ ] Test on multiple macOS versions

## 🚨 Important Notes

### For Enterprise MSP Use:
- **Always use proper code signing** for client deployments
- **Never distribute unsigned apps** to production environments
- **Consider managed certificates** for team development

### Development vs Production:
- **Development builds**: Can use self-signed certificates
- **Production builds**: Must use Apple-issued certificates
- **Distribution builds**: Should be notarized

## 🆘 Troubleshooting

### "Certificate not trusted"
```bash
# Check certificate in Keychain Access
# Right-click certificate → Get Info → Trust → Use System Defaults
```

### "Bundle identifier mismatch"
- Ensure Xcode bundle ID matches your certificate's App ID
- Update in Xcode: Runner → General → Bundle Identifier

### "Provisioning profile issues"
- Regenerate provisioning profiles in Apple Developer Portal
- Download and install new profiles

---

**Need help with any step?** The most common issues are:
1. Wrong bundle identifier
2. Certificate not properly installed
3. Missing Apple Developer Program membership

**For MSP enterprise use, proper code signing is essential for security and trust.** 🔐
