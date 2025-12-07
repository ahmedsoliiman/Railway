# Train Booking Mobile App

A professional Flutter mobile application for train ticket booking with multi-class seat support.

## Features

### User Features
- ✅ User Registration with Email Verification
- ✅ Login/Logout with Role-Based Routing
- ✅ Browse Available Tours
- ✅ Advanced Search and Filter Tours (Date, Seat Class)
- ✅ Multi-Class Booking (First Class & Second Class with different pricing)
- ✅ View Booking History (Upcoming/Past tabs)
- ✅ Cancel Bookings
- ✅ Manage User Profile
- ✅ Real-time Seat Availability

### Admin Features
- ✅ Admin Dashboard with Real-Time Statistics
- ✅ Stations Management (Full CRUD)
- ✅ Trains Management (Full CRUD with class configuration)
- ✅ Tours Management (Full CRUD with dual pricing)
- ✅ Reservations Overview (View all bookings)
- ✅ Train Types: Express, Premium, Standard
- ✅ Train Status: Active, Maintenance, Retired
- ✅ Tour Status: Scheduled, Boarding, Departed, Arrived, Cancelled

## Setup

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode (for iOS)
- Backend API running on http://localhost:3000

### Installation

1. Install dependencies:
```bash
cd flutter_app
flutter pub get
```

2. Update API URL (if needed):
   - Open `lib/services/api_service.dart`
   - Update `baseUrl` to your backend URL

3. Run the app:
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── config/
│   ├── app_config.dart      # App configuration
│   └── theme.dart           # App theme
├── models/                  # Data models
│   ├── user.dart
│   ├── tour.dart
│   ├── station.dart
│   └── reservation.dart
├── services/                # API & Storage services
│   ├── api_service.dart
│   └── storage_service.dart
├── providers/               # State management
│   ├── auth_provider.dart
│   └── tour_provider.dart
├── screens/                 # UI Screens
│   ├── auth/
│   ├── home/
│   ├── tours/
│   ├── booking/
│   └── profile/
└── widgets/                 # Reusable widgets
    ├── custom_button.dart
    ├── custom_textfield.dart
    └── tour_card.dart
```

## Backend API

Make sure the Node.js backend is running on port 3000:
```bash
cd ..
npm start
```

## Default Credentials

For testing, you can register a new user or use:
- Email: test@example.com
- Password: Test@123

Admin Dashboard: http://localhost:3000/admin
- Email: admin@trainbooking.com
- Password: password123

## Screenshots

[Add screenshots here]

## License

ISC
