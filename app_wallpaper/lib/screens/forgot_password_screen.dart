import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _isSuccess = BoolWrapper(false);
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _isSuccess.value = false;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final didNavigate = await authProvider.resetPassword(
        email: _emailController.text.trim(),
        success: _isSuccess,
      );

      if (didNavigate) context.go('/reset-password');

      if (mounted && !_isSuccess.value) {
        setState(() {
          _errorMessage = 'Failed to send reset link. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isSuccess = _isSuccess.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: isSuccess
                            ? Border.all(
                          color: AppTheme.successColor,
                          width: 2,
                        )
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/favicon.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn()
                      .scale(duration: 300.ms, curve: Curves.easeOutBack),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    isSuccess ? 'Reset Link Sent!' : 'Forgot Password?',
                    style: AppTheme.headingStyle,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    isSuccess
                        ? 'Check your email to reset your password.'
                        : 'Enter your email and we’ll send you a reset link.',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 32),

                  if (_errorMessage != null && !isSuccess) ...[
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

                  if (isSuccess) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.successColor),
                      ),
                      child: Text(
                        'Reset link sent to ${_emailController.text}',
                        style: TextStyle(color: AppTheme.successColor),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn().scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (!isSuccess) ...[
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: Validators.validateEmail,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _resetPassword(),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.3, end: 0),

                    const SizedBox(height: 32),

                    CustomButton(
                      text: 'Send Reset Link',
                      onPressed: _resetPassword,
                      isLoading: authProvider.isLoading,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
                  ],

                  const SizedBox(height: 24),

                  if (!isSuccess)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Remember your password? ', style: AppTheme.bodyStyle),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Login'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
