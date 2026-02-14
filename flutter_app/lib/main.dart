import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/trip_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/review_provider.dart';
import 'routes/app_router.dart';
import 'providers/manager_provider.dart';
import 'services/notification_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase (required for FCM)
    await Firebase.initializeApp();
    print('✅ Firebase initialized');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    // Continue - notifications will not work but app will still function
  }

  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    print('✅ Supabase initialized');
  } catch (e) {
    print('Supabase initialization failed: $e');
    // Continue running app to show UI, but services might fail
  }

  runApp(const MyApp());

  // Background pre-fetching and notification setup
  _preFetchData();
}

Future<void> _preFetchData() async {
  try {
    // Initialize notification service in background
    await NotificationService().initialize();

    // We can't use Provider.of here because there's no context yet.
    // However, the services themselves can start warming up or we can
    // trigger static initializers if any.
    // For now, the most effective way is to ensure Supabase is ready
    // and maybe trigger an early fetch of stations which are used everywhere.
  } catch (e) {
    print('Pre-fetch failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ManagerProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: MaterialApp.router(
        title: 'Railway System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
