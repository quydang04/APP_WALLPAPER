import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/premium_provider.dart';
import '../widgets/custom_button.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = false;

  Future<void> _purchasePremium() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final premiumProvider = Provider.of<PremiumProvider>(
        context,
        listen: false,
      );
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to purchase premium'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final success = await premiumProvider.purchasePremium(
        user,
        (updatedUser) => authProvider.updateUser(updatedUser),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium subscription activated!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to purchase premium'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isPremium = user?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Premium'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      isPremium ? 'You are Premium!' : 'Upgrade to Premium',
                      style: AppTheme.headingStyle.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPremium
                          ? 'Enjoy all premium features'
                          : 'Unlock exclusive wallpapers and features',
                      style: AppTheme.bodyStyle.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),

              const SizedBox(height: 32),

              // Features list
              Text(
                'Premium Features',
                style: AppTheme.subheadingStyle,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 16),

              _buildFeatureItem(
                icon: Icons.lock_open,
                title: 'Exclusive Wallpapers',
                description: 'Access to all premium wallpapers',
                delay: 200,
              ),

              _buildFeatureItem(
                icon: Icons.notifications,
                title: 'New Wallpaper Notifications',
                description:
                    'Get notified when new wallpapers are added to your favorite topics',
                delay: 300,
              ),

              _buildFeatureItem(
                icon: Icons.block,
                title: 'Ad-Free Experience',
                description: 'Enjoy the app without any advertisements',
                delay: 400,
              ),

              _buildFeatureItem(
                icon: Icons.download,
                title: 'Unlimited Downloads',
                description: 'Download as many wallpapers as you want',
                delay: 500,
              ),

              const SizedBox(height: 32),

              // Pricing
              if (!isPremium) ...[
                Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Premium Subscription',
                            style: AppTheme.subheadingStyle,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$',
                                style: AppTheme.bodyStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                '${AppConstants.premiumPrice}',
                                style: AppTheme.headingStyle.copyWith(
                                  fontSize: 36,
                                ),
                              ),
                              Text(
                                '/month',
                                style: AppTheme.bodyStyle.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onBackground.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Subscribe Now',
                            onPressed: _purchasePremium,
                            isLoading: _isLoading,
                            backgroundColor: AppTheme.accentColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cancel anytime',
                            style: AppTheme.captionStyle.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: 600.ms,
                      duration: 300.ms,
                    ),
              ] else ...[
                Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.successColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You have an active premium subscription',
                            style: AppTheme.subheadingStyle.copyWith(
                              color: AppTheme.successColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thank you for supporting us!',
                            style: AppTheme.bodyStyle,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                    ),
              ],

              const SizedBox(height: 32),

              // Alternative option
              if (!isPremium) ...[
                Text(
                  'Other Ways to Unlock Premium Content',
                  style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.videocam, size: 40, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text(
                        'Watch Videos',
                        style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Watch ${AppConstants.videosToUnlockWallpaper} videos to unlock a premium wallpaper',
                        style: AppTheme.bodyStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.accentColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                ),
                Text(
                  description,
                  style: AppTheme.bodyStyle.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay));
  }
}
