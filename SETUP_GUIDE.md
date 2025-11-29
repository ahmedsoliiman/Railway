# 🚀 Project Setup Guide for New Developers

## Prerequisites

Before running this project, ensure you have:

1. **Node.js** (v16 or higher) - [Download](https://nodejs.org/)
2. **PostgreSQL** (v12 or higher) - [Download](https://www.postgresql.org/download/)
3. **Flutter SDK** (v3.0+) - [Download](https://docs.flutter.dev/get-started/install)
4. **Git** - [Download](https://git-scm.com/)

## 📋 Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Railway-System
```

### 2. Set Up PostgreSQL Database

**Option A: Using pgAdmin**
1. Open pgAdmin
2. Create a new database named `train_system`
3. Note your PostgreSQL port (default: 5432, this project uses: 5433)
4. Note your PostgreSQL password

**Option B: Using Command Line**
```bash
# Login to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE train_system;

# Exit
\q
```

### 3. Configure Backend

```bash
cd Backend
npm install
```

**Create/Update `.env` file:**

Create a file named `.env` in the `Backend` folder with these values:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=5433
DB_NAME=train_system
DB_USER=postgres
DB_PASSWORD=YOUR_POSTGRES_PASSWORD

# JWT Secret
JWT_SECRET=train_booking_secret_key_2024_change_in_production
JWT_EXPIRE=7d

# Email Configuration (Gmail)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
EMAIL_FROM=Train Booking System <your_email@gmail.com>

# Frontend URL (for CORS)
CLIENT_URL=http://localhost:3000
```

**IMPORTANT:** Replace:
- `YOUR_POSTGRES_PASSWORD` with your actual PostgreSQL password
- `your_email@gmail.com` with your Gmail address
- `your_app_password` with Gmail App Password (see Email Setup below)

### 4. Run Database Migrations

```bash
npm run migrate
```

This will create all tables and insert sample data.

**If you get a connection error:**
- Check PostgreSQL is running
- Verify DB_PORT matches your PostgreSQL port
- Verify DB_PASSWORD is correct
- Check if database `train_system` exists

### 5. Start Backend Server

```bash
npm start
```

Server should run on: http://localhost:3000

### 6. Set Up Flutter App

```bash
cd ../flutter_app
flutter pub get
```

**Update API URL for your environment:**

Edit `lib/config/app_config.dart`:

```dart
// For Chrome/Web
static const String baseUrl = 'http://localhost:3000/api';

// For Android Emulator
// static const String baseUrl = 'http://10.0.2.2:3000/api';

// For Physical Device (replace with your PC's IP)
// static const String baseUrl = 'http://192.168.1.XXX:3000/api';
```

### 7. Run Flutter App

**For Chrome (easiest):**
```bash
flutter run -d chrome
```

**For Android Emulator:**
```bash
flutter run
```

## 📧 Email Setup (Optional but Recommended)

To enable email verification:

1. **Enable 2-Factor Authentication** on your Gmail:
   - Go to https://myaccount.google.com/security
   - Enable "2-Step Verification"

2. **Generate App Password**:
   - Go to https://myaccount.google.com/apppasswords
   - Select "Mail" and "Windows Computer"
   - Click "Generate"
   - Copy the 16-character password

3. **Update `.env`**:
   ```env
   EMAIL_USER=your_email@gmail.com
   EMAIL_PASSWORD=abcd efgh ijkl mnop  # (no spaces in actual file)
   ```

## 🔧 Common Issues & Solutions

### Issue: "ECONNREFUSED" or Connection Timeout

**Solution:**
- Ensure PostgreSQL is running
- Check if port 5433 is correct (or change to 5432)
- Verify database `train_system` exists
- Check DB_PASSWORD in `.env` is correct

```bash
# Test PostgreSQL connection
psql -U postgres -d train_system -p 5433
```

### Issue: "Port 3000 already in use"

**Solution:**
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <pid> /F

# Linux/Mac
lsof -ti:3000 | xargs kill -9
```

### Issue: CORS Error in Flutter App

**Solution:**
- Ensure backend is running
- Check API URL in `app_config.dart` matches your setup
- Restart both backend and Flutter app

### Issue: Flutter not found

**Solution:**
```bash
# Check Flutter installation
flutter doctor

# If not installed, download from:
# https://docs.flutter.dev/get-started/install
```

### Issue: Migration fails with "relation already exists"

**Solution:**
The tables already exist. You can either:
1. Drop and recreate database:
```sql
DROP DATABASE train_system;
CREATE DATABASE train_system;
```
2. Or skip migration if tables are already set up

## 🎯 Default Credentials

### Admin Dashboard
- URL: http://localhost:3000/admin
- Email: admin@trainbooking.com
- Password: Admin@123

### Test User (create via signup)
- Register through the Flutter app
- Verify email with 6-digit code

## 📱 Testing the Complete System

1. **Start Backend:**
   ```bash
   cd Backend
   npm start
   ```

2. **Start Flutter App:**
   ```bash
   cd flutter_app
   flutter run -d chrome
   ```

3. **Test Flow:**
   - Sign up with your email
   - Check email for verification code
   - Verify account
   - Browse available tours
   - Book a ticket
   - Check "My Bookings"

## 🛠️ Development Commands

```bash
# Backend
npm start              # Start server
npm run migrate        # Run migrations
npm run dev           # Start with nodemon (auto-reload)

# Flutter
flutter pub get       # Install dependencies
flutter run          # Run app
flutter clean        # Clean build files
flutter doctor       # Check setup
```

## 📚 Project Structure

```
Railway-System/
├── Backend/
│   ├── src/
│   │   ├── config/         # Database config
│   │   ├── database/       # Migrations
│   │   ├── middleware/     # Auth, validation
│   │   ├── routes/         # API routes
│   │   └── utils/          # Email service
│   ├── public/             # Admin dashboard
│   ├── .env               # Environment variables
│   └── server.js          # Main server file
│
└── flutter_app/
    ├── lib/
    │   ├── config/        # App config, theme
    │   ├── models/        # Data models
    │   ├── providers/     # State management
    │   ├── screens/       # UI screens
    │   └── services/      # API, storage
    └── pubspec.yaml      # Flutter dependencies
```

## 🔗 Important URLs

- Backend API: http://localhost:3000
- Admin Dashboard: http://localhost:3000/admin
- API Documentation: http://localhost:3000/api
- Flutter App: http://localhost:55881 (or random port)

## 💡 Tips

1. **Always start backend before Flutter app**
2. **Check terminal logs for errors**
3. **Use Chrome for fastest testing** (no emulator setup)
4. **Keep PostgreSQL running** while developing
5. **Restart backend after `.env` changes**

## 🆘 Need Help?

1. Check terminal logs for detailed errors
2. Verify all prerequisites are installed
3. Ensure `.env` file is configured correctly
4. Make sure PostgreSQL is running
5. Check if ports 3000 and 5433 are available

---

**Happy Coding! 🚂✨**
