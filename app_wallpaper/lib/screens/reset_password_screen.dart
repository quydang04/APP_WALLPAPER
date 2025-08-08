import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _confirmResetPassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Passwords do not match.';
        });
        return;
      }

      setState(() {
        _errorMessage = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.confirmResetPassword(
        newPassword: _newPasswordController.text.trim(),
      );

      if (success && mounted) {
        context.go('/login'); // Go to Login after successful reset
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Failed to reset password. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/favicon.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ).animate().fadeIn().scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Reset Your Password',
                    style: AppTheme.headingStyle,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Enter your new password below.',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 32),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.errorColor),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: AppTheme.errorColor),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn().shake(),

                    const SizedBox(height: 16),
                  ],

                  // New Password Field
                  CustomTextField(
                    label: 'New Password',
                    hint: 'Enter new password',
                    controller: _newPasswordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: Validators.validatePassword,
                    textInputAction: TextInputAction.next,
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 16),

                  // Confirm Password Field
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter new password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: Validators.validatePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _confirmResetPassword(),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 24),

                  // Confirm Reset Button
                  CustomButton(
                    text: 'Confirm Reset',
                    onPressed: _confirmResetPassword,
                    isLoading: authProvider.isLoading,
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 24),

                  // Back to Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Back to ',
                        style: AppTheme.bodyStyle,
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
