import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values first
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Fetch latest user data from server
    await authProvider.fetchCurrentUser();
    
    final user = authProvider.user;
    _fullNameController.text = user?.fullName ?? '';
    _phoneController.text = user?.phone ?? '';
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await authProvider.updateProfile(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response['message'] ?? 'Profile updated'),
        backgroundColor: response['success'] == true ? AppTheme.successColor : AppTheme.dangerColor,
      ),
    );

    if (response['success'] == true) {
      setState(() => _isEditing = false);
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
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
                          border: Border.all(color: Colors.white, width: 4),
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

                // Profile Form
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fullNameController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: TextEditingController(text: user.email),
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = false;
                                      _fullNameController.text = user.fullName;
                                      _phoneController.text = user.phone ?? '';
                                    });
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading ? null : _handleUpdateProfile,
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Save'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 32),

                        // Logout Button
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

