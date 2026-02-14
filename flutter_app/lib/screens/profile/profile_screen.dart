import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Fetch latest user data from server
    await authProvider.fetchCurrentUser();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                if (user == null) {
                  return const Center(child: Text('Please login'));
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Header
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4),
                              ),
                              child: Center(
                                child: Text(
                                  user.fullName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: const Text('Full Name'),
                                subtitle: Text(user.fullName),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.email_outlined),
                                title: const Text('Email'),
                                subtitle: Text(user.email),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _handleLogout,
                                icon: const Icon(Icons.logout),
                                label: const Text('Logout'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.dangerColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
