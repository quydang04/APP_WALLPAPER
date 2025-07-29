import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User profile section
          if (user != null) ...[
            _buildSectionHeader(context, 'Account'),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: user.profileImageUrl != null
                    ? null // Would be an image in a real app
                    : Text(
                        user.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              title: Text(user.username),
              subtitle: Text(user.email),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push('/profile');
              },
            ),
            const Divider(),
          ],

          // Appearance section
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark theme'),
            value: themeProvider.isDarkMode,
            onChanged: (_) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.primaryColor,
            ),
          ),
          const Divider(),

          // Notifications section
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications about new wallpapers'),
            value: true, // Would be stored in user preferences in a real app
            onChanged: (_) {
              // Would update user preferences in a real app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'This would toggle notifications in a real app',
                  ),
                ),
              );
            },
            secondary: const Icon(
              Icons.notifications,
              color: AppTheme.primaryColor,
            ),
          ),
          const Divider(),

          // Premium section
          _buildSectionHeader(context, 'Premium'),
          ListTile(
            leading: const Icon(Icons.star, color: AppTheme.accentColor),
            title: const Text('Premium Subscription'),
            subtitle: Text(
              user?.isPremium ?? false
                  ? 'You have an active subscription'
                  : 'Upgrade to premium for exclusive content',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/premium');
            },
          ),
          const Divider(),

          // About section
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: AppTheme.primaryColor,
            ),
            title: const Text('App Version'),
            subtitle: Text(AppConstants.appVersion),
          ),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Would navigate to terms of service in a real app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'This would open Terms of Service in a real app',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: AppTheme.primaryColor,
            ),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Would navigate to privacy policy in a real app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This would open Privacy Policy in a real app'),
                ),
              );
            },
          ),
          const Divider(),

          // Logout button
          if (user != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
