# Train Booking Mobile App

A professional Flutter mobile application for train ticket booking.

## Features

- User Registration with Email Verification
- Login/Logout
- Browse Available Tours
- Search and Filter Tours
- Book Train Tickets
- View Booking History
- Manage User Profile
- Real-time Seat Availability

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
- Password: Admin@123

## Screenshots

[Add screenshots here]

## License

ISC
