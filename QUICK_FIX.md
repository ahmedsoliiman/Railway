# Quick Fix for Git Pull Error

## ⚡ Fast Solution

Your friend should copy and paste these commands in order:

### 1. Navigate to Project
```bash
cd "C:\Users\[YourUsername]\Path\To\Train System"
```

### 2. Force Clean Pull
```bash
git reset --hard HEAD
git clean -fd
git pull origin main
```

### 3. Clean Flutter
```bash
cd flutter_app
flutter clean
flutter pub get
```

## ✅ What This Does

1. **git reset --hard HEAD** - Discards all local changes
2. **git clean -fd** - Removes untracked files and directories
3. **git pull origin main** - Pulls latest changes from GitHub
4. **flutter clean** - Removes generated Flutter files
5. **flutter pub get** - Reinstalls Flutter dependencies

## 🎯 Why The Error Happened

The `.dart_tool/` and `build/` directories contain auto-generated Flutter files. They were accidentally committed to Git but are now properly excluded via `.gitignore`.

## 📝 After Pull, To Run The App

### Backend
```bash
cd Backend
npm install
npm start
```
**Backend runs on:** http://localhost:3000

### Flutter App
```bash
cd flutter_app
flutter run -d chrome
```

## 🔑 Login Credentials

**Admin:**
- Email: admin@trainbooking.com
- Password: Admin@123

**Test User:**
- Email: test@example.com
- Password: Test@123

## ❓ If Still Having Issues

See full troubleshooting guide in: `GIT_TROUBLESHOOTING.md`

---

**The issue is now fixed!** After pulling the latest changes, the `.dart_tool` files are properly ignored and won't cause conflicts anymore.
