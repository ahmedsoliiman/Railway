import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/tour_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/tours/tours_screen.dart';
import 'screens/tours/tour_detail_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/booking/my_bookings_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TourProvider()),
      ],
      child: MaterialApp(
        title: 'Train Booking System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/verification': (context) => const VerificationScreen(),
          '/home': (context) => const HomeScreen(),
          '/tours': (context) => const ToursScreen(),
          '/tour-detail': (context) => const TourDetailScreen(),
          '/booking': (context) => const BookingScreen(),
          '/my-bookings': (context) => const MyBookingsScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
