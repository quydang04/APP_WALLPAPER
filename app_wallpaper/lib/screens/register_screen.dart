import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Registration failed. Please try again.';
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Register'), centerTitle: true),
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
                    'Create Account',
                    style: AppTheme.headingStyle,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 300.ms,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Sign up to discover amazing wallpapers',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 100.ms),

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

                  // Username field
                  CustomTextField(
                        label: 'Username',
                        hint: 'Choose a username',
                        controller: _usernameController,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: Validators.validateUsername,
                        textInputAction: TextInputAction.next,
                      )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        delay: 200.ms,
                        duration: 300.ms,
                      ),

                  const SizedBox(height: 16),

                  // Email field
                  CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: Validators.validateEmail,
                        textInputAction: TextInputAction.next,
                      )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        delay: 300.ms,
                        duration: 300.ms,
                      ),

                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                        label: 'Password',
                        hint: 'Create a password',
                        controller: _passwordController,
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
                      )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        delay: 400.ms,
                        duration: 300.ms,
                      ),

                  const SizedBox(height: 16),

                  // Confirm password field
                  CustomTextField(
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) =>
                            Validators.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _register(),
                      )
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideX(
                        begin: 0.3,
                        end: 0,
                        delay: 500.ms,
                        duration: 300.ms,
                      ),

                  const SizedBox(height: 32),

                  // Register button
                  CustomButton(
                        text: 'Register',
                        onPressed: _register,
                        isLoading: authProvider.isLoading,
                      )
                      .animate()
                      .fadeIn(delay: 600.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 600.ms,
                        duration: 300.ms,
                      ),

                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTheme.bodyStyle,
                      ),
                      TextButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
