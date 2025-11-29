# Git Pull Merge Conflict - Troubleshooting Guide

## Problem
When pulling the project, you see an error:
```
error: Your local changes to the following files would be overwritten by merge:
    flutter_app/.dart_tool/...
```

## Solution

Your friend should follow these steps to resolve the issue:

### Step 1: Stash or Discard Local Changes

#### Option A: Discard all local changes (recommended for first-time pull)
```bash
cd "C:\Path\To\Train System"
git reset --hard HEAD
git clean -fd
git pull origin main
```

#### Option B: Keep local changes and reapply them
```bash
git stash
git pull origin main
git stash pop
```

### Step 2: Clean Flutter Generated Files
```bash
cd flutter_app
flutter clean
flutter pub get
```

### Step 3: Verify the Pull
```bash
git status
```

## Why This Happened

The `.dart_tool/` directory contains Flutter-generated files that should not be in version control. These files are automatically created when running Flutter commands and can cause conflicts.

## Prevention (Already Fixed)

I've added proper `.gitignore` files to the project:
- Root `.gitignore` for general files
- `flutter_app/.gitignore` for Flutter-specific files

After you push these changes, your friend should:

1. **First Time Setup:**
```bash
# Remove tracked .dart_tool if it exists
git rm -r --cached flutter_app/.dart_tool/
git commit -m "Remove .dart_tool from version control"
git push origin main
```

2. **Your friend should then:**
```bash
git pull origin main
cd flutter_app
flutter clean
flutter pub get
```

## Quick Fix for Your Friend (Right Now)

Tell your friend to run these commands in order:

```bash
# Navigate to project
cd "C:\Users\[username]\Path\To\Train System"

# Force discard local changes
git reset --hard HEAD
git clean -fd

# Pull latest changes
git pull origin main

# Clean and reinstall Flutter dependencies
cd flutter_app
flutter clean
flutter pub get
```

## Running the Project

### Backend
```bash
cd Backend
npm install
npm start
```

### Flutter App
```bash
cd flutter_app
flutter run -d chrome
# or
flutter run -d windows
```

## If Issues Persist

### Complete Clean Reinstall
```bash
# Delete local repository
# Re-clone fresh copy
git clone https://github.com/3atofa/Railway-System.git
cd Railway-System

# Setup Backend
cd Backend
npm install

# Setup Flutter
cd ../flutter_app
flutter clean
flutter pub get
flutter run -d chrome
```

## Default Credentials for Testing

**Regular User:**
- Email: test@example.com
- Password: Test@123

**Admin:**
- Email: admin@trainbooking.com
- Password: Admin@123

## Common Flutter Issues

### Issue: "flutter: command not found"
**Solution:** Install Flutter SDK from https://flutter.dev

### Issue: "No devices found"
**Solution:** 
```bash
flutter doctor
# Follow the instructions to enable web/desktop support
flutter config --enable-web
```

### Issue: Package version conflicts
**Solution:**
```bash
flutter clean
flutter pub upgrade
flutter pub get
```

---

## Contact
If you continue to have issues, please share:
1. The exact error message
2. Your operating system
3. Flutter version (`flutter --version`)
4. Git version (`git --version`)
