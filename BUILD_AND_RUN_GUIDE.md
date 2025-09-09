# DriveLess Flutter - Build & Run Guide 📱

Complete step-by-step instructions for building and running DriveLess on all platforms and devices.

## 🛠️ Prerequisites

### Required Software
- **Flutter SDK** (latest stable)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development - macOS only)
- **VS Code** or **Android Studio** (IDE)

### Verify Installation
```bash
flutter doctor -v
```
Ensure all checkmarks are green for your target platforms.

---

## 🤖 Android Development

### Android Emulator Setup

#### 1. Create/Configure Emulator (One-time setup)
```bash
# List available emulators
flutter emulators

# If no emulators exist, create one in Android Studio:
# - Open Android Studio
# - Tools > AVD Manager
# - Create Virtual Device
# - Choose Pixel 7 Pro or similar (API 30+)
# - Download system image if needed
# - Finish setup
```

#### 2. Fix Common Emulator Storage Issues
```bash
# Option A: Wipe emulator data (clears storage)
flutter emulators --launch <emulator-name> --cold-boot

# Option B: Create new emulator with more storage
# In Android Studio AVD Manager:
# - Edit existing emulator
# - Advanced Settings > Internal Storage: 8GB+
# - SD Card: 2GB+
```

#### 3. Launch Emulator & Run App
```bash
# Start emulator
flutter emulators --launch Pixel_7_Pro  # Replace with your emulator name

# Wait for emulator to fully boot, then run
flutter run -d emulator-5554

# Alternative: Let Flutter pick the device
flutter run
```

### Physical Android Device (Pixel 2)

#### 1. Enable Developer Options
1. Go to **Settings > About phone**
2. Tap **Build number** 7 times
3. Go to **Settings > System > Developer options**
4. Enable **USB debugging**
5. Enable **Install via USB**

#### 2. Connect & Run
```bash
# Check device is detected
flutter devices

# Should show something like:
# Pixel 2 (mobile) • HT82P1A01886 • android-arm64 • Android 11 (API 30)

# Run on connected device
flutter run -d HT82P1A01886  # Replace with your device ID
```

#### 3. If Build Fails - Troubleshooting
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug

# If minSdk errors, ensure android/app/build.gradle.kts has:
# minSdk = 24
```

---

## 🍎 iOS Development

### iOS Simulator Setup

#### 1. Install Xcode Command Line Tools
```bash
xcode-select --install
```

#### 2. Open iOS Simulator
```bash
# List available simulators
xcrun simctl list devices

# Launch specific simulator
xcrun simctl boot "iPhone 15 Pro"

# Or open Simulator app
open -a Simulator
```

#### 3. Run on iOS Simulator
```bash
# Run on any available iOS simulator
flutter run -d ios

# Or specify simulator
flutter run -d "iPhone 15 Pro"
```

### Physical iPhone 16 Pro

#### 1. Xcode Setup (Required)
1. **Open Xcode** (not VS Code for iOS device deployment)
2. **Apple Developer Account**: Sign in with your Apple ID
   - Xcode > Preferences > Accounts > Add Apple ID
3. **Team Selection**: Ensure your team is selected

#### 2. Open Project in Xcode
```bash
# Navigate to iOS directory
cd ios/

# Open in Xcode
open Runner.xcworkspace  # Use .xcworkspace, NOT .xcodeproj
```

#### 3. Configure Signing & Deployment
1. In Xcode, select **Runner** project
2. Select **Runner** target
3. **Signing & Capabilities** tab:
   - **Team**: Select your Apple ID team
   - **Bundle Identifier**: Should be `com.driveless.app`
   - **Provisioning Profile**: Automatic

#### 4. Connect iPhone & Deploy
1. **Connect iPhone 16 Pro** via USB
2. **Trust Computer** when prompted on device
3. **Enable Developer Mode** on iPhone:
   - Settings > Privacy & Security > Developer Mode > On

```bash
# Back in terminal, check device is detected
flutter devices

# Should show your iPhone
# Run on iPhone (use Xcode is recommended for first deployment)
flutter run -d "iPhone 16 Pro"  # Replace with actual device name
```

#### 5. If iOS Build Fails
```bash
# Common fixes:
flutter clean
cd ios/
pod deintegrate
pod install --repo-update
cd ..
flutter build ios --debug
```

---

## 💻 IDE-Specific Instructions

### VS Code (Recommended for Flutter)

#### Setup
1. **Install Extensions**:
   - Flutter
   - Dart
   - Flutter Widget Inspector

#### Running
1. **Open** project in VS Code
2. **Command Palette** (Cmd/Ctrl + Shift + P)
3. **"Flutter: Select Device"** - choose your target
4. **F5** to run in debug mode
5. **Or** use terminal commands above

### Android Studio

#### Setup
1. **Flutter Plugin** installed
2. **Dart Plugin** installed

#### Running
1. **Open** project in Android Studio
2. **Device Dropdown** in toolbar - select target device
3. **Run Button** (▶️) or **Shift + F10**

### Xcode (iOS Only - Required for Physical Device)

#### When to Use Xcode
- **Physical iPhone deployment** (first time)
- **iOS build issues** requiring native debugging
- **Certificate/signing problems**

#### Process
1. **Open** `ios/Runner.xcworkspace` in Xcode
2. **Select** your iPhone from device dropdown
3. **Build & Run** (▶️ button)

---

## 🚀 Quick Command Reference

```bash
# Essential commands
flutter doctor                          # Check setup
flutter devices                         # List connected devices
flutter emulators                       # List available emulators
flutter clean                          # Clean build cache
flutter pub get                        # Get dependencies

# Running on different platforms
flutter run                            # Auto-select device
flutter run -d android                 # Any Android device
flutter run -d ios                     # Any iOS device
flutter run -d chrome                  # Web browser
flutter run -d emulator-5554           # Specific emulator
flutter run -d "iPhone 15 Pro"         # Specific simulator
flutter run -d HT82P1A01886           # Specific physical device

# Building
flutter build apk --debug             # Android debug APK
flutter build apk --release           # Android release APK
flutter build ios --debug             # iOS debug build
flutter build ios --release           # iOS release build
```

---

## ⚠️ Troubleshooting Common Issues

### Android Emulator "Not Enough Space"
```bash
# Solution 1: Wipe emulator data
flutter emulators --launch <name> --cold-boot

# Solution 2: Increase storage in Android Studio AVD Manager
# Edit emulator > Advanced > Internal Storage: 8GB+
```

### iOS "Flutter engine crash"
```bash
# Clean everything
flutter clean
cd ios/
rm -rf Pods/
rm Podfile.lock
pod install --repo-update
cd ..
flutter build ios --debug
```

### "minSdk version" errors
- Check `android/app/build.gradle.kts`
- Ensure `minSdk = 24` (not 23)

### Signing errors (iOS)
- Open `ios/Runner.xcworkspace` in Xcode
- Fix signing issues in Xcode UI
- Run from Xcode first, then try Flutter CLI

---

## ✅ Success Indicators

### Android
- App installs without storage errors
- No overflow UI errors in console
- Swipe navigation works between tabs

### iOS
- No Flutter engine crashes on startup
- App launches to welcome screen
- Sign-in buttons display properly

### Physical Devices
- All features work (location, biometrics, etc.)
- Performance is smooth
- No debug-only artifacts visible

---

## 📞 Quick Help

**If you're still having issues:**

1. **Check Flutter doctor**: `flutter doctor -v`
2. **Clean everything**: `flutter clean && flutter pub get`
3. **Try different device**: Switch between emulator/physical device
4. **Check this guide**: Follow steps exactly for your target platform
5. **Verify versions**: Ensure Flutter, Android Studio, Xcode are up to date

**Platform Priority for Testing:**
1. **Android Emulator** (easiest to set up)
2. **Physical Android** (Pixel 2 - real performance)
3. **iOS Simulator** (if on macOS)
4. **Physical iPhone** (requires more setup, use Xcode first)