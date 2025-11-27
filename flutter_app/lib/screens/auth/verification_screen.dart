import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerification() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = await authProvider.storageService.getEmail() ?? '';
    
    final response = await authProvider.verifyEmail(
      email: email,
      code: _codeController.text.trim(),
    );

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Verification failed'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  Future<void> _handleResendCode() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = await authProvider.storageService.getEmail() ?? '';
    
    final response = await authProvider.resendCode(email: email);

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code resent!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Failed to resend code'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Verify Your Email',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'We\'ve sent a 6-digit verification code to your email. Please enter it below.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.grayColor,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Code Input
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      hintText: '000000',
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the verification code';
                      }
                      if (value.trim().length != 6) {
                        return 'Code must be 6 digits';
                      }
                      if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
                        return 'Code must contain only numbers';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Verify Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleVerification,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Verify Email'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Resend Code
                  TextButton(
                    onPressed: _handleResendCode,
                    child: const Text('Didn\'t receive code? Resend'),
                  ),
                  const SizedBox(height: 8),

                  // Back to Login
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
