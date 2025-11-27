# 🚂 Train Booking System - Complete Installation Guide

## ✅ What's Been Created

### Backend (Node.js + PostgreSQL)
- ✅ RESTful API with Express.js
- ✅ PostgreSQL database (port 5433)
- ✅ JWT Authentication with email verification
- ✅ Admin dashboard (HTML/CSS/JS)
- ✅ User management system
- ✅ Stations, trains, and tours management
- ✅ Booking and reservation system

### Flutter Mobile App
- ✅ Professional UI with Material Design
- ✅ State management with Provider
- ✅ Authentication (Login/Signup/Verification)
- ✅ Tour browsing and booking
- ✅ User profile management
- ✅ Booking history

## 📋 Prerequisites

### Backend Requirements
- Node.js (v14+)
- PostgreSQL (running on port 5433)
- npm or yarn

### Flutter Requirements
- Flutter SDK (3.0+)
- Android Studio or Xcode
- Android Emulator or iOS Simulator

## 🚀 Step-by-Step Installation

### Part 1: Backend Setup (COMPLETED ✅)

1. **Database is already created and migrated**
   - Database name: `train_system`
   - Port: 5433
   - Password: testpass

2. **Start the backend server:**
   ```cmd
   cd "c:\Users\omara\OneDrive\Desktop\Horus Sight Technologies\Projects\Train System"
   npm start
   ```

3. **Backend will run on:** `http://localhost:3000`

4. **Admin Dashboard:** `http://localhost:3000/admin`
   - Email: admin@trainbooking.com
   - Password: Admin@123

### Part 2: Flutter App Setup

1. **Navigate to Flutter app directory:**
   ```cmd
   cd "c:\Users\omara\OneDrive\Desktop\Horus Sight Technologies\Projects\Train System\flutter_app"
   ```

2. **Install Flutter dependencies:**
   ```cmd
   flutter pub get
   ```

3. **Update API URL (Important for physical devices):**
   - Open `lib/config/app_config.dart`
   - For Android Emulator: Use `http://10.0.2.2:3000/api` (default)
   - For iOS Simulator: Use `http://localhost:3000/api`
   - For Physical Device: Use `http://YOUR_COMPUTER_IP:3000/api`

4. **Run the Flutter app:**
   ```cmd
   # List available devices
   flutter devices

   # Run on specific device
   flutter run -d <device_id>

   # Or just
   flutter run
   ```

## 🎯 Testing the Application

### Test User Registration

1. **Start Backend Server** (Terminal 1):
   ```cmd
   cd "c:\Users\omara\OneDrive\Desktop\Horus Sight Technologies\Projects\Train System"
   npm start
   ```

2. **Start Flutter App** (Terminal 2):
   ```cmd
   cd "c:\Users\omara\OneDrive\Desktop\Horus Sight Technologies\Projects\Train System\flutter_app"
   flutter run
   ```

3. **Register New User:**
   - Open the app
   - Tap "Sign Up"
   - Fill in details
   - Enter 6-digit verification code from console/email
   - Login with your credentials

4. **Browse and Book Tours:**
   - Search for available tours
   - Select origin and destination
   - Choose a tour
   - Select seat class (First/Second)
   - Confirm booking
   - View in "My Bookings"

### Test Admin Dashboard

1. Open browser: `http://localhost:3000/admin`
2. Login with admin credentials
3. Manage:
   - Stations (Add/Edit/Delete)
   - Trains (Add/Edit/Delete)
   - Tours (Add/Edit/Delete)
   - View all reservations

## 📱 Flutter App Features

### Authentication
- ✅ User Registration
- ✅ Email Verification (6-digit code)
- ✅ Login/Logout
- ✅ Profile Management

### Tour Booking
- ✅ Browse available tours
- ✅ Search by origin/destination
- ✅ Filter by date
- ✅ View tour details
- ✅ Real-time seat availability
- ✅ First/Second class options

### My Bookings
- ✅ View upcoming bookings
- ✅ View past bookings
- ✅ Cancel bookings (2+ hours before departure)
- ✅ Booking reference numbers

### Profile
- ✅ View user information
- ✅ Update profile details
- ✅ Logout

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/signup` - Register user
- `POST /api/auth/login` - Login
- `POST /api/auth/verify-email` - Verify email
- `POST /api/auth/resend-code` - Resend verification code
- `GET /api/auth/me` - Get current user

### Tours
- `GET /api/tours` - Get all tours (with filters)
- `GET /api/tours/:id` - Get tour details

### Reservations
- `POST /api/reservations` - Create booking
- `GET /api/reservations` - Get user bookings
- `DELETE /api/reservations/:id` - Cancel booking

### Stations
- `GET /api/stations` - Get all stations

### Profile
- `GET /api/profile` - Get profile
- `PUT /api/profile` - Update profile

## 🗄️ Database Schema

### Tables
- `users` - User accounts
- `email_verifications` - Email verification codes
- `stations` - Train stations
- `trains` - Train information
- `tours` - Scheduled tours
- `reservations` - User bookings

### Sample Data
- ✅ 5 stations (Cairo, Alexandria, Aswan, Luxor, Mansoura)
- ✅ 4 trains with different classes
- ✅ Multiple scheduled tours
- ✅ 1 admin user

## 🔐 Security Features

- Password hashing with bcrypt
- JWT token authentication
- Email verification required
- Protected API routes
- SQL injection prevention
- CORS configuration
- Helmet security headers

## 📝 Environment Configuration

### Backend (.env)
```env
PORT=3000
DB_HOST=localhost
DB_PORT=5433
DB_NAME=train_system
DB_USER=postgres
DB_PASSWORD=testpass
JWT_SECRET=train_booking_secret_key_2024
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
```

### Flutter (lib/config/app_config.dart)
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

## 🐛 Troubleshooting

### Backend Issues

**Port already in use:**
```cmd
# Change PORT in .env file
PORT=3001
```

**Database connection error:**
- Verify PostgreSQL is running on port 5433
- Check database credentials in .env
- Ensure database 'train_system' exists

### Flutter Issues

**Cannot connect to backend:**
- Check baseUrl in `app_config.dart`
- Use correct IP for physical devices
- Ensure backend server is running

**Pub get fails:**
```cmd
flutter clean
flutter pub get
```

**Build errors:**
```cmd
flutter clean
flutter pub get
flutter run
```

## 📞 API Testing with Postman/Thunder Client

### Register User
```http
POST http://localhost:3000/api/auth/signup
Content-Type: application/json

{
  "full_name": "John Doe",
  "email": "john@example.com",
  "password": "Test@123",
  "phone": "1234567890"
}
```

### Login
```http
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "Test@123"
}
```

### Get Tours
```http
GET http://localhost:3000/api/tours
Authorization: Bearer YOUR_TOKEN
```

## 🎨 UI Screenshots Locations

The Flutter app includes:
- Gradient splash screen with train icon
- Modern login/signup forms
- Card-based tour listings
- Detailed tour information
- Booking confirmation screen
- Profile management
- Booking history with status badges

## 🚀 Next Steps

1. **Configure Email Service** (Optional):
   - Update EMAIL_* variables in .env
   - Use Gmail App Password or SMTP service

2. **Customize Theme**:
   - Edit `flutter_app/lib/config/theme.dart`
   - Change colors, fonts, styles

3. **Add More Features**:
   - Payment integration
   - Push notifications
   - Ticket QR codes
   - Reviews and ratings

## 📦 Project Structure

```
Train System/
├── backend/
│   ├── server.js
│   ├── package.json
│   ├── .env
│   ├── src/
│   │   ├── config/
│   │   ├── routes/
│   │   ├── middleware/
│   │   ├── utils/
│   │   └── database/
│   └── public/
│       └── admin/
└── flutter_app/
    ├── pubspec.yaml
    ├── lib/
    │   ├── main.dart
    │   ├── config/
    │   ├── models/
    │   ├── services/
    │   ├── providers/
    │   ├── screens/
    │   └── widgets/
    └── assets/
```

## ✅ Checklist

- [x] Backend server created
- [x] Database created and migrated
- [x] Admin dashboard functional
- [x] Flutter app structure created
- [x] API service layer implemented
- [x] State management configured
- [x] Authentication screens ready
- [ ] Run `npm start` for backend
- [ ] Run `flutter pub get` for dependencies
- [ ] Run `flutter run` to launch app
- [ ] Test user registration
- [ ] Test tour booking
- [ ] Test admin dashboard

## 🎓 Learning Resources

- [Node.js Documentation](https://nodejs.org/docs/)
- [Express.js Guide](https://expressjs.com/)
- [PostgreSQL Tutorial](https://www.postgresql.org/docs/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider State Management](https://pub.dev/packages/provider)

## 📄 License

ISC License - Free to use and modify

---

**Created by:** Train Booking System
**Version:** 1.0.0
**Date:** November 27, 2025
