# 📱 Flutter Installation Guide for Windows

## ✅ Quick Installation Steps

### Step 1: Download Flutter SDK

1. **Download Flutter:**
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Click "Download Flutter SDK" (approximately 1.5 GB)
   - Or direct link: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip

2. **Extract the ZIP file:**
   - Extract to: `C:\src\flutter` (recommended)
   - **DO NOT** extract to `C:\Program Files\` (requires elevated privileges)

### Step 2: Add Flutter to PATH

1. **Open Environment Variables:**
   - Press `Windows Key + R`
   - Type: `sysdm.cpl` and press Enter
   - Go to "Advanced" tab
   - Click "Environment Variables"

2. **Edit PATH:**
   - Under "User variables", find "Path"
   - Click "Edit"
   - Click "New"
   - Add: `C:\src\flutter\bin`
   - Click "OK" on all dialogs

3. **Verify PATH:**
   - Open NEW PowerShell window
   - Run: `flutter --version`

### Step 3: Run Flutter Doctor

Open PowerShell and run:

```powershell
flutter doctor
```

This will check for:
- ✅ Flutter SDK (should be OK now)
- ⚠️ Android toolchain (optional for now)
- ⚠️ Visual Studio (optional)
- ⚠️ VS Code (you already have this!)

### Step 4: Accept Android Licenses (if needed)

If you plan to run on Android:

```powershell
flutter doctor --android-licenses
```

Press `y` to accept all licenses.

### Step 5: Install VS Code Flutter Extension

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "Flutter"
4. Install "Flutter" by Dart Code
5. This will also install "Dart" extension

## 🚀 Quick Start Your App

Once Flutter is installed:

```powershell
# Navigate to your Flutter app
cd "c:\Users\omara\OneDrive\Desktop\Horus Sight Technologies\Projects\Train System\flutter_app"

# Get dependencies
flutter pub get

# Run on Chrome (easiest for testing)
flutter run -d chrome

# Or run on Android emulator
flutter run

# Or run on connected device
flutter devices
flutter run -d <device-id>
```

## 🌐 Alternative: Run on Web (Easiest!)

If you don't want to setup Android/iOS, use Chrome:

```powershell
# Enable web support
flutter config --enable-web

# Run on Chrome
flutter run -d chrome
```

Your app will open in Chrome browser - perfect for testing!

## 📱 Testing Options

### Option 1: Chrome (Recommended - No Setup!)
```powershell
flutter run -d chrome
```
✅ No additional setup needed
✅ Fast hot reload
✅ Easy debugging

### Option 2: Android Emulator
1. Install Android Studio
2. Open AVD Manager
3. Create virtual device
4. Start emulator
5. Run: `flutter run`

### Option 3: Physical Device
1. Enable Developer Mode on phone
2. Enable USB Debugging
3. Connect via USB
4. Run: `flutter run`

## ⚡ After Installation

### Update API URL (if testing on physical device)

Edit: `flutter_app\lib\config\app_config.dart`

```dart
class AppConfig {
  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // For Physical Device (replace with your PC's IP)
  // static const String baseUrl = 'http://192.168.1.XXX:3000/api';
  
  // For Chrome/Web
  // static const String baseUrl = 'http://localhost:3000/api';
}
```

### Start Backend Server

Before running Flutter:

```cmd
cd "c:\Users\omara\OneDrive\Desktop\Horus Sight Technologies\Projects\Train System"
npm start
```

Server should be running on: http://localhost:3000

## 🔧 Troubleshooting

### "flutter: command not found"
- Close and reopen PowerShell/Terminal
- Verify PATH was added correctly
- Restart VS Code

### "Unable to find git"
Download Git: https://git-scm.com/download/win

### "Android SDK not found"
You can skip Android for now and use Chrome:
```powershell
flutter run -d chrome
```

### Port 3000 already in use
```cmd
netstat -ano | findstr :3000
taskkill /PID <pid> /F
```

## 📚 Useful Commands

```powershell
# Check Flutter installation
flutter doctor -v

# List available devices
flutter devices

# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Run with hot reload
flutter run

# Build APK (Android)
flutter build apk

# Build for web
flutter build web
```

## 🎯 Next Steps After Installation

1. ✅ Install Flutter SDK
2. ✅ Add to PATH
3. ✅ Run `flutter doctor`
4. ✅ Install VS Code Flutter extension
5. ✅ Navigate to flutter_app folder
6. ✅ Run `flutter pub get`
7. ✅ Start backend server (npm start)
8. ✅ Run `flutter run -d chrome`
9. 🎉 Test your train booking app!

## 💡 Pro Tips

- Use **Chrome** for fastest testing (no emulator setup needed)
- Enable hot reload: Save file = instant UI update
- Use Flutter DevTools for debugging
- Check `flutter doctor` if anything breaks

## 📞 Need Help?

Common issues and solutions:
- **PATH not working**: Restart computer
- **Git missing**: Install from git-scm.com
- **Android issues**: Use Chrome instead
- **Backend not connecting**: Check firewall settings

---

**Estimated Installation Time:** 10-15 minutes  
**Recommended Method:** Chrome web for fastest testing  
**Status:** Ready to run once installed! 🚀
