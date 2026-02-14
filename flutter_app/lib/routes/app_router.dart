import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/verification_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verify_reset_code_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/main_screen.dart';
import '../screens/trips/trips_screen.dart';
import '../screens/trips/trip_detail_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/payment_screen.dart';
import '../screens/booking/ticket_screen.dart';
import '../screens/booking/my_bookings_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/manager/manager_dashboard_screen.dart';
import '../screens/reviews/trip_reviews_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/verification',
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-reset-code',
        builder: (context, state) =>
            VerifyResetCodeScreen(email: state.extra as String),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ResetPasswordScreen(
            email: extra['email'] as String,
            code: extra['code'] as String,
          );
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/trips',
        builder: (context, state) => const TripsScreen(),
      ),
      GoRoute(
        path: '/trip-detail',
        builder: (context, state) =>
            TripDetailScreen(tripId: state.extra as int),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) => BookingScreen(tripId: state.extra as int),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) =>
            PaymentScreen(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: '/ticket',
        builder: (context, state) =>
            TicketScreen(args: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: '/my-bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/manager',
        builder: (context, state) => const ManagerDashboardScreen(),
      ),
      GoRoute(
        path: '/trip-reviews',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return TripReviewsScreen(
            tripId: extra['tripId'] as int,
            tripName: extra['tripName'] as String,
          );
        },
      ),
    ],
  );
}
