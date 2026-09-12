import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart';
import '../utils/database_helper.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  String _userName = 'Md Saiduzzaman';
  String _username = '';
  String _userInitials = 'MS';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    String? dbImagePath;
    if (userId != null) {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (maps.isNotEmpty) {
        dbImagePath = maps.first['image_path'] as String?;
      }
    }

    String? finalPath = dbImagePath ?? prefs.getString('profile_image_path');

    if (finalPath != null && !await File(finalPath).exists()) {
      finalPath = null;
      await prefs.remove('profile_image_path');
      if (userId != null) {
        final dbHelper = DatabaseHelper();
        await dbHelper.updateProfileImage(userId, '');
      }
    }

    setState(() {
      _userName = prefs.getString('user_name') ?? 'Md Saiduzzaman';
      _username = prefs.getString('user_username') ?? '';
      _imagePath = finalPath;
      
      if (_userName.isNotEmpty) {
        List<String> parts = _userName.trim().split(' ');
        if (parts.length > 1) {
          _userInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        } else {
          _userInitials = parts[0][0].toUpperCase();
        }
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, 
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final permanentImage = File('${appDir.path}/profile_$fileName.jpg');
      await File(pickedFile.path).copy(permanentImage.path);

      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');

      await prefs.setString('profile_image_path', permanentImage.path);

      if (userId != null) {
        final dbHelper = DatabaseHelper();
        await dbHelper.updateProfileImage(userId, permanentImage.path);
      }

      setState(() {
        _imagePath = permanentImage.path;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    }
  }

  void _showAccountSettingsBottomSheet() {
    TextEditingController nameController = TextEditingController(text: _userName);
    TextEditingController currentPassController = TextEditingController();
    TextEditingController newPassController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: currentPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      
                      if (nameController.text.isNotEmpty) {
                        await prefs.setString('user_name', nameController.text);
                        setState(() {
                          _userName = nameController.text;
                          List<String> parts = _userName.trim().split(' ');
                          if (parts.length > 1) {
                            _userInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
                          } else {
                            _userInitials = parts[0][0].toUpperCase();
                          }
                        });
                      }

                      if (newPassController.text.isNotEmpty) {
                        await prefs.setString('user_password', newPassController.text);
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Account settings updated successfully!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null
                      ? Text(
                          _userInitials,
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('@$_username', style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132F73).withOpacity(0.3) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.manage_accounts_rounded, color: theme.colorScheme.primary),
                  title: const Text('Account Settings', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Change Name & Password', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: _showAccountSettingsBottomSheet,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.dark_mode_rounded, color: theme.colorScheme.primary),
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Switch(
                    value: _isDarkMode,
                    activeThumbColor: theme.colorScheme.primary,
                    onChanged: _toggleTheme,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.help_outline_rounded, color: theme.colorScheme.primary),
                  title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}