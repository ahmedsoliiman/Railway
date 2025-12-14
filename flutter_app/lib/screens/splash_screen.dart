import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkAuthStatus();
    
    if (isLoggedIn) {
      await authProvider.loadUser();
      if (mounted) {
        // Check user role and route accordingly
        final user = authProvider.user;
        if (user?.role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.train,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                'Train Booking',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your Journey Starts Here',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

