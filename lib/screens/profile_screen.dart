import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Profile Picture
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 2),
              ),
              child: Center(
                child: Text(
                  'MS',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // User Info
            const Text(
              'Md Saiduzzaman',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'CSE, Southeast University',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            // Settings Options
            _buildProfileOption(
              context: context,
              icon: Icons.settings_rounded,
              title: 'Account Settings',
              onTap: () {},
            ),
            const SizedBox(height: 14),
            _buildProfileOption(
              context: context,
              icon: Icons.dark_mode_rounded,
              title: 'Dark Mode',
              trailing: Switch(
                value: isDark,
                onChanged: (val) {
                  // থিম ম্যানেজমেন্ট যুক্ত করার পর এটি কাজ করবে
                },
                activeThumbColor: theme.colorScheme.primary,
              ),
              onTap: () {},
            ),
            const SizedBox(height: 14),
            _buildProfileOption(
              context: context,
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () {},
            ),
            const SizedBox(height: 40),
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  foregroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 22),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor ?? (isDark ? Colors.transparent : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}